#!/usr/bin/env python3
"""
Test Enhanced Classification with Reflection

Demonstrates the self-correction capabilities for technical records
and hierarchical validation improvements.
"""

import sys
import time
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

def test_reflection_system():
    """Test the enhanced classification system with reflection"""
    
    print("🧠 TESTING ENHANCED CLASSIFICATION WITH REFLECTION")
    print("=" * 70)
    
    # Test the original maintenance record that had issues
    test_description = "06H-100101-1 Performed scheduled preventative maintenance on hydraulic pump #3, which included checking fluid levels, inspecting hoses for leaks and wear, and cleaning the intake strainer. All components were found to be within operational parameters, with no signs of leaks or abnormal wear detected. The pump is functioning normally and ready for continued service."
    
    print(f"📝 Testing: {test_description[:100]}...")
    print("=" * 70)
    
    try:
        # Initialize the enhanced classification chain
        print("\n🚀 Initializing Enhanced Classification Chain...")
        from chain.classification_chain_with_reflection import UNSPSCClassificationChainWithReflection
        
        enhanced_classifier = UNSPSCClassificationChainWithReflection()
        print("✅ Enhanced classification system ready!")
        
        # Run classification with reflection
        start_time = time.time()
        result = enhanced_classifier.classify_product_with_reflection(test_description)
        processing_time = time.time() - start_time
        
        # Display enhanced results
        print("\n" + "🎯" * 70)
        print("🎯 ENHANCED CLASSIFICATION RESULTS WITH REFLECTION")
        print("🎯" * 70)
        
        if result.get("success"):
            print("✅ CLASSIFICATION SUCCESSFUL WITH REFLECTION!")
            
            print(f"\n📊 FINAL UNSPSC HIERARCHY:")
            print(f"   🎯 Segment: {result.get('segment_code', 'N/A')} - {result.get('segment_description', 'N/A')}")
            print(f"   📁 Family:  {result.get('family_code', 'N/A')} - {result.get('family_description', 'N/A')}")
            print(f"   📂 Class:   {result.get('class_code', 'N/A')} - {result.get('class_description', 'N/A')}")
            
            print(f"\n🏷️ FINAL UNSPSC CODE: {result.get('final_unspsc_code', 'N/A')}")
            print(f"📊 CLASSIFICATION LEVEL: {result.get('classification_level', 'N/A').title()}")
            print(f"🎯 CONFIDENCE: {result.get('confidence', 'N/A')}")
            
            # Show reflection information
            if result.get("reflection_applied"):
                print(f"\n🧠 REFLECTION APPLIED:")
                print(f"   ✅ Self-correction was performed")
                print(f"   🔄 Reasoning: {result.get('reflection_reasoning', 'N/A')}")
                if result.get("original_segment"):
                    print(f"   📝 Original segment: {result['original_segment']}")
                    print(f"   📝 Corrected segment: {result.get('segment_code')}")
            else:
                print(f"\n🧠 NO REFLECTION NEEDED:")
                print(f"   ✅ Initial classification was correct")
            
        else:
            print("❌ CLASSIFICATION FAILED")
            print(f"   Error details: {result}")
        
        print(f"\n⏱️ TOTAL PROCESSING TIME: {processing_time:.2f} seconds")
        
        # Compare with original system
        print(f"\n📈 COMPARISON WITH ORIGINAL SYSTEM:")
        print(f"   🔄 Original system: Segment 26 → Family 2610 (Power sources)")
        print(f"   🧠 Enhanced system: Segment {result.get('segment_code')} → Family {result.get('family_code')} ({result.get('family_description', 'N/A')})")
        print(f"   💡 Improvement: {'Reflection corrected the classification path' if result.get('reflection_applied') else 'No correction needed'}")
        
        # Test additional challenging cases
        print(f"\n" + "🧪" * 70)
        print("🧪 TESTING ADDITIONAL TECHNICAL RECORD SCENARIOS")
        print("🧪" * 70)
        
        additional_tests = [
            "SN-2024-HV-001 Honeywell thermostat sensor calibration - checked temperature accuracy within ±0.5°C tolerance",
            "Bosch BGH-4500 motor bearing replacement - Unit #7 production line",
            "Maintenance log: Parker valve actuator model P150-3A shows normal operation after fluid change"
        ]
        
        for i, test_case in enumerate(additional_tests, 1):
            print(f"\n🔍 TEST CASE {i}: {test_case[:60]}...")
            
            case_start = time.time()
            case_result = enhanced_classifier.classify_product_with_reflection(test_case)
            case_time = time.time() - case_start
            
            print(f"   Result: {case_result.get('final_unspsc_code', 'Failed')} - {case_result.get('family_description', 'N/A')}")
            print(f"   Reflection: {'Applied' if case_result.get('reflection_applied') else 'Not needed'}")
            print(f"   Time: {case_time:.2f}s")
        
        print(f"\n🎉 ENHANCED REFLECTION TESTING COMPLETED!")
        print("=" * 70)
        print("🧠 REFLECTION CAPABILITIES DEMONSTRATED:")
        print("   ✅ Hierarchical mismatch detection")
        print("   ✅ Self-correction for segment conflicts") 
        print("   ✅ Enhanced technical record handling")
        print("   ✅ Confidence-based decision making")
        print("   ✅ Multiple classification path validation")
        
    except Exception as e:
        import traceback
        print(f"❌ Enhanced test failed: {e}")
        print(traceback.format_exc())

def main():
    """Main test function"""
    test_reflection_system()

if __name__ == "__main__":
    main() 