"""Backend for the before/after React demo.

The browser never sees the Snowflake token: the React page calls /api/ask, and this server plays the
orchestrator, calling the specialist agents through the managed MCP server.

  before: specialists return their full response (old behavior). The orchestrator reads all of it and
          sends the app a text answer only.
  after:  specialists return only the result table. The orchestrator reads that, and the app gets the
          specialists' charts and tables from MCP Apps (structuredContent._mcp_app).

Run locally:  export SNOWFLAKE_ACCOUNT=<org>-<account> SNOWFLAKE_PAT=<token>
              uvicorn server:app --port 8000      then open http://localhost:8000
In Snowflake: deployed as a Snowpark Container Services service (see spcs/), which uses the service's own
              OAuth token, so no PAT is needed.
"""
import json
import os
import re
import time

import requests
from fastapi import FastAPI
from fastapi.responses import FileResponse
from pydantic import BaseModel

TOKEN_FILE = "/snowflake/session/token"  # present when running as a Snowpark Container Services service
IN_SPCS = os.path.exists(TOKEN_FILE)
if IN_SPCS:  # the service's own OAuth token and Snowflake's internal endpoint; no secrets in the image
    HOST = f"https://{os.environ['SNOWFLAKE_HOST']}"
else:
    HOST = f"https://{os.environ['SNOWFLAKE_ACCOUNT'].lower().replace('_', '-')}.snowflakecomputing.com"
DB, SC = os.environ.get("DEMO_DB", "MULTIAGENT_DEMO"), os.environ.get("DEMO_SCHEMA", "DEMO")
WAREHOUSE = os.environ.get("DEMO_WAREHOUSE", "COMPUTE_WH")
MODEL = "claude-sonnet-4-6"
# Credits per token for claude-sonnet-4-6, as billed in SNOWFLAKE.ACCOUNT_USAGE.CORTEX_AGENT_USAGE_HISTORY.
RATES = {"cache_read": 0.0000002, "input": 0.00000244, "output": 0.00000976}


def headers():
    if IN_SPCS:  # the token rotates, so read it on every call
        token, kind = open(TOKEN_FILE).read().strip(), "OAUTH"
    else:
        token, kind = os.environ["SNOWFLAKE_PAT"], "PROGRAMMATIC_ACCESS_TOKEN"
    return {"Authorization": f"Bearer {token}", "X-Snowflake-Authorization-Token-Type": kind,
            "Content-Type": "application/json", "Accept": "application/json"}


MCP_URL = f"{HOST}/api/v2/databases/{DB}/schemas/{SC}/mcp-servers/SPECIALIST_AGENTS_MCP"
FILTERS = {"before": "full", "after": "content.filter(c, c.type == 'table')"}
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
ANSWER = ("You are an orchestrator answering for a business app. Using the specialist results below, answer "
          "the question in 2-4 sentences with exact values.{charts}\nQuestion: {q}\nResults:\n{r}")

FOLLOW_UP = ("You are an orchestrator. Rewrite the question for {agent} so it uses the specific values "
             "(IDs, plants, parts) found in the earlier specialist results. Return only the question.\n"
             "User question: {q}\nDraft question for {agent}: {draft}\nEarlier results:\n{r}")

app = FastAPI()
http = requests.Session()
http.mount("https://", requests.adapters.HTTPAdapter(
    max_retries=requests.adapters.Retry(total=4, connect=4, backoff_factor=1.5, allowed_methods=None)))


def complete(prompt):
    body = {"model": MODEL, "stream": False, "messages": [{"role": "user", "content": prompt}]}
    r = http.post(f"{HOST}/api/v2/cortex/inference:complete", headers=headers(), json=body, timeout=600)
    r.raise_for_status()
    j = r.json()
    u = j.get("usage", {})
    return j["choices"][0]["message"]["content"], u.get("prompt_tokens", 0) + u.get("completion_tokens", 0)


def mcp_call(tool, args):
    body = {"jsonrpc": "2.0", "id": 1, "method": "tools/call", "params": {"name": tool, "arguments": args}}
    r = http.post(MCP_URL, headers=headers(), json=body, timeout=900)
    r.raise_for_status()
    j = r.json()
    if "error" in j:
        raise RuntimeError(json.dumps(j["error"])[:300])
    return j["result"]


def specialist_usage(text):
    """Tokens, credits and thread id for one specialist run, from its response metadata."""
    try:
        meta = json.loads(text).get("metadata", {})
    except json.JSONDecodeError:
        return 0, 0, 0.0, None
    tokens = uncached = 0
    credits = 0.0
    for u in meta.get("usage", {}).get("tokens_consumed", []):
        inp, out = u.get("input_tokens", {}), u.get("output_tokens", {}).get("total", 0)
        cache_read = inp.get("cache_read", 0)
        full_price = inp.get("total", 0) - cache_read
        tokens += inp.get("total", 0) + out
        uncached += full_price + out
        credits += cache_read * RATES["cache_read"] + full_price * RATES["input"] + out * RATES["output"]
    return tokens, uncached, credits, meta.get("thread_id")


def sql(statement, *binds):
    """Run one statement through the Snowflake SQL API with bound parameters."""
    body = {"statement": statement, "warehouse": WAREHOUSE, "database": DB, "schema": SC, "timeout": 120,
            "bindings": {str(i + 1): {"type": "REAL" if isinstance(v, float) else "FIXED" if isinstance(v, int)
                                      else "TEXT", "value": str(v)} for i, v in enumerate(binds)}}
    r = http.post(f"{HOST}/api/v2/statements", headers=headers(), json=body, timeout=180)
    r.raise_for_status()
    return r.json().get("data", [])


def log_run(result, question):
    s = result["stats"]
    sql("INSERT INTO DEMO_RUNS (mode, question, specialists, orchestrator_tokens, specialist_tokens, total_tokens, "
        "full_price_tokens, est_credits, kb_to_orchestrator, seconds, charts, specialist_thread_ids) "
        "SELECT ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?",
        result["mode"], question, ",".join(result["specialists"]), s["orchestrator_tokens"], s["specialist_tokens"],
        s["total_tokens"], s["full_price_tokens"], s["credits"], s["kb_to_orchestrator"], s["seconds"], s["charts"],
        ",".join(str(x) for x in result["thread_ids"] if x))


def run(mode, question):
    start = time.time()
    plan, orch_tok = complete(ROUTER + question)
    calls = json.loads(re.search(r"\{.*\}", plan, re.S).group(0))["calls"]

    # Call specialists in order. When a question spans domains, the orchestrator rewrites each follow-up
    # question using what the earlier specialists returned (e.g. "these 5 supplier IDs").
    results = []
    for i, call in enumerate(calls):
        if i:
            prior = "\n\n".join(f"[{c['agent']}]\n{r['content'][0]['text']}" for c, r in results)
            call["question"], tok = complete(FOLLOW_UP.format(q=question, agent=call["agent"],
                                                              draft=call["question"], r=prior))
            orch_tok += tok
        res = mcp_call(call["agent"], {"text": call["question"], "content_cel_filter": FILTERS[mode]})
        results.append((call, res))

    received, visuals, threads = [], [], []
    spec_tok = spec_unc = 0
    spec_cr = 0.0
    for call, res in results:
        text = res["content"][0]["text"]
        received.append({"agent": call["agent"], "bytes": len(text), "preview": text[:1500]})
        tok, unc, cr, thread = specialist_usage(text)
        spec_tok, spec_unc, spec_cr = spec_tok + tok, spec_unc + unc, spec_cr + cr
        threads.append(thread)
        if mode == "after":  # MCP Apps: charts and tables go to the app, not the orchestrator
            app_view = (res.get("structuredContent") or {}).get("_mcp_app") or {}
            for b in app_view.get("blocks", []):
                if b.get("type") in ("chart", "table"):
                    visuals.append({"agent": call["agent"], **b})

    note = " Charts are already shown to the user." if mode == "after" else ""
    joined = "\n\n".join(f"[{c['agent']}]\n{r['content'][0]['text']}" for c, r in results)
    answer, ans_tok = complete(ANSWER.format(charts=note, q=question, r=joined))
    orch_tok += ans_tok
    # The orchestrator's prompts aren't cached, so its tokens are billed at the full input rate.
    orch_cr = orch_tok * RATES["input"]
    return {
        "mode": mode, "answer": answer, "visuals": visuals, "received": received,
        "specialists": [c["agent"] for c in calls], "thread_ids": threads,
        "stats": {"orchestrator_tokens": orch_tok, "specialist_tokens": spec_tok,
                  "total_tokens": orch_tok + spec_tok, "full_price_tokens": orch_tok + spec_unc,
                  "credits": round(orch_cr + spec_cr, 5),
                  "kb_to_orchestrator": round(sum(r["bytes"] for r in received) / 1024, 1),
                  "seconds": round(time.time() - start, 1), "charts": sum(v["type"] == "chart" for v in visuals)},
    }


class Ask(BaseModel):
    question: str
    mode: str


@app.post("/api/ask")
def ask(req: Ask):
    try:
        result = run(req.mode, req.question)
    except Exception as e:  # surface the error in the UI instead of a blank panel
        return {"mode": req.mode, "error": str(e)[:500]}
    try:
        log_run(result, req.question)
    except Exception as e:  # metrics are best effort; the answer still shows
        result["log_error"] = str(e)[:200]
    return result


@app.get("/api/metrics")
def metrics():
    """Running before/after averages from DEMO_RUNS (every question asked in the app)."""
    try:
        rows = sql("SELECT mode, COUNT(*), AVG(est_credits), AVG(seconds), MEDIAN(seconds), AVG(orchestrator_tokens), "
                   "AVG(full_price_tokens), AVG(kb_to_orchestrator), AVG(IFF(charts > 0, 1, 0)) "
                   "FROM DEMO_RUNS GROUP BY mode")
    except Exception as e:
        return {"error": str(e)[:300]}
    keys = ["runs", "credits", "seconds", "median_seconds", "orchestrator_tokens", "full_price_tokens",
            "kb_to_orchestrator", "chart_rate"]
    return {r[0]: {k: float(v) if v is not None else None for k, v in zip(keys, r[1:])} for r in rows}


@app.get("/")
def index():
    return FileResponse(os.path.join(os.path.dirname(__file__), "index.html"))
