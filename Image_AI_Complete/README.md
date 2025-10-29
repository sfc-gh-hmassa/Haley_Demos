# Snowflake AI Complete: Image Analysis and Entity Extraction

This project demonstrates how to use Snowflake's AI Complete with multimodal capabilities to analyze a knowledge graph image and generate SQL code for extracting entities in star schema format.

## Files Overview

- `snowflake_ai_complete_image_analysis.ipynb` - Jupyter notebook with Python implementation
- `snowflake_ai_complete_image_analysis.sql` - Pure SQL implementation
- `knowledge_graph.jpg` - Sample knowledge graph image for analysis

## Prerequisites

1. **Snowflake Account**: Access to a Snowflake account with AI Complete enabled
2. **OpenAI Integration**: Snowflake AI Complete must be configured with OpenAI
3. **Permissions**: ACCOUNTADMIN role or equivalent permissions
4. **Python Environment**: For the Jupyter notebook approach
   - `snowflake-connector-python`
   - `PIL` (Pillow)
   - `requests`

## Quick Start

### Option 1: Jupyter Notebook (Python)

1. Update connection parameters in the notebook:
   ```python
   SNOWFLAKE_ACCOUNT = 'your_account.snowflakecomputing.com'
   SNOWFLAKE_USER = 'your_username'
   SNOWFLAKE_PASSWORD = 'your_password'
   # ... other parameters
   ```

2. Upload the `knowledge_graph.jpg` file to your Snowflake stage
3. Run the notebook cells sequentially

### Option 2: Pure SQL

1. Update the context in the SQL file:
   ```sql
   USE WAREHOUSE YOUR_WAREHOUSE;
   USE DATABASE YOUR_DATABASE;
   USE SCHEMA YOUR_SCHEMA;
   ```

2. Upload the image to the stage:
   ```sql
   PUT file:///path/to/knowledge_graph.jpg @knowledge_graph_stage
       AUTO_COMPRESS = FALSE
       OVERWRITE = TRUE;
   ```

3. Execute the AI Complete query to generate SQL
4. Copy and execute the generated SQL

## Workflow

1. **Setup**: Create Snowflake stage for image storage
2. **Upload**: Upload knowledge graph image to stage
3. **Analyze**: Use AI Complete to analyze the image with custom prompts
4. **Generate**: AI generates SQL DDL for star schema creation
5. **Execute**: Run the generated SQL to create tables and relationships
6. **Verify**: Validate the created schema structure

## Key Features

- **Multimodal AI Analysis**: Analyzes both text and images
- **Custom Prompting**: Tailored prompts for specific business requirements
- **Code Generation**: AI-generated SQL DDL for database schema creation
- **Star Schema Design**: Proper data warehouse design patterns
- **Error Handling**: Robust error handling and validation
- **Schema Verification**: Automated verification of created database objects

## Customization

### Modifying the AI Prompt

You can customize the analysis by modifying the prompt in either approach:

```python
# Python approach
analysis_prompt = """
Your custom prompt here...
"""
```

```sql
-- SQL approach
'text', 'Your custom prompt here...'
```

### Adding More Image Types

The current implementation supports JPEG images. To support other formats:

1. Update the MIME type in the base64 encoding
2. Modify the file extension in the stage operations
3. Ensure the AI model supports the image format

## Troubleshooting

### Common Issues

1. **Connection Errors**: Verify Snowflake credentials and network access
2. **AI Complete Errors**: Ensure OpenAI integration is properly configured
3. **Image Upload Issues**: Check file permissions and stage configuration
4. **SQL Execution Errors**: Review generated SQL for syntax issues

### Debugging Tips

1. Enable debug logging in the Python connector
2. Check Snowflake query history for AI Complete calls
3. Verify image data integrity before AI analysis
4. Test with smaller images if experiencing timeouts

## Security Considerations

- Store credentials securely (use environment variables or key management)
- Limit AI Complete access to necessary users only
- Review generated SQL before execution in production
- Consider data privacy implications of image analysis

## Performance Optimization

- Use appropriate warehouse sizes for AI Complete operations
- Consider image compression for large files
- Implement caching for repeated analyses
- Monitor query performance and costs

## Next Steps

1. Test with your own knowledge graph images
2. Customize prompts for your specific domain
3. Implement data validation and constraints
4. Add sample data loading procedures
5. Create monitoring and alerting for the process

## Support

For issues related to:
- Snowflake AI Complete: Check Snowflake documentation
- OpenAI Integration: Review Snowflake AI Complete setup guide
- Image Processing: Verify file formats and sizes
- SQL Generation: Review and modify prompts as needed
