-- ============================================================================
-- SNOWFLAKE WAFER YIELD FORECASTING DEMO - SETUP
-- ============================================================================
-- Creates only the raw data tables needed for Notebook 0 (Synthetic Data).
-- All other objects (features, models, etc.) are created by Snowflake services.
-- ============================================================================

-- Database & Schemas
CREATE DATABASE IF NOT EXISTS WAFER_YIELD_DEMO;
USE DATABASE WAFER_YIELD_DEMO;

CREATE SCHEMA IF NOT EXISTS RAW_DATA;
CREATE SCHEMA IF NOT EXISTS FEATURES;      -- For Feature Store
CREATE SCHEMA IF NOT EXISTS ML_MODELS;     -- For Model Registry
CREATE SCHEMA IF NOT EXISTS INFERENCE;     -- For predictions

-- Warehouse
CREATE WAREHOUSE IF NOT EXISTS WAFER_DEMO_WH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

USE WAREHOUSE WAFER_DEMO_WH;
USE SCHEMA RAW_DATA;

-- ============================================================================
-- RAW DATA TABLES (populated by Notebook 0)
-- ============================================================================

-- Table 1: Process telemetry per wafer per step
CREATE OR REPLACE TABLE WAFER_PROCESS_DATA (
    WAFER_ID            VARCHAR(20) NOT NULL,
    LOT_ID              VARCHAR(20) NOT NULL,
    EQUIPMENT_ID        VARCHAR(30) NOT NULL,
    PROCESS_STEP        VARCHAR(30) NOT NULL,
    TEMPERATURE_PROFILE VARIANT,
    PRESSURE_PROFILE    VARIANT,
    GAS_FLOW_RATE       FLOAT,
    AMBIENT_HUMIDITY    FLOAT,
    TIMESTAMP           TIMESTAMP_NTZ NOT NULL
);

-- Table 2: Defect inspection results
CREATE OR REPLACE TABLE WAFER_DEFECT_LOGS (
    WAFER_ID            VARCHAR(20) NOT NULL,
    DEFECT_TYPE         VARCHAR(30) NOT NULL,
    DEFECT_COUNT        INTEGER     NOT NULL,
    INSPECTION_TOOL     VARCHAR(30) NOT NULL,
    SEVERITY_SCORE      FLOAT       NOT NULL,
    TIMESTAMP           TIMESTAMP_NTZ NOT NULL
);

-- Table 3: Yield outcomes (ML target variable)
CREATE OR REPLACE TABLE FINAL_YIELD_LABELS (
    WAFER_ID                VARCHAR(20) NOT NULL,
    YIELD_GOOD              INTEGER     NOT NULL,
    YIELD_SCORE             FLOAT       NOT NULL,
    ROOT_CAUSE_CATEGORY     VARCHAR(30) NOT NULL
);

-- ============================================================================
-- COMPUTE POOLS FOR ML WORKLOADS (SPCS)
-- ============================================================================
-- See docs/COMPUTE_SIZING_GUIDE.md for detailed sizing recommendations

-- Training Compute Pool (GPU) - For Notebooks, HP Tuning, Model Training
CREATE COMPUTE POOL IF NOT EXISTS WAFER_TRAINING_POOL
    MIN_NODES = 1
    MAX_NODES = 2
    INSTANCE_FAMILY = GPU_NV_S       -- 1x A10G (24GB), 8 vCPU, 32GB RAM
    AUTO_SUSPEND_SECS = 3600         -- Suspend after 1 hour idle
    COMMENT = 'GPU pool for model training and hyperparameter tuning';

-- Inference Compute Pool (CPU) - For batch predictions
CREATE COMPUTE POOL IF NOT EXISTS WAFER_INFERENCE_POOL
    MIN_NODES = 1
    MAX_NODES = 4
    INSTANCE_FAMILY = CPU_X64_M      -- 8 vCPU, 32GB RAM (cost-effective)
    AUTO_SUSPEND_SECS = 300          -- Suspend after 5 min idle
    COMMENT = 'CPU pool for batch inference workloads';

-- Real-time Inference Pool (GPU) - For low-latency API endpoints
CREATE COMPUTE POOL IF NOT EXISTS WAFER_REALTIME_POOL
    MIN_NODES = 1
    MAX_NODES = 2
    INSTANCE_FAMILY = GPU_NV_S       -- For <10ms latency requirements
    AUTO_SUSPEND_SECS = 600          -- Suspend after 10 min idle
    COMMENT = 'GPU pool for real-time inference API';

-- ============================================================================
-- Verify
-- ============================================================================
SELECT 'Setup complete - 3 raw data tables created' AS STATUS;
SHOW TABLES IN SCHEMA RAW_DATA;