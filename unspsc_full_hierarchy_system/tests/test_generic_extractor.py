#!/usr/bin/env python3
"""
Test Generic Extractor with Diverse Products

Demonstrates that the extractor works without hardcoded brands or product types.
"""

import sys
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

def test_diverse_products():
    """Test extractor with completely different product types"""
    
    print("🧪 TESTING GENERIC EXTRACTOR WITH DIVERSE PRODUCTS")
    print("=" * 60)
    
    test_products = [
        "Siemens S7-1200 CPU 1214C DC/DC/DC programmable logic controller",
        "3M Scotch-Weld DP8005 structural adhesive 45ml cartridge",
        "Honeywell HMC5883L 3-axis digital compass magnetometer sensor",
        "Bosch GLI 12V-300 LED work light with 18650 battery",
        "Caterpillar C9.3B ACERT diesel engine 275HP industrial"
    ]
    
    try:
        from extractors.llm_extractor import LLMProductExtractor
        
        extractor = LLMProductExtractor()
        
        for i, product in enumerate(test_products, 1):
            print(f"\n🔍 TEST {i}: {product}")
            print("-" * 60)
            
            extracted = extractor.extract_all(product)
            
            print(f"✅ Brands: {extracted.brand_names}")
            print(f"✅ Models: {extracted.model_numbers}")
            print(f"✅ Manufacturer: {extracted.manufacturer}")
            print(f"✅ Search Terms: {extracted.search_worthy_terms}")
            
            # Show that it generates relevant search terms without hardcoding
            if extracted.search_worthy_terms:
                print(f"🌟 Generated intelligent search terms:")
                for term in extracted.search_worthy_terms:
                    print(f"   • {term}")
            
    except Exception as e:
        import traceback
        print(f"❌ Test failed: {e}")
        print(traceback.format_exc())

def main():
    test_diverse_products()

if __name__ == "__main__":
    main() 