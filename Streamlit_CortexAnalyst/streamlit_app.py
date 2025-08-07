import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark.functions import col, sum as sum_, avg, count, max as max_, min as min_
import json
from datetime import datetime, timedelta
import numpy as np

# Page configuration
st.set_page_config(
    page_title="Financial Analytics Dashboard",
    page_icon="💰",
    layout="wide",
    initial_sidebar_state="collapsed"
)

# Custom CSS for better styling
st.markdown("""
<style>
    .main > div {
        padding-top: 2rem;
    }
    .metric-card {
        background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
        padding: 1rem;
        border-radius: 10px;
        color: white;
        text-align: center;
        margin: 0.5rem 0;
    }
    .chat-container {
        background-color: #f8f9fa;
        border-radius: 10px;
        padding: 1rem;
        height: 600px;
        overflow-y: auto;
        border: 1px solid #dee2e6;
    }
    .chat-message {
        margin: 0.5rem 0;
        padding: 0.75rem;
        border-radius: 8px;
        max-width: 100%;
        word-wrap: break-word;
    }
    .user-message {
        background-color: #007bff;
        color: white;
        margin-left: 20%;
    }
    .assistant-message {
        background-color: #e9ecef;
        color: #333;
        margin-right: 20%;
    }
    .sql-code {
        background-color: #f8f9fa;
        border: 1px solid #dee2e6;
        border-radius: 4px;
        padding: 0.5rem;
        font-family: 'Courier New', monospace;
        font-size: 0.85rem;
        margin: 0.5rem 0;
    }
</style>
""", unsafe_allow_html=True)

# Initialize session state for chat history
if 'messages' not in st.session_state:
    st.session_state.messages = []

# Get Snowflake session (automatically available in SiS)
@st.cache_resource
def get_snowflake_session():
    """Get the active Snowflake session in SiS"""
    return get_active_session()

# Data loading functions using Snowpark
@st.cache_data(ttl=300)  # Cache for 5 minutes
def load_financial_summary():
    """Load monthly financial summary data using Snowpark"""
    session = get_snowflake_session()
    
    try:
        # Use the view we created in the SQL setup
        df = session.table("MONTHLY_FINANCIAL_SUMMARY").limit(12).to_pandas()
        return df.sort_values('DATE_PERIOD', ascending=False)
    except Exception as e:
        st.error(f"Error loading financial summary: {str(e)}")
        return pd.DataFrame()

@st.cache_data(ttl=300)
def load_department_performance():
    """Load department performance data using Snowpark"""
    session = get_snowflake_session()
    
    try:
        df = session.table("DEPARTMENT_PERFORMANCE").filter(
            col("DATE_PERIOD") >= "2024-07-01"
        ).to_pandas()
        return df.sort_values(['DATE_PERIOD', 'DEPARTMENT'], ascending=[False, True])
    except Exception as e:
        st.error(f"Error loading department performance: {str(e)}")
        return pd.DataFrame()

@st.cache_data(ttl=300)
def load_expense_breakdown():
    """Load expense breakdown data using Snowpark"""
    session = get_snowflake_session()
    
    try:
        # Aggregate expenses by category for last 3 months
        df = session.table("EXPENSE_DATA").filter(
            col("DATE_PERIOD") >= "2024-10-01"
        ).group_by("EXPENSE_CATEGORY").agg(
            sum_("EXPENSE_AMOUNT").alias("TOTAL_EXPENSE"),
            sum_("BUDGET_AMOUNT").alias("TOTAL_BUDGET")
        ).to_pandas()
        
        df['VARIANCE'] = df['TOTAL_EXPENSE'] - df['TOTAL_BUDGET']
        return df.sort_values('TOTAL_EXPENSE', ascending=False)
    except Exception as e:
        st.error(f"Error loading expense breakdown: {str(e)}")
        return pd.DataFrame()

@st.cache_data(ttl=300)
def load_revenue_forecast():
    """Load revenue and forecast data using Snowpark"""
    session = get_snowflake_session()
    
    try:
        # Get revenue data for last 12 months + 6 months forecast
        df = session.table("REVENUE_DATA").filter(
            col("DATE_PERIOD") >= "2024-01-01"
        ).group_by("DATE_PERIOD").agg(
            sum_("REVENUE_AMOUNT").alias("ACTUAL_REVENUE"),
            sum_("FORECAST_AMOUNT").alias("FORECASTED_REVENUE")
        ).to_pandas()
        
        return df.sort_values('DATE_PERIOD')
    except Exception as e:
        st.error(f"Error loading revenue forecast: {str(e)}")
        return pd.DataFrame()

@st.cache_data(ttl=300)
def load_key_metrics():
    """Load key financial metrics using Snowpark"""
    session = get_snowflake_session()
    
    try:
        # Get latest metrics
        df = session.table("FINANCIAL_METRICS").filter(
            col("DATE_PERIOD") == "2024-12-01"
        ).to_pandas()
        
        metrics = {}
        for _, row in df.iterrows():
            metrics[row['METRIC_NAME']] = {
                'value': row['METRIC_VALUE'],
                'target': row['TARGET_VALUE']
            }
        return metrics
    except Exception as e:
        st.error(f"Error loading key metrics: {str(e)}")
        return {}

# Old functions removed - now using the GitHub example approach

# Dashboard visualization functions
def create_metric_cards(metrics_data):
    """Create metric cards for key financial indicators"""
    if not metrics_data:
        st.warning("No metrics data available")
        return
    
    col1, col2, col3, col4 = st.columns(4)
    
    # Revenue Growth Rate
    if 'Revenue Growth Rate' in metrics_data:
        growth_rate = metrics_data['Revenue Growth Rate']['value'] * 100
        target_growth = metrics_data['Revenue Growth Rate']['target'] * 100
        delta = growth_rate - target_growth
        
        with col1:
            st.metric(
                label="📈 Revenue Growth Rate",
                value=f"{growth_rate:.1f}%",
                delta=f"{delta:.1f}% vs target"
            )
    
    # Profit Margin
    if 'Profit Margin' in metrics_data:
        profit_margin = metrics_data['Profit Margin']['value'] * 100
        target_margin = metrics_data['Profit Margin']['target'] * 100
        delta = profit_margin - target_margin
        
        with col2:
            st.metric(
                label="💰 Profit Margin",
                value=f"{profit_margin:.1f}%",
                delta=f"{delta:.1f}% vs target"
            )
    
    # Operating Expense Ratio
    if 'Operating Expense Ratio' in metrics_data:
        expense_ratio = metrics_data['Operating Expense Ratio']['value'] * 100
        target_ratio = metrics_data['Operating Expense Ratio']['target'] * 100
        delta = expense_ratio - target_ratio
        
        with col3:
            st.metric(
                label="📊 Operating Expense Ratio",
                value=f"{expense_ratio:.1f}%",
                delta=f"{delta:.1f}% vs target",
                delta_color="inverse"
            )
    
    # Customer Acquisition Cost
    if 'Customer Acquisition Cost' in metrics_data:
        cac = metrics_data['Customer Acquisition Cost']['value']
        target_cac = metrics_data['Customer Acquisition Cost']['target']
        delta = cac - target_cac
        
        with col4:
            st.metric(
                label="🎯 Customer Acquisition Cost",
                value=f"${cac:,.0f}",
                delta=f"${delta:,.0f} vs target",
                delta_color="inverse"
            )

def create_revenue_trend_chart(df):
    """Create revenue trend chart with actual and forecast data"""
    if df.empty:
        st.warning("No revenue data available")
        return None
    
    fig = go.Figure()
    
    # Add actual revenue line
    actual_data = df[df['ACTUAL_REVENUE'].notna()]
    if not actual_data.empty:
        fig.add_trace(go.Scatter(
            x=actual_data['DATE_PERIOD'],
            y=actual_data['ACTUAL_REVENUE'],
            mode='lines+markers',
            name='Actual Revenue',
            line=dict(color='#2E86C1', width=3),
            marker=dict(size=8)
        ))
    
    # Add forecast line
    forecast_data = df[df['FORECASTED_REVENUE'].notna()]
    if not forecast_data.empty:
        fig.add_trace(go.Scatter(
            x=forecast_data['DATE_PERIOD'],
            y=forecast_data['FORECASTED_REVENUE'],
            mode='lines+markers',
            name='Forecasted Revenue',
            line=dict(color='#E74C3C', width=2, dash='dash'),
            marker=dict(size=6)
        ))
    
    fig.update_layout(
        title="Revenue Trend - Actual vs Forecast",
        xaxis_title="Date",
        yaxis_title="Revenue ($)",
        hovermode='x unified',
        showlegend=True,
        height=400
    )
    
    return fig

def create_expense_breakdown_chart(df):
    """Create expense breakdown pie chart"""
    if df.empty:
        st.warning("No expense data available")
        return None
    
    fig = px.pie(
        df,
        values='TOTAL_EXPENSE',
        names='EXPENSE_CATEGORY',
        title="Expense Breakdown by Category (Last 3 Months)",
        color_discrete_sequence=px.colors.qualitative.Set3
    )
    
    fig.update_traces(textposition='inside', textinfo='percent+label')
    fig.update_layout(height=400)
    
    return fig

def create_department_performance_chart(df):
    """Create department performance bar chart"""
    if df.empty:
        st.warning("No department performance data available")
        return None
    
    # Get latest month data
    latest_month = df['DATE_PERIOD'].max()
    latest_data = df[df['DATE_PERIOD'] == latest_month]
    
    fig = go.Figure()
    
    fig.add_trace(go.Bar(
        name='Revenue',
        x=latest_data['DEPARTMENT'],
        y=latest_data['REVENUE'],
        marker_color='#3498DB'
    ))
    
    fig.add_trace(go.Bar(
        name='Expenses',
        x=latest_data['DEPARTMENT'],
        y=latest_data['EXPENSES'],
        marker_color='#E74C3C'
    ))
    
    fig.add_trace(go.Bar(
        name='Profit',
        x=latest_data['DEPARTMENT'],
        y=latest_data['PROFIT'],
        marker_color='#27AE60'
    ))
    
    fig.update_layout(
        title=f"Department Performance - {latest_month.strftime('%B %Y') if hasattr(latest_month, 'strftime') else latest_month}",
        xaxis_title="Department",
        yaxis_title="Amount ($)",
        barmode='group',
        height=400
    )
    
    return fig

def create_monthly_forecast_chart(df):
    """Create monthly forecast comparison chart"""
    if df.empty:
        st.warning("No forecast data available")
        return None
    
    # Filter for future months (forecast only)
    future_data = df[df['ACTUAL_REVENUE'].isna()]
    
    if future_data.empty:
        st.warning("No forecast data available")
        return None
    
    fig = go.Figure()
    
    fig.add_trace(go.Bar(
        x=future_data['DATE_PERIOD'],
        y=future_data['FORECASTED_REVENUE'],
        name='Forecasted Revenue',
        marker_color='#9B59B6'
    ))
    
    fig.update_layout(
        title="6-Month Revenue Forecast",
        xaxis_title="Month",
        yaxis_title="Forecasted Revenue ($)",
        height=400
    )
    
    return fig

def render_chat_interface():
    """Render the Cortex Analyst chat interface using the official GitHub example approach"""
    st.subheader("🤖 Cortex Analyst")
    st.write("Ask questions about your financial data using natural language.")
    
    # Initialize messages in session state
    if "messages" not in st.session_state:
        st.session_state.messages = []
    
    # Display chat messages
    for message in st.session_state.messages:
        with st.chat_message(message["role"]):
            if message["role"] == "user":
                st.write(message["content"])
            else:
                # Display analyst response
                if isinstance(message["content"], dict):
                    # Handle structured response from Cortex Analyst
                    content = message["content"]
                    
                    # Show interpretation
                    if "interpretation" in content:
                        st.write(content["interpretation"])
                    
                    # Show SQL query in expander
                    if "sql" in content:
                        with st.expander("View SQL Query", expanded=False):
                            st.code(content["sql"], language='sql')
                    
                    # Show results
                    if "results" in content and not content["results"].empty:
                        with st.expander(f"View Results ({len(content['results'])} rows)", expanded=False):
                            st.dataframe(content["results"])
                    
                    # Show summary
                    if "summary" in content:
                        st.markdown("**Summary:**")
                        st.write(content["summary"])
                else:
                    # Simple text response
                    st.write(message["content"])
    
    # Quick action buttons
    st.markdown("**Quick Questions:**")
    col1, col2, col3 = st.columns(3)
    
    with col1:
        if st.button("💰 Q3 2024 Revenue", use_container_width=True):
            handle_user_input("What was our total revenue in Q3 2024?")
    
    with col2:
        if st.button("📊 Top Expenses", use_container_width=True):
            handle_user_input("What are our biggest expense categories?")
    
    with col3:
        if st.button("📈 Growth Rate", use_container_width=True):
            handle_user_input("What is our revenue growth rate?")
    
    # Chat input
    if prompt := st.chat_input("Ask a question about your financial data"):
        handle_user_input(prompt)
    
    # Clear chat button
    if st.button("Clear Chat", use_container_width=True):
        st.session_state.messages = []
        st.rerun()

def handle_user_input(user_input):
    """Handle user input and get response from Cortex Analyst"""
    # Add user message to chat
    st.session_state.messages.append({"role": "user", "content": user_input})
    
    # Get response from Cortex Analyst
    with st.spinner("Thinking..."):
        response = get_analyst_response(user_input)
        
        # Add assistant response to chat
        st.session_state.messages.append({"role": "assistant", "content": response})
    
    st.rerun()

def get_analyst_response(user_question):
    """Get response from Cortex Analyst using the GitHub example approach"""
    try:
        # Import the required module for API calls
        import _snowflake
        
        # API configuration
        API_ENDPOINT = "/api/v2/cortex/analyst/message"
        API_TIMEOUT = 30 * 1000  # 30 seconds in milliseconds
        
        # Prepare messages for the API
        messages = [
            {
                "role": "user", 
                "content": [
                    {
                        "type": "text",
                        "text": user_question
                    }
                ]
            }
        ]
        
        request_body = {
            "messages": messages,
            "semantic_model_file": f"@FINANCIAL_DEMO.ANALYTICS.STAGE_FINANCIAL_DEMO/cortex_analyst_config.yaml",
        }
        
        # Send request to Cortex Analyst API
        resp = _snowflake.send_snow_api_request(
            "POST",
            API_ENDPOINT,
            {},
            {},
            request_body,
            None,
            API_TIMEOUT,
        )
        
        # Parse response
        parsed_content = json.loads(resp["content"])
        
        if resp["status"] < 400:
            # Extract response content
            message = parsed_content.get("message", {})
            
            if isinstance(message, dict) and "content" in message:
                content_items = message["content"]
                
                interpretation = ""
                sql_query = ""
                results_df = pd.DataFrame()
                
                # Parse content items
                for item in content_items:
                    if item.get("type") == "text":
                        interpretation = item.get("text", "")
                    elif item.get("type") == "sql":
                        sql_query = item.get("statement", "")
                
                # Execute SQL if available
                if sql_query:
                    try:
                        session = get_snowflake_session()
                        results_df = session.sql(sql_query).to_pandas()
                    except Exception as e:
                        return f"Error executing query: {str(e)}"
                
                # Generate summary using Cortex COMPLETE
                summary = ""
                if not results_df.empty:
                    try:
                        summary = generate_summary_with_complete(user_question, results_df)
                    except Exception as e:
                        summary = f"Query executed successfully with {len(results_df)} results."
                
                # Return structured response
                return {
                    "interpretation": interpretation,
                    "sql": sql_query,
                    "results": results_df,
                    "summary": summary
                }
            else:
                return "Received response but couldn't parse content"
        else:
            # Handle error
            error_msg = parsed_content.get('message', 'Unknown error occurred')
            return f"Error: {error_msg}"
            
    except ImportError:
        # Fallback if _snowflake module not available
        return "Cortex Analyst API not available in this environment. Please ensure you're running in Streamlit in Snowflake."
    except Exception as e:
        return f"Error calling Cortex Analyst: {str(e)}"

def generate_summary_with_complete(user_question, data_df):
    """Generate a simple summary using Cortex COMPLETE"""
    try:
        session = get_snowflake_session()
        
        # Create a simple summary of the data
        row_count = len(data_df)
        
        # Get key statistics for numeric columns
        numeric_cols = data_df.select_dtypes(include=['number']).columns.tolist()
        stats_text = ""
        
        if numeric_cols and len(numeric_cols) > 0:
            first_col = numeric_cols[0]
            if not data_df[first_col].empty:
                total = float(data_df[first_col].sum())
                avg = float(data_df[first_col].mean())
                stats_text = f"Total {first_col}: {total:,.2f}, Average: {avg:,.2f}"
        
        # Simple prompt for summary
        prompt = f"Question: {user_question}. Results: {row_count} records found. {stats_text}. Provide a 1-2 sentence business summary."
        
        # Escape the prompt
        escaped_prompt = prompt.replace("'", "''")
        
        # Use Cortex COMPLETE
        complete_sql = f"""
            SELECT SNOWFLAKE.CORTEX.COMPLETE(
                'mistral-large2',
                '{escaped_prompt}'
            ) as summary
        """
        
        result_df = session.sql(complete_sql).to_pandas()
        
        if not result_df.empty:
            return result_df.iloc[0]['SUMMARY']
        else:
            return f"Found {row_count} records. {stats_text}"
            
    except Exception as e:
        return f"Analysis complete: {len(data_df)} records found."

# Main application
def main():
    # Header
    st.title("💰 Financial Analytics Dashboard")
    st.markdown("*Powered by Snowflake Cortex Analyst & Streamlit in Snowflake*")
    st.markdown("---")
    
    # Create main layout: 2/3 dashboard + 1/3 chat
    col_dashboard, col_chat = st.columns([2, 1])
    
    with col_dashboard:
        # Load data
        with st.spinner("Loading financial data..."):
            metrics_data = load_key_metrics()
            financial_summary = load_financial_summary()
            department_performance = load_department_performance()
            expense_breakdown = load_expense_breakdown()
            revenue_forecast = load_revenue_forecast()
        
        # Key metrics cards
        st.subheader("📊 Executive Summary")
        create_metric_cards(metrics_data)
        
        st.markdown("---")
        
        # Charts section
        st.subheader("📈 Financial Analysis")
        
        # Top row charts
        chart_col1, chart_col2 = st.columns(2)
        
        with chart_col1:
            revenue_chart = create_revenue_trend_chart(revenue_forecast)
            if revenue_chart:
                st.plotly_chart(revenue_chart, use_container_width=True)
        
        with chart_col2:
            expense_chart = create_expense_breakdown_chart(expense_breakdown)
            if expense_chart:
                st.plotly_chart(expense_chart, use_container_width=True)
        
        # Bottom row charts
        chart_col3, chart_col4 = st.columns(2)
        
        with chart_col3:
            forecast_chart = create_monthly_forecast_chart(revenue_forecast)
            if forecast_chart:
                st.plotly_chart(forecast_chart, use_container_width=True)
        
        with chart_col4:
            dept_chart = create_department_performance_chart(department_performance)
            if dept_chart:
                st.plotly_chart(dept_chart, use_container_width=True)
        
        # Data tables section
        with st.expander("📋 Detailed Data Tables"):
            tab1, tab2, tab3 = st.tabs(["Financial Summary", "Department Performance", "Expense Breakdown"])
            
            with tab1:
                if not financial_summary.empty:
                    st.dataframe(financial_summary, use_container_width=True)
                else:
                    st.warning("No financial summary data available")
            
            with tab2:
                if not department_performance.empty:
                    st.dataframe(department_performance, use_container_width=True)
                else:
                    st.warning("No department performance data available")
            
            with tab3:
                if not expense_breakdown.empty:
                    st.dataframe(expense_breakdown, use_container_width=True)
                else:
                    st.warning("No expense breakdown data available")
    
    with col_chat:
        render_chat_interface()

if __name__ == "__main__":
    main() 