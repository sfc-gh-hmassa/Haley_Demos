/*
================================================================================
MULTI-AGENT RBAC DEMO - TEST SCRIPT
================================================================================
Run these queries to verify the RBAC is working correctly.
These tests use direct procedure calls to show raw data without agent interpretation.
================================================================================
*/

USE ROLE ACCOUNTADMIN;
USE DATABASE MULTI_AGENT_RBAC_DEMO;

-- ============================================================================
-- TEST 1: Verify Row Access Policies are Attached
-- ============================================================================

SELECT 'Verifying Row Access Policies...' as TEST;

SELECT 
    policy_name,
    ref_entity_name as table_name,
    ref_schema_name as schema_name
FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
    ref_entity_name => 'MULTI_AGENT_RBAC_DEMO.SALES.OPPORTUNITIES',
    ref_entity_domain => 'TABLE'
))
UNION ALL
SELECT 
    policy_name,
    ref_entity_name,
    ref_schema_name
FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
    ref_entity_name => 'MULTI_AGENT_RBAC_DEMO.FINANCE.BUDGET',
    ref_entity_domain => 'TABLE'
))
UNION ALL
SELECT 
    policy_name,
    ref_entity_name,
    ref_schema_name
FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
    ref_entity_name => 'MULTI_AGENT_RBAC_DEMO.HR.EMPLOYEES',
    ref_entity_domain => 'TABLE'
));

-- ============================================================================
-- TEST 2: Verify Agents Exist
-- ============================================================================

SELECT 'Verifying Agents...' as TEST;

SHOW AGENTS IN SCHEMA MULTI_AGENT_RBAC_DEMO.AGENTS;

-- ============================================================================
-- TEST 3: Test Query Procedures (as ACCOUNTADMIN - sees all data)
-- ============================================================================

SELECT 'Testing Query Procedures as ACCOUNTADMIN...' as TEST;

-- Sales: Should see all 15 deals across 3 regions
CALL MULTI_AGENT_RBAC_DEMO.TOOLS.QUERY_SALES_DATA('summary');

-- Finance: Should see all 14 budget rows across 4 departments
CALL MULTI_AGENT_RBAC_DEMO.TOOLS.QUERY_FINANCE_DATA('summary');

-- HR: Should see all 16 employees including executives
CALL MULTI_AGENT_RBAC_DEMO.TOOLS.QUERY_HR_DATA('all');

-- ============================================================================
-- TEST 4: Test Sub-Agent Calls (as ACCOUNTADMIN)
-- ============================================================================

SELECT 'Testing Sub-Agent Calls...' as TEST;

CALL MULTI_AGENT_RBAC_DEMO.TOOLS.CALL_SALES_AGENT('Show me sales by region');
CALL MULTI_AGENT_RBAC_DEMO.TOOLS.CALL_FINANCE_AGENT('What is budget by department?');
CALL MULTI_AGENT_RBAC_DEMO.TOOLS.CALL_HR_AGENT('List all employees with salaries');

-- ============================================================================
-- TEST 5: Expected Results Summary
-- ============================================================================

SELECT 'Expected Results by Role:' as TEST;

-- What SALES_WEST_ROLE should see (WEST region only)
SELECT 'SALES_WEST_ROLE - Sales' as role_test, COUNT(*) as expected_rows, 
       LISTAGG(DISTINCT region, ', ') as regions
FROM MULTI_AGENT_RBAC_DEMO.SALES.OPPORTUNITIES WHERE region = 'WEST';

-- What SALES_EAST_ROLE should see (EAST region only)
SELECT 'SALES_EAST_ROLE - Sales' as role_test, COUNT(*) as expected_rows,
       LISTAGG(DISTINCT region, ', ') as regions
FROM MULTI_AGENT_RBAC_DEMO.SALES.OPPORTUNITIES WHERE region = 'EAST';

-- What FINANCE_ANALYST_ROLE should see (all except EXECUTIVE dept)
SELECT 'FINANCE_ANALYST_ROLE - Finance' as role_test, COUNT(*) as expected_rows,
       LISTAGG(DISTINCT department, ', ') as departments
FROM MULTI_AGENT_RBAC_DEMO.FINANCE.BUDGET WHERE department != 'EXECUTIVE';

-- What HR_ROLE should see (all except EXECUTIVE dept)
SELECT 'HR_ROLE - Employees' as role_test, COUNT(*) as expected_rows,
       LISTAGG(DISTINCT department, ', ') as departments
FROM MULTI_AGENT_RBAC_DEMO.HR.EMPLOYEES WHERE department != 'EXECUTIVE';

-- What EXECUTIVE_ROLE should see (everything)
SELECT 'EXECUTIVE_ROLE - All Data' as role_test,
       (SELECT COUNT(*) FROM MULTI_AGENT_RBAC_DEMO.SALES.OPPORTUNITIES) as sales_rows,
       (SELECT COUNT(*) FROM MULTI_AGENT_RBAC_DEMO.FINANCE.BUDGET) as finance_rows,
       (SELECT COUNT(*) FROM MULTI_AGENT_RBAC_DEMO.HR.EMPLOYEES) as hr_rows;

-- ============================================================================
-- INTERACTIVE TESTING
-- ============================================================================
/*
To test RBAC with different users, log into Snowflake with these credentials:

| Username              | Password           | Expected Access                    |
|-----------------------|--------------------|------------------------------------|
| SALES_REP_WEST        | DemoPassword123!   | WEST region sales only             |
| SALES_REP_EAST        | DemoPassword123!   | EAST region sales only             |
| SALES_MANAGER_USER    | DemoPassword123!   | All sales + SALES budget/HR        |
| FINANCE_ANALYST_USER  | DemoPassword123!   | All budgets except EXECUTIVE       |
| HR_REP_USER           | DemoPassword123!   | All employees except EXECUTIVE     |
| EXECUTIVE_USER        | DemoPassword123!   | EVERYTHING                         |

Then in Snowflake Intelligence, select agents from:
  Database: MULTI_AGENT_RBAC_DEMO
  Schema: AGENTS
  
And ask questions like:
  - "List all sales deals"
  - "Show budget by department"  
  - "List all employees with salaries"
*/
