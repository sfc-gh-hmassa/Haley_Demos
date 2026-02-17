# AI_EXTRACT Fine-Tuning Demo: Safety Data Sheet Extraction

Extract **both scalar values AND tables** from PDF documents using Snowflake's AI_EXTRACT, then fine-tune for improved accuracy.

## Demo Flow

| Part | Description |
|------|-------------|
| **Part 1** | Basic AI_EXTRACT - Extract scalar fields + tables (no fine-tuning) |
| **Part 2** | Create training dataset with ground truth (scalar + table examples) |
| **Part 3** | Fine-tune arctic-extract model *(skip if model exists)* |
| **Part 4** | Use fine-tuned model for better accuracy |

## What Gets Extracted

**Scalar Fields:** Product name, Manufacturer, Signal word, pH value

**Tables:** Hazardous ingredients (name, CAS#, %), Physical properties (property, value)

---

## Quick Start

### 1. Create Stage & Upload PDFs
```sql
CREATE STAGE SDS_DOCS ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE') DIRECTORY = (ENABLE = TRUE);
-- Upload PDFs from sample_data/ to @SDS_DOCS/sds/
ALTER STAGE SDS_DOCS REFRESH;
```

### 2. Run the Notebook
Import `AI_Extract_SDS_Fine_Tune_Demo.ipynb` into Snowsight and execute cells in order.

**Note:** Part 4 uses the fine-tuned model `DEMODB.PUBLIC.SDS_TABLE_EXTRACT`. Update the model name if using a different database/schema.

---

## Training Data Format

**Prompt** (JSON Schema):
```json
{
    "schema": {
        "type": "object",
        "properties": {
            "product_name": { "type": "string", "$comment": "Product name" },
            "hazardous_ingredients": {
                "type": "object",
                "properties": {
                    "ingredient_name": { "type": "array", "items": { "type": "string" } },
                    "cas_number": { "type": "array", "items": { "type": "string" } }
                }
            }
        }
    }
}
```

**Response** (ground truth - column-based arrays for tables):
```json
{
    "product_name": "Clorox Bleach",
    "hazardous_ingredients": {
        "ingredient_name": ["Sodium hypochlorite", "Sodium hydroxide"],
        "cas_number": ["7681-52-9", "1310-73-2"]
    }
}
```

---

## Files

```
AI_Extract_SDS_Demo/
├── README.md
├── AI_Extract_SDS_Fine_Tune_Demo.ipynb
├── setup.sql
└── sample_data/
    ├── US001066-Clorox-Regular-Bleach1_3.pdf
    ├── Clorox-Commercial-Solutions®-Clorox®-Disinfecting-Wipes-Fresh-Scent.pdf
    └── SDS-US-Formula-409®-Multi-Surface-Cleaner-English-2022.pdf
```

---

## Troubleshooting

| Error | Solution |
|-------|----------|
| Stage encryption error | Use `ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')` |
| Model unavailable | Wait for fine-tuning (check `FINETUNE('SHOW')`) |
| Model already exists | Change model name in Part 3 or skip that cell |
| Empty strings in array | Use `"None"` instead of `""` for missing values |

---

## Resources

- [AI_EXTRACT Docs](https://docs.snowflake.com/en/sql-reference/functions/ai_extract)
- [Cortex Fine-Tuning](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-finetuning)
