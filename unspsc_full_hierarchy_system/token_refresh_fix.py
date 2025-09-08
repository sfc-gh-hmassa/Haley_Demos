"""
🔄 Snowflake Token Refresh Utility

Use this script when you encounter "token expired" errors in Jupyter notebooks.
This will force refresh your Snowflake connection and test it.
"""

from config import refresh_session, test_connection

def fix_expired_token():
    """Fix expired Snowflake token by refreshing the session"""
    print("🔄 **SNOWFLAKE TOKEN REFRESH**")
    print("=" * 50)
    
    try:
        # Force refresh the session
        session = refresh_session("haleyconnect")
        
        # Test the new connection
        if test_connection("haleyconnect"):
            print("✅ **TOKEN REFRESH SUCCESSFUL!**")
            print("   Your Snowflake connection is now working.")
            print("   You can continue using your Jupyter notebook.")
            return True
        else:
            print("❌ **TOKEN REFRESH FAILED**")
            print("   Please check your Snowflake configuration.")
            return False
            
    except Exception as e:
        print(f"❌ **ERROR DURING REFRESH:** {e}")
        print("\n🔧 **TROUBLESHOOTING STEPS:**")
        print("1. Check that your private key file exists and is accessible")
        print("2. Verify your ~/.snowflake/connections.toml is correct")
        print("3. Ensure your Snowflake account and role have proper permissions")
        return False

if __name__ == "__main__":
    print("🚀 **FIXING EXPIRED SNOWFLAKE TOKEN...**")
    print()
    success = fix_expired_token()
    print()
    
    if success:
        print("💡 **NEXT STEPS:**")
        print("1. Go back to your Jupyter notebook")
        print("2. Restart your kernel (Kernel → Restart)")
        print("3. Re-run your cells - the token should now work!")
    else:
        print("💡 **NEED HELP?**")
        print("Run: python tests/test_haleyconnect_setup.py")
        print("This will help diagnose connection issues.") 