"""
Production UNSPSC Classification System

A sophisticated, production-ready UNSPSC classification system that combines:
- LLM-powered product identifier extraction
- Real-time web search intelligence gathering
- Enhanced product summarization
- Complete hierarchical UNSPSC classification
- Validation and confusion handling at each level
- Your haleyconnect Snowflake connection
- Snowflake Cortex LLM integration

Quick Start:
    from production_unspsc_system.chain import UNSPSCClassificationChain
    
    classifier = UNSPSCClassificationChain()
    result = classifier.classify_product("Your product description here")
    classifier.print_classification_summary(result)
"""

__version__ = "1.0.0"
__author__ = "Claude AI Assistant"

# Main exports
from .chain import UNSPSCClassificationChain
from .config import get_snowflake_session, get_snowflake_llm, test_connection

__all__ = [
    'UNSPSCClassificationChain',
    'get_snowflake_session', 
    'get_snowflake_llm',
    'test_connection'
] 