#!/usr/bin/env python3
"""
Debug Classification System

Simple test to debug why classifications aren't working.
"""

import sys
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

def test_simple_product():
    """Test a simple product step by step"""
    
    print("🔍 DEBUGGING CLASSIFICATION SYSTEM")
    print("=" * 50)
    
    test_product = "Parker Hannifin hydraulic pump model P2075"
    print(f"Testing: {test_product}")
    
    try:
        # Step 1: Test LLM extraction
        print("\n1️⃣ Testing LLM extraction...")
        from extractors.llm_extractor import LLMProductExtractor
        
        extractor = LLMProductExtractor()
        extracted = extractor.extract_all(test_product)
        print(f"✅ Extraction successful")
        
        # Step 2: Test web search
        print("\n2️⃣ Testing web search...")
        from extractors.web_searcher import WebSearcher
        
        searcher = WebSearcher(max_searches=1, delay_between_searches=0.0)
        search_terms = extractor.get_search_terms(extracted)
        if search_terms:
            web_results = searcher.search_product_info(search_terms[:1])  # Just 1 search
            print(f"✅ Web search successful")
        else:
            print("⚠️ No search terms generated")
        
        # Step 3: Test product summarizer
        print("\n3️⃣ Testing product summarizer...")
        from agents.product_summarizer import ProductSummarizer
        
        summarizer = ProductSummarizer()
        summary = summarizer.summarize_product(test_product, extracted, web_results if search_terms else None)
        print(f"✅ Product summary created")
        print(f"Summary: {summary[:100]}...")
        
        # Step 4: Test UNSPSC database
        print("\n4️⃣ Testing UNSPSC database...")
        from database.unspsc_database import UNSPSCDatabase
        
        db = UNSPSCDatabase()
        segments = db.get_all_segments()
        print(f"✅ Got {len(segments)} segments from database")
        if segments:
            print(f"First segment: {segments[0]['code']} - {segments[0]['description'][:50]}...")
        
        # Step 5: Test segment classifier
        print("\n5️⃣ Testing segment classifier...")
        from agents.segment_classifier import SegmentClassifier
        
        seg_classifier = SegmentClassifier()
        seg_result = seg_classifier.classify_segment(summary)
        print(f"Segment result: {seg_result}")
        
        if seg_result.get("success"):
            segment_code = seg_result["segment_code"]
            print(f"✅ Segment classified: {segment_code}")
            
            # Step 6: Test family classifier
            print("\n6️⃣ Testing family classifier...")
            from agents.family_classifier import FamilyClassifier
            
            fam_classifier = FamilyClassifier()
            fam_result = fam_classifier.classify_family(summary, segment_code)
            print(f"Family result: {fam_result}")
            
            if fam_result.get("success"):
                family_code = fam_result["family_code"]
                print(f"✅ Family classified: {family_code}")
                
                # Step 7: Test class classifier
                print("\n7️⃣ Testing class classifier...")
                from agents.class_classifier import ClassClassifier
                
                class_classifier = ClassClassifier()
                class_result = class_classifier.classify_class(summary, family_code)
                print(f"Class result: {class_result}")
                
                if class_result.get("success"):
                    class_code = class_result["class_code"]
                    print(f"✅ Class classified: {class_code}")
                    
                    print(f"\n🎉 FULL CLASSIFICATION PATH:")
                    print(f"   Segment: {segment_code}")
                    print(f"   Family: {family_code}")
                    print(f"   Class: {class_code}")
                else:
                    print(f"❌ Class classification failed: {class_result.get('error')}")
            else:
                print(f"❌ Family classification failed: {fam_result.get('error')}")
        else:
            print(f"❌ Segment classification failed: {seg_result.get('error')}")
        
    except Exception as e:
        import traceback
        print(f"❌ Error in step: {e}")
        print(traceback.format_exc())

def main():
    test_simple_product()

if __name__ == "__main__":
    main() 