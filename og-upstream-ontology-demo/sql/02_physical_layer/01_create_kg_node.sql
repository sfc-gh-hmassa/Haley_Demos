/*
=============================================================================
O&G Upstream Ontology Demo - KG_NODE Table
=============================================================================
Universal node storage table for the Knowledge Graph.
All entity instances (Wells, Fields, Facilities, etc.) are stored here.

Features:
  - UUID-based primary key
  - Flexible VARIANT column for entity-specific properties
  - Vector embedding column for semantic search
  - Audit columns for tracking changes
=============================================================================
*/

CREATE TABLE IF NOT EXISTS OG_ONTOLOGY_DEMO.PHYSICAL_LAYER.KG_NODE (
    NODE_ID VARCHAR(36) DEFAULT UUID_STRING() PRIMARY KEY,
    NODE_TYPE VARCHAR(100) NOT NULL,           -- Entity type (WELL, FIELD, FACILITY, etc.)
    NODE_KEY VARCHAR(255) NOT NULL,            -- Business key (e.g., well API number)
    NODE_NAME VARCHAR(500),                    -- Display name
    NODE_DESCRIPTION VARCHAR(4000),            -- Human-readable description
    NODE_PROPERTIES VARIANT,                   -- Flexible JSON properties
    EMBEDDING VECTOR(FLOAT, 1024),             -- Vector embedding for semantic search
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CREATED_BY VARCHAR(100) DEFAULT CURRENT_USER(),
    
    UNIQUE (NODE_TYPE, NODE_KEY)
)
COMMENT = 'Universal node storage - stores all entity instances in the knowledge graph';
