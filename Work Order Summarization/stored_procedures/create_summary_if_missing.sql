-- ============================================================================
-- Enterprise Work Order Summary Generation Procedure - TESTED AND WORKING
-- ============================================================================
-- This stored procedure creates AI-generated summaries for work orders
-- using Snowflake Cortex Complete with conversation format.
-- 
-- TESTED: Successfully created summaries in Snowflake environment
-- USAGE: CALL CREATE_ENTERPRISE_SUMMARY_IF_MISSING('WO-2024-001');
-- ============================================================================

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