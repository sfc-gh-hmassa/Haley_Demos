-- ============================================================================
-- AI_EXTRACT Fine-Tuning Demo: Setup Script
-- Extracts BOTH scalar values AND tables from Safety Data Sheets
-- ============================================================================

USE ROLE ACCOUNTADMIN;
CREATE DATABASE IF NOT EXISTS SDS_DEMO;
USE DATABASE SDS_DEMO;
CREATE SCHEMA IF NOT EXISTS PUBLIC;
USE SCHEMA PUBLIC;

-- ============================================================================
-- Step 1: Create Stage (SSE encryption required for AI_EXTRACT)
-- ============================================================================
CREATE STAGE IF NOT EXISTS SDS_DOCS 
    DIRECTORY = (ENABLE = TRUE AUTO_REFRESH = TRUE) 
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');

-- Upload PDFs to @SDS_DOCS/sds/ then refresh:
ALTER STAGE SDS_DOCS REFRESH;

SELECT relative_path, size FROM DIRECTORY(@SDS_DOCS) WHERE relative_path ILIKE '%.pdf';

-- ============================================================================
-- Step 2: Basic AI_EXTRACT (No Fine-Tuning) - Scalar + Tables
-- ============================================================================

SELECT AI_EXTRACT(
    file => TO_FILE('@SDS_DOCS', 'sds/US001066-Clorox-Regular-Bleach1_3.pdf'),
    responseFormat => {
        'schema': {
            'type': 'object',
            'properties': {
                'product_name': { 'type': 'string', '$comment': 'Product name from Section 1' },
                'manufacturer': { 'type': 'string', '$comment': 'Manufacturer name' },
                'signal_word': { 'type': 'string', '$comment': 'GHS signal word' },
                'ph': { 'type': 'string', '$comment': 'pH value from Section 9' },
                'hazardous_ingredients': {
                    '$comment': 'Hazardous ingredients from Section 3',
                    'type': 'object',
                    'properties': {
                        'ingredient_name': { 'type': 'array', 'items': { 'type': 'string' } },
                        'cas_number': { 'type': 'array', 'items': { 'type': 'string' } },
                        'percent_range': { 'type': 'array', 'items': { 'type': 'string' } }
                    }
                },
                'physical_properties': {
                    '$comment': 'Physical properties from Section 9',
                    'type': 'object',
                    'properties': {
                        'property_name': { 'type': 'array', 'items': { 'type': 'string' } },
                        'value': { 'type': 'array', 'items': { 'type': 'string' } }
                    }
                }
            }
        }
    }
) AS extraction_result;

-- ============================================================================
-- Step 3: Create Training Data (Scalar + Tables in each example)
-- ============================================================================

CREATE OR REPLACE TABLE SDS_TRAINING (
    f FILE,
    p VARCHAR,
    r VARCHAR
);

-- Training Example 1: Clorox Bleach
INSERT INTO SDS_TRAINING (f, p, r)
SELECT 
    TO_FILE('@SDS_DOCS', 'sds/US001066-Clorox-Regular-Bleach1_3.pdf'),
    '{
        "schema": {
            "type": "object",
            "properties": {
                "product_name": { "type": "string", "$comment": "Product name from Section 1" },
                "manufacturer": { "type": "string", "$comment": "Manufacturer name" },
                "signal_word": { "type": "string", "$comment": "GHS signal word" },
                "ph": { "type": "string", "$comment": "pH value from Section 9" },
                "hazardous_ingredients": {
                    "$comment": "Hazardous ingredients from Section 3",
                    "type": "object",
                    "properties": {
                        "ingredient_name": { "type": "array", "items": { "type": "string" } },
                        "cas_number": { "type": "array", "items": { "type": "string" } },
                        "percent_range": { "type": "array", "items": { "type": "string" } }
                    }
                },
                "physical_properties": {
                    "$comment": "Physical properties from Section 9",
                    "type": "object",
                    "properties": {
                        "property_name": { "type": "array", "items": { "type": "string" } },
                        "value": { "type": "array", "items": { "type": "string" } }
                    }
                }
            }
        }
    }',
    '{
        "product_name": "Clorox Regular Bleach1",
        "manufacturer": "The Clorox Company",
        "signal_word": "Danger",
        "ph": "11.9",
        "hazardous_ingredients": {
            "ingredient_name": ["Sodium hypochlorite", "Sodium hydroxide"],
            "cas_number": ["7681-52-9", "1310-73-2"],
            "percent_range": ["5 - 10", "0.5 - 1.5"]
        },
        "physical_properties": {
            "property_name": ["pH", "Physical state", "Color", "Odor", "Relative density"],
            "value": ["11.9", "Liquid", "Clear, light yellow", "Chlorine", "1.085"]
        }
    }';

-- Training Example 2: Disinfecting Wipes
INSERT INTO SDS_TRAINING (f, p, r)
SELECT 
    TO_FILE('@SDS_DOCS', 'sds/Clorox-Commercial-Solutions®-Clorox®-Disinfecting-Wipes-Fresh-Scent.pdf'),
    '{
        "schema": {
            "type": "object",
            "properties": {
                "product_name": { "type": "string", "$comment": "Product name from Section 1" },
                "manufacturer": { "type": "string", "$comment": "Manufacturer name" },
                "signal_word": { "type": "string", "$comment": "GHS signal word" },
                "ph": { "type": "string", "$comment": "pH value from Section 9" },
                "hazardous_ingredients": {
                    "$comment": "Hazardous ingredients from Section 3",
                    "type": "object",
                    "properties": {
                        "ingredient_name": { "type": "array", "items": { "type": "string" } },
                        "cas_number": { "type": "array", "items": { "type": "string" } },
                        "percent_range": { "type": "array", "items": { "type": "string" } }
                    }
                },
                "physical_properties": {
                    "$comment": "Physical properties from Section 9",
                    "type": "object",
                    "properties": {
                        "property_name": { "type": "array", "items": { "type": "string" } },
                        "value": { "type": "array", "items": { "type": "string" } }
                    }
                }
            }
        }
    }',
    '{
        "product_name": "Clorox Commercial Solutions Clorox Disinfecting Wipes Fresh Scent",
        "manufacturer": "The Clorox Company",
        "signal_word": "Warning",
        "ph": "6 - 7.5",
        "hazardous_ingredients": {
            "ingredient_name": ["Alkyl dimethyl benzyl ammonium chloride", "Alkyl dimethyl ethylbenzyl ammonium chloride"],
            "cas_number": ["68424-85-1", "68956-79-6"],
            "percent_range": ["0.1 - 1", "0.1 - 1"]
        },
        "physical_properties": {
            "property_name": ["pH", "Relative density", "Water Solubility", "Color", "Odor", "Physical state"],
            "value": ["6 - 7.5 (liquid)", "~1.0 (liquid)", "Completely soluble", "Clear White", "Fruity Apple Floral", "Pre-Moistened Towelette"]
        }
    }';

-- Training Example 3: Formula 409
INSERT INTO SDS_TRAINING (f, p, r)
SELECT 
    TO_FILE('@SDS_DOCS', 'sds/SDS-US-Formula-409®-Multi-Surface-Cleaner-English-2022.pdf'),
    '{
        "schema": {
            "type": "object",
            "properties": {
                "product_name": { "type": "string", "$comment": "Product name from Section 1" },
                "manufacturer": { "type": "string", "$comment": "Manufacturer name" },
                "signal_word": { "type": "string", "$comment": "GHS signal word" },
                "ph": { "type": "string", "$comment": "pH value from Section 9" },
                "hazardous_ingredients": {
                    "$comment": "Hazardous ingredients from Section 3",
                    "type": "object",
                    "properties": {
                        "ingredient_name": { "type": "array", "items": { "type": "string" } },
                        "cas_number": { "type": "array", "items": { "type": "string" } },
                        "percent_range": { "type": "array", "items": { "type": "string" } }
                    }
                },
                "physical_properties": {
                    "$comment": "Physical properties from Section 9",
                    "type": "object",
                    "properties": {
                        "property_name": { "type": "array", "items": { "type": "string" } },
                        "value": { "type": "array", "items": { "type": "string" } }
                    }
                }
            }
        }
    }',
    '{
        "product_name": "Formula 409 Multi-Surface Cleaner",
        "manufacturer": "The Clorox Company",
        "signal_word": "None",
        "ph": "9 - 11.5",
        "hazardous_ingredients": {
            "ingredient_name": ["2-Butoxyethanol", "Ethanolamine"],
            "cas_number": ["111-76-2", "141-43-5"],
            "percent_range": ["1 - 5", "0.5 - 1.5"]
        },
        "physical_properties": {
            "property_name": ["pH", "Physical state", "Color", "Odor", "Relative density"],
            "value": ["9 - 11.5", "Liquid", "Green", "Floral Citrus", "1.00 - 1.02"]
        }
    }';

-- View training data summary
SELECT 
    FL_GET_RELATIVE_PATH(f) AS file_path,
    PARSE_JSON(r):product_name::STRING AS product,
    PARSE_JSON(r):signal_word::STRING AS signal_word,
    ARRAY_SIZE(PARSE_JSON(r):hazardous_ingredients:ingredient_name) AS num_ingredients,
    ARRAY_SIZE(PARSE_JSON(r):physical_properties:property_name) AS num_properties
FROM SDS_TRAINING;

-- ============================================================================
-- Step 4: Create Dataset and Fine-Tune
-- ============================================================================

CREATE OR REPLACE DATASET SDS_DATASET;

ALTER DATASET SDS_DATASET
ADD VERSION 'v1' FROM (
    SELECT 
        FL_GET_STAGE(f) || '/' || FL_GET_RELATIVE_PATH(f) AS "file",
        p AS "prompt",
        r AS "response"
    FROM SDS_TRAINING
);

-- Start fine-tuning
SELECT SNOWFLAKE.CORTEX.FINETUNE(
    'CREATE',
    'sds_extract_model',
    'arctic-extract',
    'snow://dataset/SDS_DEMO.PUBLIC.SDS_DATASET/versions/v1'
);

-- Check status (run until status = SUCCESS)
SELECT SNOWFLAKE.CORTEX.FINETUNE('SHOW');

-- ============================================================================
-- Step 5: Use Fine-Tuned Model (after status = SUCCESS)
-- ============================================================================

SELECT AI_EXTRACT(
    model => 'SDS_DEMO.PUBLIC.SDS_EXTRACT_MODEL',
    file => TO_FILE('@SDS_DOCS', 'sds/US001066-Clorox-Regular-Bleach1_3.pdf'),
    responseFormat => {
        'schema': {
            'type': 'object',
            'properties': {
                'product_name': { 'type': 'string', '$comment': 'Product name' },
                'manufacturer': { 'type': 'string', '$comment': 'Manufacturer' },
                'signal_word': { 'type': 'string', '$comment': 'Signal word' },
                'ph': { 'type': 'string', '$comment': 'pH value' },
                'hazardous_ingredients': {
                    'type': 'object',
                    'properties': {
                        'ingredient_name': { 'type': 'array', 'items': { 'type': 'string' } },
                        'cas_number': { 'type': 'array', 'items': { 'type': 'string' } },
                        'percent_range': { 'type': 'array', 'items': { 'type': 'string' } }
                    }
                },
                'physical_properties': {
                    'type': 'object',
                    'properties': {
                        'property_name': { 'type': 'array', 'items': { 'type': 'string' } },
                        'value': { 'type': 'array', 'items': { 'type': 'string' } }
                    }
                }
            }
        }
    }
) AS finetuned_result;
