"""Summarize benchmark CSVs into one comparison table (markdown)."""
import glob
import os

import pandas as pd

here = os.path.dirname(__file__)
df = pd.concat(pd.read_csv(f) for f in sorted(glob.glob(os.path.join(here, "results*.csv"))))
df = df[df["error"].isna() | (df["error"] == "")]
df["uncached"] = df.total_tokens - df.cache_read
g = df.groupby("arch").agg(
    runs=("qid", "count"),
    total_tokens=("total_tokens", "mean"),
    uncached_tokens=("uncached", "mean"),
    master_input=("master_in", "mean"),
    payload_kb=("payload_to_master_bytes", lambda x: x.mean() / 1024),
    latency_s=("secs", "mean"),
    chart_rate=("chart", "mean"),
).round(1)
print(g.to_markdown())
