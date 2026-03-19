-- ============================================================================
-- Fine-Tuned Embedding Search Demo - Setup Script
-- ============================================================================
-- This script creates all infrastructure needed for the demo.
-- Run this BEFORE opening the notebook.
-- ============================================================================

-- 1. Database and Schema
CREATE DATABASE IF NOT EXISTS JIRA_EMBEDDING_DEMO;
USE DATABASE JIRA_EMBEDDING_DEMO;
CREATE SCHEMA IF NOT EXISTS PUBLIC;
USE SCHEMA PUBLIC;

-- 2. Warehouse (MEDIUM for data operations)
CREATE WAREHOUSE IF NOT EXISTS JIRA_DEMO_WH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;

-- 3. GPU Compute Pool (for training and inference)
CREATE COMPUTE POOL IF NOT EXISTS JIRA_TRAINING_POOL
    MIN_NODES = 1
    MAX_NODES = 1
    INSTANCE_FAMILY = GPU_NV_S
    AUTO_RESUME = TRUE
    AUTO_SUSPEND_SECS = 300;

-- 4. External Access Integration (for PyPI and HuggingFace)
CREATE OR REPLACE NETWORK RULE ALLOW_ALL_RULE
    MODE = EGRESS
    TYPE = HOST_PORT
    VALUE_LIST = ('0.0.0.0:443', '0.0.0.0:80');

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION ALLOW_ALL_EAI
    ALLOWED_NETWORK_RULES = (ALLOW_ALL_RULE)
    ENABLED = TRUE;

-- 5. Stages for artifacts
CREATE STAGE IF NOT EXISTS TRAINING_ARTIFACTS;
CREATE STAGE IF NOT EXISTS NOTEBOOKS;

-- 6. Sample JIRA Tickets Data (100 synthetic tickets)
CREATE OR REPLACE TABLE JIRA_TICKETS (
    ISSUE_KEY VARCHAR,
    ISSUE_TYPE VARCHAR,
    PRIORITY VARCHAR,
    STATUS VARCHAR,
    COMPONENT VARCHAR,
    SUMMARY VARCHAR,
    DESCRIPTION VARCHAR
);

-- Insert synthetic JIRA tickets across different types
INSERT INTO JIRA_TICKETS VALUES
-- BUGS (30)
('JIRA-001', 'BUG', 'P1', 'Open', 'Authentication', 'Login fails with SSO enabled', 'Users cannot log in when SSO is enabled. Error message shows timeout after 30 seconds.'),
('JIRA-002', 'BUG', 'P2', 'In Progress', 'Authentication', 'Password reset email not sent', 'Password reset functionality not sending emails to users. SMTP logs show connection refused.'),
('JIRA-003', 'BUG', 'P1', 'Open', 'Payments', 'Checkout fails on mobile Safari', 'Payment processing fails specifically on iOS Safari. Works on Chrome and Firefox.'),
('JIRA-004', 'BUG', 'P3', 'Resolved', 'UI', 'Button alignment broken on Firefox', 'Submit button misaligned by 10px on Firefox browser. CSS flexbox issue suspected.'),
('JIRA-005', 'BUG', 'P2', 'Open', 'API', 'Rate limiting not working correctly', 'API rate limits are not being enforced. Users can make unlimited requests.'),
('JIRA-006', 'BUG', 'P1', 'In Progress', 'Database', 'Query timeout on large datasets', 'Reports timing out when dataset exceeds 1M rows. Need query optimization.'),
('JIRA-007', 'BUG', 'P2', 'Open', 'Authentication', 'Session expires too quickly', 'User sessions expire after 5 minutes instead of configured 30 minutes.'),
('JIRA-008', 'BUG', 'P3', 'Open', 'UI', 'Dark mode colors incorrect', 'Some text is unreadable in dark mode due to low contrast ratios.'),
('JIRA-009', 'BUG', 'P1', 'Open', 'Payments', 'Duplicate charges on retry', 'Payment retries are creating duplicate charges. Need idempotency check.'),
('JIRA-010', 'BUG', 'P2', 'Resolved', 'Search', 'Search returns stale results', 'Search index not updating. Results are 24 hours behind actual data.'),
('JIRA-011', 'BUG', 'P2', 'Open', 'Authentication', 'MFA codes not validating', 'Time-based MFA codes rejected even when correct. Clock sync issue suspected.'),
('JIRA-012', 'BUG', 'P1', 'In Progress', 'API', 'Webhook deliveries failing', 'Webhook endpoints receiving 503 errors. Retry mechanism not working.'),
('JIRA-013', 'BUG', 'P3', 'Open', 'UI', 'Modal not closing on escape key', 'Accessibility issue - modal dialogs should close when pressing Escape.'),
('JIRA-014', 'BUG', 'P2', 'Open', 'Database', 'Connection pool exhausted', 'Database connections not being released properly. Pool exhausted after 1 hour.'),
('JIRA-015', 'BUG', 'P1', 'Open', 'Payments', 'Refund processing stuck', 'Refunds stuck in pending state. Payment provider API returning errors.'),
('JIRA-016', 'BUG', 'P2', 'Resolved', 'Authentication', 'OAuth callback URL mismatch', 'OAuth login failing due to redirect URI mismatch in production.'),
('JIRA-017', 'BUG', 'P3', 'Open', 'UI', 'Tooltip overlapping content', 'Help tooltips appearing behind other UI elements due to z-index.'),
('JIRA-018', 'BUG', 'P1', 'In Progress', 'Search', 'Full-text search crashes on special chars', 'Search crashes when query contains unicode or special characters.'),
('JIRA-019', 'BUG', 'P2', 'Open', 'API', 'Pagination returning duplicates', 'API pagination sometimes returns duplicate records across pages.'),
('JIRA-020', 'BUG', 'P2', 'Open', 'Database', 'Deadlock on concurrent updates', 'Concurrent updates to same record causing database deadlocks.'),
('JIRA-021', 'BUG', 'P1', 'Open', 'Authentication', 'JWT token not refreshing', 'Access tokens not refreshing before expiry causing logout.'),
('JIRA-022', 'BUG', 'P3', 'Resolved', 'UI', 'Form validation messages unclear', 'Error messages not specific enough for users to understand issue.'),
('JIRA-023', 'BUG', 'P2', 'Open', 'Payments', 'Currency conversion incorrect', 'Multi-currency payments using wrong exchange rates.'),
('JIRA-024', 'BUG', 'P1', 'In Progress', 'API', 'GraphQL query depth attack', 'No depth limiting on GraphQL queries allowing DoS attacks.'),
('JIRA-025', 'BUG', 'P2', 'Open', 'Search', 'Fuzzy search too aggressive', 'Fuzzy matching returning irrelevant results with low similarity.'),
('JIRA-026', 'BUG', 'P3', 'Open', 'UI', 'Print stylesheet missing', 'Printed pages missing styles and showing broken layout.'),
('JIRA-027', 'BUG', 'P1', 'Open', 'Database', 'Migration script failing', 'Database migration script failing on production with FK constraint.'),
('JIRA-028', 'BUG', 'P2', 'Resolved', 'Authentication', 'Remember me not persisting', 'Remember me checkbox not keeping users logged in across sessions.'),
('JIRA-029', 'BUG', 'P2', 'Open', 'Payments', 'Invoice PDF generation slow', 'PDF generation taking 30+ seconds for invoices with many line items.'),
('JIRA-030', 'BUG', 'P1', 'In Progress', 'API', 'CORS headers missing on errors', 'CORS headers not included in error responses causing frontend issues.'),

-- FEATURES (30)
('JIRA-031', 'FEATURE', 'P2', 'Open', 'Authentication', 'Add biometric login support', 'Implement Face ID and Touch ID authentication for mobile apps.'),
('JIRA-032', 'FEATURE', 'P1', 'In Progress', 'Payments', 'Support Apple Pay checkout', 'Add Apple Pay as payment method for faster mobile checkout.'),
('JIRA-033', 'FEATURE', 'P2', 'Open', 'UI', 'Implement dark mode toggle', 'Add user preference for dark/light mode with system default option.'),
('JIRA-034', 'FEATURE', 'P3', 'Open', 'Search', 'Add search filters by date', 'Allow users to filter search results by date range.'),
('JIRA-035', 'FEATURE', 'P1', 'Open', 'API', 'Implement GraphQL subscriptions', 'Add real-time updates via GraphQL subscriptions for live data.'),
('JIRA-036', 'FEATURE', 'P2', 'In Progress', 'Database', 'Add read replicas support', 'Scale read operations by supporting read replicas for reporting.'),
('JIRA-037', 'FEATURE', 'P2', 'Open', 'Authentication', 'Support passkey authentication', 'Implement WebAuthn passkeys for passwordless login.'),
('JIRA-038', 'FEATURE', 'P3', 'Open', 'UI', 'Add keyboard shortcuts', 'Implement keyboard shortcuts for power users to navigate faster.'),
('JIRA-039', 'FEATURE', 'P1', 'Open', 'Payments', 'Add subscription billing', 'Implement recurring billing with proration and plan changes.'),
('JIRA-040', 'FEATURE', 'P2', 'Open', 'Search', 'Implement semantic search', 'Use embeddings for semantic similarity search beyond keywords.'),
('JIRA-041', 'FEATURE', 'P2', 'In Progress', 'API', 'Add batch API endpoints', 'Support batch operations for bulk create/update/delete.'),
('JIRA-042', 'FEATURE', 'P3', 'Open', 'UI', 'Implement drag and drop', 'Add drag and drop for file uploads and list reordering.'),
('JIRA-043', 'FEATURE', 'P1', 'Open', 'Database', 'Implement soft deletes', 'Add soft delete support for data recovery and audit trails.'),
('JIRA-044', 'FEATURE', 'P2', 'Open', 'Authentication', 'Add SSO with Okta', 'Integrate Okta as identity provider for enterprise SSO.'),
('JIRA-045', 'FEATURE', 'P2', 'Open', 'Payments', 'Support crypto payments', 'Add Bitcoin and Ethereum payment options via Coinbase.'),
('JIRA-046', 'FEATURE', 'P3', 'In Progress', 'Search', 'Add saved searches', 'Allow users to save and name frequently used search queries.'),
('JIRA-047', 'FEATURE', 'P1', 'Open', 'API', 'Implement API versioning', 'Add URL-based API versioning for backward compatibility.'),
('JIRA-048', 'FEATURE', 'P2', 'Open', 'UI', 'Add customizable dashboard', 'Let users customize dashboard widgets and layout.'),
('JIRA-049', 'FEATURE', 'P2', 'Open', 'Database', 'Add data archival system', 'Implement automatic archival of old data to cold storage.'),
('JIRA-050', 'FEATURE', 'P1', 'In Progress', 'Authentication', 'Implement role-based access', 'Add RBAC with custom roles and granular permissions.'),
('JIRA-051', 'FEATURE', 'P3', 'Open', 'Payments', 'Add payment analytics', 'Dashboard showing payment trends, failures, and revenue.'),
('JIRA-052', 'FEATURE', 'P2', 'Open', 'Search', 'Implement typeahead suggestions', 'Show search suggestions as user types in search box.'),
('JIRA-053', 'FEATURE', 'P2', 'Open', 'API', 'Add webhook management UI', 'UI for users to manage webhook endpoints and view logs.'),
('JIRA-054', 'FEATURE', 'P1', 'Open', 'UI', 'Implement accessibility audit', 'Ensure WCAG 2.1 AA compliance across all pages.'),
('JIRA-055', 'FEATURE', 'P3', 'Open', 'Database', 'Add query performance insights', 'Dashboard showing slow queries and optimization suggestions.'),
('JIRA-056', 'FEATURE', 'P2', 'In Progress', 'Authentication', 'Add session management UI', 'Let users view and revoke active sessions from settings.'),
('JIRA-057', 'FEATURE', 'P2', 'Open', 'Payments', 'Implement payment retry logic', 'Automatic retry with exponential backoff for failed payments.'),
('JIRA-058', 'FEATURE', 'P1', 'Open', 'Search', 'Add search analytics', 'Track popular searches and zero-result queries for insights.'),
('JIRA-059', 'FEATURE', 'P3', 'Open', 'API', 'Add request/response logging', 'Detailed API logging for debugging and compliance.'),
('JIRA-060', 'FEATURE', 'P2', 'Open', 'UI', 'Implement onboarding wizard', 'Step-by-step wizard for new user onboarding.'),

-- TASKS (20)
('JIRA-061', 'TASK', 'P2', 'Open', 'Infrastructure', 'Upgrade to Node 20 LTS', 'Upgrade Node.js runtime from 18 to 20 LTS for performance.'),
('JIRA-062', 'TASK', 'P3', 'In Progress', 'Documentation', 'Update API documentation', 'Refresh API docs with new endpoints and examples.'),
('JIRA-063', 'TASK', 'P2', 'Open', 'Infrastructure', 'Set up staging environment', 'Create staging environment mirroring production setup.'),
('JIRA-064', 'TASK', 'P1', 'Open', 'Security', 'Conduct penetration testing', 'Annual security audit and penetration testing.'),
('JIRA-065', 'TASK', 'P2', 'Resolved', 'Infrastructure', 'Configure CDN for static assets', 'Set up CloudFront for faster static asset delivery.'),
('JIRA-066', 'TASK', 'P3', 'Open', 'Documentation', 'Create user guides', 'Write end-user documentation for new features.'),
('JIRA-067', 'TASK', 'P2', 'In Progress', 'Infrastructure', 'Implement blue-green deployments', 'Set up zero-downtime deployment pipeline.'),
('JIRA-068', 'TASK', 'P1', 'Open', 'Security', 'Update SSL certificates', 'Renew expiring SSL certificates before deadline.'),
('JIRA-069', 'TASK', 'P2', 'Open', 'Infrastructure', 'Set up log aggregation', 'Centralize logs with ELK stack for easier debugging.'),
('JIRA-070', 'TASK', 'P3', 'Open', 'Documentation', 'Document deployment process', 'Create runbook for deployment and rollback procedures.'),
('JIRA-071', 'TASK', 'P2', 'Resolved', 'Security', 'Implement secrets rotation', 'Set up automatic rotation for API keys and secrets.'),
('JIRA-072', 'TASK', 'P2', 'Open', 'Infrastructure', 'Configure auto-scaling', 'Set up auto-scaling policies based on CPU and memory.'),
('JIRA-073', 'TASK', 'P1', 'In Progress', 'Security', 'SOC 2 compliance audit', 'Prepare documentation and controls for SOC 2 audit.'),
('JIRA-074', 'TASK', 'P3', 'Open', 'Documentation', 'Create architecture diagrams', 'Document system architecture with up-to-date diagrams.'),
('JIRA-075', 'TASK', 'P2', 'Open', 'Infrastructure', 'Implement circuit breakers', 'Add circuit breaker pattern for external service calls.'),
('JIRA-076', 'TASK', 'P2', 'Open', 'Security', 'Review IAM policies', 'Audit and tighten IAM policies following least privilege.'),
('JIRA-077', 'TASK', 'P3', 'Resolved', 'Infrastructure', 'Set up monitoring alerts', 'Configure PagerDuty alerts for critical metrics.'),
('JIRA-078', 'TASK', 'P1', 'Open', 'Security', 'Implement audit logging', 'Add comprehensive audit trail for compliance.'),
('JIRA-079', 'TASK', 'P2', 'Open', 'Documentation', 'Write runbooks for incidents', 'Create incident response playbooks for on-call team.'),
('JIRA-080', 'TASK', 'P2', 'In Progress', 'Infrastructure', 'Migrate to Kubernetes', 'Move from ECS to Kubernetes for better orchestration.'),

-- IMPROVEMENTS (20)
('JIRA-081', 'IMPROVEMENT', 'P2', 'Open', 'Performance', 'Optimize image loading', 'Implement lazy loading and WebP format for images.'),
('JIRA-082', 'IMPROVEMENT', 'P3', 'In Progress', 'Performance', 'Add Redis caching layer', 'Cache frequently accessed data in Redis.'),
('JIRA-083', 'IMPROVEMENT', 'P2', 'Open', 'Performance', 'Reduce bundle size', 'Code splitting and tree shaking to reduce JS bundle.'),
('JIRA-084', 'IMPROVEMENT', 'P1', 'Open', 'Performance', 'Optimize database queries', 'Add indexes and rewrite slow queries identified in logs.'),
('JIRA-085', 'IMPROVEMENT', 'P2', 'Open', 'UX', 'Improve error messages', 'Make error messages more helpful with suggested actions.'),
('JIRA-086', 'IMPROVEMENT', 'P3', 'Resolved', 'Performance', 'Enable gzip compression', 'Enable gzip for API responses to reduce bandwidth.'),
('JIRA-087', 'IMPROVEMENT', 'P2', 'Open', 'UX', 'Streamline checkout flow', 'Reduce checkout steps from 5 to 3 for better conversion.'),
('JIRA-088', 'IMPROVEMENT', 'P2', 'In Progress', 'Performance', 'Implement connection pooling', 'Use connection pooling for database connections.'),
('JIRA-089', 'IMPROVEMENT', 'P3', 'Open', 'UX', 'Add loading skeletons', 'Replace spinners with skeleton screens for better UX.'),
('JIRA-090', 'IMPROVEMENT', 'P1', 'Open', 'Performance', 'Add query result caching', 'Cache expensive query results with TTL-based invalidation.'),
('JIRA-091', 'IMPROVEMENT', 'P2', 'Open', 'UX', 'Improve mobile navigation', 'Redesign mobile nav for easier thumb access.'),
('JIRA-092', 'IMPROVEMENT', 'P3', 'Open', 'Performance', 'Optimize API response size', 'Add field selection to reduce payload sizes.'),
('JIRA-093', 'IMPROVEMENT', 'P2', 'Resolved', 'UX', 'Add breadcrumb navigation', 'Help users understand location in app hierarchy.'),
('JIRA-094', 'IMPROVEMENT', 'P2', 'Open', 'Performance', 'Implement request deduplication', 'Dedupe identical concurrent requests to reduce load.'),
('JIRA-095', 'IMPROVEMENT', 'P1', 'In Progress', 'UX', 'Reduce form friction', 'Add autofill, inline validation, and smart defaults.'),
('JIRA-096', 'IMPROVEMENT', 'P3', 'Open', 'Performance', 'Add database query timeout', 'Set query timeouts to prevent runaway queries.'),
('JIRA-097', 'IMPROVEMENT', 'P2', 'Open', 'UX', 'Improve empty states', 'Add helpful empty states with CTAs instead of blank pages.'),
('JIRA-098', 'IMPROVEMENT', 'P2', 'Open', 'Performance', 'Optimize webhook delivery', 'Batch webhook deliveries and add retry queue.'),
('JIRA-099', 'IMPROVEMENT', 'P3', 'Resolved', 'UX', 'Add confirmation dialogs', 'Confirm destructive actions before executing.'),
('JIRA-100', 'IMPROVEMENT', 'P1', 'Open', 'Performance', 'Implement query batching', 'Batch GraphQL queries to reduce round trips.');

-- 7. Upload notebook to stage (run this from snowsql or adjust path)
-- PUT file://jira_embedding_finetuning_demo.ipynb @NOTEBOOKS AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

-- 8. Create notebook from stage
-- CREATE OR REPLACE NOTEBOOK JIRA_FINETUNING_DEMO
--     FROM '@NOTEBOOKS'
--     MAIN_FILE = 'jira_embedding_finetuning_demo.ipynb'
--     QUERY_WAREHOUSE = 'JIRA_DEMO_WH';

-- ALTER NOTEBOOK JIRA_FINETUNING_DEMO 
-- SET EXTERNAL_ACCESS_INTEGRATIONS = ('ALLOW_ALL_EAI');

-- ============================================================================
-- Verification Queries
-- ============================================================================
SELECT 'JIRA_TICKETS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM JIRA_TICKETS;
SELECT ISSUE_TYPE, COUNT(*) AS COUNT FROM JIRA_TICKETS GROUP BY ISSUE_TYPE ORDER BY COUNT DESC;
SHOW COMPUTE POOLS LIKE 'JIRA%';
SHOW WAREHOUSES LIKE 'JIRA%';

PRINT '====================================';
PRINT 'Setup complete! Next steps:';
PRINT '1. Upload notebook: PUT file://jira_embedding_finetuning_demo.ipynb @NOTEBOOKS';
PRINT '2. Create notebook in Snowsight or via SQL';
PRINT '3. Open notebook and run cells in order';
PRINT '====================================';
