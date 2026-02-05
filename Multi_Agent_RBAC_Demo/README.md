# Multi-Agent Orchestration with Row-Based Access Control (RBAC)

This demo shows how to build a **multi-agent system in Snowflake Intelligence** where each user sees only the data they're authorized to access, based on their role.

## Key Concepts

| Concept | Description |
|---------|-------------|
| `EXECUTE AS CALLER` | Procedures run as the logged-in user, not the owner |
| `_snowflake.send_snow_api_request()` | Internal API that inherits the caller's session |
| Row Access Policies | Filter table rows based on `IS_ROLE_IN_SESSION()` |
| Multi-Agent Routing | Orchestrator routes questions to specialized sub-agents |

## Architecture

```
User (logged into Snowflake Intelligence)
    │
    ▼
ORCHESTRATOR_AGENT
    │ routes to appropriate sub-agent
    ├── CALL_SALES_AGENT (EXECUTE AS CALLER)
    │       │ calls REST API as the user
    │       ▼
    │   SALES_AGENT → QUERY_SALES_DATA (EXECUTE AS CALLER)
    │       │
    │       ▼
    │   Row Access Policy filters by region
    │
    ├── CALL_FINANCE_AGENT (EXECUTE AS CALLER)
    │       ▼
    │   FINANCE_AGENT → QUERY_FINANCE_DATA (EXECUTE AS CALLER)
    │       │
    │       ▼
    │   Row Access Policy filters by department
    │
    └── CALL_HR_AGENT (EXECUTE AS CALLER)
            ▼
        HR_AGENT → QUERY_HR_DATA (EXECUTE AS CALLER)
            │
            ▼
        Row Access Policy filters by department/region
```

## Setup Instructions

### Prerequisites
- Snowflake account with ACCOUNTADMIN role
- A warehouse (the demo uses `COMPUTE_WH` - modify if needed)

### Step 1: Run the Setup Script
Execute `01_setup.sql` in a Snowflake worksheet. This creates:
- Database, schemas, and sample data
- Row access policies
- Test users and roles
- Sub-agents (Sales, Finance, HR)
- Orchestrator agent

```sql
-- Run in Snowsight as ACCOUNTADMIN
-- Execute 01_setup.sql
```

### Step 2: Test the RBAC
Execute `02_test_rbac.sql` to verify the row access policies work correctly.

### Step 3: Test in Snowflake Intelligence
Log in as different test users and interact with the agents.

## Test Users

| Username | Password | Role | Data Access |
|----------|----------|------|-------------|
| `SALES_REP_WEST` | `DemoPassword123!` | `SALES_WEST_ROLE` | WEST region sales only |
| `SALES_REP_EAST` | `DemoPassword123!` | `SALES_EAST_ROLE` | EAST region sales only |
| `SALES_MANAGER_USER` | `DemoPassword123!` | `SALES_MANAGER_ROLE` | All sales, SALES budget/HR |
| `FINANCE_ANALYST_USER` | `DemoPassword123!` | `FINANCE_ANALYST_ROLE` | All budgets except EXECUTIVE |
| `HR_REP_USER` | `DemoPassword123!` | `HR_ROLE` | All employees except EXECUTIVE |
| `EXECUTIVE_USER` | `DemoPassword123!` | `EXECUTIVE_ROLE` | **Everything** |

## Test Questions

### Sales Agent
> "List all sales opportunities with deal values"

| User | Expected Result |
|------|-----------------|
| `SALES_REP_WEST` | 5 deals, WEST only (~$775K) |
| `SALES_REP_EAST` | 5 deals, EAST only (~$1.45M) |
| `EXECUTIVE_USER` | 15 deals, all regions (~$3.26M) |

### Finance Agent
> "Show budget by department"

| User | Expected Result |
|------|-----------------|
| `FINANCE_ANALYST_USER` | 3 depts (no EXECUTIVE) ~$2.78M |
| `EXECUTIVE_USER` | 4 depts (incl EXECUTIVE $3.25M) |

### HR Agent
> "List all employees with salaries"

| User | Expected Result |
|------|-----------------|
| `HR_REP_USER` | 13 employees (no EXECUTIVE dept) |
| `EXECUTIVE_USER` | 16 employees (incl CEO $450K) |

## How It Works

### 1. Row Access Policies
Policies evaluate `IS_ROLE_IN_SESSION()` to filter rows:

```sql
CREATE ROW ACCESS POLICY sales_region_policy
AS (region STRING) RETURNS BOOLEAN ->
    CASE
        WHEN IS_ROLE_IN_SESSION('EXECUTIVE_ROLE') THEN TRUE
        WHEN IS_ROLE_IN_SESSION('SALES_WEST_ROLE') AND region = 'WEST' THEN TRUE
        WHEN IS_ROLE_IN_SESSION('SALES_EAST_ROLE') AND region = 'EAST' THEN TRUE
        ELSE FALSE
    END;
```

### 2. EXECUTE AS CALLER Procedures
Procedures run as the calling user, so row access policies apply:

```sql
CREATE PROCEDURE QUERY_SALES_DATA(query_type STRING)
...
EXECUTE AS CALLER  -- Key: runs as logged-in user
AS
$$
    # This query runs as the CALLER, so row access policies filter the results
    session.sql("SELECT * FROM SALES.OPPORTUNITIES")
$$
```

### 3. Sub-Agent Calls via REST API
The `_snowflake.send_snow_api_request()` function inherits the caller's session:

```python
# Inside CALL_SALES_AGENT procedure (EXECUTE AS CALLER)
API_ENDPOINT = "/api/v2/databases/DB/schemas/SCHEMA/agents/SALES_AGENT:run"

# This call runs AS THE LOGGED-IN USER
resp = _snowflake.send_snow_api_request("POST", API_ENDPOINT, {}, {}, payload, None, 60000)
```

## Files

| File | Description |
|------|-------------|
| `01_setup.sql` | Complete setup script - run once |
| `02_test_rbac.sql` | Test queries to verify RBAC works |
| `03_cleanup.sql` | Remove all demo objects |

## Cleanup

To remove all demo objects:

```sql
-- Run 03_cleanup.sql or:
DROP DATABASE IF EXISTS MULTI_AGENT_RBAC_DEMO;
DROP USER IF EXISTS SALES_REP_WEST;
DROP USER IF EXISTS SALES_REP_EAST;
DROP USER IF EXISTS SALES_MANAGER_USER;
DROP USER IF EXISTS FINANCE_ANALYST_USER;
DROP USER IF EXISTS HR_REP_USER;
DROP USER IF EXISTS EXECUTIVE_USER;
DROP ROLE IF EXISTS SALES_WEST_ROLE;
DROP ROLE IF EXISTS SALES_EAST_ROLE;
DROP ROLE IF EXISTS SALES_MANAGER_ROLE;
DROP ROLE IF EXISTS FINANCE_ANALYST_ROLE;
DROP ROLE IF EXISTS HR_ROLE;
DROP ROLE IF EXISTS EXECUTIVE_ROLE;
```

## Troubleshooting

### Agent says "privacy restrictions"
The LLM may add extra caution. The agent instructions tell it not to, but if it persists:
- Test with direct procedure calls: `CALL QUERY_HR_DATA('all');`
- This proves the RBAC works at the database level

### "Unable to connect to data sources" error
Make sure you're selecting agents from `MULTI_AGENT_RBAC_DEMO.AGENTS` schema, not a different database.

### Users can't access agents
Ensure grants are in place:
```sql
GRANT USAGE ON AGENT MULTI_AGENT_RBAC_DEMO.AGENTS.HR_AGENT TO ROLE <role_name>;
```
