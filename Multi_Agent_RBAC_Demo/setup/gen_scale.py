"""Scale variant: 14 domain sub-agents (~30 analyst tools), AGG/BASE semantic views per domain."""
import os

import gen_setup as g  # reuses helpers; re-writes setup.sql identically

from domains import DOMAINS

sql = [f"USE SCHEMA {g.FQ};"]
agents = []
for d in DOMAINS:
    tools, res = "", ""
    for kind in ("AGG", "BASE"):
        sv = f"{d}_{kind}_SV"
        attrs = g.attr_cols("i")  # real INVENTORY columns
        ddl = g.sv_ddl(
            sv, "INVENTORY", "t", "snapshot_id",
            [("snapshot_date", "'date'", f"{d.title()} period date"),
             ("product_id", "'product', 'part number'", "Part number"),
             ("plant", "'site'", "Plant")],
            [f"t.{d.lower()}_amount AS inventory_value"],
            [f"t.total_{d.lower()}_amount AS SUM(t.{d.lower()}_amount) COMMENT = 'Total {d.lower()} amount'",
             f"t.{d.lower()}_record_count AS COUNT(t.snapshot_id) COMMENT = 'Number of {d.lower()} records'"],
            attrs, d.title().replace("_", " "),
        )
        # unique column names so the dim alias doesn't collide with the fact rename
        sql.append(ddl)
        tname = f"query_{d.lower()}_{kind.lower()}"
        tools += g.analyst_tool(tname, f"{d.title().replace('_',' ')} {kind.lower()} metrics by product, plant, date")
        res += (f"  {tname}:\n    semantic_view: {g.FQ}.{sv}\n    execution_environment:\n"
                f"      type: warehouse\n      warehouse: {g.WH}\n")
    name = f"{d}_AGENT"
    agents.append(name)
    sql.append(g.agent(name, tools + g.CHART_TOOL, res, g.INSTR))

all_agents = ["SALES_AGENT", "INVENTORY_AGENT"] + agents
ts_tools = "".join(f"  - tool_spec:\n      type: agent_toolset\n      name: ts_{a.lower()}\n" for a in all_agents)
ts_res = "".join(f"  ts_{a.lower()}:\n    agent_name: {g.FQ}.{a}\n" for a in all_agents)
sql.append(g.agent("MASTER_TOOLSET_SCALE", ts_tools, ts_res, g.INSTR))

mcp = "".join(
    f"  - name: \"{a.lower()}\"\n    type: \"CORTEX_AGENT_RUN\"\n    identifier: \"{g.FQ}.{a}\"\n"
    f"    title: \"{a}\"\n    description: \"{a.replace('_AGENT','').replace('_',' ').title()} questions\"\n"
    for a in all_agents)
sql.append(f"CREATE OR REPLACE MCP SERVER {g.FQ}.BENCH_MCP_SCALE FROM SPECIFICATION $$\ntools:\n{mcp}$$;\n")
open(os.path.join(os.path.dirname(__file__), "setup_scale.sql"), "w").write("\n".join(sql))
print("wrote setup_scale.sql", len(sql), "statements")
