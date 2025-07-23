"""
Custom Snowflake LLM for Production UNSPSC System

Wraps Snowflake Cortex LLM functionality for easy use throughout the system.
"""

from typing import Optional
from snowflake.snowpark import Session

class CustomSnowflakeLLM:
    """
    Custom Snowflake Cortex LLM wrapper for production use.
    
    Provides a simple interface to Snowflake Cortex COMPLETE function
    with proper error handling and response management.
    """
    
    def __init__(self, session: Session, model: str = "llama3-70b"):
        """
        Initialize CustomSnowflakeLLM.
        
        Args:
            session: Active Snowflake session
            model: Snowflake Cortex model name
        """
        self.session = session
        self.model = model
        
        # Available Snowflake Cortex models
        self.available_models = [
            "llama3-70b",
            "llama3-8b", 
            "mistral-7b",
            "mistral-large",
            "mixtral-8x7b",
            "llama2-70b-chat"
        ]
        
        if model not in self.available_models:
            print(f"⚠️ Warning: Model '{model}' not in known list. Proceeding anyway...")
    
    def query(self, prompt: str) -> str:
        """
        Execute LLM query using Snowflake Cortex.
        
        Args:
            prompt: Text prompt for the LLM
            
        Returns:
            str: LLM response text
        """
        try:
            # Escape single quotes in prompt for SQL
            escaped_prompt = prompt.replace("'", "''")
            
            # Build Snowflake Cortex query
            sql_query = f"""
            SELECT SNOWFLAKE.CORTEX.COMPLETE(
                '{self.model}',
                '{escaped_prompt}'
            ) as response
            """
            
            # Execute query
            result = self.session.sql(sql_query).collect()
            
            if result and len(result) > 0:
                response = result[0]['RESPONSE']
                return str(response).strip()
            else:
                return "No response from Snowflake Cortex"
                
        except Exception as e:
            error_msg = f"Snowflake Cortex error: {str(e)}"
            print(f"❌ {error_msg}")
            return error_msg
    
    def get_model_name(self) -> str:
        """Get the current model name"""
        return self.model
    
    def change_model(self, new_model: str):
        """
        Change the LLM model.
        
        Args:
            new_model: New model name to use
        """
        if new_model in self.available_models:
            old_model = self.model
            self.model = new_model
            print(f"🔄 Model changed from {old_model} to {new_model}")
        else:
            print(f"❌ Model '{new_model}' not available")
            print(f"   Available models: {', '.join(self.available_models)}")
    
    def get_available_models(self) -> list:
        """Get list of available Snowflake Cortex models"""
        return self.available_models.copy()
    
    def test_llm(self) -> bool:
        """
        Test the LLM functionality with a simple query.
        
        Returns:
            bool: True if test passes
        """
        try:
            test_response = self.query("Say exactly: LLM test successful")
            return "LLM test successful" in test_response
        except Exception:
            return False 