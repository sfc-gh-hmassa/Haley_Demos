#!/usr/bin/env python3
"""
🔧 Snowflake Setup Utility

This script helps you set up your Snowflake connection for the UNSPSC Classification System.
It supports multiple authentication methods and creates the necessary configuration files.
"""

import os
import sys
import getpass
from pathlib import Path
import toml

def create_connections_toml():
    """Create a connections.toml file interactively"""
    print("🔧 **SNOWFLAKE CONNECTION SETUP**")
    print("=" * 50)
    
    # Get connection details
    print("\n📋 **Basic Connection Information**")
    account = input("Snowflake Account Identifier: ").strip()
    user = input("Username: ").strip()
    
    if not account or not user:
        print("❌ Account and username are required!")
        return False
    
    # Choose authentication method
    print("\n🔐 **Authentication Method**")
    print("1. Password authentication")
    print("2. Private key (JWT) authentication")
    print("3. SSO/External authentication")
    
    auth_choice = input("Choose authentication method (1-3): ").strip()
    
    connection_config = {
        "account": account,
        "user": user
    }
    
    if auth_choice == "1":
        # Password authentication
        password = getpass.getpass("Password: ")
        connection_config["password"] = password
        
    elif auth_choice == "2":
        # JWT authentication
        key_file = input("Path to private key file (.pem): ").strip()
        if key_file and Path(key_file).expanduser().exists():
            connection_config["private_key_file"] = str(Path(key_file).expanduser().absolute())
            connection_config["authenticator"] = "SNOWFLAKE_JWT"
        else:
            print("❌ Private key file not found!")
            return False
            
    elif auth_choice == "3":
        # SSO authentication
        authenticator = input("Authenticator (e.g., 'externalbrowser'): ").strip()
        if authenticator:
            connection_config["authenticator"] = authenticator
        else:
            print("❌ Authenticator is required for SSO!")
            return False
    else:
        print("❌ Invalid choice!")
        return False
    
    # Optional parameters
    print("\n⚙️ **Optional Parameters** (press Enter to skip)")
    role = input("Role: ").strip()
    if role:
        connection_config["role"] = role
        
    warehouse = input("Warehouse: ").strip()
    if warehouse:
        connection_config["warehouse"] = warehouse
        
    database = input("Database: ").strip()
    if database:
        connection_config["database"] = database
        
    schema = input("Schema: ").strip()
    if schema:
        connection_config["schema"] = schema
    
    # Create the configuration file
    config_dir = Path.home() / ".snowflake"
    config_dir.mkdir(exist_ok=True)
    
    config_file = config_dir / "connections.toml"
    
    # Load existing config or create new
    if config_file.exists():
        config = toml.load(config_file)
    else:
        config = {}
    
    config["default"] = connection_config
    
    # Write configuration
    with open(config_file, 'w') as f:
        toml.dump(config, f)
    
    print(f"\n✅ Configuration saved to {config_file}")
    return True

def test_connection():
    """Test the Snowflake connection"""
    print("\n🧪 **Testing Connection**")
    print("-" * 30)
    
    try:
        from config import test_connection
        
        if test_connection("default"):
            print("✅ **CONNECTION SUCCESSFUL!**")
            print("   Your Snowflake setup is working correctly.")
            print("   You can now use the UNSPSC Classification System.")
            return True
        else:
            print("❌ **CONNECTION FAILED!**")
            print("   Please check your configuration and try again.")
            return False
            
    except Exception as e:
        print(f"❌ **ERROR:** {e}")
        return False

def setup_environment_variables():
    """Show how to set up environment variables"""
    print("\n🌍 **Environment Variable Setup**")
    print("=" * 40)
    print("Instead of a config file, you can set these environment variables:")
    print()
    print("# Required")
    print("export SNOWFLAKE_ACCOUNT='your-account-identifier'")
    print("export SNOWFLAKE_USER='your-username'")
    print()
    print("# Authentication (choose one)")
    print("export SNOWFLAKE_PASSWORD='your-password'")
    print("# OR")
    print("export SNOWFLAKE_PRIVATE_KEY_FILE='/path/to/private_key.pem'")
    print("export SNOWFLAKE_AUTHENTICATOR='SNOWFLAKE_JWT'")
    print()
    print("# Optional")
    print("export SNOWFLAKE_ROLE='your-role'")
    print("export SNOWFLAKE_WAREHOUSE='your-warehouse'")
    print("export SNOWFLAKE_DATABASE='your-database'")
    print("export SNOWFLAKE_SCHEMA='your-schema'")
    print()

def main():
    """Main setup function"""
    print("🚀 **SNOWFLAKE SETUP FOR UNSPSC CLASSIFICATION SYSTEM**")
    print("=" * 60)
    
    print("\n🎯 **Setup Options:**")
    print("1. Create connections.toml file (recommended)")
    print("2. Show environment variable setup")
    print("3. Test existing connection")
    print("4. Exit")
    
    while True:
        choice = input("\nChoose an option (1-4): ").strip()
        
        if choice == "1":
            if create_connections_toml():
                if test_connection():
                    break
                else:
                    print("\n🔄 Would you like to try again? (y/n)")
                    if input().lower() != 'y':
                        break
            else:
                print("\n🔄 Would you like to try again? (y/n)")
                if input().lower() != 'y':
                    break
                    
        elif choice == "2":
            setup_environment_variables()
            
        elif choice == "3":
            test_connection()
            
        elif choice == "4":
            print("👋 Goodbye!")
            break
            
        else:
            print("❌ Invalid choice. Please enter 1-4.")
    
    print("\n💡 **Next Steps:**")
    print("- Run: python interactive_demo.py")
    print("- Or: jupyter notebook UNSPSC_Classification_Demo.ipynb")
    print("- For help: python tests/test_snowflake_setup.py")

if __name__ == "__main__":
    main()
