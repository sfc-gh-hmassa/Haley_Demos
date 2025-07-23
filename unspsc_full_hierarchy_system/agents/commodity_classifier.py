"""
Commodity Classifier Agent

Classifies products into UNSPSC commodities (8-digit codes) within a specific class.
Validates single response requirement and handles confusion cases.
"""

import json
from typing import Dict, List, Optional
from pathlib import Path
import sys

class CommodityClassifier:
    """
    Agent for classifying products into UNSPSC commodities within a class.
    
    Ensures only one commodity is returned, otherwise returns confusion or falls back to class level.
    """
    
    def __init__(self):
        """Initialize Commodity Classifier Agent"""
        self.commodity_cache = {}
    
    def _get_commodities_for_class(self, class_code: str) -> List[Dict[str, str]]:
        """Get available UNSPSC commodities for a specific class"""
        if class_code not in self.commodity_cache:
            try:
                # Handle both relative and absolute imports
                current_dir = Path(__file__).parent.parent
                sys.path.insert(0, str(current_dir))
                
                try:
                    from ..database import UNSPSCDatabase
                except ImportError:
                    try:
                        from database import UNSPSCDatabase
                    except ImportError:
                        print("❌ Could not import UNSPSCDatabase")
                        self.commodity_cache[class_code] = []
                        return self.commodity_cache[class_code]
                
                db = UNSPSCDatabase()
                self.commodity_cache[class_code] = db.get_commodities_by_class(class_code)
                print(f"🗄️ Commodity classifier loaded {len(self.commodity_cache[class_code])} commodities for class {class_code}")
                
            except Exception as e:
                print(f"❌ Error loading commodities for class {class_code}: {e}")
                self.commodity_cache[class_code] = []
        
        return self.commodity_cache[class_code]
    
    def classify_commodity(self, enhanced_product_summary: str, class_code: str) -> Dict:
        """
        Classify product into UNSPSC commodity with complete hierarchy.
        
        Args:
            enhanced_product_summary: Enhanced product summary from ProductSummarizer
            class_code: 6-digit class code from ClassClassifier
            
        Returns:
            Dict: Classification result with complete hierarchy from 8-digit commodity code
        """
        print("🎯 Classifying UNSPSC Commodity...")
        
        # Get available commodities for this class
        available_commodities = self._get_commodities_for_class(class_code)
        
        if not available_commodities:
            return {
                "success": False,
                "error": f"No UNSPSC commodities available for class {class_code}",
                "commodity_code": None,
                "commodity_description": None,
                "confidence": "None",
                "complete_hierarchy": None
            }
        
        print(f"📋 Using {len(available_commodities)} available commodities for classification")
        
        # Create commodity classification prompt
        commodities_list = []
        for commodity in available_commodities[:15]:  # Limit for prompt size
            commodities_list.append(f"{commodity['code']}: {commodity['description']}")
        
        commodities_text = "\n".join(commodities_list)
        
        classification_prompt = f"""
        Classify this product into ONE UNSPSC commodity (8-digit code).

        PRODUCT: {enhanced_product_summary}

        AVAILABLE COMMODITIES for class {class_code}:
        {commodities_text}

        Return JSON:
        {{
            "commodity_code": "40151801",
            "commodity_description": "Hydraulic pumps",
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
            print(f"🔍 LLM Classification Response: {response[:200]}...")
            
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
            
            # Validate and get complete hierarchy
            return self._validate_and_get_hierarchy(classification_data, class_code, available_commodities)
            
        except (json.JSONDecodeError, KeyError) as e:
            print(f"⚠️ JSON parsing error in commodity classification: {e}")
            print("🔄 Using fallback classification...")
            return self.get_commodity_fallback(enhanced_product_summary, class_code)
        except Exception as e:
            print(f"❌ Commodity classification error: {e}")
            print("🔄 Using fallback classification...")
            return self.get_commodity_fallback(enhanced_product_summary, class_code)
    
    def _validate_and_get_hierarchy(self, classification_data: Dict, class_code: str, available_commodities: List[Dict]) -> Dict:
        """
        Validate commodity classification and get complete hierarchy from database.
        
        Args:
            classification_data: Raw classification response
            class_code: Expected class code
            available_commodities: List of valid commodities
            
        Returns:
            Dict: Validated classification result with complete hierarchy
        """
        # Check for confusion
        confidence = classification_data.get("confidence", "").upper()
        if confidence == "CONFUSED":
            print("⚠️ Commodity classification confused - multiple valid options")
            return {
                "success": False,
                "error": "Multiple commodities seem equally valid - classification confused",
                "commodity_code": None,
                "commodity_description": None,
                "confidence": "CONFUSED",
                "reasoning": classification_data.get("reasoning", "Multiple options detected"),
                "complete_hierarchy": None
            }
        
        # Validate commodity code format
        commodity_code = classification_data.get("commodity_code", "")
        if not commodity_code or not commodity_code.isdigit() or len(commodity_code.zfill(8)) != 8:
            print(f"⚠️ Invalid commodity code format: {commodity_code}")
            return self.get_commodity_fallback("", class_code)
        
        # Normalize commodity code to 8 digits
        commodity_code = commodity_code.zfill(8)
        
        # Verify commodity exists and belongs to the class
        valid_commodity = None
        for commodity in available_commodities:
            if commodity["code"] == commodity_code:
                valid_commodity = commodity
                break
        
        if not valid_commodity:
            print(f"⚠️ Commodity code {commodity_code} not found or doesn't belong to class {class_code}")
            return self.get_commodity_fallback("", class_code)
        
        # Get complete hierarchy from database
        try:
            current_dir = Path(__file__).parent.parent
            sys.path.insert(0, str(current_dir))
            
            try:
                from ..database import UNSPSCDatabase
            except ImportError:
                from database import UNSPSCDatabase
            
            db = UNSPSCDatabase()
            complete_hierarchy = db.get_commodity_with_hierarchy(commodity_code)
            
            if complete_hierarchy.get("success"):
                print(f"✅ Commodity classified with complete hierarchy: {commodity_code}")
                return {
                    "success": True,
                    "error": None,
                    "commodity_code": commodity_code,
                    "commodity_description": valid_commodity['description'],
                    "confidence": classification_data.get("confidence", "Medium"),
                    "reasoning": classification_data.get("reasoning", ""),
                    "complete_hierarchy": complete_hierarchy
                }
            else:
                print(f"⚠️ Could not get complete hierarchy for {commodity_code}")
                return {
                    "success": True,
                    "error": None,
                    "commodity_code": commodity_code,
                    "commodity_description": valid_commodity['description'],
                    "confidence": classification_data.get("confidence", "Medium"),
                    "reasoning": classification_data.get("reasoning", ""),
                    "complete_hierarchy": None
                }
        
        except Exception as e:
            print(f"⚠️ Error getting complete hierarchy: {e}")
            # Return basic result without complete hierarchy
            return {
                "success": True,
                "error": None,
                "commodity_code": commodity_code,
                "commodity_description": valid_commodity['description'],
                "confidence": classification_data.get("confidence", "Medium"),
                "reasoning": classification_data.get("reasoning", ""),
                "complete_hierarchy": None
            }
    
    def get_commodity_fallback(self, product_summary: str, class_code: str) -> Dict:
        """
        Provide fallback commodity classification based on keyword matching.
        
        Args:
            product_summary: Product summary for fallback classification
            class_code: Parent class code
            
        Returns:
            Dict: Fallback classification result
        """
        print(f"🔄 Using commodity fallback classification for class {class_code}...")
        
        available_commodities = self._get_commodities_for_class(class_code)
        
        if not available_commodities:
            return {
                "success": False,
                "error": f"No commodities available for class {class_code}",
                "commodity_code": None,
                "commodity_description": None,
                "confidence": "None",
                "fallback_to_class": True
            }
        
        # Simple keyword matching against commodity descriptions
        summary_lower = product_summary.lower()
        
        commodity_scores = {}
        for commodity in available_commodities:
            description_lower = commodity['description'].lower()
            
            # Score based on word overlap
            summary_words = set(summary_lower.split())
            description_words = set(description_lower.split())
            common_words = summary_words.intersection(description_words)
            
            # Remove common stop words
            stop_words = {'and', 'or', 'the', 'of', 'for', 'in', 'to', 'a', 'an', 'components', 'supplies', 'equipment'}
            meaningful_words = common_words - stop_words
            
            if meaningful_words:
                commodity_scores[commodity['code']] = len(meaningful_words)
        
        if commodity_scores:
            best_commodity_code = max(commodity_scores.items(), key=lambda x: x[1])[0]
            
            # Get commodity description
            commodity_desc = "Unknown commodity"
            for commodity in available_commodities:
                if commodity["code"] == best_commodity_code:
                    commodity_desc = commodity["description"]
                    break
            
            return {
                "success": True,
                "error": None,
                "commodity_code": best_commodity_code,
                "commodity_description": commodity_desc,
                "confidence": "Low",
                "reasoning": "Fallback keyword-based classification",
                "fallback_to_class": False
            }
        
        # If no keyword match, return first commodity as desperate fallback
        first_commodity = available_commodities[0]
        return {
            "success": True,
            "error": None,
            "commodity_code": first_commodity["code"],
            "commodity_description": first_commodity["description"],
            "confidence": "Very Low",
            "reasoning": "Desperate fallback - first available commodity",
            "fallback_to_class": False
        } 