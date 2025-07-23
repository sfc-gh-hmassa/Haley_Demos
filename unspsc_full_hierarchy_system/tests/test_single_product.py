#!/usr/bin/env python3
"""
Single Product Classification Test

Test the classification system on a specific product description.
"""

import sys
import time
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

def test_single_product(product_description: str):
    """Test classification of a single product"""
    
    print("🎯 SINGLE PRODUCT CLASSIFICATION TEST")
    print("=" * 60)
    print(f"Product: {product_description}")
    print("=" * 60)
    
    try:
        # Step-by-step classification with detailed output
        print("\n1️⃣ Testing LLM extraction...")
        from extractors.llm_extractor import LLMProductExtractor
        
        extractor = LLMProductExtractor()
        extracted = extractor.extract_all(product_description)
        
        print("\n2️⃣ Testing web search...")
        from extractors.web_searcher import WebSearcher
        
        searcher = WebSearcher(max_searches=2, delay_between_searches=1.0)
        search_terms = extractor.get_search_terms(extracted)
        web_results = None
        
        if search_terms:
            web_results = searcher.search_product_info(search_terms[:2])
            print(f"✅ Web search completed")
        else:
            print("⚠️ No search terms generated")
        
        print("\n3️⃣ Creating product summary...")
        from agents.product_summarizer import ProductSummarizer
        
        summarizer = ProductSummarizer()
        summary = summarizer.summarize_product(product_description, extracted, web_results)
        print(f"✅ Summary: {summary[:150]}...")
        
        print("\n4️⃣ Running full classification chain...")
        from chain.classification_chain import UNSPSCClassificationChain
        
        start_time = time.time()
        classifier = UNSPSCClassificationChain()
        result = classifier.classify_product(product_description)
        processing_time = time.time() - start_time
        
        print(f"\n🎯 CLASSIFICATION RESULTS:")
        print("=" * 60)
        
        if hasattr(result, 'success') and result.success:
            print("✅ CLASSIFICATION SUCCESSFUL!")
            print(f"\n📊 UNSPSC HIERARCHY:")
            print(f"   🎯 Segment: {getattr(result, 'segment_code', 'N/A')} - {getattr(result, 'segment_description', 'N/A')}")
            print(f"   📁 Family:  {getattr(result, 'family_code', 'N/A')} - {getattr(result, 'family_description', 'N/A')}")
            print(f"   📂 Class:   {getattr(result, 'class_code', 'N/A')} - {getattr(result, 'class_description', 'N/A')}")
            print(f"   📄 Commodity: {getattr(result, 'commodity_code', 'N/A')} - {getattr(result, 'commodity_description', 'N/A')}")
            
            print(f"\n📈 CONFIDENCE: {getattr(result, 'confidence', 'N/A')}")
            print(f"⏱️ PROCESSING TIME: {processing_time:.2f} seconds")
            
            # Show final UNSPSC code
            if hasattr(result, 'final_unspsc_code') and result.final_unspsc_code:
                print(f"\n🏷️ FINAL UNSPSC CODE: {result.final_unspsc_code}")
            
        else:
            print("❌ CLASSIFICATION FAILED")
            if hasattr(result, 'error_messages') and result.error_messages:
                print(f"   Errors: {result.error_messages}")
            
            # Show any partial results
            if hasattr(result, 'segment_code') and result.segment_code:
                print(f"\n⚠️ PARTIAL RESULTS:")
                print(f"   Segment: {result.segment_code} - {getattr(result, 'segment_description', '')}")
                if hasattr(result, 'family_code') and result.family_code:
                    print(f"   Family: {result.family_code} - {getattr(result, 'family_description', '')}")
        
        # Show extracted information details
        if hasattr(result, 'extracted_identifiers') and result.extracted_identifiers:
            extracted = result.extracted_identifiers
            print(f"\n🔍 EXTRACTED IDENTIFIERS:")
            print(f"   Brands: {getattr(extracted, 'brand_names', [])}")
            print(f"   Models: {getattr(extracted, 'model_numbers', [])}")
            print(f"   Serials: {getattr(extracted, 'serial_numbers', [])}")
            print(f"   Manufacturer: {getattr(extracted, 'manufacturer', 'N/A')}")
            print(f"   Search Terms: {getattr(extracted, 'search_worthy_terms', [])}")
        
        # Show web search results if available
        if hasattr(result, 'web_search_results') and result.web_search_results:
            web_data = result.web_search_results
            print(f"\n🌐 WEB SEARCH RESULTS:")
            if hasattr(web_data, 'product_category') and web_data.product_category:
                print(f"   Product Category: {web_data.product_category}")
            if hasattr(web_data, 'search_results') and web_data.search_results:
                print(f"   Search Results: {len(web_data.search_results)} found")
        
        print(f"\n🎉 TEST COMPLETED!")
        
    except Exception as e:
        import traceback
        print(f"❌ Test failed: {e}")
        print(traceback.format_exc())

def main():
    """Main test function"""
    # Test the specific product provided by user
    product_description = "06H-100101-1 Performed scheduled preventative maintenance on hydraulic pump #3, which included checking fluid levels, inspecting hoses for leaks and wear, and cleaning the intake strainer. All components were found to be within operational parameters, with no signs of leaks or abnormal wear detected. The pump is functioning normally and ready for continued service."
    
    test_single_product(product_description)

if __name__ == "__main__":
    main() 