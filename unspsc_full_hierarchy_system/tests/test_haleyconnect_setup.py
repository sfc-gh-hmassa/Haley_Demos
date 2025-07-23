#!/usr/bin/env python3
"""
Test haleyconnect Snowflake Connection

Validates that your haleyconnect credentials work correctly
and that Snowflake Cortex LLM is accessible.
"""

import sys
from pathlib import Path

# Add parent directory to path for imports  
sys.path.insert(0, str(Path(__file__).parent.parent))

def test_haleyconnect_connection():
    """Test haleyconnect Snowflake connection and LLM access"""
    print("🏭 TESTING PRODUCTION UNSPSC SYSTEM SETUP")
    print("=" * 60)
    
    try:
        print("🔗 Testing haleyconnect Snowflake connection...")
        from config import test_connection
        
        # Test connection
        if test_connection("haleyconnect"):
            print("✅ SUCCESS! Your haleyconnect connection is working!")
            print("✅ Snowflake Cortex LLM is functional!")
            print("✅ Ready to build the complete UNSPSC system!")
            
            print("\n🚀 NEXT STEPS:")
            print("1. ✅ Connection verified")
            print("2. 🏗️ Building extraction system...")
            print("3. 🌐 Adding web search capability...")
            print("4. 🤖 Creating classification agents...")
            print("5. ⛓️ Building orchestration chain...")
            
            return True
        else:
            print("❌ FAILED! Connection test unsuccessful")
            return False
            
    except ImportError as e:
        print(f"❌ FAILED! Could not import required modules: {e}")
        print("\n🛠️ TROUBLESHOOTING:")
        print("1. Ensure you're in the correct directory")
        print("2. Check that all required files exist")
        print("3. Verify your virtual environment is activated")
        return False
        
    except Exception as e:
        print(f"❌ FAILED! Unexpected error: {e}")
        print("\n🛠️ TROUBLESHOOTING:")
        print("1. Check your network connection")
        print("2. Verify haleyconnect credentials")  
        print("3. Ensure Snowflake account is accessible")
        return False

def main():
    """Main test function"""
    success = test_haleyconnect_connection()
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main() 