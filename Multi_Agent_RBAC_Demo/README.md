# Multi-Agent Orchestration with Row-Based Access Control (RBAC)

This demo shows how to build a **multi-agent system in Snowflake Intelligence** where each user sees only the data they're authorized to access, based on their role.

## Key Concepts

| Concept | Description |
|---------|-------------|
| `Cortex Analyst` | Sub-agents use Cortex Analyst to convert natural language to SQL |
| `Row Access Policies` | Filter table rows based on `IS_ROLE_IN_SESSION()` |
| `Multi-Agent Routing` | Orchestrator routes questions to specialized sub-agents |
| `EXECUTE AS CALLER` | Orchestrator procedures run as the logged-in user |

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
    │   SALES_AGENT → Cortex Analyst (sales_model.yaml)
    │       │
    │       ▼
    │   Row Access Policy filters by region
    │
    ├── CALL_FINANCE_AGENT (EXECUTE AS CALLER)
    │       ▼
    │   FINANCE_AGENT → Cortex Analyst (finance_model.yaml)
    │       │
    │       ▼
    │   Row Access Policy filters by department
    │
    └── CALL_HR_AGENT (EXECUTE AS CALLER)
            ▼
        HR_AGENT → Cortex Analyst (hr_model.yaml)
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
- Stage for semantic models
- Sub-agents (Sales, Finance, HR) using Cortex Analyst
- Orchestrator agent

```sql
-- Run in Snowsight as ACCOUNTADMIN
-- Execute 01_setup.sql
```

### Step 2: Upload Semantic Model Files
After running the SQL setup, upload the YAML files to the stage:

**Option A: Using Snowsight UI**
1. Navigate to: Data → Databases → MULTI_AGENT_RBAC_DEMO → AGENTS → Stages → SEMANTIC_MODELS
2. Click `+ Files` and upload all three YAML files from the `semantic_models/` folder:
   - `sales_model.yaml`
   - `finance_model.yaml`
   - `hr_model.yaml`

**Option B: Using Snowflake CLI**
```bash
snow stage copy semantic_models/sales_model.yaml @MULTI_AGENT_RBAC_DEMO.AGENTS.SEMANTIC_MODELS/
snow stage copy semantic_models/finance_model.yaml @MULTI_AGENT_RBAC_DEMO.AGENTS.SEMANTIC_MODELS/
snow stage copy semantic_models/hr_model.yaml @MULTI_AGENT_RBAC_DEMO.AGENTS.SEMANTIC_MODELS/
```

**Option C: Using SQL PUT command**
```sql
PUT file:///path/to/semantic_models/sales_model.yaml @MULTI_AGENT_RBAC_DEMO.AGENTS.SEMANTIC_MODELS AUTO_COMPRESS=FALSE;
PUT file:///path/to/semantic_models/finance_model.yaml @MULTI_AGENT_RBAC_DEMO.AGENTS.SEMANTIC_MODELS AUTO_COMPRESS=FALSE;
PUT file:///path/to/semantic_models/hr_model.yaml @MULTI_AGENT_RBAC_DEMO.AGENTS.SEMANTIC_MODELS AUTO_COMPRESS=FALSE;
```

### Step 3: Test the RBAC
Execute `02_test_rbac.sql` to verify the row access policies work correctly.

### Step 4: Test in Snowflake Intelligence
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

### 2. Cortex Analyst with Semantic Models
Each sub-agent uses Cortex Analyst to convert natural language to SQL. The semantic models define the schema:

```yaml
# sales_model.yaml
tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "sales_analyst"
      description: "Query sales opportunities data"
tool_resources:
  sales_analyst:
    semantic_model_file: "@MULTI_AGENT_RBAC_DEMO.AGENTS.SEMANTIC_MODELS/sales_model.yaml"
```

When Cortex Analyst generates and executes SQL, the Row Access Policies automatically filter results based on the user's role.

### 3. Sub-Agent Calls via REST API
The `_snowflake.send_snow_api_request()` function inherits the caller's session:

```python
# Inside CALL_SALES_AGENT procedure (EXECUTE AS CALLER)
API_ENDPOINT = "/api/v2/databases/DB/schemas/SCHEMA/agents/SALES_AGENT:run"

# This call runs AS THE LOGGED-IN USER
resp = _snowflake.send_snow_api_request("POST", API_ENDPOINT, {}, {}, payload, None, 60000)
```

## Files

| File/Folder | Description |
|-------------|-------------|
| `01_setup.sql` | Complete setup script - run once |
| `02_test_rbac.sql` | Test queries to verify RBAC works |
| `03_cleanup.sql` | Remove all demo objects |
| `semantic_models/` | Cortex Analyst YAML semantic model files |
| `semantic_models/sales_model.yaml` | Semantic model for SALES.OPPORTUNITIES |
| `semantic_models/finance_model.yaml` | Semantic model for FINANCE.BUDGET |
| `semantic_models/hr_model.yaml` | Semantic model for HR.EMPLOYEES |

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
- Test with direct SQL queries to verify RBAC works at the database level
- Check that the semantic model files were uploaded correctly

### "Unable to connect to data sources" error
Make sure you're selecting agents from `MULTI_AGENT_RBAC_DEMO.AGENTS` schema, not a different database.

### "Semantic model not found" error
Verify the YAML files were uploaded to the stage:
```sql
LIST @MULTI_AGENT_RBAC_DEMO.AGENTS.SEMANTIC_MODELS;
```

### Users can't access agents
Ensure grants are in place:
```sql
GRANT USAGE ON AGENT MULTI_AGENT_RBAC_DEMO.AGENTS.HR_AGENT TO ROLE <role_name>;
GRANT READ ON STAGE MULTI_AGENT_RBAC_DEMO.AGENTS.SEMANTIC_MODELS TO ROLE <role_name>;
```
