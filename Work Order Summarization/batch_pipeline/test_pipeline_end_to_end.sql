-- ============================================================================
-- END-TO-END PIPELINE TEST SCRIPT
-- ============================================================================
-- This script tests the complete streaming pipeline by:
-- 1. Setting up and enabling the stream and task
-- 2. Adding test work orders (both high and low cost)
-- 3. Triggering the pipeline
-- 4. Validating that only high-cost work orders get summaries
-- ============================================================================

USE DATABASE DEMODB;
USE SCHEMA WORK_ORDER_MANAGEMENT;

-- ============================================================================
-- STEP 1: PIPELINE SETUP AND ACTIVATION
-- ============================================================================

SELECT 'STEP 1: Setting up pipeline components' AS TEST_STEP;

-- Resume the task (stream should already exist from streaming_pipeline_improved.sql)
ALTER TASK PROCESS_HIGH_COST_WORK_ORDERS_TASK RESUME;

-- Verify stream and task status
SHOW STREAMS LIKE 'ENTERPRISE_WORK_ORDERS_STREAM';

SHOW TASKS LIKE 'PROCESS_HIGH_COST_WORK_ORDERS_TASK';

-- ============================================================================
-- STEP 2: BASELINE - COUNT EXISTING SUMMARIES
-- ============================================================================

SELECT 'STEP 2: Recording baseline summary count' AS TEST_STEP;

SELECT 
    'Before Test:' AS PHASE,
    COUNT(*) AS EXISTING_SUMMARIES,
    CURRENT_TIMESTAMP() AS RECORDED_AT
FROM WORK_ORDER_SUMMARIES;

-- ============================================================================
-- STEP 3: INSERT TEST DATA (MIX OF HIGH AND LOW COST)
-- ============================================================================

SELECT 'STEP 3: Adding test work orders' AS TEST_STEP;

-- Insert 3 HIGH-COST work orders (should get summaries)
INSERT INTO ENTERPRISE_WORK_ORDERS (
    WORK_ORDER_ID, EQUIPMENT_TYPE, FACILITY, STATUS, PRIORITY, URGENCY,
    TOTAL_COST, LABOR_COST, PARTS_COST, LABOR_HOURS,
    CREATED_DATE, SCHEDULED_DATE, WORK_ORDER_NOTES,
    FAILURE_MODE, ESTIMATED_DOWNTIME_HOURS, BUSINESS_IMPACT_SCORE,
    SAFETY_RISK_LEVEL, COMPLIANCE_REQUIRED, SPECIALIZED_SKILLS_REQUIRED, CONTRACTOR_COST
) VALUES 
-- HIGH COST #1 - $75,000 (above $25K threshold)
('TEST-HIGH-001', 'Critical Production Line', 'Manufacturing Plant A', 'Open', 'Critical', 'High',
 75000.00, 25000.00, 45000.00, 120.0, CURRENT_DATE(), CURRENT_DATE() + 7,
 'CRITICAL: Main production line conveyor system complete failure. Requires immediate specialized repair crew and emergency parts procurement. Production halted affecting 3 shifts.',
 'Mechanical Failure', 48.0, 9, 'High', TRUE, TRUE, 5000.00),

-- HIGH COST #2 - $50,000 (above $25K threshold)  
('TEST-HIGH-002', 'HVAC System', 'Warehouse B', 'In Progress', 'High', 'Medium',
 50000.00, 20000.00, 25000.00, 80.0, CURRENT_DATE(), CURRENT_DATE() + 5,
 'Major HVAC system overhaul required. Temperature control failure affecting product storage. Multiple components need replacement including main compressor unit.',
 'System Failure', 24.0, 7, 'Medium', TRUE, FALSE, 5000.00),

-- HIGH COST #3 - $30,000 (above $25K threshold)
('TEST-HIGH-003', 'Robotic Assembly', 'Factory C', 'Open', 'High', 'High', 
 30000.00, 15000.00, 12000.00, 60.0, CURRENT_DATE(), CURRENT_DATE() + 3,
 'Robotic assembly arm calibration failure causing quality defects. Requires precision recalibration and sensor replacement. Critical for quality standards.',
 'Calibration Error', 16.0, 8, 'High', TRUE, TRUE, 3000.00),

-- LOW COST #1 - $5,000 (below $25K threshold - should NOT get summary)
('TEST-LOW-001', 'Office Equipment', 'Admin Building', 'Open', 'Low', 'Low',
 5000.00, 2000.00, 2500.00, 8.0, CURRENT_DATE(), CURRENT_DATE() + 14,
 'Routine office equipment maintenance. Replace printer cartridges and clean workstations. Standard maintenance procedure.',
 'Routine Maintenance', 2.0, 2, 'Low', FALSE, FALSE, 500.00),

-- LOW COST #2 - $15,000 (below $25K threshold - should NOT get summary)
('TEST-LOW-002', 'Lighting System', 'Parking Lot', 'Pending Parts', 'Medium', 'Low',
 15000.00, 8000.00, 6000.00, 24.0, CURRENT_DATE(), CURRENT_DATE() + 10,
 'Parking lot lighting upgrade. Replace old fixtures with LED units. Improves security and energy efficiency.',
 'Upgrade', 4.0, 3, 'Low', FALSE, FALSE, 1000.00);

-- Verify test data insertion
SELECT 'Test Data Inserted:' AS PHASE, COUNT(*) AS NEW_WORK_ORDERS
FROM ENTERPRISE_WORK_ORDERS 
WHERE WORK_ORDER_ID LIKE 'TEST-%';

-- Show the test data breakdown
SELECT 
    'Cost Breakdown:' AS ANALYSIS,
    CASE 
        WHEN TOTAL_COST >= 25000 THEN 'HIGH COST (should get summary)'
        ELSE 'LOW COST (should NOT get summary)'
    END AS COST_CATEGORY,
    COUNT(*) AS COUNT,
    MIN(TOTAL_COST) AS MIN_COST,
    MAX(TOTAL_COST) AS MAX_COST
FROM ENTERPRISE_WORK_ORDERS 
WHERE WORK_ORDER_ID LIKE 'TEST-%'
GROUP BY CASE WHEN TOTAL_COST >= 25000 THEN 'HIGH COST (should get summary)' ELSE 'LOW COST (should NOT get summary)' END;

-- ============================================================================
-- STEP 4: TRIGGER PIPELINE AND WAIT FOR PROCESSING
-- ============================================================================

SELECT 'STEP 4: Triggering pipeline processing' AS TEST_STEP;

-- Check if stream has data
SELECT 
    'Stream Data Check:' AS CHECK_TYPE,
    COUNT(*) AS RECORDS_IN_STREAM,
    COUNT(CASE WHEN METADATA$ACTION = 'INSERT' THEN 1 END) AS INSERT_RECORDS
FROM ENTERPRISE_WORK_ORDERS_STREAM;

-- Manually trigger the task to process immediately
EXECUTE TASK PROCESS_HIGH_COST_WORK_ORDERS_TASK;

-- Wait a moment for processing (in real scenario, you might add a delay)
SELECT 'Processing triggered - checking results...' AS STATUS;

-- ============================================================================
-- STEP 5: VALIDATION AND RESULTS
-- ============================================================================

SELECT 'STEP 5: Validating pipeline results' AS TEST_STEP;

-- Check what summaries were created
SELECT 
    'New Summaries Created:' AS RESULT_TYPE,
    COUNT(*) AS SUMMARY_COUNT
FROM WORK_ORDER_SUMMARIES 
WHERE WORK_ORDER_ID LIKE 'TEST-%';

-- Detailed breakdown of which work orders got summaries
SELECT 
    'Summary Analysis:' AS ANALYSIS,
    w.WORK_ORDER_ID,
    w.TOTAL_COST,
    CASE 
        WHEN w.TOTAL_COST >= 25000 THEN 'HIGH (should have summary)'
        ELSE 'LOW (should NOT have summary)'
    END AS EXPECTED_CATEGORY,
    CASE 
        WHEN s.WORK_ORDER_ID IS NOT NULL THEN 'HAS SUMMARY' 
        ELSE 'NO SUMMARY' 
    END AS ACTUAL_RESULT,
    CASE 
        WHEN w.TOTAL_COST >= 25000 AND s.WORK_ORDER_ID IS NOT NULL THEN '✅ CORRECT'
        WHEN w.TOTAL_COST < 25000 AND s.WORK_ORDER_ID IS NULL THEN '✅ CORRECT'
        ELSE '❌ ERROR'
    END AS VALIDATION_STATUS
FROM ENTERPRISE_WORK_ORDERS w
LEFT JOIN WORK_ORDER_SUMMARIES s ON w.WORK_ORDER_ID = s.WORK_ORDER_ID
WHERE w.WORK_ORDER_ID LIKE 'TEST-%'
ORDER BY w.TOTAL_COST DESC;

-- Summary validation counts
SELECT 
    'Validation Summary:' AS FINAL_CHECK,
    COUNT(CASE WHEN w.TOTAL_COST >= 25000 AND s.WORK_ORDER_ID IS NOT NULL THEN 1 END) AS HIGH_COST_WITH_SUMMARY_CORRECT,
    COUNT(CASE WHEN w.TOTAL_COST < 25000 AND s.WORK_ORDER_ID IS NULL THEN 1 END) AS LOW_COST_WITHOUT_SUMMARY_CORRECT,
    COUNT(CASE WHEN w.TOTAL_COST >= 25000 AND s.WORK_ORDER_ID IS NULL THEN 1 END) AS HIGH_COST_MISSING_SUMMARY_ERROR,
    COUNT(CASE WHEN w.TOTAL_COST < 25000 AND s.WORK_ORDER_ID IS NOT NULL THEN 1 END) AS LOW_COST_WITH_SUMMARY_ERROR
FROM ENTERPRISE_WORK_ORDERS w
LEFT JOIN WORK_ORDER_SUMMARIES s ON w.WORK_ORDER_ID = s.WORK_ORDER_ID
WHERE w.WORK_ORDER_ID LIKE 'TEST-%';

-- Show the actual summaries created
SELECT 
    'Generated Summaries:' AS CONTENT_CHECK,
    s.WORK_ORDER_ID,
    w.TOTAL_COST,
    LEFT(s.SUMMARY, 100) || '...' AS SUMMARY_PREVIEW,
    s.CREATED_TIMESTAMP
FROM WORK_ORDER_SUMMARIES s
JOIN ENTERPRISE_WORK_ORDERS w ON s.WORK_ORDER_ID = w.WORK_ORDER_ID
WHERE s.WORK_ORDER_ID LIKE 'TEST-%'
ORDER BY w.TOTAL_COST DESC;

-- ============================================================================
-- STEP 6: CLEANUP (OPTIONAL)
-- ============================================================================

SELECT 'STEP 6: Test cleanup options' AS TEST_STEP;

-- Uncomment these lines to clean up test data after validation:
/*
DELETE FROM WORK_ORDER_SUMMARIES WHERE WORK_ORDER_ID LIKE 'TEST-%';
DELETE FROM ENTERPRISE_WORK_ORDERS WHERE WORK_ORDER_ID LIKE 'TEST-%';
SELECT 'Test data cleaned up' AS CLEANUP_STATUS;
*/

-- Or keep test data for further analysis:
SELECT 'Test data preserved for analysis - run cleanup manually if needed' AS CLEANUP_STATUS;

-- ============================================================================
-- TEST COMPLETE
-- ============================================================================

SELECT 
    'END-TO-END PIPELINE TEST COMPLETE' AS FINAL_STATUS,
    CURRENT_TIMESTAMP() AS COMPLETED_AT,
    'Check validation results above to confirm pipeline is working correctly' AS NEXT_STEPS; 