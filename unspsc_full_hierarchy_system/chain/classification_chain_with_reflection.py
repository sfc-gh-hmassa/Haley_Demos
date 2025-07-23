"""
Enhanced UNSPSC Classification Chain with Reflection

Adds reflection and self-correction capabilities to handle hierarchical mismatches
and improve classification accuracy for technical records with sparse information.
"""

import sys
import os
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any
from dataclasses import dataclass

# Handle imports
current_dir = Path(__file__).parent.parent
sys.path.insert(0, str(current_dir))

from .classification_chain import UNSPSCClassificationChain, ClassificationResult

@dataclass
class ReflectionResult:
    """Result of reflection analysis"""
    needs_correction: bool
    suggested_segment: Optional[str] = None
    suggested_family: Optional[str] = None
    confidence_improvement: float = 0.0
    reasoning: str = ""

class UNSPSCClassificationChainWithReflection:
    """
    Enhanced UNSPSC Classification Chain with Reflection Capabilities
    
    Features:
    - Self-correction when hierarchical mismatches detected
    - Multiple classification paths with confidence comparison
    - Enhanced handling of sparse technical records
    - Validation and reflection at each step
    """
    
    def __init__(self):
        """Initialize enhanced classification chain"""
        # Use the main classification chain as the base
        self.base_chain = UNSPSCClassificationChain()
        self._initialize_agents()
    
    def _initialize_agents(self):
        """Initialize all classification agents"""
        try:
            from extractors.llm_extractor import LLMProductExtractor
            from extractors.web_searcher import WebSearcher
            from agents.product_summarizer import ProductSummarizer
            from agents.segment_classifier import SegmentClassifier
            from agents.family_classifier import FamilyClassifier
            from agents.class_classifier import ClassClassifier
            from agents.commodity_classifier import CommodityClassifier
            from database.unspsc_database import UNSPSCDatabase
            
            self.extractor = LLMProductExtractor()
            self.web_searcher = WebSearcher(max_searches=3, delay_between_searches=0.5)
            self.summarizer = ProductSummarizer()
            self.segment_classifier = SegmentClassifier()
            self.family_classifier = FamilyClassifier()
            self.class_classifier = ClassClassifier()
            self.commodity_classifier = CommodityClassifier()
            self.database = UNSPSCDatabase()
            
            print("✅ Enhanced classification agents initialized")
            
        except ImportError as e:
            print(f"❌ Failed to initialize agents: {e}")
            raise
    
    def classify_product_with_reflection(self, product_description: str) -> ClassificationResult:
        """
        Classify product with reflection and self-correction capabilities
        
        Args:
            product_description: Product or technical record description
            
        Returns:
            ClassificationResult: Enhanced classification result with reflection data
        """
        print("\n🧠 ENHANCED CLASSIFICATION WITH REFLECTION")
        print("=" * 60)
        print(f"📝 Input: {product_description[:100]}...")
        
        # Step 1: Enhanced extraction for technical records
        print("\n🔍 STEP 1: Enhanced Product Extraction")
        extracted = self._enhanced_extraction(product_description)
        
        # Step 2: Web intelligence with technical focus
        print("\n🌐 STEP 2: Technical Web Intelligence")
        web_results = self._technical_web_search(extracted)
        
        # Step 3: Enhanced summary for sparse data
        print("\n📋 STEP 3: Enhanced Technical Summary")
        summary = self._create_technical_summary(product_description, extracted, web_results)
        
        # Step 4: Initial classification using the main chain
        print("\n🎯 STEP 4: Initial Classification")
        result = self._perform_enhanced_classification(product_description, extracted, web_results, summary)
        
        # Step 5: Reflection and validation
        print("\n🧠 STEP 5: Reflection and Validation")
        reflection = self._perform_reflection(summary, result)
        
        # Step 6: Correction if needed
        if reflection.needs_correction:
            print("\n🔄 STEP 6: Self-Correction")
            result = self._perform_correction(summary, reflection, result)
        else:
            print("\n✅ STEP 6: No correction needed")
        
        # Step 7: Final validation and confidence scoring
        print("\n📊 STEP 7: Final Validation")
        result = self._final_validation(result, reflection)
        
        return result
    
    def _enhanced_extraction(self, product_description: str) -> Any:
        """Enhanced extraction optimized for technical records"""
        print("🔍 Enhanced extraction for technical records...")
        
        # Use standard extraction but with enhanced patterns for technical records
        extracted = self.extractor.extract_all(product_description)
        
        # Additional extraction for technical logs
        if not extracted.brand_names and not extracted.model_numbers:
            print("⚙️ Applying technical record enhancement...")
            
            # Look for additional technical patterns
            import re
            
            # Enhanced serial number patterns for technician logs
            technical_serials = re.findall(r'\b[A-Z0-9]{6,}[-]?[A-Z0-9]{2,}\b', product_description)
            extracted.serial_numbers.extend(technical_serials)
            
            # Look for maintenance/service codes
            service_codes = re.findall(r'\b\d{2}[A-Z][-]\d{6}[-]\d+\b', product_description)
            extracted.part_numbers.extend(service_codes)
            
            # Equipment numbers (like "pump #3")
            equipment_nums = re.findall(r'(?:pump|motor|valve|sensor|unit)\s*#?\s*(\d+)', product_description, re.IGNORECASE)
            if equipment_nums:
                extracted.model_numbers.extend([f"Unit-{num}" for num in equipment_nums])
            
            print(f"   Enhanced serials: {technical_serials}")
            print(f"   Service codes: {service_codes}")
            print(f"   Equipment IDs: {equipment_nums}")
        
        return extracted
    
    def _technical_web_search(self, extracted: Any) -> Any:
        """Web search optimized for technical equipment"""
        print("🔍 Technical web search...")
        
        search_terms = self.extractor.get_search_terms(extracted)
        
        # Add technical equipment terms for better results
        technical_terms = []
        if any('pump' in term.lower() for term in search_terms):
            technical_terms.append("industrial hydraulic pump")
        if any('maintenance' in term.lower() for term in search_terms):
            technical_terms.append("equipment maintenance")
        
        # Combine original and technical terms
        all_search_terms = search_terms + technical_terms
        
        if all_search_terms:
            return self.web_searcher.search_product_info(all_search_terms[:3])
        return None
    
    def _create_technical_summary(self, description: str, extracted: Any, web_results: Any) -> str:
        """Create enhanced summary for technical records"""
        print("📋 Creating technical summary...")
        
        # Use standard summarizer but enhance for technical context
        base_summary = self.summarizer.summarize_product(description, extracted, web_results)
        
        # Add technical context if this appears to be a maintenance record
        if any(word in description.lower() for word in ['maintenance', 'inspection', 'service', 'repair']):
            technical_context = " | Context: Technical maintenance record for industrial equipment"
            base_summary += technical_context
        
        print(f"📋 Technical summary: {base_summary[:100]}...")
        return base_summary
    
    def _perform_enhanced_classification(self, description: str, extracted: Any, web_results: Any, summary: str) -> ClassificationResult:
        """Perform initial classification using the main chain"""
        print("🎯 Initial classification using the main chain...")
        
        # Create a result object and populate it manually with our enhanced data
        result = ClassificationResult(
            success=False,
            original_description=description,
            enhanced_summary=summary,
            extracted_identifiers=extracted,
            web_search_results=web_results
        )
        
        # Perform hierarchical classification using the base chain logic
        self.base_chain._perform_hierarchical_classification(result, summary)
        self.base_chain._finalize_classification_result(result)
        
        return result
    
    def _perform_reflection(self, summary: str, initial_result: ClassificationResult) -> ReflectionResult:
        """Perform reflection to detect potential issues"""
        print("🧠 Performing reflection analysis...")
        
        # Check for hierarchical mismatches
        if not initial_result.success and initial_result.error_messages:
            error_msgs = " ".join(initial_result.error_messages)
            
            # Look for specific mismatch patterns
            if "doesn't belong to segment" in error_msgs or "not found in segment" in error_msgs:
                print("🔍 Detected hierarchical mismatch!")
                
                # Try to extract the suggested family from error or fallback reasoning
                return self._analyze_mismatch(summary, initial_result)
        
        # Check confidence levels
        if initial_result.confidence.lower() in ["low", "confused"]:
            print("⚠️ Low segment confidence detected")
            return self._suggest_alternative_segments(summary)
        
        print("✅ No reflection issues detected")
        return ReflectionResult(needs_correction=False)
    
    def _analyze_mismatch(self, summary: str, initial_result: ClassificationResult) -> ReflectionResult:
        """Analyze hierarchical mismatch and suggest corrections"""
        print("🔍 Analyzing hierarchical mismatch...")
        
        # Check error messages for hints
        error_msgs = " ".join(initial_result.error_messages)
        
        # Look for pump-related products that should be in segment 40
        if "pump" in summary.lower() and "hydraulic" in summary.lower():
            return ReflectionResult(
                needs_correction=True,
                suggested_segment="40",
                suggested_family="4015",  # Industrial pumps and compressors
                confidence_improvement=0.3,
                reasoning="Hydraulic pump should be in segment 40 (Distribution and Conditioning Systems)"
            )
        
        # Look for other common mismatches
        if "motor" in summary.lower() and ("electric" in summary.lower() or "electrical" in summary.lower()):
            return ReflectionResult(
                needs_correction=True,
                suggested_segment="26",
                suggested_family="2610",  # Electric motors
                confidence_improvement=0.2,
                reasoning="Electric motor should be in segment 26 (Power Generation and Distribution)"
            )
        
        return ReflectionResult(needs_correction=False)
    
    def _suggest_alternative_segments(self, summary: str) -> ReflectionResult:
        """Suggest alternative segments for low confidence cases"""
        print("💭 Suggesting alternative segments...")
        
        # Smart suggestions based on content
        if "pump" in summary.lower():
            return ReflectionResult(
                needs_correction=True,
                suggested_segment="40",
                reasoning="Pump equipment typically belongs in segment 40"
            )
        
        return ReflectionResult(needs_correction=False)
    
    def _perform_correction(self, summary: str, reflection: ReflectionResult, initial_result: ClassificationResult) -> ClassificationResult:
        """Perform self-correction based on reflection"""
        print(f"🔄 Performing correction: {reflection.reasoning}")
        
        if reflection.suggested_segment:
            # Re-classify with the suggested segment
            segment_result = {
                "success": True,
                "segment_code": reflection.suggested_segment,
                "segment_description": f"Corrected segment {reflection.suggested_segment}",
                "confidence": "Medium (Corrected)"
            }
            
            # Update the result with corrected segment
            result = ClassificationResult(
                success=True,
                original_description=initial_result.original_description,
                enhanced_summary=initial_result.enhanced_summary,
                extracted_identifiers=initial_result.extracted_identifiers,
                web_search_results=initial_result.web_search_results,
                segment_code=reflection.suggested_segment,
                segment_description=f"Corrected segment {reflection.suggested_segment}",
                confidence="Medium (Corrected)",
                reasoning=reflection.reasoning
            )
            
            # Try family classification with the corrected segment
            family_result = self.family_classifier.classify_family(summary, reflection.suggested_segment)
            if family_result.get("success"):
                result.family_code = family_result["family_code"]
                result.family_description = family_result["family_description"]
                
                # Try class if family succeeded
                if result.family_code:
                    class_result = self.class_classifier.classify_class(summary, result.family_code)
                    if class_result.get("success"):
                        result.class_code = class_result["class_code"]
                        result.class_description = class_result["class_description"]
            
            # Finalize the corrected result
            self.base_chain._finalize_classification_result(result)
            
            print(f"✅ Correction completed - new path: {reflection.suggested_segment}")
            return result
        
        return initial_result
    
    def _final_validation(self, result: ClassificationResult, reflection: ReflectionResult) -> ClassificationResult:
        """Final validation and confidence scoring"""
        print("📊 Final validation...")
        
        # Update confidence if reflection was applied
        if reflection.needs_correction and reflection.confidence_improvement > 0:
            current_conf = result.confidence.lower()
            if "low" in current_conf:
                result.confidence = "Medium (Reflection Enhanced)"
            elif "medium" in current_conf:
                result.confidence = "High (Reflection Enhanced)"
        
        print(f"✅ Final confidence: {result.confidence}")
        return result 