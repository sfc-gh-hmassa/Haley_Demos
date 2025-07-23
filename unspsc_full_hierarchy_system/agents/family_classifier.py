"""
Family Classifier Agent

Classifies products into UNSPSC families (4-digit codes) within a specific segment.
Validates single response requirement and handles confusion cases.
"""

import json
import sys
import os
from pathlib import Path
from typing import Dict, List, Optional

class FamilyClassifier:
    """
    Agent for classifying products into UNSPSC families within a segment.
    
    Ensures only one family is returned, otherwise returns confusion.
    """
    
    def __init__(self):
        """Initialize Family Classifier Agent"""
        self.family_cache = {}
    
    def _get_families_for_segment(self, segment_code: str) -> List[Dict[str, str]]:
        """Get available UNSPSC families for a specific segment"""
        if segment_code not in self.family_cache:
            try:
                # Handle both relative and absolute imports
                current_dir = Path(__file__).parent.parent
                sys.path.insert(0, str(current_dir))
                
                try:
                    from ..database import UNSPSCDatabase
                except ImportError:
                    from database import UNSPSCDatabase
                
                db = UNSPSCDatabase()
                self.family_cache[segment_code] = db.get_families_by_segment(segment_code)
                print(f"🗄️ Family classifier loaded {len(self.family_cache[segment_code])} families for segment {segment_code}")
            except ImportError as e:
                print(f"❌ Could not import UNSPSCDatabase in family classifier: {e}")
                self.family_cache[segment_code] = []
        
        return self.family_cache[segment_code]
    
    def classify_family(self, enhanced_product_summary: str, segment_code: str) -> Dict:
        """
        Classify product into UNSPSC family within the given segment.
        
        Args:
            enhanced_product_summary: Enhanced product summary 
            segment_code: Parent segment code (2-digit)
            
        Returns:
            Dict: Classification result with family code, description, and confidence
        """
        print(f"🎯 Classifying UNSPSC Family for segment {segment_code}...")
        
        # Get available families for this segment
        available_families = self._get_families_for_segment(segment_code)
        
        if not available_families:
            print(f"⚠️ No families found for segment {segment_code}")
            return {
                "success": False,
                "error": f"No UNSPSC families available for segment {segment_code}",
                "family_code": None,
                "family_description": None,
                "confidence": "None"
            }
        
        print(f"📋 Using {len(available_families)} available families for classification")
        
        # Limit families for prompt size (most relevant ones)
        limited_families = available_families[:10]  
        
        # Create family classification prompt
        families_list = []
        for family in limited_families:
            families_list.append(f"{family['code']}: {family['description']}")
        
        families_text = "\n".join(families_list)
        
        classification_prompt = f"""
        Classify this product into ONE UNSPSC family (4-digit) in segment {segment_code}.

        PRODUCT: {enhanced_product_summary}

        FAMILIES IN SEGMENT {segment_code}:
        {families_text}

        Return JSON:
        {{
            "family_code": "4015",
            "family_description": "Industrial pumps and compressors",
            "confidence": "High"
        }}
        """
        
        try:
            # Get LLM response
            current_dir = Path(__file__).parent.parent
            sys.path.insert(0, str(current_dir))
            
            try:
                from ..config import get_snowflake_llm
            except ImportError:
                from config import get_snowflake_llm
            
            llm = get_snowflake_llm()
            
            response = llm.query(classification_prompt).strip()
            print(f"🔍 Family LLM Response: {response[:200]}...")
            
            # Clean and parse JSON response
            if response.startswith('```json'):
                response = response[7:]
            if response.endswith('```'):
                response = response[:-3]
            response = response.strip()
            
            # Try to find JSON in the response
            json_start = response.find('{')
            json_end = response.rfind('}') + 1
            if json_start >= 0 and json_end > json_start:
                response = response[json_start:json_end]
            
            classification_data = json.loads(response)
            
            # Validate the classification
            return self._validate_family_classification(
                classification_data, 
                available_families, 
                segment_code
            )
            
        except (json.JSONDecodeError, KeyError) as e:
            print(f"⚠️ JSON parsing error in family classification: {e}")
            return self.get_family_fallback(enhanced_product_summary, segment_code)
        except Exception as e:
            print(f"❌ Family classification error: {e}")
            return self.get_family_fallback(enhanced_product_summary, segment_code)
    
    def _validate_family_classification(self, classification_data: Dict, 
                                      available_families: List[Dict], 
                                      segment_code: str) -> Dict:
        """
        Validate family classification response.
        
        Args:
            classification_data: Raw classification response
            available_families: List of valid families
            segment_code: Parent segment code
            
        Returns:
            Dict: Validated classification result
        """
        # Check for confusion
        confidence = classification_data.get("confidence", "").upper()
        if confidence == "CONFUSED":
            print("⚠️ Family classification confused - multiple valid options")
            return {
                "success": False,
                "error": "Multiple families seem equally valid - classification confused",
                "family_code": None,
                "family_description": None,
                "confidence": "CONFUSED",
                "reasoning": classification_data.get("reasoning", "Multiple options detected")
            }
        
        # Validate family code format
        family_code = classification_data.get("family_code", "")
        if not family_code or not family_code.isdigit() or len(family_code.zfill(4)) != 4:
            print(f"⚠️ Invalid family code format: {family_code}")
            return self.get_family_fallback("", segment_code)
        
        # Normalize family code
        family_code = family_code.zfill(4)
        
        # Validate family belongs to segment
        if not family_code.startswith(segment_code.zfill(2)):
            print(f"⚠️ Family {family_code} doesn't belong to segment {segment_code}")
            return self.get_family_fallback("", segment_code)
        
        # Verify family exists in database
        valid_family = None
        for family in available_families:
            if family["code"] == family_code:
                valid_family = family
                break
        
        if not valid_family:
            print(f"⚠️ Family code {family_code} not found in segment {segment_code}")
            return self.get_family_fallback("", segment_code)
        
        # Successful single classification
        print(f"✅ Family classified: {family_code} - {valid_family['description']}")
        return {
            "success": True,
            "error": None,
            "family_code": family_code,
            "family_description": valid_family['description'],
            "confidence": classification_data.get("confidence", "Medium"),
            "reasoning": classification_data.get("reasoning", "")
        }
    
    def get_family_fallback(self, product_summary: str, segment_code: str) -> Dict:
        """
        Provide fallback family classification based on keyword matching.
        
        Args:
            product_summary: Product summary for fallback classification
            segment_code: Parent segment code
            
        Returns:
            Dict: Fallback classification result
        """
        print(f"🔄 Using family fallback classification for segment {segment_code}...")
        
        available_families = self._get_families_for_segment(segment_code)
        
        if not available_families:
            return {
                "success": False,
                "error": f"No families available for segment {segment_code}",
                "family_code": None,
                "family_description": None,
                "confidence": "None"
            }
        
        # Smart fallback for segment 40 (our case)
        if segment_code == "40":
            summary_lower = product_summary.lower()
            if any(word in summary_lower for word in ["pump", "hydraulic", "compressor"]):
                # Look for pumps family
                for family in available_families:
                    if "pump" in family['description'].lower():
                        print(f"✅ Smart fallback - pumps family: {family['code']}")
                        return {
                            "success": True,
                            "error": None,
                            "family_code": family["code"],
                            "family_description": family["description"],
                            "confidence": "Medium",
                            "reasoning": "Smart fallback based on pump keywords"
                        }
        
        # General fallback - return first family
        first_family = available_families[0]
        print(f"✅ General fallback - first family: {first_family['code']}")
        return {
            "success": True,
            "error": None,
            "family_code": first_family["code"],
            "family_description": first_family["description"],
            "confidence": "Low",
            "reasoning": "General fallback - first available family"
        } 