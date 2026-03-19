# Cortex Code CLI — Snowday Workshop Repo

Materials for a hands-on workshop using the **Cortex Code CLI** with Snowflake.

## What’s in this repo

- `SetUp/`
  - `00_snowday_setup.sql` — creates workshop database/schema/warehouse (run once)
  - `00_sample_data.sql` — loads sample source tables + small evaluation question sets
- `Participant_Materials/`
  - `Connecting to Cortex Code CLI .pdf` — CLI connection / getting started guide
  - `BestPracticesCortexCode.pdf` — usage tips + best practices
  - `sample_business_requirements.xlsx` — sample requirements used in exercises
- `Presentations/`
  - `Snowday Starter Deck .pdf` — slide deck for the session
- `Cortex Code CLI.pdf` — CLI reference deck/handout

## Prerequisites

- Access to a Snowflake account where you can create objects (database/schema/warehouse) or a pre-provisioned workshop role with equivalent privileges.
- Cortex Code CLI installed and able to connect to Snowflake (see `Participant_Materials/Connecting to Cortex Code CLI .pdf`).

## Quickstart (Snowflake setup)

1. Open and run:
   - `SetUp/00_snowday_setup.sql`

2. Then load sample data by running:
   - `SetUp/00_sample_data.sql`

Notes:
- The setup script uses `USE ROLE SYSADMIN;` by default. If your environment requires a different role, update accordingly.
- `00_snowday_setup.sql` includes an **optional** section to create/grant a dedicated workshop role (commented out).

## Suggested flow for the workshop

1. Confirm CLI connectivity (PDF).
2. Run Snowflake setup + sample data scripts.
3. Use the slide deck to guide exercises and refer to the CLI reference as needed.

## Troubleshooting

- If object creation fails, verify your active role has privileges to create the database/schema/warehouse used in `SetUp/00_snowday_setup.sql`.
- If queries fail due to missing tables, re-run `SetUp/00_sample_data.sql` and confirm the warehouse/database/schema context.
