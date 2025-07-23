"""
UNSPSC Database Interface

Connects to Snowflake UNSPSC codes table to retrieve hierarchical classification data.
Provides methods for getting segments, families, classes, and commodities.
"""

import sys
import os
from pathlib import Path
from typing import List, Dict, Optional, Any
from snowflake.snowpark import Session

class UNSPSCDatabase:
    """
    Interface to UNSPSC codes database in Snowflake.
    
    Provides methods to retrieve hierarchical UNSPSC classification data
    with proper validation and error handling.
    """
    
    def __init__(self):
        """Initialize UNSPSC Database interface"""
        self.session: Optional[Session] = None
        self.database = "DEMODB"
        self.schema = "UNSPSC_CODE_PROJECT"
        self.table = "UNSPSC_CODES_UNDP"
    
    def _get_session(self) -> Session:
        """Get Snowflake session"""
        if self.session is None:
            # Handle both relative and absolute imports
            current_dir = Path(__file__).parent.parent
            sys.path.insert(0, str(current_dir))
            
            try:
                from ..config import get_snowflake_session
            except ImportError:
                try:
                    from config import get_snowflake_session
                except ImportError:
                    print("❌ Could not import get_snowflake_session")
                    raise
            
            self.session = get_snowflake_session()
        return self.session
    
    def get_all_segments(self) -> List[Dict[str, str]]:
        """
        Get all UNSPSC segments (2-digit codes).
        
        Returns:
            List[Dict]: List of segments with code and description
        """
        try:
            session = self._get_session()
            
            query = f"""
            SELECT DISTINCT 
                SUBSTR(SEGMENT::STRING, 1, 2) as segment_code,
                SEGMENT_TITLE as segment_description
            FROM {self.database}.{self.schema}.{self.table}
            WHERE SEGMENT IS NOT NULL
            ORDER BY segment_code
            """
            
            result = session.sql(query).collect()
            
            segments = []
            for row in result:
                segments.append({
                    "code": str(row[0]).zfill(2),  # Ensure 2-digit format
                    "description": row[1] if row[1] else "Unknown segment"
                })
            
            print(f"✅ Loaded {len(segments)} UNSPSC segments from database")
            return segments
            
        except Exception as e:
            print(f"❌ Error loading segments from database: {e}")
            print("🔄 Using fallback segments...")
            return self._get_fallback_segments()
    
    def get_families_by_segment(self, segment_code: str) -> List[Dict[str, str]]:
        """
        Get all families for a specific segment (4-digit codes).
        
        Args:
            segment_code: 2-digit segment code
            
        Returns:
            List[Dict]: List of families with code and description
        """
        try:
            session = self._get_session()
            
            # Convert 2-digit to full segment code (e.g., "23" -> "23000000")
            full_segment_code = segment_code.zfill(2) + "000000"
            
            query = f"""
            SELECT DISTINCT 
                SUBSTR(FAMILY::STRING, 1, 4) as family_code,
                FAMILY_TITLE as family_description
            FROM {self.database}.{self.schema}.{self.table}
            WHERE SEGMENT = {int(full_segment_code)}
            AND FAMILY IS NOT NULL
            ORDER BY family_code
            """
            
            result = session.sql(query).collect()
            
            families = []
            for row in result:
                family_code = str(row[0]).zfill(4)
                # Validate that family starts with segment prefix
                if family_code.startswith(segment_code.zfill(2)):
                    families.append({
                        "code": family_code,
                        "description": row[1] if row[1] else "Unknown family"
                    })
            
            print(f"✅ Loaded {len(families)} families for segment {segment_code}")
            return families
            
        except Exception as e:
            print(f"❌ Error loading families for segment {segment_code}: {e}")
            return []
    
    def get_classes_by_family(self, family_code: str) -> List[Dict[str, str]]:
        """
        Get all classes for a specific family (6-digit codes).
        
        Args:
            family_code: 4-digit family code
            
        Returns:
            List[Dict]: List of classes with code and description
        """
        try:
            session = self._get_session()
            
            # Convert 4-digit to full family code (e.g., "2320" -> "23200000") 
            full_family_code = family_code.zfill(4) + "0000"
            
            query = f"""
            SELECT DISTINCT 
                SUBSTR(CLASS::STRING, 1, 6) as class_code,
                CLASS_TITLE as class_description
            FROM {self.database}.{self.schema}.{self.table}
            WHERE FAMILY = {int(full_family_code)}
            AND CLASS IS NOT NULL
            ORDER BY class_code
            """
            
            result = session.sql(query).collect()
            
            classes = []
            for row in result:
                class_code = str(row[0]).zfill(6)
                # Validate that class starts with family prefix
                if class_code.startswith(family_code.zfill(4)):
                    classes.append({
                        "code": class_code,
                        "description": row[1] if row[1] else "Unknown class"
                    })
            
            print(f"✅ Loaded {len(classes)} classes for family {family_code}")
            return classes
            
        except Exception as e:
            print(f"❌ Error loading classes for family {family_code}: {e}")
            return []
    
    def get_commodities_by_class(self, class_code: str) -> List[Dict[str, str]]:
        """
        Get all commodities for a specific class (8-digit codes).
        
        Args:
            class_code: 6-digit class code
            
        Returns:
            List[Dict]: List of commodities with code and description
        """
        try:
            session = self._get_session()
            
            # Convert 6-digit to full class code (e.g., "232015" -> "23201500")
            full_class_code = class_code.zfill(6) + "00"
            
            query = f"""
            SELECT DISTINCT 
                COMMODITY::STRING as commodity_code,
                COMMODITY_TITLE as commodity_description
            FROM {self.database}.{self.schema}.{self.table}
            WHERE CLASS = {int(full_class_code)}
            AND COMMODITY IS NOT NULL
            ORDER BY commodity_code
            """
            
            result = session.sql(query).collect()
            
            commodities = []
            for row in result:
                commodity_code = str(row[0]).zfill(8)
                # Validate that commodity starts with class prefix
                if commodity_code.startswith(class_code.zfill(6)):
                    commodities.append({
                        "code": commodity_code,
                        "description": row[1] if row[1] else "Unknown commodity"
                    })
            
            print(f"✅ Loaded {len(commodities)} commodities for class {class_code}")
            return commodities
            
        except Exception as e:
            print(f"❌ Error loading commodities for class {class_code}: {e}")
            return []
    
    def get_commodity_with_hierarchy(self, commodity_code: str) -> Dict[str, Any]:
        """
        Get a specific commodity with its complete hierarchy parsed from the 8-digit code.
        
        Args:
            commodity_code: 8-digit commodity code (e.g., "10101501")
            
        Returns:
            Dict: Complete hierarchy information
        """
        try:
            session = self._get_session()
            
            # Ensure 8-digit format
            full_code = commodity_code.zfill(8)
            
            query = f"""
            SELECT 
                COMMODITY::STRING as commodity_code,
                COMMODITY_TITLE as commodity_description
            FROM {self.database}.{self.schema}.{self.table}
            WHERE COMMODITY = {int(full_code)}
            """
            
            result = session.sql(query).collect()
            
            if result:
                row = result[0]
                return self._parse_hierarchy_from_commodity_code(str(row[0]).zfill(8), str(row[1]) if row[1] else "Unknown commodity")
            else:
                return {"success": False, "error": f"Commodity code {commodity_code} not found"}
                
        except Exception as e:
            print(f"❌ Error getting commodity {commodity_code}: {e}")
            return {"success": False, "error": str(e)}
    
    def _parse_hierarchy_from_commodity_code(self, commodity_code: str, commodity_description: str) -> Dict[str, Any]:
        """
        Parse complete UNSPSC hierarchy from an 8-digit commodity code.
        
        Args:
            commodity_code: 8-digit commodity code (e.g., "10101501")
            commodity_description: Description of the commodity
            
        Returns:
            Dict: Complete hierarchy breakdown
        """
        full_code = commodity_code.zfill(8)
        
        # Extract hierarchy levels from the 8-digit code
        segment_code = full_code[:2]           # First 2 digits: "10"
        family_code = full_code[:4]            # First 4 digits: "1010"  
        class_code = full_code[:6]             # First 6 digits: "101015"
        
        # Get descriptions for each level by querying the database
        hierarchy = {
            "success": True,
            "commodity": {
                "code": full_code,
                "description": commodity_description
            },
            "class": self._get_level_description(class_code + "00", "CLASS"),
            "family": self._get_level_description(family_code + "0000", "FAMILY"), 
            "segment": self._get_level_description(segment_code + "000000", "SEGMENT"),
            "complete_hierarchy": {
                "segment_code": segment_code,
                "family_code": family_code,
                "class_code": class_code,
                "commodity_code": full_code
            }
        }
        
        return hierarchy
    
    def _get_level_description(self, padded_code: str, level_column: str) -> Dict[str, str]:
        """Get description for a specific hierarchy level"""
        try:
            session = self._get_session()
            
            if level_column == "SEGMENT":
                title_column = "SEGMENT_TITLE"
            elif level_column == "FAMILY":
                title_column = "FAMILY_TITLE"
            elif level_column == "CLASS":
                title_column = "CLASS_TITLE"
            else:
                return {"code": "", "description": "Unknown"}
            
            query = f"""
            SELECT DISTINCT {title_column}
            FROM {self.database}.{self.schema}.{self.table}
            WHERE {level_column} = {int(padded_code)}
            AND {title_column} IS NOT NULL
            LIMIT 1
            """
            
            result = session.sql(query).collect()
            
            if result and result[0][0]:
                return {
                    "code": padded_code.lstrip('0')[:2 if level_column == "SEGMENT" else 4 if level_column == "FAMILY" else 6],
                    "description": str(result[0][0])
                }
            else:
                return {
                    "code": padded_code.lstrip('0')[:2 if level_column == "SEGMENT" else 4 if level_column == "FAMILY" else 6],
                    "description": f"Unknown {level_column.lower()}"
                }
                
        except Exception as e:
            return {
                "code": padded_code.lstrip('0')[:2 if level_column == "SEGMENT" else 4 if level_column == "FAMILY" else 6],
                "description": f"Error getting {level_column.lower()}: {str(e)}"
            }
    
    def search_commodities_by_text(self, search_terms: List[str], limit: int = 20) -> List[Dict[str, Any]]:
        """
        Search for commodities by text match in their descriptions.
        
        Args:
            search_terms: List of terms to search for
            limit: Maximum number of results to return
            
        Returns:
            List[Dict]: List of matching commodities with complete hierarchy
        """
        try:
            session = self._get_session()
            
            # Build search condition
            search_conditions = []
            for term in search_terms:
                search_conditions.append(f"LOWER(COMMODITY_TITLE) LIKE '%{term.lower()}%'")
            
            search_clause = " OR ".join(search_conditions)
            
            query = f"""
            SELECT 
                COMMODITY::STRING as commodity_code,
                COMMODITY_TITLE as commodity_description
            FROM {self.database}.{self.schema}.{self.table}
            WHERE ({search_clause})
            AND COMMODITY IS NOT NULL
            AND COMMODITY_TITLE IS NOT NULL
            ORDER BY COMMODITY
            LIMIT {limit}
            """
            
            result = session.sql(query).collect()
            
            commodities = []
            for row in result:
                hierarchy = self._parse_hierarchy_from_commodity_code(str(row[0]).zfill(8), str(row[1]) if row[1] else "Unknown commodity")
                commodities.append(hierarchy)
            
            print(f"✅ Found {len(commodities)} matching commodities")
            return commodities
            
        except Exception as e:
            print(f"❌ Error searching commodities: {e}")
            return []
    
    def validate_hierarchy(self, segment: Optional[str] = None, family: Optional[str] = None, 
                          class_code: Optional[str] = None, commodity: Optional[str] = None) -> Dict:
        """
        Validate UNSPSC hierarchical consistency.
        
        Args:
            segment: 2-digit segment code
            family: 4-digit family code  
            class_code: 6-digit class code
            commodity: 8-digit commodity code
            
        Returns:
            Dict: Validation result with errors/warnings
        """
        validation = {
            "valid": True,
            "errors": [],
            "warnings": []
        }
        
        # Validate segment format
        if segment:
            if not segment.isdigit() or len(segment.zfill(2)) != 2:
                validation["errors"].append(f"Invalid segment format: {segment}")
                validation["valid"] = False
            
            segment_prefix = segment.zfill(2)
            
            # Validate family
            if family:
                if not family.isdigit() or len(family.zfill(4)) != 4:
                    validation["errors"].append(f"Invalid family format: {family}")
                    validation["valid"] = False
                elif not family.zfill(4).startswith(segment_prefix):
                    validation["errors"].append(f"Family {family} doesn't belong to segment {segment}")
                    validation["valid"] = False
                
                family_prefix = family.zfill(4)
                
                # Validate class
                if class_code:
                    if not class_code.isdigit() or len(class_code.zfill(6)) != 6:
                        validation["errors"].append(f"Invalid class format: {class_code}")
                        validation["valid"] = False
                    elif not class_code.zfill(6).startswith(family_prefix):
                        validation["errors"].append(f"Class {class_code} doesn't belong to family {family}")
                        validation["valid"] = False
                    
                    class_prefix = class_code.zfill(6)
                    
                    # Validate commodity
                    if commodity:
                        if not commodity.isdigit() or len(commodity.zfill(8)) != 8:
                            validation["errors"].append(f"Invalid commodity format: {commodity}")
                            validation["valid"] = False
                        elif not commodity.zfill(8).startswith(class_prefix):
                            validation["errors"].append(f"Commodity {commodity} doesn't belong to class {class_code}")
                            validation["valid"] = False
        
        return validation
    
    def _get_fallback_segments(self) -> List[Dict[str, str]]:
        """Provide fallback segments when database is not available"""
        return [
            {"code": "10", "description": "Live Plant and Animal Material and Accessories and Supplies"},
            {"code": "11", "description": "Mineral and Textile and Inedible Plant and Animal Materials"},
            {"code": "12", "description": "Chemicals including Bio Chemicals and Gas Materials"},
            {"code": "13", "description": "Resin and Rosin and Rubber and Foam and Film and Elastomeric Materials"},
            {"code": "14", "description": "Paper Materials and Products"},
            {"code": "15", "description": "Fuels and Fuel Additives and Lubricants and Anti corrosive Materials"},
            {"code": "20", "description": "Mining and Well Drilling Machinery and Accessories"},
            {"code": "21", "description": "Farming and Forestry Machinery and Accessories"},
            {"code": "22", "description": "Building and Construction Machinery and Accessories"},
            {"code": "23", "description": "Manufacturing Components and Supplies"},
            {"code": "24", "description": "Industrial Manufacturing and Processing Machinery and Accessories"},
            {"code": "25", "description": "Commercial and Military and Private Vehicles and their Accessories and Components"},
            {"code": "26", "description": "Power Generation and Distribution Machinery and Accessories"},
            {"code": "27", "description": "Tools and General Machinery"},
            {"code": "30", "description": "Structures and Building and Construction and Manufacturing Components and Supplies"},
            {"code": "31", "description": "Manufacturing Components and Supplies"},
            {"code": "32", "description": "Electronic Equipment and Components and Supplies"},
            {"code": "39", "description": "Electrical Systems and Lighting and Components and Accessories and Supplies"},
            {"code": "40", "description": "Distribution and Conditioning Systems and Equipment and Components"},
            {"code": "41", "description": "Laboratory and Measuring and Observing and Testing Equipment"},
            {"code": "42", "description": "Medical Equipment and Accessories and Supplies"},
            {"code": "43", "description": "Information Technology Broadcasting and Telecommunications"},
            {"code": "44", "description": "Office Equipment and Accessories and Supplies"},
            {"code": "45", "description": "Printing and Photographic and Audio and Visual Equipment and Supplies"},
            {"code": "46", "description": "Musical Instruments and Games and Toys and Arts and Crafts and Educational Equipment and Materials and Accessories and Supplies"},
            {"code": "47", "description": "Cleaning Equipment and Supplies"},
            {"code": "48", "description": "Service Industry Machinery and Equipment and Supplies"},
            {"code": "49", "description": "Transportation and Storage and Mail Services"},
            {"code": "50", "description": "Food Beverage and Tobacco Products"},
            {"code": "51", "description": "Drugs and Pharmaceutical Products"},
            {"code": "52", "description": "Domestic Appliances and Supplies and Consumer Electronic Products"},
            {"code": "53", "description": "Apparel and Luggage and Personal Care Products"},
            {"code": "54", "description": "Personal Safety and Security and Survival and Emergency Products"},
            {"code": "55", "description": "Published Products"},
            {"code": "56", "description": "Furniture and Furnishings"},
            {"code": "60", "description": "Musical Instruments and Games and Toys and Arts and Crafts and Educational Equipment and Materials and Accessories and Supplies"},
            {"code": "70", "description": "Farming and Fishing and Forestry and Wildlife Contracting Services"},
            {"code": "71", "description": "Mining and oil and gas services"},
            {"code": "72", "description": "Building and Construction and Maintenance Services"},
            {"code": "73", "description": "Industrial Production and Manufacturing Services"},
            {"code": "76", "description": "Industrial Cleaning Services"},
            {"code": "77", "description": "Environmental Services"},
            {"code": "78", "description": "Transportation and Storage and Mail Services"},
            {"code": "80", "description": "Management and Business Professionals and Administrative Services"},
            {"code": "81", "description": "Engineering and Research and Technology Based Services"},
            {"code": "82", "description": "Editorial and Design and Graphic and Fine Art Services"},
            {"code": "83", "description": "Public Utilities and Public Sector Related Services"},
            {"code": "84", "description": "Financial and Insurance Services"},
            {"code": "85", "description": "Healthcare Services"},
            {"code": "86", "description": "Education and Training Services"},
            {"code": "90", "description": "Travel and Food and Lodging and Entertainment Services"},
            {"code": "91", "description": "Personal and Domestic Services"},
            {"code": "92", "description": "National Defense and Public Order and Security and Safety Services"},
            {"code": "93", "description": "Politics and Civic Affairs Services"},
            {"code": "94", "description": "Organizations and Clubs"}
        ] 