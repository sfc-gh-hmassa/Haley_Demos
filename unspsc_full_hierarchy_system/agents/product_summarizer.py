"""
Product Summarizer Agent

Combines original product description with extracted identifiers and web search intelligence
to create an enhanced product summary for better UNSPSC classification.
"""

from typing import Dict, Any

class ProductSummarizer:
    """
    Agent that creates enhanced product summaries by combining:
    1. Original technical description
    2. LLM-extracted identifiers (brands, models, serials)
    3. Web search intelligence
    """
    
    def __init__(self):
        """Initialize Product Summarizer Agent"""
        pass
    
    def summarize_product(self, original_description: str, extracted_info: Any, web_info: Any) -> str:
        """
        Create enhanced product summary with all available intelligence.
        
        Args:
            original_description: Original technical product description
            extracted_info: ExtractedInfo object with identifiers
            web_info: ProductWebInfo object with web search results
            
        Returns:
            str: Enhanced product summary for classification
        """
        print("📋 Creating enhanced product summary...")
        
        # Start with original description
        summary_parts = [f"Product Description: {original_description}"]
        
        # Add extracted identifier information
        if hasattr(extracted_info, 'manufacturer') and extracted_info.manufacturer:
            summary_parts.append(f"Manufacturer: {extracted_info.manufacturer}")
        
        if hasattr(extracted_info, 'brand_names') and extracted_info.brand_names:
            brands = ", ".join(extracted_info.brand_names)
            summary_parts.append(f"Brand(s): {brands}")
        
        if hasattr(extracted_info, 'model_numbers') and extracted_info.model_numbers:
            models = ", ".join(extracted_info.model_numbers[:3])  # Limit to first 3
            summary_parts.append(f"Model Number(s): {models}")
        
        if hasattr(extracted_info, 'serial_numbers') and extracted_info.serial_numbers:
            serials = ", ".join(extracted_info.serial_numbers[:2])  # Limit to first 2  
            summary_parts.append(f"Serial Number(s): {serials}")
        
        # Add web search intelligence
        if hasattr(web_info, 'product_category') and web_info.product_category:
            summary_parts.append(f"Web Research Category: {web_info.product_category}")
        
        if hasattr(web_info, 'applications') and web_info.applications:
            apps = ", ".join(web_info.applications[:3])  # Limit to first 3
            summary_parts.append(f"Industry Applications: {apps}")
        
        if hasattr(web_info, 'specifications') and web_info.specifications:
            specs = ", ".join(web_info.specifications)
            summary_parts.append(f"Technical Specifications: {specs}")
        
        # Add confidence level from web search
        if hasattr(web_info, 'confidence'):
            summary_parts.append(f"Research Confidence: {web_info.confidence}")
        
        # Create final enhanced summary
        enhanced_summary = " | ".join(summary_parts)
        
        print("✅ Enhanced product summary created")
        print(f"   📝 Length: {len(enhanced_summary)} characters")
        
        return enhanced_summary
    
    def create_classification_prompt_context(self, enhanced_summary: str) -> str:
        """
        Create optimized context for UNSPSC classification prompts.
        
        Args:
            enhanced_summary: Enhanced product summary
            
        Returns:
            str: Formatted context for classification
        """
        context_parts = [
            "PRODUCT INFORMATION FOR UNSPSC CLASSIFICATION:",
            "=" * 50,
            enhanced_summary,
            "",
            "CLASSIFICATION REQUIREMENTS:",
            "- Use the complete product information above",
            "- Consider manufacturer, brand, model, and technical specifications", 
            "- Factor in web research findings about product category",
            "- Ensure classification accuracy based on actual product functionality"
        ]
        
        return "\n".join(context_parts)
    
    def extract_key_classification_terms(self, enhanced_summary: str) -> Dict[str, Any]:
        """
        Extract key terms from enhanced summary for classification guidance.
        
        Args:
            enhanced_summary: Enhanced product summary
            
        Returns:
            Dict: Key classification terms and hints
        """
        summary_lower = enhanced_summary.lower()
        
        classification_hints = {
            "product_type": "",
            "industry_sector": "",
            "key_functions": [],
            "technical_category": ""
        }
        
        # Identify product types
        product_types = {
            "pump": ["pump", "pumping"],
            "valve": ["valve", "control valve"],
            "motor": ["motor", "electric motor"],
            "sensor": ["sensor", "transducer"],
            "controller": ["controller", "control system"],
            "actuator": ["actuator", "cylinder"]
        }
        
        for product_type, keywords in product_types.items():
            if any(keyword in summary_lower for keyword in keywords):
                classification_hints["product_type"] = product_type
                break
        
        # Identify industry sectors
        if any(word in summary_lower for word in ["industrial", "manufacturing"]):
            classification_hints["industry_sector"] = "industrial"
        elif any(word in summary_lower for word in ["automotive", "vehicle"]):
            classification_hints["industry_sector"] = "automotive"
        elif any(word in summary_lower for word in ["medical", "healthcare"]):
            classification_hints["industry_sector"] = "medical"
        
        # Extract key functions
        function_keywords = ["pressure", "flow", "control", "monitoring", "measurement", "power", "hydraulic"]
        classification_hints["key_functions"] = [func for func in function_keywords if func in summary_lower]
        
        return classification_hints 