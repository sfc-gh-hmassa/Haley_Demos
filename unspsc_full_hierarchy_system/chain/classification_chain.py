"""
UNSPSC Classification Chain

Orchestrates the complete UNSPSC classification workflow:
1. Extract identifiers from product description
2. Web search extracted identifiers 
3. Create enhanced product summary
4. Hierarchical classification: Segment → Family → Class → Commodity
5. Handle validation and fallback at each level
"""

import sys
import os
from pathlib import Path
from typing import Dict, Any, Optional, List, Union
from dataclasses import dataclass, field

@dataclass
class ClassificationResult:
    """Complete UNSPSC classification result with full hierarchy"""
    success: bool
    original_description: str
    enhanced_summary: str
    
    # Extracted information
    extracted_identifiers: Any = None
    web_search_results: Any = None
    
    # Complete Classification hierarchy - Individual components
    segment_code: Optional[str] = None
    segment_description: Optional[str] = None
    
    family_code: Optional[str] = None
    family_description: Optional[str] = None
    
    class_code: Optional[str] = None  
    class_description: Optional[str] = None
    
    commodity_code: Optional[str] = None
    commodity_description: Optional[str] = None
    
    # NEW: Complete Hierarchy Representation
    full_hierarchy_path: str = ""  # Human-readable hierarchy path
    complete_unspsc_code: Optional[str] = None  # Full 8-digit code when available
    hierarchy_levels_achieved: List[str] = field(default_factory=list)  # ["segment", "family", "class", "commodity"]
    hierarchy_breakdown: Dict[str, Dict[str, Union[str, int]]] = field(default_factory=dict)  # Structured hierarchy data
    
    # Final UNSPSC code (highest achieved level) - kept for backward compatibility
    final_unspsc_code: Optional[str] = None
    final_unspsc_description: Optional[str] = None
    classification_level: str = "none"  # segment, family, class, commodity
    
    # Metadata
    confidence: str = "Unknown"
    reasoning: str = ""
    error_messages: List[str] = field(default_factory=list)
    
    def get_full_hierarchy_display(self) -> str:
        """Get a formatted display of the complete hierarchy"""
        if not self.hierarchy_breakdown:
            return "❌ No hierarchy achieved"
        
        display_lines = []
        display_lines.append("🎯 COMPLETE UNSPSC HIERARCHY:")
        display_lines.append("=" * 50)
        
        # Build hierarchy display
        hierarchy_order = ["segment", "family", "class", "commodity"]
        icons = {"segment": "🟦", "family": "🟩", "class": "🟨", "commodity": "🟧"}
        
        for level in hierarchy_order:
            if level in self.hierarchy_breakdown:
                data = self.hierarchy_breakdown[level]
                icon = icons.get(level, "🔸")
                level_name = level.upper().ljust(10)
                code = data.get("code", "N/A")
                description = data.get("description", "N/A")
                display_lines.append(f"{icon} {level_name}: {code} - {description}")
        
        # Add complete code if available
        if self.complete_unspsc_code:
            display_lines.append("=" * 50)
            display_lines.append(f"🏆 COMPLETE CODE: {self.complete_unspsc_code}")
        
        return "\n".join(display_lines)
    
    def get_hierarchy_path_string(self) -> str:
        """Get a condensed hierarchy path string"""
        if not self.hierarchy_breakdown:
            return "No hierarchy"
        
        path_parts = []
        for level in ["segment", "family", "class", "commodity"]:
            if level in self.hierarchy_breakdown:
                code = self.hierarchy_breakdown[level].get("code", "")
                if code:
                    path_parts.append(code)
        
        return " → ".join(path_parts) if path_parts else "No path"

class UNSPSCClassificationChain:
    """
    Main orchestration chain for UNSPSC classification.
    
    Coordinates all agents to perform complete product classification
    with validation and intelligent fallback handling.
    """
    
    def __init__(self):
        """Initialize the classification chain"""
        self._initialize_agents()
    
    def _initialize_agents(self):
        """Initialize all required agents"""
        try:
            # Handle both relative and absolute imports
            current_dir = Path(__file__).parent.parent
            sys.path.insert(0, str(current_dir))
            
            try:
                from ..extractors import LLMProductExtractor, WebSearcher
                from ..agents import (
                    ProductSummarizer, 
                    SegmentClassifier, 
                    FamilyClassifier,
                    ClassClassifier,
                    CommodityClassifier
                )
            except ImportError:
                # Fallback to absolute imports
                from extractors import LLMProductExtractor, WebSearcher
                from agents import (
                    ProductSummarizer, 
                    SegmentClassifier, 
                    FamilyClassifier,
                    ClassClassifier,
                    CommodityClassifier
                )
            
            # Initialize extraction and intelligence gathering
            self.extractor = LLMProductExtractor()
            self.web_searcher = WebSearcher(max_searches=3, delay_between_searches=0.5)
            self.summarizer = ProductSummarizer()
            
            # Initialize classification agents
            self.segment_classifier = SegmentClassifier()
            self.family_classifier = FamilyClassifier()
            self.class_classifier = ClassClassifier()
            self.commodity_classifier = CommodityClassifier()
            
            print("✅ All agents initialized successfully")
            
        except ImportError as e:
            print(f"❌ Failed to initialize agents: {e}")
            raise
    
    def classify_product(self, product_description: str) -> ClassificationResult:
        """
        Perform complete UNSPSC classification for a product.
        
        Args:
            product_description: Original technical product description
            
        Returns:
            ClassificationResult: Complete classification result with hierarchy
        """
        print("\n🚀 STARTING UNSPSC CLASSIFICATION CHAIN")
        print("=" * 60)
        print(f"📝 Product: {product_description[:100]}...")
        print("=" * 60)
        
        result = ClassificationResult(
            success=False,
            original_description=product_description,
            enhanced_summary=""
        )
        
        try:
            # Step 1: Extract product identifiers
            print("\n🔍 STEP 1: Extracting Product Identifiers")
            extracted_info = self.extractor.extract_all(product_description)
            result.extracted_identifiers = extracted_info
            
            # Step 2: Web search for additional intelligence
            print("\n🌐 STEP 2: Web Search Intelligence Gathering")
            search_terms = self.extractor.get_search_terms(extracted_info)
            web_info = self.web_searcher.search_product_info(search_terms)
            result.web_search_results = web_info
            
            # Step 3: Create enhanced product summary
            print("\n📋 STEP 3: Creating Enhanced Product Summary")
            enhanced_summary = self.summarizer.summarize_product(
                product_description, extracted_info, web_info
            )
            result.enhanced_summary = enhanced_summary
            
            # Step 4: Hierarchical Classification
            print("\n🎯 STEP 4: Hierarchical UNSPSC Classification")
            self._perform_hierarchical_classification(result, enhanced_summary)
            
            # Step 5: Finalize results
            self._finalize_classification_result(result)
            
            print("\n✅ CLASSIFICATION CHAIN COMPLETED")
            print("=" * 60)
            
            return result
            
        except Exception as e:
            error_msg = f"Classification chain failed: {str(e)}"
            print(f"\n❌ {error_msg}")
            result.error_messages.append(error_msg)
            result.success = False
            return result
    
    def _perform_hierarchical_classification(self, result: ClassificationResult, enhanced_summary: str):
        """Perform the hierarchical classification steps"""
        
        # SEGMENT CLASSIFICATION
        print("   🎯 Classifying Segment...")
        segment_result = self.segment_classifier.classify_segment(enhanced_summary)
        
        if segment_result["success"]:
            result.segment_code = segment_result["segment_code"]
            result.segment_description = segment_result["segment_description"]
            result.confidence = segment_result["confidence"]
            result.reasoning = segment_result.get("reasoning", "")
            
            print(f"   ✅ Segment: {result.segment_code} - {result.segment_description}")
            
            # Only proceed if we have a valid segment code
            if result.segment_code:
                # FAMILY CLASSIFICATION
                print("   🎯 Classifying Family...")
                family_result = self.family_classifier.classify_family(enhanced_summary, result.segment_code)
                
                if family_result["success"]:
                    result.family_code = family_result["family_code"]
                    result.family_description = family_result["family_description"]
                    
                    print(f"   ✅ Family: {result.family_code} - {result.family_description}")
                    
                    # Only proceed if we have a valid family code
                    if result.family_code:
                        # CLASS CLASSIFICATION
                        print("   🎯 Classifying Class...")
                        class_result = self.class_classifier.classify_class(enhanced_summary, result.family_code)
                        
                        if class_result["success"]:
                            result.class_code = class_result["class_code"]
                            result.class_description = class_result["class_description"]
                            
                            print(f"   ✅ Class: {result.class_code} - {result.class_description}")
                            
                            # Only proceed if we have a valid class code
                            if result.class_code:
                                # COMMODITY CLASSIFICATION (ALWAYS ATTEMPT)
                                print("   🎯 Classifying Commodity...")
                                commodity_result = self.commodity_classifier.classify_commodity(enhanced_summary, result.class_code)
                                
                                # REFLECTION: Decide between commodity and class level
                                print("   🧠 Performing commodity reflection...")
                                final_classification = self._reflect_on_commodity_classification(
                                    enhanced_summary, result, commodity_result
                                )
                                
                                # Apply reflection decision
                                if final_classification["use_commodity"]:
                                    result.commodity_code = final_classification["commodity_code"]
                                    result.commodity_description = final_classification["commodity_description"]
                                    result.confidence = final_classification["confidence"]
                                    print(f"   ✅ Commodity: {result.commodity_code} - {result.commodity_description}")
                                    print(f"   🧠 Reflection: Using specific commodity (confidence: {result.confidence})")
                                    
                                    # Handle complete hierarchy from 8-digit commodity code
                                    if final_classification.get("complete_hierarchy"):
                                        print("   🎯 Extracting complete hierarchy from commodity code...")
                                        hierarchy = final_classification["complete_hierarchy"]
                                        
                                        # Update all hierarchy levels with information from the commodity code
                                        if hierarchy.get("segment"):
                                            result.segment_code = hierarchy["segment"]["code"]
                                            result.segment_description = hierarchy["segment"]["description"]
                                        
                                        if hierarchy.get("family"):
                                            result.family_code = hierarchy["family"]["code"]
                                            result.family_description = hierarchy["family"]["description"]
                                        
                                        if hierarchy.get("class"):
                                            result.class_code = hierarchy["class"]["code"]
                                            result.class_description = hierarchy["class"]["description"]
                                        
                                        print("   🏆 COMPLETE 8-DIGIT HIERARCHY ACHIEVED!")
                                else:
                                    # Use class level but ensure 8-digit code
                                    result.commodity_code = None
                                    result.commodity_description = None
                                    result.confidence = final_classification["confidence"]
                                    print(f"   ⚠️ Reflection: No specific commodity match - staying at class level")
                                    print(f"   🎯 Will return 8-digit class code: {result.class_code.zfill(6)}00")
                                    
                            else:
                                print("   ⚠️ Class classification failed - cannot proceed to commodity level")
                                result.error_messages.append("Class classification required for commodity reflection")
                
                else:
                    print("   ⚠️ Family classification failed - stopping at segment level")
                    result.error_messages.append(f"Family classification failed: {family_result.get('error', '')}")
        
        else:
            print("   ❌ Segment classification failed")
            result.error_messages.append(f"Segment classification failed: {segment_result.get('error', '')}")
            
            # Try fallback segment classification
            print("   🔄 Attempting segment fallback...")
            fallback_result = self.segment_classifier.get_segment_fallback(enhanced_summary)
            if fallback_result["success"]:
                result.segment_code = fallback_result["segment_code"]
                result.segment_description = fallback_result["segment_description"]
                result.confidence = "Low (Fallback)"
                print(f"   ✅ Fallback Segment: {result.segment_code} - {result.segment_description}")
    
    def _finalize_classification_result(self, result: ClassificationResult):
        """Finalize the classification result with complete hierarchy information"""
        
        # Build complete hierarchy breakdown
        self._build_hierarchy_breakdown(result)
        
        # Build hierarchy path string
        result.full_hierarchy_path = result.get_hierarchy_path_string()
        
        # Set complete UNSPSC code (8-digit commodity if available)
        if result.commodity_code:
            result.complete_unspsc_code = result.commodity_code.zfill(8)
        elif result.class_code:
            # CRITICAL: Always return 8 digits - pad class code with 00
            result.complete_unspsc_code = result.class_code.zfill(6) + "00"
        elif result.family_code:
            # Should not happen with reflection, but fallback
            result.complete_unspsc_code = result.family_code.zfill(4) + "0000"
        elif result.segment_code:
            # Should not happen with reflection, but fallback
            result.complete_unspsc_code = result.segment_code.zfill(2) + "000000"
        
        # Determine the final classification level achieved (for backward compatibility)
        if result.commodity_code:
            result.final_unspsc_code = result.commodity_code
            result.final_unspsc_description = result.commodity_description
            result.classification_level = "commodity"
            result.success = True
        elif result.class_code:
            result.final_unspsc_code = result.class_code
            result.final_unspsc_description = result.class_description
            result.classification_level = "class"
            result.success = True
            # Important note: complete_unspsc_code is still 8 digits (class + 00)
        elif result.family_code:
            # This should rarely happen with new reflection logic
            result.final_unspsc_code = result.family_code
            result.final_unspsc_description = result.family_description
            result.classification_level = "family"
            result.success = True
            result.error_messages.append("Warning: Classification stopped at family level - reflection should ensure at least class level")
        elif result.segment_code:
            # This should rarely happen with new reflection logic  
            result.final_unspsc_code = result.segment_code
            result.final_unspsc_description = result.segment_description
            result.classification_level = "segment"
            result.success = True
            result.error_messages.append("Warning: Classification stopped at segment level - reflection should ensure at least class level")
        else:
            result.success = False
            result.error_messages.append("No classification level achieved")
        
        # Display results
        if result.success:
            print(f"\n🏆 HIGHEST LEVEL ACHIEVED: {result.final_unspsc_code}")
            print(f"📋 Description: {result.final_unspsc_description}")
            print(f"📊 Level: {result.classification_level.title()}")
            print(f"🎯 Confidence: {result.confidence}")
            
            # Always show the 8-digit complete code
            print(f"🏆 COMPLETE 8-DIGIT CODE: {result.complete_unspsc_code}")
            
            if result.classification_level == "class":
                print(f"   📝 Note: Class-level result padded to 8 digits ({result.class_code} + 00)")
            elif result.classification_level == "commodity":
                print(f"   📝 Note: Full 8-digit commodity code achieved")
            
            # Display complete hierarchy
            print(f"\n{result.get_full_hierarchy_display()}")
            
        else:
            print(f"\n❌ CLASSIFICATION FAILED")
            for error in result.error_messages:
                print(f"   • {error}")
    
    def _build_hierarchy_breakdown(self, result: ClassificationResult):
        """Build the structured hierarchy breakdown"""
        result.hierarchy_breakdown = {}
        result.hierarchy_levels_achieved = []
        
        # Add segment if available
        if result.segment_code and result.segment_description:
            result.hierarchy_breakdown["segment"] = {
                "code": result.segment_code,
                "description": result.segment_description,
                "level": 1
            }
            result.hierarchy_levels_achieved.append("segment")
        
        # Add family if available
        if result.family_code and result.family_description:
            result.hierarchy_breakdown["family"] = {
                "code": result.family_code,
                "description": result.family_description,
                "level": 2
            }
            result.hierarchy_levels_achieved.append("family")
        
        # Add class if available
        if result.class_code and result.class_description:
            result.hierarchy_breakdown["class"] = {
                "code": result.class_code,
                "description": result.class_description,
                "level": 3
            }
            result.hierarchy_levels_achieved.append("class")
        
        # Add commodity if available
        if result.commodity_code and result.commodity_description:
            result.hierarchy_breakdown["commodity"] = {
                "code": result.commodity_code,
                "description": result.commodity_description,
                "level": 4
            }
            result.hierarchy_levels_achieved.append("commodity")
    
    def _reflect_on_commodity_classification(self, enhanced_summary: str, result: ClassificationResult, commodity_result: Dict) -> Dict:
        """
        Reflect on commodity classification to decide whether to use commodity or class level.
        
        Args:
            enhanced_summary: Enhanced product summary
            result: Current classification result with class level
            commodity_result: Result from commodity classifier
            
        Returns:
            Dict: Reflection decision with final classification choice
        """
        # If commodity classification succeeded with high confidence, use it
        if commodity_result.get("success"):
            confidence = commodity_result.get("confidence", "").lower()
            
            # High confidence commodity - use it
            if "high" in confidence:
                print(f"   🧠 High confidence commodity match - using commodity level")
                return {
                    "use_commodity": True,
                    "commodity_code": commodity_result["commodity_code"],
                    "commodity_description": commodity_result["commodity_description"],
                    "confidence": commodity_result.get("confidence", "High"),
                    "complete_hierarchy": commodity_result.get("complete_hierarchy"),
                    "reasoning": "High confidence commodity match"
                }
            
            # Medium confidence - check if commodity is specific enough
            elif "medium" in confidence:
                commodity_desc = commodity_result.get("commodity_description", "").lower()
                
                # Check if commodity is very generic (might want to stay at class)
                generic_terms = ["other", "miscellaneous", "general", "various", "unspecified"]
                is_generic = any(term in commodity_desc for term in generic_terms)
                
                if not is_generic:
                    print(f"   🧠 Medium confidence, specific commodity - using commodity level")
                    return {
                        "use_commodity": True,
                        "commodity_code": commodity_result["commodity_code"],
                        "commodity_description": commodity_result["commodity_description"],
                        "confidence": commodity_result.get("confidence", "Medium"),
                        "complete_hierarchy": commodity_result.get("complete_hierarchy"),
                        "reasoning": "Medium confidence but specific commodity"
                    }
                else:
                    print(f"   🧠 Medium confidence but generic commodity - staying at class level")
                    return {
                        "use_commodity": False,
                        "confidence": "Medium (Class level - generic commodity avoided)",
                        "reasoning": "Commodity too generic, class level more appropriate"
                    }
            
            # Low confidence - check for exact keyword matches
            else:
                # For low confidence, check if there's a strong keyword match
                summary_lower = enhanced_summary.lower()
                commodity_desc = commodity_result.get("commodity_description", "").lower()
                
                # Extract key terms from both
                summary_words = set(summary_lower.split())
                commodity_words = set(commodity_desc.split())
                
                # Check for strong keyword overlap
                overlap = summary_words.intersection(commodity_words)
                meaningful_overlap = [word for word in overlap if len(word) > 3 and word not in ["with", "from", "that", "this", "they", "have", "were"]]
                
                if len(meaningful_overlap) >= 2:
                    print(f"   🧠 Low confidence but strong keyword match ({meaningful_overlap}) - using commodity")
                    return {
                        "use_commodity": True,
                        "commodity_code": commodity_result["commodity_code"],
                        "commodity_description": commodity_result["commodity_description"],
                        "confidence": "Medium (Keyword match)",
                        "complete_hierarchy": commodity_result.get("complete_hierarchy"),
                        "reasoning": f"Strong keyword overlap: {meaningful_overlap}"
                    }
                else:
                    print(f"   🧠 Low confidence, weak match - staying at class level")
                    return {
                        "use_commodity": False,
                        "confidence": "Medium (Class level - low commodity confidence)",
                        "reasoning": "Commodity confidence too low, class level safer"
                    }
        
        # Commodity classification failed - stay at class level
        else:
            error_msg = commodity_result.get("error", "Classification failed")
            print(f"   🧠 Commodity classification failed ({error_msg}) - staying at class level")
            return {
                "use_commodity": False,
                "confidence": "Medium (Class level - commodity classification failed)",
                "reasoning": f"Commodity classification failed: {error_msg}"
            }
    
    def print_classification_summary(self, result: ClassificationResult):
        """Print a comprehensive summary of the classification results"""
        
        print("\n" + "="*80)
        print("📊 UNSPSC CLASSIFICATION SUMMARY")
        print("="*80)
        
        print(f"\n📝 ORIGINAL DESCRIPTION:")
        print(f"   {result.original_description}")
        
        if result.extracted_identifiers:
            print(f"\n🔍 EXTRACTED IDENTIFIERS:")
            if hasattr(result.extracted_identifiers, 'brand_names') and result.extracted_identifiers.brand_names:
                print(f"   📛 Brands: {', '.join(result.extracted_identifiers.brand_names)}")
            if hasattr(result.extracted_identifiers, 'model_numbers') and result.extracted_identifiers.model_numbers:
                print(f"   🔢 Models: {', '.join(result.extracted_identifiers.model_numbers)}")
            if hasattr(result.extracted_identifiers, 'serial_numbers') and result.extracted_identifiers.serial_numbers:
                print(f"   🏷️ Serials: {', '.join(result.extracted_identifiers.serial_numbers)}")
        
        if result.web_search_results:
            print(f"\n🌐 WEB INTELLIGENCE:")
            if hasattr(result.web_search_results, 'product_category') and result.web_search_results.product_category:
                print(f"   📂 Category: {result.web_search_results.product_category}")
            if hasattr(result.web_search_results, 'confidence'):
                print(f"   🎯 Search Confidence: {result.web_search_results.confidence}")
        
        # Display complete hierarchy
        print(f"\n{result.get_full_hierarchy_display()}")
        
        # Display hierarchy path
        if result.full_hierarchy_path:
            print(f"\n🎯 HIERARCHY PATH: {result.full_hierarchy_path}")
        
        # Display complete UNSPSC code
        if result.complete_unspsc_code:
            print(f"🏆 COMPLETE UNSPSC CODE: {result.complete_unspsc_code}")
        
        print(f"\n📊 CLASSIFICATION DETAILS:")
        print(f"   ✅ Levels Achieved: {len(result.hierarchy_levels_achieved)}/4 ({', '.join(result.hierarchy_levels_achieved)})")
        print(f"   🎯 Highest Level: {result.classification_level.title()}")
        print(f"   🎯 Confidence: {result.confidence}")
        
        if result.success:
            print(f"\n🏆 FINAL RESULT:")
            print(f"   ✅ Success: {result.final_unspsc_code}")
            print(f"   📋 Description: {result.final_unspsc_description}")
        else:
            print(f"\n❌ CLASSIFICATION FAILED:")
            for error in result.error_messages:
                print(f"   • {error}")
        
        print("="*80) 