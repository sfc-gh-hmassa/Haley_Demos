-- Financial Dashboard Data Setup
-- Run this in your Snowflake account to create the necessary tables

-- Create database and schema
CREATE DATABASE IF NOT EXISTS FINANCIAL_DEMO;
USE DATABASE FINANCIAL_DEMO;
CREATE SCHEMA IF NOT EXISTS ANALYTICS;

CREATE STAGE IF NOT EXISTS FINANCIAL_DEMO.ANALYTICS.STAGE_FINANCIAL_DEMO;

USE SCHEMA ANALYTICS;

-- 1. Revenue Data Table
CREATE OR REPLACE TABLE REVENUE_DATA (
    DATE_PERIOD DATE,
    DEPARTMENT VARCHAR(50),
    REVENUE_AMOUNT DECIMAL(15,2),
    FORECAST_AMOUNT DECIMAL(15,2),
    REGION VARCHAR(50),
    PRODUCT_CATEGORY VARCHAR(50),
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- 2. Expense Data Table
CREATE OR REPLACE TABLE EXPENSE_DATA (
    DATE_PERIOD DATE,
    EXPENSE_CATEGORY VARCHAR(50),
    EXPENSE_AMOUNT DECIMAL(15,2),
    DEPARTMENT VARCHAR(50),
    EXPENSE_TYPE VARCHAR(20), -- Fixed, Variable, One-time
    BUDGET_AMOUNT DECIMAL(15,2),
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- 3. Financial Metrics Table
CREATE OR REPLACE TABLE FINANCIAL_METRICS (
    DATE_PERIOD DATE,
    METRIC_NAME VARCHAR(50),
    METRIC_VALUE DECIMAL(15,4),
    TARGET_VALUE DECIMAL(15,4),
    METRIC_CATEGORY VARCHAR(50),
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- 4. Department Performance Table
CREATE OR REPLACE TABLE DEPARTMENT_PERFORMANCE (
    DATE_PERIOD DATE,
    DEPARTMENT VARCHAR(50),
    REVENUE DECIMAL(15,2),
    EXPENSES DECIMAL(15,2),
    PROFIT DECIMAL(15,2),
    EMPLOYEE_COUNT INTEGER,
    PRODUCTIVITY_SCORE DECIMAL(5,2),
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Insert sample revenue data (last 24 months + 6 months forecast)
INSERT INTO REVENUE_DATA VALUES
-- 2023 Data
('2023-01-01', 'Sales', 180000.00, 175000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2023-01-01', 'Marketing', 45000.00, 42000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2023-01-01', 'Operations', 25000.00, 28000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2023-02-01', 'Sales', 195000.00, 185000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2023-02-01', 'Marketing', 52000.00, 48000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2023-02-01', 'Operations', 28000.00, 30000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2023-03-01', 'Sales', 210000.00, 195000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2023-03-01', 'Marketing', 58000.00, 55000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2023-03-01', 'Operations', 32000.00, 35000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2023-04-01', 'Sales', 225000.00, 205000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2023-04-01', 'Marketing', 62000.00, 58000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2023-04-01', 'Operations', 35000.00, 38000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2023-05-01', 'Sales', 240000.00, 220000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2023-05-01', 'Marketing', 68000.00, 62000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2023-05-01', 'Operations', 38000.00, 40000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2023-06-01', 'Sales', 255000.00, 235000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2023-06-01', 'Marketing', 72000.00, 68000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2023-06-01', 'Operations', 42000.00, 45000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2023-07-01', 'Sales', 270000.00, 250000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2023-07-01', 'Marketing', 78000.00, 72000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2023-07-01', 'Operations', 45000.00, 48000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2023-08-01', 'Sales', 285000.00, 265000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2023-08-01', 'Marketing', 82000.00, 78000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2023-08-01', 'Operations', 48000.00, 52000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2023-09-01', 'Sales', 300000.00, 280000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2023-09-01', 'Marketing', 88000.00, 82000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2023-09-01', 'Operations', 52000.00, 55000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2023-10-01', 'Sales', 315000.00, 295000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2023-10-01', 'Marketing', 92000.00, 88000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2023-10-01', 'Operations', 55000.00, 58000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2023-11-01', 'Sales', 330000.00, 310000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2023-11-01', 'Marketing', 98000.00, 92000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2023-11-01', 'Operations', 58000.00, 62000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2023-12-01', 'Sales', 345000.00, 325000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2023-12-01', 'Marketing', 102000.00, 98000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2023-12-01', 'Operations', 62000.00, 65000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),

-- 2024 Data (Current Year)
('2024-01-01', 'Sales', 360000.00, 340000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2024-01-01', 'Marketing', 108000.00, 102000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2024-01-01', 'Operations', 65000.00, 68000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2024-02-01', 'Sales', 375000.00, 355000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2024-02-01', 'Marketing', 112000.00, 108000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2024-02-01', 'Operations', 68000.00, 72000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2024-03-01', 'Sales', 390000.00, 370000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2024-03-01', 'Marketing', 118000.00, 112000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2024-03-01', 'Operations', 72000.00, 75000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2024-04-01', 'Sales', 405000.00, 385000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2024-04-01', 'Marketing', 122000.00, 118000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2024-04-01', 'Operations', 75000.00, 78000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2024-05-01', 'Sales', 420000.00, 400000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2024-05-01', 'Marketing', 128000.00, 122000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2024-05-01', 'Operations', 78000.00, 82000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2024-06-01', 'Sales', 435000.00, 415000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2024-06-01', 'Marketing', 132000.00, 128000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2024-06-01', 'Operations', 82000.00, 85000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2024-07-01', 'Sales', 450000.00, 430000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2024-07-01', 'Marketing', 138000.00, 132000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2024-07-01', 'Operations', 85000.00, 88000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2024-08-01', 'Sales', 465000.00, 445000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2024-08-01', 'Marketing', 142000.00, 138000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2024-08-01', 'Operations', 88000.00, 92000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2024-09-01', 'Sales', 480000.00, 460000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2024-09-01', 'Marketing', 148000.00, 142000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2024-09-01', 'Operations', 92000.00, 95000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2024-10-01', 'Sales', 495000.00, 475000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2024-10-01', 'Marketing', 152000.00, 148000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2024-10-01', 'Operations', 95000.00, 98000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2024-11-01', 'Sales', 510000.00, 490000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2024-11-01', 'Marketing', 158000.00, 152000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2024-11-01', 'Operations', 98000.00, 102000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2024-12-01', 'Sales', 525000.00, 505000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2024-12-01', 'Marketing', 162000.00, 158000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2024-12-01', 'Operations', 102000.00, 105000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),

-- Future Forecast Data (2025)
('2025-01-01', 'Sales', NULL, 540000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2025-01-01', 'Marketing', NULL, 168000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2025-01-01', 'Operations', NULL, 108000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2025-02-01', 'Sales', NULL, 555000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2025-02-01', 'Marketing', NULL, 172000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2025-02-01', 'Operations', NULL, 112000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2025-03-01', 'Sales', NULL, 570000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2025-03-01', 'Marketing', NULL, 178000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2025-03-01', 'Operations', NULL, 115000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2025-04-01', 'Sales', NULL, 585000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2025-04-01', 'Marketing', NULL, 182000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2025-04-01', 'Operations', NULL, 118000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2025-05-01', 'Sales', NULL, 600000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2025-05-01', 'Marketing', NULL, 188000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2025-05-01', 'Operations', NULL, 122000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP()),
('2025-06-01', 'Sales', NULL, 615000.00, 'North America', 'Software', CURRENT_TIMESTAMP()),
('2025-06-01', 'Marketing', NULL, 192000.00, 'North America', 'Services', CURRENT_TIMESTAMP()),
('2025-06-01', 'Operations', NULL, 125000.00, 'Europe', 'Hardware', CURRENT_TIMESTAMP());

-- Insert expense data
INSERT INTO EXPENSE_DATA VALUES
-- 2023 Expenses
('2023-01-01', 'Salaries', 120000.00, 'Sales', 'Fixed', 125000.00, CURRENT_TIMESTAMP()),
('2023-01-01', 'Marketing', 35000.00, 'Marketing', 'Variable', 40000.00, CURRENT_TIMESTAMP()),
('2023-01-01', 'Office Rent', 15000.00, 'Operations', 'Fixed', 15000.00, CURRENT_TIMESTAMP()),
('2023-01-01', 'Technology', 25000.00, 'Operations', 'Variable', 30000.00, CURRENT_TIMESTAMP()),
('2023-02-01', 'Salaries', 125000.00, 'Sales', 'Fixed', 125000.00, CURRENT_TIMESTAMP()),
('2023-02-01', 'Marketing', 38000.00, 'Marketing', 'Variable', 40000.00, CURRENT_TIMESTAMP()),
('2023-02-01', 'Office Rent', 15000.00, 'Operations', 'Fixed', 15000.00, CURRENT_TIMESTAMP()),
('2023-02-01', 'Technology', 28000.00, 'Operations', 'Variable', 30000.00, CURRENT_TIMESTAMP()),
('2023-03-01', 'Salaries', 128000.00, 'Sales', 'Fixed', 130000.00, CURRENT_TIMESTAMP()),
('2023-03-01', 'Marketing', 42000.00, 'Marketing', 'Variable', 45000.00, CURRENT_TIMESTAMP()),
('2023-03-01', 'Office Rent', 15000.00, 'Operations', 'Fixed', 15000.00, CURRENT_TIMESTAMP()),
('2023-03-01', 'Technology', 32000.00, 'Operations', 'Variable', 35000.00, CURRENT_TIMESTAMP()),
('2023-04-01', 'Salaries', 132000.00, 'Sales', 'Fixed', 135000.00, CURRENT_TIMESTAMP()),
('2023-04-01', 'Marketing', 45000.00, 'Marketing', 'Variable', 48000.00, CURRENT_TIMESTAMP()),
('2023-04-01', 'Office Rent', 15000.00, 'Operations', 'Fixed', 15000.00, CURRENT_TIMESTAMP()),
('2023-04-01', 'Technology', 35000.00, 'Operations', 'Variable', 38000.00, CURRENT_TIMESTAMP()),
('2023-05-01', 'Salaries', 135000.00, 'Sales', 'Fixed', 140000.00, CURRENT_TIMESTAMP()),
('2023-05-01', 'Marketing', 48000.00, 'Marketing', 'Variable', 52000.00, CURRENT_TIMESTAMP()),
('2023-05-01', 'Office Rent', 15000.00, 'Operations', 'Fixed', 15000.00, CURRENT_TIMESTAMP()),
('2023-05-01', 'Technology', 38000.00, 'Operations', 'Variable', 42000.00, CURRENT_TIMESTAMP()),
('2023-06-01', 'Salaries', 140000.00, 'Sales', 'Fixed', 145000.00, CURRENT_TIMESTAMP()),
('2023-06-01', 'Marketing', 52000.00, 'Marketing', 'Variable', 55000.00, CURRENT_TIMESTAMP()),
('2023-06-01', 'Office Rent', 15000.00, 'Operations', 'Fixed', 15000.00, CURRENT_TIMESTAMP()),
('2023-06-01', 'Technology', 42000.00, 'Operations', 'Variable', 45000.00, CURRENT_TIMESTAMP()),

-- 2024 Expenses (continuing pattern with growth)
('2024-01-01', 'Salaries', 155000.00, 'Sales', 'Fixed', 160000.00, CURRENT_TIMESTAMP()),
('2024-01-01', 'Marketing', 58000.00, 'Marketing', 'Variable', 62000.00, CURRENT_TIMESTAMP()),
('2024-01-01', 'Office Rent', 18000.00, 'Operations', 'Fixed', 18000.00, CURRENT_TIMESTAMP()),
('2024-01-01', 'Technology', 48000.00, 'Operations', 'Variable', 52000.00, CURRENT_TIMESTAMP()),
('2024-02-01', 'Salaries', 158000.00, 'Sales', 'Fixed', 162000.00, CURRENT_TIMESTAMP()),
('2024-02-01', 'Marketing', 62000.00, 'Marketing', 'Variable', 65000.00, CURRENT_TIMESTAMP()),
('2024-02-01', 'Office Rent', 18000.00, 'Operations', 'Fixed', 18000.00, CURRENT_TIMESTAMP()),
('2024-02-01', 'Technology', 52000.00, 'Operations', 'Variable', 55000.00, CURRENT_TIMESTAMP()),
('2024-03-01', 'Salaries', 162000.00, 'Sales', 'Fixed', 165000.00, CURRENT_TIMESTAMP()),
('2024-03-01', 'Marketing', 65000.00, 'Marketing', 'Variable', 68000.00, CURRENT_TIMESTAMP()),
('2024-03-01', 'Office Rent', 18000.00, 'Operations', 'Fixed', 18000.00, CURRENT_TIMESTAMP()),
('2024-03-01', 'Technology', 55000.00, 'Operations', 'Variable', 58000.00, CURRENT_TIMESTAMP()),
('2024-04-01', 'Salaries', 165000.00, 'Sales', 'Fixed', 168000.00, CURRENT_TIMESTAMP()),
('2024-04-01', 'Marketing', 68000.00, 'Marketing', 'Variable', 72000.00, CURRENT_TIMESTAMP()),
('2024-04-01', 'Office Rent', 18000.00, 'Operations', 'Fixed', 18000.00, CURRENT_TIMESTAMP()),
('2024-04-01', 'Technology', 58000.00, 'Operations', 'Variable', 62000.00, CURRENT_TIMESTAMP()),
('2024-05-01', 'Salaries', 168000.00, 'Sales', 'Fixed', 172000.00, CURRENT_TIMESTAMP()),
('2024-05-01', 'Marketing', 72000.00, 'Marketing', 'Variable', 75000.00, CURRENT_TIMESTAMP()),
('2024-05-01', 'Office Rent', 18000.00, 'Operations', 'Fixed', 18000.00, CURRENT_TIMESTAMP()),
('2024-05-01', 'Technology', 62000.00, 'Operations', 'Variable', 65000.00, CURRENT_TIMESTAMP()),
('2024-06-01', 'Salaries', 172000.00, 'Sales', 'Fixed', 175000.00, CURRENT_TIMESTAMP()),
('2024-06-01', 'Marketing', 75000.00, 'Marketing', 'Variable', 78000.00, CURRENT_TIMESTAMP()),
('2024-06-01', 'Office Rent', 18000.00, 'Operations', 'Fixed', 18000.00, CURRENT_TIMESTAMP()),
('2024-06-01', 'Technology', 65000.00, 'Operations', 'Variable', 68000.00, CURRENT_TIMESTAMP()),
('2024-07-01', 'Salaries', 175000.00, 'Sales', 'Fixed', 178000.00, CURRENT_TIMESTAMP()),
('2024-07-01', 'Marketing', 78000.00, 'Marketing', 'Variable', 82000.00, CURRENT_TIMESTAMP()),
('2024-07-01', 'Office Rent', 18000.00, 'Operations', 'Fixed', 18000.00, CURRENT_TIMESTAMP()),
('2024-07-01', 'Technology', 68000.00, 'Operations', 'Variable', 72000.00, CURRENT_TIMESTAMP()),
('2024-08-01', 'Salaries', 178000.00, 'Sales', 'Fixed', 182000.00, CURRENT_TIMESTAMP()),
('2024-08-01', 'Marketing', 82000.00, 'Marketing', 'Variable', 85000.00, CURRENT_TIMESTAMP()),
('2024-08-01', 'Office Rent', 18000.00, 'Operations', 'Fixed', 18000.00, CURRENT_TIMESTAMP()),
('2024-08-01', 'Technology', 72000.00, 'Operations', 'Variable', 75000.00, CURRENT_TIMESTAMP()),
('2024-09-01', 'Salaries', 182000.00, 'Sales', 'Fixed', 185000.00, CURRENT_TIMESTAMP()),
('2024-09-01', 'Marketing', 85000.00, 'Marketing', 'Variable', 88000.00, CURRENT_TIMESTAMP()),
('2024-09-01', 'Office Rent', 18000.00, 'Operations', 'Fixed', 18000.00, CURRENT_TIMESTAMP()),
('2024-09-01', 'Technology', 75000.00, 'Operations', 'Variable', 78000.00, CURRENT_TIMESTAMP()),
('2024-10-01', 'Salaries', 185000.00, 'Sales', 'Fixed', 188000.00, CURRENT_TIMESTAMP()),
('2024-10-01', 'Marketing', 88000.00, 'Marketing', 'Variable', 92000.00, CURRENT_TIMESTAMP()),
('2024-10-01', 'Office Rent', 18000.00, 'Operations', 'Fixed', 18000.00, CURRENT_TIMESTAMP()),
('2024-10-01', 'Technology', 78000.00, 'Operations', 'Variable', 82000.00, CURRENT_TIMESTAMP()),
('2024-11-01', 'Salaries', 188000.00, 'Sales', 'Fixed', 192000.00, CURRENT_TIMESTAMP()),
('2024-11-01', 'Marketing', 92000.00, 'Marketing', 'Variable', 95000.00, CURRENT_TIMESTAMP()),
('2024-11-01', 'Office Rent', 18000.00, 'Operations', 'Fixed', 18000.00, CURRENT_TIMESTAMP()),
('2024-11-01', 'Technology', 82000.00, 'Operations', 'Variable', 85000.00, CURRENT_TIMESTAMP()),
('2024-12-01', 'Salaries', 192000.00, 'Sales', 'Fixed', 195000.00, CURRENT_TIMESTAMP()),
('2024-12-01', 'Marketing', 95000.00, 'Marketing', 'Variable', 98000.00, CURRENT_TIMESTAMP()),
('2024-12-01', 'Office Rent', 18000.00, 'Operations', 'Fixed', 18000.00, CURRENT_TIMESTAMP()),
('2024-12-01', 'Technology', 85000.00, 'Operations', 'Variable', 88000.00, CURRENT_TIMESTAMP());

-- Insert Financial Metrics
INSERT INTO FINANCIAL_METRICS VALUES
('2024-01-01', 'Revenue Growth Rate', 0.125, 0.15, 'Growth', CURRENT_TIMESTAMP()),
('2024-01-01', 'Profit Margin', 0.28, 0.30, 'Profitability', CURRENT_TIMESTAMP()),
('2024-01-01', 'Operating Expense Ratio', 0.72, 0.70, 'Efficiency', CURRENT_TIMESTAMP()),
('2024-01-01', 'Customer Acquisition Cost', 1250.00, 1000.00, 'Marketing', CURRENT_TIMESTAMP()),
('2024-02-01', 'Revenue Growth Rate', 0.132, 0.15, 'Growth', CURRENT_TIMESTAMP()),
('2024-02-01', 'Profit Margin', 0.295, 0.30, 'Profitability', CURRENT_TIMESTAMP()),
('2024-02-01', 'Operating Expense Ratio', 0.705, 0.70, 'Efficiency', CURRENT_TIMESTAMP()),
('2024-02-01', 'Customer Acquisition Cost', 1180.00, 1000.00, 'Marketing', CURRENT_TIMESTAMP()),
('2024-03-01', 'Revenue Growth Rate', 0.138, 0.15, 'Growth', CURRENT_TIMESTAMP()),
('2024-03-01', 'Profit Margin', 0.31, 0.30, 'Profitability', CURRENT_TIMESTAMP()),
('2024-03-01', 'Operating Expense Ratio', 0.69, 0.70, 'Efficiency', CURRENT_TIMESTAMP()),
('2024-03-01', 'Customer Acquisition Cost', 1150.00, 1000.00, 'Marketing', CURRENT_TIMESTAMP()),
('2024-04-01', 'Revenue Growth Rate', 0.145, 0.15, 'Growth', CURRENT_TIMESTAMP()),
('2024-04-01', 'Profit Margin', 0.318, 0.30, 'Profitability', CURRENT_TIMESTAMP()),
('2024-04-01', 'Operating Expense Ratio', 0.682, 0.70, 'Efficiency', CURRENT_TIMESTAMP()),
('2024-04-01', 'Customer Acquisition Cost', 1100.00, 1000.00, 'Marketing', CURRENT_TIMESTAMP()),
('2024-05-01', 'Revenue Growth Rate', 0.152, 0.15, 'Growth', CURRENT_TIMESTAMP()),
('2024-05-01', 'Profit Margin', 0.325, 0.30, 'Profitability', CURRENT_TIMESTAMP()),
('2024-05-01', 'Operating Expense Ratio', 0.675, 0.70, 'Efficiency', CURRENT_TIMESTAMP()),
('2024-05-01', 'Customer Acquisition Cost', 1050.00, 1000.00, 'Marketing', CURRENT_TIMESTAMP()),
('2024-06-01', 'Revenue Growth Rate', 0.158, 0.15, 'Growth', CURRENT_TIMESTAMP()),
('2024-06-01', 'Profit Margin', 0.332, 0.30, 'Profitability', CURRENT_TIMESTAMP()),
('2024-06-01', 'Operating Expense Ratio', 0.668, 0.70, 'Efficiency', CURRENT_TIMESTAMP()),
('2024-06-01', 'Customer Acquisition Cost', 1000.00, 1000.00, 'Marketing', CURRENT_TIMESTAMP()),
('2024-07-01', 'Revenue Growth Rate', 0.165, 0.15, 'Growth', CURRENT_TIMESTAMP()),
('2024-07-01', 'Profit Margin', 0.338, 0.30, 'Profitability', CURRENT_TIMESTAMP()),
('2024-07-01', 'Operating Expense Ratio', 0.662, 0.70, 'Efficiency', CURRENT_TIMESTAMP()),
('2024-07-01', 'Customer Acquisition Cost', 950.00, 1000.00, 'Marketing', CURRENT_TIMESTAMP()),
('2024-08-01', 'Revenue Growth Rate', 0.172, 0.15, 'Growth', CURRENT_TIMESTAMP()),
('2024-08-01', 'Profit Margin', 0.345, 0.30, 'Profitability', CURRENT_TIMESTAMP()),
('2024-08-01', 'Operating Expense Ratio', 0.655, 0.70, 'Efficiency', CURRENT_TIMESTAMP()),
('2024-08-01', 'Customer Acquisition Cost', 900.00, 1000.00, 'Marketing', CURRENT_TIMESTAMP()),
('2024-09-01', 'Revenue Growth Rate', 0.178, 0.15, 'Growth', CURRENT_TIMESTAMP()),
('2024-09-01', 'Profit Margin', 0.352, 0.30, 'Profitability', CURRENT_TIMESTAMP()),
('2024-09-01', 'Operating Expense Ratio', 0.648, 0.70, 'Efficiency', CURRENT_TIMESTAMP()),
('2024-09-01', 'Customer Acquisition Cost', 875.00, 1000.00, 'Marketing', CURRENT_TIMESTAMP()),
('2024-10-01', 'Revenue Growth Rate', 0.185, 0.15, 'Growth', CURRENT_TIMESTAMP()),
('2024-10-01', 'Profit Margin', 0.358, 0.30, 'Profitability', CURRENT_TIMESTAMP()),
('2024-10-01', 'Operating Expense Ratio', 0.642, 0.70, 'Efficiency', CURRENT_TIMESTAMP()),
('2024-10-01', 'Customer Acquisition Cost', 850.00, 1000.00, 'Marketing', CURRENT_TIMESTAMP()),
('2024-11-01', 'Revenue Growth Rate', 0.192, 0.15, 'Growth', CURRENT_TIMESTAMP()),
('2024-11-01', 'Profit Margin', 0.365, 0.30, 'Profitability', CURRENT_TIMESTAMP()),
('2024-11-01', 'Operating Expense Ratio', 0.635, 0.70, 'Efficiency', CURRENT_TIMESTAMP()),
('2024-11-01', 'Customer Acquisition Cost', 825.00, 1000.00, 'Marketing', CURRENT_TIMESTAMP()),
('2024-12-01', 'Revenue Growth Rate', 0.198, 0.15, 'Growth', CURRENT_TIMESTAMP()),
('2024-12-01', 'Profit Margin', 0.372, 0.30, 'Profitability', CURRENT_TIMESTAMP()),
('2024-12-01', 'Operating Expense Ratio', 0.628, 0.70, 'Efficiency', CURRENT_TIMESTAMP()),
('2024-12-01', 'Customer Acquisition Cost', 800.00, 1000.00, 'Marketing', CURRENT_TIMESTAMP());

-- Insert Department Performance Data
INSERT INTO DEPARTMENT_PERFORMANCE VALUES
('2024-01-01', 'Sales', 360000.00, 155000.00, 205000.00, 15, 8.5, CURRENT_TIMESTAMP()),
('2024-01-01', 'Marketing', 108000.00, 58000.00, 50000.00, 8, 7.2, CURRENT_TIMESTAMP()),
('2024-01-01', 'Operations', 65000.00, 66000.00, -1000.00, 12, 6.8, CURRENT_TIMESTAMP()),
('2024-02-01', 'Sales', 375000.00, 158000.00, 217000.00, 15, 8.7, CURRENT_TIMESTAMP()),
('2024-02-01', 'Marketing', 112000.00, 62000.00, 50000.00, 8, 7.5, CURRENT_TIMESTAMP()),
('2024-02-01', 'Operations', 68000.00, 70000.00, -2000.00, 12, 7.0, CURRENT_TIMESTAMP()),
('2024-03-01', 'Sales', 390000.00, 162000.00, 228000.00, 16, 8.9, CURRENT_TIMESTAMP()),
('2024-03-01', 'Marketing', 118000.00, 65000.00, 53000.00, 9, 7.8, CURRENT_TIMESTAMP()),
('2024-03-01', 'Operations', 72000.00, 73000.00, -1000.00, 13, 7.2, CURRENT_TIMESTAMP()),
('2024-04-01', 'Sales', 405000.00, 165000.00, 240000.00, 16, 9.1, CURRENT_TIMESTAMP()),
('2024-04-01', 'Marketing', 122000.00, 68000.00, 54000.00, 9, 8.0, CURRENT_TIMESTAMP()),
('2024-04-01', 'Operations', 75000.00, 76000.00, -1000.00, 13, 7.4, CURRENT_TIMESTAMP()),
('2024-05-01', 'Sales', 420000.00, 168000.00, 252000.00, 17, 9.3, CURRENT_TIMESTAMP()),
('2024-05-01', 'Marketing', 128000.00, 72000.00, 56000.00, 10, 8.2, CURRENT_TIMESTAMP()),
('2024-05-01', 'Operations', 78000.00, 80000.00, -2000.00, 14, 7.6, CURRENT_TIMESTAMP()),
('2024-06-01', 'Sales', 435000.00, 172000.00, 263000.00, 17, 9.5, CURRENT_TIMESTAMP()),
('2024-06-01', 'Marketing', 132000.00, 75000.00, 57000.00, 10, 8.4, CURRENT_TIMESTAMP()),
('2024-06-01', 'Operations', 82000.00, 83000.00, -1000.00, 14, 7.8, CURRENT_TIMESTAMP()),
('2024-07-01', 'Sales', 450000.00, 175000.00, 275000.00, 18, 9.7, CURRENT_TIMESTAMP()),
('2024-07-01', 'Marketing', 138000.00, 78000.00, 60000.00, 11, 8.6, CURRENT_TIMESTAMP()),
('2024-07-01', 'Operations', 85000.00, 86000.00, -1000.00, 15, 8.0, CURRENT_TIMESTAMP()),
('2024-08-01', 'Sales', 465000.00, 178000.00, 287000.00, 18, 9.9, CURRENT_TIMESTAMP()),
('2024-08-01', 'Marketing', 142000.00, 82000.00, 60000.00, 11, 8.8, CURRENT_TIMESTAMP()),
('2024-08-01', 'Operations', 88000.00, 90000.00, -2000.00, 15, 8.2, CURRENT_TIMESTAMP()),
('2024-09-01', 'Sales', 480000.00, 182000.00, 298000.00, 19, 10.1, CURRENT_TIMESTAMP()),
('2024-09-01', 'Marketing', 148000.00, 85000.00, 63000.00, 12, 9.0, CURRENT_TIMESTAMP()),
('2024-09-01', 'Operations', 92000.00, 93000.00, -1000.00, 16, 8.4, CURRENT_TIMESTAMP()),
('2024-10-01', 'Sales', 495000.00, 185000.00, 310000.00, 19, 10.3, CURRENT_TIMESTAMP()),
('2024-10-01', 'Marketing', 152000.00, 88000.00, 64000.00, 12, 9.2, CURRENT_TIMESTAMP()),
('2024-10-01', 'Operations', 95000.00, 96000.00, -1000.00, 16, 8.6, CURRENT_TIMESTAMP()),
('2024-11-01', 'Sales', 510000.00, 188000.00, 322000.00, 20, 10.5, CURRENT_TIMESTAMP()),
('2024-11-01', 'Marketing', 158000.00, 92000.00, 66000.00, 13, 9.4, CURRENT_TIMESTAMP()),
('2024-11-01', 'Operations', 98000.00, 100000.00, -2000.00, 17, 8.8, CURRENT_TIMESTAMP()),
('2024-12-01', 'Sales', 525000.00, 192000.00, 333000.00, 20, 10.7, CURRENT_TIMESTAMP()),
('2024-12-01', 'Marketing', 162000.00, 95000.00, 67000.00, 13, 9.6, CURRENT_TIMESTAMP()),
('2024-12-01', 'Operations', 102000.00, 103000.00, -1000.00, 17, 9.0, CURRENT_TIMESTAMP());

-- Create views for easier data access
CREATE OR REPLACE VIEW MONTHLY_FINANCIAL_SUMMARY AS
SELECT 
    DATE_PERIOD,
    SUM(REVENUE_AMOUNT) AS TOTAL_REVENUE,
    SUM(FORECAST_AMOUNT) AS TOTAL_FORECAST,
    (SELECT SUM(EXPENSE_AMOUNT) FROM EXPENSE_DATA e WHERE e.DATE_PERIOD = r.DATE_PERIOD) AS TOTAL_EXPENSES,
    SUM(REVENUE_AMOUNT) - (SELECT SUM(EXPENSE_AMOUNT) FROM EXPENSE_DATA e WHERE e.DATE_PERIOD = r.DATE_PERIOD) AS NET_PROFIT,
    CASE 
        WHEN SUM(REVENUE_AMOUNT) > 0 THEN 
            (SUM(REVENUE_AMOUNT) - (SELECT SUM(EXPENSE_AMOUNT) FROM EXPENSE_DATA e WHERE e.DATE_PERIOD = r.DATE_PERIOD)) / SUM(REVENUE_AMOUNT) * 100
        ELSE 0 
    END AS PROFIT_MARGIN_PCT
FROM REVENUE_DATA r
WHERE REVENUE_AMOUNT IS NOT NULL
GROUP BY DATE_PERIOD
ORDER BY DATE_PERIOD;

CREATE OR REPLACE VIEW DEPARTMENT_REVENUE_SUMMARY AS
SELECT 
    DEPARTMENT,
    DATE_PERIOD,
    SUM(REVENUE_AMOUNT) AS DEPARTMENT_REVENUE,
    SUM(FORECAST_AMOUNT) AS DEPARTMENT_FORECAST
FROM REVENUE_DATA
GROUP BY DEPARTMENT, DATE_PERIOD
ORDER BY DATE_PERIOD, DEPARTMENT;

CREATE OR REPLACE VIEW EXPENSE_CATEGORY_SUMMARY AS
SELECT 
    EXPENSE_CATEGORY,
    DATE_PERIOD,
    SUM(EXPENSE_AMOUNT) AS CATEGORY_EXPENSES,
    SUM(BUDGET_AMOUNT) AS CATEGORY_BUDGET,
    SUM(EXPENSE_AMOUNT) - SUM(BUDGET_AMOUNT) AS BUDGET_VARIANCE
FROM EXPENSE_DATA
GROUP BY EXPENSE_CATEGORY, DATE_PERIOD
ORDER BY DATE_PERIOD, EXPENSE_CATEGORY;

-- Grant permissions (adjust as needed for your Snowflake setup)
GRANT USAGE ON DATABASE FINANCIAL_DEMO TO PUBLIC;
GRANT USAGE ON SCHEMA FINANCIAL_DEMO.ANALYTICS TO PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA FINANCIAL_DEMO.ANALYTICS TO PUBLIC;
GRANT SELECT ON ALL VIEWS IN SCHEMA FINANCIAL_DEMO.ANALYTICS TO PUBLIC;

SELECT 'Financial demo data setup completed successfully!' as STATUS; 