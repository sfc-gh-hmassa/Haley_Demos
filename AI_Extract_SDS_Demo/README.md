# AI_EXTRACT Fine-Tuning Demo: Safety Data Sheet Extraction

Extract **both scalar values AND tables** from PDF documents using Snowflake's AI_EXTRACT, then fine-tune for improved accuracy.

## Demo Flow

| Part | Description |
|------|-------------|
| **Part 1** | Basic AI_EXTRACT - Extract scalar fields + tables (no fine-tuning) |
| **Part 2** | Create training dataset with ground truth (scalar + table examples) |
| **Part 3** | Fine-tune arctic-extract model |
| **Part 4** | Use fine-tuned model for better accuracy |

## What Gets Extracted

**Scalar Fields:**
- Product name
- Manufacturer
- Signal word (Danger/Warning/None)
- pH value

**Tables:**
- Hazardous ingredients (ingredient, CAS#, %)
- Physical properties (property, value)

---

## Quick Start

### 1. Upload Files
Upload the sample PDFs from `sample_data/` to your Snowflake stage:
```sql
CREATE STAGE SDS_DOCS ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE') DIRECTORY = (ENABLE = TRUE);
-- Upload PDFs to @SDS_DOCS/sds/
ALTER STAGE SDS_DOCS REFRESH;
```

### 2. Run the Notebook
Import `AI_Extract_SDS_Fine_Tune_Demo.ipynb` into Snowsight and execute cells in order.

---

## Training Data Format

Each training example includes **both** scalar and table fields:

```json
{
    "schema": {
        "type": "object",
        "properties": {
            "product_name": { "type": "string", "$comment": "Product name" },
            "signal_word": { "type": "string", "$comment": "GHS signal word" },
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

**Response format** (ground truth):
```json
{
    "product_name": "Clorox Bleach",
    "signal_word": "Danger",
    "hazardous_ingredients": {
        "ingredient_name": ["Sodium hypochlorite", "Sodium hydroxide"],
        "cas_number": ["7681-52-9", "1310-73-2"]
    }
}
```

> **Key**: Tables use column-based arrays where each column is an array of values.

---

## Files

```
AI_Extract_SDS_Demo/
├── README.md                              # This file
├── AI_Extract_SDS_Fine_Tune_Demo.ipynb   # Main demo notebook
├── setup.sql                              # Standalone SQL script
└── sample_data/
    ├── Clorox-Disinfecting-Wipes.pdf
    ├── Formula-409-Multi-Surface.pdf
    └── Clorox-Regular-Bleach.pdf
```

---

## Troubleshooting

| Error | Solution |
|-------|----------|
| Stage encryption error | Use `ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')` |
| Model unavailable | Wait for fine-tuning to complete (check with `FINETUNE('SHOW')`) |
| Empty strings in array | Use `"None"` instead of `""` for missing values |

---

## Resources

- [AI_EXTRACT Docs](https://docs.snowflake.com/en/sql-reference/functions/ai_extract)
- [Cortex Fine-Tuning](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-finetuning)
