/*
=============================================================================
O&G Upstream Ontology Demo - Ontology Metadata Tables
=============================================================================
Layer 2 tables that store the declarative definitions of business meaning.
These tables define WHAT entities, attributes, and relationships exist
in the domain without storing actual data.

Tables:
  - ONT_DOMAIN: High-level domain definitions (e.g., O&G Upstream)
  - ONT_ENTITY: Entity type definitions (e.g., WELL, FIELD)
  - ONT_ATTRIBUTE: Attribute definitions for each entity type
  - ONT_RELATION_DEF: Relationship type definitions between entities
=============================================================================
*/

-- ONT_DOMAIN: Domain definitions (e.g., O&G Upstream)
CREATE TABLE IF NOT EXISTS OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_DOMAIN (
    DOMAIN_ID VARCHAR(36) DEFAULT UUID_STRING() PRIMARY KEY,
    DOMAIN_NAME VARCHAR(100) NOT NULL UNIQUE,
    DOMAIN_DESCRIPTION VARCHAR(2000),
    SEMANTIC_YAML TEXT,                        -- Semantic model YAML for Cortex Analyst
    EMBEDDING VECTOR(FLOAT, 1024),             -- Vector embedding for semantic search
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Ontology Layer 2: Domain definitions for organizing entities';

-- ONT_ENTITY: Entity type definitions (WELL, FIELD, FACILITY, etc.)
CREATE TABLE IF NOT EXISTS OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_ENTITY (
    ENTITY_ID VARCHAR(36) DEFAULT UUID_STRING() PRIMARY KEY,
    DOMAIN_ID VARCHAR(36) NOT NULL,
    ENTITY_NAME VARCHAR(100) NOT NULL,         -- e.g., WELL, WELLBORE, FIELD
    ENTITY_DISPLAY_NAME VARCHAR(200),          -- Human-friendly name
    ENTITY_DESCRIPTION VARCHAR(2000),          -- Business description
    ENTITY_ICON VARCHAR(50),                   -- Icon identifier for UI
    SEMANTIC_YAML TEXT,                        -- Semantic model YAML snippet
    EMBEDDING VECTOR(FLOAT, 1024),             -- Vector embedding
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    
    FOREIGN KEY (DOMAIN_ID) REFERENCES OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_DOMAIN(DOMAIN_ID),
    UNIQUE (DOMAIN_ID, ENTITY_NAME)
)
COMMENT = 'Ontology Layer 2: Entity type definitions within a domain';

-- ONT_ATTRIBUTE: Attribute definitions for entities
CREATE TABLE IF NOT EXISTS OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_ATTRIBUTE (
    ATTRIBUTE_ID VARCHAR(36) DEFAULT UUID_STRING() PRIMARY KEY,
    ENTITY_ID VARCHAR(36) NOT NULL,
    ATTRIBUTE_NAME VARCHAR(100) NOT NULL,      -- Technical name
    ATTRIBUTE_DISPLAY_NAME VARCHAR(200),       -- Human-friendly name
    ATTRIBUTE_DESCRIPTION VARCHAR(2000),       -- Business description
    DATA_TYPE VARCHAR(50) NOT NULL,            -- NUMBER, VARCHAR, DATE, BOOLEAN, etc.
    UNIT_OF_MEASURE VARCHAR(50),               -- e.g., BBL, MCF, PSI
    IS_REQUIRED BOOLEAN DEFAULT FALSE,
    IS_SEARCHABLE BOOLEAN DEFAULT TRUE,
    DEFAULT_VALUE VARCHAR(500),
    VALIDATION_RULE VARCHAR(1000),
    EMBEDDING VECTOR(FLOAT, 1024),             -- Vector embedding
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    
    FOREIGN KEY (ENTITY_ID) REFERENCES OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_ENTITY(ENTITY_ID),
    UNIQUE (ENTITY_ID, ATTRIBUTE_NAME)
)
COMMENT = 'Ontology Layer 2: Attribute definitions for entity types';

-- ONT_RELATION_DEF: Relationship type definitions
CREATE TABLE IF NOT EXISTS OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_RELATION_DEF (
    RELATION_ID VARCHAR(36) DEFAULT UUID_STRING() PRIMARY KEY,
    DOMAIN_ID VARCHAR(36) NOT NULL,
    RELATION_NAME VARCHAR(100) NOT NULL,       -- e.g., PRODUCES, PART_OF, TESTED_BY
    RELATION_DISPLAY_NAME VARCHAR(200),
    RELATION_DESCRIPTION VARCHAR(2000),
    SOURCE_ENTITY_ID VARCHAR(36) NOT NULL,     -- Source entity type
    TARGET_ENTITY_ID VARCHAR(36) NOT NULL,     -- Target entity type
    CARDINALITY VARCHAR(20) DEFAULT '1:N',     -- 1:1, 1:N, N:N
    IS_DIRECTIONAL BOOLEAN DEFAULT TRUE,
    INVERSE_RELATION_NAME VARCHAR(100),        -- e.g., PRODUCED_BY for PRODUCES
    EMBEDDING VECTOR(FLOAT, 1024),             -- Vector embedding
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    
    FOREIGN KEY (DOMAIN_ID) REFERENCES OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_DOMAIN(DOMAIN_ID),
    FOREIGN KEY (SOURCE_ENTITY_ID) REFERENCES OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_ENTITY(ENTITY_ID),
    FOREIGN KEY (TARGET_ENTITY_ID) REFERENCES OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_ENTITY(ENTITY_ID)
)
COMMENT = 'Ontology Layer 2: Relationship type definitions between entities';
