"""Generate setup.sql for the multi-agent delegation benchmark.

Semantic views are padded with many documented attribute columns so each
one lands near ~17-19K tokens, a typical enterprise semantic view size.
"""
import os
import random

DB = os.environ.get("DEMO_DB", "MULTIAGENT_DEMO")
SC = os.environ.get("DEMO_SCHEMA", "BENCH")
WH = os.environ.get("DEMO_WAREHOUSE", "COMPUTE_WH")
FQ = f"{DB}.{SC}"
random.seed(7)
N_ATTR = 120  # extra documented attribute columns per domain

ATTR_THEMES = [
    "plant", "region", "business_unit", "commodity", "supplier_tier", "incoterm",
    "channel", "segment", "program", "platform", "connector_family", "pin_count",
    "material", "plating", "currency", "fiscal_period", "planner", "buyer",
    "warehouse_zone", "lot_class",
]


def attr_cols(prefix):
    cols = []
    for i in range(N_ATTR):
        theme = ATTR_THEMES[i % len(ATTR_THEMES)]
        cols.append((f"{prefix}_{theme}_attr_{i:02d}", theme))
    return cols


def long_comment(domain, col, theme):
    return (
        f"{domain} attribute {col}. Represents the {theme.replace('_', ' ')} classification "
        f"used by the {domain} reporting team for slicing KPIs. Values are conformed "
        f"against the enterprise master data hub, refreshed nightly, and may be blank for "
        f"legacy records created before the 2019 ERP migration. Use for grouping and "
        f"filtering only; do not aggregate."
    ).replace("'", "")


def table_ddl(name, base_cols, attrs, rows, row_sql):
    cols = ",\n  ".join(base_cols + [f"{c} VARCHAR" for c, _ in attrs])
    attr_vals = ", ".join(
        f"'{t.upper()}_' || UNIFORM(1, 8, RANDOM())::VARCHAR" for _, t in attrs
    )
    return (
        f"CREATE OR REPLACE TABLE {FQ}.{name} (\n  {cols}\n);\n"
        f"INSERT INTO {FQ}.{name}\nSELECT {row_sql}, {attr_vals}\n"
        f"FROM TABLE(GENERATOR(ROWCOUNT => {rows}));\n"
    )


def sv_ddl(name, table, alias, pk, base_dims, facts, metrics, attrs, domain):
    dims = [
        f"{alias}.{c} AS {c} WITH SYNONYMS = ({syn}) COMMENT = '{cm}'"
        for c, syn, cm in base_dims
    ]
    dims += [
        f"{alias}.{c} AS {c} WITH SYNONYMS = ('{t.replace('_', ' ')}', '{t} code') "
        f"COMMENT = '{long_comment(domain, c, t)}'"
        for c, t in attrs
    ]
    return (
        f"CREATE OR REPLACE SEMANTIC VIEW {FQ}.{name}\n"
        f"  TABLES ({alias} AS {FQ}.{table} PRIMARY KEY ({pk}) "
        f"COMMENT = '{domain} fact table')\n"
        f"  FACTS (\n    " + ",\n    ".join(facts) + "\n  )\n"
        f"  DIMENSIONS (\n    " + ",\n    ".join(dims) + "\n  )\n"
        f"  METRICS (\n    " + ",\n    ".join(metrics) + "\n  )\n"
        f"  COMMENT = '{domain} semantic view for the A2A benchmark';\n"
    )


PRODUCTS = [f"P{i:03d}" for i in range(1, 41)]
prod_case = "ARRAY_CONSTRUCT(" + ",".join(f"'{p}'" for p in PRODUCTS) + ")"

sales_attrs, inv_attrs = attr_cols("s"), attr_cols("i")

sql = [f"CREATE DATABASE IF NOT EXISTS {DB};", f"CREATE SCHEMA IF NOT EXISTS {FQ};",
       f"USE SCHEMA {FQ};"]

sql.append(table_ddl(
    "SALES",
    ["order_id NUMBER", "order_date DATE", "product_id VARCHAR", "customer_region VARCHAR",
     "quantity NUMBER", "revenue NUMBER(12,2)"],
    sales_attrs, 50000,
    f"SEQ4(), DATEADD(day, -UNIFORM(0, 730, RANDOM()), CURRENT_DATE()), "
    f"GET({prod_case}, UNIFORM(0, 39, RANDOM()))::VARCHAR, "
    f"GET(ARRAY_CONSTRUCT('AMER','EMEA','APAC'), UNIFORM(0, 2, RANDOM()))::VARCHAR, "
    f"UNIFORM(1, 500, RANDOM()), ROUND(UNIFORM(10, 5000, RANDOM()) * 1.37, 2)",
))
sql.append(table_ddl(
    "INVENTORY",
    ["snapshot_id NUMBER", "snapshot_date DATE", "product_id VARCHAR", "plant VARCHAR",
     "on_hand_qty NUMBER", "safety_stock_qty NUMBER", "inventory_value NUMBER(12,2)"],
    inv_attrs, 20000,
    f"SEQ4(), DATEADD(day, -UNIFORM(0, 365, RANDOM()), CURRENT_DATE()), "
    f"GET({prod_case}, UNIFORM(0, 39, RANDOM()))::VARCHAR, "
    f"GET(ARRAY_CONSTRUCT('LISLE','GUADALAJARA','PENANG','SHANNON'), UNIFORM(0, 3, RANDOM()))::VARCHAR, "
    f"UNIFORM(0, 20000, RANDOM()), UNIFORM(500, 5000, RANDOM()), "
    f"ROUND(UNIFORM(100, 90000, RANDOM()) * 1.11, 2)",
))

sql.append(sv_ddl(
    "SALES_SV", "SALES", "sales", "order_id",
    [("order_date", "'date', 'order day'", "Date the order was booked"),
     ("product_id", "'product', 'part number', 'sku'", "Part number"),
     ("customer_region", "'region', 'geo'", "Customer sales region")],
    ["sales.quantity AS quantity", "sales.revenue AS revenue"],
    ["sales.total_revenue AS SUM(sales.revenue) COMMENT = 'Total sales revenue in USD'",
     "sales.total_units AS SUM(sales.quantity) COMMENT = 'Total units sold'",
     "sales.order_count AS COUNT(sales.order_id) COMMENT = 'Number of orders'"],
    sales_attrs, "Sales",
))
sql.append(sv_ddl(
    "INVENTORY_SV", "INVENTORY", "inv", "snapshot_id",
    [("snapshot_date", "'date', 'as of date'", "Inventory snapshot date"),
     ("product_id", "'product', 'part number', 'sku'", "Part number"),
     ("plant", "'site', 'factory'", "Manufacturing plant")],
    ["inv.on_hand_qty AS on_hand_qty", "inv.safety_stock_qty AS safety_stock_qty",
     "inv.inventory_value AS inventory_value"],
    ["inv.total_on_hand AS SUM(inv.on_hand_qty) COMMENT = 'Total on-hand units'",
     "inv.total_inventory_value AS SUM(inv.inventory_value) COMMENT = 'Total inventory value USD'",
     "inv.total_safety_stock AS SUM(inv.safety_stock_qty) COMMENT = 'Total safety stock units'"],
    inv_attrs, "Inventory",
))

MODEL = "claude-sonnet-4-6"


def analyst_tool(name, desc):
    return (f"  - tool_spec:\n      type: cortex_analyst_text_to_sql\n      name: {name}\n"
            f"      description: \"{desc}\"\n")


CHART_TOOL = "  - tool_spec:\n      type: data_to_chart\n      name: data_to_chart\n      description: \"Generate a chart from query results\"\n"


def agent(name, tools, resources, instr):
    return (f"CREATE OR REPLACE AGENT {FQ}.{name}\n  FROM SPECIFICATION $$\n"
            f"models:\n  orchestration: {MODEL}\n"
            f"instructions:\n  response: \"{instr}\"\n"
            f"tools:\n{tools}tool_resources:\n{resources}$$;\n")


sales_res = f"  query_sales:\n    semantic_view: {FQ}.SALES_SV\n    execution_environment:\n      type: warehouse\n      warehouse: {WH}\n"
inv_res = f"  query_inventory:\n    semantic_view: {FQ}.INVENTORY_SV\n    execution_environment:\n      type: warehouse\n      warehouse: {WH}\n"
sales_tool = analyst_tool("query_sales", "Sales orders, revenue, units by product, region, date")
inv_tool = analyst_tool("query_inventory", "Inventory on hand, safety stock, value by product, plant, date")
INSTR = "Be concise. Return the result table and a chart when the answer has more than one row."

sql.append(agent("SALES_AGENT", sales_tool + CHART_TOOL, sales_res, INSTR))
sql.append(agent("INVENTORY_AGENT", inv_tool + CHART_TOOL, inv_res, INSTR))
sql.append(agent("SINGLE_AGENT", sales_tool + inv_tool + CHART_TOOL, sales_res + inv_res, INSTR))
sql.append(agent(
    "MASTER_TOOLSET_AGENT",
    "  - tool_spec:\n      type: agent_toolset\n      name: sales_toolset\n"
    "  - tool_spec:\n      type: agent_toolset\n      name: inventory_toolset\n",
    f"  sales_toolset:\n    agent_name: {FQ}.SALES_AGENT\n"
    f"  inventory_toolset:\n    agent_name: {FQ}.INVENTORY_AGENT\n",
    INSTR,
))

sql.append(
    f"CREATE OR REPLACE MCP SERVER {FQ}.BENCH_MCP FROM SPECIFICATION $$\n"
    "tools:\n"
    "  - name: \"sales_agent\"\n    type: \"CORTEX_AGENT_RUN\"\n"
    f"    identifier: \"{FQ}.SALES_AGENT\"\n"
    "    title: \"Sales agent\"\n    description: \"Answers sales questions: revenue, units, orders by product/region/date\"\n"
    "  - name: \"inventory_agent\"\n    type: \"CORTEX_AGENT_RUN\"\n"
    f"    identifier: \"{FQ}.INVENTORY_AGENT\"\n"
    "    title: \"Inventory agent\"\n    description: \"Answers inventory questions: on hand, safety stock, value by product/plant/date\"\n"
    "$$;\n"
)

# "Before" pattern from the original demo: DATA_AGENT_RUN stored procedures as custom tools
SPROC_SQL = f"""-- "Before" pattern: sub-agents wrapped in DATA_AGENT_RUN stored procedures (text-only return),
-- attached to a master agent as custom tools. Usage is logged so sub-agent tokens can be measured;
-- the master still only sees the text, exactly like the original demo.

CREATE TABLE IF NOT EXISTS SUBAGENT_USAGE_LOG (
  logged_at TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP(), agent STRING, run_tag STRING, usage VARIANT);


CREATE OR REPLACE PROCEDURE CALL_SALES_AGENT(QUERY STRING)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    full_result STRING;
    text_result STRING;
    request_json STRING;
BEGIN
    SELECT OBJECT_CONSTRUCT('messages', ARRAY_CONSTRUCT(OBJECT_CONSTRUCT('role', 'user',
             'content', ARRAY_CONSTRUCT(OBJECT_CONSTRUCT('type', 'text', 'text', :query)))))::STRING
      INTO :request_json;
    SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN('{FQ}.SALES_AGENT', :request_json)
      INTO :full_result;
    INSERT INTO {FQ}.SUBAGENT_USAGE_LOG (agent, run_tag, usage)
      SELECT 'SALES_AGENT', CURRENT_QUERY_TAG(), PARSE_JSON(:full_result):metadata:usage;
    SELECT LISTAGG(value:text::STRING, '') WITHIN GROUP (ORDER BY index) INTO :text_result
      FROM TABLE(FLATTEN(INPUT => PARSE_JSON(:full_result):content)) WHERE value:type = 'text';
    RETURN COALESCE(NULLIF(:text_result, ''), :full_result);
END;
$$;

CREATE OR REPLACE PROCEDURE CALL_INVENTORY_AGENT(QUERY STRING)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    full_result STRING;
    text_result STRING;
    request_json STRING;
BEGIN
    SELECT OBJECT_CONSTRUCT('messages', ARRAY_CONSTRUCT(OBJECT_CONSTRUCT('role', 'user',
             'content', ARRAY_CONSTRUCT(OBJECT_CONSTRUCT('type', 'text', 'text', :query)))))::STRING
      INTO :request_json;
    SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN('{FQ}.INVENTORY_AGENT', :request_json)
      INTO :full_result;
    INSERT INTO {FQ}.SUBAGENT_USAGE_LOG (agent, run_tag, usage)
      SELECT 'INVENTORY_AGENT', CURRENT_QUERY_TAG(), PARSE_JSON(:full_result):metadata:usage;
    SELECT LISTAGG(value:text::STRING, '') WITHIN GROUP (ORDER BY index) INTO :text_result
      FROM TABLE(FLATTEN(INPUT => PARSE_JSON(:full_result):content)) WHERE value:type = 'text';
    RETURN COALESCE(NULLIF(:text_result, ''), :full_result);
END;
$$;

CREATE OR REPLACE AGENT {FQ}.MASTER_SPROC_AGENT
  FROM SPECIFICATION $$
models:
  orchestration: claude-sonnet-4-6
instructions:
  response: "Be concise. Return the result table and a chart when the answer has more than one row."
tools:
  - tool_spec:
      type: generic
      name: call_sales_agent
      description: "Ask the sales agent: sales orders, revenue, units by product, region, date"
      input_schema:
        type: object
        properties:
          query:
            type: string
            description: "Natural-language question for the sales agent"
        required: [query]
  - tool_spec:
      type: generic
      name: call_inventory_agent
      description: "Ask the inventory agent: on hand, safety stock, value by product, plant, date"
      input_schema:
        type: object
        properties:
          query:
            type: string
            description: "Natural-language question for the inventory agent"
        required: [query]
  - tool_spec:
      type: data_to_chart
      name: data_to_chart
      description: "Generate a chart from data"
tool_resources:
  call_sales_agent:
    type: procedure
    identifier: {FQ}.CALL_SALES_AGENT
    execution_environment:
      type: warehouse
      warehouse: {WH}
  call_inventory_agent:
    type: procedure
    identifier: {FQ}.CALL_INVENTORY_AGENT
    execution_environment:
      type: warehouse
      warehouse: {WH}
$$;
"""
sql.extend(s.strip() + ("" if s.strip().endswith(";") else ";") for s in SPROC_SQL.split(";\n\n") if s.strip())

open(os.path.join(os.path.dirname(__file__), "setup.sql"), "w").write("\n".join(sql))
print("wrote setup.sql", sum(len(s) for s in sql), "chars")
