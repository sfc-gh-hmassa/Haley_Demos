"""Scale variant: 14 sub-agents / 30 analyst tools.

B_scale  MASTER_TOOLSET_SCALE (agent_toolset over 14 agents -> 30 flattened tools)
C3_scale python master routes across 14 MCP sub-agents, CEL table-only pass-through
"""
import csv
import json
import re
import sys
from concurrent.futures import ThreadPoolExecutor

import bench
import client as c
from domains import DOMAINS

AGENTS = ["sales_agent", "inventory_agent"] + [f"{d.lower()}_agent" for d in DOMAINS]
bench.ROUTER_PROMPT = (
    "You are a master orchestrator. Available sub-agents:\n"
    "- sales_agent: sales orders, revenue, units by product, region, date\n"
    "- inventory_agent: inventory on hand, safety stock, value by product, plant, date\n"
    + "".join(f"- {d.lower()}_agent: {d.replace('_', ' ').lower()} agg and base metrics by product, plant, date\n"
              for d in DOMAINS)
    + 'Return ONLY JSON: {"calls":[{"agent":"<name>","question":"..."}]}\n'
    "Use one call per needed agent. User question: "
)
_orig_call = c.mcp_call
c.mcp_call = lambda tool, args, rid=1, server="BENCH_MCP_SCALE": _orig_call(tool, args, rid, server)


def job(arch, q, rep):
    try:
        if arch == "B_scale_toolset":
            row = bench.run_agent_arch(arch, "MASTER_TOOLSET_SCALE", q)
        else:
            row = bench.run_mcp_arch("C3_mcp_table_only", q)
            row["arch"] = arch
        row["rep"], row["error"] = rep, ""
    except Exception as e:
        row = dict(arch=arch, qid=q["id"], rep=rep, error=str(e)[:200])
    row["total_tokens"] = sum(row.get(k, 0) for k in ("master_in", "master_out", "sub_in", "sub_out"))
    print(row, flush=True)
    return row


if __name__ == "__main__":
    reps = int(sys.argv[1]) if len(sys.argv) > 1 else 2
    jobs = [(a, q, r) for r in range(reps) for q in bench.QUESTIONS
            for a in ("B_scale_toolset", "C3_scale_mcp_table_only")]
    with ThreadPoolExecutor(4) as ex:
        rows = list(ex.map(lambda j: job(*j), jobs))
    cols = ["arch", "qid", "rep", "secs", "master_in", "master_out", "sub_in", "sub_out",
            "cache_read", "total_tokens", "payload_to_master_bytes", "chart", "correct", "error"]
    with open("results_scale.csv", "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=cols, extrasaction="ignore")
        w.writeheader()
        w.writerows(rows)
    print("wrote results_scale.csv", len(rows))
