/*
================================================================================
MULTI-AGENT RBAC DEMO - SETUP SCRIPT
================================================================================
This script creates a complete multi-agent system with row-based access control.
Run as ACCOUNTADMIN.

Prerequisites:
- Modify WAREHOUSE_NAME variable if you don't have COMPUTE_WH
================================================================================
*/

-- Configuration: Change this if needed
SET WAREHOUSE_NAME = 'COMPUTE_WH';
SET DATABASE_NAME = 'MULTI_AGENT_RBAC_DEMO';

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- STEP 1: CREATE DATABASE AND SCHEMAS
-- ============================================================================

CREATE OR REPLACE DATABASE IDENTIFIER($DATABASE_NAME);
USE DATABASE IDENTIFIER($DATABASE_NAME);

CREATE SCHEMA SALES;
CREATE SCHEMA FINANCE;
CREATE SCHEMA HR;
CREATE SCHEMA AGENTS;
CREATE SCHEMA TOOLS;

-- Create stage for semantic models (used by Cortex Analyst)
CREATE OR REPLACE STAGE AGENTS.SEMANTIC_MODELS
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage for storing Cortex Analyst semantic model YAML files';

-- ============================================================================
-- STEP 2: CREATE ROLES
-- ============================================================================

CREATE ROLE IF NOT EXISTS SALES_WEST_ROLE;
CREATE ROLE IF NOT EXISTS SALES_EAST_ROLE;
CREATE ROLE IF NOT EXISTS SALES_MANAGER_ROLE;
CREATE ROLE IF NOT EXISTS FINANCE_ANALYST_ROLE;
CREATE ROLE IF NOT EXISTS HR_ROLE;
CREATE ROLE IF NOT EXISTS EXECUTIVE_ROLE;

-- Grant roles to ACCOUNTADMIN for management
GRANT ROLE SALES_WEST_ROLE TO ROLE ACCOUNTADMIN;
GRANT ROLE SALES_EAST_ROLE TO ROLE ACCOUNTADMIN;
GRANT ROLE SALES_MANAGER_ROLE TO ROLE ACCOUNTADMIN;
GRANT ROLE FINANCE_ANALYST_ROLE TO ROLE ACCOUNTADMIN;
GRANT ROLE HR_ROLE TO ROLE ACCOUNTADMIN;
GRANT ROLE EXECUTIVE_ROLE TO ROLE ACCOUNTADMIN;

-- ============================================================================
-- STEP 3: CREATE SAMPLE DATA
-- ============================================================================

-- Sales Opportunities
CREATE OR REPLACE TABLE SALES.OPPORTUNITIES (
    opportunity_id INT,
    account_name STRING,
    deal_value DECIMAL(12,2),
    stage STRING,
    region STRING,
    sales_rep STRING,
    close_date DATE,
    product STRING
);

INSERT INTO SALES.OPPORTUNITIES VALUES
-- WEST region deals
(1001, 'Acme Corp', 150000, 'Closed Won', 'WEST', 'Alice Johnson', '2025-01-15', 'Enterprise Platform'),
(1002, 'TechStart Inc', 75000, 'Negotiation', 'WEST', 'Alice Johnson', '2025-02-28', 'Data Analytics'),
(1003, 'Pacific Solutions', 200000, 'Closed Won', 'WEST', 'Bob Smith', '2025-01-20', 'Enterprise Platform'),
(1004, 'Golden Gate Ltd', 50000, 'Proposal', 'WEST', 'Alice Johnson', '2025-03-15', 'Cloud Storage'),
(1005, 'Silicon Dynamics', 300000, 'Closed Won', 'WEST', 'Bob Smith', '2025-02-01', 'AI Suite'),
-- EAST region deals
(1006, 'Atlantic Industries', 450000, 'Closed Won', 'EAST', 'Carol Davis', '2025-01-10', 'Enterprise Platform'),
(1007, 'Metro Systems', 180000, 'Negotiation', 'EAST', 'Dan Wilson', '2025-03-01', 'Data Analytics'),
(1008, 'Eastern Digital', 350000, 'Closed Won', 'EAST', 'Carol Davis', '2025-02-15', 'AI Suite'),
(1009, 'Harbor Tech', 120000, 'Proposal', 'EAST', 'Dan Wilson', '2025-04-01', 'Cloud Storage'),
(1010, 'Coastal Innovations', 350000, 'Closed Won', 'EAST', 'Carol Davis', '2025-01-25', 'Enterprise Platform'),
-- CENTRAL region deals
(1011, 'Midwest Manufacturing', 280000, 'Closed Won', 'CENTRAL', 'Eve Martinez', '2025-02-10', 'AI Suite'),
(1012, 'Plains Energy Co', 200000, 'Negotiation', 'CENTRAL', 'Frank Brown', '2025-03-20', 'Data Analytics'),
(1013, 'Heartland Services', 150000, 'Closed Won', 'CENTRAL', 'Eve Martinez', '2025-01-30', 'Enterprise Platform'),
(1014, 'Central Logistics', 250000, 'Proposal', 'CENTRAL', 'Frank Brown', '2025-04-15', 'Cloud Storage'),
(1015, 'Great Lakes Tech', 150000, 'Closed Won', 'CENTRAL', 'Eve Martinez', '2025-02-20', 'Data Analytics');

-- Finance Budget
CREATE OR REPLACE TABLE FINANCE.BUDGET (
    budget_id INT,
    department STRING,
    category STRING,
    allocated_amount DECIMAL(12,2),
    spent_amount DECIMAL(12,2),
    fiscal_year INT,
    quarter STRING
);

INSERT INTO FINANCE.BUDGET VALUES
-- SALES department
(1, 'SALES', 'Marketing', 200000, 180000, 2025, 'Q1'),
(2, 'SALES', 'Travel', 150000, 120000, 2025, 'Q1'),
(3, 'SALES', 'Training', 100000, 90000, 2025, 'Q1'),
(4, 'SALES', 'Events', 100000, 90000, 2025, 'Q1'),
-- ENGINEERING department
(5, 'ENGINEERING', 'Cloud Infrastructure', 500000, 450000, 2025, 'Q1'),
(6, 'ENGINEERING', 'Software Licenses', 300000, 280000, 2025, 'Q1'),
(7, 'ENGINEERING', 'R&D', 400000, 350000, 2025, 'Q1'),
(8, 'ENGINEERING', 'Equipment', 250000, 125000, 2025, 'Q1'),
-- HR department
(9, 'HR', 'Recruiting', 300000, 250000, 2025, 'Q1'),
(10, 'HR', 'Benefits Administration', 200000, 180000, 2025, 'Q1'),
(11, 'HR', 'Training Programs', 275000, 240000, 2025, 'Q1'),
-- EXECUTIVE department (restricted)
(12, 'EXECUTIVE', 'Strategic Initiatives', 2000000, 500000, 2025, 'Q1'),
(13, 'EXECUTIVE', 'M&A Reserve', 1000000, 150000, 2025, 'Q1'),
(14, 'EXECUTIVE', 'Board Operations', 250000, 50000, 2025, 'Q1');

-- HR Employees
CREATE OR REPLACE TABLE HR.EMPLOYEES (
    employee_id INT,
    name STRING,
    title STRING,
    department STRING,
    region STRING,
    hire_date DATE,
    salary DECIMAL(12,2)
);

INSERT INTO HR.EMPLOYEES VALUES
-- SALES employees
(1, 'Alice Johnson', 'Sales Rep', 'SALES', 'WEST', '2022-03-15', 120000),
(2, 'Bob Smith', 'Sales Rep', 'SALES', 'WEST', '2021-06-01', 115000),
(3, 'Carol Davis', 'Sr Sales Rep', 'SALES', 'EAST', '2020-02-01', 140000),
(4, 'Dan Wilson', 'Sales Rep', 'SALES', 'EAST', '2023-04-15', 110000),
(5, 'Eve Martinez', 'Sales Rep', 'SALES', 'CENTRAL', '2021-09-15', 118000),
(6, 'Frank Brown', 'Sales Manager', 'SALES', 'CENTRAL', '2018-05-01', 160000),
-- ENGINEERING employees
(7, 'Grace Lee', 'Software Engineer', 'ENGINEERING', 'WEST', '2023-01-10', 145000),
(8, 'Henry Chen', 'Data Scientist', 'ENGINEERING', 'WEST', '2022-08-20', 155000),
(9, 'Ivy Zhang', 'Sr Engineer', 'ENGINEERING', 'EAST', '2019-11-01', 165000),
(10, 'Jack Brown', 'Engineer', 'ENGINEERING', 'EAST', '2022-07-01', 135000),
(11, 'Kim Park', 'Engineering Manager', 'ENGINEERING', 'CENTRAL', '2017-03-01', 180000),
-- HR employees
(12, 'Leo Garcia', 'HR Specialist', 'HR', 'CENTRAL', '2022-01-15', 95000),
(13, 'Maria Santos', 'HR Manager', 'HR', 'CENTRAL', '2019-06-01', 130000),
-- EXECUTIVE employees (restricted)
(14, 'Nancy White', 'CEO', 'EXECUTIVE', 'HQ', '2015-01-01', 450000),
(15, 'Oscar Black', 'CFO', 'EXECUTIVE', 'HQ', '2016-03-01', 380000),
(16, 'Paula Green', 'CTO', 'EXECUTIVE', 'HQ', '2016-06-01', 400000);

-- ============================================================================
-- STEP 4: CREATE ROW ACCESS POLICIES
-- ============================================================================

-- Sales: Filter by region
CREATE OR REPLACE ROW ACCESS POLICY SALES.SALES_REGION_POLICY
AS (region STRING) RETURNS BOOLEAN ->
    CASE
        WHEN IS_ROLE_IN_SESSION('EXECUTIVE_ROLE') THEN TRUE
        WHEN IS_ROLE_IN_SESSION('SALES_MANAGER_ROLE') THEN TRUE
        WHEN IS_ROLE_IN_SESSION('ACCOUNTADMIN') THEN TRUE
        WHEN IS_ROLE_IN_SESSION('SALES_WEST_ROLE') AND region = 'WEST' THEN TRUE
        WHEN IS_ROLE_IN_SESSION('SALES_EAST_ROLE') AND region = 'EAST' THEN TRUE
        ELSE FALSE
    END;

ALTER TABLE SALES.OPPORTUNITIES ADD ROW ACCESS POLICY SALES.SALES_REGION_POLICY ON (region);

-- Finance: Filter by department
CREATE OR REPLACE ROW ACCESS POLICY FINANCE.BUDGET_DEPT_POLICY
AS (department STRING) RETURNS BOOLEAN ->
    CASE
        WHEN IS_ROLE_IN_SESSION('EXECUTIVE_ROLE') THEN TRUE
        WHEN IS_ROLE_IN_SESSION('ACCOUNTADMIN') THEN TRUE
        WHEN IS_ROLE_IN_SESSION('FINANCE_ANALYST_ROLE') AND department != 'EXECUTIVE' THEN TRUE
        WHEN IS_ROLE_IN_SESSION('SALES_MANAGER_ROLE') AND department = 'SALES' THEN TRUE
        WHEN IS_ROLE_IN_SESSION('HR_ROLE') AND department = 'HR' THEN TRUE
        ELSE FALSE
    END;

ALTER TABLE FINANCE.BUDGET ADD ROW ACCESS POLICY FINANCE.BUDGET_DEPT_POLICY ON (department);

-- HR: Filter by department and region
CREATE OR REPLACE ROW ACCESS POLICY HR.EMPLOYEE_ACCESS_POLICY
AS (department STRING, region STRING) RETURNS BOOLEAN ->
    CASE
        WHEN IS_ROLE_IN_SESSION('EXECUTIVE_ROLE') THEN TRUE
        WHEN IS_ROLE_IN_SESSION('ACCOUNTADMIN') THEN TRUE
        WHEN IS_ROLE_IN_SESSION('HR_ROLE') AND department != 'EXECUTIVE' THEN TRUE
        WHEN IS_ROLE_IN_SESSION('SALES_MANAGER_ROLE') AND department = 'SALES' THEN TRUE
        WHEN IS_ROLE_IN_SESSION('SALES_WEST_ROLE') AND region = 'WEST' THEN TRUE
        WHEN IS_ROLE_IN_SESSION('SALES_EAST_ROLE') AND region = 'EAST' THEN TRUE
        ELSE FALSE
    END;

ALTER TABLE HR.EMPLOYEES ADD ROW ACCESS POLICY HR.EMPLOYEE_ACCESS_POLICY ON (department, region);

-- ============================================================================
-- STEP 5: CREATE TEST USERS
-- ============================================================================

CREATE USER IF NOT EXISTS SALES_REP_WEST
    PASSWORD = 'DemoPassword123!'
    DEFAULT_ROLE = SALES_WEST_ROLE
    DEFAULT_WAREHOUSE = IDENTIFIER($WAREHOUSE_NAME)
    MUST_CHANGE_PASSWORD = FALSE;

CREATE USER IF NOT EXISTS SALES_REP_EAST
    PASSWORD = 'DemoPassword123!'
    DEFAULT_ROLE = SALES_EAST_ROLE
    DEFAULT_WAREHOUSE = IDENTIFIER($WAREHOUSE_NAME)
    MUST_CHANGE_PASSWORD = FALSE;

CREATE USER IF NOT EXISTS SALES_MANAGER_USER
    PASSWORD = 'DemoPassword123!'
    DEFAULT_ROLE = SALES_MANAGER_ROLE
    DEFAULT_WAREHOUSE = IDENTIFIER($WAREHOUSE_NAME)
    MUST_CHANGE_PASSWORD = FALSE;

CREATE USER IF NOT EXISTS FINANCE_ANALYST_USER
    PASSWORD = 'DemoPassword123!'
    DEFAULT_ROLE = FINANCE_ANALYST_ROLE
    DEFAULT_WAREHOUSE = IDENTIFIER($WAREHOUSE_NAME)
    MUST_CHANGE_PASSWORD = FALSE;

CREATE USER IF NOT EXISTS HR_REP_USER
    PASSWORD = 'DemoPassword123!'
    DEFAULT_ROLE = HR_ROLE
    DEFAULT_WAREHOUSE = IDENTIFIER($WAREHOUSE_NAME)
    MUST_CHANGE_PASSWORD = FALSE;

CREATE USER IF NOT EXISTS EXECUTIVE_USER
    PASSWORD = 'DemoPassword123!'
    DEFAULT_ROLE = EXECUTIVE_ROLE
    DEFAULT_WAREHOUSE = IDENTIFIER($WAREHOUSE_NAME)
    MUST_CHANGE_PASSWORD = FALSE;

-- Grant roles to users
GRANT ROLE SALES_WEST_ROLE TO USER SALES_REP_WEST;
GRANT ROLE SALES_EAST_ROLE TO USER SALES_REP_EAST;
GRANT ROLE SALES_MANAGER_ROLE TO USER SALES_MANAGER_USER;
GRANT ROLE FINANCE_ANALYST_ROLE TO USER FINANCE_ANALYST_USER;
GRANT ROLE HR_ROLE TO USER HR_REP_USER;
GRANT ROLE EXECUTIVE_ROLE TO USER EXECUTIVE_USER;

-- ============================================================================
-- STEP 6: GRANT PERMISSIONS TO ROLES
-- ============================================================================

-- Warehouse access
GRANT USAGE ON WAREHOUSE IDENTIFIER($WAREHOUSE_NAME) TO ROLE SALES_WEST_ROLE;
GRANT USAGE ON WAREHOUSE IDENTIFIER($WAREHOUSE_NAME) TO ROLE SALES_EAST_ROLE;
GRANT USAGE ON WAREHOUSE IDENTIFIER($WAREHOUSE_NAME) TO ROLE SALES_MANAGER_ROLE;
GRANT USAGE ON WAREHOUSE IDENTIFIER($WAREHOUSE_NAME) TO ROLE FINANCE_ANALYST_ROLE;
GRANT USAGE ON WAREHOUSE IDENTIFIER($WAREHOUSE_NAME) TO ROLE HR_ROLE;
GRANT USAGE ON WAREHOUSE IDENTIFIER($WAREHOUSE_NAME) TO ROLE EXECUTIVE_ROLE;

-- Database access
GRANT USAGE ON DATABASE IDENTIFIER($DATABASE_NAME) TO ROLE SALES_WEST_ROLE;
GRANT USAGE ON DATABASE IDENTIFIER($DATABASE_NAME) TO ROLE SALES_EAST_ROLE;
GRANT USAGE ON DATABASE IDENTIFIER($DATABASE_NAME) TO ROLE SALES_MANAGER_ROLE;
GRANT USAGE ON DATABASE IDENTIFIER($DATABASE_NAME) TO ROLE FINANCE_ANALYST_ROLE;
GRANT USAGE ON DATABASE IDENTIFIER($DATABASE_NAME) TO ROLE HR_ROLE;
GRANT USAGE ON DATABASE IDENTIFIER($DATABASE_NAME) TO ROLE EXECUTIVE_ROLE;

-- Schema access (all schemas to all roles - policies handle data filtering)
GRANT USAGE ON ALL SCHEMAS IN DATABASE IDENTIFIER($DATABASE_NAME) TO ROLE SALES_WEST_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE IDENTIFIER($DATABASE_NAME) TO ROLE SALES_EAST_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE IDENTIFIER($DATABASE_NAME) TO ROLE SALES_MANAGER_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE IDENTIFIER($DATABASE_NAME) TO ROLE FINANCE_ANALYST_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE IDENTIFIER($DATABASE_NAME) TO ROLE HR_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE IDENTIFIER($DATABASE_NAME) TO ROLE EXECUTIVE_ROLE;

-- Table access
GRANT SELECT ON ALL TABLES IN DATABASE IDENTIFIER($DATABASE_NAME) TO ROLE SALES_WEST_ROLE;
GRANT SELECT ON ALL TABLES IN DATABASE IDENTIFIER($DATABASE_NAME) TO ROLE SALES_EAST_ROLE;
GRANT SELECT ON ALL TABLES IN DATABASE IDENTIFIER($DATABASE_NAME) TO ROLE SALES_MANAGER_ROLE;
GRANT SELECT ON ALL TABLES IN DATABASE IDENTIFIER($DATABASE_NAME) TO ROLE FINANCE_ANALYST_ROLE;
GRANT SELECT ON ALL TABLES IN DATABASE IDENTIFIER($DATABASE_NAME) TO ROLE HR_ROLE;
GRANT SELECT ON ALL TABLES IN DATABASE IDENTIFIER($DATABASE_NAME) TO ROLE EXECUTIVE_ROLE;

-- Cortex access
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE SALES_WEST_ROLE;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE SALES_EAST_ROLE;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE SALES_MANAGER_ROLE;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE FINANCE_ANALYST_ROLE;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE HR_ROLE;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE EXECUTIVE_ROLE;

-- ============================================================================
-- STEP 7: CREATE QUERY PROCEDURES (EXECUTE AS CALLER)
-- ============================================================================

USE SCHEMA TOOLS;

-- Sales Query Procedure
CREATE OR REPLACE PROCEDURE QUERY_SALES_DATA(query_type STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'handler'
EXECUTE AS CALLER
AS
$$
import json

def handler(session, query_type: str):
    ctx = session.sql("SELECT CURRENT_USER() as u, CURRENT_ROLE() as r").collect()[0]
    caller_info = f"User: {ctx['U']}, Role: {ctx['R']}"
    
    results = {
        "caller": caller_info, 
        "query_type": query_type,
        "security_note": "DATA FILTERED BY ROW ACCESS POLICIES"
    }
    
    try:
        if query_type.lower() == "summary":
            df = session.sql("""
                SELECT region, COUNT(*) as deal_count, SUM(deal_value) as total_value, AVG(deal_value) as avg_deal_size
                FROM MULTI_AGENT_RBAC_DEMO.SALES.OPPORTUNITIES GROUP BY region
            """).collect()
            results["data"] = [row.as_dict() for row in df]
        elif query_type.lower() == "pipeline":
            df = session.sql("""
                SELECT stage, COUNT(*) as count, SUM(deal_value) as total_amount
                FROM MULTI_AGENT_RBAC_DEMO.SALES.OPPORTUNITIES GROUP BY stage ORDER BY total_amount DESC
            """).collect()
            results["data"] = [row.as_dict() for row in df]
        elif query_type.lower() == "top_deals":
            df = session.sql("""
                SELECT account_name, deal_value, stage, region, sales_rep
                FROM MULTI_AGENT_RBAC_DEMO.SALES.OPPORTUNITIES ORDER BY deal_value DESC LIMIT 5
            """).collect()
            results["data"] = [row.as_dict() for row in df]
        else:
            df = session.sql("SELECT * FROM MULTI_AGENT_RBAC_DEMO.SALES.OPPORTUNITIES ORDER BY deal_value DESC").collect()
            results["data"] = [row.as_dict() for row in df]
            results["row_count"] = len(df)
    except Exception as e:
        results["error"] = str(e)
    
    return json.dumps(results, default=str)
$$;

-- Finance Query Procedure
CREATE OR REPLACE PROCEDURE QUERY_FINANCE_DATA(query_type STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'handler'
EXECUTE AS CALLER
AS
$$
import json

def handler(session, query_type: str):
    ctx = session.sql("SELECT CURRENT_USER() as u, CURRENT_ROLE() as r").collect()[0]
    caller_info = f"User: {ctx['U']}, Role: {ctx['R']}"
    
    results = {
        "caller": caller_info, 
        "query_type": query_type,
        "security_note": "DATA FILTERED BY ROW ACCESS POLICIES"
    }
    
    try:
        if query_type.lower() == "summary":
            df = session.sql("""
                SELECT department, fiscal_year, SUM(allocated_amount) as total_budget, 
                       SUM(spent_amount) as total_spent, SUM(allocated_amount - spent_amount) as remaining
                FROM MULTI_AGENT_RBAC_DEMO.FINANCE.BUDGET GROUP BY department, fiscal_year ORDER BY department
            """).collect()
            results["data"] = [row.as_dict() for row in df]
        elif query_type.lower() == "variance":
            df = session.sql("""
                SELECT department, category, allocated_amount, spent_amount,
                       (spent_amount - allocated_amount) as variance,
                       ROUND((spent_amount / allocated_amount) * 100, 1) as pct_used
                FROM MULTI_AGENT_RBAC_DEMO.FINANCE.BUDGET WHERE fiscal_year = 2025 ORDER BY variance DESC
            """).collect()
            results["data"] = [row.as_dict() for row in df]
        else:
            df = session.sql("SELECT * FROM MULTI_AGENT_RBAC_DEMO.FINANCE.BUDGET ORDER BY department").collect()
            results["data"] = [row.as_dict() for row in df]
            results["row_count"] = len(df)
    except Exception as e:
        results["error"] = str(e)
    
    return json.dumps(results, default=str)
$$;

-- HR Query Procedure
CREATE OR REPLACE PROCEDURE QUERY_HR_DATA(query_type STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'handler'
EXECUTE AS CALLER
AS
$$
import json

def handler(session, query_type: str):
    ctx = session.sql("SELECT CURRENT_USER() as u, CURRENT_ROLE() as r").collect()[0]
    caller_info = f"User: {ctx['U']}, Role: {ctx['R']}"
    
    results = {
        "caller": caller_info, 
        "query_type": query_type,
        "security_note": "DATA FILTERED BY ROW ACCESS POLICIES - SAFE TO DISPLAY ALL"
    }
    
    try:
        if query_type.lower() == "headcount":
            df = session.sql("""
                SELECT department, region, COUNT(*) as headcount, AVG(salary) as avg_salary
                FROM MULTI_AGENT_RBAC_DEMO.HR.EMPLOYEES GROUP BY department, region ORDER BY department, region
            """).collect()
            results["data"] = [row.as_dict() for row in df]
        elif query_type.lower() == "compensation":
            df = session.sql("""
                SELECT department, MIN(salary) as min_salary, AVG(salary) as avg_salary,
                       MAX(salary) as max_salary, SUM(salary) as total_payroll
                FROM MULTI_AGENT_RBAC_DEMO.HR.EMPLOYEES GROUP BY department ORDER BY total_payroll DESC
            """).collect()
            results["data"] = [row.as_dict() for row in df]
        else:
            df = session.sql("""
                SELECT employee_id, name, title, department, region, hire_date, salary
                FROM MULTI_AGENT_RBAC_DEMO.HR.EMPLOYEES ORDER BY salary DESC
            """).collect()
            results["employees"] = [row.as_dict() for row in df]
            results["row_count"] = len(df)
    except Exception as e:
        results["error"] = str(e)
    
    return json.dumps(results, default=str)
$$;

-- ============================================================================
-- STEP 8: CREATE SUB-AGENT CALLER PROCEDURES
-- ============================================================================

-- Call Sales Agent as Caller
CREATE OR REPLACE PROCEDURE CALL_SALES_AGENT(query STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'handler'
EXECUTE AS CALLER
AS
$$
import json
import _snowflake

def handler(session, query: str):
    ctx = session.sql("SELECT CURRENT_USER() as u, CURRENT_ROLE() as r").collect()[0]
    caller_info = f"User: {ctx['U']}, Role: {ctx['R']}"
    
    API_ENDPOINT = "/api/v2/databases/MULTI_AGENT_RBAC_DEMO/schemas/AGENTS/agents/SALES_AGENT:run"
    payload = {"messages": [{"role": "user", "content": [{"type": "text", "text": query}]}]}
    
    try:
        resp = _snowflake.send_snow_api_request("POST", API_ENDPOINT, {}, {}, payload, None, 60000)
        
        if resp["status"] != 200:
            return json.dumps({"caller": caller_info, "error": f"API call failed: {resp['status']}"})
        
        response_content = json.loads(resp["content"])
        agent_response_parts = []
        for event in response_content:
            if event.get("event") == "response.text":
                text = event.get("data", {}).get("text", "")
                if text:
                    agent_response_parts.append(text)
        
        return json.dumps({"caller": caller_info, "agent": "SALES_AGENT", "response": "".join(agent_response_parts)})
    except Exception as e:
        return json.dumps({"caller": caller_info, "error": str(e)})
$$;

-- Call Finance Agent as Caller
CREATE OR REPLACE PROCEDURE CALL_FINANCE_AGENT(query STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'handler'
EXECUTE AS CALLER
AS
$$
import json
import _snowflake

def handler(session, query: str):
    ctx = session.sql("SELECT CURRENT_USER() as u, CURRENT_ROLE() as r").collect()[0]
    caller_info = f"User: {ctx['U']}, Role: {ctx['R']}"
    
    API_ENDPOINT = "/api/v2/databases/MULTI_AGENT_RBAC_DEMO/schemas/AGENTS/agents/FINANCE_AGENT:run"
    payload = {"messages": [{"role": "user", "content": [{"type": "text", "text": query}]}]}
    
    try:
        resp = _snowflake.send_snow_api_request("POST", API_ENDPOINT, {}, {}, payload, None, 60000)
        
        if resp["status"] != 200:
            return json.dumps({"caller": caller_info, "error": f"API call failed: {resp['status']}"})
        
        response_content = json.loads(resp["content"])
        agent_response_parts = []
        for event in response_content:
            if event.get("event") == "response.text":
                text = event.get("data", {}).get("text", "")
                if text:
                    agent_response_parts.append(text)
        
        return json.dumps({"caller": caller_info, "agent": "FINANCE_AGENT", "response": "".join(agent_response_parts)})
    except Exception as e:
        return json.dumps({"caller": caller_info, "error": str(e)})
$$;

-- Call HR Agent as Caller
CREATE OR REPLACE PROCEDURE CALL_HR_AGENT(query STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'handler'
EXECUTE AS CALLER
AS
$$
import json
import _snowflake

def handler(session, query: str):
    ctx = session.sql("SELECT CURRENT_USER() as u, CURRENT_ROLE() as r").collect()[0]
    caller_info = f"User: {ctx['U']}, Role: {ctx['R']}"
    
    API_ENDPOINT = "/api/v2/databases/MULTI_AGENT_RBAC_DEMO/schemas/AGENTS/agents/HR_AGENT:run"
    payload = {"messages": [{"role": "user", "content": [{"type": "text", "text": query}]}]}
    
    try:
        resp = _snowflake.send_snow_api_request("POST", API_ENDPOINT, {}, {}, payload, None, 60000)
        
        if resp["status"] != 200:
            return json.dumps({"caller": caller_info, "error": f"API call failed: {resp['status']}"})
        
        response_content = json.loads(resp["content"])
        agent_response_parts = []
        for event in response_content:
            if event.get("event") == "response.text":
                text = event.get("data", {}).get("text", "")
                if text:
                    agent_response_parts.append(text)
        
        return json.dumps({"caller": caller_info, "agent": "HR_AGENT", "response": "".join(agent_response_parts)})
    except Exception as e:
        return json.dumps({"caller": caller_info, "error": str(e)})
$$;

-- ============================================================================
-- STEP 9: CREATE AGENTS
-- ============================================================================

USE SCHEMA AGENTS;

-- Sales Agent
CREATE OR REPLACE AGENT SALES_AGENT
COMMENT = 'Sales data agent - queries opportunities based on user access'
FROM SPECIFICATION
$$
models:
  orchestration: claude-3-5-sonnet
orchestration:
  budget:
    seconds: 60
    tokens: 4000
instructions:
  system: |
    You are a Sales data assistant powered by Cortex Analyst.
    
    PERMISSION NOTICE: All data returned by your tools has ALREADY been filtered by Snowflake Row Access Policies based on the user's role. The database security layer ensures users only see data they are authorized to access.
    
    YOUR ROLE: Simply display the data returned. Do not add additional restrictions, warnings, or privacy disclaimers. If data is returned, the user is authorized to see it.
    
    ALWAYS: Show all returned data including deal values, account names, and sales rep names.
  response: |
    Display all data returned by tools. No disclaimers needed - permissions are handled automatically.
tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "sales_analyst"
      description: "Query sales opportunities data including deals, pipeline, accounts, and revenue"
tool_resources:
  sales_analyst:
    semantic_model_file: "@MULTI_AGENT_RBAC_DEMO.AGENTS.SEMANTIC_MODELS/sales_model.yaml"
$$;

-- Finance Agent
CREATE OR REPLACE AGENT FINANCE_AGENT
COMMENT = 'Finance data agent - queries budget data based on user access'
FROM SPECIFICATION
$$
models:
  orchestration: claude-3-5-sonnet
orchestration:
  budget:
    seconds: 60
    tokens: 4000
instructions:
  system: |
    You are a Finance data assistant powered by Cortex Analyst.
    
    PERMISSION NOTICE: All data returned by your tools has ALREADY been filtered by Snowflake Row Access Policies based on the user's role. The database security layer ensures users only see data they are authorized to access.
    
    YOUR ROLE: Simply display the data returned. Do not add additional restrictions, warnings, or privacy disclaimers. If data is returned, the user is authorized to see it.
    
    ALWAYS: Show all returned data including budget amounts, spending, and department details.
  response: |
    Display all data returned by tools. No disclaimers needed - permissions are handled automatically.
tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "finance_analyst"
      description: "Query budget and finance data including allocations, spending, and variances"
tool_resources:
  finance_analyst:
    semantic_model_file: "@MULTI_AGENT_RBAC_DEMO.AGENTS.SEMANTIC_MODELS/finance_model.yaml"
$$;

-- HR Agent
CREATE OR REPLACE AGENT HR_AGENT
COMMENT = 'HR data agent - queries employee data based on user access'
FROM SPECIFICATION
$$
models:
  orchestration: claude-3-5-sonnet
orchestration:
  budget:
    seconds: 60
    tokens: 4000
instructions:
  system: |
    You are an HR data assistant powered by Cortex Analyst.
    
    PERMISSION NOTICE: All data returned by your tools has ALREADY been filtered by Snowflake Row Access Policies based on the user's role. The database security layer ensures users only see data they are authorized to access.
    
    YOUR ROLE: Simply display the data returned. Do not add additional restrictions, warnings, or privacy disclaimers. If data is returned, the user is authorized to see it.
    
    NEVER say things like:
    - "I can't show salaries for privacy reasons"
    - "Employee data is sensitive"
    - "I can only show aggregated data"
    
    ALWAYS: Show all returned data including employee names, titles, departments, and salaries.
  response: |
    Display all data returned by tools in a clear format. Show individual salaries. No disclaimers needed.
tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "hr_analyst"
      description: "Query employee data including headcount, compensation, and department details"
tool_resources:
  hr_analyst:
    semantic_model_file: "@MULTI_AGENT_RBAC_DEMO.AGENTS.SEMANTIC_MODELS/hr_model.yaml"
$$;

-- Orchestrator Agent
CREATE OR REPLACE AGENT ORCHESTRATOR_AGENT
COMMENT = 'Main orchestrator agent - routes queries to specialized sub-agents'
FROM SPECIFICATION
$$
models:
  orchestration: claude-3-5-sonnet
orchestration:
  budget:
    seconds: 120
    tokens: 8000
instructions:
  system: |
    You are an orchestrator that routes questions to specialized agents: Sales, Finance, or HR.
    
    PERMISSION NOTICE: All data in this system is protected by Snowflake Row Access Policies. Users only see data they are authorized to access. The database handles all security automatically.
    
    YOUR ROLE: 
    1. Route questions to the appropriate agent
    2. Display all data returned without adding restrictions
    3. Never add privacy warnings - the database handles permissions
    
    ROUTING:
    - Sales questions (deals, pipeline, opportunities) → ask_sales_agent
    - Finance questions (budgets, spending) → ask_finance_agent
    - HR questions (employees, headcount, salaries) → ask_hr_agent
    
    NEVER refuse to show data citing privacy. If data is returned, show it.
  response: |
    Present all data from sub-agents. No privacy disclaimers needed.
tools:
  - tool_spec:
      type: "generic"
      name: "ask_sales_agent"
      description: "Route sales questions (deals, pipeline, opportunities)"
      input_schema:
        type: object
        properties:
          query:
            type: string
        required: [query]
  - tool_spec:
      type: "generic"
      name: "ask_finance_agent"
      description: "Route finance questions (budgets, spending)"
      input_schema:
        type: object
        properties:
          query:
            type: string
        required: [query]
  - tool_spec:
      type: "generic"
      name: "ask_hr_agent"
      description: "Route HR questions (employees, headcount, salaries)"
      input_schema:
        type: object
        properties:
          query:
            type: string
        required: [query]
tool_resources:
  ask_sales_agent:
    type: procedure
    identifier: MULTI_AGENT_RBAC_DEMO.TOOLS.CALL_SALES_AGENT
    execution_environment:
      type: warehouse
  ask_finance_agent:
    type: procedure
    identifier: MULTI_AGENT_RBAC_DEMO.TOOLS.CALL_FINANCE_AGENT
    execution_environment:
      type: warehouse
  ask_hr_agent:
    type: procedure
    identifier: MULTI_AGENT_RBAC_DEMO.TOOLS.CALL_HR_AGENT
    execution_environment:
      type: warehouse
$$;

-- ============================================================================
-- STEP 10: GRANT PERMISSIONS ON PROCEDURES AND AGENTS
-- ============================================================================

-- Grant procedure usage (still needed for orchestrator's sub-agent calls)
GRANT USAGE ON ALL PROCEDURES IN SCHEMA MULTI_AGENT_RBAC_DEMO.TOOLS TO ROLE SALES_WEST_ROLE;
GRANT USAGE ON ALL PROCEDURES IN SCHEMA MULTI_AGENT_RBAC_DEMO.TOOLS TO ROLE SALES_EAST_ROLE;
GRANT USAGE ON ALL PROCEDURES IN SCHEMA MULTI_AGENT_RBAC_DEMO.TOOLS TO ROLE SALES_MANAGER_ROLE;
GRANT USAGE ON ALL PROCEDURES IN SCHEMA MULTI_AGENT_RBAC_DEMO.TOOLS TO ROLE FINANCE_ANALYST_ROLE;
GRANT USAGE ON ALL PROCEDURES IN SCHEMA MULTI_AGENT_RBAC_DEMO.TOOLS TO ROLE HR_ROLE;
GRANT USAGE ON ALL PROCEDURES IN SCHEMA MULTI_AGENT_RBAC_DEMO.TOOLS TO ROLE EXECUTIVE_ROLE;

-- Grant stage read access for semantic models (required for Cortex Analyst)
GRANT READ ON STAGE MULTI_AGENT_RBAC_DEMO.AGENTS.SEMANTIC_MODELS TO ROLE SALES_WEST_ROLE;
GRANT READ ON STAGE MULTI_AGENT_RBAC_DEMO.AGENTS.SEMANTIC_MODELS TO ROLE SALES_EAST_ROLE;
GRANT READ ON STAGE MULTI_AGENT_RBAC_DEMO.AGENTS.SEMANTIC_MODELS TO ROLE SALES_MANAGER_ROLE;
GRANT READ ON STAGE MULTI_AGENT_RBAC_DEMO.AGENTS.SEMANTIC_MODELS TO ROLE FINANCE_ANALYST_ROLE;
GRANT READ ON STAGE MULTI_AGENT_RBAC_DEMO.AGENTS.SEMANTIC_MODELS TO ROLE HR_ROLE;
GRANT READ ON STAGE MULTI_AGENT_RBAC_DEMO.AGENTS.SEMANTIC_MODELS TO ROLE EXECUTIVE_ROLE;

-- Grant agent usage
GRANT USAGE ON ALL AGENTS IN SCHEMA MULTI_AGENT_RBAC_DEMO.AGENTS TO ROLE SALES_WEST_ROLE;
GRANT USAGE ON ALL AGENTS IN SCHEMA MULTI_AGENT_RBAC_DEMO.AGENTS TO ROLE SALES_EAST_ROLE;
GRANT USAGE ON ALL AGENTS IN SCHEMA MULTI_AGENT_RBAC_DEMO.AGENTS TO ROLE SALES_MANAGER_ROLE;
GRANT USAGE ON ALL AGENTS IN SCHEMA MULTI_AGENT_RBAC_DEMO.AGENTS TO ROLE FINANCE_ANALYST_ROLE;
GRANT USAGE ON ALL AGENTS IN SCHEMA MULTI_AGENT_RBAC_DEMO.AGENTS TO ROLE HR_ROLE;
GRANT USAGE ON ALL AGENTS IN SCHEMA MULTI_AGENT_RBAC_DEMO.AGENTS TO ROLE EXECUTIVE_ROLE;

-- ============================================================================
-- SETUP COMPLETE!
-- ============================================================================

SELECT 'Setup complete! Upload semantic model YAML files to the stage before testing.' as STATUS;
