#!/bin/bash
#=============================================================================
# O&G Upstream Ontology Demo - Full Deployment Script
#=============================================================================
# This script deploys the complete demo to Snowflake using Snowflake CLI.
# 
# Prerequisites:
#   - Snowflake CLI (snow) installed
#   - Snowflake connection configured
#
# Usage:
#   ./deploy.sh <connection_name> [warehouse_name]
#
# Example:
#   ./deploy.sh myconnection COMPUTE_WH
#=============================================================================

set -e

CONNECTION=${1:-"default"}
WAREHOUSE=${2:-"COMPUTE_WH"}

echo "========================================"
echo "O&G Upstream Ontology Demo Deployment"
echo "========================================"
echo "Connection: $CONNECTION"
echo "Warehouse:  $WAREHOUSE"
echo ""

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SQL_DIR="$SCRIPT_DIR/../sql"

echo "Step 1: Creating database and schemas..."
snow sql -f "$SQL_DIR/01_setup/01_create_database.sql" -c "$CONNECTION"

echo "Step 2: Creating Physical Layer tables..."
snow sql -f "$SQL_DIR/02_physical_layer/01_create_kg_node.sql" -c "$CONNECTION"
snow sql -f "$SQL_DIR/02_physical_layer/02_create_kg_edge.sql" -c "$CONNECTION"

echo "Step 3: Creating Ontology Metadata tables..."
snow sql -f "$SQL_DIR/03_ontology_metadata/01_create_metadata_tables.sql" -c "$CONNECTION"
snow sql -f "$SQL_DIR/03_ontology_metadata/02_populate_metadata.sql" -c "$CONNECTION"

echo "Step 4: Inserting sample data..."
snow sql -f "$SQL_DIR/04_sample_data/01_insert_entities.sql" -c "$CONNECTION"
snow sql -f "$SQL_DIR/04_sample_data/02_insert_relationships.sql" -c "$CONNECTION"
snow sql -f "$SQL_DIR/04_sample_data/03_insert_production.sql" -c "$CONNECTION"

echo "Step 5: Creating Ontology Views..."
snow sql -f "$SQL_DIR/05_ontology_views/01_create_views.sql" -c "$CONNECTION"

echo "Step 6: Adding vector embeddings..."
snow sql -f "$SQL_DIR/06_embeddings/01_add_embeddings.sql" -c "$CONNECTION"

echo "Step 7: Creating Semantic Views..."
snow sql -f "$SQL_DIR/07_semantic_view/01_create_semantic_view.sql" -c "$CONNECTION"

echo "Step 8: Creating Graph Analytics Functions..."
snow sql -f "$SQL_DIR/09_graph_analytics/01_create_graph_functions.sql" -c "$CONNECTION"

echo "Step 9: Creating Cortex Agent..."
# Replace warehouse name in agent SQL and execute
sed "s/COMPUTE_WH/$WAREHOUSE/g" "$SQL_DIR/10_agent/01_create_agent.sql" | \
    snow sql -c "$CONNECTION" -i

echo "Step 10: Uploading semantic model YAML (alternative to Semantic View)..."
snow stage copy "$SCRIPT_DIR/../semantic_model/og_upstream_semantic_model.yaml" \
    @OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.SEMANTIC_MODELS \
    -c "$CONNECTION" --overwrite 2>/dev/null || echo "  (Skipped - stage may not exist)"

echo ""
echo "========================================"
echo "Deployment Complete!"
echo "========================================"
echo ""
echo "Database: OG_ONTOLOGY_DEMO"
echo "Schemas:  PHYSICAL_LAYER, ONTOLOGY_METADATA, ONTOLOGY_VIEWS"
echo ""
echo "Cortex Agent: OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.OG_UPSTREAM_ONTOLOGY_AGENT"
echo "  Tools:"
echo "    - query_knowledge_graph (Cortex Analyst)"
echo "    - query_ontology (Cortex Analyst)"
echo "    - query_metadata (Cortex Analyst)"
echo "    - query_field_production (Cortex Analyst)"
echo "    - graph_community_detect (Graph Analytics)"
echo "    - graph_critical_assets (Graph Analytics)"
echo "    - graph_centrality (Graph Analytics)"
echo "    - graph_asset_dependencies (Graph Analytics)"
echo ""
echo "Access the agent in Snowsight: AI & ML -> Agents -> OG_UPSTREAM_ONTOLOGY_AGENT"
echo ""
echo "Sample questions to try:"
echo "  - What natural groupings exist in our asset network?"
echo "  - What are the most critical assets?"
echo "  - How many wells do we have by field?"
echo "  - What wells feed into facility-001?"
echo ""
