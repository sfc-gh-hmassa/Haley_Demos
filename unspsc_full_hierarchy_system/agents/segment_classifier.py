"""
Segment Classifier Agent

Classifies products into UNSPSC segments (2-digit codes) using Snowflake LLM.
Validates single response requirement and handles confusion cases.
"""

import json
import sys
import os
from pathlib import Path
from typing import Dict, List, Optional

class SegmentClassifier:
    """
    Agent for classifying products into UNSPSC segments.
    
    Ensures only one segment is returned, otherwise escalates confusion.
    """
    
    def __init__(self):
        """Initialize Segment Classifier Agent"""
        self.segment_cache = None
    
    def _get_available_segments(self) -> List[Dict[str, str]]:
        """Get available UNSPSC segments from database"""
        if self.segment_cache is None:
            try:
                # Handle both relative and absolute imports
                current_dir = Path(__file__).parent.parent
                sys.path.insert(0, str(current_dir))
                
                try:
                    from ..database import UNSPSCDatabase
                except ImportError:
                    from database import UNSPSCDatabase
                
                db = UNSPSCDatabase()
                self.segment_cache = db.get_all_segments()
                print(f"🗄️ Segment classifier loaded {len(self.segment_cache)} segments")
            except ImportError as e:
                print(f"❌ Could not import UNSPSCDatabase: {e}")
                self.segment_cache = []
        
        return self.segment_cache
    
    def classify_segment(self, enhanced_product_summary: str) -> Dict:
        """
        Classify product into UNSPSC segment.
        
        Args:
            enhanced_product_summary: Enhanced product summary from ProductSummarizer
            
        Returns:
            Dict: Classification result with segment code, description, and confidence
        """
        print("🎯 Classifying UNSPSC Segment...")
        
        # Get available segments
        available_segments = self._get_available_segments()
        
        if not available_segments:
            return {
                "success": False,
                "error": "No UNSPSC segments available",
                "segment_code": None,
                "segment_description": None,
                "confidence": "None"
            }
        
        print(f"📋 Using {len(available_segments)} available segments for classification")
        
        # Create segment classification prompt
        segments_list = []
        for segment in available_segments[:20]:  # Limit for prompt size
            segments_list.append(f"{segment['code']}: {segment['description']}")
        
        segments_text = "\n".join(segments_list)
        
        classification_prompt = f"""
        Classify this product into ONE UNSPSC segment (2-digit code).

        PRODUCT: {enhanced_product_summary}

        IMPORTANT CLASSIFICATION GUIDELINES:
        • PUMPS and COMPRESSORS → Segment 40 (Distribution and Conditioning Systems)
        • VALVES and FLOW CONTROL → Segment 40 (Distribution and Conditioning Systems)  
        • HYDRAULIC and PNEUMATIC SYSTEMS → Segment 40 (Distribution and Conditioning Systems)
        • MANUFACTURING MACHINES/EQUIPMENT → Segment 23 (Industrial Manufacturing)
        • TOOLS and GENERAL MACHINERY → Segment 27 (Tools and General Machinery)

        AVAILABLE SEGMENTS:
        {segments_text}

        CRITICAL: Pumps, compressors, hydraulic systems, and fluid handling equipment belong in Segment 40, NOT Segment 23.

        Return JSON:
        {{
            "segment_code": "40",
            "segment_description": "Distribution and Conditioning Systems",
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
            
            # Validate the classification
            return self._validate_segment_classification(classification_data, available_segments)
            
        except (json.JSONDecodeError, KeyError) as e:
            print(f"⚠️ JSON parsing error in segment classification: {e}")
            print("🔄 Using fallback classification...")
            return self.get_segment_fallback(enhanced_product_summary)
        except Exception as e:
            print(f"❌ Segment classification error: {e}")
            print("🔄 Using fallback classification...")
            return self.get_segment_fallback(enhanced_product_summary)
    
    def _validate_segment_classification(self, classification_data: Dict, available_segments: List[Dict]) -> Dict:
        """
        Validate segment classification response.
        
        Args:
            classification_data: Raw classification response
            available_segments: List of valid segments
            
        Returns:
            Dict: Validated classification result
        """
        # Check for confusion
        confidence = classification_data.get("confidence", "").upper()
        if confidence == "CONFUSED":
            print("⚠️ Segment classification confused - multiple valid options")
            return {
                "success": False,
                "error": "Multiple segments seem equally valid - classification confused",
                "segment_code": None,
                "segment_description": None,
                "confidence": "CONFUSED",
                "reasoning": classification_data.get("reasoning", "Multiple options detected")
            }
        
        # Validate segment code format
        segment_code = classification_data.get("segment_code", "")
        if not segment_code or not segment_code.isdigit() or len(segment_code.zfill(2)) != 2:
            print(f"⚠️ Invalid segment code format: {segment_code}")
            return self.get_segment_fallback("")
        
        # Normalize segment code
        segment_code = segment_code.zfill(2)
        
        # Verify segment exists in database
        valid_segment = None
        for segment in available_segments:
            if segment["code"] == segment_code:
                valid_segment = segment
                break
        
        if not valid_segment:
            print(f"⚠️ Segment code {segment_code} not found in database")
            return self.get_segment_fallback("")
        
        # Successful single classification
        print(f"✅ Segment classified: {segment_code} - {valid_segment['description']}")
        return {
            "success": True,
            "error": None,
            "segment_code": segment_code,
            "segment_description": valid_segment['description'],
            "confidence": classification_data.get("confidence", "Medium"),
            "reasoning": classification_data.get("reasoning", "")
        }
    
    def get_segment_fallback(self, product_summary: str) -> Dict:
        """
        Provide fallback segment classification based on simple keyword matching.
        
        Args:
            product_summary: Product summary for fallback classification
            
        Returns:
            Dict: Fallback classification result
        """
        print("🔄 Using segment fallback classification...")
        
        summary_lower = product_summary.lower()
        
        # Simple keyword-based segment mapping for common cases
        segment_keywords = {
            "40": ["pump", "valve", "distribution", "conditioning", "flow", "hydraulic", "pneumatic"],
            "24": ["machinery", "equipment", "processing", "industrial", "manufacturing"],
            "32": ["electronic", "sensor", "controller", "circuit", "digital"],
            "42": ["medical", "healthcare", "diagnostic", "surgical"],
            "23": ["component", "supply", "part", "fitting", "bearing"]
        }
        
        segment_scores = {}
        for segment_code, keywords in segment_keywords.items():
            score = sum(1 for keyword in keywords if keyword in summary_lower)
            if score > 0:
                segment_scores[segment_code] = score
        
        if segment_scores:
            best_segment = max(segment_scores.items(), key=lambda x: x[1])[0]
            
            # Get segment description from available segments
            segments = self._get_available_segments()
            segment_desc = "Unknown segment"
            for segment in segments:
                if segment["code"] == best_segment:
                    segment_desc = segment["description"]
                    break
            
            print(f"✅ Fallback segment: {best_segment} - {segment_desc}")
            return {
                "success": True,
                "error": None,
                "segment_code": best_segment,
                "segment_description": segment_desc,
                "confidence": "Low",
                "reasoning": "Fallback keyword-based classification"
            }
        
        # Default to segment 23 if nothing matches
        print("⚠️ No fallback match - defaulting to segment 23")
        return {
            "success": True,
            "error": None,
            "segment_code": "23",
            "segment_description": "Manufacturing Components and Supplies",
            "confidence": "Very Low",
            "reasoning": "Default fallback segment"
        } 