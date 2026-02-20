# Fine-Tuned Embedding Search Demo

Fine-tune a custom embedding model for JIRA ticket search using Snowflake ML Jobs, Model Registry, and Cortex Search with BYO Embeddings.

## What This Demo Shows

1. **ML Jobs** - Train a SentenceTransformer model on GPU compute pools
2. **Model Registry** - Version and deploy custom models with `CustomModel` wrapper
3. **SPCS Inference** - Deploy model as auto-suspending service for embeddings
4. **Cortex Search BYO** - Use your own embeddings with Cortex Search

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   ML Job #1     │     │   ML Job #2     │     │  SPCS Service   │
│   Fine-tune     │ ──► │   Log Model     │ ──► │   Inference     │
│   on GPU        │     │   to Registry   │     │   (auto-suspend)│
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │                       │
        ▼                       ▼                       ▼
   Job Stage              Model Registry          Cortex Search
   (model artifacts)      (JIRA_EMBEDDER)        (BYO Embedding)
```

## Prerequisites

- Snowflake account with:
  - GPU compute pool access (GPU_NV_S)
  - ACCOUNTADMIN or equivalent privileges
  - External network access enabled

## Quick Start

### 1. Run Setup Script

```sql
-- In Snowsight SQL Worksheet
!source setup.sql
```

Or copy/paste `setup.sql` contents into a SQL worksheet and execute.

### 2. Upload Notebook

```bash
# Using SnowCLI
snow stage copy jira_embedding_finetuning_demo.ipynb "@JIRA_EMBEDDING_DEMO.PUBLIC.NOTEBOOKS/" --overwrite

# Create notebook
snow sql -q "
CREATE NOTEBOOK JIRA_EMBEDDING_DEMO.PUBLIC.JIRA_FINETUNING_DEMO
    FROM '@JIRA_EMBEDDING_DEMO.PUBLIC.NOTEBOOKS'
    MAIN_FILE = 'jira_embedding_finetuning_demo.ipynb'
    QUERY_WAREHOUSE = 'JIRA_DEMO_WH';

ALTER NOTEBOOK JIRA_EMBEDDING_DEMO.PUBLIC.JIRA_FINETUNING_DEMO 
SET EXTERNAL_ACCESS_INTEGRATIONS = ('ALLOW_ALL_EAI');
"
```

### 3. Run the Notebook

Open `JIRA_FINETUNING_DEMO` in Snowsight and run cells in order.

**Timing:**
- Training job: ~5-10 minutes
- Model logging job: ~3-5 minutes  
- Service creation (first time): ~10-20 minutes (image build)
- Embedding generation: ~1-2 minutes

## Files

| File | Description |
|------|-------------|
| `setup.sql` | Creates database, compute pool, sample data |
| `jira_embedding_finetuning_demo.ipynb` | Main demo notebook |
| `README.md` | This file |

## Key Concepts

### Training Pairs (Contrastive Learning)

The model learns similarity via `MultipleNegativesRankingLoss`:
- **Anchor**: Ticket summary
- **Positive**: Summary + description of similar ticket (same issue type)
- **Negatives**: Other tickets in batch (implicit)

This teaches domain-specific similarity:
- "Login timeout" ↔ "SSO authentication failure" (both AUTH bugs)
- "Add dark mode" ↔ "Implement theme toggle" (both UI features)

### CustomModel Wrapper

SentenceTransformer isn't natively supported, so we wrap it:

```python
class JiraEmbedder(custom_model.CustomModel):
    @custom_model.inference_api
    def encode(self, input_df: pd.DataFrame) -> pd.DataFrame:
        texts = input_df["text"].tolist()
        embeddings = self.model.encode(texts)
        return pd.DataFrame({"embedding": [emb.tolist() for emb in embeddings]})
```

### Service vs run_batch

| Approach | Use When |
|----------|----------|
| `create_service()` + `run()` | Recurring inference, search service |
| `run_batch()` | One-off large batch jobs |

Services auto-suspend when idle - no manual cleanup needed.

### Cortex Search BYO Embedding

```sql
CREATE CORTEX SEARCH SERVICE JIRA_SEARCH
    TEXT INDEXES (SUMMARY)           -- keyword search
    VECTOR INDEXES (EMBEDDING_COL)   -- your pre-computed vectors
    ATTRIBUTES ISSUE_TYPE, PRIORITY
    ...
```

## Cleanup

```sql
-- Delete service when completely done
-- (auto-suspends when idle, so usually not needed)
ALTER SERVICE JIRA_EMBEDDER_SVC SUSPEND;

-- Or full cleanup
DROP DATABASE JIRA_EMBEDDING_DEMO;
DROP COMPUTE POOL JIRA_TRAINING_POOL;
```

## Troubleshooting

**"Compute pool busy"**
- The service is using the only node
- Wait for auto-suspend, or: `ALTER SERVICE JIRA_EMBEDDER_SVC SUSPEND;`

**"Service already exists"**
- The notebook handles this - it reuses existing services

**"VECTOR type in VALUES clause"**
- Use `INSERT ... SELECT` instead of `INSERT ... VALUES` for VECTOR columns

## Resources

- [ML Jobs Documentation](https://docs.snowflake.com/developer-guide/snowflake-ml/ml-jobs/overview)
- [Model Registry Overview](https://docs.snowflake.com/en/developer-guide/snowflake-ml/model-registry/overview)
- [Cortex Search](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview)
- [Official LLM Fine-Tuning Sample](https://github.com/Snowflake-Labs/sf-samples/tree/main/samples/ml/ml_jobs/llm_finetune)
