# Custom Clustering Models with Snowflake Model Registry

Build and deploy custom AI clustering models that work with `AI_EMBED` embeddings. This demo shows how to register models in the Model Registry and run them on both **Warehouse** and **SPCS** runtimes.

## What's Included

| Model | Algorithm | Runtime | Use Case |
|-------|-----------|---------|----------|
| `AI_CLUSTER_KMEANS` | K-Means | Warehouse (TABLE_FUNCTION) | Group into specified number of clusters |
| `AI_CLUSTER_DEEP` | HDBSCAN | SPCS (Batch Jobs) | Auto-discover clusters + outliers |

## Prerequisites

### 1. Compute Pool (for SPCS models)

Create a compute pool for running SPCS batch inference jobs:

```sql
CREATE COMPUTE POOL IF NOT EXISTS MLOPS_COMPUTE_POOL
    MIN_NODES = 1
    MAX_NODES = 3
    INSTANCE_FAMILY = CPU_X64_S
    AUTO_RESUME = TRUE
    AUTO_SUSPEND_SECS = 300;
```

### 2. External Access Integration (for pip packages)

SPCS models using pip packages need external access to PyPI:

```sql
-- Create network rule for PyPI
CREATE OR REPLACE NETWORK RULE PYPI_NETWORK_RULE
    MODE = EGRESS
    TYPE = HOST_PORT
    VALUE_LIST = ('pypi.org', 'files.pythonhosted.org', 'pypi.python.org');

-- Create external access integration
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION PYPI_ACCESS_INTEGRATION
    ALLOWED_NETWORK_RULES = (PYPI_NETWORK_RULE)
    ENABLED = TRUE;

-- Grant usage (if needed for other roles)
GRANT USAGE ON INTEGRATION PYPI_ACCESS_INTEGRATION TO ROLE <your_role>;
```

### 3. Stage for Output

Create a stage to store batch inference results:

```sql
CREATE STAGE IF NOT EXISTS MY_DB.MY_SCHEMA.NOTEBOOKS
    DIRECTORY = (ENABLE = TRUE);
```

### 4. Notebook Setup

When creating or importing the notebook, ensure these settings:

- **Query Warehouse**: Any warehouse (e.g., `COMPUTE_WH`)
- **External Access Integrations**: Add `PYPI_ACCESS_INTEGRATION`
- **Packages**: The notebook will `pip install` required packages

## Key Concepts

### Model Registry Runtimes

| Runtime | Package Source | Best For |
|---------|---------------|----------|
| **Warehouse** | Anaconda (1000+ curated) | TABLE_FUNCTION, instant scaling |
| **SPCS Batch** | PyPI (full access) | pip packages, GPUs, large-scale |

### Batch Inference Jobs (`run_batch`)

For SPCS models, use `run_batch()` instead of inference services:

```python
from snowflake.ml.model._client.model.batch_inference_specs import OutputSpec, SaveMode

job = mv.run_batch(
    compute_pool="MLOPS_COMPUTE_POOL",
    X=input_dataframe,
    output_spec=OutputSpec(
        stage_location="@my_stage/output/",
        mode=SaveMode.OVERWRITE
    )
)

job.wait()
results = session.read.parquet("@my_stage/output/")
```

**Benefits:**
- Compute spins up only when needed
- Auto-terminates after completion
- No persistent service to manage
- Handles millions of rows efficiently

### Embedding Format

Models expect embeddings as JSON strings:

```sql
TO_JSON(AI_EMBED('snowflake-arctic-embed-l-v2.0', text_column)::ARRAY) AS EMBEDDING
```

## Documentation Links

- [Model Registry Overview](https://docs.snowflake.com/en/developer-guide/snowflake-ml/model-registry/overview)
- [Custom Models](https://docs.snowflake.com/en/developer-guide/snowflake-ml/model-registry/custom-models)
- [Batch Inference Jobs](https://docs.snowflake.com/en/developer-guide/snowflake-ml/model-registry/run-batch-inference)
- [Inference on SPCS](https://docs.snowflake.com/en/developer-guide/snowflake-ml/model-registry/container-runtime)
- [External Access Integrations](https://docs.snowflake.com/en/developer-guide/external-network-access/creating-using-external-network-access)
- [Compute Pools](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-compute-pool)
- [AI_EMBED Function](https://docs.snowflake.com/en/sql-reference/functions/ai_embed)

## Quick Start

1. Run prerequisites SQL (compute pool, external access, stage)
2. Import `ai_cluster_walkthrough.ipynb` to Snowflake Notebooks
3. Add `PYPI_ACCESS_INTEGRATION` to notebook settings
4. Run all cells

## Files

| File | Description |
|------|-------------|
| `ai_cluster_walkthrough.ipynb` | Main demo notebook |
| `README.md` | This file |

## Troubleshooting

### "Module not found: hdbscan"
- Ensure `PYPI_ACCESS_INTEGRATION` is added to notebook external access settings
- Run the pip install cell first

### Batch job stuck in "PENDING"
- Check compute pool is running: `SHOW COMPUTE POOLS`
- First run builds container image (~2-3 min)

### Parquet file 0 bytes error
- Use exact filename from `LIST @stage/output/`
- Files have UUID names like `3_abc123_000000-0.parquet`

### OutputSpec import error
- Use: `from snowflake.ml.model._client.model.batch_inference_specs import OutputSpec, SaveMode`
- Not: `from snowflake.ml.model import OutputSpec`
