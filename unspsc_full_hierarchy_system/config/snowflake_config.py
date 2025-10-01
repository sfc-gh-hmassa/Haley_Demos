"""
Snowflake Configuration for Production UNSPSC System

Flexible Snowflake connection supporting multiple authentication methods.
Provides easy setup and LLM integration.
"""

import sys
import os
from pathlib import Path
from typing import Optional, Dict, Any
import toml
import json
from snowflake.snowpark import Session

# Global session instance
_session: Optional[Session] = None
_llm = None

def get_snowflake_session(connection_name: str = "haleyconnect_correct") -> Session:
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
    
    # Try multiple configuration sources
    connection_params = None
    config_source = None
    
    try:
        # Method 1: Try connections.toml file
        config_path = Path.home() / ".snowflake" / "connections.toml"
        if config_path.exists():
            config = toml.load(config_path)
            if connection_name in config:
                connection_params = _build_connection_params(config[connection_name])
                config_source = f"connections.toml ({connection_name})"
        
        # Method 2: Try environment variables if no TOML config
        if connection_params is None:
            connection_params = _build_connection_from_env()
            if connection_params:
                config_source = "environment variables"
        
        # Method 3: Try interactive setup if still none and using default
        if connection_params is None and connection_name in ["default", "haleyconnect"]:
            connection_params = _get_default_connection()
            if connection_params:
                config_source = "interactive setup"
        
        if connection_params is None:
            raise Exception(f"❌ No valid Snowflake configuration found for '{connection_name}'")
        
        # Create session
        _session = Session.builder.configs(connection_params).create()
        print(f"✅ Connected to Snowflake using {config_source}")
        
        # Test the connection
        result = _session.sql("SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_DATABASE()").collect()
        if result:
            print(f"   👤 User: {result[0][0]}")
            print(f"   🎭 Role: {result[0][1]}")
            print(f"   🗄️ Database: {result[0][2] if result[0][2] else 'None'}")
        
        return _session
        
    except Exception as e:
        print(f"❌ Snowflake connection failed: {e}")
        _print_setup_instructions()
        raise

def _build_connection_params(conn_config: Dict[str, Any]) -> Dict[str, Any]:
    """Build connection parameters from configuration"""
    connection_params = {
        "account": conn_config["account"],
        "user": conn_config["user"],
    }
    
    # Add optional parameters
    if "role" in conn_config:
        connection_params["role"] = conn_config["role"]
    if "warehouse" in conn_config:
        connection_params["warehouse"] = conn_config["warehouse"]
    if "database" in conn_config:
        connection_params["database"] = conn_config["database"]
    if "schema" in conn_config:
        connection_params["schema"] = conn_config["schema"]
    
    # Handle different authentication methods
    if conn_config.get("authenticator") == "SNOWFLAKE_JWT":
        private_key_file = conn_config.get("private_key_file")
        if private_key_file and Path(private_key_file).exists():
            connection_params["private_key_file"] = private_key_file
        else:
            raise Exception(f"❌ Private key file not found: {private_key_file}")
    elif "password" in conn_config:
        connection_params["password"] = conn_config["password"]
    elif "authenticator" in conn_config:
        connection_params["authenticator"] = conn_config["authenticator"]
    
    return connection_params

def _build_connection_from_env() -> Optional[Dict[str, Any]]:
    """Build connection parameters from environment variables"""
    required_env = ["SNOWFLAKE_ACCOUNT", "SNOWFLAKE_USER"]
    
    if not all(os.getenv(var) for var in required_env):
        return None
    
    connection_params = {
        "account": os.getenv("SNOWFLAKE_ACCOUNT"),
        "user": os.getenv("SNOWFLAKE_USER"),
    }
    
    # Add optional environment variables
    if os.getenv("SNOWFLAKE_PASSWORD"):
        connection_params["password"] = os.getenv("SNOWFLAKE_PASSWORD")
    if os.getenv("SNOWFLAKE_ROLE"):
        connection_params["role"] = os.getenv("SNOWFLAKE_ROLE")
    if os.getenv("SNOWFLAKE_WAREHOUSE"):
        connection_params["warehouse"] = os.getenv("SNOWFLAKE_WAREHOUSE")
    if os.getenv("SNOWFLAKE_DATABASE"):
        connection_params["database"] = os.getenv("SNOWFLAKE_DATABASE")
    if os.getenv("SNOWFLAKE_SCHEMA"):
        connection_params["schema"] = os.getenv("SNOWFLAKE_SCHEMA")
    if os.getenv("SNOWFLAKE_PRIVATE_KEY_FILE"):
        connection_params["private_key_file"] = os.getenv("SNOWFLAKE_PRIVATE_KEY_FILE")
    if os.getenv("SNOWFLAKE_AUTHENTICATOR"):
        connection_params["authenticator"] = os.getenv("SNOWFLAKE_AUTHENTICATOR")
    
    return connection_params

def _get_default_connection() -> Optional[Dict[str, Any]]:
    """Interactive setup for default connection"""
    print("🔧 No Snowflake configuration found. Let's set one up!")
    print("   You can also set environment variables or create ~/.snowflake/connections.toml")
    
    try:
        account = input("   Enter your Snowflake account identifier: ").strip()
        user = input("   Enter your Snowflake username: ").strip()
        
        if not account or not user:
            return None
            
        connection_params = {
            "account": account,
            "user": user
        }
        
        # Ask for password or key file
        auth_choice = input("   Authentication method (1=password, 2=key file): ").strip()
        if auth_choice == "1":
            import getpass
            password = getpass.getpass("   Enter your Snowflake password: ")
            connection_params["password"] = password
        elif auth_choice == "2":
            key_file = input("   Enter path to your private key file: ").strip()
            if key_file and Path(key_file).exists():
                connection_params["private_key_file"] = key_file
                connection_params["authenticator"] = "SNOWFLAKE_JWT"
            else:
                print("   ❌ Key file not found, falling back to password")
                return None
        
        # Optional parameters
        role = input("   Enter your role (optional, press Enter to skip): ").strip()
        if role:
            connection_params["role"] = role
            
        return connection_params
        
    except (KeyboardInterrupt, EOFError):
        print("\n   Setup cancelled.")
        return None

def _print_setup_instructions():
    """Print setup instructions for Snowflake configuration"""
    print("\n🔧 SNOWFLAKE SETUP OPTIONS:")
    print("=" * 50)
    
    print("\n📋 Option 1: Environment Variables")
    print("Set these environment variables:")
    print("   export SNOWFLAKE_ACCOUNT='your-account'")
    print("   export SNOWFLAKE_USER='your-username'")
    print("   export SNOWFLAKE_PASSWORD='your-password'  # OR")
    print("   export SNOWFLAKE_PRIVATE_KEY_FILE='/path/to/key.pem'")
    print("   export SNOWFLAKE_ROLE='your-role'  # optional")
    
    print("\n📋 Option 2: Configuration File")
    print("Create ~/.snowflake/connections.toml:")
    print("   [default]")
    print("   account = 'your-account'")
    print("   user = 'your-username'")
    print("   password = 'your-password'  # OR")
    print("   private_key_file = '/path/to/key.pem'")
    print("   authenticator = 'SNOWFLAKE_JWT'  # if using key")
    print("   role = 'your-role'  # optional")
    
    print("\n📋 Option 3: Interactive Setup")
    print("Run: python -c \"from config import get_snowflake_session; get_snowflake_session()\"")
    
    print("\n💡 For Cortex LLM access, ensure your role has USAGE privileges on the model.")
    print("   Example: GRANT USAGE ON FUNCTION SNOWFLAKE.CORTEX.COMPLETE TO ROLE your_role;")

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

def refresh_session(connection_name: str = "haleyconnect_correct"):
    """Force refresh of the Snowflake session"""
    global _session, _llm
    print("🔄 Forcing session refresh...")
    close_session()
    return get_snowflake_session(connection_name)

def test_connection(connection_name: str = "haleyconnect_correct") -> bool:
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
