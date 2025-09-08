import streamlit as st
import pandas as pd
import json
from datetime import datetime
from snowflake.snowpark.context import get_active_session

# Configure Streamlit page
st.set_page_config(
    page_title="Invoice Entity Resolution & Procurement Intelligence",
    page_icon="💼",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Initialize Snowflake session
@st.cache_resource
def init_snowflake_session():
    """Get the active Snowflake session in Snowflake Streamlit environment"""
    try:
        session = get_active_session()
        return session
    except Exception as e:
        st.error(f"Failed to get Snowflake session: {str(e)}")
        return None

# Load data functions
@st.cache_data
def load_vendor_quotes(_session):
    """Load new vendor quotes from Snowflake"""
    try:
        df = _session.table("DEMODB.PROCUREMENT_INTELLIGENCE.NEW_VENDOR_QUOTES").to_pandas()
        return df
    except Exception as e:
        st.error(f"Error loading vendor quotes: {str(e)}")
        return pd.DataFrame()

@st.cache_data
def load_historical_invoices(_session):
    """Load historical invoices from Snowflake"""
    try:
        df = _session.table("DEMODB.PROCUREMENT_INTELLIGENCE.HISTORICAL_INVOICES").to_pandas()
        return df
    except Exception as e:
        st.error(f"Error loading historical invoices: {str(e)}")
        return pd.DataFrame()

def analyze_single_quote(session, quote_id):
    """Analyze a single quote with top 3 historical matches"""
    try:
        analysis_sql = f"""
        WITH quote_analysis AS (
            SELECT 
                nq.QUOTE_ID,
                nq.PRODUCT_DESCRIPTION,
                nq.VENDOR_NAME as current_vendor,
                nq.QUOTED_UNIT_PRICE as current_price,
                nq.QUOTED_QUANTITY,
                
                -- Historical match details
                s.RANK as match_rank,
                s.VENDOR_NAME as historical_vendor,
                TRY_CAST(s.UNIT_PRICE AS FLOAT) as historical_price,
                s.INVOICE_DATE as purchase_date,
                TRY_CAST(s.RECENCY_WEIGHT AS FLOAT) as recency_weight,
                
                -- Price analysis
                ROUND(((nq.QUOTED_UNIT_PRICE - TRY_CAST(s.UNIT_PRICE AS FLOAT)) / TRY_CAST(s.UNIT_PRICE AS FLOAT) * 100), 1) as price_variance_pct,
                (nq.QUOTED_UNIT_PRICE - TRY_CAST(s.UNIT_PRICE AS FLOAT)) * nq.QUOTED_QUANTITY as total_price_impact,
                
                -- Recommendation logic
                CASE 
                    WHEN ((nq.QUOTED_UNIT_PRICE - TRY_CAST(s.UNIT_PRICE AS FLOAT)) / TRY_CAST(s.UNIT_PRICE AS FLOAT) * 100) > 25 THEN 'NEGOTIATE AGGRESSIVELY'
                    WHEN ((nq.QUOTED_UNIT_PRICE - TRY_CAST(s.UNIT_PRICE AS FLOAT)) / TRY_CAST(s.UNIT_PRICE AS FLOAT) * 100) > 15 THEN 'NEGOTIATE'
                    WHEN ((nq.QUOTED_UNIT_PRICE - TRY_CAST(s.UNIT_PRICE AS FLOAT)) / TRY_CAST(s.UNIT_PRICE AS FLOAT) * 100) > 5 THEN 'CONSIDER NEGOTIATION'
                    WHEN ((nq.QUOTED_UNIT_PRICE - TRY_CAST(s.UNIT_PRICE AS FLOAT)) / TRY_CAST(s.UNIT_PRICE AS FLOAT) * 100) > -5 THEN 'FAIR PRICE'
                    ELSE 'GOOD DEAL'
                END as recommendation
                
                         FROM DEMODB.PROCUREMENT_INTELLIGENCE.NEW_VENDOR_QUOTES nq,
             LATERAL CORTEX_SEARCH_BATCH(
                 service_name => 'DEMODB.PROCUREMENT_INTELLIGENCE.PROCUREMENT_SEARCH',
                query => CONCAT('Product: ', nq.PRODUCT_DESCRIPTION, ', Category: ', nq.PRODUCT_CATEGORY, ', Specs: ', COALESCE(nq.SPECIFICATIONS, '')),
                limit => 3
            ) s
            WHERE nq.QUOTE_ID = '{quote_id}'
              AND s.INVOICE_ID IS NOT NULL
              AND s.ERROR IS NULL
              AND TRY_CAST(s.UNIT_PRICE AS FLOAT) IS NOT NULL
            ORDER BY s.RANK
        )
        SELECT * FROM quote_analysis
        """
        
        result = session.sql(analysis_sql).to_pandas()
        return result
        
    except Exception as e:
        st.error(f"Error analyzing quote: {str(e)}")
        return pd.DataFrame()

def run_daily_batch_analysis(session):
    """Run daily batch analysis of all quotes"""
    try:
                 # First create the batch search results
         batch_sql = """
         CREATE OR REPLACE TABLE DEMODB.PROCUREMENT_INTELLIGENCE.PROCUREMENT_BATCH_SEARCH_RESULTS AS
         SELECT
           nq.QUOTE_ID,
           nq.PRODUCT_DESCRIPTION,
           nq.VENDOR_NAME as quote_vendor,
           nq.QUOTED_UNIT_PRICE,
           nq.QUOTED_QUANTITY,
           nq.REQUESTED_BY,
           nq.VALID_UNTIL,
           CONCAT('Product: ', nq.PRODUCT_DESCRIPTION, ', Category: ', nq.PRODUCT_CATEGORY, ', Specs: ', COALESCE(nq.SPECIFICATIONS, '')) as search_query,
           s.*
         FROM DEMODB.PROCUREMENT_INTELLIGENCE.NEW_VENDOR_QUOTES AS nq,
         LATERAL CORTEX_SEARCH_BATCH(
           service_name => 'DEMODB.PROCUREMENT_INTELLIGENCE.PROCUREMENT_SEARCH',
           query => CONCAT('Product: ', nq.PRODUCT_DESCRIPTION, ', Category: ', nq.PRODUCT_CATEGORY, ', Specs: ', COALESCE(nq.SPECIFICATIONS, '')),
           limit => 3
         ) AS s
         """
         session.sql(batch_sql).collect()
         
         # Then run the analysis
         analysis_sql = """
         WITH daily_analysis AS (
             SELECT 
                QUOTE_ID,
                PRODUCT_DESCRIPTION,
                quote_vendor,
                QUOTED_UNIT_PRICE,
                QUOTED_QUANTITY,
                REQUESTED_BY,
                VALID_UNTIL,
                
                -- Best historical match (rank 1 only)
                VENDOR_NAME as historical_vendor,
                TRY_CAST(UNIT_PRICE AS FLOAT) as historical_price,
                INVOICE_DATE as historical_date,
                TRY_CAST(RECENCY_WEIGHT AS FLOAT) as recency_weight,
                
                -- Price analysis
                ROUND(((QUOTED_UNIT_PRICE - TRY_CAST(UNIT_PRICE AS FLOAT)) / TRY_CAST(UNIT_PRICE AS FLOAT) * 100), 1) as price_variance_pct,
                (QUOTED_UNIT_PRICE - TRY_CAST(UNIT_PRICE AS FLOAT)) * QUOTED_QUANTITY as potential_savings,
                
                -- Priority classification
                CASE 
                    WHEN ((QUOTED_UNIT_PRICE - TRY_CAST(UNIT_PRICE AS FLOAT)) / TRY_CAST(UNIT_PRICE AS FLOAT) * 100) > 20 THEN 'HIGH PRIORITY'
                    WHEN ((QUOTED_UNIT_PRICE - TRY_CAST(UNIT_PRICE AS FLOAT)) / TRY_CAST(UNIT_PRICE AS FLOAT) * 100) > 10 THEN 'MEDIUM PRIORITY'
                    WHEN ((QUOTED_UNIT_PRICE - TRY_CAST(UNIT_PRICE AS FLOAT)) / TRY_CAST(UNIT_PRICE AS FLOAT) * 100) > 0 THEN 'LOW PRIORITY'
                    ELSE 'GOOD PRICE'
                END as priority_level
                
                         FROM DEMODB.PROCUREMENT_INTELLIGENCE.PROCUREMENT_BATCH_SEARCH_RESULTS
            WHERE RANK = 1  -- Only best match
              AND ERROR IS NULL
              AND INVOICE_ID IS NOT NULL
              AND TRY_CAST(UNIT_PRICE AS FLOAT) IS NOT NULL
        )
        
        SELECT 
            priority_level,
            COUNT(*) as quote_count,
            ROUND(AVG(price_variance_pct), 1) as avg_price_variance,
            ROUND(SUM(CASE WHEN potential_savings > 0 THEN potential_savings ELSE 0 END), 0) as total_potential_savings
        FROM daily_analysis
        GROUP BY priority_level
        
        UNION ALL
        
        SELECT 
            'TOTAL' as priority_level,
            COUNT(*) as quote_count,
            ROUND(AVG(price_variance_pct), 1) as avg_price_variance,
            ROUND(SUM(CASE WHEN potential_savings > 0 THEN potential_savings ELSE 0 END), 0) as total_potential_savings
        FROM daily_analysis
        
        ORDER BY 
            CASE WHEN priority_level = 'TOTAL' THEN 1
                 WHEN priority_level = 'HIGH PRIORITY' THEN 2
                 WHEN priority_level = 'MEDIUM PRIORITY' THEN 3
                 ELSE 4 END
        """
         
         summary_result = session.sql(analysis_sql).to_pandas()
         
         # Also get detailed results for high priority items
         detail_sql = """
         SELECT 
            QUOTE_ID,
            PRODUCT_DESCRIPTION,
            quote_vendor,
            QUOTED_UNIT_PRICE,
            historical_vendor,
            historical_price,
            price_variance_pct,
            potential_savings,
            priority_level
        FROM (
            SELECT 
                QUOTE_ID,
                PRODUCT_DESCRIPTION,
                quote_vendor,
                QUOTED_UNIT_PRICE,
                VENDOR_NAME as historical_vendor,
                TRY_CAST(UNIT_PRICE AS FLOAT) as historical_price,
                ROUND(((QUOTED_UNIT_PRICE - TRY_CAST(UNIT_PRICE AS FLOAT)) / TRY_CAST(UNIT_PRICE AS FLOAT) * 100), 1) as price_variance_pct,
                (QUOTED_UNIT_PRICE - TRY_CAST(UNIT_PRICE AS FLOAT)) * QUOTED_QUANTITY as potential_savings,
                CASE 
                    WHEN ((QUOTED_UNIT_PRICE - TRY_CAST(UNIT_PRICE AS FLOAT)) / TRY_CAST(UNIT_PRICE AS FLOAT) * 100) > 20 THEN 'HIGH PRIORITY'
                    WHEN ((QUOTED_UNIT_PRICE - TRY_CAST(UNIT_PRICE AS FLOAT)) / TRY_CAST(UNIT_PRICE AS FLOAT) * 100) > 10 THEN 'MEDIUM PRIORITY'
                    ELSE 'OTHER'
                END as priority_level
                         FROM DEMODB.PROCUREMENT_INTELLIGENCE.PROCUREMENT_BATCH_SEARCH_RESULTS
            WHERE RANK = 1 AND ERROR IS NULL AND INVOICE_ID IS NOT NULL
              AND TRY_CAST(UNIT_PRICE AS FLOAT) IS NOT NULL
        )
        WHERE priority_level IN ('HIGH PRIORITY', 'MEDIUM PRIORITY')
        ORDER BY price_variance_pct DESC
         """
         
         detail_result = session.sql(detail_sql).to_pandas()
         
         return summary_result, detail_result
        
    except Exception as e:
        st.error(f"Error running batch analysis: {str(e)}")
        return pd.DataFrame(), pd.DataFrame()

def display_single_quote_analysis(analysis_df):
    """Display single quote analysis results"""
    if analysis_df.empty:
        st.warning("No analysis results found.")
        return
    
    # Get quote info from first row
    quote_info = analysis_df.iloc[0]
    
    st.subheader(f"🎯 Quote Analysis: {quote_info['QUOTE_ID']}")
    st.write(f"**Product:** {quote_info['PRODUCT_DESCRIPTION']}")
    st.write(f"**Current Vendor:** {quote_info['CURRENT_VENDOR']}")
    st.write(f"**Quoted Price:** ${quote_info['CURRENT_PRICE']:,.2f}")
    st.write(f"**Quantity:** {quote_info['QUOTED_QUANTITY']}")
    
    # Overall recommendation
    recommendation = quote_info['RECOMMENDATION']
    if 'NEGOTIATE AGGRESSIVELY' in recommendation:
        st.error(f"🚨 **{recommendation}** - Significant savings opportunity!")
    elif 'NEGOTIATE' in recommendation:
        st.warning(f"🟡 **{recommendation}** - Consider negotiation")
    elif 'CONSIDER' in recommendation:
        st.info(f"🟢 **{recommendation}** - Minor opportunity")
    else:
        st.success(f"✅ **{recommendation}**")
    
    # Historical matches
    st.subheader("📊 Historical Matches")
    
    for idx, row in analysis_df.iterrows():
        with st.expander(f"Match #{row['MATCH_RANK']} - {row['HISTORICAL_VENDOR']} (${row['HISTORICAL_PRICE']:,.2f})"):
            col1, col2, col3 = st.columns(3)
            
            with col1:
                st.metric("Historical Price", f"${row['HISTORICAL_PRICE']:,.2f}")
                st.write(f"**Vendor:** {row['HISTORICAL_VENDOR']}")
                st.write(f"**Date:** {row['PURCHASE_DATE']}")
            
            with col2:
                variance = row['PRICE_VARIANCE_PCT']
                if variance > 0:
                    st.metric("Price Change", f"+{variance}%", f"+${row['TOTAL_PRICE_IMPACT']:,.0f}")
                else:
                    st.metric("Price Change", f"{variance}%", f"${row['TOTAL_PRICE_IMPACT']:,.0f}")
            
            with col3:
                recency_score = row['RECENCY_WEIGHT'] * 100
                st.metric("Recency Score", f"{recency_score:.0f}%")
                st.write("*Higher = more recent purchase*")

def display_batch_analysis(summary_df, detail_df):
    """Display batch analysis results"""
    if summary_df.empty:
        st.warning("No batch analysis results found.")
        return
    
    st.subheader("📊 Daily Procurement Intelligence Summary")
    
    # Summary metrics
    total_row = summary_df[summary_df['PRIORITY_LEVEL'] == 'TOTAL'].iloc[0]
    
    col1, col2, col3, col4 = st.columns(4)
    with col1:
        st.metric("Total Quotes", int(total_row['QUOTE_COUNT']))
    with col2:
        st.metric("Avg Price Variance", f"{total_row['AVG_PRICE_VARIANCE']:.1f}%")
    with col3:
        st.metric("Potential Savings", f"${total_row['TOTAL_POTENTIAL_SAVINGS']:,.0f}")
    with col4:
        high_priority = summary_df[summary_df['PRIORITY_LEVEL'] == 'HIGH PRIORITY']
        high_count = int(high_priority['QUOTE_COUNT'].iloc[0]) if not high_priority.empty else 0
        st.metric("High Priority", high_count)
    
    # Priority breakdown
    st.subheader("🎯 Priority Breakdown")
    priority_data = summary_df[summary_df['PRIORITY_LEVEL'] != 'TOTAL']
    
    for _, row in priority_data.iterrows():
        priority = row['PRIORITY_LEVEL']
        count = int(row['QUOTE_COUNT'])
        variance = row['AVG_PRICE_VARIANCE']
        savings = row['TOTAL_POTENTIAL_SAVINGS']
        
        if priority == 'HIGH PRIORITY':
            st.error(f"🔴 **{priority}**: {count} quotes, {variance:.1f}% avg variance, ${savings:,.0f} potential savings")
        elif priority == 'MEDIUM PRIORITY':
            st.warning(f"🟡 **{priority}**: {count} quotes, {variance:.1f}% avg variance, ${savings:,.0f} potential savings")
        else:
            st.success(f"✅ **{priority}**: {count} quotes, {variance:.1f}% avg variance")
    
    # Detailed high priority items
    if not detail_df.empty:
        st.subheader("🚨 Action Required - High Priority Quotes")
        
        for _, row in detail_df.iterrows():
            with st.expander(f"{row['QUOTE_ID']} - {row['PRODUCT_DESCRIPTION']} ({row['PRICE_VARIANCE_PCT']:+.1f}%)"):
                col1, col2 = st.columns(2)
                
                with col1:
                    st.write(f"**Current Quote:** ${row['QUOTED_UNIT_PRICE']:,.2f} from {row['QUOTE_VENDOR']}")
                    st.write(f"**Historical:** ${row['HISTORICAL_PRICE']:,.2f} from {row['HISTORICAL_VENDOR']}")
                
                with col2:
                    st.metric("Price Increase", f"{row['PRICE_VARIANCE_PCT']:+.1f}%")
                    st.metric("Potential Savings", f"${abs(row['POTENTIAL_SAVINGS']):,.0f}")

# Main Streamlit App
def main():
    st.title("💼 Invoice Entity Resolution & Procurement Intelligence")
    st.markdown("**AI-Powered Quote Analysis with Historical Price Intelligence**")
    
    # Initialize session
    session = init_snowflake_session()
    if not session:
        st.stop()
    
    # Load data
    quotes_df = load_vendor_quotes(session)
    if quotes_df.empty:
        st.error("No vendor quotes found. Please ensure data is loaded.")
        st.stop()
    
    # Sidebar for workflow selection
    st.sidebar.header("Analysis Workflow")
    workflow = st.sidebar.radio(
        "Choose Analysis Type:",
        ["Single Quote Analysis", "Daily Batch Analysis"]
    )
    
    if workflow == "Single Quote Analysis":
        st.header("🎯 Single Quote Analysis")
        st.markdown("Analyze one specific quote with detailed historical comparisons")
        
        # Quote selection
        quote_ids = quotes_df['QUOTE_ID'].tolist()
        selected_quote = st.selectbox("Select Quote to Analyze:", quote_ids)
        
        if st.button("Analyze Quote", type="primary"):
            with st.spinner("Analyzing quote against historical data..."):
                analysis_result = analyze_single_quote(session, selected_quote)
                display_single_quote_analysis(analysis_result)
    
    elif workflow == "Daily Batch Analysis":
        st.header("📈 Daily Batch Analysis")
        st.markdown("Process all quotes to identify negotiation priorities")
        
        if st.button("Run Batch Analysis", type="primary"):
            with st.spinner("Processing all quotes against historical data..."):
                summary_result, detail_result = run_daily_batch_analysis(session)
                display_batch_analysis(summary_result, detail_result)
    
    # Data preview
    with st.expander("📋 View Raw Data"):
        tab1, tab2 = st.tabs(["New Quotes", "Historical Data"])
        
        with tab1:
            st.dataframe(quotes_df)
        
        with tab2:
            historical_df = load_historical_invoices(session)
            st.dataframe(historical_df)

if __name__ == "__main__":
    main()
