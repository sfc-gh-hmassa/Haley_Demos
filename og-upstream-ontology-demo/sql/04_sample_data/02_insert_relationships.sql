/*
=============================================================================
O&G Upstream Ontology Demo - Sample Relationships (Edges)
=============================================================================
Creates relationships between entities in the Knowledge Graph.
=============================================================================
*/

-- Insert Well-to-Field relationships
INSERT INTO OG_ONTOLOGY_DEMO.PHYSICAL_LAYER.KG_EDGE 
    (EDGE_TYPE, SOURCE_NODE_ID, TARGET_NODE_ID, EDGE_PROPERTIES)
SELECT 'PART_OF_FIELD', 'well-001', 'field-001', PARSE_JSON('{}')
UNION ALL SELECT 'PART_OF_FIELD', 'well-002', 'field-001', PARSE_JSON('{}')
UNION ALL SELECT 'PART_OF_FIELD', 'well-003', 'field-001', PARSE_JSON('{}')
UNION ALL SELECT 'PART_OF_FIELD', 'well-004', 'field-001', PARSE_JSON('{}')
UNION ALL SELECT 'PART_OF_FIELD', 'well-005', 'field-001', PARSE_JSON('{}')
UNION ALL SELECT 'PART_OF_FIELD', 'well-006', 'field-001', PARSE_JSON('{}')
UNION ALL SELECT 'PART_OF_FIELD', 'well-007', 'field-002', PARSE_JSON('{}')
UNION ALL SELECT 'PART_OF_FIELD', 'well-008', 'field-002', PARSE_JSON('{}')
UNION ALL SELECT 'PART_OF_FIELD', 'well-009', 'field-002', PARSE_JSON('{}')
UNION ALL SELECT 'PART_OF_FIELD', 'well-010', 'field-003', PARSE_JSON('{}')
UNION ALL SELECT 'PART_OF_FIELD', 'well-011', 'field-003', PARSE_JSON('{}')
UNION ALL SELECT 'PART_OF_FIELD', 'well-012', 'field-003', PARSE_JSON('{}')
UNION ALL SELECT 'PART_OF_FIELD', 'well-013', 'field-004', PARSE_JSON('{}')
UNION ALL SELECT 'PART_OF_FIELD', 'well-014', 'field-004', PARSE_JSON('{}');

-- Insert Well-to-Facility relationships
INSERT INTO OG_ONTOLOGY_DEMO.PHYSICAL_LAYER.KG_EDGE 
    (EDGE_TYPE, SOURCE_NODE_ID, TARGET_NODE_ID, EDGE_PROPERTIES)
SELECT 'PRODUCES_TO', 'well-001', 'facility-001', PARSE_JSON('{}')
UNION ALL SELECT 'PRODUCES_TO', 'well-002', 'facility-001', PARSE_JSON('{}')
UNION ALL SELECT 'PRODUCES_TO', 'well-003', 'facility-002', PARSE_JSON('{}')
UNION ALL SELECT 'PRODUCES_TO', 'well-004', 'facility-002', PARSE_JSON('{}')
UNION ALL SELECT 'PRODUCES_TO', 'well-005', 'facility-001', PARSE_JSON('{}')
UNION ALL SELECT 'PRODUCES_TO', 'well-006', 'facility-002', PARSE_JSON('{}')
UNION ALL SELECT 'PRODUCES_TO', 'well-007', 'facility-003', PARSE_JSON('{}')
UNION ALL SELECT 'PRODUCES_TO', 'well-008', 'facility-003', PARSE_JSON('{}')
UNION ALL SELECT 'PRODUCES_TO', 'well-009', 'facility-003', PARSE_JSON('{}')
UNION ALL SELECT 'PRODUCES_TO', 'well-010', 'facility-004', PARSE_JSON('{}')
UNION ALL SELECT 'PRODUCES_TO', 'well-011', 'facility-004', PARSE_JSON('{}')
UNION ALL SELECT 'PRODUCES_TO', 'well-012', 'facility-004', PARSE_JSON('{}')
UNION ALL SELECT 'PRODUCES_TO', 'well-013', 'facility-005', PARSE_JSON('{}')
UNION ALL SELECT 'PRODUCES_TO', 'well-014', 'facility-005', PARSE_JSON('{}');

-- Insert Well-to-Equipment relationships
INSERT INTO OG_ONTOLOGY_DEMO.PHYSICAL_LAYER.KG_EDGE 
    (EDGE_TYPE, SOURCE_NODE_ID, TARGET_NODE_ID, EDGE_PROPERTIES)
SELECT 'HAS_EQUIPMENT', 'well-001', 'equip-001', PARSE_JSON('{}')
UNION ALL SELECT 'HAS_EQUIPMENT', 'well-002', 'equip-002', PARSE_JSON('{}')
UNION ALL SELECT 'HAS_EQUIPMENT', 'well-004', 'equip-003', PARSE_JSON('{}')
UNION ALL SELECT 'HAS_EQUIPMENT', 'well-007', 'equip-006', PARSE_JSON('{}')
UNION ALL SELECT 'HAS_EQUIPMENT', 'well-010', 'equip-007', PARSE_JSON('{}');

-- Insert Field-to-Facility relationships
INSERT INTO OG_ONTOLOGY_DEMO.PHYSICAL_LAYER.KG_EDGE 
    (EDGE_TYPE, SOURCE_NODE_ID, TARGET_NODE_ID, EDGE_PROPERTIES)
SELECT 'FIELD_HAS_FACILITY', 'field-001', 'facility-001', PARSE_JSON('{}')
UNION ALL SELECT 'FIELD_HAS_FACILITY', 'field-001', 'facility-002', PARSE_JSON('{}')
UNION ALL SELECT 'FIELD_HAS_FACILITY', 'field-002', 'facility-003', PARSE_JSON('{}')
UNION ALL SELECT 'FIELD_HAS_FACILITY', 'field-003', 'facility-004', PARSE_JSON('{}')
UNION ALL SELECT 'FIELD_HAS_FACILITY', 'field-004', 'facility-005', PARSE_JSON('{}');
