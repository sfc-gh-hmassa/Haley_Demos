-- ============================================================
-- Cortex Analyst Evaluation Framework - Setup Script
-- ============================================================
-- Run this script to create the evaluation tables and load sample data
-- ============================================================

-- Step 1: Create evaluation schema
-- ============================================================
USE DATABASE CORTEX_AGENTS_DEMO;  -- Change to your database

CREATE SCHEMA IF NOT EXISTS CORTEX_ANALYST_EVAL;
USE SCHEMA CORTEX_ANALYST_EVAL;

-- Step 2: Create evaluation tables
-- ============================================================

-- Table to store test questions
CREATE OR REPLACE TABLE EVAL_QUESTIONS (
    question_id INT AUTOINCREMENT,
    question VARCHAR(4000),
    expected_sql VARCHAR(16000),
    description VARCHAR(1000),
    category VARCHAR(100),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Table to store evaluation results
CREATE OR REPLACE TABLE EVAL_RESULTS (
    result_id INT AUTOINCREMENT,
    run_id VARCHAR(50),
    run_timestamp TIMESTAMP,
    semantic_model VARCHAR(500),
    question_id INT,
    question VARCHAR(4000),
    expected_sql VARCHAR(16000),
    generated_sql VARCHAR(16000),
    expected_result VARIANT,
    generated_result VARIANT,
    results_match BOOLEAN,
    execution_error VARCHAR(4000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- View for run summaries
CREATE OR REPLACE VIEW EVAL_RUN_SUMMARY AS
SELECT 
    run_id,
    run_timestamp,
    semantic_model,
    COUNT(*) as total_questions,
    SUM(CASE WHEN results_match THEN 1 ELSE 0 END) as passed,
    SUM(CASE WHEN NOT results_match AND execution_error IS NULL THEN 1 ELSE 0 END) as failed,
    SUM(CASE WHEN execution_error IS NOT NULL THEN 1 ELSE 0 END) as errors,
    ROUND(SUM(CASE WHEN results_match THEN 1 ELSE 0 END)::FLOAT / COUNT(*) * 100, 1) as accuracy_pct
FROM EVAL_RESULTS
GROUP BY run_id, run_timestamp, semantic_model
ORDER BY run_timestamp DESC;

-- Step 3: Load sample questions (for sales_orders semantic model)
-- ============================================================
-- Modify these for your own semantic model!

INSERT INTO EVAL_QUESTIONS (question, expected_sql, description, category) VALUES
('How many orders were placed in 2024?', 
 'SELECT COUNT(DISTINCT ORDER_ID) AS order_count FROM CORTEX_AGENTS_DEMO.MAIN.ORDERS WHERE YEAR(ORDER_DATE) = 2024',
 'Basic count with year filter',
 'Aggregation');

INSERT INTO EVAL_QUESTIONS (question, expected_sql, description, category) VALUES
('What is the total quantity of Iron Pipes ordered?', 
 'SELECT SUM(QUANTITY) AS total_quantity FROM CORTEX_AGENTS_DEMO.MAIN.ORDERS WHERE PRODUCT = ''Iron Pipes''',
 'Sum with product filter',
 'Aggregation');

INSERT INTO EVAL_QUESTIONS (question, expected_sql, description, category) VALUES
('Which customer has the most orders?', 
 'SELECT co.CUSTOMER, COUNT(DISTINCT co.ORDER_ID) AS order_count FROM CORTEX_AGENTS_DEMO.MAIN.CUSTOMER_ORDERS co GROUP BY co.CUSTOMER ORDER BY order_count DESC LIMIT 1',
 'Ranking query',
 'Ranking');

INSERT INTO EVAL_QUESTIONS (question, expected_sql, description, category) VALUES
('How many orders are currently pending?', 
 'SELECT COUNT(DISTINCT ORDER_ID) AS pending_orders FROM CORTEX_AGENTS_DEMO.MAIN.ORDERS WHERE STATUS = ''Pending''',
 'Status filter',
 'Filters');

INSERT INTO EVAL_QUESTIONS (question, expected_sql, description, category) VALUES
('What is the total revenue from shipped orders?', 
 'SELECT SUM(o.QUANTITY * p.UNIT_PRICE) AS total_revenue FROM CORTEX_AGENTS_DEMO.MAIN.ORDERS o JOIN CORTEX_AGENTS_DEMO.MAIN.PRODUCTS p ON o.PRODUCT = p.PRODUCT WHERE o.STATUS = ''Shipped''',
 'Multi-table join with calculation',
 'Joins');

INSERT INTO EVAL_QUESTIONS (question, expected_sql, description, category) VALUES
('How many orders were cancelled in Germany?', 
 'SELECT COUNT(DISTINCT ORDER_ID) AS cancelled_orders FROM CORTEX_AGENTS_DEMO.MAIN.ORDERS WHERE STATUS = ''Cancelled'' AND COUNTRY = ''Germany''',
 'Multiple filters',
 'Filters');

INSERT INTO EVAL_QUESTIONS (question, expected_sql, description, category) VALUES
('What products have been ordered to the UK?', 
 'SELECT DISTINCT PRODUCT FROM CORTEX_AGENTS_DEMO.MAIN.ORDERS WHERE COUNTRY = ''UK'' ORDER BY PRODUCT',
 'Distinct values',
 'Filters');

INSERT INTO EVAL_QUESTIONS (question, expected_sql, description, category) VALUES
('What is the total revenue by country?', 
 'SELECT COUNTRY, SUM(o.QUANTITY * p.UNIT_PRICE) AS total_revenue FROM CORTEX_AGENTS_DEMO.MAIN.ORDERS o JOIN CORTEX_AGENTS_DEMO.MAIN.PRODUCTS p ON o.PRODUCT = p.PRODUCT GROUP BY COUNTRY ORDER BY total_revenue DESC',
 'Group by with join',
 'Joins');

INSERT INTO EVAL_QUESTIONS (question, expected_sql, description, category) VALUES
('How many orders did Beta Ltd place?', 
 'SELECT COUNT(DISTINCT co.ORDER_ID) AS order_count FROM CORTEX_AGENTS_DEMO.MAIN.CUSTOMER_ORDERS co WHERE co.CUSTOMER = ''Beta Ltd''',
 'Customer filter',
 'Filters');

INSERT INTO EVAL_QUESTIONS (question, expected_sql, description, category) VALUES
('What is the most ordered product?', 
 'SELECT PRODUCT, SUM(QUANTITY) AS total_qty FROM CORTEX_AGENTS_DEMO.MAIN.ORDERS GROUP BY PRODUCT ORDER BY total_qty DESC LIMIT 1',
 'Ranking by quantity',
 'Ranking');

-- Step 4: Verify setup
-- ============================================================
SELECT 'Questions loaded:' as status, COUNT(*) as count FROM EVAL_QUESTIONS;

SELECT * FROM EVAL_QUESTIONS ORDER BY question_id;
