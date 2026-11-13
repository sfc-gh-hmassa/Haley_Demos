#!/usr/bin/env bash
# Run the before/after app on your laptop instead of in Snowflake.
#
#   export SNOWFLAKE_ACCOUNT=<org>-<account> SNOWFLAKE_PAT=<programmatic access token> DEMO_WAREHOUSE=<warehouse>
#   ./run_local.sh                     # then open http://localhost:8000
#
# setup.sql must have been run first (./deploy.sh does that, or paste it into a worksheet).
set -euo pipefail
: "${SNOWFLAKE_ACCOUNT:?set SNOWFLAKE_ACCOUNT}" "${SNOWFLAKE_PAT:?set SNOWFLAKE_PAT}" "${DEMO_WAREHOUSE:?set DEMO_WAREHOUSE}"
HERE="$(cd "$(dirname "$0")" && pwd)"
python3 -m pip install -q -r "$HERE/requirements.txt"
echo "Open http://localhost:8000"
exec python3 -m uvicorn server:app --app-dir "$HERE/app" --port 8000
