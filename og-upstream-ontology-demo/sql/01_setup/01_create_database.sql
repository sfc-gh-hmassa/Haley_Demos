/*
=============================================================================
O&G Upstream Ontology Demo - Database Setup
=============================================================================
This script creates the main database and three-layer schema structure
following the Snowflake Ontology pattern.

Architecture:
  - PHYSICAL_LAYER: Universal object-relationship storage (KG_NODE, KG_EDGE)
  - ONTOLOGY_METADATA: Declarative definitions of business meaning
  - ONTOLOGY_VIEWS: Dynamic abstraction and unification views

Reference: https://medium.com/snowflake/ontology-on-snowflake-part-1-overview-and-data-model-9e8eeaac7363
=============================================================================
*/

-- Create the main database
CREATE DATABASE IF NOT EXISTS OG_ONTOLOGY_DEMO
COMMENT = 'Oil & Gas Upstream Ontology Demo - Semantic Intelligence Platform';

-- Layer 1: Physical Storage
CREATE SCHEMA IF NOT EXISTS OG_ONTOLOGY_DEMO.PHYSICAL_LAYER
COMMENT = 'Layer 1: Universal object-relationship storage';

-- Layer 2: Ontology Metadata  
CREATE SCHEMA IF NOT EXISTS OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA
COMMENT = 'Layer 2: Declarative definitions of business meaning';

-- Layer 3: Generated Views
CREATE SCHEMA IF NOT EXISTS OG_ONTOLOGY_DEMO.ONTOLOGY_VIEWS
COMMENT = 'Layer 3: Dynamic abstraction and unification views';

-- Create stage for semantic model files
CREATE STAGE IF NOT EXISTS OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.SEMANTIC_MODELS
DIRECTORY = (ENABLE = TRUE)
COMMENT = 'Stage for storing Cortex Analyst semantic model files';
