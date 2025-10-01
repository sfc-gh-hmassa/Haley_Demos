#!/usr/bin/env python3
"""
🎯 UNSPSC Classification Demo with Mock Snowflake

This demo works even when Snowflake connection is not available.
It shows the complete system functionality with mock LLM responses.
"""

import sys
from pathlib import Path

# Add the current directory to the path for imports
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))

class MockSnowflakeLLM:
    """Mock LLM that provides realistic responses when Snowflake is unavailable"""
    
    def __init__(self, model="llama3-70b"):
        self.model = model
        print(f"🧠 Initialized Mock Snowflake LLM: {model}")
    
    def query(self, prompt: str) -> str:
        """Return mock responses based on prompt content"""
        prompt_lower = prompt.lower()
        
        # Mock extraction responses
        if "extract product identifiers" in prompt_lower:
            if "parker hannifin p2075" in prompt_lower:
                return '''
                {
                    "brand_names": ["Parker Hannifin"],
                    "model_numbers": ["P2075"],
                    "serial_numbers": [],
                    "part_numbers": ["P2075"],
                    "manufacturer": "Parker Hannifin",
                    "search_worthy_terms": ["Parker Hannifin P2075", "hydraulic pump", "3000 PSI"]
                }
                '''
            elif "siemens s7-1200" in prompt_lower:
                return '''
                {
                    "brand_names": ["Siemens"],
                    "model_numbers": ["S7-1200", "1214C"],
                    "serial_numbers": [],
                    "part_numbers": [],
                    "manufacturer": "Siemens", 
                    "search_worthy_terms": ["Siemens S7-1200", "programmable logic controller", "PLC"]
                }
                '''
        
        # Mock classification responses
        elif "classify this product into unspsc segment" in prompt_lower:
            if "hydraulic pump" in prompt_lower:
                return "40 - Industrial Equipment and Components"
            elif "programmable logic controller" in prompt_lower:
                return "39 - Electrical Systems and Components"
                
        elif "classify this product into unspsc family" in prompt_lower:
            if "hydraulic pump" in prompt_lower:
                return "4015 - Fluid power pumps"
            elif "programmable logic controller" in prompt_lower:
                return "3912 - Control systems"
                
        elif "classify this product into unspsc class" in prompt_lower:
            if "hydraulic pump" in prompt_lower:
                return "401515 - Hydraulic pumps"
            elif "programmable logic controller" in prompt_lower:
                return "391203 - Programmable logic controllers"
                
        elif "classify this product into unspsc commodity" in prompt_lower:
            if "hydraulic pump" in prompt_lower:
                return "40151509 - Hydraulic gear pumps"
            elif "programmable logic controller" in prompt_lower:
                return "39120301 - Programmable logic controllers PLCs"
        
        # Connection test
        elif "connection test successful" in prompt_lower:
            return "Connection test successful - Mock LLM is working!"
            
        # Default response
        return f"Mock response for: {prompt[:50]}..."

def mock_snowflake_setup():
    """Set up mock Snowflake components"""
    print("🎭 **MOCK SNOWFLAKE SETUP**")
    print("=" * 50)
    print("⚠️  Your Snowflake connection is not available (IP restriction)")
    print("✅ Using mock LLM responses to demonstrate the system")
    print("💡 The web search functionality will still work with real data!")
    print()
    
    # Replace the real LLM with mock
    import config.snowflake_config as config_module
    config_module._llm = MockSnowflakeLLM()
    
    return True

def run_demo():
    """Run the classification demo with mock Snowflake"""
    print("🎯 **UNSPSC CLASSIFICATION DEMO - MOCK MODE**")
    print("=" * 60)
    
    # Set up mock Snowflake
    mock_snowflake_setup()
    
    # Import components
    from extractors import LLMProductExtractor, WebSearcher
    from agents.product_summarizer import ProductSummarizer
    
    # Initialize components
    print("🔧 Initializing system components...")
    extractor = LLMProductExtractor()
    web_searcher = WebSearcher(max_searches=2, delay_between_searches=0.5)
    summarizer = ProductSummarizer()
    print("✅ Components ready!")
    print()
    
    # Demo products
    demo_products = {
        "Industrial Pump": "Parker Hannifin P2075 hydraulic pump with 3000 PSI rating",
        "PLC Controller": "Siemens S7-1200 CPU 1214C DC/DC/DC programmable logic controller",
    }
    
    for product_name, product_desc in demo_products.items():
        print("=" * 80)
        print(f"🎯 **CLASSIFYING: {product_name}**")
        print("=" * 80)
        print(f"📝 Description: {product_desc}")
        print()
        
        try:
            # Step 1: Extract identifiers
            print("🧠 **STEP 1: LLM EXTRACTION**")
            print("-" * 40)
            extracted_info = extractor.extract_all(product_desc)
            search_terms = extractor.get_search_terms(extracted_info)
            print()
            
            # Step 2: Web search
            print("🌐 **STEP 2: WEB SEARCH**")
            print("-" * 40)
            web_info = web_searcher.search_product_info(search_terms)
            print(f"   📄 Found {len(web_info.search_results)} web results")
            print(f"   📂 Category: {web_info.product_category or 'Not identified'}")
            print(f"   🎯 Applications: {web_info.applications or 'None'}")
            print()
            
            # Step 3: Enhanced summary
            print("📋 **STEP 3: ENHANCED SUMMARY**")
            print("-" * 40)
            enhanced_summary = summarizer.summarize_product(product_desc, extracted_info, web_info)
            print(f"✨ Enhanced Description:")
            print(f"   {enhanced_summary}")
            print()
            
            # Step 4: Mock classification
            print("🎯 **STEP 4: MOCK CLASSIFICATION**")
            print("-" * 40)
            
            # Mock the classification process
            if "pump" in product_desc.lower():
                print("   🎯 Segment: 40 - Industrial Equipment and Components")
                print("   📂 Family: 4015 - Fluid power pumps") 
                print("   📋 Class: 401515 - Hydraulic pumps")
                print("   🏷️ Commodity: 40151509 - Hydraulic gear pumps")
                print("   ✅ **FINAL CODE: 40151509** (8-digit commodity)")
            elif "controller" in product_desc.lower():
                print("   🎯 Segment: 39 - Electrical Systems and Components")
                print("   📂 Family: 3912 - Control systems")
                print("   📋 Class: 391203 - Programmable logic controllers") 
                print("   🏷️ Commodity: 39120301 - Programmable logic controllers PLCs")
                print("   ✅ **FINAL CODE: 39120301** (8-digit commodity)")
            
            print("   📊 Confidence: High (Mock)")
            print()
            
        except Exception as e:
            print(f"❌ Error processing {product_name}: {e}")
            print()
    
    print("🎉 **DEMO COMPLETE!**")
    print("=" * 60)
    print("📊 **WHAT WAS DEMONSTRATED:**")
    print("✅ LLM extraction (with mock responses)")
    print("✅ Real web search with DuckDuckGo")
    print("✅ Product intelligence analysis")
    print("✅ Enhanced product summaries")
    print("✅ Complete UNSPSC classification flow")
    print()
    print("💡 **TO USE WITH REAL SNOWFLAKE:**")
    print("1. Contact your Snowflake admin to add your IP to the allowlist")
    print("2. Or use the setup_snowflake.py script for alternative authentication")
    print("3. Once connected, all mock responses will be replaced with real LLM")

if __name__ == "__main__":
    run_demo()
