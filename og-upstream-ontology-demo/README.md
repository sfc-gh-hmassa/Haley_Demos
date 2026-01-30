# O&G Upstream Ontology Demo

A comprehensive demonstration of building a **Semantic Intelligence Platform** for Oil & Gas Upstream operations using **Snowflake's Ontology Pattern**. This demo implements a Knowledge Graph architecture with a **Cortex Agent** that combines natural language queries with **graph analytics**.

## Overview

This demo implements the 3-layer ontology architecture as described in [Ontology on Snowflake: Part 1](https://medium.com/snowflake/ontology-on-snowflake-part-1-overview-and-data-model-9e8eeaac7363), specifically tailored for Oil & Gas Upstream operations.

### What This Demo Shows

1. **Universal Data Model**: A flexible Knowledge Graph structure (nodes + edges) that can represent any O&G entity and relationship
2. **Semantic Layer**: Business metadata that gives meaning to technical data
3. **Dynamic Views**: Auto-generated views that flatten complex graph data for easy analytics
4. **Vector Embeddings**: Cortex-powered semantic search capabilities
5. **Cortex Agent**: 8-tool intelligent assistant combining:
   - **4 Cortex Analyst tools** - Natural language to SQL via Semantic Views
   - **4 Graph Analytics tools** - NetworkX-powered network analysis via Python UDFs

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CORTEX AGENT (8 Tools)                            │
│  ┌─────────────────────────────────┐  ┌─────────────────────────────────┐   │
│  │     CORTEX ANALYST (4 tools)    │  │    GRAPH ANALYTICS (4 tools)   │   │
│  │  • query_knowledge_graph        │  │  • graph_community_detect       │   │
│  │  • query_ontology               │  │  • graph_critical_assets        │   │
│  │  • query_metadata               │  │  • graph_centrality             │   │
│  │  • query_field_production       │  │  • graph_asset_dependencies     │   │
│  └─────────────────────────────────┘  └─────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    LAYER 3: ONTOLOGY_VIEWS (Generated Views)                │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐   │
│  │  V_WELLS    │ │  V_FIELDS   │ │V_PRODUCTION │ │ V_WELL_PRODUCTION   │   │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────────────┘   │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐   │
│  │V_EQUIPMENT  │ │V_FACILITIES │ │V_WELL_FIELD │ │ V_FIELD_PRODUCTION  │   │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                 LAYER 2: ONTOLOGY_METADATA (Business Meaning)               │
│  ┌─────────────┐ ┌─────────────┐ ┌───────────────┐ ┌───────────────────┐   │
│  │ ONT_DOMAIN  │ │ ONT_ENTITY  │ │ ONT_ATTRIBUTE │ │ ONT_RELATION_DEF  │   │
│  └─────────────┘ └─────────────┘ └───────────────┘ └───────────────────┘   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │              GRAPH ANALYTICS FUNCTIONS (Python UDFs)                │   │
│  │  • GRAPH_COMMUNITY_DETECT_FN   • GRAPH_CRITICAL_ASSETS_FN          │   │
│  │  • GRAPH_CENTRALITY_FN         • GRAPH_ASSET_DEPENDENCIES_FN       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                  LAYER 1: PHYSICAL_LAYER (Knowledge Graph)                  │
│  ┌───────────────────────────────┐    ┌───────────────────────────────┐    │
│  │           KG_NODE             │    │           KG_EDGE             │    │
│  │  • NODE_ID (UUID)             │    │  • EDGE_ID (UUID)             │    │
│  │  • NODE_TYPE                  │◄──►│  • EDGE_TYPE                  │    │
│  │  • NODE_KEY                   │    │  • SOURCE_NODE_ID             │    │
│  │  • NODE_NAME                  │    │  • TARGET_NODE_ID             │    │
│  │  • NODE_PROPERTIES (VARIANT)  │    │  • EDGE_PROPERTIES (VARIANT)  │    │
│  │  • EMBEDDING (VECTOR)         │    │  • EFFECTIVE_FROM/TO          │    │
│  └───────────────────────────────┘    └───────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Demo Questions

### Graph Analytics Questions

| Question | Tool Used | What It Shows |
|----------|-----------|---------------|
| "What natural groupings exist in our asset network?" | `graph_community_detect` | Discovers 4 regional clusters (Permian, Eagle Ford, Bakken, DJ Basin) |
| "What are the most critical assets that could be single points of failure?" | `graph_critical_assets` | Ranks assets by criticality score |
| "Which assets have the highest connectivity?" | `graph_centrality` | Network centrality analysis (degree, betweenness, PageRank) |
| "What wells feed into facility-001?" | `graph_asset_dependencies` | Upstream/downstream dependency tracing |

### Cortex Analyst Questions

| Question | Tool Used |
|----------|-----------|
| "How many wells do we have by field?" | `query_knowledge_graph` |
| "Show total production by field" | `query_field_production` |
| "What entity types exist in the ontology?" | `query_ontology` |
| "What attributes are available for wells?" | `query_metadata` |

## Project Structure

```
og-upstream-ontology-demo/
├── README.md                              # This file
├── sql/
│   ├── 01_setup/
│   │   └── 01_create_database.sql         # Database and schema creation
│   ├── 02_physical_layer/
│   │   ├── 01_create_kg_node.sql          # Universal node table
│   │   └── 02_create_kg_edge.sql          # Universal edge table
│   ├── 03_ontology_metadata/
│   │   ├── 01_create_metadata_tables.sql  # Metadata schema
│   │   └── 02_populate_metadata.sql       # O&G domain definitions
│   ├── 04_sample_data/
│   │   ├── 01_insert_entities.sql         # Fields, Wells, Facilities, Equipment
│   │   ├── 02_insert_relationships.sql    # Entity relationships
│   │   └── 03_insert_production.sql       # Production data (Q4 2024)
│   ├── 05_ontology_views/
│   │   └── 01_create_views.sql            # All Layer 3 views
│   ├── 06_embeddings/
│   │   └── 01_add_embeddings.sql          # Cortex vector embeddings
│   ├── 07_semantic_view/
│   │   └── 01_create_semantic_view.sql    # Semantic Views for Cortex Analyst
│   ├── 09_graph_analytics/
│   │   └── 01_create_graph_functions.sql  # Python UDFs for graph analytics
│   └── 10_agent/
│       └── 01_create_agent.sql            # Cortex Agent with 8 tools
├── semantic_models/
│   ├── og_knowledge_graph_model.yaml      # Knowledge graph semantic model
│   ├── og_ontology_model.yaml             # Ontology semantic model
│   └── og_metadata_governance_model.yaml  # Metadata semantic model
├── scripts/
│   ├── deploy.sh                          # Automated deployment script
│   └── cleanup.sh                         # Database cleanup script
└── docs/
    └── images/                            # Documentation images
```

## Prerequisites

- **Snowflake Account** with:
  - ACCOUNTADMIN role (or equivalent privileges)
  - Access to Snowflake Cortex (for embeddings and agents)
  - A warehouse (e.g., `COMPUTE_WH`)
- **Snowflake CLI** (`snow`) installed and configured
  - Install: `pip install snowflake-cli-labs`
  - Configure: `snow connection add`

## Quick Start

### Option 1: Automated Deployment

```bash
# Clone or download this repository
cd og-upstream-ontology-demo

# Run the deployment script
./scripts/deploy.sh <your_connection_name>
```

### Option 2: Manual Deployment

Execute the SQL files in order:

```bash
# 1. Setup
snow sql -f sql/01_setup/01_create_database.sql -c <connection>

# 2. Physical Layer
snow sql -f sql/02_physical_layer/01_create_kg_node.sql -c <connection>
snow sql -f sql/02_physical_layer/02_create_kg_edge.sql -c <connection>

# 3. Ontology Metadata
snow sql -f sql/03_ontology_metadata/01_create_metadata_tables.sql -c <connection>
snow sql -f sql/03_ontology_metadata/02_populate_metadata.sql -c <connection>

# 4. Sample Data
snow sql -f sql/04_sample_data/01_insert_entities.sql -c <connection>
snow sql -f sql/04_sample_data/02_insert_relationships.sql -c <connection>
snow sql -f sql/04_sample_data/03_insert_production.sql -c <connection>

# 5. Views
snow sql -f sql/05_ontology_views/01_create_views.sql -c <connection>

# 6. Embeddings
snow sql -f sql/06_embeddings/01_add_embeddings.sql -c <connection>

# 7. Semantic Views
snow sql -f sql/07_semantic_view/01_create_semantic_view.sql -c <connection>

# 8. Graph Analytics Functions
snow sql -f sql/09_graph_analytics/01_create_graph_functions.sql -c <connection>

# 9. Create Agent
snow sql -f sql/10_agent/01_create_agent.sql -c <connection>
```

## Using the Cortex Agent

After deployment, access the agent in **Snowsight**:

1. Navigate to **AI & ML** → **Agents**
2. Select **OG_UPSTREAM_ONTOLOGY_AGENT**
3. Ask questions like:
   - "What natural groupings exist in our asset network?"
   - "What are the most critical facilities?"
   - "How many wells do we have by field?"
   - "What wells feed into facility-001?"

### Customizing the Agent

Edit `sql/10_agent/01_create_agent.sql` to:
- Change the warehouse name (default: `COMPUTE_WH`)
- Add/remove tools
- Modify orchestration instructions

## Sample Data Summary

| Entity Type | Count | Details |
|-------------|-------|---------|
| Fields | 4 | Permian (Midland), Eagle Ford, Bakken, DJ Basin (Wattenberg) |
| Wells | 14 | Mix of oil and gas wells across all fields |
| Facilities | 5 | CPF, Separators, Tank Battery, Compressor Station |
| Equipment | 7 | ESPs, Rod Pump, Compressor, Separator |
| Production Records | 26 | Q4 2024 (Oct, Nov, Dec) |
| Relationships | 64 | Well-Field, Well-Facility, Well-Equipment, Production |

## Graph Analytics Functions

The demo includes 4 Python UDFs for network analysis:

| Function | Description | Parameters |
|----------|-------------|------------|
| `GRAPH_COMMUNITY_DETECT_FN()` | Discovers natural clusters | None |
| `GRAPH_CRITICAL_ASSETS_FN(top_n)` | Identifies critical infrastructure | `top_n`: Number of results |
| `GRAPH_CENTRALITY_FN(type, top_n)` | Measures asset importance | `type`: degree/betweenness/pagerank |
| `GRAPH_ASSET_DEPENDENCIES_FN(asset_id, direction)` | Traces dependencies | `asset_id`, `direction`: upstream/downstream/both |

### Testing Functions Directly

```sql
-- Discover asset clusters
SELECT OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.GRAPH_COMMUNITY_DETECT_FN();

-- Find critical assets
SELECT OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.GRAPH_CRITICAL_ASSETS_FN(5);

-- Check centrality
SELECT OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.GRAPH_CENTRALITY_FN('degree', 5);

-- Trace dependencies
SELECT OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.GRAPH_ASSET_DEPENDENCIES_FN('facility-001', 'upstream');
```

## Cleanup

```bash
./scripts/cleanup.sh <your_connection_name>
```

Or manually:

```sql
DROP DATABASE IF EXISTS OG_ONTOLOGY_DEMO CASCADE;
```

## References

- [Ontology on Snowflake: Part 1 - Overview and Data Model](https://medium.com/snowflake/ontology-on-snowflake-part-1-overview-and-data-model-9e8eeaac7363)
- [Snowflake Cortex Agents Documentation](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents)
- [Cortex Analyst Semantic Model Specification](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst/semantic-model-spec)

## License

This demo is provided for educational and demonstration purposes.

---

**Built with Snowflake Cortex Code**
