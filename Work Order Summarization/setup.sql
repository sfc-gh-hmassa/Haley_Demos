-- ============================================================================
-- ENTERPRISE WORK ORDER MANAGEMENT SYSTEM - COMPLETE SETUP
-- ============================================================================
-- This script sets up everything needed for the Cortex AI Enterprise Demo
-- Follow the steps in order for the complete workflow

-- ============================================================================
-- 1. DATABASE AND SCHEMA SETUP
-- ============================================================================

-- Create database (if not exists to avoid destroying existing data)
CREATE DATABASE IF NOT EXISTS DEMODB;
USE DATABASE DEMODB;

-- Create schema for work order management
CREATE SCHEMA IF NOT EXISTS WORK_ORDER_MANAGEMENT;
USE SCHEMA WORK_ORDER_MANAGEMENT;

-- ============================================================================
-- 2. MAIN TABLES
-- ============================================================================

-- Enterprise work orders table with comprehensive business metrics
CREATE OR REPLACE TABLE ENTERPRISE_WORK_ORDERS (
    WORK_ORDER_ID VARCHAR(50) PRIMARY KEY,
    EQUIPMENT_TYPE VARCHAR(100),
    FACILITY VARCHAR(100),
    STATUS VARCHAR(50),
    PRIORITY VARCHAR(20),
    URGENCY VARCHAR(20),
    TOTAL_COST DECIMAL(12,2),
    LABOR_COST DECIMAL(12,2),
    PARTS_COST DECIMAL(12,2),
    CONTRACTOR_COST DECIMAL(12,2),
    LABOR_HOURS DECIMAL(8,1),
    BUSINESS_IMPACT_SCORE INTEGER,
    SAFETY_RISK_LEVEL VARCHAR(20),
    ESTIMATED_DOWNTIME_HOURS DECIMAL(8,1),
    FAILURE_MODE VARCHAR(100),
    COMPLIANCE_REQUIRED BOOLEAN,
    SPECIALIZED_SKILLS_REQUIRED BOOLEAN,
    CREATED_DATE DATE,
    SCHEDULED_DATE DATE,
    WORK_ORDER_NOTES TEXT
);

-- Work order summaries table (simplified structure)
CREATE OR REPLACE TABLE WORK_ORDER_SUMMARIES (
    WORK_ORDER_ID VARCHAR(50) PRIMARY KEY,
    SUMMARY TEXT,
    CREATED_TIMESTAMP TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    
    -- Foreign key relationship
    FOREIGN KEY (WORK_ORDER_ID) REFERENCES ENTERPRISE_WORK_ORDERS(WORK_ORDER_ID)
);

-- ============================================================================
-- 3. STAGE FOR DATA AND SEMANTIC FILES
-- ============================================================================

CREATE STAGE IF NOT EXISTS ENTERPRISE_DATA_STAGE
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage for loading enterprise work order CSV data and semantic YAML files';

-- ============================================================================
-- 4. STORED PROCEDURE FOR CREATING SUMMARIES
-- ============================================================================
-- This procedure will be used as a tool in the Cortex Agent

CREATE OR REPLACE PROCEDURE CREATE_ENTERPRISE_SUMMARY_IF_MISSING(WORK_ORDER_ID STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  v_summary STRING;
  v_notes STRING;
  v_response VARIANT;
BEGIN
  -- Check if summary exists
  SELECT SUMMARY INTO :v_summary
  FROM WORK_ORDER_SUMMARIES
  WHERE WORK_ORDER_ID = :WORK_ORDER_ID;

  IF (v_summary IS NOT NULL) THEN
    RETURN v_summary;
  END IF;

  -- Get the notes
  SELECT WORK_ORDER_NOTES INTO :v_notes
  FROM ENTERPRISE_WORK_ORDERS
  WHERE WORK_ORDER_ID = :WORK_ORDER_ID;

  IF (v_notes IS NULL) THEN
    RETURN 'No work order found';
  END IF;

  -- Generate summary using conversation format
  SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'claude-3-5-sonnet',
    ARRAY_CONSTRUCT(
      OBJECT_CONSTRUCT('role', 'user', 'content', 'Summarize these technician notes: ' || :v_notes)
    ),
    OBJECT_CONSTRUCT('max_tokens', 256)
  ) INTO :v_response;

  -- Extract just the message content from the response
  SELECT :v_response:choices[0]:messages::STRING INTO :v_summary;

  -- Insert summary
  INSERT INTO WORK_ORDER_SUMMARIES (WORK_ORDER_ID, SUMMARY, CREATED_TIMESTAMP)
  SELECT :WORK_ORDER_ID, :v_summary, CURRENT_TIMESTAMP()
  WHERE NOT EXISTS (
    SELECT 1 FROM WORK_ORDER_SUMMARIES WHERE WORK_ORDER_ID = :WORK_ORDER_ID
  );

  RETURN v_summary;
END;
$$;

-- ============================================================================
-- 5. DATA LOADING INSTRUCTIONS
-- ============================================================================

SELECT 'SETUP COMPLETE! Follow these steps:' as MESSAGE,
       '1. Load CSV data using the commands below' as STEP_1,
       '2. Upload YAML file to stage' as STEP_2,
       '3. Create semantic view from YAML' as STEP_3,
       '4. Create Cortex Analyst in UI' as STEP_4,
       '5. Create Cortex Agent with tools' as STEP_5;

-- ============================================================================
-- STEP 1: LOAD THE CSV DATA
-- ============================================================================
-- Upload the CSV file to the stage first, then load the data:

/*
-- Upload CSV file from your local data folder:
PUT file://data/enterprise_work_orders.csv @ENTERPRISE_DATA_STAGE/;

-- Load the data into the table:
COPY INTO ENTERPRISE_WORK_ORDERS 
FROM @ENTERPRISE_DATA_STAGE/enterprise_work_orders.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- Verify data loaded successfully:
SELECT COUNT(*) as TOTAL_WORK_ORDERS FROM ENTERPRISE_WORK_ORDERS;
SELECT * FROM ENTERPRISE_WORK_ORDERS LIMIT 5;
*/

-- ============================================================================
-- STEP 2: UPLOAD SEMANTIC YAML FILE
-- ============================================================================
-- Upload the semantic model YAML file to the stage:

/*
PUT file://semantic/enterprise_work_orders_analyst.yaml @ENTERPRISE_DATA_STAGE/semantic/;
*/

-- ============================================================================
-- STEP 3: CREATE SEMANTIC VIEW FROM YAML
-- ============================================================================
-- Create the semantic view with verified queries for Cortex Analyst:

/*
CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
    'ENTERPRISE_WORK_ORDER_ANALYST',
    '@ENTERPRISE_DATA_STAGE/semantic/enterprise_work_orders_analyst.yaml'
);

-- Verify the semantic view was created:
SHOW SEMANTIC VIEWS;
DESCRIBE SEMANTIC VIEW ENTERPRISE_WORK_ORDER_ANALYST;
*/

-- ============================================================================
-- STEP 4: CREATE CORTEX ANALYST (IN SNOWSIGHT UI)
-- ============================================================================
-- 1. Open Snowsight
-- 2. Go to AI & ML > Cortex Analyst
-- 3. Click "Create Analyst"
-- 4. Select the ENTERPRISE_WORK_ORDER_ANALYST semantic view
-- 5. Name it "Enterprise Work Order Analyst"
-- 6. Save and test with questions like:
--    - "Show me business information for high-cost work orders"
--    - "What work orders have summaries?"

-- ============================================================================
-- STEP 5: CREATE CORTEX AGENT (IN SNOWSIGHT UI)
-- ============================================================================
-- 1. Go to AI & ML > Cortex Agents
-- 2. Click "Create Agent"
-- 3. Name: "Enterprise Work Order Agent"
-- 4. Add these TWO TOOLS:
--    a) Cortex Analyst: Select "Enterprise Work Order Analyst"
--    b) SQL Tool: Select procedure "CREATE_ENTERPRISE_SUMMARY_IF_MISSING"
-- 5. Add Custom Instructions (see below)
-- 6. Test the complete workflow

-- ============================================================================
-- CUSTOM INSTRUCTIONS FOR CORTEX AGENT ORCHESTRATION
-- ============================================================================
/*
Copy these instructions into the Custom Instructions field:

You are an enterprise work order management assistant. Follow this workflow:

1. ALWAYS start by using the Cortex Analyst to answer user questions about work orders.

2. If a user asks for a work order summary that doesn't exist:
   - First, inform them the summary doesn't exist
   - Use the CREATE_ENTERPRISE_SUMMARY_IF_MISSING tool to generate it
   - Then use Cortex Analyst again to retrieve the newly created summary

3. For general work order questions (costs, facilities, equipment, etc.), use Cortex Analyst directly.

4. Always prioritize using existing data first, then create summaries only when specifically requested or when they don't exist.

5. Provide business-focused responses that highlight costs, priorities, and strategic implications.
*/ 