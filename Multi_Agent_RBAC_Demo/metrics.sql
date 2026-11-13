-- Before vs after metrics for every question asked in the demo app.
-- Run in a Snowsight worksheet. The app logs each run to DEMO_RUNS; billed credits come from
-- SNOWFLAKE.ACCOUNT_USAGE (which can lag up to ~1 hour), matched on the specialists' thread ids.
USE SCHEMA MULTIAGENT_DEMO.DEMO;

-- 1. The comparison (what the app's scoreboard shows)
SELECT
  mode,
  COUNT(*)                                        AS questions,
  ROUND(AVG(est_credits), 3)                      AS credits_per_question,
  ROUND(AVG(est_credits) * 1000, 0)               AS credits_per_1000_questions,
  ROUND(MEDIAN(seconds), 1)                       AS median_seconds,
  ROUND(AVG(seconds), 1)                          AS avg_seconds,
  ROUND(AVG(orchestrator_tokens), 0)              AS orchestrator_tokens,
  ROUND(AVG(full_price_tokens), 0)                AS full_price_tokens,
  ROUND(AVG(kb_to_orchestrator), 1)               AS kb_sent_to_orchestrator,
  ROUND(AVG(IFF(charts > 0, 1, 0)) * 100, 0)      AS pct_answers_with_chart
FROM DEMO_RUNS
GROUP BY mode
ORDER BY mode DESC;   -- before, then after

-- 2. Side by side with the percentage change
WITH m AS (
  SELECT mode, AVG(est_credits) cr, MEDIAN(seconds) s, AVG(orchestrator_tokens) ot, AVG(kb_to_orchestrator) kb
  FROM DEMO_RUNS GROUP BY mode)
SELECT
  ROUND(b.cr, 3) AS before_credits, ROUND(a.cr, 3) AS after_credits,
  ROUND((1 - a.cr / b.cr) * 100, 0) || '% lower' AS cost_change,
  ROUND(b.s, 0) AS before_median_s, ROUND(a.s, 0) AS after_median_s,
  ROUND((1 - a.s / b.s) * 100, 0) || '% lower' AS latency_change,
  ROUND((1 - a.ot / b.ot) * 100, 0) || '% lower' AS orchestrator_token_change,
  ROUND((1 - a.kb / b.kb) * 100, 0) || '% lower' AS data_to_orchestrator_change
FROM m b JOIN m a ON b.mode = 'before' AND a.mode = 'after';

-- 3. Billed credits for the specialist agent runs (matches the app's estimate; lags up to ~1 hour)
WITH runs AS (
  SELECT r.mode, r.run_at, TRIM(t.value) AS thread_id
  FROM DEMO_RUNS r, LATERAL SPLIT_TO_TABLE(r.specialist_thread_ids, ',') t)
SELECT
  runs.mode,
  COUNT(DISTINCT runs.run_at)                                AS questions,
  ROUND(SUM(u.token_credits) / COUNT(DISTINCT runs.run_at), 3) AS billed_specialist_credits_per_question
FROM runs
JOIN SNOWFLAKE.ACCOUNT_USAGE.CORTEX_AGENT_USAGE_HISTORY u
  ON u.thread_id::STRING = runs.thread_id
GROUP BY runs.mode
ORDER BY runs.mode DESC;

-- 4. Every run, newest first
SELECT run_at, mode, question, specialists, ROUND(est_credits, 4) AS credits, seconds,
       orchestrator_tokens, kb_to_orchestrator, charts
FROM DEMO_RUNS ORDER BY run_at DESC LIMIT 50;

-- Reset the scoreboard before a customer session:
-- TRUNCATE TABLE DEMO_RUNS;
