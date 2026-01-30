/*
=============================================================================
O&G Upstream Ontology Demo - Populate Ontology Metadata
=============================================================================
Populates the ontology metadata with O&G Upstream domain definitions.

This defines:
  - The O&G Upstream domain
  - 8 entity types (WELL, WELLBORE, FIELD, FACILITY, EQUIPMENT, etc.)
  - 42 attributes across all entities
  - 8 relationship types
=============================================================================
*/

-- Insert the O&G Upstream Domain
INSERT INTO OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_DOMAIN 
    (DOMAIN_ID, DOMAIN_NAME, DOMAIN_DESCRIPTION, IS_ACTIVE)
VALUES 
    ('d001-og-upstream', 'OIL_GAS_UPSTREAM', 
     'Oil & Gas Upstream domain covering exploration, drilling, and production operations including wells, wellbores, fields, facilities, and equipment', 
     TRUE);

-- Insert Entity Type Definitions for O&G Upstream
INSERT INTO OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_ENTITY 
    (ENTITY_ID, DOMAIN_ID, ENTITY_NAME, ENTITY_DISPLAY_NAME, ENTITY_DESCRIPTION, ENTITY_ICON)
VALUES 
    ('e001-well', 'd001-og-upstream', 'WELL', 'Well', 
     'A drilled hole in the ground for the purpose of exploration or extraction of natural resources such as oil and gas', 'oil-well'),
    ('e002-wellbore', 'd001-og-upstream', 'WELLBORE', 'Wellbore', 
     'The physical hole that makes up a well, including the casing, tubing, and completion equipment', 'wellbore'),
    ('e003-field', 'd001-og-upstream', 'FIELD', 'Field', 
     'A geographical area under which an oil or gas reservoir lies, typically containing multiple wells', 'map-marker'),
    ('e004-facility', 'd001-og-upstream', 'FACILITY', 'Facility', 
     'Surface installations used for processing, storing, or transporting oil and gas', 'factory'),
    ('e005-equipment', 'd001-og-upstream', 'EQUIPMENT', 'Equipment', 
     'Physical equipment used in oil and gas operations including pumps, compressors, separators', 'gear'),
    ('e006-reservoir', 'd001-og-upstream', 'RESERVOIR', 'Reservoir', 
     'A subsurface rock formation containing oil and/or gas in its pore spaces', 'layers'),
    ('e007-completion', 'd001-og-upstream', 'COMPLETION', 'Completion', 
     'The process of making a well ready for production after drilling', 'check-circle'),
    ('e008-production_period', 'd001-og-upstream', 'PRODUCTION_PERIOD', 'Production Period', 
     'A time-based record of production volumes and operational metrics', 'calendar');

-- Insert Attribute Definitions for WELL
INSERT INTO OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_ATTRIBUTE 
    (ENTITY_ID, ATTRIBUTE_NAME, ATTRIBUTE_DISPLAY_NAME, ATTRIBUTE_DESCRIPTION, DATA_TYPE, UNIT_OF_MEASURE, IS_REQUIRED)
VALUES 
    ('e001-well', 'API_NUMBER', 'API Number', 'American Petroleum Institute unique well identifier', 'VARCHAR', NULL, TRUE),
    ('e001-well', 'WELL_NAME', 'Well Name', 'Common name of the well', 'VARCHAR', NULL, TRUE),
    ('e001-well', 'WELL_STATUS', 'Well Status', 'Current operational status (ACTIVE, SHUT_IN, P&A, DRILLING)', 'VARCHAR', NULL, TRUE),
    ('e001-well', 'WELL_TYPE', 'Well Type', 'Type of well (OIL, GAS, INJECTION, WATER)', 'VARCHAR', NULL, FALSE),
    ('e001-well', 'SPUD_DATE', 'Spud Date', 'Date when drilling began', 'DATE', NULL, FALSE),
    ('e001-well', 'COMPLETION_DATE', 'Completion Date', 'Date when well was completed', 'DATE', NULL, FALSE),
    ('e001-well', 'LATITUDE', 'Latitude', 'Surface location latitude', 'NUMBER', 'degrees', FALSE),
    ('e001-well', 'LONGITUDE', 'Longitude', 'Surface location longitude', 'NUMBER', 'degrees', FALSE),
    ('e001-well', 'TOTAL_DEPTH', 'Total Depth', 'Total measured depth of the well', 'NUMBER', 'FT', FALSE),
    ('e001-well', 'OPERATOR', 'Operator', 'Company operating the well', 'VARCHAR', NULL, FALSE);

-- Insert Attribute Definitions for PRODUCTION_PERIOD
INSERT INTO OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_ATTRIBUTE 
    (ENTITY_ID, ATTRIBUTE_NAME, ATTRIBUTE_DISPLAY_NAME, ATTRIBUTE_DESCRIPTION, DATA_TYPE, UNIT_OF_MEASURE, IS_REQUIRED)
VALUES 
    ('e008-production_period', 'PERIOD_DATE', 'Period Date', 'Date of the production period (typically monthly)', 'DATE', NULL, TRUE),
    ('e008-production_period', 'OIL_VOLUME', 'Oil Volume', 'Oil produced during the period', 'NUMBER', 'BBL', FALSE),
    ('e008-production_period', 'GAS_VOLUME', 'Gas Volume', 'Gas produced during the period', 'NUMBER', 'MCF', FALSE),
    ('e008-production_period', 'WATER_VOLUME', 'Water Volume', 'Water produced during the period', 'NUMBER', 'BBL', FALSE),
    ('e008-production_period', 'DAYS_ON_PRODUCTION', 'Days on Production', 'Number of days the well produced', 'NUMBER', 'DAYS', FALSE),
    ('e008-production_period', 'DOWNTIME_HOURS', 'Downtime Hours', 'Hours of unplanned downtime', 'NUMBER', 'HOURS', FALSE),
    ('e008-production_period', 'UPTIME_PERCENTAGE', 'Uptime Percentage', 'Percentage of time well was operational', 'NUMBER', '%', FALSE),
    ('e008-production_period', 'CHOKE_SIZE', 'Choke Size', 'Choke setting during production', 'NUMBER', 'INCHES', FALSE),
    ('e008-production_period', 'TUBING_PRESSURE', 'Tubing Pressure', 'Average tubing head pressure', 'NUMBER', 'PSI', FALSE),
    ('e008-production_period', 'CASING_PRESSURE', 'Casing Pressure', 'Average casing head pressure', 'NUMBER', 'PSI', FALSE);

-- Insert Attribute Definitions for FIELD
INSERT INTO OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_ATTRIBUTE 
    (ENTITY_ID, ATTRIBUTE_NAME, ATTRIBUTE_DISPLAY_NAME, ATTRIBUTE_DESCRIPTION, DATA_TYPE, UNIT_OF_MEASURE, IS_REQUIRED)
VALUES 
    ('e003-field', 'FIELD_NAME', 'Field Name', 'Name of the oil and gas field', 'VARCHAR', NULL, TRUE),
    ('e003-field', 'FIELD_CODE', 'Field Code', 'Unique code identifier for the field', 'VARCHAR', NULL, TRUE),
    ('e003-field', 'BASIN', 'Basin', 'Geological basin where field is located', 'VARCHAR', NULL, FALSE),
    ('e003-field', 'REGION', 'Region', 'Operational region', 'VARCHAR', NULL, FALSE),
    ('e003-field', 'COUNTRY', 'Country', 'Country where field is located', 'VARCHAR', NULL, FALSE),
    ('e003-field', 'DISCOVERY_DATE', 'Discovery Date', 'Date the field was discovered', 'DATE', NULL, FALSE),
    ('e003-field', 'TOTAL_AREA', 'Total Area', 'Total area of the field', 'NUMBER', 'ACRES', FALSE),
    ('e003-field', 'ESTIMATED_RESERVES_OIL', 'Estimated Oil Reserves', 'Estimated recoverable oil reserves', 'NUMBER', 'MMBBL', FALSE),
    ('e003-field', 'ESTIMATED_RESERVES_GAS', 'Estimated Gas Reserves', 'Estimated recoverable gas reserves', 'NUMBER', 'BCF', FALSE);

-- Insert Attribute Definitions for FACILITY
INSERT INTO OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_ATTRIBUTE 
    (ENTITY_ID, ATTRIBUTE_NAME, ATTRIBUTE_DISPLAY_NAME, ATTRIBUTE_DESCRIPTION, DATA_TYPE, UNIT_OF_MEASURE, IS_REQUIRED)
VALUES 
    ('e004-facility', 'FACILITY_NAME', 'Facility Name', 'Name of the facility', 'VARCHAR', NULL, TRUE),
    ('e004-facility', 'FACILITY_TYPE', 'Facility Type', 'Type of facility (SEPARATOR, COMPRESSOR, TANK_BATTERY, CPF)', 'VARCHAR', NULL, TRUE),
    ('e004-facility', 'CAPACITY', 'Capacity', 'Processing capacity', 'NUMBER', 'BBL/DAY', FALSE),
    ('e004-facility', 'INSTALL_DATE', 'Installation Date', 'Date facility was installed', 'DATE', NULL, FALSE),
    ('e004-facility', 'STATUS', 'Status', 'Operational status', 'VARCHAR', NULL, FALSE);

-- Insert Attribute Definitions for EQUIPMENT
INSERT INTO OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_ATTRIBUTE 
    (ENTITY_ID, ATTRIBUTE_NAME, ATTRIBUTE_DISPLAY_NAME, ATTRIBUTE_DESCRIPTION, DATA_TYPE, UNIT_OF_MEASURE, IS_REQUIRED)
VALUES 
    ('e005-equipment', 'EQUIPMENT_NAME', 'Equipment Name', 'Name of the equipment', 'VARCHAR', NULL, TRUE),
    ('e005-equipment', 'EQUIPMENT_TYPE', 'Equipment Type', 'Type of equipment (PUMP, ESP, ROD_PUMP, COMPRESSOR)', 'VARCHAR', NULL, TRUE),
    ('e005-equipment', 'MANUFACTURER', 'Manufacturer', 'Equipment manufacturer', 'VARCHAR', NULL, FALSE),
    ('e005-equipment', 'MODEL', 'Model', 'Equipment model', 'VARCHAR', NULL, FALSE),
    ('e005-equipment', 'SERIAL_NUMBER', 'Serial Number', 'Unique serial number', 'VARCHAR', NULL, FALSE),
    ('e005-equipment', 'INSTALL_DATE', 'Installation Date', 'Date equipment was installed', 'DATE', NULL, FALSE),
    ('e005-equipment', 'LAST_MAINTENANCE_DATE', 'Last Maintenance Date', 'Date of last maintenance', 'DATE', NULL, FALSE),
    ('e005-equipment', 'STATUS', 'Status', 'Operational status (RUNNING, FAILED, MAINTENANCE)', 'VARCHAR', NULL, FALSE);

-- Insert Relationship Definitions
INSERT INTO OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_RELATION_DEF 
    (DOMAIN_ID, RELATION_NAME, RELATION_DISPLAY_NAME, RELATION_DESCRIPTION, SOURCE_ENTITY_ID, TARGET_ENTITY_ID, CARDINALITY, INVERSE_RELATION_NAME)
VALUES 
    ('d001-og-upstream', 'PART_OF_FIELD', 'Part of Field', 'Well belongs to a field', 'e001-well', 'e003-field', '1:N', 'HAS_WELL'),
    ('d001-og-upstream', 'HAS_WELLBORE', 'Has Wellbore', 'Well contains wellbores', 'e001-well', 'e002-wellbore', '1:N', 'WELLBORE_OF'),
    ('d001-og-upstream', 'PRODUCES_TO', 'Produces To', 'Well produces to a facility', 'e001-well', 'e004-facility', '1:N', 'RECEIVES_FROM'),
    ('d001-og-upstream', 'HAS_EQUIPMENT', 'Has Equipment', 'Well has installed equipment', 'e001-well', 'e005-equipment', '1:N', 'INSTALLED_IN'),
    ('d001-og-upstream', 'HAS_PRODUCTION', 'Has Production', 'Well has production records', 'e001-well', 'e008-production_period', '1:N', 'PRODUCTION_OF'),
    ('d001-og-upstream', 'TARGETS_RESERVOIR', 'Targets Reservoir', 'Well targets a reservoir', 'e001-well', 'e006-reservoir', 'N:N', 'TARGETED_BY'),
    ('d001-og-upstream', 'HAS_COMPLETION', 'Has Completion', 'Well has completion records', 'e001-well', 'e007-completion', '1:N', 'COMPLETION_OF'),
    ('d001-og-upstream', 'FIELD_HAS_FACILITY', 'Has Facility', 'Field has associated facilities', 'e003-field', 'e004-facility', '1:N', 'FACILITY_IN_FIELD');
