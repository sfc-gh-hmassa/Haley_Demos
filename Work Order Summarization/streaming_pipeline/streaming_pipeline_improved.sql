-- ============================================================================
-- Enterprise Work Order Streaming Pipeline
-- ============================================================================
-- This script creates a real-time streaming pipeline that automatically
-- generates AI summaries for new high-cost work orders as they are inserted
-- into the ENTERPRISE_WORK_ORDERS table.
--
-- ARCHITECTURE:
-- 1. STREAM monitors ENTERPRISE_WORK_ORDERS for new inserts
-- 2. TASK processes high-cost work orders (>= $25,000) from the stream
-- 3. AI summaries are generated automatically using Cortex Complete
-- 4. Summaries are inserted into WORK_ORDER_SUMMARIES table
-- ============================================================================

-- Set up the environment
USE ROLE ACCOUNTADMIN;
USE DATABASE DEMODB;
USE SCHEMA WORK_ORDER_MANAGEMENT;

-- ============================================================================
-- BUSINESS CONFIGURATION: HIGH-VALUE WORK ORDER CRITERIA
-- ============================================================================
-- Define what constitutes a "high-value" work order requiring executive attention
-- 
-- CUSTOMIZE THESE VALUES FOR YOUR BUSINESS:

SET HIGH_VALUE_COST_THRESHOLD = 25000;  -- $25,000 minimum cost
-- Note: ACTIVE_STATUSES defined in stored procedure logic

-- BUSINESS RATIONALE:
-- - $25,000+ represents significant financial impact requiring executive review
-- - Only active work orders need immediate attention (not completed/cancelled)
-- - Avoid reprocessing work orders that already have summaries
-- 
-- EXAMPLES OF HIGH-VALUE SCENARIOS:
-- ✓ Emergency equipment repairs >$25K
-- ✓ Critical production line failures
-- ✓ Major facility maintenance projects
-- ✓ Specialized contractor requirements
-- ✗ Routine maintenance <$25K (handled by standard processes)
-- ✗ Completed work orders (no action needed)

SELECT 
    'BUSINESS CONFIGURATION LOADED' as STATUS,
    'High-value threshold: $' || $HIGH_VALUE_COST_THRESHOLD as COST_THRESHOLD,
    'Schedule: Weekly on Mondays at 9 AM EST' as SCHEDULE,
    'Active statuses: Open, In Progress, Pending Approval' as STATUSES;

-- ============================================================================
-- 1. CREATE STREAM TO MONITOR NEW WORK ORDERS
-- ============================================================================
-- Stream captures all changes to ENTERPRISE_WORK_ORDERS table

CREATE OR REPLACE STREAM ENTERPRISE_WORK_ORDERS_STREAM
ON TABLE ENTERPRISE_WORK_ORDERS
COMMENT = 'Stream to capture new work orders for automatic summarization';

-- ============================================================================
-- 2. CREATE STORED PROCEDURE FOR BATCH PROCESSING
-- ============================================================================
-- Procedure to process high-cost work orders from the stream

CREATE OR REPLACE PROCEDURE PROCESS_HIGH_COST_WORK_ORDERS()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    min_cost_threshold NUMBER DEFAULT $HIGH_VALUE_COST_THRESHOLD;  -- Use configured threshold
    result_message STRING;
BEGIN
    
    -- Process new high-cost work orders from stream
    INSERT INTO WORK_ORDER_SUMMARIES (WORK_ORDER_ID, SUMMARY)
    WITH new_high_cost_orders AS (
        -- Get new work orders from stream that meet HIGH-VALUE CRITERIA
        -- 
        -- BUSINESS LOGIC APPLIED HERE:
        -- 1. Only INSERT operations (new work orders)
        -- 2. Cost >= configured threshold (currently $25,000)
        -- 3. Active status only (Open, In Progress, Pending Approval)
        -- 4. No existing summary (avoid duplicates)
        SELECT 
            s.WORK_ORDER_ID,
            s.TOTAL_COST,
            s.EQUIPMENT_TYPE,
            s.FACILITY,
            s.URGENCY,
            s.WORK_ORDER_NOTES,
            s.LABOR_COST,
            s.PARTS_COST,
            s.BUSINESS_IMPACT_SCORE,
            s.SAFETY_RISK_LEVEL,
            s.STATUS
        FROM ENTERPRISE_WORK_ORDERS_STREAM s
        WHERE s.METADATA$ACTION = 'INSERT'  -- Only new inserts
          AND s.TOTAL_COST >= :min_cost_threshold  -- HIGH-VALUE THRESHOLD
          AND s.STATUS IN ('Open', 'In Progress', 'Pending Approval')  -- ACTIVE STATUSES ONLY
          -- Ensure we don't already have a summary
          AND NOT EXISTS (
              SELECT 1 FROM WORK_ORDER_SUMMARIES ws 
              WHERE ws.WORK_ORDER_ID = s.WORK_ORDER_ID
          )
    ),
    ai_summaries AS (
        -- Generate AI summaries for qualifying work orders
        SELECT 
            n.WORK_ORDER_ID,
            SNOWFLAKE.CORTEX.COMPLETE(
                'claude-3-5-sonnet',
                ARRAY_CONSTRUCT(
                    OBJECT_CONSTRUCT(
                        'role', 'system',
                        'content', 'You are an enterprise operations executive assistant. Generate a concise, executive-level summary of this high-cost work order. Focus on: 1) Total cost and main cost drivers, 2) Business impact and urgency, 3) Key operational risks, 4) Recommended executive actions. Keep it under 300 words and be specific about financial implications.'
                    ),
                    OBJECT_CONSTRUCT(
                        'role', 'user',
                        'content', 'EXECUTIVE SUMMARY NEEDED - High-Cost Work Order Alert:' ||
                                  '\n• Work Order ID: ' || n.WORK_ORDER_ID ||
                                  '\n• Total Cost: $' || n.TOTAL_COST ||
                                  '\n• Equipment: ' || n.EQUIPMENT_TYPE ||
                                  '\n• Facility: ' || n.FACILITY ||
                                  '\n• Status: ' || n.STATUS ||
                                  '\n• Urgency: ' || n.URGENCY ||
                                  '\n• Safety Risk: ' || n.SAFETY_RISK_LEVEL ||
                                  '\n• Business Impact Score: ' || n.BUSINESS_IMPACT_SCORE || '/10' ||
                                  '\n• Labor Cost: $' || n.LABOR_COST ||
                                  '\n• Parts Cost: $' || n.PARTS_COST ||
                                  '\n\nWork Order Details:\n' || n.WORK_ORDER_NOTES
                    )
                ),
                OBJECT_CONSTRUCT(
                    'max_tokens', 350,
                    'temperature', 0.1,
                    'guardrails', false
                )
            ) AS ai_summary
        FROM new_high_cost_orders n
    )
    SELECT 
        s.WORK_ORDER_ID,
        s.ai_summary
    FROM ai_summaries s
    WHERE s.ai_summary IS NOT NULL;
    
        -- Create result message
    result_message := 'Processed high-cost work orders from stream. Cost threshold: $' || min_cost_threshold;
    
    RETURN result_message;
    
END;
$$;

-- ============================================================================
-- 3. CREATE TASK FOR AUTOMATED PROCESSING
-- ============================================================================
-- Task runs every 5 minutes but ONLY when there are NEW HIGH-VALUE work orders
-- 
-- BUSINESS LOGIC: High-value work orders are defined as:
-- - TOTAL_COST >= $25,000 (configurable threshold)
-- - Status in ('Open', 'In Progress', 'Pending Approval') - active work orders only
-- - No existing summary (to avoid reprocessing)
--
-- The task will ONLY execute when the stream contains new records meeting these criteria

CREATE OR REPLACE TASK PROCESS_HIGH_COST_WORK_ORDERS_TASK
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = 'USING CRON 0 9 * * MON America/New_York'
    COMMENT = 'Automatically process high-cost work orders (>=$25K) for AI summarization - runs weekly on Mondays at 9 AM EST'
    WHEN (
        -- Only execute when stream has data
        -- The stored procedure will handle filtering for high-value work orders
        SYSTEM$STREAM_HAS_DATA('ENTERPRISE_WORK_ORDERS_STREAM')
    )
AS
    CALL PROCESS_HIGH_COST_WORK_ORDERS();

-- ============================================================================
-- 4. CREATE MONITORING VIEW
-- ============================================================================
-- View to monitor the streaming pipeline performance

CREATE OR REPLACE VIEW STREAMING_PIPELINE_MONITOR AS
SELECT 
    'STREAM_STATUS' AS METRIC_TYPE,
    CASE 
        WHEN SYSTEM$STREAM_HAS_DATA('ENTERPRISE_WORK_ORDERS_STREAM') 
        THEN 'HAS_DATA' 
        ELSE 'NO_DATA' 
    END AS STATUS,
    (SELECT COUNT(*) FROM ENTERPRISE_WORK_ORDERS_STREAM WHERE METADATA$ACTION = 'INSERT') AS PENDING_INSERTS,
    (SELECT COUNT(*) FROM ENTERPRISE_WORK_ORDERS_STREAM WHERE METADATA$ACTION = 'INSERT' AND TOTAL_COST >= 25000) AS PENDING_HIGH_COST,
    CURRENT_TIMESTAMP() AS CHECK_TIME

UNION ALL

SELECT 
    'SUMMARY_STATS' AS METRIC_TYPE,
    'PROCESSED' AS STATUS,
    (SELECT COUNT(*) FROM WORK_ORDER_SUMMARIES) AS PENDING_INSERTS,
    (SELECT COUNT(*) FROM WORK_ORDER_SUMMARIES WHERE CREATED_TIMESTAMP >= CURRENT_TIMESTAMP() - INTERVAL '1 HOUR') AS PENDING_HIGH_COST,
    CURRENT_TIMESTAMP() AS CHECK_TIME

UNION ALL

SELECT 
    'TASK_STATUS' AS METRIC_TYPE,
    (SELECT STATE FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY()) WHERE NAME = 'PROCESS_HIGH_COST_WORK_ORDERS_TASK' ORDER BY SCHEDULED_TIME DESC LIMIT 1) AS STATUS,
    (SELECT COUNT(*) FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY()) WHERE NAME = 'PROCESS_HIGH_COST_WORK_ORDERS_TASK' AND SCHEDULED_TIME >= CURRENT_TIMESTAMP() - INTERVAL '1 DAY') AS PENDING_INSERTS,
    (SELECT COUNT(*) FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY()) WHERE NAME = 'PROCESS_HIGH_COST_WORK_ORDERS_TASK' AND STATE = 'SUCCEEDED' AND SCHEDULED_TIME >= CURRENT_TIMESTAMP() - INTERVAL '1 DAY') AS PENDING_HIGH_COST,
    CURRENT_TIMESTAMP() AS CHECK_TIME;

-- ============================================================================
-- 5. CREATE TASK HISTORY VIEW
-- ============================================================================
-- View to see task execution history and performance

CREATE OR REPLACE VIEW TASK_EXECUTION_HISTORY AS
SELECT 
    NAME AS TASK_NAME,
    STATE,
    SCHEDULED_TIME,
    QUERY_START_TIME,
    COMPLETED_TIME,
    DATEDIFF('SECOND', QUERY_START_TIME, COMPLETED_TIME) AS EXECUTION_TIME_SECONDS,
    RETURN_VALUE,
    ERROR_CODE,
    ERROR_MESSAGE
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE NAME = 'PROCESS_HIGH_COST_WORK_ORDERS_TASK'
ORDER BY SCHEDULED_TIME DESC;

-- ============================================================================
-- 6. ENABLE THE STREAMING PIPELINE
-- ============================================================================

-- Start the task (it will run every 5 minutes when stream has data)
ALTER TASK PROCESS_HIGH_COST_WORK_ORDERS_TASK RESUME;

-- ============================================================================
-- 7. TESTING AND VALIDATION QUERIES
-- ============================================================================

-- Check if stream has data
SELECT 'Stream Status Check' AS TEST_TYPE, SYSTEM$STREAM_HAS_DATA('ENTERPRISE_WORK_ORDERS_STREAM') AS HAS_DATA;

-- View current stream contents
SELECT 'Current Stream Contents' AS TEST_TYPE, COUNT(*) AS RECORD_COUNT FROM ENTERPRISE_WORK_ORDERS_STREAM;

-- View pipeline monitoring
SELECT * FROM STREAMING_PIPELINE_MONITOR ORDER BY METRIC_TYPE;

-- View recent task executions
SELECT * FROM TASK_EXECUTION_HISTORY LIMIT 10;

-- ============================================================================
-- 8. MANUAL TESTING COMMANDS
-- ============================================================================

-- To test the pipeline, insert a high-cost work order:
/*
INSERT INTO ENTERPRISE_WORK_ORDERS (
    WORK_ORDER_ID, EQUIPMENT_TYPE, FACILITY, STATUS, PRIORITY, URGENCY,
    TOTAL_COST, LABOR_COST, PARTS_COST, LABOR_HOURS,
    CREATED_DATE, DUE_DATE, WORK_ORDER_NOTES,
    FAILURE_MODE, ESTIMATED_DOWNTIME_HOURS, BUSINESS_IMPACT_SCORE,
    SAFETY_RISK_LEVEL, COMPLIANCE_REQUIRED, SPECIALIZED_SKILLS_REQUIRED
) VALUES (
    'TEST-STREAM-001',
    'Critical Production Line',
    'Manufacturing Plant A',
    'Open',
    'Critical',
    'High',
    75000.00,
    25000.00,
    50000.00,
    120.0,
    CURRENT_DATE(),
    CURRENT_DATE() + 7,
    'URGENT: Critical production line failure requiring immediate attention. Main conveyor system has complete mechanical failure affecting entire production capacity. Estimated 48-hour downtime if not resolved quickly. Requires specialized technician and emergency parts procurement.',
    'Mechanical Failure',
    48.0,
    9,
    'High',
    TRUE,
    TRUE
);
*/

-- To manually trigger the task:
-- EXECUTE TASK PROCESS_HIGH_COST_WORK_ORDERS_TASK;

-- To manually call the procedure:
-- CALL PROCESS_HIGH_COST_WORK_ORDERS();

-- ============================================================================
-- PIPELINE SETUP COMPLETE
-- ============================================================================

SELECT 'Enterprise Streaming Pipeline Setup Complete!' as STATUS,
       'The pipeline will automatically process high-cost work orders (>= $25,000)' as DESCRIPTION,
       'Task runs every 5 minutes when new data is available' as SCHEDULE,
       'Monitor using STREAMING_PIPELINE_MONITOR and TASK_EXECUTION_HISTORY views' as MONITORING; 