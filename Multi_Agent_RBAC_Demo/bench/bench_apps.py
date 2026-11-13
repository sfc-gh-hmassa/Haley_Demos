"""MCP Apps variant (PrPr): sub-agent charts pass through to the client via _mcp_app.

D_mcp_apps        master routes -> MCP sub-agents with CEL table-only for the model;
                  master writes text only, charts come from structuredContent._mcp_app
D_scale_mcp_apps  same across the 14-agent BENCH_MCP_SCALE server
Re-runs B and C3 alongside for an apples-to-apples comparison.
"""
import csv
import json
import re
import sys
from concurrent.futures import ThreadPoolExecutor

import bench
import client as c

TABLE_ONLY = "content.filter(c, c.type == 'table')"
TEXT_PROMPT = """You are a master orchestrator. Sub-agent results are below; their charts are
already rendered for the user. Answer the user question concisely in text. Do not produce a chart.
User question: {q}
Sub-agent results:
{results}"""


def run_apps(arch, q, server, router):
    plan, rin, rout = bench.complete(router + q["question"])
    calls = json.loads(re.search(r"\{.*\}", plan, re.S).group(0))["calls"]
    sub_in = sub_out = cache = secs = app_bytes = 0
    payloads, charts = [], 0
    for call in calls:
        res, s = c.mcp_call(call["agent"], {"text": call["question"], "content_cel_filter": TABLE_ONLY},
                            server=server)
        secs += s
        txt = res["content"][0]["text"]
        payloads.append(f"[{call['agent']}]\n{txt}")
        app = (res.get("structuredContent") or {}).get("_mcp_app") or {}
        app_bytes += len(json.dumps(app))
        charts += sum(1 for b in app.get("blocks", [])
                      if b.get("type") == "chart" and b.get("spec", {}).get("data", {}).get("values"))
        meta = json.loads(txt).get("metadata", {})
        i, o = c.usage(meta)
        sub_in, sub_out = sub_in + i, sub_out + o
        cache += sum(t.get("input_tokens", {}).get("cache_read", 0)
                     for t in meta.get("usage", {}).get("tokens_consumed", []))
    joined = "\n\n".join(payloads)
    ans, fin, fout = bench.complete(TEXT_PROMPT.format(q=q["question"], results=joined))
    return dict(arch=arch, qid=q["id"], secs=round(secs, 1), master_in=rin + fin,
                master_out=rout + fout, sub_in=sub_in, sub_out=sub_out, cache_read=cache,
                payload_to_master_bytes=len(joined), app_bytes=app_bytes,
                chart=charts > 0, correct=bench.check(ans, q))


def job(arch, q, rep):
    try:
        if arch == "B_agent_toolset":
            row = bench.run_agent_arch(arch, "MASTER_TOOLSET_AGENT", q)
        elif arch == "C3_mcp_table_only":
            row = run_c3(q)
        elif arch == "D_mcp_apps":
            row = run_apps(arch, q, "BENCH_MCP", BASE_ROUTER)
        else:
            row = run_apps(arch, q, "BENCH_MCP_SCALE", SCALE_ROUTER)
        row["rep"], row["error"] = rep, ""
    except Exception as e:
        row = dict(arch=arch, qid=q["id"], rep=rep, error=str(e)[:200])
    row["total_tokens"] = sum(row.get(k, 0) for k in ("master_in", "master_out", "sub_in", "sub_out"))
    print(row, flush=True)
    return row


BASE_ROUTER = bench.ROUTER_PROMPT
_raw_mcp = c.mcp_call
import bench_scale  # noqa: E402  (patches bench.ROUTER_PROMPT and c.mcp_call)
SCALE_ROUTER = bench.ROUTER_PROMPT
bench.ROUTER_PROMPT = BASE_ROUTER
c.mcp_call = _raw_mcp


def run_c3(q):
    return bench.run_mcp_arch("C3_mcp_table_only", q)


if __name__ == "__main__":
    reps = int(sys.argv[1]) if len(sys.argv) > 1 else 2
    archs = ["B_agent_toolset", "C3_mcp_table_only", "D_mcp_apps", "D_scale_mcp_apps"]
    jobs = [(a, q, r) for r in range(reps) for q in bench.QUESTIONS for a in archs]
    with ThreadPoolExecutor(6) as ex:
        rows = list(ex.map(lambda j: job(*j), jobs))
    cols = ["arch", "qid", "rep", "secs", "master_in", "master_out", "sub_in", "sub_out", "cache_read",
            "total_tokens", "payload_to_master_bytes", "app_bytes", "chart", "correct", "error"]
    with open("results_apps.csv", "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=cols, extrasaction="ignore")
        w.writeheader()
        w.writerows(rows)
    print("wrote results_apps.csv", len(rows))
