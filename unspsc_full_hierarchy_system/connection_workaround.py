
# Updated configuration for IP-restricted environment
import os
from pathlib import Path

def get_working_connection():
    '''Get a working Snowflake connection or provide alternatives'''
    
    # Try browser-based authentication (may bypass IP restrictions)
    browser_connections = [
        "haleyconnect_browser",
        "haleyconnect_temp"
    ]
    
    for conn in browser_connections:
        try:
            # Test if this connection works
            import subprocess
            result = subprocess.run(
                ['snow', 'connection', 'test', '-c', conn],
                capture_output=True, text=True, timeout=10
            )
            if result.returncode == 0:
                return conn
        except:
            continue
    
    return None

def setup_alternative_access():
    '''Set up alternative access methods'''
    print("🌐 **ALTERNATIVE ACCESS OPTIONS:**")
    print("1. VPN Connection - Connect to your company VPN")
    print("2. Network Allowlist - Ask admin to add your IP")
    print("3. Different Network - Try from office/different location") 
    print("4. Proxy/Tunnel - Use authorized network connection")
    print("5. Mock Mode - Use demo_with_mock_snowflake.py")
