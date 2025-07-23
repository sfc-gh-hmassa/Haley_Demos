"""
Class Classifier Agent

Classifies products into UNSPSC classes (6-digit codes) within a specific family.
Validates single response requirement and handles confusion cases.
"""

import json
import sys
import os
from pathlib import Path
from typing import Dict, List, Optional

class ClassClassifier:
    """
    Agent for classifying products into UNSPSC classes within a family.
    
    Ensures only one class is returned, otherwise returns confusion or falls back to family level.
    """
    
    def __init__(self):
        """Initialize Class Classifier Agent"""
        self.class_cache = {}
    
    def _get_classes_for_family(self, family_code: str) -> List[Dict[str, str]]:
        """Get available UNSPSC classes for a specific family"""
        if family_code not in self.class_cache:
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
                        self.class_cache[family_code] = []
                        return self.class_cache[family_code]
                
                db = UNSPSCDatabase()
                self.class_cache[family_code] = db.get_classes_by_family(family_code)
                print(f"🗄️ Class classifier loaded {len(self.class_cache[family_code])} classes for family {family_code}")
                
            except Exception as e:
                print(f"❌ Error loading classes for family {family_code}: {e}")
                self.class_cache[family_code] = []
        
        return self.class_cache[family_code]
    
    def classify_class(self, enhanced_product_summary: str, family_code: str) -> Dict:
        """
        Classify product into UNSPSC class within the given family.
        
        Args:
            enhanced_product_summary: Enhanced product summary 
            family_code: Parent family code (4-digit)
            
        Returns:
            Dict: Classification result with class code, description, and confidence
        """
        print(f"🎯 Classifying UNSPSC Class for family {family_code}...")
        
        # Get available classes for this family
        available_classes = self._get_classes_for_family(family_code)
        
        if not available_classes:
            print(f"⚠️ No classes found for family {family_code}")
            return {
                "success": False,
                "error": f"No UNSPSC classes available for family {family_code}",
                "class_code": None,
                "class_description": None,
                "confidence": "None",
                "fallback_to_family": True
            }
        
        # Limit classes for prompt size (most relevant ones)
        limited_classes = available_classes[:12]  
        
        # Create class classification prompt
        classes_list = []
        for class_item in limited_classes:
            classes_list.append(f"{class_item['code']}: {class_item['description']}")
        
        classes_text = "\n".join(classes_list)
        
        classification_prompt = f"""
        Classify this product into the most appropriate UNSPSC CLASS (6-digit code) within family {family_code}.

        PRODUCT INFORMATION:
        {enhanced_product_summary}

        AVAILABLE UNSPSC CLASSES IN FAMILY {family_code}:
        {classes_text}

        CRITICAL REQUIREMENTS:
        1. Return EXACTLY ONE class classification within family {family_code}
        2. If you cannot determine a single best class, return "CONFUSED"
        3. If multiple classes seem equally valid, return "CONFUSED"
        4. Class code MUST start with {family_code}

        Return ONLY this JSON format:
        {{
            "class_code": "XXXXXX",
            "class_description": "Full description",
            "confidence": "High|Medium|Low|CONFUSED",
            "reasoning": "Brief explanation of why this class fits"
        }}

        JSON:
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
            
            # Clean and parse JSON response with robust handling
            if response.startswith('```json'):
                response = response[7:]
            if response.endswith('```'):
                response = response[:-3]
            response = response.strip()
            
            # Handle empty response
            if not response:
                print("⚠️ Empty response from LLM")
                return self.get_class_fallback(enhanced_product_summary, family_code)
            
            # Try to find JSON in the response
            json_start = response.find('{')
            json_end = response.rfind('}') + 1
            if json_start >= 0 and json_end > json_start:
                response = response[json_start:json_end]
            else:
                print("⚠️ No valid JSON found in response")
                return self.get_class_fallback(enhanced_product_summary, family_code)
            
            classification_data = json.loads(response)
            
            # Validate the classification
            return self._validate_class_classification(
                classification_data, 
                available_classes, 
                family_code
            )
            
        except (json.JSONDecodeError, KeyError) as e:
            print(f"⚠️ JSON parsing error in class classification: {e}")
            print("🔄 Using fallback classification...")
            return self.get_class_fallback(enhanced_product_summary, family_code)
        except Exception as e:
            print(f"❌ Class classification error: {e}")
            print("🔄 Using fallback classification...")
            return self.get_class_fallback(enhanced_product_summary, family_code)
    
    def _validate_class_classification(self, classification_data: Dict, 
                                     available_classes: List[Dict], 
                                     family_code: str) -> Dict:
        """
        Validate class classification response.
        
        Args:
            classification_data: Raw classification response
            available_classes: List of valid classes
            family_code: Parent family code
            
        Returns:
            Dict: Validated classification result
        """
        # Check for confusion
        confidence = classification_data.get("confidence", "").upper()
        if confidence == "CONFUSED":
            print("⚠️ Class classification confused - returning to family level")
            return {
                "success": False,
                "error": "Multiple classes seem equally valid - classification confused",
                "class_code": None,
                "class_description": None,
                "confidence": "CONFUSED",
                "reasoning": classification_data.get("reasoning", "Multiple options detected"),
                "fallback_to_family": True
            }
        
        # Validate class code format
        class_code = classification_data.get("class_code", "")
        if not class_code or not class_code.isdigit() or len(class_code.zfill(6)) != 6:
            return {
                "success": False,
                "error": f"Invalid class code format: {class_code}",
                "class_code": None,
                "class_description": None,
                "confidence": "None",
                "fallback_to_family": True
            }
        
        # Normalize class code
        class_code = class_code.zfill(6)
        
        # Validate class belongs to family
        if not class_code.startswith(family_code.zfill(4)):
            return {
                "success": False,
                "error": f"Class {class_code} doesn't belong to family {family_code}",
                "class_code": None,
                "class_description": None,
                "confidence": "None",
                "fallback_to_family": True
            }
        
        # Verify class exists in database
        valid_class = None
        for class_item in available_classes:
            if class_item["code"] == class_code:
                valid_class = class_item
                break
        
        if not valid_class:
            return {
                "success": False,
                "error": f"Class code {class_code} not found in family {family_code}",
                "class_code": None,
                "class_description": None,
                "confidence": "None",
                "fallback_to_family": True
            }
        
        # Successful single classification
        print(f"✅ Class classified: {class_code} - {valid_class['description']}")
        return {
            "success": True,
            "error": None,
            "class_code": class_code,
            "class_description": valid_class['description'],
            "confidence": classification_data.get("confidence", "Medium"),
            "reasoning": classification_data.get("reasoning", ""),
            "fallback_to_family": False
        }
    
    def get_class_fallback(self, product_summary: str, family_code: str) -> Dict:
        """
        Provide fallback class classification based on keyword matching.
        
        Args:
            product_summary: Product summary for fallback classification
            family_code: Parent family code
            
        Returns:
            Dict: Fallback classification result
        """
        print(f"🔄 Using class fallback classification for family {family_code}...")
        
        available_classes = self._get_classes_for_family(family_code)
        
        if not available_classes:
            return {
                "success": False,
                "error": f"No classes available for family {family_code}",
                "class_code": None,
                "class_description": None,
                "confidence": "None",
                "fallback_to_family": True
            }
        
        # Simple keyword matching against class descriptions
        summary_lower = product_summary.lower()
        
        class_scores = {}
        for class_item in available_classes:
            description_lower = class_item['description'].lower()
            
            # Score based on word overlap
            summary_words = set(summary_lower.split())
            description_words = set(description_lower.split())
            common_words = summary_words.intersection(description_words)
            
            # Remove common stop words
            stop_words = {'and', 'or', 'the', 'of', 'for', 'in', 'to', 'a', 'an', 'components', 'supplies'}
            meaningful_words = common_words - stop_words
            
            if meaningful_words:
                class_scores[class_item['code']] = len(meaningful_words)
        
        if class_scores:
            best_class_code = max(class_scores.items(), key=lambda x: x[1])[0]
            
            # Get class description
            class_desc = "Unknown class"
            for class_item in available_classes:
                if class_item["code"] == best_class_code:
                    class_desc = class_item["description"]
                    break
            
            return {
                "success": True,
                "error": None,
                "class_code": best_class_code,
                "class_description": class_desc,
                "confidence": "Low",
                "reasoning": "Fallback keyword-based classification",
                "fallback_to_family": False
            }
        
        # If no keyword match, return first class as desperate fallback
        first_class = available_classes[0]
        return {
            "success": True,
            "error": None,
            "class_code": first_class["code"],
            "class_description": first_class["description"],
            "confidence": "Very Low",
            "reasoning": "Desperate fallback - first available class",
            "fallback_to_family": False
        } 