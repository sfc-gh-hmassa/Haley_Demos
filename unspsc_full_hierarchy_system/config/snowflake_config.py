"""
Snowflake Configuration for Production UNSPSC System

Automatically connects to your haleyconnect Snowflake connection.
Provides easy setup and LLM integration.
"""

import sys
import os
from pathlib import Path
from typing import Optional
import toml
from snowflake.snowpark import Session

# Global session instance
_session: Optional[Session] = None
_llm = None

def get_snowflake_session(connection_name: str = "haleyconnect") -> Session:
    """
    Get Snowflake session using existing set up Snowflake configuration.
    
    Returns:
        Session: Active Snowflake session
    """
    global _session
    
    # Test existing session if it exists
    if _session is not None:
        try:
            # Test if session is still valid
            _session.sql("SELECT 1").collect()
            return _session
        except Exception:
            # Session expired or invalid, create a new one
            print("🔄 Session expired, creating new connection...")
            _session = None
    
    print(f"🔗 Connecting to Snowflake using {connection_name}...")
    
    try:
        # Read your connections.toml file
        config_path = Path.home() / ".snowflake" / "connections.toml"
        
        if not config_path.exists():
            raise Exception(f"❌ Snowflake config not found at {config_path}")
            
        config = toml.load(config_path)
        
        if connection_name not in config:
            raise Exception(f"❌ Connection '{connection_name}' not found in config")
            
        conn_config = config[connection_name]
        
        # Build connection parameters
        connection_params = {
            "account": conn_config["account"],
            "user": conn_config["user"],
            "role": conn_config["role"]
        }
        
        # Handle JWT authentication
        if conn_config.get("authenticator") == "SNOWFLAKE_JWT":
            private_key_file = conn_config.get("private_key_file")
            if private_key_file and Path(private_key_file).exists():
                connection_params["private_key_file"] = private_key_file
            else:
                raise Exception(f"❌ Private key file not found: {private_key_file}")
        
        # Create session
        _session = Session.builder.configs(connection_params).create()
        print(f"✅ Connected to Snowflake ({connection_name})")
        
        # Test the connection
        result = _session.sql("SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_DATABASE()").collect()
        if result:
            print(f"   👤 User: {result[0][0]}")
            print(f"   🎭 Role: {result[0][1]}")
            print(f"   🗄️ Database: {result[0][2] if result[0][2] else 'None'}")
        
        return _session
        
    except Exception as e:
        print(f"❌ Snowflake connection failed: {e}")
        print("\n🔧 SETUP INSTRUCTIONS:")
        print("1. Ensure ~/.snowflake/connections.toml exists")
        print("2. Ensure haleyconnect section is configured")
        print("3. Ensure private key file exists and is accessible")
        raise

def get_snowflake_llm(model_name: str = "llama3-70b"):
    """
    Get Snowflake LLM instance using the established session.
    
    Args:
        model_name: Snowflake Cortex model to use
        
    Returns:
        CustomSnowflakeLLM instance
    """
    global _llm
    
    if _llm is not None and _llm.model == model_name:
        return _llm
        
    session = get_snowflake_session()
    
    # Try different import methods to handle script vs module execution
    try:
        from ..models.snowflake_llm import CustomSnowflakeLLM
    except ImportError:
        try:
            # Add parent directory to path for direct script execution
            current_dir = Path(__file__).parent.parent
            sys.path.insert(0, str(current_dir))
            from models.snowflake_llm import CustomSnowflakeLLM
        except ImportError:
            raise ImportError("Could not import CustomSnowflakeLLM. Check models package.")
    
    _llm = CustomSnowflakeLLM(session=session, model=model_name)
    print(f"🧠 Initialized Snowflake LLM: {model_name}")
    
    return _llm

def close_session():
    """Close the current Snowflake session"""
    global _session, _llm
    
    if _session:
        try:
            _session.close()
        except Exception:
            pass  # Ignore errors when closing
        _session = None
        print("🧹 Snowflake session closed")
    
    _llm = None

def refresh_session(connection_name: str = "haleyconnect"):
    """Force refresh of the Snowflake session"""
    global _session, _llm
    print("🔄 Forcing session refresh...")
    close_session()
    return get_snowflake_session(connection_name)

def test_connection(connection_name: str = "haleyconnect") -> bool:
    """
    Test the Snowflake connection and LLM functionality.
    
    Args:
        connection_name: Connection name to test
        
    Returns:
        bool: True if all tests pass
    """
    try:
        print("🧪 Testing Snowflake Connection")
        print("=" * 40)
        
        # Test session
        session = get_snowflake_session(connection_name)
        print("✅ Session connection successful")
        
        # Test LLM
        llm = get_snowflake_llm()
        test_response = llm.query("Say 'Connection test successful'")
        
        if "Connection test successful" in test_response:
            print("✅ LLM test successful")
            print(f"   Response: {test_response[:50]}...")
        else:
            print("⚠️ LLM test partial - received response but unexpected format")
            print(f"   Response: {test_response[:100]}...")
        
        print("✅ All connection tests passed!")
        return True
        
    except Exception as e:
        print(f"❌ Connection test failed: {e}")
        return False 
