"""Measure the multi-agent patterns on the same questions.

Patterns
  before_sproc      ORCHESTRATOR_SPROC agent: tools are stored procedures that call DATA_AGENT_RUN (text only)
  before_mcp_full   orchestrator -> MCP server, specialists return their full response
  now_mcp_apps      orchestrator -> MCP server, specialists return only the result table; charts via MCP Apps
  appendix_toolset  ORCHESTRATOR_TOOLSET agent: borrows the specialists' tools (agent_toolset)

The MCP orchestrator is a small client: one LLM call to pick specialists, one to write the answer.
Token counts come from each agent run's metadata.usage and from the Cortex inference API usage.

Usage:
  export SNOWFLAKE_ACCOUNT=<org>-<account> SNOWFLAKE_USER=<user> SNOWFLAKE_PAT=<token>
  python3 measure.py --pattern all --reps 3
"""
import argparse
import csv
import json
import os
import re
import time
from concurrent.futures import ThreadPoolExecutor

import requests
import snowflake.connector

ACCOUNT = os.environ["SNOWFLAKE_ACCOUNT"]
HOST = f"https://{ACCOUNT.lower().replace('_', '-')}.snowflakecomputing.com"
PAT = os.environ["SNOWFLAKE_PAT"]
DB, SC = "MULTIAGENT_DEMO", "DEMO"
MODEL = "claude-sonnet-4-6"
HDRS = {"Authorization": f"Bearer {PAT}", "X-Snowflake-Authorization-Token-Type": "PROGRAMMATIC_ACCESS_TOKEN",
        "Content-Type": "application/json", "Accept": "application/json"}
MCP_URL = f"{HOST}/api/v2/databases/{DB}/schemas/{SC}/mcp-servers/SPECIALIST_AGENTS_MCP"
FILTERS = {"before_mcp_full": "full", "now_mcp_apps": "content.filter(c, c.type == 'table')"}
SPECIALISTS = {
    "procurement_agent": "purchase orders, spend, units and prices by supplier, part, plant, date",
    "supplier_quality_agent": "inspections, defects, defect rate (PPM), NCRs by supplier, part, plant, date",
    "inventory_agent": "on-hand stock, safety stock, parts below safety stock, days of supply by part and plant",
    "orders_agent": "customer orders, open backlog value, on-time delivery by customer, part, plant, date",
}
ROUTER = ("You are an orchestrator. Specialist agents:\n"
          + "".join(f"- {k}: {v}\n" for k, v in SPECIALISTS.items())
          + 'Call only the specialists the question needs. Return ONLY JSON: '
            '{"calls":[{"agent":"<name>","question":"<question for that agent>"}]}\nQuestion: ')
ANSWER = ("You are an orchestrator. Using the specialist results below, answer the question concisely with "
          "exact values. Charts are already shown to the user.\nQuestion: {q}\nResults:\n{r}")


def usage(meta):
    inp = out = cache = 0
    for t in (meta or {}).get("usage", {}).get("tokens_consumed", []):
        inp += t.get("input_tokens", {}).get("total", 0)
        cache += t.get("input_tokens", {}).get("cache_read", 0)
        out += t.get("output_tokens", {}).get("total", 0)
    return inp, out, cache


def run_agent(name, question):
    url = f"{HOST}/api/v2/databases/{DB}/schemas/{SC}/agents/{name}:run"
    body = {"messages": [{"role": "user", "content": [{"type": "text", "text": question}]}], "stream": False}
    r = requests.post(url, headers=HDRS, json=body, timeout=900)
    r.raise_for_status()
    return r.json()


def complete(prompt):
    body = {"model": MODEL, "stream": False, "messages": [{"role": "user", "content": prompt}]}
    r = requests.post(f"{HOST}/api/v2/cortex/inference:complete", headers=HDRS, json=body, timeout=600)
    r.raise_for_status()
    j = r.json()
    u = j.get("usage", {})
    return j["choices"][0]["message"]["content"], u.get("prompt_tokens", 0) + u.get("completion_tokens", 0)


def mcp_call(tool, args):
    body = {"jsonrpc": "2.0", "id": 1, "method": "tools/call", "params": {"name": tool, "arguments": args}}
    r = requests.post(MCP_URL, headers=HDRS, json=body, timeout=900)
    r.raise_for_status()
    j = r.json()
    if "error" in j:
        raise RuntimeError(json.dumps(j["error"])[:300])
    return j["result"]


def correct(text, q):
    nums = [float(n.replace(",", "")) for n in re.findall(r"\d[\d,]*\.?\d*", text)]
    tol = max(1.0, abs(q["gt_value"]) * 0.005)
    return q["gt_label"].lower() in text.lower() and any(abs(n - q["gt_value"]) <= tol for n in nums)


def agent_pattern(pattern, q, cur):
    name = {"before_sproc": "ORCHESTRATOR_SPROC", "appendix_toolset": "ORCHESTRATOR_TOOLSET"}[pattern]
    t0 = cur.execute("select current_timestamp()").fetchone()[0]
    start = time.time()
    r = run_agent(name, q["question"])
    secs = time.time() - start
    o_in, o_out, cache = usage(r.get("metadata"))
    s_in = s_out = calls = 0
    if pattern == "before_sproc":  # specialist usage is logged by the wrapper procedures
        for (u,) in cur.execute(f"select usage from {DB}.{SC}.SPECIALIST_USAGE_LOG where logged_at > %s", (t0,)):
            i, o, c = usage({"usage": json.loads(u) if u else {}})
            s_in, s_out, cache, calls = s_in + i, s_out + o, cache + c, calls + 1
    blocks = r.get("content", [])
    text = json.dumps([b for b in blocks if b.get("type") in ("text", "table")])
    return dict(orchestrator_tokens=o_in + o_out, specialist_tokens=s_in + s_out, cache_read=cache,
                specialist_calls=calls, bytes_to_orchestrator=0, secs=secs,
                chart=any(b.get("type") == "chart" for b in blocks), correct=correct(text, q))


def mcp_pattern(pattern, q):
    start = time.time()
    plan, router_tok = complete(ROUTER + q["question"])
    calls = json.loads(re.search(r"\{.*\}", plan, re.S).group(0))["calls"]
    s_tok = cache = nbytes = 0
    chart, results = False, []
    for call in calls:
        res = mcp_call(call["agent"], {"text": call["question"], "content_cel_filter": FILTERS[pattern]})
        txt = res["content"][0]["text"]
        results.append(f"[{call['agent']}]\n{txt}")
        nbytes += len(txt)
        i, o, c = usage(json.loads(txt).get("metadata"))
        s_tok, cache = s_tok + i + o, cache + c
        app = (res.get("structuredContent") or {}).get("_mcp_app") or {}
        if pattern == "now_mcp_apps":  # "before" predates MCP Apps, so only count it for the new pattern
            chart |= any(b.get("type") == "chart" for b in app.get("blocks", []))
    answer, answer_tok = complete(ANSWER.format(q=q["question"], r="\n\n".join(results)))
    return dict(orchestrator_tokens=router_tok + answer_tok, specialist_tokens=s_tok, cache_read=cache,
                specialist_calls=len(calls), bytes_to_orchestrator=nbytes, secs=time.time() - start,
                chart=chart, correct=correct(answer, q))


def run_one(pattern, q, rep, cur):
    try:
        row = agent_pattern(pattern, q, cur) if pattern in ("before_sproc", "appendix_toolset") else mcp_pattern(pattern, q)
        row["error"] = ""
    except Exception as e:  # keep going; failures are reported in the CSV
        row = dict(error=str(e)[:200])
    row.update(pattern=pattern, question=q["id"], rep=rep)
    row["total_tokens"] = row.get("orchestrator_tokens", 0) + row.get("specialist_tokens", 0)
    print({k: (round(v, 1) if isinstance(v, float) else v) for k, v in row.items()}, flush=True)
    return row


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pattern", default="all",
                    choices=["all", "before_sproc", "before_mcp_full", "now_mcp_apps", "appendix_toolset"])
    ap.add_argument("--reps", type=int, default=3)
    a = ap.parse_args()
    here = os.path.dirname(os.path.abspath(__file__))
    questions = json.load(open(os.path.join(here, "questions.json")))
    patterns = ["before_sproc", "before_mcp_full", "now_mcp_apps", "appendix_toolset"] if a.pattern == "all" else [a.pattern]
    conn = snowflake.connector.connect(account=ACCOUNT, host=HOST.removeprefix("https://"),
                                       user=os.environ["SNOWFLAKE_USER"],
                                       authenticator="PROGRAMMATIC_ACCESS_TOKEN", token=PAT)
    rows = []
    for p in patterns:
        jobs = [(q, r) for r in range(a.reps) for q in questions]
        if p == "before_sproc":  # sequential, so logged specialist usage maps to the right run
            rows += [run_one(p, q, r, conn.cursor()) for q, r in jobs]
        else:
            with ThreadPoolExecutor(4) as ex:
                rows += list(ex.map(lambda j: run_one(p, j[0], j[1], conn.cursor()), jobs))
    os.makedirs(os.path.join(here, "results"), exist_ok=True)
    out = os.path.join(here, "results", f"results_{a.pattern}.csv")
    cols = ["pattern", "question", "rep", "total_tokens", "orchestrator_tokens", "specialist_tokens",
            "cache_read", "specialist_calls", "bytes_to_orchestrator", "secs", "chart", "correct", "error"]
    with open(out, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=cols, extrasaction="ignore")
        w.writeheader()
        w.writerows(rows)
    print("wrote", out)


if __name__ == "__main__":
    main()
