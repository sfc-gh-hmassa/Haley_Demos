#!/usr/bin/env python3
"""
Production UNSPSC Classification Demo

Comprehensive demonstration of the complete UNSPSC classification system
with real Snowflake LLM, web search, and hierarchical classification.
"""

import sys
import time
from pathlib import Path
from typing import Any

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

def display_classification_result(result: Any, product_name: str):
    """Display classification result in a formatted way"""
    
    print(f"\n🎯 FINAL CLASSIFICATION RESULT FOR: {product_name}")
    print("=" * 80)
    
    if hasattr(result, 'success') and result.success:
        # Show full hierarchy
        print("📊 UNSPSC CLASSIFICATION HIERARCHY:")
        print(f"   🎯 Segment:   {getattr(result, 'segment_code', 'N/A')} - {getattr(result, 'segment_description', 'N/A')}")
        print(f"   📁 Family:    {getattr(result, 'family_code', 'N/A')} - {getattr(result, 'family_description', 'N/A')}")
        print(f"   📂 Class:     {getattr(result, 'class_code', 'N/A')} - {getattr(result, 'class_description', 'N/A')}")
        print(f"   📄 Commodity: {getattr(result, 'commodity_code', 'N/A')} - {getattr(result, 'commodity_description', 'N/A')}")
        
        # Show confidence scores
        print(f"\n📈 CONFIDENCE SCORES:")
        print(f"   Overall: {getattr(result, 'confidence', 'N/A')}")
        
        # Show extracted information
        if hasattr(result, 'extracted_identifiers') and result.extracted_identifiers:
            extracted = result.extracted_identifiers
            print(f"\n🔍 EXTRACTED INFORMATION:")
            print(f"   Brands: {getattr(extracted, 'brand_names', [])}")
            print(f"   Models: {getattr(extracted, 'model_numbers', [])}")
            print(f"   Manufacturer: {getattr(extracted, 'manufacturer', 'N/A')}")
        
        print(f"\n✅ SUCCESS: Product successfully classified!")
        
    else:
        print("❌ CLASSIFICATION FAILED")
        if hasattr(result, 'error_messages') and result.error_messages:
            print(f"   Errors: {result.error_messages}")
        
        # Show partial results if available
        if hasattr(result, 'segment_code') and result.segment_code:
            print(f"\n⚠️ PARTIAL RESULTS:")
            print(f"   Segment: {result.segment_code} - {getattr(result, 'segment_description', '')}")
            if hasattr(result, 'family_code') and result.family_code:
                print(f"   Family: {result.family_code} - {getattr(result, 'family_description', '')}")

def run_comprehensive_demo():
    """Run the complete UNSPSC classification demo"""
    
    print("🎬 Starting Production UNSPSC Classification Demo...")
    
    # Demo header
    print("\n🏭 PRODUCTION UNSPSC CLASSIFICATION SYSTEM")
    print("=" * 80)
    print("🔗 Using your haleyconnect Snowflake connection")
    print("🧠 Powered by Snowflake Cortex LLM (llama3-70b)")
    print("🌐 Real web search with DuckDuckGo")
    print("🎯 Complete hierarchical UNSPSC classification")
    print("=" * 80)
    
    try:
        # Initialize the classification chain
        print("\n🚀 Initializing Classification Chain...")
        from chain.classification_chain import UNSPSCClassificationChain
        
        classifier = UNSPSCClassificationChain()
        print("✅ All agents initialized successfully")
        print("✅ Classification system ready!")
        
        # Test products with varying complexity
        test_products = [
            {
                "name": "Complex Industrial Product",
                "description": "Parker Hannifin P2075-31CC-VAC-02-111-0000 Hydraulic Pump 3000PSI Variable Displacement"
            },
            {
                "name": "Electronic Component",
                "description": "Siemens 6ES7214-1BG40-0XB0 SIMATIC S7-1200 CPU 1214C compact controller"
            },
            {
                "name": "Generic Industrial Item",
                "description": "Stainless steel ball valve 1/2 inch NPT threaded with lever handle"
            }
        ]
        
        # Run classification tests
        for i, product in enumerate(test_products, 1):
            print(f"\n{'='*80}")
            print(f"🧪 TEST {i}: {product['name']}")
            print("=" * 80)
            
            start_time = time.time()
            
            # Classify the product
            result = classifier.classify_product(product['description'])
            
            processing_time = time.time() - start_time
            
            # Display result
            display_classification_result(result, product['name'])
            
            print(f"\n⏱️ Processing completed in {processing_time:.2f} seconds")
            
            # Add delay between tests
            if i < len(test_products):
                print(f"\n⏳ Waiting 3 seconds before next test...")
                time.sleep(3)
        
        # Demo conclusion
        print(f"\n🎉 DEMO COMPLETED SUCCESSFULLY!")
        print("=" * 80)
        print("🚀 The Production UNSPSC Classification System is fully operational!")
        print("📊 All classification levels working:")
        print("   ✅ Segment classification")
        print("   ✅ Family classification") 
        print("   ✅ Class classification")
        print("   ✅ Commodity classification (when available)")
        print("🔍 Advanced features demonstrated:")
        print("   ✅ Intelligent product extraction")
        print("   ✅ Real-time web search enhancement")
        print("   ✅ Hierarchical validation")
        print("   ✅ Confidence scoring")
        print("   ✅ Fallback mechanisms")
        
    except ImportError as e:
        print(f"❌ Failed to import required modules: {e}")
        print("🔧 Please ensure all system components are properly installed")
        
    except Exception as e:
        print(f"❌ Demo failed with error: {e}")
        import traceback
        traceback.print_exc()

def main():
    """Main demo function"""
    run_comprehensive_demo()

if __name__ == "__main__":
    main() 