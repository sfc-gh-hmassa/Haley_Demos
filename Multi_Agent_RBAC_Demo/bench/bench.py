"""Multi-agent delegation benchmark: compare agent_toolset vs MCP sub-agent delegation.

A  SINGLE_AGENT           both semantic views on one agent
B  MASTER_TOOLSET_AGENT   agent_toolset over SALES_AGENT + INVENTORY_AGENT
C1 python master -> MCP sub-agents, content_cel_filter=full
C2 same, compact
C3 same, CEL table-only (structured result_set pass-through)

C masters use /cortex/inference:complete for routing + final answer/chart spec,
so master tokens are measured directly and sub-agent tokens come from each
sub-agent run's metadata.usage.
"""
import csv
import json
import re
import sys
from concurrent.futures import ThreadPoolExecutor

import requests

import client as c

MASTER_MODEL = "claude-sonnet-4-6"
QUESTIONS = json.load(open("questions.json"))
FILTERS = {"C1_mcp_full": "full", "C2_mcp_compact": "compact",
           "C3_mcp_table_only": "content.filter(c, c.type == 'table')"}
ROUTER_PROMPT = """You are a master orchestrator. Available sub-agents:
- sales_agent: sales orders, revenue, units by product, region, date
- inventory_agent: inventory on hand, safety stock, value by product, plant, date
Return ONLY JSON: {"calls":[{"agent":"sales_agent|inventory_agent","question":"..."}]}
Use one call per needed agent. User question: """
FINAL_PROMPT = """You are a master orchestrator. Sub-agent results are below.
Answer the user question concisely, then output a Vega-Lite v5 JSON spec inside
<chart>...</chart> that charts the answer using inline data values.
User question: {q}
Sub-agent results:
{results}"""


def complete(prompt):
    body = {"model": MASTER_MODEL, "stream": False,
            "messages": [{"role": "user", "content": prompt}]}
    r = requests.post(c.HOST + "/api/v2/cortex/inference:complete", headers=c.HDRS,
                      json=body, timeout=600)
    r.raise_for_status()
    j = r.json()
    u = j.get("usage", {})
    return j["choices"][0]["message"]["content"], u.get("prompt_tokens", 0), u.get("completion_tokens", 0)


def check(text, q):
    """Correct if the ground-truth label and value both appear."""
    nums = {re.sub(r"[,\s]", "", n) for n in re.findall(r"[\d,]+\.?\d*", text)}
    val = q["gt_value"]
    hit_val = any(n and abs(float(n) - val) <= max(1, abs(val) * 0.005)
                  for n in nums if re.fullmatch(r"\d+\.?\d*", n))
    return q["gt_label"].lower() in text.lower() and hit_val


def run_agent_arch(arch, agent, q):
    r, secs = c.run_agent(agent, q["question"])
    inp, out = c.usage(r.get("metadata"))
    cache = sum(t.get("input_tokens", {}).get("cache_read", 0)
                for t in r.get("metadata", {}).get("usage", {}).get("tokens_consumed", []))
    types = [b.get("type") for b in r.get("content", [])]
    blob = json.dumps([b for b in r.get("content", []) if b.get("type") in ("text", "table")])
    return dict(arch=arch, qid=q["id"], secs=round(secs, 1), master_in=inp, master_out=out,
                sub_in=0, sub_out=0, cache_read=cache, payload_to_master_bytes=0,
                chart=("chart" in types), correct=check(blob, q))


def run_mcp_arch(arch, q):
    flt = FILTERS[arch]
    plan, rin, rout = complete(ROUTER_PROMPT + q["question"])
    calls = json.loads(re.search(r"\{.*\}", plan, re.S).group(0))["calls"]
    sub_in = sub_out = cache = secs = 0
    payloads = []
    for call in calls:
        res, s = c.mcp_call(call["agent"], {"text": call["question"], "content_cel_filter": flt})
        secs += s
        txt = res["content"][0]["text"]
        payloads.append(f"[{call['agent']}]\n{txt}")
        try:
            meta = json.loads(txt).get("metadata", {})
        except json.JSONDecodeError:
            meta = {}
        i, o = c.usage(meta)
        sub_in, sub_out = sub_in + i, sub_out + o
        cache += sum(t.get("input_tokens", {}).get("cache_read", 0)
                     for t in meta.get("usage", {}).get("tokens_consumed", []))
    joined = "\n\n".join(payloads)
    ans, fin, fout = complete(FINAL_PROMPT.format(q=q["question"], results=joined))
    m = re.search(r"<chart>(.*?)</chart>", ans, re.S)
    chart_ok = False
    if m:
        try:
            spec = json.loads(m.group(1).strip().strip("`").removeprefix("json"))
            chart_ok = bool(spec.get("data", {}).get("values"))
        except (json.JSONDecodeError, AttributeError):
            pass
    return dict(arch=arch, qid=q["id"], secs=round(secs, 1), master_in=rin + fin,
                master_out=rout + fout, sub_in=sub_in, sub_out=sub_out, cache_read=cache,
                payload_to_master_bytes=len(joined), chart=chart_ok, correct=check(ans, q))


def job(arch, q, rep):
    try:
        if arch == "A_single_agent":
            row = run_agent_arch(arch, "SINGLE_AGENT", q)
        elif arch == "B_agent_toolset":
            row = run_agent_arch(arch, "MASTER_TOOLSET_AGENT", q)
        else:
            row = run_mcp_arch(arch, q)
        row["rep"], row["error"] = rep, ""
    except Exception as e:  # keep the benchmark going; failures are reported
        row = dict(arch=arch, qid=q["id"], rep=rep, error=str(e)[:200])
    row["total_tokens"] = sum(row.get(k, 0) for k in ("master_in", "master_out", "sub_in", "sub_out"))
    print(row, flush=True)
    return row


if __name__ == "__main__":
    reps = int(sys.argv[1]) if len(sys.argv) > 1 else 2
    archs = ["A_single_agent", "B_agent_toolset", *FILTERS]
    jobs = [(a, q, r) for r in range(reps) for q in QUESTIONS for a in archs]
    with ThreadPoolExecutor(6) as ex:
        rows = list(ex.map(lambda j: job(*j), jobs))
    cols = ["arch", "qid", "rep", "secs", "master_in", "master_out", "sub_in", "sub_out",
            "cache_read", "total_tokens", "payload_to_master_bytes", "chart", "correct", "error"]
    with open("results.csv", "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=cols, extrasaction="ignore")
        w.writeheader()
        w.writerows(rows)
    print("wrote results.csv", len(rows))
