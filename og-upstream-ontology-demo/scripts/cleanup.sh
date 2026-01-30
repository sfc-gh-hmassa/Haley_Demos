#!/bin/bash
#=============================================================================
# O&G Upstream Ontology Demo - Cleanup Script
#=============================================================================
# This script removes the demo database and all its contents.
#
# Usage:
#   ./cleanup.sh <connection_name>
#=============================================================================

set -e

CONNECTION=${1:-"default"}

echo "========================================"
echo "O&G Upstream Ontology Demo Cleanup"
echo "========================================"
echo "Connection: $CONNECTION"
echo ""
echo "WARNING: This will permanently delete the OG_ONTOLOGY_DEMO database!"
read -p "Are you sure? (y/N): " confirm

if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    echo "Dropping database..."
    snow sql -q "DROP DATABASE IF EXISTS OG_ONTOLOGY_DEMO CASCADE;" -c "$CONNECTION"
    echo "Database OG_ONTOLOGY_DEMO has been dropped."
else
    echo "Cleanup cancelled."
fi
