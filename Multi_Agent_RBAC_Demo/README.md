# Multi-Agent RBAC Demo

Demonstrates how Cortex Agents respect row-level security policies in Snowflake. An orchestrator agent routes queries to specialized sub-agents (Sales, Finance, HR), and each user sees only the data their role permits.

## Demo Questions to Ask

### Single-Agent Questions (Orchestrator routes to one agent)

**Sales Questions:**
- "What are my top sales opportunities?"
- "Show me deals in the pipeline"
- "What sales do I have access to?"
- "Who are my top performing sales reps?"

**Finance Questions:**
- "Show me the budget summary"
- "Which departments are over budget?"
- "What's our Q1 spending?"

**HR Questions:**
- "How many employees do I have access to?"
- "Show me the team roster"
- "Who was hired recently?"

### Multi-Agent Questions (Orchestrator routes to multiple agents)
- "Give me a complete business overview - sales pipeline, budget status, and team size"
- "What's happening across sales and finance?"
- "Show me everything I have access to"

### RBAC Demo Questions (Show different results per role)

| Question | SALES_WEST_ROLE sees | EXECUTIVE_ROLE sees |
|----------|---------------------|---------------------|
| "Show my sales" | Only WEST region deals | All regions |
| "Show the budget" | Only SALES dept budget | All departments |
| "Show employees" | Only WEST region staff | All employees |

### Demo Flow Script

1. **Login as EXECUTIVE_USER** → "Show me all sales opportunities"
   - Shows all 15 opportunities across all regions
   
2. **Login as SALES_REP_WEST** → "Show me all sales opportunities"  
   - Shows only 5 WEST region opportunities
   
3. **Ask orchestrator** → "What's my sales pipeline and current budget?"
   - Routes to both SALES_AGENT and FINANCE_AGENT
   - Each returns data filtered by the user's role

## Architecture

```
                          USER QUERY
                               │
                               ▼
                    ┌─────────────────────┐
                    │  ORCHESTRATOR_AGENT │
                    │   (Routes queries)  │
                    └──────────┬──────────┘
                               │
           ┌───────────────────┼───────────────────┐
           │                   │                   │
           ▼                   ▼                   ▼
    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
    │ SALES_AGENT │    │FINANCE_AGENT│    │  HR_AGENT   │
    │             │    │             │    │             │
    │ Opportunities│   │   Budget    │    │  Employees  │
    │ (by Region) │    │ (by Dept)   │    │(by Dept/Rgn)│
    └─────────────┘    └─────────────┘    └─────────────┘
           │                   │                   │
           ▼                   ▼                   ▼
    ┌─────────────────────────────────────────────────┐
    │            ROW ACCESS POLICIES                   │
    │  User sees only data their role permits          │
    └─────────────────────────────────────────────────┘
```

## Key Features

- **Caller's Rights**: Stored procedures use `EXECUTE AS CALLER` so row policies apply based on the calling user's role
- **Thread Tracking**: Each call includes a `threadId` for monitoring in Snowsight
- **DATA_AGENT_RUN**: Uses SQL function instead of REST API for nested agent calls

## Roles and Access

| Role | Sales Data | Finance Data | HR Data |
|------|------------|--------------|---------|
| SALES_WEST_ROLE | WEST region only | SALES dept only | WEST region only |
| SALES_EAST_ROLE | EAST region only | None | EAST region only |
| SALES_MANAGER_ROLE | All regions | SALES dept only | SALES dept only |
| FINANCE_ANALYST_ROLE | None | All except EXECUTIVE | None |
| HR_ROLE | None | HR dept only | All except EXECUTIVE |
| EXECUTIVE_ROLE | All | All | All |

## Setup

### 1. Run the setup script
```sql
-- Run sql/setup.sql in Snowsight or SnowSQL
```

### 2. Create Agents in Snowsight UI

Navigate to **AI & ML → Agents** and create:

#### SALES_AGENT
- **Database**: MULTI_AGENT_RBAC_DEMO
- **Schema**: AGENTS
- **About**: "Sales data agent - queries opportunities based on user access"
- **Semantic Model**: Add your sales semantic model YAML

#### FINANCE_AGENT
- **Database**: MULTI_AGENT_RBAC_DEMO
- **Schema**: AGENTS
- **About**: "Finance data agent - queries budget data based on user access"
- **Semantic Model**: Add your finance semantic model YAML

#### HR_AGENT
- **Database**: MULTI_AGENT_RBAC_DEMO
- **Schema**: AGENTS
- **About**: "HR data agent - queries employee data based on user access"
- **Semantic Model**: Add your HR semantic model YAML

#### ORCHESTRATOR_AGENT
- **Database**: MULTI_AGENT_RBAC_DEMO
- **Schema**: AGENTS
- **About**: "Main orchestrator agent - routes queries to specialized sub-agents"
- **Tools**: Add custom tools pointing to the stored procedures:
  - `CALL_SALES_AGENT(VARCHAR)` → TOOLS schema
  - `CALL_FINANCE_AGENT(VARCHAR)` → TOOLS schema
  - `CALL_HR_AGENT(VARCHAR)` → TOOLS schema

### 3. Run agent grants (Part 11 in setup.sql)

After creating agents, run the GRANT statements from Part 11.

## Testing

### Test as different roles:
```sql
-- As Sales West Rep
USE ROLE SALES_WEST_ROLE;
CALL MULTI_AGENT_RBAC_DEMO.TOOLS.CALL_SALES_AGENT('show my deals');
-- Returns only WEST region opportunities

-- As Executive
USE ROLE EXECUTIVE_ROLE;
CALL MULTI_AGENT_RBAC_DEMO.TOOLS.CALL_SALES_AGENT('show all deals');
-- Returns all opportunities
```

### Test orchestrator:
```sql
-- Query the orchestrator in Snowsight UI
-- "What are my top sales opportunities and current budget?"
-- Will route to both SALES_AGENT and FINANCE_AGENT
```

## Technical Notes

### Thread ID
The stored procedures include `threadId` in the DATA_AGENT_RUN payload for tracking:
- Use camelCase `threadId` (not `thread_id` with underscore)
- Track in Snowsight Monitoring tab

### JSON Payload Format
```json
{
  "threadId": "uuid-string",
  "messages": [{
    "role": "user",
    "content": [{"type": "text", "text": "query here"}]
  }]
}
```

### Error Handling
Procedures return error details if DATA_AGENT_RUN fails:
```
ERROR: <message> | SQLCODE: <code>
```

## Files

- `sql/setup.sql` - Complete setup script with all DDL, data, and grants
- `README.md` - This file
