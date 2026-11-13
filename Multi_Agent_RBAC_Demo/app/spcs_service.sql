-- Run the before/after React app in Snowflake as a Snowpark Container Services service.
-- No Docker build: the service uses the stock python:3.12-slim image, mounts the app code from a stage,
-- and installs FastAPI when it starts. It calls Cortex with the service's own token (no PAT in the image).
--
-- Prereqs: setup.sql has been run (MULTIAGENT_DEMO.DEMO exists), and the base image is in the repository.
-- Copy it once with crane (or docker pull/tag/push):
--   crane auth login <org>-<account>.registry.snowflakecomputing.com -u <user> --password-stdin   # PAT on stdin
--   crane copy --platform linux/amd64 python:3.12-slim \
--     <org>-<account>.registry.snowflakecomputing.com/multiagent_demo/demo/app_images/python:3.12-slim
-- Upload the app code (from the app/ folder):
--   PUT file://server.py  @MULTIAGENT_DEMO.DEMO.APP_CODE AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
--   PUT file://index.html @MULTIAGENT_DEMO.DEMO.APP_CODE AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

CREATE IMAGE REPOSITORY IF NOT EXISTS MULTIAGENT_DEMO.DEMO.APP_IMAGES;
CREATE STAGE IF NOT EXISTS MULTIAGENT_DEMO.DEMO.APP_CODE
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE') DIRECTORY = (ENABLE = TRUE);

CREATE COMPUTE POOL IF NOT EXISTS MULTIAGENT_DEMO_POOL
  MIN_NODES = 1 MAX_NODES = 1 INSTANCE_FAMILY = CPU_X64_XS
  AUTO_SUSPEND_SECS = 3600 AUTO_RESUME = TRUE;

-- The container installs packages from PyPI on startup.
CREATE NETWORK RULE IF NOT EXISTS MULTIAGENT_DEMO.DEMO.PYPI_RULE
  MODE = EGRESS TYPE = HOST_PORT VALUE_LIST = ('pypi.org', 'files.pythonhosted.org');
CREATE EXTERNAL ACCESS INTEGRATION IF NOT EXISTS MULTIAGENT_DEMO_PYPI_EAI
  ALLOWED_NETWORK_RULES = (MULTIAGENT_DEMO.DEMO.PYPI_RULE) ENABLED = TRUE;

CREATE SERVICE IF NOT EXISTS MULTIAGENT_DEMO.DEMO.BEFORE_AFTER_APP
  IN COMPUTE POOL MULTIAGENT_DEMO_POOL
  FROM SPECIFICATION $$
spec:
  containers:
    - name: app
      image: /multiagent_demo/demo/app_images/python:3.12-slim
      command:
        - /bin/sh
        - -c
        - pip install --no-cache-dir fastapi==0.115.* uvicorn==0.32.* requests==2.32.* && exec python -m uvicorn server:app --app-dir /app --host 0.0.0.0 --port 8080
      env:
        DEMO_DB: MULTIAGENT_DEMO
        DEMO_SCHEMA: DEMO
      volumeMounts:
        - name: code
          mountPath: /app
      readinessProbe:
        port: 8080
        path: /
  volumes:
    - name: code
      source: "@MULTIAGENT_DEMO.DEMO.APP_CODE"
  endpoints:
    - name: web
      port: 8080
      public: true
$$
  EXTERNAL_ACCESS_INTEGRATIONS = (MULTIAGENT_DEMO_PYPI_EAI)
  MIN_INSTANCES = 1 MAX_INSTANCES = 1;

-- Wait for READY, then open ingress_url and sign in with your Snowflake user:
SELECT SYSTEM$GET_SERVICE_STATUS('MULTIAGENT_DEMO.DEMO.BEFORE_AFTER_APP');
SHOW ENDPOINTS IN SERVICE MULTIAGENT_DEMO.DEMO.BEFORE_AFTER_APP;

-- After changing server.py or index.html: PUT the files again, then restart the container.
-- ALTER SERVICE MULTIAGENT_DEMO.DEMO.BEFORE_AFTER_APP SUSPEND;
-- ALTER SERVICE MULTIAGENT_DEMO.DEMO.BEFORE_AFTER_APP RESUME;

-- Share with another role (they also need USAGE on the database and schema):
-- GRANT SERVICE ROLE MULTIAGENT_DEMO.DEMO.BEFORE_AFTER_APP!ALL_ENDPOINTS_USAGE TO ROLE <role>;

-- Stop paying for it when you're done:
-- ALTER SERVICE MULTIAGENT_DEMO.DEMO.BEFORE_AFTER_APP SUSPEND;
-- ALTER COMPUTE POOL MULTIAGENT_DEMO_POOL SUSPEND;
