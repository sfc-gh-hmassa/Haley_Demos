-- The before/after app as a Snowpark Container Services service. deploy.sh runs this for you.
-- It uses the stock python:3.12-slim image, mounts the app code from the APP_CODE stage, and calls
-- Cortex with the service's own token (no secrets in the container).
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
        DEMO_WAREHOUSE: COMPUTE_WH
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

-- Useful afterwards:
--   SHOW ENDPOINTS IN SERVICE MULTIAGENT_DEMO.DEMO.BEFORE_AFTER_APP;          -- the app URL
--   SELECT SYSTEM$GET_SERVICE_STATUS('MULTIAGENT_DEMO.DEMO.BEFORE_AFTER_APP');
--   SELECT SYSTEM$GET_SERVICE_LOGS('MULTIAGENT_DEMO.DEMO.BEFORE_AFTER_APP', 0, 'app', 100);
--   GRANT SERVICE ROLE MULTIAGENT_DEMO.DEMO.BEFORE_AFTER_APP!ALL_ENDPOINTS_USAGE TO ROLE <role>;  -- share it
--   ALTER SERVICE MULTIAGENT_DEMO.DEMO.BEFORE_AFTER_APP SUSPEND;               -- stop cost
--   ALTER COMPUTE POOL MULTIAGENT_DEMO_POOL SUSPEND;
