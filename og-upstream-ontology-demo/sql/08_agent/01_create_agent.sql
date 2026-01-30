-- ============================================================================
-- O&G UPSTREAM ONTOLOGY - CORTEX AGENT SETUP
-- ============================================================================
-- Creates a Cortex Agent that orchestrates the 3 semantic models:
-- 1. Knowledge Graph Model - Concrete entity queries
-- 2. Ontology Model - Abstract/polymorphic queries
-- 3. Metadata & Governance Model - Schema introspection
-- ============================================================================

USE DATABASE OG_ONTOLOGY_DEMO;
USE SCHEMA ONTOLOGY_VIEWS;

-- ============================================================================
-- STEP 1: Create the Cortex Agent
-- ============================================================================
-- Note: Cortex Agents are created via Snowsight UI or API
-- This script provides the configuration to paste into the UI

-- Agent Name: OG_UPSTREAM_ONTOLOGY_AGENT
-- Database: OG_ONTOLOGY_DEMO
-- Schema: ONTOLOGY_VIEWS

-- ============================================================================
-- STEP 2: Alternative - Use COMPLETE function with semantic models directly
-- ============================================================================
-- If Cortex Agent is not available, you can use Cortex COMPLETE with 
-- the semantic models directly via the AI SQL function

-- Example: Query using Knowledge Graph model
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'claude-3-5-sonnet',
    'You are an O&G upstream analyst. Using the following context about our data model, answer the question.

Context:
- V_MONTHLY_WELL_RANKING has: WELL_NAME, OPERATOR, FIELD_NAME, OIL_VOLUME_BBL, GAS_VOLUME_MCF, OIL_RANK, GAS_RANK, PRODUCTION_MONTH
- V_WELL_EQUIPMENT has: WELL_NAME, EQUIPMENT_TYPE, EQUIPMENT_STATUS, MANUFACTURER, FAILURE_DATE, IS_FAILED
- V_SHUT_IN_WELLS has: WELL_NAME, WELL_TYPE, OPERATOR, FIELD_NAME, BASIN
- V_FIELD_PRODUCTION has: FIELD_NAME, BASIN, TOTAL_OIL_BBL, TOTAL_GAS_MCF, AVG_UPTIME_PCT, PRODUCTION_MONTH
- V_PRODUCTION_TREND has: WELL_NAME, OIL_VOLUME_BBL, PREV_MONTH_OIL, OIL_CHANGE_PCT

Question: Which 10 wells produced the most oil last month?

Generate a Snowflake SQL query to answer this question. Return ONLY the SQL query.'
) AS generated_sql;

-- ============================================================================
-- STEP 3: Create a Streamlit app for the Agent UI (optional)
-- ============================================================================
-- See the streamlit/ folder for a sample Streamlit app that provides
-- a chat interface to the Cortex Agent

-- ============================================================================
-- STEP 4: Test the semantic models directly
-- ============================================================================

-- Test Knowledge Graph Model - Top Oil Producers
SELECT * FROM OG_ONTOLOGY_DEMO.ONTOLOGY_VIEWS.V_MONTHLY_WELL_RANKING
WHERE PRODUCTION_MONTH = (SELECT MAX(PRODUCTION_MONTH) FROM OG_ONTOLOGY_DEMO.ONTOLOGY_VIEWS.V_MONTHLY_WELL_RANKING)
ORDER BY OIL_RANK
LIMIT 10;

-- Test Knowledge Graph Model - ESP Failures
SELECT WELL_NAME, EQUIPMENT_NAME, MANUFACTURER, FAILURE_DATE
FROM OG_ONTOLOGY_DEMO.ONTOLOGY_VIEWS.V_WELL_EQUIPMENT
WHERE EQUIPMENT_TYPE = 'ESP' AND IS_FAILED = TRUE;

-- Test Ontology Model - All Assets
SELECT ID, SUBTYPE, NAME, ASSET_CODE
FROM OG_ONTOLOGY_DEMO.ONTOLOGY_VIEWS.VW_ONT_ASSET
ORDER BY SUBTYPE, NAME;

-- Test Ontology Model - Relationships
SELECT REL_NAME, SRC_CLASS, SRC_NAME, DST_CLASS, DST_NAME
FROM OG_ONTOLOGY_DEMO.ONTOLOGY_VIEWS.REL_RESOLVED
LIMIT 20;

-- Test Metadata Model - Entity Types
SELECT ENTITY_NAME, ENTITY_DESCRIPTION, IS_ABSTRACT
FROM OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_ENTITY
WHERE IS_ACTIVE = TRUE
ORDER BY ENTITY_NAME;

-- Test Metadata Model - Relationship Definitions
SELECT 
    r.RELATION_NAME,
    se.ENTITY_NAME AS SOURCE_ENTITY,
    te.ENTITY_NAME AS TARGET_ENTITY,
    r.CARDINALITY
FROM OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_RELATION_DEF r
JOIN OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_ENTITY se ON r.SOURCE_ENTITY_ID = se.ENTITY_ID
JOIN OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_ENTITY te ON r.TARGET_ENTITY_ID = te.ENTITY_ID
WHERE r.IS_ACTIVE = TRUE;

-- ============================================================================
-- AGENT CONFIGURATION (for Snowsight UI)
-- ============================================================================
-- Copy the contents of agent/cortex_agent_config.json to create the agent
-- in Snowsight under AI & ML > Cortex Agents

/*
Agent Configuration Summary:
- Name: OG_UPSTREAM_ONTOLOGY_AGENT
- Tools:
  1. query_og_knowledge_graph - @OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.SEMANTIC_MODELS/og_knowledge_graph_model.yaml
  2. query_og_ontology - @OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.SEMANTIC_MODELS/og_ontology_model.yaml  
  3. query_og_metadata - @OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.SEMANTIC_MODELS/og_metadata_governance_model.yaml

Sample Questions:
- "Which 10 wells produced the most oil last month?"
- "What was on-stream efficiency by field last quarter?"
- "Which wells have had ESP failures in the last 90 days?"
- "What assets are in the Permian Basin?"
- "What entity types exist in the ontology?"
*/
