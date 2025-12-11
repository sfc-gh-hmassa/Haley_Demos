"""
Quote-to-Project Matching App
Find similar historical projects for incoming quotes using Snowflake Cortex Search
"""

import streamlit as st
import pandas as pd
import json
from datetime import datetime
import plotly.express as px
from snowflake.snowpark.context import get_active_session
session = get_active_session()



# Page configuration
st.set_page_config(
    page_title="Quote-Project Matching",
    page_icon="🚛",
    layout="wide"
)

# Title and description
st.title("🚛 Quote-to-Project Matching with Cortex Multi-Index Search")
st.markdown("""
Find similar historical repair projects for incoming quotes using hybrid text + vector search.
Match quotes to projects based on description, vendor, and part type.
""")

# Sidebar - Search Configuration
st.sidebar.header("🔍 Search Configuration")

# Number of results
top_n = st.sidebar.slider(
    "Number of results per quote",
    min_value=1,
    max_value=10,
    value=5,
    help="How many similar projects to return for each quote"
)

# Advanced settings
with st.sidebar.expander("⚙️ Advanced Settings"):
    text_weight = st.slider("Text Search Weight", 0.0, 5.0, 1.0, 0.5)
    vector_weight = st.slider("Vector Search Weight", 0.0, 5.0, 3.0, 0.5)
    reranker_weight = st.slider("Reranker Weight", 0.0, 5.0, 1.0, 0.5)
    
    st.markdown("**Field Boosts**")
    description_boost = st.slider("Description Boost", 1.0, 5.0, 2.0, 0.5)
    vendor_boost = st.slider("Vendor Boost", 1.0, 5.0, 1.5, 0.5)
    part_type_boost = st.slider("Part Type Boost", 1.0, 5.0, 1.0, 0.5)

# Main content area
st.markdown("---")

# Search mode selection
search_mode = st.radio(
    "Choose search mode:",
    options=["Search by Quote ID(s)", "Search All Quotes", "Free-form Text Search"],
    horizontal=True
)

# Mode 1: Search by Quote ID(s)
if search_mode == "Search by Quote ID(s)":
    st.header("🎯 Search by Quote ID(s)")
    
    col1, col2 = st.columns([3, 1])
    
    with col1:
        quote_input = st.text_area(
            "Enter Quote ID(s)",
            placeholder="Q001\nQ002\nQ003",
            help="Enter one quote ID per line"
        )
    
    with col2:
        st.markdown("**Sample Quote IDs:**")
        sample_quotes = session.sql("SELECT quote_id FROM quotes LIMIT 5").to_pandas()
        for qid in sample_quotes['QUOTE_ID']:
            st.code(qid, language=None)
    
    if st.button("🔍 Search", type="primary", use_container_width=True):
        if not quote_input.strip():
            st.error("Please enter at least one quote ID")
        else:
            quote_ids = [qid.strip() for qid in quote_input.split('\n') if qid.strip()]
            quote_ids_str = "', '".join(quote_ids)
            
            with st.spinner("Searching for similar projects..."):
                source_quotes_df = session.sql(f"""
                    SELECT quote_id, description, vendor, part_type, quote_date
                    FROM quotes
                    WHERE quote_id IN ('{quote_ids_str}')
                """).to_pandas()
                
                if len(source_quotes_df) == 0:
                    st.error("No quotes found with the provided IDs")
                else:
                    source_quotes_df.columns = [col.upper() for col in source_quotes_df.columns]
                    st.success(f"Found {len(source_quotes_df)} quote(s). Searching for matches...")
                    
                    all_results = []
                    progress_bar = st.progress(0)
                    
                    for idx, row in source_quotes_df.iterrows():
                        search_query = {
                            "multi_index_query": {
                                "description": [{"text": str(row['DESCRIPTION'])}],
                                "vendor": [{"text": str(row['VENDOR']) if row['VENDOR'] else ""}],
                                "part_type": [{"text": str(row['PART_TYPE']) if row['PART_TYPE'] else ""}]
                            },
                            "scoring_config": {
                                "weights": {"texts": text_weight, "vectors": vector_weight, "reranker": reranker_weight},
                                "functions": {
                                    "text_boosts": [{"column": "description", "weight": description_boost}],
                                    "vector_boosts": [{"column": "description", "weight": description_boost}]
                                }
                            },
                            "columns": ["project_id", "description", "vendor", "part_type", "price"],
                            "limit": top_n
                        }
                        
                        search_sql = f"""
                            SELECT '{row['QUOTE_ID']}' AS quote_id,
                                   value['project_id']::text AS project_id,
                                   value['description']::text AS project_description,
                                   value['vendor']::text AS project_vendor,
                                   value['part_type']::text AS project_part_type,
                                   value['price']::float AS project_price,
                                   value['@score']::float AS score
                            FROM TABLE(FLATTEN(PARSE_JSON(SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
                                'TRUCKING_DEMO.DEMO.TRUCKING_PROJECTS_MULTI_SEARCH', '{json.dumps(search_query).replace("'", "''")}'
                            ))['results']))
                        """
                        
                        try:
                            results = session.sql(search_sql).to_pandas()
                            # Add source quote info
                            results['QUOTE_DESCRIPTION'] = row['DESCRIPTION']
                            results['QUOTE_VENDOR'] = row['VENDOR']
                            all_results.append(results)
                        except Exception as e:
                            st.error(f"Error searching for {row['QUOTE_ID']}: {str(e)}")
                        
                        progress_bar.progress((idx + 1) / len(source_quotes_df))
                    
                    if all_results:
                        final_results = pd.concat(all_results, ignore_index=True)
                        
                        # Display summary
                        st.markdown("---")
                        st.subheader("📊 Search Results")
                        
                        col1, col2, col3, col4 = st.columns(4)
                        with col1:
                            st.metric("Quotes Searched", len(source_quotes_df))
                        with col2:
                            st.metric("Total Matches", len(final_results))
                        with col3:
                            avg_score = final_results['SCORE'].mean() * 100
                            st.metric("Avg Score", f"{avg_score:.1f}%")
                        with col4:
                            avg_price = final_results['PROJECT_PRICE'].mean()
                            st.metric("Avg Project Price", f"${avg_price:,.0f}")
                        
                        # Results table
                        st.dataframe(final_results, use_container_width=True, height=400)
                        
                        # Download button
                        csv = final_results.to_csv(index=False)
                        st.download_button(
                            label="📥 Download Results as CSV",
                            data=csv,
                            file_name=f"quote_matches_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv",
                            mime="text/csv"
                        )

# Mode 2: Search All Quotes
elif search_mode == "Search All Quotes":
    st.header("📋 Search All Quotes")
    st.markdown("Match all quotes in the database to similar historical projects.")
    
    # Get quote count
    quote_count = session.sql("SELECT COUNT(*) AS cnt FROM quotes").to_pandas()['CNT'][0]
    st.info(f"Found {quote_count} quotes in the database")
    
    if st.button("🔍 Search All Quotes", type="primary", use_container_width=True):
        with st.spinner("Searching all quotes... This may take a moment."):
            quotes_df = session.sql("""
                SELECT quote_id, description, vendor, part_type, quote_date
                FROM quotes
            """).to_pandas()
            
            quotes_df.columns = [col.upper() for col in quotes_df.columns]
            all_results = []
            progress_bar = st.progress(0)
            
            for idx, row in quotes_df.iterrows():
                search_query = {
                    "multi_index_query": {
                        "description": [{"text": str(row['DESCRIPTION'])}],
                        "vendor": [{"text": str(row['VENDOR']) if row['VENDOR'] else ""}],
                        "part_type": [{"text": str(row['PART_TYPE']) if row['PART_TYPE'] else ""}]
                    },
                    "scoring_config": {
                        "weights": {"texts": text_weight, "vectors": vector_weight, "reranker": reranker_weight},
                        "functions": {
                            "text_boosts": [{"column": "description", "weight": description_boost}],
                            "vector_boosts": [{"column": "description", "weight": description_boost}]
                        }
                    },
                    "columns": ["project_id", "description", "vendor", "part_type", "price"],
                    "limit": top_n
                }
                
                search_sql = f"""
                    SELECT '{row['QUOTE_ID']}' AS quote_id,
                           value['project_id']::text AS project_id,
                           value['description']::text AS project_description,
                           value['vendor']::text AS project_vendor,
                           value['part_type']::text AS project_part_type,
                           value['price']::float AS project_price,
                           value['@score']::float AS score
                    FROM TABLE(FLATTEN(PARSE_JSON(SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
                        'TRUCKING_DEMO.DEMO.TRUCKING_PROJECTS_MULTI_SEARCH', '{json.dumps(search_query).replace("'", "''")}'
                    ))['results']))
                """
                
                try:
                    results = session.sql(search_sql).to_pandas()
                    all_results.append(results)
                except Exception as e:
                    pass
                
                progress_bar.progress((idx + 1) / len(quotes_df))
            
            if all_results:
                final_results = pd.concat(all_results, ignore_index=True)
                
                # Get best match per quote
                best_matches = final_results.loc[final_results.groupby('QUOTE_ID')['SCORE'].idxmax()]
                
                # Display summary
                st.markdown("---")
                st.subheader("📊 Results Summary")
                
                col1, col2, col3, col4 = st.columns(4)
                with col1:
                    st.metric("Quotes Matched", len(best_matches))
                with col2:
                    st.metric("Total Candidates", len(final_results))
                with col3:
                    avg_score = best_matches['SCORE'].mean() * 100
                    st.metric("Avg Best Score", f"{avg_score:.1f}%")
                with col4:
                    high_conf = len(best_matches[best_matches['SCORE'] >= 0.7])
                    st.metric("High Confidence", high_conf)
                
                # Score distribution
                st.markdown("---")
                st.subheader("📈 Score Distribution")
                
                fig = px.histogram(
                    best_matches,
                    x='SCORE',
                    nbins=20,
                    title="Best Match Score Distribution"
                )
                fig.add_vline(x=0.7, line_dash="dash", line_color="green", annotation_text="High Confidence")
                st.plotly_chart(fig, use_container_width=True)
                
                # Best matches table
                st.subheader("🏆 Best Match Per Quote")
                st.dataframe(best_matches, use_container_width=True, height=400)
                
                # Download
                csv = final_results.to_csv(index=False)
                st.download_button(
                    label="📥 Download All Results as CSV",
                    data=csv,
                    file_name=f"all_quote_matches_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv",
                    mime="text/csv"
                )

# Mode 3: Free-form Text Search
elif search_mode == "Free-form Text Search":
    st.header("✍️ Free-form Text Search")
    st.markdown("Enter a description to find similar historical projects.")
    
    search_text = st.text_area(
        "Enter repair description",
        placeholder="Example: Replace front brake pads and rotors on Peterbilt truck...",
        height=100
    )
    
    col1, col2 = st.columns(2)
    with col1:
        vendor_filter = st.text_input("Vendor (optional)", placeholder="e.g., Peterbilt")
    with col2:
        part_type_filter = st.text_input("Part Type (optional)", placeholder="e.g., Brakes")
    
    if st.button("🔍 Search", type="primary", use_container_width=True):
        if not search_text.strip():
            st.error("Please enter a description")
        else:
            with st.spinner("Searching..."):
                search_query = {
                    "multi_index_query": {
                        "description": [{"text": search_text}],
                        "vendor": [{"text": vendor_filter if vendor_filter else ""}],
                        "part_type": [{"text": part_type_filter if part_type_filter else ""}]
                    },
                    "scoring_config": {
                        "weights": {"texts": text_weight, "vectors": vector_weight, "reranker": reranker_weight},
                        "functions": {
                            "text_boosts": [{"column": "description", "weight": description_boost}],
                            "vector_boosts": [{"column": "description", "weight": description_boost}]
                        }
                    },
                    "columns": ["project_id", "description", "vendor", "part_type", "price", "manager", "department"],
                    "limit": top_n * 2
                }
                
                search_sql = f"""
                    SELECT value['project_id']::text AS project_id,
                           value['description']::text AS description,
                           value['vendor']::text AS vendor,
                           value['part_type']::text AS part_type,
                           value['price']::float AS price,
                           value['manager']::text AS manager,
                           value['department']::text AS department,
                           value['@score']::float AS score
                    FROM TABLE(FLATTEN(PARSE_JSON(SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
                        'TRUCKING_DEMO.DEMO.TRUCKING_PROJECTS_MULTI_SEARCH', '{json.dumps(search_query).replace("'", "''")}'
                    ))['results']))
                """
                
                try:
                    results = session.sql(search_sql).to_pandas()
                    
                    if len(results) == 0:
                        st.warning("No matching projects found.")
                    else:
                        st.success(f"Found {len(results)} matching projects!")
                        
                        # Metrics
                        col1, col2, col3, col4 = st.columns(4)
                        with col1:
                            st.metric("Matches Found", len(results))
                        with col2:
                            avg_score = results['SCORE'].mean() * 100
                            st.metric("Avg Score", f"{avg_score:.1f}%")
                        with col3:
                            avg_price = results['PRICE'].mean()
                            st.metric("Avg Price", f"${avg_price:,.0f}")
                        with col4:
                            price_range = f"${results['PRICE'].min():,.0f} - ${results['PRICE'].max():,.0f}"
                            st.metric("Price Range", price_range)
                        
                        # Results table
                        st.dataframe(results, use_container_width=True, height=400)
                        
                        # Download
                        csv = results.to_csv(index=False)
                        st.download_button(
                            label="📥 Download Results as CSV",
                            data=csv,
                            file_name=f"search_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv",
                            mime="text/csv"
                        )
                except Exception as e:
                    st.error(f"Error: {str(e)}")

# Footer
st.markdown("---")
st.markdown("""
<div style='text-align: center; color: #666; padding: 20px;'>
    <p>Powered by Snowflake Cortex Search | Multi-Index Semantic Search</p>
    <p>🚛 Quote-to-Project Matching Demo</p>
</div>
""", unsafe_allow_html=True)



