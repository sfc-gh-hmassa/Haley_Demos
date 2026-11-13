# Findings: multi-agent delegation on Cortex Agents

## Problem statement

A master agent orchestrates domain sub-agents, and each sub-agent owns semantic views of ~17–19K tokens. The goals are:

1. Keep sub-agent context (semantic views, instructions, tool schemas) out of the master's context window.
2. Return structured results (tables and charts), not just text, so a front end can render charts.
3. Stay efficient as the number of domains grows (for example, 14 domains × AGG/BASE views ≈ 30 analyst tools).

## Test setup

- **Data:** synthetic SALES (50K rows) and INVENTORY (20K rows). Each table has 120 documented attribute columns, so each
  semantic view is about 17.5K tokens.
- **Sub-agents:** SALES_AGENT and INVENTORY_AGENT. Each has `cortex_analyst_text_to_sql` and `data_to_chart`.
- **Scale set:** 12 more domain agents, each with AGG and BASE semantic views. That makes 14 agents and 30 analyst tools.
- **Questions:**
  - Top 5 products by sales (sales only)
  - Inventory by plant (inventory only)
  - Revenue by region
  - A cross-domain question (top-5 revenue products with their on-hand inventory)
- **Metrics:** total, uncached, and cache-read tokens; payload bytes returned to the master; latency; chart produced;
  correctness against ground-truth SQL.

## Results

### Before: sub-agents wrapped in DATA_AGENT_RUN stored procedures (12 runs, sequential)

This is the pattern from the original demo (now in `legacy/`). The master's custom tools call procedures that run
`DATA_AGENT_RUN` and return only the sub-agent's text.

| Metric | Before (SP wrappers) | agent_toolset | Ratio |
|---|---|---|---|
| Tokens / question | 806K | 257K | **3.1x** |
| Uncached tokens | 151K | 16K | 9.4x |
| Latency | 102 s | 23 s | 4.4x |
| Sub-agent calls / question | 3.1 (1–9) | — | |
| Exact-number answers | 6/12 | 11/12 | |

The trace shows `data_to_chart` failing on prose. The master then re-asks the sub-agent for exact columns or a raw
table, and each re-ask is a full ~200K-token sub-agent run. Answers built from prose are often rounded ("~50.9M").


### Two domains (3 reps)

| Pattern | Total tokens | vs B | Uncached | Payload to master | Latency (s) |
|---|---|---|---|---|---|
| A: single agent | 278K | 1.08 | 24K | — | 33 |
| B: agent_toolset | 257K | 1.00 | 16K | — | 23 |
| C: MCP `full` | 297K | 1.16 | 70K | 142 KB | 26 |
| C: MCP `compact` | 253K | 0.99 | 21K | 4.4 KB | 24 |
| C: MCP table-only CEL | 252K | 0.98 | 19K | 1.7 KB | 23 |

### 14 domains / 30 tools (2 reps)

| Pattern | Total tokens | vs B (2-domain) | Uncached |
|---|---|---|---|
| B: agent_toolset | 392K | 1.53 | 39K |
| C: MCP table-only | 252K | 0.98 | 31K |

The trace shows that B at scale makes the same tool calls and fetches only the relevant semantic view. The extra
~117K input tokens per question are flattened tool definitions, about 29K, re-sent on each of ~4 orchestration turns.
These are almost entirely cache reads.

### MCP Apps (3 reps, separate run)

| Pattern | Total tokens | vs B | Master input | To model | To UI | Chart |
|---|---|---|---|---|---|---|
| B: agent_toolset | 265K | 1.00 | 262K | — | — | native |
| C: MCP table-only | 252K | 0.95 | 818 | 1.6 KB | — | rebuilt by master |
| D: MCP Apps | 256K | 0.97 | 890 | 1.8 KB | 3.0 KB | sub-agent's chart |
| D: MCP Apps, 14 agents | 252K | 0.95 | 1.0K | 1.7 KB | 2.6 KB | sub-agent's chart |

`structuredContent._mcp_app` is `{"type": "blocks@v1", "blocks": [...]}`. It contains a `table` block (columns, rows) and a
`chart` block with a complete Vega-Lite v5 spec and inline data. It is returned regardless of `content_cel_filter`, so the
model can receive a minimal payload while the UI still gets the full chart.

## Recommendation

| Situation | Recommended pattern |
|---|---|
| Today using SP / `DATA_AGENT_RUN` wrappers | Replace them: 3.1x tokens, 4.4x latency, lossy numbers |
| Few domains (2–5 sub-agents, a handful of tools) | `agent_toolset`: simplest, native charts, no extra cost |
| Many domains | Consolidate semantic views where splits are not semantic (for example AGG/BASE), **or** MCP delegation with `compact` / CEL filtering |
| Need the sub-agent's chart in your own UI | MCP Apps: render `_mcp_app.blocks` (Vega-Lite) or host `ui://snowflake/cortex/view` |
| Never | `content_cel_filter: full` for agent-to-agent calls |

## Caveats

- Synthetic data. Padded semantic views approximate real size, but not real complexity.
- The client master is a minimal Python router. The token totals are dominated by the sub-agent runs, which are identical
  across C and D.
- Accuracy was similar across patterns, and misses were concentrated on the cross-domain question. One grader bug
  (a case-sensitive label match) was found and fixed after the MCP Apps run.
- MCP Apps card rendering in a desktop client was not visually verified. The payload was validated over JSON-RPC.
