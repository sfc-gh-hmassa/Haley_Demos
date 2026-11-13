# Multi-Agent on Cortex Agents: the cost of the architecture decision

How you connect a master agent to domain sub-agents decides what you pay. This demo measures the
pattern many teams start with (sub-agents wrapped in `DATA_AGENT_RUN` stored procedures) against the
patterns we recommend now, on the same data and the same questions.

## Before vs after

| | **Before**: stored-procedure wrappers | **After**: `agent_toolset` | **After**: MCP delegation + MCP Apps |
|---|---|---|---|
| How the master reaches a sub-agent | Custom tool → SP → `DATA_AGENT_RUN` → text | Inherits the sub-agents' tools | Managed MCP server `CORTEX_AGENT_RUN` with a CEL filter |
| Tokens / question | **806K** | **257K** | **256K** |
| vs agent_toolset | **3.1x** | 1.00 | 0.97 |
| Latency | **102 s** | 23 s | 25 s |
| Sub-agent calls / question | 3.1 (up to 9) | n/a | 1 per domain |
| Charts | Master re-asks sub-agents until it can chart from prose | Native `data_to_chart` | Sub-agent's own Vega-Lite chart in `_mcp_app` |
| Exact numbers | Often rounded ("~50.9M"), 6/12 exact | 11/12 exact | 12/12 exact |
| At 14 domains / 30 tools | Not tested (cost scales with calls) | 1.53x | **0.95x** |

**Why "before" is expensive:** the wrapper returns only the sub-agent's text. The master's
`data_to_chart` can't chart prose, so it calls the sub-agent again ("give me exact column names",
"return the raw table") until it gets something it can use. Each extra call is a full sub-agent run
of about 200K tokens, because the sub-agent reloads its ~17.5K-token semantic view and orchestrates
from scratch.

**The fix:** don't flatten sub-agents into text.
- **Few domains:** use `agent_toolset`. The master runs the sub-agents' tools directly, so it has native
  charts and pays for each semantic view only when it's used.
- **Many domains, or an external orchestrator / React app:** use MCP delegation, with
  `content_cel_filter` set to table-only or `compact`. Add MCP Apps (preview) so the sub-agent's chart
  reaches the UI without passing through the master's context.
- **Never** use `content_cel_filter: full` for agent-to-agent calls. It returns ~142 KB of trace per call
  (1.16x, and 4x uncached).

Full method and numbers: [`docs/findings.md`](docs/findings.md). Slides:
[`docs/multiagent-delegation-findings.pptx`](docs/multiagent-delegation-findings.pptx).

## Architecture

```
BEFORE                                         AFTER (pick one)
                                               ┌───────────────── agent_toolset ─────────────────┐
Master agent                                   │ Master agent  ── inherits ──▶ sub-agent tools   │
  └─ custom tool: CALL_SALES_AGENT (SP)        │   (native data_to_chart, SVs loaded on demand)  │
       └─ DATA_AGENT_RUN(SALES_AGENT)          └─────────────────────────────────────────────────┘
            └─ returns TEXT only               ┌──────────── MCP delegation + MCP Apps ──────────┐
  └─ data_to_chart fails on prose              │ Orchestrator ─▶ MCP server ─▶ sub-agents (1..N) │
  └─ re-calls sub-agent 2–9x                   │   model gets table-only (~1.7 KB)               │
                                               │   UI gets _mcp_app chart + table (~3 KB)        │
                                               └─────────────────────────────────────────────────┘
```

## What's in here

```
setup/      gen_setup.py, gen_scale.py   generate setup.sql / setup_scale.sql
            run_setup.py                 deploy them and refresh benchmark ground truth
bench/      bench_sproc.py               BEFORE: SP-wrapped sub-agents (E)
            bench.py                     single agent (A), agent_toolset (B), MCP full/compact/table-only (C)
            bench_apps.py                MCP Apps (D) vs B and C
            bench_scale.py               B vs C at 14 domains / 30 tools
            client.py, questions.json    REST/MCP clients, questions + ground truth
results/    *.csv, summarize.py          our measured results
docs/       findings.md, *.pptx          write-up and slides
legacy/                                  the original stored-procedure + RBAC demo, for reference
```

Objects created (in `MULTIAGENT_DEMO.BENCH`):

| Object | Pattern |
|---|---|
| `SALES_AGENT`, `INVENTORY_AGENT` | Domain sub-agents (analyst + `data_to_chart`), ~17.5K-token semantic views each |
| `MASTER_SPROC_AGENT` + `CALL_*_AGENT` procedures | **Before** |
| `MASTER_TOOLSET_AGENT` | After: `agent_toolset` |
| `BENCH_MCP` (MCP server) | After: MCP delegation (+ MCP Apps if enabled) |
| `SINGLE_AGENT` | Baseline |
| `*_SCALE` objects (optional) | 14-domain scale test |

## Run it

Prerequisites:
- Cortex Agents with `claude-sonnet-4-6`
- A warehouse
- ACCOUNTADMIN, or a role that can create databases, agents, procedures and MCP servers
- A programmatic access token (PAT)
- **MCP Apps** is a preview feature; ask your account team to enable it for pattern D

```bash
pip install snowflake-connector-python requests pandas tabulate

export SNOWFLAKE_ACCOUNT=<org>-<account>  SNOWFLAKE_USER=<user>  SNOWFLAKE_PAT=<token>
export SNOWFLAKE_HOST=https://<org>-<account>.snowflakecomputing.com
export DEMO_WAREHOUSE=<warehouse>

cd setup && python3 gen_scale.py && python3 run_setup.py          # add --scale for the 14-domain set
cd ../bench
python3 bench_sproc.py 3    # BEFORE   -> results_sproc.csv (sequential)
python3 bench.py 3          # AFTER    -> results.csv
python3 bench_apps.py 3     # MCP Apps -> results_apps.csv
python3 bench_scale.py 2    # scale    -> results_scale.csv (needs --scale)
```

### Try it live (Snowsight or CoWork)

Ask `MASTER_SPROC_AGENT`, then `MASTER_TOOLSET_AGENT`:
*"Show me sales by product for the top 5 products."*

The trace for the stored-procedure agent shows `data_to_chart` failing on text and the sub-agent being
called repeatedly. The toolset agent answers in one pass with a native chart.

## How tokens are measured

- **Agent runs:** `metadata.usage.tokens_consumed` from each run (input, output and cache reads).
- **Before (E):** the wrapper procedures write each sub-agent run's usage to `SUBAGENT_USAGE_LOG`, and the
  master's usage comes from its own run. Runs are sequential so log rows can be attributed to the right run.
- **MCP master (C, D):** `usage` from `/api/v2/cortex/inference:complete`.
- **Correctness:** label and value within 0.5% of ground-truth SQL, recomputed on every deploy.

## Caveats

- Synthetic data. The semantic views are padded to a realistic size, not a realistic complexity.
- The C/D master is a minimal Python router. A heavier orchestrator adds tokens.
- Cache reads are billed at a discount, so token ratios overstate dollar gaps.
- The number of "before" re-calls varies by run (1–9). The 3.1x is the mean over 12 runs.
- MCP Apps is in preview.
