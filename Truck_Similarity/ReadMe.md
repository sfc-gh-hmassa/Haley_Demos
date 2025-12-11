# Quote-to-Project Matching with Snowflake Cortex Multi-Index Search

Match incoming repair quotes to similar historical projects using hybrid text + vector search.

## Overview

This demo shows how to use **Snowflake Cortex Search Multi-Index** to find the best matching historical repair projects for new quotes. It combines:

- **Text Search** (BM25) - Keyword/lexical matching for exact terms
- **Vector Search** (Embeddings) - Semantic similarity for meaning-based matching

## Files

| File | Description |
|------|-------------|
| `quote_project_matching.ipynb` | Snowflake Notebook - Creates search service and runs batch matching |
| `streamlit_quote_validator.py` | Streamlit in Snowflake app for interactive search |
| `JIRA_SEARCH_DEMO (1).ipynb` | Reference example for JIRA ticket matching |
| `jira_app_two.py` | Reference Streamlit app with detailed scoring |

## How It Works

### 1. Multi-Index Search Service

```sql
CREATE OR REPLACE CORTEX SEARCH SERVICE quote_project_search
TEXT INDEXES (description, vendor, part_type)      -- Keyword matching
VECTOR INDEXES (description)                        -- Semantic matching
ATTRIBUTES (project_id, manager, department, price)
...
```

- `description` is in **BOTH** TEXT and VECTOR indexes for hybrid search
- `vendor` and `part_type` are TEXT only for exact matching

### 2. Multi-Index Query

```python
search_query = {
    "multi_index_query": {
        "description": [{"text": quote_description}],
        "vendor": [{"text": quote_vendor}],
        "part_type": [{"text": quote_part_type}]
    },
    "columns": ["project_id", "description", "vendor", "part_type", "price"],
    "limit": 5
}
```

### 3. Score Calculation

Cortex returns two component scores:

| Score | Description | Range |
|-------|-------------|-------|
| `text_match` | BM25 keyword similarity | 0 to ~2+ |
| `cosine_similarity` | Semantic vector similarity | 0 to 1 |

**Simple formula (no scoring_config):**
```
SCORE = (text_match + cosine_similarity) / 2
```

**With custom weights:**
```
SCORE = (text_match × text_weight + cosine_similarity × vector_weight) / total_weight
```


## Setup

### Prerequisites

- Snowflake account with Cortex Search enabled
- Database with `projects` and `quotes` tables
- Warehouse for search service

### Expected Table Structure

**projects** (historical repair records):
```sql
CREATE TABLE projects (
    project_id VARCHAR,
    description TEXT,
    vendor VARCHAR,
    part_type VARCHAR,
    department VARCHAR,
    manager VARCHAR,
    start_date DATE,
    price FLOAT
);
```

**quotes** (incoming quotes to match):
```sql
CREATE TABLE quotes (
    quote_id VARCHAR,
    description TEXT,
    vendor VARCHAR,
    part_type VARCHAR,
    quote_date DATE
);
```

### Running the Notebook

1. Open `quote_project_matching.ipynb` in Snowflake Notebooks
2. Run Step 1-3 to set up database and create search service
3. Wait ~1 minute for service to index data
4. Run Step 4+ to batch search and analyze results

### Running the Streamlit App

1. Create a Streamlit in Snowflake app
2. Upload `streamlit_quote_validator.py`
3. Update the search service name if needed:
   ```python
   'TRUCKING_DEMO.DEMO.TRUCKING_PROJECTS_MULTI_SEARCH'
   ```
4. Run the app

## Streamlit App Features

- **Search by Quote ID(s)** - Enter specific quote IDs to find matches
- **Search All Quotes** - Batch process all quotes in the database
- **Free-form Text Search** - Enter any description to find similar projects

## Customizing Weights

To emphasize semantic similarity over keywords:
```python
"scoring_config": {
    "weights": {"texts": 1, "vectors": 3, "reranker": 1}
}
```

To emphasize exact keyword matching:
```python
"scoring_config": {
    "weights": {"texts": 3, "vectors": 1, "reranker": 1}
}
```

## Resources

- [Snowflake Cortex Search Docs](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview)
- [Multi-Index Search Docs](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/query-cortex-search-service#multi-index-search)


