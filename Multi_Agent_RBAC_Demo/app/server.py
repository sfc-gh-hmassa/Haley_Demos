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
MODEL = "claude-sonnet-4-6"


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


def specialist_tokens(text):
    try:
        meta = json.loads(text).get("metadata", {})
    except json.JSONDecodeError:
        return 0
    return sum(t.get("input_tokens", {}).get("total", 0) + t.get("output_tokens", {}).get("total", 0)
               for t in meta.get("usage", {}).get("tokens_consumed", []))


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

    received, visuals, spec_tok = [], [], 0
    for call, res in results:
        text = res["content"][0]["text"]
        received.append({"agent": call["agent"], "bytes": len(text), "preview": text[:1500]})
        spec_tok += specialist_tokens(text)
        if mode == "after":  # MCP Apps: charts and tables go to the app, not the orchestrator
            app_view = (res.get("structuredContent") or {}).get("_mcp_app") or {}
            for b in app_view.get("blocks", []):
                if b.get("type") in ("chart", "table"):
                    visuals.append({"agent": call["agent"], **b})

    note = " Charts are already shown to the user." if mode == "after" else ""
    joined = "\n\n".join(f"[{c['agent']}]\n{r['content'][0]['text']}" for c, r in results)
    answer, ans_tok = complete(ANSWER.format(charts=note, q=question, r=joined))
    orch_tok += ans_tok
    return {
        "mode": mode, "answer": answer, "visuals": visuals, "received": received,
        "specialists": [c["agent"] for c in calls],
        "stats": {"orchestrator_tokens": orch_tok, "specialist_tokens": spec_tok,
                  "total_tokens": orch_tok + spec_tok,
                  "kb_to_orchestrator": round(sum(r["bytes"] for r in received) / 1024, 1),
                  "seconds": round(time.time() - start, 1), "charts": sum(v["type"] == "chart" for v in visuals)},
    }


class Ask(BaseModel):
    question: str
    mode: str


@app.post("/api/ask")
def ask(req: Ask):
    try:
        return run(req.mode, req.question)
    except Exception as e:  # surface the error in the UI instead of a blank panel
        return {"mode": req.mode, "error": str(e)[:500]}


@app.get("/")
def index():
    return FileResponse(os.path.join(os.path.dirname(__file__), "index.html"))
