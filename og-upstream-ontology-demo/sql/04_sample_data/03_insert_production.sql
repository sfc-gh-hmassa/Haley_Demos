/*
=============================================================================
O&G Upstream Ontology Demo - Production Data
=============================================================================
Sample monthly production data for Q4 2024 (October, November, December).
This data supports analytical queries like:
  - Top 10 oil/gas producers
  - On-stream efficiency by field
  - Production decline analysis
=============================================================================
*/

-- Insert Production Period nodes for December 2024
INSERT INTO OG_ONTOLOGY_DEMO.PHYSICAL_LAYER.KG_NODE 
    (NODE_ID, NODE_TYPE, NODE_KEY, NODE_NAME, NODE_DESCRIPTION, NODE_PROPERTIES)
SELECT 'prod-001-202412', 'PRODUCTION_PERIOD', 'PROD-well-001-202412', 'Apache State 1H - Dec 2024', 'Monthly production for December 2024',
     PARSE_JSON('{"period_date": "2024-12-01", "oil_volume": 18500, "gas_volume": 42000, "water_volume": 8200, "days_on_production": 30, "downtime_hours": 12, "uptime_percentage": 98.3, "choke_size": 32, "tubing_pressure": 850, "casing_pressure": 420}')
UNION ALL SELECT 'prod-002-202412', 'PRODUCTION_PERIOD', 'PROD-well-002-202412', 'Pioneer Ranch 2H - Dec 2024', 'Monthly production for December 2024',
     PARSE_JSON('{"period_date": "2024-12-01", "oil_volume": 22100, "gas_volume": 51000, "water_volume": 9800, "days_on_production": 31, "downtime_hours": 0, "uptime_percentage": 100, "choke_size": 36, "tubing_pressure": 920, "casing_pressure": 480}')
UNION ALL SELECT 'prod-003-202412', 'PRODUCTION_PERIOD', 'PROD-well-003-202412', 'Diamondback Unit 3H - Dec 2024', 'Monthly production for December 2024',
     PARSE_JSON('{"period_date": "2024-12-01", "oil_volume": 25800, "gas_volume": 58000, "water_volume": 11500, "days_on_production": 31, "downtime_hours": 8, "uptime_percentage": 99.0, "choke_size": 40, "tubing_pressure": 1050, "casing_pressure": 520}')
UNION ALL SELECT 'prod-004-202412', 'PRODUCTION_PERIOD', 'PROD-well-004-202412', 'Concho State 4H - Dec 2024', 'Monthly production - SHUT IN',
     PARSE_JSON('{"period_date": "2024-12-01", "oil_volume": 0, "gas_volume": 0, "water_volume": 0, "days_on_production": 0, "downtime_hours": 744, "uptime_percentage": 0, "choke_size": 0, "tubing_pressure": 0, "casing_pressure": 0}')
UNION ALL SELECT 'prod-005-202412', 'PRODUCTION_PERIOD', 'PROD-well-005-202412', 'Chevron Midland 5H - Dec 2024', 'Monthly production for December 2024',
     PARSE_JSON('{"period_date": "2024-12-01", "oil_volume": 19200, "gas_volume": 44500, "water_volume": 7600, "days_on_production": 29, "downtime_hours": 48, "uptime_percentage": 93.5, "choke_size": 34, "tubing_pressure": 880, "casing_pressure": 445}')
UNION ALL SELECT 'prod-006-202412', 'PRODUCTION_PERIOD', 'PROD-well-006-202412', 'EOG Resources 6H - Dec 2024', 'Monthly production for December 2024',
     PARSE_JSON('{"period_date": "2024-12-01", "oil_volume": 8500, "gas_volume": 125000, "water_volume": 3200, "days_on_production": 31, "downtime_hours": 4, "uptime_percentage": 99.5, "choke_size": 28, "tubing_pressure": 1200, "casing_pressure": 580}')
UNION ALL SELECT 'prod-007-202412', 'PRODUCTION_PERIOD', 'PROD-well-007-202412', 'Marathon Eagle 1H - Dec 2024', 'Monthly production for December 2024',
     PARSE_JSON('{"period_date": "2024-12-01", "oil_volume": 16800, "gas_volume": 38000, "water_volume": 6500, "days_on_production": 30, "downtime_hours": 24, "uptime_percentage": 96.8, "choke_size": 30, "tubing_pressure": 780, "casing_pressure": 390}')
UNION ALL SELECT 'prod-008-202412', 'PRODUCTION_PERIOD', 'PROD-well-008-202412', 'Murphy South Texas 2H - Dec 2024', 'Monthly production for December 2024',
     PARSE_JSON('{"period_date": "2024-12-01", "oil_volume": 21500, "gas_volume": 48000, "water_volume": 8900, "days_on_production": 31, "downtime_hours": 6, "uptime_percentage": 99.2, "choke_size": 38, "tubing_pressure": 950, "casing_pressure": 470}')
UNION ALL SELECT 'prod-009-202412', 'PRODUCTION_PERIOD', 'PROD-well-009-202412', 'Devon Eagle 3H - Dec 2024', 'Monthly production for December 2024',
     PARSE_JSON('{"period_date": "2024-12-01", "oil_volume": 5200, "gas_volume": 98000, "water_volume": 2100, "days_on_production": 31, "downtime_hours": 2, "uptime_percentage": 99.7, "choke_size": 26, "tubing_pressure": 1150, "casing_pressure": 560}')
UNION ALL SELECT 'prod-010-202412', 'PRODUCTION_PERIOD', 'PROD-well-010-202412', 'Continental Bakken 1H - Dec 2024', 'Monthly production for December 2024',
     PARSE_JSON('{"period_date": "2024-12-01", "oil_volume": 14200, "gas_volume": 32000, "water_volume": 5800, "days_on_production": 28, "downtime_hours": 72, "uptime_percentage": 90.3, "choke_size": 28, "tubing_pressure": 720, "casing_pressure": 360}')
UNION ALL SELECT 'prod-011-202412', 'PRODUCTION_PERIOD', 'PROD-well-011-202412', 'Hess Bakken 2H - Dec 2024', 'Monthly production for December 2024',
     PARSE_JSON('{"period_date": "2024-12-01", "oil_volume": 17600, "gas_volume": 39000, "water_volume": 7200, "days_on_production": 31, "downtime_hours": 10, "uptime_percentage": 98.7, "choke_size": 32, "tubing_pressure": 810, "casing_pressure": 405}')
UNION ALL SELECT 'prod-012-202412', 'PRODUCTION_PERIOD', 'PROD-well-012-202412', 'Whiting Bakken 3H - Dec 2024', 'Monthly production - SHUT IN',
     PARSE_JSON('{"period_date": "2024-12-01", "oil_volume": 0, "gas_volume": 0, "water_volume": 0, "days_on_production": 0, "downtime_hours": 744, "uptime_percentage": 0, "choke_size": 0, "tubing_pressure": 0, "casing_pressure": 0}')
UNION ALL SELECT 'prod-013-202412', 'PRODUCTION_PERIOD', 'PROD-well-013-202412', 'PDC Wattenberg 1H - Dec 2024', 'Monthly production for December 2024',
     PARSE_JSON('{"period_date": "2024-12-01", "oil_volume": 6800, "gas_volume": 145000, "water_volume": 2800, "days_on_production": 31, "downtime_hours": 0, "uptime_percentage": 100, "choke_size": 24, "tubing_pressure": 1320, "casing_pressure": 640}')
UNION ALL SELECT 'prod-014-202412', 'PRODUCTION_PERIOD', 'PROD-well-014-202412', 'Noble DJ Basin 2H - Dec 2024', 'Monthly production for December 2024',
     PARSE_JSON('{"period_date": "2024-12-01", "oil_volume": 12400, "gas_volume": 68000, "water_volume": 4500, "days_on_production": 30, "downtime_hours": 18, "uptime_percentage": 97.6, "choke_size": 30, "tubing_pressure": 980, "casing_pressure": 490}');

-- Insert October and November 2024 production for Q4 analysis
INSERT INTO OG_ONTOLOGY_DEMO.PHYSICAL_LAYER.KG_NODE 
    (NODE_ID, NODE_TYPE, NODE_KEY, NODE_NAME, NODE_DESCRIPTION, NODE_PROPERTIES)
-- October 2024 production
SELECT 'prod-001-202410', 'PRODUCTION_PERIOD', 'PROD-well-001-202410', 'Apache State 1H - Oct 2024', 'Monthly production for October 2024',
     PARSE_JSON('{"period_date": "2024-10-01", "oil_volume": 19200, "gas_volume": 43500, "water_volume": 7800, "days_on_production": 31, "downtime_hours": 8, "uptime_percentage": 98.9}')
UNION ALL SELECT 'prod-002-202410', 'PRODUCTION_PERIOD', 'PROD-well-002-202410', 'Pioneer Ranch 2H - Oct 2024', 'Monthly production for October 2024',
     PARSE_JSON('{"period_date": "2024-10-01", "oil_volume": 23500, "gas_volume": 53000, "water_volume": 9200, "days_on_production": 31, "downtime_hours": 4, "uptime_percentage": 99.5}')
UNION ALL SELECT 'prod-003-202410', 'PRODUCTION_PERIOD', 'PROD-well-003-202410', 'Diamondback Unit 3H - Oct 2024', 'Monthly production for October 2024',
     PARSE_JSON('{"period_date": "2024-10-01", "oil_volume": 27200, "gas_volume": 61000, "water_volume": 10800, "days_on_production": 31, "downtime_hours": 0, "uptime_percentage": 100}')
UNION ALL SELECT 'prod-007-202410', 'PRODUCTION_PERIOD', 'PROD-well-007-202410', 'Marathon Eagle 1H - Oct 2024', 'Monthly production for October 2024',
     PARSE_JSON('{"period_date": "2024-10-01", "oil_volume": 17500, "gas_volume": 40000, "water_volume": 6200, "days_on_production": 31, "downtime_hours": 16, "uptime_percentage": 97.8}')
UNION ALL SELECT 'prod-010-202410', 'PRODUCTION_PERIOD', 'PROD-well-010-202410', 'Continental Bakken 1H - Oct 2024', 'Monthly production for October 2024',
     PARSE_JSON('{"period_date": "2024-10-01", "oil_volume": 15800, "gas_volume": 35000, "water_volume": 5400, "days_on_production": 31, "downtime_hours": 24, "uptime_percentage": 96.8}')
UNION ALL SELECT 'prod-013-202410', 'PRODUCTION_PERIOD', 'PROD-well-013-202410', 'PDC Wattenberg 1H - Oct 2024', 'Monthly production for October 2024',
     PARSE_JSON('{"period_date": "2024-10-01", "oil_volume": 7200, "gas_volume": 152000, "water_volume": 2600, "days_on_production": 31, "downtime_hours": 6, "uptime_percentage": 99.2}')
-- November 2024 production
UNION ALL SELECT 'prod-001-202411', 'PRODUCTION_PERIOD', 'PROD-well-001-202411', 'Apache State 1H - Nov 2024', 'Monthly production for November 2024',
     PARSE_JSON('{"period_date": "2024-11-01", "oil_volume": 18800, "gas_volume": 42800, "water_volume": 8000, "days_on_production": 30, "downtime_hours": 16, "uptime_percentage": 97.8}')
UNION ALL SELECT 'prod-002-202411', 'PRODUCTION_PERIOD', 'PROD-well-002-202411', 'Pioneer Ranch 2H - Nov 2024', 'Monthly production for November 2024',
     PARSE_JSON('{"period_date": "2024-11-01", "oil_volume": 22800, "gas_volume": 52000, "water_volume": 9500, "days_on_production": 30, "downtime_hours": 0, "uptime_percentage": 100}')
UNION ALL SELECT 'prod-003-202411', 'PRODUCTION_PERIOD', 'PROD-well-003-202411', 'Diamondback Unit 3H - Nov 2024', 'Monthly production for November 2024',
     PARSE_JSON('{"period_date": "2024-11-01", "oil_volume": 26500, "gas_volume": 59500, "water_volume": 11200, "days_on_production": 30, "downtime_hours": 12, "uptime_percentage": 98.3}')
UNION ALL SELECT 'prod-007-202411', 'PRODUCTION_PERIOD', 'PROD-well-007-202411', 'Marathon Eagle 1H - Nov 2024', 'Monthly production for November 2024',
     PARSE_JSON('{"period_date": "2024-11-01", "oil_volume": 17100, "gas_volume": 39000, "water_volume": 6400, "days_on_production": 29, "downtime_hours": 36, "uptime_percentage": 95.0}')
UNION ALL SELECT 'prod-010-202411', 'PRODUCTION_PERIOD', 'PROD-well-010-202411', 'Continental Bakken 1H - Nov 2024', 'Monthly production for November 2024',
     PARSE_JSON('{"period_date": "2024-11-01", "oil_volume": 15000, "gas_volume": 33500, "water_volume": 5600, "days_on_production": 30, "downtime_hours": 48, "uptime_percentage": 93.3}')
UNION ALL SELECT 'prod-013-202411', 'PRODUCTION_PERIOD', 'PROD-well-013-202411', 'PDC Wattenberg 1H - Nov 2024', 'Monthly production for November 2024',
     PARSE_JSON('{"period_date": "2024-11-01", "oil_volume": 7000, "gas_volume": 148000, "water_volume": 2700, "days_on_production": 30, "downtime_hours": 8, "uptime_percentage": 98.9}');

-- Link wells to their December production periods
INSERT INTO OG_ONTOLOGY_DEMO.PHYSICAL_LAYER.KG_EDGE 
    (EDGE_TYPE, SOURCE_NODE_ID, TARGET_NODE_ID, EDGE_PROPERTIES, EFFECTIVE_FROM)
SELECT 'HAS_PRODUCTION', 'well-001', 'prod-001-202412', PARSE_JSON('{}'), '2024-12-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-002', 'prod-002-202412', PARSE_JSON('{}'), '2024-12-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-003', 'prod-003-202412', PARSE_JSON('{}'), '2024-12-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-004', 'prod-004-202412', PARSE_JSON('{}'), '2024-12-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-005', 'prod-005-202412', PARSE_JSON('{}'), '2024-12-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-006', 'prod-006-202412', PARSE_JSON('{}'), '2024-12-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-007', 'prod-007-202412', PARSE_JSON('{}'), '2024-12-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-008', 'prod-008-202412', PARSE_JSON('{}'), '2024-12-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-009', 'prod-009-202412', PARSE_JSON('{}'), '2024-12-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-010', 'prod-010-202412', PARSE_JSON('{}'), '2024-12-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-011', 'prod-011-202412', PARSE_JSON('{}'), '2024-12-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-012', 'prod-012-202412', PARSE_JSON('{}'), '2024-12-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-013', 'prod-013-202412', PARSE_JSON('{}'), '2024-12-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-014', 'prod-014-202412', PARSE_JSON('{}'), '2024-12-01'::DATE;

-- Link Q4 production to wells (Oct & Nov)
INSERT INTO OG_ONTOLOGY_DEMO.PHYSICAL_LAYER.KG_EDGE 
    (EDGE_TYPE, SOURCE_NODE_ID, TARGET_NODE_ID, EDGE_PROPERTIES, EFFECTIVE_FROM)
SELECT 'HAS_PRODUCTION', 'well-001', 'prod-001-202410', PARSE_JSON('{}'), '2024-10-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-002', 'prod-002-202410', PARSE_JSON('{}'), '2024-10-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-003', 'prod-003-202410', PARSE_JSON('{}'), '2024-10-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-007', 'prod-007-202410', PARSE_JSON('{}'), '2024-10-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-010', 'prod-010-202410', PARSE_JSON('{}'), '2024-10-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-013', 'prod-013-202410', PARSE_JSON('{}'), '2024-10-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-001', 'prod-001-202411', PARSE_JSON('{}'), '2024-11-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-002', 'prod-002-202411', PARSE_JSON('{}'), '2024-11-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-003', 'prod-003-202411', PARSE_JSON('{}'), '2024-11-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-007', 'prod-007-202411', PARSE_JSON('{}'), '2024-11-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-010', 'prod-010-202411', PARSE_JSON('{}'), '2024-11-01'::DATE
UNION ALL SELECT 'HAS_PRODUCTION', 'well-013', 'prod-013-202411', PARSE_JSON('{}'), '2024-11-01'::DATE;
