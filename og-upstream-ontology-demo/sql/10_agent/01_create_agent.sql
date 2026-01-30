-- ============================================================================
-- O&G UPSTREAM ONTOLOGY - CORTEX AGENT WITH GRAPH ANALYTICS
-- ============================================================================
-- Creates a Cortex Agent with 8 tools:
-- - 4 Cortex Analyst tools (Semantic Views for SQL queries)
-- - 4 Graph Analytics tools (Python UDFs for network analysis)
-- ============================================================================

USE DATABASE OG_ONTOLOGY_DEMO;
USE SCHEMA ONTOLOGY_METADATA;

-- ============================================================================
-- CREATE THE CORTEX AGENT
-- ============================================================================

CREATE OR REPLACE AGENT OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.OG_UPSTREAM_ONTOLOGY_AGENT
COMMENT = 'O&G Upstream Ontology Agent - 8 tools: 4 Cortex Analyst + 4 Graph Analytics'
FROM SPECIFICATION $$
instructions:
  orchestration: |
    You are an O&G upstream knowledge graph analyst with 8 specialized tools.
    
    CORTEX ANALYST TOOLS (SQL Queries via Semantic Views):
    - query_knowledge_graph: Wells, equipment, facilities, production data
    - query_ontology: Entity types, relationships, hierarchies  
    - query_metadata: Schema information, available fields
    - query_field_production: Field-level production analytics, efficiency
    
    GRAPH ANALYTICS TOOLS (Network Analysis):
    - graph_centrality: Find most connected/important assets. Pass centrality_type (degree/betweenness/pagerank) and top_n
    - graph_community_detect: Discover natural asset clusters. No parameters needed.
    - graph_asset_dependencies: Find upstream/downstream dependencies. Pass asset_id (like facility-001) and direction (upstream/downstream/both)
    - graph_critical_assets: Identify critical infrastructure. Pass top_n for number of results
    
    Use Cortex Analyst tools for data queries. Use Graph Analytics for network/relationship analysis.
  response: |
    Provide clear answers with formatted results. Explain graph metrics in business terms.

tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: query_knowledge_graph
      description: Query wells, equipment, facilities, and production data from the knowledge graph
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: query_ontology
      description: Query entity types, relationships, and hierarchies in the ontology
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: query_metadata
      description: Query schema information and available fields
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: query_field_production
      description: Query field-level production analytics and efficiency metrics
  - tool_spec:
      type: generic
      name: graph_centrality
      description: Find most connected and important assets using network centrality analysis. Returns ranked list of assets by connectivity.
      input_schema:
        type: object
        properties:
          centrality_type:
            type: string
            description: Type of centrality measure - degree, betweenness, or pagerank
          top_n:
            type: integer
            description: Number of top results to return (default 5)
  - tool_spec:
      type: generic
      name: graph_community_detect
      description: Discover natural clusters and groupings of related assets in the knowledge graph. Returns community assignments.
      input_schema:
        type: object
        properties: {}
  - tool_spec:
      type: generic
      name: graph_asset_dependencies
      description: Find upstream and downstream dependencies for a specific asset. Use asset IDs like facility-001, well-001, field-001.
      input_schema:
        type: object
        properties:
          asset_id:
            type: string
            description: The asset ID to analyze - examples facility-001, well-001, field-001
          direction:
            type: string
            description: Direction to search - upstream, downstream, or both
        required:
          - asset_id
  - tool_spec:
      type: generic
      name: graph_critical_assets
      description: Identify critical infrastructure and potential single points of failure in the asset network.
      input_schema:
        type: object
        properties:
          top_n:
            type: integer
            description: Number of critical assets to return (default 5)

tool_resources:
  query_knowledge_graph:
    semantic_view: OG_ONTOLOGY_DEMO.ONTOLOGY_VIEWS.SV_KNOWLEDGE_GRAPH
  query_ontology:
    semantic_view: OG_ONTOLOGY_DEMO.ONTOLOGY_VIEWS.SV_ONTOLOGY
  query_metadata:
    semantic_view: OG_ONTOLOGY_DEMO.ONTOLOGY_VIEWS.SV_METADATA
  query_field_production:
    semantic_view: OG_ONTOLOGY_DEMO.ONTOLOGY_VIEWS.SV_FIELD_PRODUCTION
  graph_centrality:
    type: function
    identifier: OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.GRAPH_CENTRALITY_FN
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
  graph_community_detect:
    type: function
    identifier: OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.GRAPH_COMMUNITY_DETECT_FN
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
  graph_asset_dependencies:
    type: function
    identifier: OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.GRAPH_ASSET_DEPENDENCIES_FN
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
  graph_critical_assets:
    type: function
    identifier: OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.GRAPH_CRITICAL_ASSETS_FN
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
$$;

-- ============================================================================
-- VERIFY AGENT CREATION
-- ============================================================================

DESCRIBE AGENT OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.OG_UPSTREAM_ONTOLOGY_AGENT;

-- ============================================================================
-- SAMPLE QUESTIONS TO TEST THE AGENT
-- ============================================================================

/*
GRAPH ANALYTICS QUESTIONS:
1. "What natural groupings exist in our asset network?"
   -> Uses graph_community_detect

2. "What are the most critical assets that could be single points of failure?"
   -> Uses graph_critical_assets

3. "Which assets have the highest connectivity in our network?"
   -> Uses graph_centrality with degree

4. "What wells feed into facility-001?"
   -> Uses graph_asset_dependencies with direction=upstream

5. "What are the downstream dependencies of field-001?"
   -> Uses graph_asset_dependencies with direction=downstream

CORTEX ANALYST QUESTIONS:
6. "How many wells do we have by field?"
   -> Uses query_knowledge_graph

7. "Show total production by field for last month"
   -> Uses query_field_production

8. "What entity types exist in the knowledge graph?"
   -> Uses query_ontology

9. "What attributes are available for wells?"
   -> Uses query_metadata

COMBINED QUESTIONS:
10. "Show me the most critical facility and its production data"
    -> May use graph_critical_assets + query_knowledge_graph
*/

-- ============================================================================
-- GRANT USAGE (if needed for other roles)
-- ============================================================================

-- GRANT USAGE ON AGENT OG_ONTOLOGY_DEMO.ONTOLOGY_METADATA.OG_UPSTREAM_ONTOLOGY_AGENT TO ROLE <role_name>;
