"""Thin REST clients for Cortex Agent :run and the managed MCP server."""
import json
import os
import time

import requests

HOST = os.environ["SNOWFLAKE_HOST"].rstrip("/")  # e.g. https://<org>-<account>.snowflakecomputing.com
DB = os.environ.get("DEMO_DB", "MULTIAGENT_DEMO")
SC = os.environ.get("DEMO_SCHEMA", "BENCH")
PAT = os.environ["SNOWFLAKE_PAT"]  # programmatic access token
HDRS = {
    "Authorization": f"Bearer {PAT}",
    "X-Snowflake-Authorization-Token-Type": "PROGRAMMATIC_ACCESS_TOKEN",
    "Content-Type": "application/json",
    "Accept": "application/json",
}


def run_agent(agent, question):
    """Call an agent object non-streaming. Returns (response_json, seconds)."""
    url = f"{HOST}/api/v2/databases/{DB}/schemas/{SC}/agents/{agent}:run"
    body = {"messages": [{"role": "user", "content": [{"type": "text", "text": question}]}],
            "stream": False}
    t = time.time()
    r = requests.post(url, headers=HDRS, json=body, timeout=600)
    r.raise_for_status()
    return r.json(), time.time() - t


def mcp_call(tool, arguments, rid=1, server="BENCH_MCP"):
    """JSON-RPC tools/call against the managed MCP server. Returns (result, seconds)."""
    url = f"{HOST}/api/v2/databases/{DB}/schemas/{SC}/mcp-servers/{server}"
    body = {"jsonrpc": "2.0", "id": rid, "method": "tools/call",
            "params": {"name": tool, "arguments": arguments}}
    t = time.time()
    r = requests.post(url, headers=HDRS, json=body, timeout=600)
    r.raise_for_status()
    j = r.json()
    if "error" in j:
        raise RuntimeError(json.dumps(j["error"]))
    return j["result"], time.time() - t


def mcp_list():
    url = f"{HOST}/api/v2/databases/{DB}/schemas/{SC}/mcp-servers/BENCH_MCP"
    r = requests.post(url, headers=HDRS, json={"jsonrpc": "2.0", "id": 0, "method": "tools/list"},
                      timeout=60)
    r.raise_for_status()
    return r.json()


def usage(meta):
    """Sum input/output tokens from metadata.usage.tokens_consumed."""
    inp = out = 0
    for t in (meta or {}).get("usage", {}).get("tokens_consumed", []):
        inp += t.get("input_tokens", {}).get("total", 0)
        out += t.get("output_tokens", {}).get("total", 0)
    return inp, out
