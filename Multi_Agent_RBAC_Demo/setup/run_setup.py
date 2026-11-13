"""Run setup.sql (and optionally setup_scale.sql) statement by statement.

Usage: SNOWFLAKE_CONNECTION=<name in connections.toml> python3 run_setup.py [--scale]
"""
import json
import os
import sys

import snowflake.connector


def split_sql(text):
    """Split on ';' at line end, ignoring semicolons inside $$ ... $$ bodies."""
    stmts, buf, in_body = [], [], False
    for line in text.splitlines():
        buf.append(line)
        in_body ^= line.count("$$") % 2 == 1
        if not in_body and not line.lstrip().startswith("--") and line.rstrip().endswith(";"):
            stmt = "\n".join(buf).strip()
            if any(l.strip() and not l.lstrip().startswith("--") for l in buf):
                stmts.append(stmt)
            buf = []
    return stmts


def connect():
    """Use a PAT if SNOWFLAKE_PAT is set, otherwise a named connection from connections.toml."""
    if os.environ.get("SNOWFLAKE_PAT"):
        return snowflake.connector.connect(
            account=os.environ["SNOWFLAKE_ACCOUNT"], user=os.environ["SNOWFLAKE_USER"],
            authenticator="PROGRAMMATIC_ACCESS_TOKEN", token=os.environ["SNOWFLAKE_PAT"],
            role=os.environ.get("SNOWFLAKE_ROLE"), warehouse=os.environ.get("DEMO_WAREHOUSE"))
    return snowflake.connector.connect(connection_name=os.environ.get("SNOWFLAKE_CONNECTION", "default"))


here = os.path.dirname(__file__)
files = ["setup.sql"] + (["setup_scale.sql"] if "--scale" in sys.argv else [])
conn = connect()
cur = conn.cursor()
for name in files:
    stmts = split_sql(open(os.path.join(here, name)).read())
    for i, s in enumerate(stmts, 1):
        first = next((l for l in s.splitlines() if l.strip() and not l.startswith("--")), s)
        print(f"[{name} {i}/{len(stmts)}] {first[:90]}")
        cur.execute(s)
# Synthetic data is random per deploy, so refresh ground truth for the benchmark questions.
db, sc = os.environ.get("DEMO_DB", "MULTIAGENT_DEMO"), os.environ.get("DEMO_SCHEMA", "BENCH")
qpath = os.path.join(here, "..", "bench", "questions.json")
questions = json.load(open(qpath))
for q in questions:
    label, value = cur.execute(q["gt_sql"].format(FQ=f"{db}.{sc}")).fetchone()
    q["gt_label"], q["gt_value"] = str(label), float(value)
json.dump(questions, open(qpath, "w"), indent=2)
print("ground truth refreshed:", [(q["id"], q["gt_label"], q["gt_value"]) for q in questions])
print("done")
