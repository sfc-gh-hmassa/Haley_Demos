/*
=============================================================================
O&G Upstream Ontology Demo - Sample Entity Data
=============================================================================
Populates the Knowledge Graph with sample O&G entities:
  - 4 Fields (Permian, Eagle Ford, Bakken, DJ Basin)
  - 14 Wells across all fields
  - 5 Facilities
  - 7 Equipment units
=============================================================================
*/

-- Insert Sample Fields
INSERT INTO OG_ONTOLOGY_DEMO.PHYSICAL_LAYER.KG_NODE 
    (NODE_ID, NODE_TYPE, NODE_KEY, NODE_NAME, NODE_DESCRIPTION, NODE_PROPERTIES)
SELECT 'field-001', 'FIELD', 'PERMIAN-001', 'Midland Basin Field', 'Major oil and gas field in the Permian Basin, Texas',
     PARSE_JSON('{"field_code": "PERMIAN-001", "basin": "Permian", "region": "West Texas", "country": "USA", "discovery_date": "1940-01-15", "total_area": 125000, "estimated_reserves_oil": 850, "estimated_reserves_gas": 2400}')
UNION ALL SELECT 'field-002', 'FIELD', 'EAGLEFORD-001', 'Eagle Ford South', 'Active shale play in South Texas',
     PARSE_JSON('{"field_code": "EAGLEFORD-001", "basin": "Eagle Ford", "region": "South Texas", "country": "USA", "discovery_date": "2008-06-20", "total_area": 85000, "estimated_reserves_oil": 620, "estimated_reserves_gas": 1800}')
UNION ALL SELECT 'field-003', 'FIELD', 'BAKKEN-001', 'Bakken Central', 'Bakken formation in North Dakota',
     PARSE_JSON('{"field_code": "BAKKEN-001", "basin": "Williston", "region": "North Dakota", "country": "USA", "discovery_date": "1951-04-10", "total_area": 200000, "estimated_reserves_oil": 750, "estimated_reserves_gas": 900}')
UNION ALL SELECT 'field-004', 'FIELD', 'DJ-BASIN-001', 'Wattenberg Field', 'DJ Basin field in Colorado',
     PARSE_JSON('{"field_code": "DJ-BASIN-001", "basin": "DJ Basin", "region": "Colorado", "country": "USA", "discovery_date": "1970-08-22", "total_area": 65000, "estimated_reserves_oil": 320, "estimated_reserves_gas": 2100}');

-- Insert Sample Wells (Permian Basin)
INSERT INTO OG_ONTOLOGY_DEMO.PHYSICAL_LAYER.KG_NODE 
    (NODE_ID, NODE_TYPE, NODE_KEY, NODE_NAME, NODE_DESCRIPTION, NODE_PROPERTIES)
SELECT 'well-001', 'WELL', '42-329-12345', 'Apache State 1H', 'Horizontal oil well in Midland Basin',
     PARSE_JSON('{"api_number": "42-329-12345", "well_status": "ACTIVE", "well_type": "OIL", "spud_date": "2022-03-15", "completion_date": "2022-06-20", "latitude": 31.9523, "longitude": -102.0778, "total_depth": 22500, "operator": "Apache Corp"}')
UNION ALL SELECT 'well-002', 'WELL', '42-329-12346', 'Pioneer Ranch 2H', 'Horizontal oil producer',
     PARSE_JSON('{"api_number": "42-329-12346", "well_status": "ACTIVE", "well_type": "OIL", "spud_date": "2022-05-10", "completion_date": "2022-08-15", "latitude": 31.9234, "longitude": -102.1023, "total_depth": 21800, "operator": "Pioneer Natural Resources"}')
UNION ALL SELECT 'well-003', 'WELL', '42-329-12347', 'Diamondback Unit 3H', 'High-rate horizontal well',
     PARSE_JSON('{"api_number": "42-329-12347", "well_status": "ACTIVE", "well_type": "OIL", "spud_date": "2022-07-01", "completion_date": "2022-10-05", "latitude": 31.8876, "longitude": -102.0456, "total_depth": 23100, "operator": "Diamondback Energy"}')
UNION ALL SELECT 'well-004', 'WELL', '42-329-12348', 'Concho State 4H', 'Wolfcamp formation well',
     PARSE_JSON('{"api_number": "42-329-12348", "well_status": "SHUT_IN", "well_type": "OIL", "spud_date": "2021-11-20", "completion_date": "2022-02-28", "latitude": 31.9012, "longitude": -102.0891, "total_depth": 20500, "operator": "ConocoPhillips"}')
UNION ALL SELECT 'well-005', 'WELL', '42-329-12349', 'Chevron Midland 5H', 'Multi-bench Spraberry well',
     PARSE_JSON('{"api_number": "42-329-12349", "well_status": "ACTIVE", "well_type": "OIL", "spud_date": "2023-01-10", "completion_date": "2023-04-15", "latitude": 31.9345, "longitude": -102.0234, "total_depth": 24000, "operator": "Chevron"}')
UNION ALL SELECT 'well-006', 'WELL', '42-329-12350', 'EOG Resources 6H', 'Leonard shale producer',
     PARSE_JSON('{"api_number": "42-329-12350", "well_status": "ACTIVE", "well_type": "GAS", "spud_date": "2023-02-20", "completion_date": "2023-05-25", "latitude": 31.8654, "longitude": -102.1234, "total_depth": 19800, "operator": "EOG Resources"}');

-- Insert Wells for Eagle Ford, Bakken, DJ Basin
INSERT INTO OG_ONTOLOGY_DEMO.PHYSICAL_LAYER.KG_NODE 
    (NODE_ID, NODE_TYPE, NODE_KEY, NODE_NAME, NODE_DESCRIPTION, NODE_PROPERTIES)
SELECT 'well-007', 'WELL', '42-255-67890', 'Marathon Eagle 1H', 'Eagle Ford horizontal well',
     PARSE_JSON('{"api_number": "42-255-67890", "well_status": "ACTIVE", "well_type": "OIL", "spud_date": "2022-09-01", "completion_date": "2022-12-10", "latitude": 28.8234, "longitude": -98.5678, "total_depth": 18500, "operator": "Marathon Oil"}')
UNION ALL SELECT 'well-008', 'WELL', '42-255-67891', 'Murphy South Texas 2H', 'High IP Eagle Ford well',
     PARSE_JSON('{"api_number": "42-255-67891", "well_status": "ACTIVE", "well_type": "OIL", "spud_date": "2023-03-15", "completion_date": "2023-06-20", "latitude": 28.7891, "longitude": -98.6012, "total_depth": 17800, "operator": "Murphy Oil"}')
UNION ALL SELECT 'well-009', 'WELL', '42-255-67892', 'Devon Eagle 3H', 'Multi-zone completion',
     PARSE_JSON('{"api_number": "42-255-67892", "well_status": "ACTIVE", "well_type": "GAS", "spud_date": "2023-05-01", "completion_date": "2023-08-10", "latitude": 28.8012, "longitude": -98.5234, "total_depth": 19200, "operator": "Devon Energy"}')
UNION ALL SELECT 'well-010', 'WELL', '33-105-12345', 'Continental Bakken 1H', 'Bakken/Three Forks producer',
     PARSE_JSON('{"api_number": "33-105-12345", "well_status": "ACTIVE", "well_type": "OIL", "spud_date": "2022-04-10", "completion_date": "2022-07-15", "latitude": 48.1234, "longitude": -103.4567, "total_depth": 21000, "operator": "Continental Resources"}')
UNION ALL SELECT 'well-011', 'WELL', '33-105-12346', 'Hess Bakken 2H', 'Three Forks formation well',
     PARSE_JSON('{"api_number": "33-105-12346", "well_status": "ACTIVE", "well_type": "OIL", "spud_date": "2022-08-20", "completion_date": "2022-11-25", "latitude": 48.0987, "longitude": -103.5012, "total_depth": 20500, "operator": "Hess Corporation"}')
UNION ALL SELECT 'well-012', 'WELL', '33-105-12347', 'Whiting Bakken 3H', 'Middle Bakken producer',
     PARSE_JSON('{"api_number": "33-105-12347", "well_status": "SHUT_IN", "well_type": "OIL", "spud_date": "2021-06-15", "completion_date": "2021-09-20", "latitude": 48.0654, "longitude": -103.4123, "total_depth": 19800, "operator": "Whiting Petroleum"}')
UNION ALL SELECT 'well-013', 'WELL', '05-123-45678', 'PDC Wattenberg 1H', 'Niobrara/Codell producer',
     PARSE_JSON('{"api_number": "05-123-45678", "well_status": "ACTIVE", "well_type": "GAS", "spud_date": "2023-01-05", "completion_date": "2023-04-10", "latitude": 40.1234, "longitude": -104.5678, "total_depth": 14500, "operator": "PDC Energy"}')
UNION ALL SELECT 'well-014', 'WELL', '05-123-45679', 'Noble DJ Basin 2H', 'Extended lateral well',
     PARSE_JSON('{"api_number": "05-123-45679", "well_status": "ACTIVE", "well_type": "OIL", "spud_date": "2023-02-20", "completion_date": "2023-05-25", "latitude": 40.0987, "longitude": -104.6012, "total_depth": 15200, "operator": "Noble Energy"}');

-- Insert Facilities
INSERT INTO OG_ONTOLOGY_DEMO.PHYSICAL_LAYER.KG_NODE 
    (NODE_ID, NODE_TYPE, NODE_KEY, NODE_NAME, NODE_DESCRIPTION, NODE_PROPERTIES)
SELECT 'facility-001', 'FACILITY', 'FAC-PERMIAN-CPF-01', 'Midland Central Processing Facility', 'Main CPF for Permian wells',
     PARSE_JSON('{"facility_type": "CPF", "capacity": 50000, "install_date": "2018-06-15", "status": "OPERATIONAL"}')
UNION ALL SELECT 'facility-002', 'FACILITY', 'FAC-PERMIAN-SEP-01', 'Permian Separator Station 1', 'Three-phase separator',
     PARSE_JSON('{"facility_type": "SEPARATOR", "capacity": 25000, "install_date": "2019-03-20", "status": "OPERATIONAL"}')
UNION ALL SELECT 'facility-003', 'FACILITY', 'FAC-EAGLE-CPF-01', 'Eagle Ford Processing Center', 'Main processing for EF wells',
     PARSE_JSON('{"facility_type": "CPF", "capacity": 35000, "install_date": "2015-09-10", "status": "OPERATIONAL"}')
UNION ALL SELECT 'facility-004', 'FACILITY', 'FAC-BAKKEN-TB-01', 'Bakken Tank Battery 1', 'Oil storage and transfer',
     PARSE_JSON('{"facility_type": "TANK_BATTERY", "capacity": 15000, "install_date": "2017-04-25", "status": "OPERATIONAL"}')
UNION ALL SELECT 'facility-005', 'FACILITY', 'FAC-DJ-COMP-01', 'Wattenberg Compressor Station', 'Gas compression facility',
     PARSE_JSON('{"facility_type": "COMPRESSOR", "capacity": 80000, "install_date": "2020-11-30", "status": "OPERATIONAL"}');

-- Insert Equipment
INSERT INTO OG_ONTOLOGY_DEMO.PHYSICAL_LAYER.KG_NODE 
    (NODE_ID, NODE_TYPE, NODE_KEY, NODE_NAME, NODE_DESCRIPTION, NODE_PROPERTIES)
SELECT 'equip-001', 'EQUIPMENT', 'ESP-001', 'Schlumberger ESP Unit 1', 'Electric submersible pump for well-001',
     PARSE_JSON('{"equipment_type": "ESP", "manufacturer": "Schlumberger", "model": "REDA-550", "serial_number": "SLB-ESP-2022-001", "install_date": "2022-06-20", "status": "RUNNING"}')
UNION ALL SELECT 'equip-002', 'EQUIPMENT', 'ESP-002', 'Baker Hughes ESP Unit 2', 'Electric submersible pump for well-002',
     PARSE_JSON('{"equipment_type": "ESP", "manufacturer": "Baker Hughes", "model": "Centrilift-400", "serial_number": "BH-ESP-2022-045", "install_date": "2022-08-15", "status": "RUNNING"}')
UNION ALL SELECT 'equip-003', 'EQUIPMENT', 'ROD-001', 'Weatherford Rod Pump 1', 'Beam pump for well-004',
     PARSE_JSON('{"equipment_type": "ROD_PUMP", "manufacturer": "Weatherford", "model": "RP-228", "serial_number": "WF-ROD-2022-012", "install_date": "2022-02-28", "status": "MAINTENANCE"}')
UNION ALL SELECT 'equip-004', 'EQUIPMENT', 'COMP-001', 'Ariel Compressor Station 1', 'Gas lift compressor',
     PARSE_JSON('{"equipment_type": "COMPRESSOR", "manufacturer": "Ariel", "model": "JGK-4", "serial_number": "AR-COMP-2020-089", "install_date": "2020-11-30", "status": "RUNNING"}')
UNION ALL SELECT 'equip-005', 'EQUIPMENT', 'SEP-001', 'NOV Separator Unit 1', 'Three-phase test separator',
     PARSE_JSON('{"equipment_type": "SEPARATOR", "manufacturer": "NOV", "model": "TS-3000", "serial_number": "NOV-SEP-2019-023", "install_date": "2019-03-20", "status": "RUNNING"}')
UNION ALL SELECT 'equip-006', 'EQUIPMENT', 'ESP-003', 'Schlumberger ESP Unit 3', 'ESP for well-007',
     PARSE_JSON('{"equipment_type": "ESP", "manufacturer": "Schlumberger", "model": "REDA-675", "serial_number": "SLB-ESP-2022-089", "install_date": "2022-12-10", "status": "RUNNING"}')
UNION ALL SELECT 'equip-007', 'EQUIPMENT', 'ESP-004', 'Baker Hughes ESP Unit 4', 'ESP for well-010 - FAILED',
     PARSE_JSON('{"equipment_type": "ESP", "manufacturer": "Baker Hughes", "model": "Centrilift-550", "serial_number": "BH-ESP-2022-112", "install_date": "2022-07-15", "status": "FAILED", "failure_date": "2024-11-15"}');
