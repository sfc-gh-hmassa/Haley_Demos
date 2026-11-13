#!/usr/bin/env bash
# One-command setup: builds the demo objects and runs the before/after app in Snowflake.
#
#   export SNOWFLAKE_ACCOUNT=<org>-<account> SNOWFLAKE_USER=<user> SNOWFLAKE_PAT=<programmatic access token>
#   ./deploy.sh <warehouse>
#
# Needs: the Snowflake CLI (`snow`) and `crane` (brew install crane) or Docker.
# Use a role that can create databases, agents, compute pools and integrations (e.g. ACCOUNTADMIN).
# Creates everything in MULTIAGENT_DEMO.DEMO and prints the app URL at the end.
set -euo pipefail

WH="${1:?usage: ./deploy.sh <warehouse>}"
: "${SNOWFLAKE_ACCOUNT:?set SNOWFLAKE_ACCOUNT}" "${SNOWFLAKE_USER:?set SNOWFLAKE_USER}" "${SNOWFLAKE_PAT:?set SNOWFLAKE_PAT}"
HERE="$(cd "$(dirname "$0")" && pwd)"
HOST="$(echo "$SNOWFLAKE_ACCOUNT" | tr '[:upper:]_' '[:lower:]-').snowflakecomputing.com"
TOKEN_FILE="$(mktemp)"; chmod 600 "$TOKEN_FILE"; trap 'rm -f "$TOKEN_FILE"' EXIT
printf '%s' "$SNOWFLAKE_PAT" > "$TOKEN_FILE"
SQL() {
  snow sql --temporary-connection --account "$SNOWFLAKE_ACCOUNT" --host "$HOST" --user "$SNOWFLAKE_USER" \
    --authenticator PROGRAMMATIC_ACCESS_TOKEN --token-file-path "$TOKEN_FILE" --warehouse "$WH" \
    ${SNOWFLAKE_ROLE:+--role "$SNOWFLAKE_ROLE"} "$@"
}

echo "==> 1/5  Creating the specialist agents, MCP server and data (setup.sql)"
sed "s/COMPUTE_WH/$WH/g" "$HERE/setup.sql" > /tmp/multiagent_setup.sql
SQL -f /tmp/multiagent_setup.sql > /dev/null

echo "==> 2/5  Creating the image repository, code stage, compute pool and PyPI access"
sed "s/COMPUTE_WH/$WH/g" "$HERE/app/spcs_infra.sql" > /tmp/multiagent_infra.sql
SQL -f /tmp/multiagent_infra.sql > /dev/null

echo "==> 3/5  Copying the base Python image into Snowflake's registry (no build needed)"
REPO_URL="$(SQL -q "SHOW IMAGE REPOSITORIES LIKE 'APP_IMAGES' IN SCHEMA MULTIAGENT_DEMO.DEMO" --format json \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)[0]["repository_url"])')"
REGISTRY="${REPO_URL%%/*}"
if command -v crane > /dev/null; then
  crane auth login "$REGISTRY" -u "$SNOWFLAKE_USER" --password-stdin < "$TOKEN_FILE"
  crane copy --platform linux/amd64 python:3.12-slim "$REPO_URL/python:3.12-slim"
else
  docker login "$REGISTRY" -u "$SNOWFLAKE_USER" --password-stdin < "$TOKEN_FILE"
  docker pull --platform linux/amd64 python:3.12-slim
  docker tag python:3.12-slim "$REPO_URL/python:3.12-slim"
  docker push "$REPO_URL/python:3.12-slim"
fi

echo "==> 4/5  Uploading the app code"
SQL -q "PUT 'file://$HERE/app/server.py' @MULTIAGENT_DEMO.DEMO.APP_CODE AUTO_COMPRESS=FALSE OVERWRITE=TRUE" > /dev/null
SQL -q "PUT 'file://$HERE/app/index.html' @MULTIAGENT_DEMO.DEMO.APP_CODE AUTO_COMPRESS=FALSE OVERWRITE=TRUE" > /dev/null

echo "==> 5/5  Starting the app service"
sed "s/COMPUTE_WH/$WH/g" "$HERE/app/spcs_service.sql" > /tmp/multiagent_service.sql
SQL -f /tmp/multiagent_service.sql > /dev/null
# The endpoint sign-in checks your user's DEFAULT role, so give that role access too.
DEFAULT_ROLE="$(SQL -q "SHOW USERS LIKE '$SNOWFLAKE_USER'" --format json \
  | python3 -c 'import sys,json; r=json.load(sys.stdin); print(r[0]["default_role"] if r else "")')"
if [ -n "$DEFAULT_ROLE" ] && [ "$DEFAULT_ROLE" != "null" ]; then
  SQL -q "GRANT USAGE ON DATABASE MULTIAGENT_DEMO TO ROLE $DEFAULT_ROLE;
          GRANT USAGE ON SCHEMA MULTIAGENT_DEMO.DEMO TO ROLE $DEFAULT_ROLE;
          GRANT SERVICE ROLE MULTIAGENT_DEMO.DEMO.BEFORE_AFTER_APP!ALL_ENDPOINTS_USAGE TO ROLE $DEFAULT_ROLE;" > /dev/null
fi

echo "    Waiting for the app URL (first start takes 2-4 minutes)..."
for _ in $(seq 1 40); do
  URL="$(SQL -q "SHOW ENDPOINTS IN SERVICE MULTIAGENT_DEMO.DEMO.BEFORE_AFTER_APP" --format json \
    | python3 -c 'import sys,json; print(json.load(sys.stdin)[0]["ingress_url"])')"
  case "$URL" in *snowflakecomputing.app*) break ;; esac
  sleep 15
done
echo
echo "Done. Open: https://$URL"
echo "Sign in with your Snowflake user. Metrics: run metrics.sql in a worksheet."
echo "When finished: ALTER SERVICE MULTIAGENT_DEMO.DEMO.BEFORE_AFTER_APP SUSPEND; ALTER COMPUTE POOL MULTIAGENT_DEMO_POOL SUSPEND;"
