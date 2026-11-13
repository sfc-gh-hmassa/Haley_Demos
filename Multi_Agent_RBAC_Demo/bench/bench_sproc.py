"""'Before' pattern: master agent with DATA_AGENT_RUN stored-procedure tools (text-only return).

Sub-agent usage is read from SUBAGENT_USAGE_LOG (written by the wrapper procedures), so runs are
sequential to attribute log rows to the right master run.
"""
import csv
import json
import os
import sys

import snowflake.connector

import bench
import client as c

conn = snowflake.connector.connect(account=os.environ["SNOWFLAKE_ACCOUNT"], user=os.environ["SNOWFLAKE_USER"],
                                   authenticator="PROGRAMMATIC_ACCESS_TOKEN", token=c.PAT)
cur = conn.cursor()


def sub_usage_since(ts):
    cur.execute(
        f"select usage from {c.DB}.{c.SC}.SUBAGENT_USAGE_LOG where logged_at > %s", (ts,))
    rows = [json.loads(r[0]) if r[0] else {} for r in cur.fetchall()]
    inp = sum(t.get("input_tokens", {}).get("total", 0) for u in rows for t in u.get("tokens_consumed", []))
    out = sum(t.get("output_tokens", {}).get("total", 0) for u in rows for t in u.get("tokens_consumed", []))
    cache = sum(t.get("input_tokens", {}).get("cache_read", 0) for u in rows for t in u.get("tokens_consumed", []))
    return inp, out, cache, len(rows)


def job(q, rep):
    try:
        cur.execute("select current_timestamp()")
        t0 = cur.fetchone()[0]
        row = bench.run_agent_arch("E_sproc_text_only", "MASTER_SPROC_AGENT", q)
        si, so, sc, calls = sub_usage_since(t0)
        row.update(sub_in=si, sub_out=so, cache_read=row["cache_read"] + sc, subagent_calls=calls)
        row["rep"], row["error"] = rep, ""
    except Exception as e:
        row = dict(arch="E_sproc_text_only", qid=q["id"], rep=rep, error=str(e)[:200])
    row["total_tokens"] = sum(row.get(k, 0) for k in ("master_in", "master_out", "sub_in", "sub_out"))
    print(row, flush=True)
    return row


if __name__ == "__main__":
    reps = int(sys.argv[1]) if len(sys.argv) > 1 else 3
    rows = [job(q, r) for r in range(reps) for q in bench.QUESTIONS]
    cols = ["arch", "qid", "rep", "secs", "master_in", "master_out", "sub_in", "sub_out", "cache_read",
            "total_tokens", "subagent_calls", "payload_to_master_bytes", "chart", "correct", "error"]
    with open("results_sproc.csv", "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=cols, extrasaction="ignore")
        w.writeheader()
        w.writerows(rows)
    print("wrote results_sproc.csv", len(rows))
