/*
=============================================================================
O&G Upstream Ontology Demo - Vector Embeddings
=============================================================================
Adds semantic vector embeddings to all nodes and metadata using
Snowflake Cortex EMBED_TEXT function.

These embeddings enable:
  - Semantic search across the knowledge graph
  - Natural language queries
  - Similarity-based recommendations
=============================================================================
*/

-- Add vector embeddings to KG_NODE using Cortex EMBED_TEXT function
UPDATE OG_ONTOLOGY_DEMO.PHYSICAL_LAYER.KG_NODE
SET EMBEDDING = SNOWFLAKE.CORTEX.EMBED_TEXT_1024('snowflake-arctic-embed-l-v2.0', 
    CONCAT(NODE_TYPE, ': ', NODE_NAME, '. ', COALESCE(NODE_DESCRIPTION, '')))
WHERE EMBEDDING IS NULL;

-- Add vector embeddings to ONT_ENTITY
UPDATE OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_ENTITY
SET EMBEDDING = SNOWFLAKE.CORTEX.EMBED_TEXT_1024('snowflake-arctic-embed-l-v2.0', 
    CONCAT(ENTITY_NAME, ': ', ENTITY_DISPLAY_NAME, '. ', COALESCE(ENTITY_DESCRIPTION, '')))
WHERE EMBEDDING IS NULL;

-- Add vector embeddings to ONT_ATTRIBUTE
UPDATE OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_ATTRIBUTE
SET EMBEDDING = SNOWFLAKE.CORTEX.EMBED_TEXT_1024('snowflake-arctic-embed-l-v2.0', 
    CONCAT(ATTRIBUTE_NAME, ': ', ATTRIBUTE_DISPLAY_NAME, '. ', COALESCE(ATTRIBUTE_DESCRIPTION, ''), 
           CASE WHEN UNIT_OF_MEASURE IS NOT NULL THEN CONCAT(' Unit: ', UNIT_OF_MEASURE) ELSE '' END))
WHERE EMBEDDING IS NULL;

-- Add vector embeddings to ONT_RELATION_DEF
UPDATE OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.ONT_RELATION_DEF
SET EMBEDDING = SNOWFLAKE.CORTEX.EMBED_TEXT_1024('snowflake-arctic-embed-l-v2.0', 
    CONCAT(RELATION_NAME, ': ', RELATION_DISPLAY_NAME, '. ', COALESCE(RELATION_DESCRIPTION, '')))
WHERE EMBEDDING IS NULL;
