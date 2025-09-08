# Snowflake Streamlit Pump Datasheet RAG Demo
# Optimized for Snowflake Streamlit environment with built-in session

import streamlit as st
import json
from typing import List, Dict, Any, Set
from snowflake.core import Root
from snowflake.snowpark.context import get_active_session

# Page configuration
st.set_page_config(
    page_title="🚀 Pump Datasheet RAG",
    page_icon="🔧",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for better styling
st.markdown("""
<style>
    .main-header {
        font-size: 2.5rem;
        color: #1f77b4;
        text-align: center;
        margin-bottom: 2rem;
    }
    .search-mode-header {
        font-size: 1.5rem;
        color: #ff7f0e;
        margin: 1rem 0;
    }
    .result-container {
        background-color: #f8f9fa;
        padding: 1rem;
        border-radius: 0.5rem;
        border-left: 4px solid #1f77b4;
        margin: 1rem 0;
    }
    .vendor-tag {
        background-color: #e7f3ff;
        color: #0066cc;
        padding: 0.2rem 0.5rem;
        border-radius: 0.3rem;
        font-size: 0.8rem;
        margin-right: 0.5rem;
    }
</style>
""", unsafe_allow_html=True)

# Core RAG Classes for Snowflake Streamlit
class SnowflakeMultimodalRAG:
    """Multimodal RAG implementing CORTEX_SEARCH_MULTIMODAL_complete approach"""
    
    def __init__(self, session, search_service):
        self.session = session
        self.search_service = search_service
    
    def embed_query(self, query_text: str) -> List[float]:
        """Generate embedding for query"""
        sql_output = self.session.sql(
            f"""SELECT SNOWFLAKE.CORTEX.EMBED_TEXT_1024('voyage-multimodal-3', 
                'Represent the query for retrieving supporting documents: {query_text}')"""
        ).collect()
        return list(sql_output[0].asDict().values())[0]
    
    def search_and_analyze(self, query_text: str) -> Dict[str, Any]:
        """Complete multimodal search and analysis (CORTEX_SEARCH_MULTIMODAL_complete approach)"""
        # Step 1: Generate embedding
        query_vector = self.embed_query(query_text)
        
        # Step 2: Multi-index search
        resp = self.search_service.search(
            multi_index_query={
                "TEXT": [{"text": query_text}],
                "VECTOR_MAIN": [{"vector": query_vector}]
            },
            columns=["TEXT", "PAGE_NUMBER", "IMAGE_FILEPATH", "VENDOR", "PRODUCT_ID", 
                    "PUMP_MODEL", "DATASHEET_TYPE", "SECTION_TITLE"],
            limit=5
        )
        
        results = resp.to_dict()["results"]
        
        if not results:
            return {
                "results": [],
                "top_result": None,
                "multimodal_answer": "No relevant information found in the pump datasheets.",
                "has_image": False
            }
        
        # Step 3: Get the top result (most relevant)
        top_result = results[0]
        top_page_path = top_result.get('IMAGE_FILEPATH')
        
        # Step 4: Generate multimodal answer using the top image (if available)
        if top_page_path:
            multimodal_answer = self._generate_multimodal_answer(top_page_path, query_text)
            has_image = True
        else:
            # Fallback to text-only answer
            multimodal_answer = self._generate_text_answer(results, query_text)
            has_image = False
        
        return {
            "results": results,
            "top_result": top_result,
            "multimodal_answer": multimodal_answer,
            "has_image": has_image,
            "image_path": top_page_path if has_image else None
        }
    
    def _generate_multimodal_answer(self, image_path: str, query_text: str) -> str:
        """Generate answer using multimodal LLM with image analysis"""
        sql = """
            SELECT AI_COMPLETE(
            'claude-3-7-sonnet',
            PROMPT(
            'Answer the question using the image {0}. Question: {1}',
            TO_FILE('@DEMODB.DATASHEET_RAG.MULTIMODAL_DEMO_INTERNAL', ?),
            ?
            )
            ) AS answer
        """
        
        try:
            row = self.session.sql(sql, params=[image_path, query_text]).collect()[0]
            return row["ANSWER"]
        except Exception as e:
            return f"Error generating multimodal answer: {str(e)}"
    
    def _generate_text_answer(self, results: List[Dict], query_text: str) -> str:
        """Generate text-only answer when no image is available"""
        if not results:
            return "No relevant information found."
        
        # Build context from search results
        context_parts = []
        for i, result in enumerate(results[:3], 1):
            vendor = result.get('VENDOR', 'Unknown')
            product = result.get('PRODUCT_ID', 'Unknown')
            page = result.get('PAGE_NUMBER', 'Unknown')
            text_content = str(result.get('TEXT', ''))[:400]
            
            context_parts.append(
                f"{i}. {vendor} {product} (Page {page}):\n{text_content}..."
            )
        
        context = "\n\n".join(context_parts)
        
        prompt = f"""
        Question: {query_text}
        
        Relevant pump datasheet information:
        {context}
        
        Provide a comprehensive technical answer based on the information above.
        Include specific details and cite sources.
        """
        
        sql = "SELECT SNOWFLAKE.CORTEX.COMPLETE('llama3.1-70b', ?) as answer"
        result = self.session.sql(sql, params=[prompt]).collect()[0]
        return result["ANSWER"]
    
    def get_image_data(self, image_path: str) -> bytes:
        """Attempt to retrieve image data from Snowflake stage"""
        try:
            # Try to get the image file from the stage
            sql = f"""
                SELECT GET_PRESIGNED_URL('@DEMODB.DATASHEET_RAG.MULTIMODAL_DEMO_INTERNAL', '{image_path}', 3600) as url
            """
            result = self.session.sql(sql).collect()
            if result:
                return result[0]["URL"]
            return None
        except Exception as e:
            st.error(f"Could not retrieve image: {str(e)}")
            return None

class SnowflakeHybridMultiHopRAG:
    """Multi-hop RAG optimized for Snowflake Streamlit"""
    
    def __init__(self, session, search_service):
        self.session = session
        self.search_service = search_service
        self.multimodal_rag = SnowflakeMultimodalRAG(session, search_service)
    
    def multi_hop_search(self, original_query: str, max_hops: int = 4, progress_callback=None) -> Dict[str, Any]:
        """Perform multi-hop search with progress tracking"""
        all_results = []
        search_history = []
        
        # HOP 1: Initial broad search
        if progress_callback:
            progress_callback(0.2, f"🔍 HOP 1: Initial search")
        
        # Use traditional search for multi-hop (not the complete multimodal analysis)
        raw_initial_results = self._search_documents(original_query, limit=12)
        initial_results = self._filter_and_rank_results(raw_initial_results, original_query)[:8]
        all_results.extend(initial_results)
        search_history.append({
            "hop": 1, 
            "query": original_query, 
            "results_count": len(initial_results),
            "description": "Initial multimodal search"
        })
        
        # Analyze coverage gaps
        found_vendors = set(r.get('VENDOR', 'Unknown') for r in initial_results)
        
        # Generate follow-up queries
        follow_up_queries = self._generate_follow_ups(original_query, found_vendors, initial_results)
        
        # HOP 2+: Targeted follow-up searches
        for hop_num, follow_up_query in enumerate(follow_up_queries, 2):
            if hop_num > max_hops:
                break
            
            if progress_callback:
                progress_callback(0.2 + (0.6 * (hop_num-1) / len(follow_up_queries)), 
                                f"🔍 HOP {hop_num}: Targeting missing vendors")
            
            raw_hop_results = self._search_documents(follow_up_query, limit=8)
            
            # Extract target vendors for better ranking
            target_vendors = {'Sulzer', 'Goulds', 'Fristam'}
            query_vendors = {v for v in target_vendors if v.lower() in follow_up_query.lower()}
            
            hop_results = self._filter_and_rank_results(raw_hop_results, follow_up_query, query_vendors)[:5]
            
            # Filter duplicates
            existing_paths = {r.get('IMAGE_FILEPATH') for r in all_results}
            new_results = [r for r in hop_results if r.get('IMAGE_FILEPATH') not in existing_paths]
            
            if new_results:
                all_results.extend(new_results)
                search_history.append({
                    "hop": hop_num, 
                    "query": follow_up_query, 
                    "results_count": len(new_results),
                    "description": f"Targeted search for {', '.join(query_vendors) if query_vendors else 'additional data'}"
                })
        
        if progress_callback:
            progress_callback(0.9, "🎯 Completing multi-hop analysis...")
        
        return {
            "original_query": original_query,
            "all_results": all_results,
            "search_history": search_history,
            "total_documents": len(all_results)
        }
    
    def _search_documents(self, query_text: str, limit: int = 10) -> List[Dict[str, Any]]:
        """Basic document search for multi-hop (without full multimodal analysis)"""
        query_vector = self.multimodal_rag.embed_query(query_text)
        
        resp = self.multimodal_rag.search_service.search(
            multi_index_query={
                "TEXT": [{"text": query_text}],
                "VECTOR_MAIN": [{"vector": query_vector}]
            },
            columns=["TEXT", "PAGE_NUMBER", "IMAGE_FILEPATH", "VENDOR", "PRODUCT_ID", 
                    "PUMP_MODEL", "DATASHEET_TYPE", "SECTION_TITLE"],
            limit=limit
        )
        
        return resp.to_dict()["results"]
    
    def _filter_and_rank_results(self, results: List[Dict], query: str, target_vendors: Set[str] = None) -> List[Dict]:
        """Filter and rank results based on relevance"""
        if not results:
            return results
            
        query_lower = query.lower()
        technical_terms = self._extract_technical_keywords(query_lower)
        
        scored_results = []
        for result in results:
            score = 0
            
            # Vendor relevance
            vendor = result.get('VENDOR', '').lower()
            if target_vendors and vendor.title() in target_vendors:
                score += 10
            
            # Section relevance
            section = result.get('SECTION_TITLE', '').lower()
            for term in technical_terms:
                if term in section:
                    score += 5
            
            # Text content relevance
            text_content = str(result.get('TEXT', '')).lower()
            for term in technical_terms:
                if term in text_content:
                    score += 2
            
            # Page number preference (avoid page 1 unless specifically relevant)
            page_num = result.get('PAGE_NUMBER', 1)
            try:
                page_num_int = int(page_num) if page_num is not None else 1
                if page_num_int > 1:
                    score += 1
            except (ValueError, TypeError):
                pass
            
            scored_results.append((score, result))
        
        scored_results.sort(key=lambda x: x[0], reverse=True)
        return [result for score, result in scored_results]
    
    def _extract_technical_keywords(self, query_lower: str) -> List[str]:
        """Extract relevant technical terms"""
        technical_keywords = {
            'efficiency', 'bep', 'npsh', 'flow', 'head', 'pressure', 'curve', 'performance',
            'suction', 'discharge', 'impeller', 'motor', 'power', 'speed', 'rpm',
            'api', 'standard', 'specification', 'rating', 'capacity', 'gpm', 'psi',
            'material', 'construction', 'temperature', 'operation', 'maintenance'
        }
        
        found_terms = []
        words = query_lower.split()
        for word in words:
            clean_word = word.strip('.,?!()[]')
            if clean_word in technical_keywords:
                found_terms.append(clean_word)
        
        return found_terms
    
    def _generate_follow_ups(self, original_query: str, found_vendors: set, initial_results: List[Dict] = None) -> List[str]:
        """Generate intelligent follow-up queries"""
        follow_ups = []
        query_lower = original_query.lower()
        
        major_vendors = ['Sulzer', 'Goulds', 'Fristam']
        missing_vendors = [v for v in major_vendors if v not in found_vendors]
        
        technical_terms = self._extract_technical_keywords(query_lower)
        
        # Context-specific follow-ups with model targeting
        if 'flow' in query_lower and 'rate' in query_lower:
            for vendor in missing_vendors[:2]:
                if vendor == 'Goulds':
                    follow_ups.append("Goulds 3196i flow rate capacity specifications performance")
                elif vendor == 'Fristam':
                    follow_ups.append("Fristam centrifugal pump flow rate operating range specifications")
                elif vendor == 'Sulzer':
                    follow_ups.append("Sulzer BE AHLSTAR flow rate head operating range")
                else:
                    follow_ups.append(f"{vendor} flow rate specifications")
        elif 'efficiency' in query_lower or 'performance' in query_lower:
            for vendor in missing_vendors[:2]:
                follow_ups.append(f"{vendor} efficiency performance curve specifications")
            if len(follow_ups) < 3:
                follow_ups.append("pump performance curve efficiency rating specifications")
        elif 'material' in query_lower or 'construction' in query_lower:
            for vendor in missing_vendors[:2]:
                follow_ups.append(f"{vendor} construction materials design specifications")
        else:
            for vendor in missing_vendors[:2]:
                if technical_terms:
                    follow_ups.append(f"{vendor} {' '.join(technical_terms[:2])}")
                else:
                    follow_ups.append(f"{vendor} specifications")
        
        return list(dict.fromkeys(follow_ups))[:3]
    
    def generate_hybrid_answer(self, search_data: Dict[str, Any], progress_callback=None) -> Dict[str, Any]:
        """Generate comprehensive hybrid answer"""
        if progress_callback:
            progress_callback(0.95, "🎯 Generating comprehensive answer...")
        
        query = search_data['original_query']
        results = search_data['all_results']
        
        # Enhanced context building for multi-hop results
        results_by_vendor = {}
        for result in results:
            vendor = result.get('VENDOR', 'Unknown')
            if vendor not in results_by_vendor:
                results_by_vendor[vendor] = []
            results_by_vendor[vendor].append(result)
        
        context_parts = []
        for vendor, vendor_results in results_by_vendor.items():
            context_parts.append(f"\n=== {vendor} Data ===")
            for result in vendor_results[:3]:  # Top 3 per vendor
                product = result.get('PRODUCT_ID', 'Unknown')
                page = result.get('PAGE_NUMBER', 'Unknown')
                section = result.get('SECTION_TITLE', 'General')
                text_content = str(result.get('TEXT', ''))[:400]
                
                context_parts.append(
                    f"Product: {product} (Page {page}, {section})\n"
                    f"Content: {text_content}..."
                )
        
        context = "\n".join(context_parts)
        
        prompt = f"""
        Question: {query}
        
        Multi-hop search results across pump datasheets from {len(search_data['search_history'])} search hops:
        {context}
        
        Provide comprehensive analysis:
        1. Answer the question using available information from all vendors
        2. Compare findings across different vendors (Sulzer, Goulds, Fristam)
        3. Highlight specific technical specifications and performance data
        4. Provide actionable engineering insights and recommendations
        5. Note any limitations or missing data
        
        Structure response with clear sections and cite specific sources.
        Focus on practical engineering value and cross-vendor comparisons.
        """
        
        sql = "SELECT SNOWFLAKE.CORTEX.COMPLETE('llama3.1-70b', ?) as answer"
        result = self.session.sql(sql, params=[prompt]).collect()[0]
        
        return {
            "query": query,
            "final_answer": result["ANSWER"],
            "documents_searched": search_data['total_documents'],
            "search_hops": len(search_data['search_history']),
            "search_history": search_data['search_history'],
            "vendor_coverage": list(results_by_vendor.keys())
        }

# Streamlit App Functions
@st.cache_resource
def initialize_snowflake_resources():
    """Initialize Snowflake resources using built-in session"""
    try:
        # Use Snowflake's built-in session for Streamlit apps
        session = get_active_session()
        
        root = Root(session)
        search_service = (root
            .databases["DEMODB"]
            .schemas["DATASHEET_RAG"]
            .cortex_search_services["DATASHEET_CORTEX_SEARCH_SERVICE"]
        )
        return session, search_service
    except Exception as e:
        st.error(f"Failed to initialize Snowflake resources: {str(e)}")
        st.info("Make sure the DATASHEET_CORTEX_SEARCH_SERVICE exists and you have proper permissions.")
        st.stop()

def display_search_results(results: List[Dict], title: str, max_display: int = 5):
    """Display search results with enhanced formatting"""
    st.markdown(f"### 📋 {title}")
    
    if not results:
        st.info("No results found.")
        return
    
    # Group by vendor for better organization
    vendor_groups = {}
    for result in results[:max_display]:
        vendor = result.get('VENDOR', 'Unknown')
        if vendor not in vendor_groups:
            vendor_groups[vendor] = []
        vendor_groups[vendor].append(result)
    
    for vendor, vendor_results in vendor_groups.items():
        st.markdown(f"#### 🏭 {vendor}")
        
        for i, result in enumerate(vendor_results, 1):
            product = result.get('PRODUCT_ID', 'N/A')
            page = result.get('PAGE_NUMBER', 'N/A')
            section = result.get('SECTION_TITLE', 'N/A')
            
            with st.expander(f"{product} - Page {page} ({section})"):
                text_content = str(result.get('TEXT', 'No text available'))
                st.text_area("Content", text_content[:800], height=150, disabled=True)
                
                col1, col2, col3 = st.columns(3)
                with col1:
                    st.markdown(f"**Datasheet Type:** {result.get('DATASHEET_TYPE', 'N/A')}")
                with col2:
                    st.markdown(f"**Pump Model:** {result.get('PUMP_MODEL', 'N/A')}")
                with col3:
                    if result.get('IMAGE_FILEPATH'):
                        st.markdown("**📷 Has Image**")

def display_hop_progress(search_history: List[Dict]):
    """Display multi-hop search progress"""
    st.markdown("### 🔄 Multi-Hop Search Progress")
    
    for hop_info in search_history:
        hop_num = hop_info['hop']
        query = hop_info['query']
        results_count = hop_info['results_count']
        description = hop_info.get('description', 'Search step')
        
        with st.expander(f"📍 HOP {hop_num}: {description}", expanded=(hop_num==1)):
            col1, col2 = st.columns(2)
            with col1:
                st.metric("New Results Found", results_count)
            with col2:
                # Extract vendor from query if possible
                vendors = [v for v in ['Sulzer', 'Goulds', 'Fristam'] if v.lower() in query.lower()]
                st.metric("Target Vendors", len(vendors) if vendors else "General")
            
            if vendors:
                st.markdown(f"**Targeting:** {', '.join(vendors)}")
            st.markdown(f"**Query:** {query}")

# Main Streamlit App
def main():
    st.markdown('<h1 class="main-header">🚀 Pump Datasheet RAG</h1>', unsafe_allow_html=True)
    st.markdown("**Advanced multimodal and multi-hop RAG for pump engineering datasheets**")
    
    # Initialize Snowflake resources (cached for performance)
    session, search_service = initialize_snowflake_resources()
    
    # Initialize RAG systems
    multimodal_rag = SnowflakeMultimodalRAG(session, search_service)
    multihop_rag = SnowflakeHybridMultiHopRAG(session, search_service)
    
    # Sidebar
    with st.sidebar:
        st.header("🔧 Search Configuration")
        
        search_mode = st.radio(
            "Search Mode:",
            ["🔍 Multimodal Search", "🔗 Multi-Hop RAG"],
            help="Choose between single multimodal search or advanced multi-hop search"
        )
        
        st.divider()
        
        if search_mode == "🔍 Multimodal Search":
            st.info("💡 Multimodal search analyzes the TOP result with image using Claude-3.7-Sonnet")
            st.markdown("**Approach**: CORTEX_SEARCH_MULTIMODAL_complete - Single best result with visual analysis")
        else:
            max_hops = st.slider("Max Hops", 2, 5, 4)
        
        st.divider()
        
        # Pre-defined queries optimized for your data
        st.subheader("💡 Optimized Example Queries")
        
        if search_mode == "🔍 Multimodal Search":
            st.markdown("**Multimodal Demo Questions:**")
            examples = [
                "What is the maximum operating temperature specified for the Goulds 3196 pump?",  # Text extraction
                "What pump model number curve reaches the highest head at 200 GPM in the Fristam chart?",  # Chart reading - requires analyzing curves
                "What materials are listed in the construction specifications for Sulzer AHLSTAR pumps?",  # Text extraction
                "At what flow rate do the pump curves start to flatten out in the Fristam chart?",  # Chart/graph analysis
                "What is the maximum allowable working pressure rating for the BE series pump?",  # Text specification
                "Which pump model curve shows the steepest drop-off after 400 GPM in the Fristam chart?"  # Chart reading - curve analysis
            ]
            
            # Highlight the two key demo questions
            st.info("🎯 **Key Demo Questions:**")
            st.markdown("📄 **Text Extraction**: *What is the maximum operating temperature specified for the Goulds 3196 pump?*")
            st.markdown("📈 **Chart Reading**: *What pump model number curve reaches the highest head at 200 GPM in the Fristam chart?*")
            
        else:
            st.markdown("**Multi-Hop RAG Questions:**")
            examples = [
                "Compare flow rates and operating ranges between Sulzer BE, Goulds 3196i, and Fristam pumps",
                "What are the technical specifications and construction materials of Sulzer AHLSTAR pumps?",
                "Which pumps are best suited for high-flow industrial applications and what are their advantages?",
                "Compare efficiency ratings and performance curves between Sulzer, Goulds, and Fristam pumps",
                "What materials and design features are used in Goulds 3196i ANSI process pumps?"
            ]
        
        selected_example = st.selectbox("Select example:", [""] + examples)
        if st.button("Use Example", disabled=not selected_example):
            st.session_state.query_input = selected_example
    
    # Main query input with mode-specific guidance
    if search_mode == "🔍 Multimodal Search":
        placeholder_text = "e.g., What pump model number curve reaches the highest head at 200 GPM in the Fristam chart?"
        help_text = "Ask about specific values in charts, graphs, or text specifications from pump datasheets"
    else:
        placeholder_text = "e.g., Compare flow rates between Sulzer BE and Goulds 3196i pumps"
        help_text = "Ask complex questions requiring analysis across multiple vendors and documents"
    
    query = st.text_input(
        "🔍 Enter your pump engineering question:",
        value=st.session_state.get('query_input', ''),
        placeholder=placeholder_text,
        help=help_text
    )
    
    # Clear the session state after use
    if 'query_input' in st.session_state:
        del st.session_state.query_input
    
    # Search execution
    if st.button("🚀 Search", type="primary") and query:
        
        if search_mode == "🔍 Multimodal Search":
            # Multimodal Search (CORTEX_SEARCH_MULTIMODAL_complete approach)
            st.markdown("## 🔍 Multimodal Search & Analysis")
            st.markdown("*Following CORTEX_SEARCH_MULTIMODAL_complete approach: Find top result + analyze with Claude-3.7-Sonnet*")
            
            with st.spinner("Performing multimodal search and analysis..."):
                result_data = multimodal_rag.search_and_analyze(query)
            
            # Display metrics
            col1, col2, col3, col4 = st.columns(4)
            with col1:
                st.metric("📄 Documents Found", len(result_data['results']))
            with col2:
                st.metric("🖼️ Visual Analysis", "✅" if result_data['has_image'] else "Text Only")
            with col3:
                st.metric("🎯 Top Result", "Analyzed")
            with col4:
                st.metric("🤖 LLM Used", "Claude-3.7-Sonnet" if result_data['has_image'] else "Llama3.1-70B")
            
            # Display top result details
            if result_data['top_result']:
                st.markdown("### 📋 Top Result (Analyzed)")
                top = result_data['top_result']
                
                col1, col2 = st.columns([2, 1])
                with col1:
                    st.markdown(f"**{top.get('VENDOR', 'N/A')} {top.get('PRODUCT_ID', 'N/A')}** - Page {top.get('PAGE_NUMBER', 'N/A')}")
                    st.markdown(f"**Section:** {top.get('SECTION_TITLE', 'N/A')}")
                    st.markdown(f"**Datasheet Type:** {top.get('DATASHEET_TYPE', 'N/A')}")
                with col2:
                    if result_data['has_image']:
                        st.success("📷 Image Analyzed")
                        st.markdown(f"**Path:** `{result_data['image_path']}`")
                    else:
                        st.info("📄 Text Analysis")
                
                # Show text content and image
                with st.expander("📄 Document Content & Image"):
                    # Display the image if available
                    if result_data['has_image'] and result_data['image_path']:
                        st.markdown("#### 🖼️ Analyzed Image")
                        st.markdown(f"**Image Path:** `{result_data['image_path']}`")
                        st.info("💡 This image was analyzed by Claude-3.7-Sonnet multimodal LLM")
                        
                        try:
                            # Try to get a presigned URL for the image
                            image_url = multimodal_rag.get_image_data(result_data['image_path'])
                            
                            if image_url:
                                # Display the actual image
                                st.image(image_url, caption=f"Pump Datasheet: {result_data['image_path']}", use_column_width=True)
                                st.success("✅ Successfully loaded image from Snowflake stage")
                            else:
                                # Fallback to placeholder
                                st.warning("⚠️ Could not load image from Snowflake stage")
                                st.markdown("**Image Information:**")
                                st.code(f"""
Image File: {result_data['image_path']}
Stage: @DEMODB.DATASHEET_RAG.MULTIMODAL_DEMO_INTERNAL
Status: Available for analysis but not displayable in Streamlit
Analysis: Completed by Claude-3.7-Sonnet multimodal LLM
""")
                                
                        except Exception as e:
                            st.error(f"Error loading image: {str(e)}")
                            st.markdown("**Image Analysis Information:**")
                            st.code(f"""
Image File: {result_data['image_path']}
Stage Location: @DEMODB.DATASHEET_RAG.MULTIMODAL_DEMO_INTERNAL
Analysis Status: ✅ Successfully analyzed by Claude-3.7-Sonnet
Display Status: ❌ Could not display in Streamlit interface
""")
                    
                    st.markdown("#### 📄 Document Text Content")
                    text_content = str(top.get('TEXT', 'No text available'))
                    st.text_area("Content", text_content[:1000], height=200, disabled=True)
            
            # Show all search results if requested
            if st.checkbox("Show all search results"):
                display_search_results(result_data['results'], "All Search Results", max_display=5)
            
            # Display the multimodal answer
            st.markdown("### 💡 Multimodal Analysis Result")
            if result_data['has_image']:
                st.success("🖼️ **Visual Analysis**: Answer generated using Claude-3.7-Sonnet with image analysis")
            else:
                st.info("📄 **Text Analysis**: Answer generated using text content only")
            
            st.markdown(result_data['multimodal_answer'])
        
        else:
            # Multi-Hop RAG
            st.markdown("## 🔗 Multi-Hop RAG Analysis")
            
            # Progress tracking
            progress_bar = st.progress(0)
            status_text = st.empty()
            
            def update_progress(value, text):
                progress_bar.progress(value)
                status_text.text(text)
            
            # Execute multi-hop search
            search_results = multihop_rag.multi_hop_search(
                query, 
                max_hops=max_hops, 
                progress_callback=update_progress
            )
            
            # Display search progress
            display_hop_progress(search_results['search_history'])
            
            # Display metrics
            col1, col2, col3, col4 = st.columns(4)
            with col1:
                st.metric("📄 Total Documents", search_results['total_documents'])
            with col2:
                st.metric("🔄 Search Hops", len(search_results['search_history']))
            with col3:
                vendors = set(r.get('VENDOR', 'Unknown') for r in search_results['all_results'])
                st.metric("🏭 Vendors Found", len(vendors))
            with col4:
                st.metric("🎯 Search Quality", "Enhanced")
            
            # Generate hybrid answer
            final_result = multihop_rag.generate_hybrid_answer(
                search_results, 
                progress_callback=update_progress
            )
            
            status_text.text("✅ Multi-hop analysis complete!")
            progress_bar.progress(1.0)
            
            # Display final answer
            st.markdown("### 💡 Comprehensive Multi-Hop Analysis")
            st.markdown(final_result['final_answer'])
            
            # Show detailed results if requested
            if st.checkbox("Show detailed search results"):
                display_search_results(search_results['all_results'], "All Multi-Hop Results", max_display=10)
    
    # Footer
    st.markdown("---")
    st.markdown("🔧 **Pump Datasheet RAG** | Powered by Snowflake Cortex Search | Running in Snowflake Streamlit")

if __name__ == "__main__":
    main()

