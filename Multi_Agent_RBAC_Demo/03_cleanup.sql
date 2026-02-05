/*
================================================================================
MULTI-AGENT RBAC DEMO - CLEANUP SCRIPT
================================================================================
Run this to remove all demo objects from your account.
================================================================================
*/

USE ROLE ACCOUNTADMIN;

-- Drop database (includes all schemas, tables, procedures, agents)
DROP DATABASE IF EXISTS MULTI_AGENT_RBAC_DEMO;

-- Drop test users
DROP USER IF EXISTS SALES_REP_WEST;
DROP USER IF EXISTS SALES_REP_EAST;
DROP USER IF EXISTS SALES_MANAGER_USER;
DROP USER IF EXISTS FINANCE_ANALYST_USER;
DROP USER IF EXISTS HR_REP_USER;
DROP USER IF EXISTS EXECUTIVE_USER;

-- Drop roles
DROP ROLE IF EXISTS SALES_WEST_ROLE;
DROP ROLE IF EXISTS SALES_EAST_ROLE;
DROP ROLE IF EXISTS SALES_MANAGER_ROLE;
DROP ROLE IF EXISTS FINANCE_ANALYST_ROLE;
DROP ROLE IF EXISTS HR_ROLE;
DROP ROLE IF EXISTS EXECUTIVE_ROLE;

SELECT 'Cleanup complete!' as STATUS;
