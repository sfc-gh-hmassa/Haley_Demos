"""
🌐 Web Search Intelligence Demo

This script demonstrates exactly how the UNSPSC Classification System uses 
intelligent web search to enhance product understanding.

Shows the exact same data and process the classifier uses internally.
"""

from extractors import LLMProductExtractor, WebSearcher
from config import test_connection

def demonstrate_web_search_intelligence(product_name, product_description):
    """
    Demonstrate web search exactly as used by the classifier.
    Shows all the data that gets returned and used.
    """
    print("="*80)
    print(f"🎯 **{product_name}**")
    print("="*80)
    print(f"📝 Original: {product_description}")
    print()
    
    # STEP 1: LLM Extraction (exactly as classifier does)
    print("🧠 **STEP 1: LLM EXTRACTION** (Finding what to search for)")
    print("-" * 50)
    
    extracted_info = extractor.extract_all(product_description)
    search_terms = extractor.get_search_terms(extracted_info)
    
    print(f"📊 **EXTRACTION RESULTS:**")
    print(f"   🏷️  Brands: {extracted_info.brand_names}")
    print(f"   🔢  Models: {extracted_info.model_numbers}")
    print(f"   📋  Serials: {extracted_info.serial_numbers}")
    print(f"   🎯  Key Identifiers: {extracted_info.key_identifiers}")
    print(f"   🌐  Search Worthy Terms: {extracted_info.search_worthy_terms}")
    print(f"   🏭  Manufacturer: {extracted_info.manufacturer}")
    print(f"   📈  Confidence: {extracted_info.confidence_scores.get('overall_extraction', 0.0):.1%}")
    print(f"   🔍  Final Search Terms: {search_terms}")
    print()
    
    # STEP 2: Web Search (exactly as classifier does)
    print("🌐 **STEP 2: WEB SEARCH** (DuckDuckGo Intelligence Gathering)")
    print("-" * 50)
    
    web_info = web_searcher.search_product_info(search_terms)
    
    print(f"📊 **WEB SEARCH RESULTS:**")
    print(f"   📄  Total Results: {len(web_info.search_results)}")
    print(f"   📂  Product Category: {web_info.product_category or 'Not identified'}")
    print(f"   🎯  Applications: {web_info.applications or 'None identified'}")
    print(f"   📏  Specifications: {web_info.specifications or 'None identified'}")
    print(f"   📈  Analysis Confidence: {web_info.confidence}")
    print()
    
    # STEP 3: Individual Search Results (detailed view)
    if web_info.search_results:
        print("🔍 **DETAILED SEARCH RESULTS:**")
        print("-" * 50)
        
        for i, result in enumerate(web_info.search_results[:6], 1):  # Show top 6
            print(f"   **Result #{i}:**")
            print(f"      🔍 Query: {result.query}")
            print(f"      📰 Title: {result.title[:80]}..." if len(result.title) > 80 else f"      📰 Title: {result.title}")
            print(f"      📝 Snippet: {result.snippet[:120]}..." if len(result.snippet) > 120 else f"      📝 Snippet: {result.snippet}")
            print(f"      🔗 URL: {result.url}")
            print(f"      📊 Relevance: {result.relevance_score:.2f}")
            print()
    
    # STEP 4: Enhanced Summary (exactly as classifier creates)
    print("📋 **STEP 3: ENHANCED SUMMARY** (How web intelligence enhances understanding)")
    print("-" * 50)
    
    enhanced_summary = web_searcher.create_enhanced_summary(product_description, web_info)
    print(f"✨ **ENHANCED PRODUCT UNDERSTANDING:**")
    print(f"   {enhanced_summary}")
    print()
    
    return {
        'extracted_info': extracted_info,
        'search_terms': search_terms,
        'web_info': web_info,
        'enhanced_summary': enhanced_summary
    }

def main():
    """Main demonstration function"""
    print("🌐 **WEB SEARCH INTELLIGENCE DEMO**")
    print("=" * 60)
    print("This demonstrates exactly how the UNSPSC Classification System")
    print("uses intelligent web search to enhance product understanding.")
    print()
    
    # Step 1: Test Connection
    print("🔗 **STEP 1: Test Connection**")
    print("-" * 30)
    print("🔍 Testing haleyconnect Snowflake connection...")
    connection_success = test_connection("haleyconnect")
    
    if connection_success:
        print("✅ Connection successful! Ready to demonstrate web search intelligence.")
    else:
        print("❌ Connection failed. Please check your haleyconnect setup.")
        return
    print()
    
    # Step 2: Initialize Components (exactly as classifier does)
    print("🧠 **STEP 2: Initialize Components**")
    print("-" * 30)
    print("🔧 Initializing components...")
    
    global extractor, web_searcher
    
    # LLM extractor for intelligent term identification 
    extractor = LLMProductExtractor()
    
    # Web searcher with same settings as classifier
    web_searcher = WebSearcher(max_searches=3, delay_between_searches=0.5)
    
    print("✅ Components initialized (same as classification chain)")
    print()
    
    # Step 3: Test Products
    print("🎯 **STEP 3: Test Products**")
    print("-" * 30)
    
    # Test products - MODIFY THESE TO TEST YOUR OWN PRODUCTS!
    TEST_PRODUCTS = {
        "Industrial Pump": "Parker Hannifin P2075 hydraulic pump with 3000 PSI rating",
        
        "Technical Equipment": "Siemens S7-1200 CPU 1214C DC/DC/DC programmable logic controller",
        
        "Maintenance Record": "06H-100101-1 Performed scheduled preventative maintenance on hydraulic pump #3, checked fluid levels and inspected hoses for leaks"
    }
    
    print(f"📝 Test products loaded: {len(TEST_PRODUCTS)} products")
    print("💡 Modify TEST_PRODUCTS dictionary in the script to test your own products!")
    print()
    
    # Step 4: Run Demonstrations
    print("🚀 **STEP 4: Run Web Search Demonstrations**")
    print("-" * 30)
    
    results = {}
    
    for product_name, product_description in TEST_PRODUCTS.items():
        try:
            results[product_name] = demonstrate_web_search_intelligence(product_name, product_description)
        except Exception as e:
            print(f"❌ Error processing {product_name}: {e}")
            print()
    
    print(f"🎉 **DEMONSTRATION COMPLETE!** Processed {len(results)} products.")
    print()
    
    # Step 5: Summary Analysis
    print("📊 **STEP 5: Summary Analysis**")
    print("-" * 30)
    print("📊 **WEB SEARCH INTELLIGENCE SUMMARY**")
    print("=" * 60)
    
    total_searches = 0
    total_results = 0
    categories_found = set()
    applications_found = set()
    specifications_found = set()
    
    for product_name, result_data in results.items():
        web_info = result_data['web_info']
        search_terms = result_data['search_terms']
        
        total_searches += len(search_terms)
        total_results += len(web_info.search_results)
        
        if web_info.product_category:
            categories_found.add(web_info.product_category)
        
        applications_found.update(web_info.applications)
        specifications_found.update(web_info.specifications)
        
        print(f"🎯 **{product_name}:**")
        print(f"   🔍 Search Terms: {len(search_terms)}")
        print(f"   📄 Web Results: {len(web_info.search_results)}")
        print(f"   📂 Category: {web_info.product_category or 'None'}")
        print(f"   📈 Confidence: {web_info.confidence}")
        print()
    
    print(f"📈 **OVERALL STATISTICS:**")
    print(f"   🔍 Total Search Terms Used: {total_searches}")
    print(f"   📄 Total Web Results Found: {total_results}")
    print(f"   📂 Product Categories Identified: {len(categories_found)}")
    print(f"   🎯 Applications Discovered: {len(applications_found)}")
    print(f"   📏 Specifications Found: {len(specifications_found)}")
    print()
    
    if categories_found:
        print(f"📂 **Categories Found:** {', '.join(sorted(categories_found))}")
    if applications_found:
        print(f"🎯 **Applications Found:** {', '.join(sorted(applications_found))}")
    if specifications_found:
        print(f"📏 **Specifications Found:** {', '.join(sorted(specifications_found))}")
    
    print()
    print("🎉 **SUMMARY: How Web Search Enhances Classification**")
    print("=" * 60)
    print()
    print("This script demonstrated the **exact web search process** used by the UNSPSC Classification System:")
    print()
    print("🧠 **Intelligence Extraction:**")
    print("- LLM identifies the most search-worthy terms from any product description")
    print("- No hardcoded lists - works on any product type")
    print("- Focuses on terms most likely to yield useful web intelligence")
    print()
    print("🌐 **Web Search Process:**")
    print("- Uses DuckDuckGo for real web search (no API keys needed)")
    print("- Searches multiple intelligent terms with proper rate limiting")
    print("- Analyzes results for product categories, applications, specifications")
    print()
    print("📊 **Intelligence Analysis:**")
    print("- Product Category Detection - pump, valve, motor, sensor, etc.")
    print("- Application Identification - industrial, automotive, aerospace, etc.")
    print("- Specification Extraction - pressure systems, flow control, etc.")
    print("- Confidence Scoring - evaluates the reliability of findings")
    print()
    print("✨ **Enhanced Understanding:**")
    print("- Enriched Product Summaries - combines original + web intelligence")
    print("- Better Classification Context - helps LLM make more accurate UNSPSC decisions")
    print("- Real-World Validation - confirms product understanding with current web data")
    print()
    print("🚀 **This is the same intelligence that powers the full classification system!**")
    print()
    print("The classifier uses this enhanced understanding to make more accurate UNSPSC")
    print("classifications by combining:")
    print("- Original product descriptions")
    print("- LLM-extracted key identifiers")
    print("- Web-gathered product intelligence")
    print("- Real-world context and specifications")

if __name__ == "__main__":
    main() 