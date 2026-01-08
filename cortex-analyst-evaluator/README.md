# Cortex Analyst Evaluator

A framework for benchmarking and tracking the accuracy of your Cortex Analyst semantic models.

## What It Does

This evaluator runs test questions against your semantic model, executes both the expected SQL and the generated SQL, and compares the actual results. This gives you an objective measure of accuracy — if the results match, the answer is correct.

## Quick Start

### 1. Run the Setup Script

Open a Snowflake worksheet and run `setup_tables.sql`. Update the database name at the top:

```sql
USE DATABASE YOUR_DATABASE;  -- Change this
```

This creates:
- `EVAL_QUESTIONS` - Table for your test questions
- `EVAL_RESULTS` - Table to store run results  
- `EVAL_RUN_SUMMARY` - View for accuracy trends

### 2. Load Your Test Questions

**Option A: Use the SQL inserts** (included in setup_tables.sql)

**Option B: Load from CSV**
```sql
-- Create a stage and upload sample_questions.csv
CREATE STAGE IF NOT EXISTS eval_stage;
PUT file://sample_questions.csv @eval_stage;

-- Load the data
COPY INTO EVAL_QUESTIONS (question, expected_sql, description, category)
FROM @eval_stage/sample_questions.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');
```

### 3. Create the Notebook in Snowflake

1. Go to Snowsight → Notebooks
2. Create a new notebook in your evaluation schema
3. Copy the contents from `cortex_analyst_eval_notebook.ipynb`
4. Update the configuration cell with your semantic model path:

```python
SEMANTIC_MODEL_PATH = "@YOUR_DB.YOUR_SCHEMA.YOUR_STAGE/your_model.yaml"
EVAL_DATABASE = "YOUR_DB"
EVAL_SCHEMA = "YOUR_SCHEMA"
```

### 4. Run the Evaluation

Run all cells in the notebook. You'll see:
- Progress as each question is evaluated
- Summary metrics (pass/fail/accuracy)
- Detailed results for failed questions
- Historical accuracy trend

## Customizing Test Questions

Edit `sample_questions.csv` or insert directly:

```sql
INSERT INTO EVAL_QUESTIONS (question, expected_sql, description, category) 
VALUES (
    'What is total revenue for 2024?',
    'SELECT SUM(amount) FROM sales WHERE YEAR(date) = 2024',
    'Basic aggregation with date filter',
    'Aggregation'
);
```

### Question Categories

Use categories to organize and filter your tests:
- `Aggregation` - COUNT, SUM, AVG queries
- `Filters` - WHERE clause tests  
- `Joins` - Multi-table queries
- `Ranking` - ORDER BY, LIMIT, TOP queries
- `Time` - Date/time filtering and grouping

## How Comparison Works

```
Expected SQL → Execute → Result Set A ─┐
                                        ├─→ Compare → PASS/FAIL
Generated SQL → Execute → Result Set B ─┘
```

The comparison:
- Ignores column name differences
- Ignores row ordering (unless ORDER BY specified)
- Compares actual values

## Improving Your Semantic Model

Based on failures, consider:

1. **Wrong columns selected** → Add column descriptions
2. **Terminology mismatch** → Add synonyms  
3. **Filter values not recognized** → Add sample_values
4. **Complex calculations wrong** → Add verified queries (VQRs)
5. **Incorrect joins** → Add/fix relationships

Re-run the evaluator after each change to track improvement!

## Files

| File | Description |
|------|-------------|
| `setup_tables.sql` | Creates evaluation tables and loads sample data |
| `sample_questions.csv` | CSV template with example test questions |
| `cortex_analyst_eval_notebook.ipynb` | The evaluation notebook |

## Requirements

- Snowflake account with Cortex Analyst enabled
- A semantic model (YAML file on a stage)
- Snowflake Notebook access
