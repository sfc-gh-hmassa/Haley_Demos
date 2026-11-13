# Customer Demo Script (15 minutes)

**The story in one line:** your orchestrator was paying to read every specialist agent's semantic model and
still couldn't draw a chart. The Snowflake MCP server now returns just the answer table, and sends the
specialist's chart straight to your app.

**Live app:** run `./deploy.sh <warehouse>` once. It prints the app URL (also available with
`SHOW ENDPOINTS IN SERVICE MULTIAGENT_DEMO.DEMO.BEFORE_AFTER_APP`). The flow is the same as a React front end:
**your app → orchestrator → Snowflake MCP server → specialist agents**.

**Slides:** [`docs/Multi-Agent_on_Cortex_Agents.pptx`](docs/Multi-Agent_on_Cortex_Agents.pptx)

---

## 1. Set the scene (2 min) · slides 1–2

> "You've split your data into domain agents (procurement, supplier quality, inventory, orders), each owned
> by a team with its own semantic views. Your React app asks one orchestrator, which calls the right
> specialists and shows a chart. That's the right design. Two things got in the way."

## 2. The two problems (2 min) · slide 3

> "First, every specialist call brought its whole semantic model and working notes back into the
> orchestrator's context: about 100 KB per call. Second, what came back was text, so your app had nothing to
> chart."

## 3. Live: before (3 min) · app, left panel

1. Open the app. Click **"For the 5 suppliers with the highest purchase spend, what is their defect rate in
   PPM?"** Both sides run the same question at the same time.
2. Point at the **Before** panel:
   - **~200 KB sent back to the orchestrator** and **~60–90K orchestrator tokens**.
   - The **No chart** box: the app only received text.
3. Expand **"What the orchestrator received from procurement_agent"**:
   > "That's the semantic model, the chart instructions and the SQL, all landing in the orchestrator's
   > context on every call."

## 4. Live: after (3 min) · app, right panel

1. Point at the **After** panel: the **same answer**, **~2 KB** to the orchestrator, **~2K orchestrator
   tokens**.
2. Point at the two charts:
   > "These are the specialists' own charts, delivered through MCP Apps. The orchestrator never touched
   > them; your app draws them directly."
3. Expand **"What the orchestrator received"**:
   > "Now it's just the result table."

## 5. What changed and the numbers (3 min) · scoreboard, then slides 4–8

Scroll to **Running comparison** at the top of the app: the cost per question, latency and orchestrator
tokens for every question asked so far, before vs after. To show the same numbers in SQL (including billed
credits), open `metrics.sql` in a worksheet and run query 2.

> "Two new MCP features do this. **Response filtering** (`content_cel_filter`) returns only the table, and
> **MCP Apps** sends the chart to your app separately."

Across 18 runs per pattern:

| | Before: stored procedure | Before: MCP full response | **Now: MCP filtered + MCP Apps** |
|---|---|---|---|
| **Accuracy:** correct answers | 67% | 100% | **100%** |
| **Cost:** credits per question | 0.246 | 0.233 | **0.139** |
| **Cost:** credits per 1,000 questions | 246 | 233 | **139** |
| **Cost:** orchestrator tokens | 93K | 40K | **1.1K** |
| **Latency:** median / average | 35 s / 50 s | 28 s / 31 s | **21 s / 28 s** |
| **Latency:** two-domain questions | 72 s | 44 s | **41 s** |
| Chart in your app | after re-asking | — | **every answer** |

> "Same accuracy, about 40% lower cost per question, and faster. The orchestrator's own tokens drop 97%.
> What's left is the specialists doing their actual work."

## 6. How to adopt it (2 min) · slide 9

1. Keep your specialist agents (make sure each has `data_to_chart`).
2. Put them behind one managed MCP server.
3. Set `content_cel_filter` to the result table; don't use `full`.
4. Draw charts from `_mcp_app` in your React app.
5. Retire the stored-procedure wrappers.

> "Everything you saw is in the repo: `setup.sql` builds it in your account, and `measure.py` reproduces
> the numbers."

---

## Before the call

- **Resume the app** (if suspended):
  `ALTER COMPUTE POOL MULTIAGENT_DEMO_POOL RESUME; ALTER SERVICE MULTIAGENT_DEMO.DEMO.BEFORE_AFTER_APP RESUME;`
- **Reset the scoreboard:** `TRUNCATE TABLE MULTIAGENT_DEMO.DEMO.DEMO_RUNS;`
- **Warm it up:** open the URL and run one question; the first run takes about 40 seconds.
- **Have a backup:** if the network is shaky, keep the screenshot (`docs/app_before_after.png`) ready.
- **After the call**, suspend both to stop cost:
  `ALTER SERVICE MULTIAGENT_DEMO.DEMO.BEFORE_AFTER_APP SUSPEND; ALTER COMPUTE POOL MULTIAGENT_DEMO_POOL SUSPEND;`

## Likely questions

- **"Why not just use `agent_toolset`?"** It's a good fit when Snowflake Intelligence is the front end and
  there are only a few specialists. For your own React app with many specialists, MCP keeps the
  orchestrator small (appendix slide).
- **"Is MCP Apps generally available?"** It's in preview. The table filtering works today without it, and
  your app can chart the returned table itself.
- **"Will our numbers match?"** Not exactly. This uses synthetic data with ~15K-token semantic views.
  `measure.py` runs the same test on your agents.
