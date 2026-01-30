-- ============================================================================
-- O&G UPSTREAM ONTOLOGY - SEMANTIC VIEW
-- ============================================================================
-- Creates a Semantic View for Cortex Analyst natural language queries
-- This is the preferred approach over YAML files uploaded to stages
-- ============================================================================

USE DATABASE OG_ONTOLOGY_DEMO;
USE SCHEMA ONTOLOGY_VIEWS;

-- Create the Semantic View
CREATE OR REPLACE SEMANTIC VIEW OG_UPSTREAM_ONTOLOGY
TABLES (
    -- Wells table - Master table of all wells
    wells AS OG_ONTOLOGY_DEMO.ONTOLOGY_VIEWS.V_WELLS
        PRIMARY KEY (WELL_ID)
        WITH SYNONYMS = ('well', 'oil well', 'gas well')
        COMMENT = 'Master table of all wells',
    
    -- Fields table - Master table of all fields
    fields AS OG_ONTOLOGY_DEMO.ONTOLOGY_VIEWS.V_FIELDS
        PRIMARY KEY (FIELD_ID)
        WITH SYNONYMS = ('field', 'oil field', 'gas field')
        COMMENT = 'Master table of all fields',
    
    -- Well Production table - Monthly production data per well
    well_prod AS OG_ONTOLOGY_DEMO.ONTOLOGY_VIEWS.V_WELL_PRODUCTION
        PRIMARY KEY (PRODUCTION_ID)
        WITH SYNONYMS = ('production', 'well production')
        COMMENT = 'Monthly production data per well',
    
    -- Monthly Well Ranking - Wells ranked by monthly production
    well_ranking AS OG_ONTOLOGY_DEMO.ONTOLOGY_VIEWS.V_MONTHLY_WELL_RANKING
        WITH SYNONYMS = ('ranking', 'top producers')
        COMMENT = 'Wells ranked by monthly production',
    
    -- Well Equipment - Equipment installed on wells
    well_equip AS OG_ONTOLOGY_DEMO.ONTOLOGY_VIEWS.V_WELL_EQUIPMENT
        PRIMARY KEY (EQUIPMENT_ID)
        WITH SYNONYMS = ('equipment', 'ESP', 'pump')
        COMMENT = 'Equipment installed on wells',
    
    -- Shut-in Wells - Wells currently in shut-in status
    shut_in AS OG_ONTOLOGY_DEMO.ONTOLOGY_VIEWS.V_SHUT_IN_WELLS
        WITH SYNONYMS = ('shut-in', 'inactive wells')
        COMMENT = 'Wells currently in shut-in status',
    
    -- Field Production - Aggregated production by field
    field_prod AS OG_ONTOLOGY_DEMO.ONTOLOGY_VIEWS.V_FIELD_PRODUCTION
        WITH SYNONYMS = ('field production')
        COMMENT = 'Aggregated production by field',
    
    -- Production Trend - Month-over-month production changes
    prod_trend AS OG_ONTOLOGY_DEMO.ONTOLOGY_VIEWS.V_PRODUCTION_TREND
        WITH SYNONYMS = ('trend', 'production trend')
        COMMENT = 'Month-over-month production changes'
)
RELATIONSHIPS (
    -- Well production references wells
    well_prod_to_wells AS well_prod(WELL_ID) REFERENCES wells(WELL_ID),
    -- Well equipment references wells
    well_equip_to_wells AS well_equip(WELL_ID) REFERENCES wells(WELL_ID),
    -- Well ranking references wells
    well_ranking_to_wells AS well_ranking(WELL_ID) REFERENCES wells(WELL_ID),
    -- Production trend references wells
    prod_trend_to_wells AS prod_trend(WELL_ID) REFERENCES wells(WELL_ID),
    -- Shut-in wells references wells
    shut_in_to_wells AS shut_in(WELL_ID) REFERENCES wells(WELL_ID)
)
FACTS (
    -- Production volume facts
    well_prod.oil_volume AS well_prod.OIL_VOLUME_BBL
        WITH SYNONYMS = ('oil', 'oil production', 'barrels of oil')
        COMMENT = 'Oil production volume in barrels',
    well_prod.gas_volume AS well_prod.GAS_VOLUME_MCF
        WITH SYNONYMS = ('gas', 'gas production', 'mcf')
        COMMENT = 'Gas production volume in MCF',
    well_prod.water_volume AS well_prod.WATER_VOLUME_BBL
        WITH SYNONYMS = ('water', 'water production')
        COMMENT = 'Water production volume in barrels',
    well_prod.days_on AS well_prod.DAYS_ON_PRODUCTION
        WITH SYNONYMS = ('producing days')
        COMMENT = 'Days the well was producing',
    well_prod.downtime AS well_prod.DOWNTIME_HOURS
        WITH SYNONYMS = ('downtime')
        COMMENT = 'Hours of downtime',
    well_prod.uptime AS well_prod.UPTIME_PCT
        WITH SYNONYMS = ('uptime', 'availability')
        COMMENT = 'Uptime percentage',
    
    -- Ranking facts
    well_ranking.oil_rank AS well_ranking.OIL_RANK
        COMMENT = 'Rank by oil production',
    well_ranking.gas_rank AS well_ranking.GAS_RANK
        COMMENT = 'Rank by gas production',
    
    -- Trend facts
    prod_trend.oil_change AS prod_trend.OIL_CHANGE_PCT
        WITH SYNONYMS = ('oil change', 'oil trend')
        COMMENT = 'Month-over-month oil change percentage',
    
    -- Field production facts
    field_prod.field_oil AS field_prod.TOTAL_OIL_BBL
        COMMENT = 'Total field oil production',
    field_prod.field_gas AS field_prod.TOTAL_GAS_MCF
        COMMENT = 'Total field gas production',
    field_prod.wells AS field_prod.WELL_COUNT
        COMMENT = 'Number of wells in field'
)
DIMENSIONS (
    -- Well dimensions
    wells.well_id AS wells.WELL_ID
        COMMENT = 'Unique well identifier',
    wells.api_number AS wells.API_NUMBER
        WITH SYNONYMS = ('API', 'well number')
        COMMENT = 'API well number',
    wells.well_name AS wells.WELL_NAME
        WITH SYNONYMS = ('name')
        COMMENT = 'Well name',
    wells.well_status AS wells.WELL_STATUS
        WITH SYNONYMS = ('status', 'active', 'shut-in')
        COMMENT = 'Operational status',
    wells.well_type AS wells.WELL_TYPE
        WITH SYNONYMS = ('type')
        COMMENT = 'Well type (OIL, GAS)',
    wells.operator AS wells.OPERATOR
        WITH SYNONYMS = ('company', 'producer')
        COMMENT = 'Operating company',
    wells.spud_date AS wells.SPUD_DATE
        COMMENT = 'Drilling start date',
    wells.completion_date AS wells.COMPLETION_DATE
        COMMENT = 'Completion date',
    wells.total_depth AS wells.TOTAL_DEPTH_FT
        WITH SYNONYMS = ('depth', 'TD')
        COMMENT = 'Total depth in feet',
    
    -- Field dimensions
    fields.field_id AS fields.FIELD_ID
        COMMENT = 'Unique field identifier',
    fields.field_name AS fields.FIELD_NAME
        WITH SYNONYMS = ('field')
        COMMENT = 'Field name',
    fields.basin AS fields.BASIN
        WITH SYNONYMS = ('play')
        COMMENT = 'Geological basin',
    fields.region AS fields.REGION
        COMMENT = 'Geographic region',
    
    -- Time dimensions
    well_prod.period_date AS well_prod.PERIOD_DATE
        WITH SYNONYMS = ('date', 'production date')
        COMMENT = 'Production period date',
    well_prod.production_month AS well_prod.PRODUCTION_MONTH
        WITH SYNONYMS = ('month')
        COMMENT = 'Production month',
    well_prod.production_quarter AS well_prod.PRODUCTION_QUARTER
        WITH SYNONYMS = ('quarter')
        COMMENT = 'Production quarter',
    well_prod.production_year AS well_prod.PRODUCTION_YEAR
        WITH SYNONYMS = ('year')
        COMMENT = 'Production year',
    
    -- Equipment dimensions
    well_equip.equipment_type AS well_equip.EQUIPMENT_TYPE
        WITH SYNONYMS = ('equipment', 'ESP')
        COMMENT = 'Equipment type',
    well_equip.equipment_status AS well_equip.EQUIPMENT_STATUS
        WITH SYNONYMS = ('condition')
        COMMENT = 'Equipment status',
    well_equip.manufacturer AS well_equip.MANUFACTURER
        COMMENT = 'Equipment manufacturer',
    well_equip.is_failed AS well_equip.IS_FAILED
        WITH SYNONYMS = ('failed', 'failure')
        COMMENT = 'Equipment failure flag'
)
METRICS (
    -- Production aggregation metrics
    well_prod.total_oil AS SUM(well_prod.oil_volume)
        WITH SYNONYMS = ('total oil', 'cumulative oil')
        COMMENT = 'Total oil production in barrels',
    well_prod.total_gas AS SUM(well_prod.gas_volume)
        WITH SYNONYMS = ('total gas', 'cumulative gas')
        COMMENT = 'Total gas production in MCF',
    well_prod.total_water AS SUM(well_prod.water_volume)
        WITH SYNONYMS = ('total water')
        COMMENT = 'Total water production in barrels',
    well_prod.avg_uptime AS AVG(well_prod.uptime)
        WITH SYNONYMS = ('average uptime')
        COMMENT = 'Average uptime percentage',
    well_prod.total_downtime AS SUM(well_prod.downtime)
        WITH SYNONYMS = ('total downtime')
        COMMENT = 'Total downtime hours',
    
    -- Count metrics
    wells.well_count AS COUNT(DISTINCT wells.well_id)
        WITH SYNONYMS = ('number of wells', 'how many wells')
        COMMENT = 'Count of distinct wells',
    well_equip.failed_count AS COUNT(DISTINCT IFF(well_equip.is_failed, well_equip.equipment_id, NULL))
        WITH SYNONYMS = ('failed equipment')
        COMMENT = 'Count of failed equipment'
)
COMMENT = 'O&G Upstream Ontology Semantic View for production analysis, well management, and equipment monitoring'
AI_SQL_GENERATION 'Oil and gas upstream production data. Use well_prod for production queries. Use well_ranking for top producers. Use well_equip with is_failed for equipment failures. Use shut_in for shut-in wells. Volumes are in BBL (oil/water) and MCF (gas). Last month = most recent PRODUCTION_MONTH.';

-- Verify the semantic view was created
SHOW SEMANTIC VIEWS LIKE 'OG_UPSTREAM_ONTOLOGY' IN SCHEMA OG_ONTOLOGY_DEMO.ONTOLOGY_VIEWS;

-- View semantic view definition
DESCRIBE SEMANTIC VIEW OG_UPSTREAM_ONTOLOGY;
