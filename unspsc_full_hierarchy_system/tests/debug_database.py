#!/usr/bin/env python3
"""
Debug Database Queries

Test database queries to see what's happening with segment 40 families.
"""

import sys
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

def test_database_queries():
    """Test database queries for segment 40"""
    
    print("🗄️ DEBUGGING UNSPSC DATABASE QUERIES")
    print("=" * 50)
    
    try:
        from database.unspsc_database import UNSPSCDatabase
        from config import get_snowflake_session
        
        db = UNSPSCDatabase()
        session = get_snowflake_session()
        
        # Test direct query for segment 40
        print("1️⃣ Testing direct query for segment 40...")
        
        query = """
        SELECT DISTINCT 
            SEGMENT::STRING as segment_code,
            FAMILY::STRING as family_code,
            SEGMENT_TITLE,
            FAMILY_TITLE
        FROM DEMODB.UNSPSC_CODE_PROJECT.UNSPSC_CODES_UNDP 
        WHERE SUBSTR(SEGMENT::STRING, 1, 2) = '40'
        AND FAMILY IS NOT NULL
        ORDER BY family_code
        LIMIT 10
        """
        
        result = session.sql(query).collect()
        print(f"✅ Found {len(result)} rows for segment 40")
        
        for i, row in enumerate(result[:5]):
            print(f"   {i+1}. Segment: {row[0]}, Family: {row[1]}")
            print(f"      Segment Title: {row[2]}")
            print(f"      Family Title: {row[3]}")
        
        # Test the family query method
        print("\n2️⃣ Testing family query method...")
        families = db.get_families_by_segment("40")
        print(f"Method returned {len(families)} families")
        
        if families:
            for i, family in enumerate(families[:3]):
                print(f"   {i+1}. {family['code']}: {family['description']}")
        
        # Test different segment codes
        print("\n3️⃣ Testing other segments...")
        for seg_code in ["23", "24", "41"]:
            families = db.get_families_by_segment(seg_code)
            print(f"   Segment {seg_code}: {len(families)} families")
        
        # Check raw data
        print("\n4️⃣ Checking raw segment values...")
        
        query2 = """
        SELECT DISTINCT 
            SEGMENT::STRING as segment_raw,
            SUBSTR(SEGMENT::STRING, 1, 2) as segment_prefix
        FROM DEMODB.UNSPSC_CODE_PROJECT.UNSPSC_CODES_UNDP 
        WHERE SEGMENT IS NOT NULL
        AND SUBSTR(SEGMENT::STRING, 1, 2) IN ('40', '23', '24', '41')
        ORDER BY segment_raw
        LIMIT 20
        """
        
        result2 = session.sql(query2).collect()
        print(f"✅ Raw segment data:")
        for row in result2:
            print(f"   Raw: {row[0]}, Prefix: {row[1]}")
        
    except Exception as e:
        import traceback
        print(f"❌ Database test failed: {e}")
        print(traceback.format_exc())

def main():
    test_database_queries()

if __name__ == "__main__":
    main() 