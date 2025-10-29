# Invoice Entity Resolution Demo

A Snowflake-powered application that helps you make informed negotiation decisions by comparing new purchase orders against historical invoice data using AI and semantic search.

## Overview

This project demonstrates how to:
- Extract line items from PDF purchase orders using Snowflake's AI_EXTRACT
- Search historical invoice data using Cortex Search with time decay
- Provide negotiation recommendations based on unit price comparisons
- Display historical invoice PDFs for detailed analysis

## Components

### 1. Historical Invoice Processing (`final_demo/HISTORICAL_INVOICE_PROCESSING.ipynb`)
- Processes hundreds of historical invoice PDFs using AI_EXTRACT
- Extracts customer info, line items, and pricing data
- Creates a Cortex Search Service for semantic product matching
- Sets up the foundation for negotiation analysis

### 2. Quote Negotiation Analyzer (`clean_streamlit_with_pdf_viewer.py`)
- Streamlit web application for analyzing new purchase orders
- Uploads and extracts data from quote PDFs
- Compares against historical invoices using semantic search
- Provides negotiation recommendations based on unit price analysis
- Displays historical invoice PDFs with download capabilities

## Key Features

- **AI-Powered PDF Extraction**: Uses Snowflake's native AI_EXTRACT function
- **Semantic Search**: Finds similar products using Cortex Search
- **Time Decay**: Prioritizes recent invoices for current market insights
- **Unit Price Analysis**: Compares unit prices rather than total amounts
- **PDF Visualization**: View and download historical invoices
- **Clean UI**: Business-friendly interface for non-technical users

## Prerequisites

- Snowflake account with Cortex AI features enabled
- Historical invoice PDFs stored in Snowflake stage `INVOICE_DOCUMENTS`
- Cortex Search Service `Invoice_Product_Search` configured

## Setup

To start this project, I created two Stages in my Database (DEMODB) and Schema (INVOICE_ANALYSIS).

These stages were named `INVOICE_DOCUMENTS` and `PDF_STAGE`. In `INVOICE_DOCUMENTS`, I uploaded the example invoices to perform the historical analysis on them.

Both stages are required to have a directory table enabled and Snowflake SSE Encryption.

### Creating the Stages

```sql
-- Create INVOICE_DOCUMENTS stage for historical invoices
CREATE OR REPLACE STAGE DEMODB.INVOICE_ANALYSIS.INVOICE_DOCUMENTS
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
  DIRECTORY = (ENABLE = TRUE);

-- Create PDF_STAGE for new quote uploads
CREATE OR REPLACE STAGE DEMODB.INVOICE_ANALYSIS.PDF_STAGE
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
  DIRECTORY = (ENABLE = TRUE);
```

## Usage

1. **Set up historical data**: Run the notebook to process historical invoices
2. **Launch the app**: Run the Streamlit application in Snowflake
3. **Upload quote**: Upload a new purchase order PDF
4. **Review recommendations**: Analyze negotiation suggestions for each line item
5. **Download invoices**: Access historical invoices for detailed comparison

## Data Flow

```
Purchase Order PDF → AI_EXTRACT → Line Items → Cortex Search → Historical Matches → Negotiation Analysis
```

## Technical Stack

- **Snowflake**: Data platform and AI functions
- **Streamlit**: Web application framework
- **Cortex Search**: Semantic search with time decay
- **AI_EXTRACT**: PDF data extraction
- **Python**: Application logic and data processing

## Files

- `quote_negotiation_analyzer.py` - Main Streamlit application
- `final_demo/HISTORICAL_INVOICE_PROCESSING.ipynb` - Historical data processing
- `requirements.txt` - Python dependencies
- `README.md` - This file

## Getting Started

1. Process your historical invoices using the notebook
2. Ensure your Cortex Search Service is configured
3. Run the Streamlit app in your Snowflake environment
4. Upload a purchase order PDF to start analyzing

---

*This demo showcases Snowflake's AI capabilities for real-world procurement and negotiation use cases.*
