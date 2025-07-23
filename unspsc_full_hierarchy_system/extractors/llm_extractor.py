"""
Intelligent LLM-based Product Identifier Extractor

Uses Snowflake Cortex LLM to intelligently extract product identifiers and determine
what information is worth web searching for additional product intelligence.
"""

import re
import json
import sys
import os
from pathlib import Path
from typing import List, Dict, Optional
from dataclasses import dataclass, field

@dataclass
class ExtractedInfo:
    """Container for extracted product information"""
    brand_names: List[str] = field(default_factory=list)
    serial_numbers: List[str] = field(default_factory=list)
    model_numbers: List[str] = field(default_factory=list)
    manufacturer: str = ""
    product_series: str = ""
    part_numbers: List[str] = field(default_factory=list)
    
    # New intelligent fields
    key_identifiers: List[str] = field(default_factory=list)  # Most important identifiers
    search_worthy_terms: List[str] = field(default_factory=list)  # What should be web searched
    confidence_scores: Dict[str, float] = field(default_factory=dict)  # Confidence in extractions

class LLMProductExtractor:
    """
    Intelligent LLM-based product identifier extractor.
    
    Uses Snowflake Cortex LLM to smartly extract identifiers and determine
    what information is worth investigating further through web search.
    """
    
    def __init__(self):
        # Generic patterns for fallback extraction - no hardcoded brands/types
        self.emergency_patterns = [
            r'\b[A-Z]{2,}[-_]?[0-9]{3,}[-_]?[A-Z0-9\-_]{2,}\b',  # Alphanumeric codes
            r'\b(?:Model|Part|Serial|P/?N|S/?N)[:\s]+([A-Z0-9\-_\/\.]+)\b',  # Labeled identifiers
            r'\b[A-Z][a-z]+ [A-Z][a-z]+\b',  # Potential brand names (Title Case)
            r'\b[0-9]{4,}[-_][A-Z0-9\-_]{2,}\b',  # Numeric prefixed codes
        ]
    
    def extract_with_intelligent_llm(self, product_description: str) -> ExtractedInfo:
        """
        Intelligently extract product identifiers using Snowflake LLM.
        
        Args:
            product_description: Technical product description text
            
        Returns:
            ExtractedInfo: Intelligently extracted product identifiers
        """
        
        # Generic, scalable prompt - no hardcoded examples
        intelligent_prompt = f"""
        Extract product identifiers from this description. Be intelligent about what information would be useful for product classification.

        Product: {product_description}

        Return valid JSON only:
        {{
            "brand_names": [],
            "model_numbers": [],
            "serial_numbers": [],
            "part_numbers": [],
            "manufacturer": "",
            "search_worthy_terms": []
        }}

        Instructions:
        - brand_names: Company/brand names found in the description
        - model_numbers: Product model identifiers
        - serial_numbers: Serial number identifiers  
        - part_numbers: Part/catalog numbers
        - manufacturer: Main manufacturer if identifiable
        - search_worthy_terms: 2-3 terms that would be most useful for web searching to learn more about this product
        """
        
        try:
            # Get LLM instance - handle both import styles
            current_dir = Path(__file__).parent.parent
            sys.path.insert(0, str(current_dir))
            
            try:
                from ..config import get_snowflake_llm
            except ImportError:
                from config import get_snowflake_llm
            
            llm = get_snowflake_llm()
            
            # Get LLM response
            response = llm.query(intelligent_prompt).strip()
            print(f"🔍 LLM Response: {response[:200]}...")
            
            if not response:
                print("⚠️ Empty LLM response")
                return self._emergency_extraction(product_description)
            
            # Clean response to extract JSON
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
            
            # Parse JSON response
            extracted_data = json.loads(response)
            
            # Create ExtractedInfo with intelligent data
            extracted_info = ExtractedInfo(
                brand_names=extracted_data.get('brand_names', []),
                serial_numbers=extracted_data.get('serial_numbers', []),
                model_numbers=extracted_data.get('model_numbers', []),
                manufacturer=extracted_data.get('manufacturer', ''),
                product_series=extracted_data.get('product_series', ''),
                part_numbers=extracted_data.get('part_numbers', []),
                key_identifiers=extracted_data.get('key_identifiers', []),
                search_worthy_terms=extracted_data.get('search_worthy_terms', []),
                confidence_scores={'overall_extraction': 0.8}  # Default confidence
            )
            
            return extracted_info
            
        except (json.JSONDecodeError, KeyError, ImportError, Exception) as e:
            print(f"⚠️ Intelligent LLM extraction failed: {e}")
            print("🔄 Falling back to emergency extraction...")
            return self._emergency_extraction(product_description)
    
    def _emergency_extraction(self, product_description: str) -> ExtractedInfo:
        """
        Emergency extraction when LLM completely fails.
        Uses generic patterns without hardcoded brands/types.
        
        Args:
            product_description: Technical product description
            
        Returns:
            ExtractedInfo: Basic extracted information
        """
        extracted_info = ExtractedInfo()
        
        # Emergency extraction - pattern-based, no hardcoding
        all_matches = []
        for pattern in self.emergency_patterns:
            matches = re.findall(pattern, product_description, re.IGNORECASE)
            all_matches.extend(matches)
        
        # Generic pattern-based extraction
        description_words = product_description.split()
        
        # Look for potential brand names (capitalized words)
        potential_brands = []
        for word in description_words:
            # Capitalized words that aren't common words
            if (word.istitle() and len(word) > 2 and 
                word not in ['Model', 'Serial', 'Part', 'Number', 'Type', 'System']):
                potential_brands.append(word)
        
        # Take first few as potential brands
        extracted_info.brand_names = potential_brands[:3]
        
        # Look for model-like patterns
        model_patterns = [
            r'\b[A-Z]+\d+[A-Z0-9\-]*\b',  # Letters followed by numbers
            r'\b\d+[A-Z]+\d*\b',          # Numbers with letters
            r'\b[A-Z]{2,}\-\d+\b'         # Letters-numbers format
        ]
        
        for pattern in model_patterns:
            matches = re.findall(pattern, product_description)
            extracted_info.model_numbers.extend(matches)
        
        # Look for serial number patterns
        serial_patterns = [
            r'(?:Serial|S/?N|SN)[:\s]+([A-Z0-9\-_]+)',
            r'\b[A-Z0-9]{8,}\b'  # Long alphanumeric strings
        ]
        
        for pattern in serial_patterns:
            matches = re.findall(pattern, product_description, re.IGNORECASE)
            extracted_info.serial_numbers.extend(matches)
        
        # Create search terms from what we found
        search_terms = []
        
        # Combine brand + model if available
        if extracted_info.brand_names and extracted_info.model_numbers:
            search_terms.append(f"{extracted_info.brand_names[0]} {extracted_info.model_numbers[0]}")
        
        # Add individual strong identifiers
        strong_identifiers = []
        for item in (extracted_info.model_numbers + extracted_info.serial_numbers):
            if len(item) > 4:  # Only substantial identifiers
                strong_identifiers.append(item)
        
        search_terms.extend(strong_identifiers[:2])  # Add top 2
        
        extracted_info.search_worthy_terms = search_terms
        extracted_info.key_identifiers = (extracted_info.brand_names + 
                                        extracted_info.model_numbers)
        
        if extracted_info.brand_names:
            extracted_info.manufacturer = extracted_info.brand_names[0]
        
        # Remove duplicates
        for field_name in ['brand_names', 'model_numbers', 'serial_numbers', 
                          'search_worthy_terms', 'key_identifiers']:
            field_list = getattr(extracted_info, field_name)
            setattr(extracted_info, field_name, list(dict.fromkeys(field_list)))
        
        # Confidence for emergency extraction
        extracted_info.confidence_scores = {
            "overall_extraction": 0.4 if extracted_info.search_worthy_terms else 0.2
        }
        
        return extracted_info
    
    def extract_all(self, product_description: str) -> ExtractedInfo:
        """
        Intelligently extract all product identifiers.
        
        Args:
            product_description: Technical product description
            
        Returns:
            ExtractedInfo: Complete intelligently extracted information
        """
        print("🧠 Intelligently extracting product identifiers with Snowflake LLM...")
        
        # Use intelligent LLM extraction
        extracted_info = self.extract_with_intelligent_llm(product_description)
        
        # Check if we got meaningful results
        overall_confidence = extracted_info.confidence_scores.get('overall_extraction', 0.0)
        has_content = any([
            extracted_info.brand_names,
            extracted_info.serial_numbers, 
            extracted_info.model_numbers,
            extracted_info.key_identifiers,
            extracted_info.search_worthy_terms
        ])
        
        if not has_content or overall_confidence < 0.3:
            print("⚠️ LLM extraction confidence too low or empty results")
            print("🔄 Using emergency extraction...")
            extracted_info = self._emergency_extraction(product_description)
        
        print("✅ Intelligent extraction completed:")
        print(f"   📛 Brands: {extracted_info.brand_names}")
        print(f"   🔢 Models: {extracted_info.model_numbers}")
        print(f"   🏷️ Serials: {extracted_info.serial_numbers}")
        print(f"   🎯 Key Identifiers: {extracted_info.key_identifiers}")
        print(f"   🌐 Search Worthy: {extracted_info.search_worthy_terms}")
        print(f"   🏭 Manufacturer: {extracted_info.manufacturer}")
        
        # Show confidence scores
        if extracted_info.confidence_scores:
            overall_conf = extracted_info.confidence_scores.get('overall_extraction', 0.0)
            print(f"   🎯 Overall Confidence: {overall_conf:.1%}")
        
        return extracted_info
    
    def get_search_terms(self, extracted_info: ExtractedInfo) -> List[str]:
        """
        Get intelligent search terms prioritizing what the LLM deemed search-worthy.
        
        Args:
            extracted_info: Previously extracted product information
            
        Returns:
            List[str]: Optimized search terms for web search
        """
        search_terms = []
        
        # Prioritize LLM-identified search-worthy terms
        if extracted_info.search_worthy_terms:
            print("🌐 Using intelligent search terms:")
            for term in extracted_info.search_worthy_terms:
                print(f"   • {term}")
            search_terms.extend(extracted_info.search_worthy_terms)
        
        # Add key identifiers if they're not already included
        for key_id in extracted_info.key_identifiers:
            if key_id not in search_terms:
                search_terms.append(key_id)
        
        # Smart combination of brand + model for any remaining space
        for brand in extracted_info.brand_names[:2]:  # Max 2 brands
            for model in extracted_info.model_numbers[:2]:  # Max 2 models
                combined_term = f"{brand} {model}"
                if combined_term not in search_terms:
                    search_terms.append(combined_term)
        
        # Add high-value individual terms
        for term in (extracted_info.serial_numbers + extracted_info.part_numbers):
            if len(term) > 6 and term not in search_terms:  # Only substantial terms
                search_terms.append(term)
        
        # Remove duplicates and clean up
        search_terms = [term.strip() for term in search_terms if term.strip()]
        search_terms = list(dict.fromkeys(search_terms))  # Remove duplicates preserving order
        
        # Prioritize by length and complexity (more specific terms first)
        search_terms.sort(key=lambda x: (len(x), x.count('-'), x.count('_')), reverse=True)
        
        return search_terms[:5]  # Return top 5 search terms 