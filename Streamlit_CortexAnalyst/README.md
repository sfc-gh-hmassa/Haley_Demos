# Financial Analytics Dashboard with Cortex Analyst

A comprehensive Streamlit dashboard for financial analysis and forecasting with integrated Snowflake Cortex Analyst for natural language querying.

## 🎯 Features

### Dashboard Components
- **Executive Summary Cards**: Key financial metrics with target comparisons
- **Revenue Trend Analysis**: Actual vs forecasted revenue visualization
- **Expense Breakdown**: Categorized expense analysis with pie charts
- **Department Performance**: Multi-metric department comparison
- **Monthly Forecasting**: 6-month revenue projection charts

### Cortex Analyst Integration
- **Natural Language Queries**: Ask questions in plain English
- **Automatic SQL Generation**: Powered by Snowflake Cortex Analyst
- **Interactive Chat Interface**: Persistent conversation history
- **Quick Question Buttons**: Pre-built common financial queries
- **Data Visualization**: Auto-generated charts from query results

## 📊 Data Model

The dashboard uses four main data tables:

1. **REVENUE_DATA**: Revenue by department, region, and product category
2. **EXPENSE_DATA**: Operating expenses with budget comparisons
3. **FINANCIAL_METRICS**: KPIs like growth rate, profit margin, CAC
4. **DEPARTMENT_PERFORMANCE**: Department-level metrics and productivity scores

## 🚀 Setup Instructions

### Prerequisites
- Snowflake account with Cortex Analyst enabled
- Python 3.8 or higher

### 1. Database Setup

1. **Run the SQL script** in your Snowflake account:
   ```bash
   # Execute financial_data.sql in your Snowflake worksheet
   # This creates the FINANCIAL_DEMO database with sample data
   ```

2. **Upload the Cortex Analyst configuration**:
   ```sql
   -- Upload cortex_analyst_config.yaml to your Snowflake stage
   PUT file://cortex_analyst_config.yaml @~/cortex_analyst_config.yaml;
   ```

### 3. Snowflake Deployment

####  Streamlit in Snowflake (Recommended)

1. **Upload files to Snowflake stage**:
   ```sql
   -- Create a stage for the app files
   CREATE STAGE IF NOT EXISTS streamlit_stage;
   
   -- Upload the files
   PUT file://streamlit_app.py @streamlit_stage/streamlit_app.py;
   PUT file://cortex_analyst_config.yaml @streamlit_stage/cortex_analyst_config.yaml;
   ```

2. **Create the Streamlit app**:
   ```sql
   CREATE STREAMLIT FINANCIAL_DASHBOARD
     ROOT_LOCATION = '@streamlit_stage'
     MAIN_FILE = 'streamlit_app.py'
     QUERY_WAREHOUSE = 'COMPUTE_WH';
   ```

3. **Grant permissions**:
   ```sql
   GRANT USAGE ON STREAMLIT FINANCIAL_DASHBOARD TO ROLE PUBLIC;
   ```

## 💡 Usage Examples

### Dashboard Navigation
- **Left Panel (2/3)**: Interactive financial charts and metrics
- **Right Panel (1/3)**: Cortex Analyst chat interface

### Sample Queries for Cortex Analyst
- "What was our total revenue in Q3 2024?"
- "Show me the revenue trend for the last 12 months"
- "Which department has the highest profit margin?"
- "What are our biggest expense categories?"
- "How accurate were our revenue forecasts this year?"
- "Compare actual vs budgeted expenses by department"

### Quick Actions
- **Revenue Analysis**: Click "💰 Q3 Revenue" for instant revenue breakdown
- **Expense Review**: Click "📊 Top Expenses" for expense category analysis
- **Growth Metrics**: Click "📈 Growth Rate" for growth rate trends

## 📈 Key Metrics Tracked

### Financial KPIs
- **Revenue Growth Rate**: Month-over-month revenue growth
- **Profit Margin**: Net profit as percentage of revenue  
- **Operating Expense Ratio**: Expenses as percentage of revenue
- **Customer Acquisition Cost**: Cost to acquire new customers

### Department Metrics
- **Revenue per Department**: Department revenue contribution
- **Expense Efficiency**: Department expense management
- **Productivity Score**: Department performance rating
- **Employee Count**: Staffing levels by department

## 🎨 Customization

### Adding New Metrics
1. **Update SQL data**: Add new columns to existing tables
2. **Modify YAML config**: Add new measures to Cortex Analyst
3. **Update dashboard**: Add new visualization components

### Styling Changes
- **CSS customization**: Modify the `st.markdown()` CSS in `streamlit_app.py`
- **Chart themes**: Update Plotly chart configurations
- **Color schemes**: Adjust color palettes in visualization functions

## 🔍 Troubleshooting

### Common Issues

1. **Snowflake Connection Errors**:
   - Verify credentials in `secrets.toml`
   - Check network connectivity and firewall settings
   - Ensure warehouse is running

2. **Cortex Analyst Not Working**:
   - Verify Cortex Analyst is enabled in your Snowflake account
   - Check YAML configuration file syntax
   - Ensure proper permissions for Cortex functions

3. **Data Loading Issues**:
   - Run the `financial_data.sql` script completely
   - Verify table permissions
   - Check data freshness and caching

### Performance Optimization
- **Data Caching**: Streamlit caches data for 5 minutes by default
- **Query Optimization**: Use appropriate filters and limits
- **Warehouse Sizing**: Scale warehouse for better performance

## 📞 Support

For issues related to:
- **Snowflake Setup**: Check Snowflake documentation
- **Cortex Analyst**: Review Cortex Analyst guides
- **Streamlit Deployment**: Visit Streamlit documentation

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Streamlit     │    │   Snowflake     │    │ Cortex Analyst  │
│   Dashboard     │◄──►│   Database      │◄──►│   Engine        │
│                 │    │                 │    │                 │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ • Visualizations│    │ • Financial Data│    │ • NL to SQL     │
│ • User Interface│    │ • Data Models   │    │ • Query Gen     │
│ • Chat Interface│    │ • Views/Tables  │    │ • Explanations  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📊 Sample Data Overview

The demo includes 24 months of financial data across:
- **3 Departments**: Sales, Marketing, Operations
- **4 Expense Categories**: Salaries, Marketing, Office Rent, Technology
- **2 Regions**: North America, Europe  
- **3 Product Categories**: Software, Services, Hardware
- **6 Months of Forecasts**: Future revenue projections

This provides a rich dataset for comprehensive financial analysis and CDO evaluation scenarios. 
