-- Snowflake AI Complete: Image Analysis and Entity Extraction
-- This SQL script demonstrates how to use Snowflake's AI Complete with multimodal capabilities
-- to analyze a knowledge graph image and generate code for extracting entities in star schema format.

-- =============================================================================
-- STEP 1: Setup and Configuration
-- =============================================================================

-- Set the context
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEMO_DB;
USE SCHEMA PUBLIC;

-- =============================================================================
-- STEP 2: Create Stage and Upload Image
-- =============================================================================

-- Create a stage for storing the knowledge graph image
CREATE OR REPLACE STAGE knowledge_graph_stage
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage for storing knowledge graph images';

-- Upload the knowledge graph image to the stage
-- Note: Run this command in Snowflake CLI or use the web interface to upload
-- PUT file:///path/to/your/knowledge_graph.jpg @knowledge_graph_stage
--     AUTO_COMPRESS = FALSE
--     OVERWRITE = TRUE;

-- Verify the stage contents
LIST @knowledge_graph_stage;

-- =============================================================================
-- STEP 3: Use AI Complete to Analyze the Image
-- =============================================================================

-- Method 1: Using AI Complete with image analysis
-- This approach reads the image from the stage and uses AI Complete to analyze it
WITH image_analysis AS (
    SELECT SNOWFLAKE.CORTEX.COMPLETE(
        'gpt-4-vision-preview',
        ARRAY_CONSTRUCT(
            OBJECT_CONSTRUCT(
                'role', 'user',
                'content', ARRAY_CONSTRUCT(
                    OBJECT_CONSTRUCT(
                        'type', 'text',
                        'text', 'Analyze this knowledge graph image and generate SQL DDL statements to create a star schema based on the entities and relationships shown in the graph. Requirements: 1) Identify all entities (nodes) in the graph, 2) Identify all relationships between entities, 3) Create a fact table for the central entity, 4) Create dimension tables for related entities, 5) Include proper foreign key relationships, 6) Use appropriate data types for each field, 7) Include primary keys and indexes. The SQL should be production-ready and follow Snowflake best practices. Return only the SQL DDL statements, no explanations.'
                    ),
                    OBJECT_CONSTRUCT(
                        'type', 'image_url',
                        'image_url', OBJECT_CONSTRUCT(
                            'url', 'data:image/jpeg;base64,' || BASE64_ENCODE($1)
                        )
                    )
                )
            )
        )
    ) as ai_response
    FROM (
        SELECT $1 as image_data
        FROM @knowledge_graph_stage/knowledge_graph.jpg
    )
)
SELECT ai_response as generated_sql
FROM image_analysis;

-- =============================================================================
-- STEP 4: Alternative Method - Direct Image Analysis
-- =============================================================================

-- Method 2: If you have the image data directly available
-- This is useful when working with images stored in variables or from other sources
/*
DECLARE
    image_base64 STRING;
    ai_response STRING;
BEGIN
    -- Get image data (this would be populated from your image source)
    -- image_base64 := 'your_base64_encoded_image_data_here';
    
    -- Use AI Complete to analyze the image
    SELECT SNOWFLAKE.CORTEX.COMPLETE(
        'gpt-4-vision-preview',
        ARRAY_CONSTRUCT(
            OBJECT_CONSTRUCT(
                'role', 'user',
                'content', ARRAY_CONSTRUCT(
                    OBJECT_CONSTRUCT(
                        'type', 'text',
                        'text', 'Analyze this knowledge graph image and generate SQL DDL statements to create a star schema based on the entities and relationships shown in the graph. Include fact tables, dimension tables, and proper relationships.'
                    ),
                    OBJECT_CONSTRUCT(
                        'type', 'image_url',
                        'image_url', OBJECT_CONSTRUCT(
                            'url', 'data:image/jpeg;base64,' || :image_base64
                        )
                    )
                )
            )
        )
    ) INTO :ai_response;
    
    -- Return the generated SQL
    RETURN :ai_response;
END;
*/

-- =============================================================================
-- STEP 5: Execute Generated SQL (Manual Step)
-- =============================================================================

-- After getting the AI response, you would manually copy and execute the generated SQL
-- The AI will generate CREATE TABLE statements that you can run directly

-- Example of what the AI might generate:
/*
-- Fact Table
CREATE OR REPLACE TABLE fact_central_entity (
    fact_id NUMBER AUTOINCREMENT PRIMARY KEY,
    entity_id VARCHAR(50) NOT NULL,
    dimension_1_id VARCHAR(50),
    dimension_2_id VARCHAR(50),
    dimension_3_id VARCHAR(50),
    measure_1 NUMBER,
    measure_2 NUMBER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Dimension Tables
CREATE OR REPLACE TABLE dim_entity_1 (
    entity_1_id VARCHAR(50) PRIMARY KEY,
    entity_1_name VARCHAR(100) NOT NULL,
    entity_1_description TEXT,
    entity_1_category VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE dim_entity_2 (
    entity_2_id VARCHAR(50) PRIMARY KEY,
    entity_2_name VARCHAR(100) NOT NULL,
    entity_2_type VARCHAR(50),
    entity_2_status VARCHAR(20),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Add foreign key constraints
ALTER TABLE fact_central_entity 
ADD CONSTRAINT fk_dim_entity_1 
FOREIGN KEY (dimension_1_id) REFERENCES dim_entity_1(entity_1_id);

ALTER TABLE fact_central_entity 
ADD CONSTRAINT fk_dim_entity_2 
FOREIGN KEY (dimension_2_id) REFERENCES dim_entity_2(entity_2_id);

-- Create indexes for performance
CREATE INDEX idx_fact_entity_id ON fact_central_entity(entity_id);
CREATE INDEX idx_fact_dim_1 ON fact_central_entity(dimension_1_id);
CREATE INDEX idx_fact_dim_2 ON fact_central_entity(dimension_2_id);
*/

-- =============================================================================
-- STEP 6: Verify Created Schema
-- =============================================================================

-- List all tables in the current schema
SHOW TABLES;

-- Describe each table structure
-- DESCRIBE TABLE fact_central_entity;
-- DESCRIBE TABLE dim_entity_1;
-- DESCRIBE TABLE dim_entity_2;

-- =============================================================================
-- STEP 7: Cleanup (Optional)
-- =============================================================================

-- Drop the stage if no longer needed
-- DROP STAGE IF EXISTS knowledge_graph_stage;

-- =============================================================================
-- USAGE INSTRUCTIONS
-- =============================================================================

/*
1. Update the warehouse, database, and schema names to match your environment
2. Upload the knowledge_graph.jpg file to the created stage
3. Run the AI Complete query to generate SQL
4. Copy the generated SQL and execute it manually
5. Verify the created schema using the verification queries
6. Test the schema with sample data

PREREQUISITES:
- Snowflake account with AI Complete enabled
- OpenAI integration configured
- ACCOUNTADMIN role or equivalent permissions
- knowledge_graph.jpg file uploaded to stage

NOTES:
- The AI Complete service requires proper configuration
- Image analysis may take some time depending on image size
- Review generated SQL before execution in production
- Consider adding data validation and constraints as needed
*/
