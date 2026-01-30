/*
=============================================================================
O&G Upstream Ontology Demo - KG_EDGE Table
=============================================================================
Universal edge/relationship storage table for the Knowledge Graph.
All relationships between entities are stored here.

Features:
  - Supports any relationship type between any nodes
  - Temporal validity (EFFECTIVE_FROM, EFFECTIVE_TO)
  - Flexible properties for relationship attributes
  - Foreign keys to KG_NODE for data integrity
=============================================================================
*/

CREATE TABLE IF NOT EXISTS OG_ONTOLOGY_DEMO.PHYSICAL_LAYER.KG_EDGE (
    EDGE_ID VARCHAR(36) DEFAULT UUID_STRING() PRIMARY KEY,
    EDGE_TYPE VARCHAR(100) NOT NULL,           -- Relationship type (PRODUCES, PART_OF, TESTED_BY, etc.)
    SOURCE_NODE_ID VARCHAR(36) NOT NULL,       -- FK to source node
    TARGET_NODE_ID VARCHAR(36) NOT NULL,       -- FK to target node
    EDGE_PROPERTIES VARIANT,                   -- Flexible JSON properties (e.g., metrics, dates)
    EFFECTIVE_FROM DATE,                       -- Temporal validity start
    EFFECTIVE_TO DATE,                         -- Temporal validity end
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CREATED_BY VARCHAR(100) DEFAULT CURRENT_USER(),
    
    FOREIGN KEY (SOURCE_NODE_ID) REFERENCES OG_ONTOLOGY_DEMO.PHYSICAL_LAYER.KG_NODE(NODE_ID),
    FOREIGN KEY (TARGET_NODE_ID) REFERENCES OG_ONTOLOGY_DEMO.PHYSICAL_LAYER.KG_NODE(NODE_ID)
)
COMMENT = 'Universal edge storage - stores all relationships between nodes in the knowledge graph';
