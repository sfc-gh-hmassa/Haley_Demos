-- ============================================================================
-- AI_AGG IMPLEMENTATION - PYTHON STORED PROCEDURES
-- ============================================================================
-- Uses Snowflake's SPLIT_TEXT_RECURSIVE_CHARACTER for chunking
-- Python-based procedures with Snowpark
-- ============================================================================

USE DATABASE demodb;
use schema workorder_summary;

-- Summarize a workorder by ID
CREATE OR REPLACE PROCEDURE summarize_workorder_two(workorder_id VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
DECLARE
    result VARCHAR;
BEGIN
    -- Chunk, summarize each chunk, merge into final summary
    CREATE OR REPLACE TEMP TABLE chunks AS
    SELECT c.value::STRING AS chunk_text
    FROM demodb.workorder_summary.sample_workorders wo,
    LATERAL FLATTEN(input => SNOWFLAKE.CORTEX.SPLIT_TEXT_RECURSIVE_CHARACTER(wo.workorder_text, 'none', 1500, 100)) c
    WHERE wo.workorder_id = :workorder_id;

    CREATE OR REPLACE TEMP TABLE summaries AS
    SELECT SNOWFLAKE.CORTEX.COMPLETE('mistral-large', 'Summarize:\n\n' || chunk_text) AS summary
    FROM chunks;

    SELECT SNOWFLAKE.CORTEX.COMPLETE('mistral-large', 
        'Create one cohesive summary:\n\n' || LISTAGG(summary, '\n\n')
    ) INTO result FROM summaries;

    RETURN result;
END;
$$;

CALL summarize_workorder_two('WO-2024-001');