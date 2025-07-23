#!/usr/bin/env python3
"""
🧠 UNSPSC Classification System - Enhanced Interactive Demo 

REFLECTION EDITION with Web Search & Segment Details

This interactive demo showcases the Production UNSPSC Classification System with:
- ✅ Always returns 8-digit codes (commodity or class + 00 padding)
- ✅ Intelligent commodity reflection - decides whether commodity match is good enough
- 🔍 Shows web search results when performed
- 🎯 Displays segment classification details
- ✅ Never returns below class level - minimum 6-digit class codes
- ✅ Smart fallback logic - class level when commodity isn't specific enough
- ✅ Production-ready accuracy - no overly generic classifications

🎯 MODIFY THE YOUR_PRODUCTS DICTIONARY TO TEST YOUR OWN PRODUCTS!
"""

import sys
from pathlib import Path
import time

# Add the current directory to the path for imports
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))

print("="*80)
print("🧠 UNSPSC CLASSIFICATION SYSTEM - ENHANCED INTERACTIVE DEMO")
print("🔍 Now showing Web Search Results & Segment Classification Details")
print("="*80)

try:
    # Test connection first
    from config import test_connection
    
    print("🔍 Testing haleyconnect connection...")
    if not test_connection("haleyconnect"):
        print("❌ Connection failed! Please check your haleyconnect setup.")
        sys.exit(1)
    print("✅ Connection successful!")
    
    # Initialize the classification chain
    from chain.classification_chain import UNSPSCClassificationChain
    
    print("🚀 Initializing classification system...")
    classifier = UNSPSCClassificationChain()
    print("✅ System ready!")
    
except Exception as e:
    print(f"❌ Error during setup: {e}")
    sys.exit(1)

def display_web_search_results(result):
    """Display detailed web search results if available"""
    if not result.web_search_results:
        print("🌐 Web Search: Not performed (sufficient information available)")
        return
    
    web_info = result.web_search_results
    print("🌐 WEB SEARCH RESULTS:")
    print("="*40)
    
    if hasattr(web_info, 'search_results') and web_info.search_results:
        for i, search_result in enumerate(web_info.search_results[:3], 1):
            print(f"🔍 Result {i}:")
            print(f"   Query: {search_result.query}")
            print(f"   Title: {search_result.title[:80]}...")
            print(f"   Snippet: {search_result.snippet[:120]}...")
            print(f"   Source: {search_result.url}")
            print()
    
    # Display aggregated intelligence
    if hasattr(web_info, 'product_category') and web_info.product_category:
        print(f"📋 Product Category: {web_info.product_category}")
    if hasattr(web_info, 'applications') and web_info.applications:
        print(f"🎯 Applications: {', '.join(web_info.applications)}")
    if hasattr(web_info, 'specifications') and web_info.specifications:
        print(f"📏 Specifications: {', '.join(web_info.specifications)}")

def display_segment_classification(result):
    """Display detailed segment classification"""
    print("🎯 SEGMENT CLASSIFICATION:")
    print("="*40)
    
    if result.segment_code and result.segment_description:
        print(f"✅ Classified into Segment: {result.segment_code}")
        print(f"📋 Description: {result.segment_description}")
        print(f"📊 Confidence: {getattr(result, 'segment_confidence', 'Not specified')}")
    else:
        print("❌ Segment classification failed")

def display_hierarchy_result(product_name, result):
    """Display classification result with enhanced details including web search and segment info"""
    print("\n" + "="*80)
    print(f"📦 PRODUCT: {product_name}")
    print(f"📝 Original: {result.original_description}")
    print("="*80)
    
    if hasattr(result, 'success') and result.success:
        # Show extracted identifiers
        if result.extracted_identifiers:
            print("🔧 EXTRACTED IDENTIFIERS:")
            extracted = result.extracted_identifiers
            if hasattr(extracted, 'brand_names') and extracted.brand_names:
                print(f"   🏢 Brands: {', '.join(extracted.brand_names)}")
            if hasattr(extracted, 'model_numbers') and extracted.model_numbers:
                print(f"   🔢 Models: {', '.join(extracted.model_numbers)}")
            if hasattr(extracted, 'manufacturer') and extracted.manufacturer:
                print(f"   🏭 Manufacturer: {extracted.manufacturer}")
            print()
        
        # Show web search results
        display_web_search_results(result)
        print()
        
        # Show segment classification
        display_segment_classification(result)
        print()
        
        # Show reflection decision
        print("🧠 REFLECTION ANALYSIS:")
        print(f"   Decision: {result.classification_level.upper()} LEVEL")
        print(f"   8-digit Code: {result.complete_unspsc_code}")
        print(f"   Confidence: {result.confidence}")
        
        if result.classification_level == "commodity":
            print("   ✅ Reflection chose: SPECIFIC COMMODITY")
            print("   📝 Reason: High confidence match found")
        else:
            print("   🔄 Reflection chose: CLASS LEVEL (padded to 8 digits)")
            print("   📝 Reason: Commodity not specific enough")
        print()
        
        # Display the complete hierarchy
        print(result.get_full_hierarchy_display())
        
        # Show 8-digit code details
        print(f"\n🎯 8-DIGIT CODE BREAKDOWN:")
        if result.classification_level == "commodity":
            print(f"   {result.complete_unspsc_code} = Full commodity code")
        else:
            print(f"   {result.complete_unspsc_code} = {result.final_unspsc_code} (class) + 00 (padding)")
        
        # Show levels achieved
        if hasattr(result, 'hierarchy_levels_achieved'):
            levels_count = len(result.hierarchy_levels_achieved)
            levels_text = " → ".join(result.hierarchy_levels_achieved)
            print(f"\n📊 HIERARCHY PATH: {levels_text}")
            print(f"📊 LEVELS ACHIEVED: {levels_count}/4")
        
    else:
        print("❌ CLASSIFICATION FAILED")
        if hasattr(result, 'error_messages'):
            for error in result.error_messages:
                print(f"   • {error}")
    
    print("="*80)

# 🎯 MODIFY THESE PRODUCTS TO TEST REFLECTION SYSTEM WITH ENHANCED DISPLAY!
YOUR_PRODUCTS = {
    "High-Confidence Product": "Parker Hannifin PV180R1K1T1NMMC hydraulic piston pump 3000PSI variable displacement",
    
    "Generic Product (Should Fall Back)": "industrial equipment component metal item",
    
    "Technical Component": "Siemens S7-1200 CPU 1214C programmable logic controller digital I/O",
    
    "Maintenance Record": "06H-100101-1 Performed scheduled preventative maintenance on hydraulic pump #3, replaced seals",
    
    "Variable Frequency Drive": "ABB ACS550 VFD 5HP 480V three phase motor controller",
    
    # 🎯 ADD YOUR OWN PRODUCTS HERE FOR TESTING:
    "Your Product #1": "REPLACE WITH YOUR SPECIFIC PRODUCT - try brands like Parker, Siemens, ABB, etc.",
    
    "Your Product #2": "REPLACE WITH GENERIC DESCRIPTION - try 'equipment component', 'industrial device', etc.",
}

def main():
    """Run the interactive demo with enhanced display"""
    print("\n🎮 INTERACTIVE DEMO - Enhanced with Web Search & Segment Details")
    print("="*80)
    print("🎯 Testing products to demonstrate reflection system capabilities...")
    print("💡 Modify YOUR_PRODUCTS dictionary above to test your own products!")
    print()
    
    for product_name, description in YOUR_PRODUCTS.items():
        if "REPLACE WITH" in description.upper():
            print(f"⏭️ Skipping placeholder: {product_name}")
            print(f"   💡 Replace with your own product to see enhanced processing")
            continue
            
        print(f"🔄 Processing: {product_name}")
        print(f"   Description: {description}")
        
        try:
            result = classifier.classify_product(description)
            display_hierarchy_result(product_name, result)
            
        except Exception as e:
            print(f"❌ Error processing {product_name}: {e}")
        
        # Add delay between products for readability
        time.sleep(1)
    
    print("\n🎉 ENHANCED INTERACTIVE DEMO COMPLETE!")
    print("="*80)
    print("✅ Key Features Demonstrated:")
    print("   🔍 Web search results with queries, titles, and snippets")
    print("   🎯 Segment classification with detailed reasoning")
    print("   📊 Complete hierarchy progression from segment to commodity")
    print("   🧠 Intelligent reflection decisions (commodity vs class level)")
    print("   ✅ Always 8-digit codes - never below class level")
    print("   📋 Production-ready accuracy with smart fallbacks")
    print("="*80)
    print("🚀 Ready for production use with complete process visibility!")

if __name__ == "__main__":
    main() 