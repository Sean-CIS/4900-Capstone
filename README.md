# CyberSafe LA Clinic Operations Database

A Dockerized PostgreSQL 15 database for the CyberSafe LA cybersecurity clinic operations, built as part of the CIS 4900 capstone project (Data Analyst track) at Cal State LA, Summer 2026.

## What This Is

CyberSafe LA is a university-run cybersecurity clinic that provides free advisory-only cybersecurity assessments to small businesses in the greater Los Angeles area. This repository contains the complete database infrastructure for tracking clinic operations: business clients, consultant assignments, engagement lifecycles, cybersecurity questionnaire responses, knowledge base findings, partner referrals, and audit logging.

The database runs inside Docker Compose so every team member gets an identical PostgreSQL environment without manually installing PostgreSQL on Windows.

## Architecture

```
Docker Compose (compose.yaml)
  |
  |-- PostgreSQL 15 Alpine (cybersafe_postgres)
  |     Port 5432
  |     Volume: pgdata
  |
  |-- Flyway 12.7.0 (schema migrations)
  |     Reads db/migrations/V001-V005
  |     Runs once, then exits
  |
  |-- PostgREST (REST API layer)
        Port 3000
        Exposes tables + views as JSON endpoints
```

**Services:**

- **PostgreSQL 15-Alpine** -- the database engine, with a persistent Docker volume for data
- **Flyway 12.7.0** -- version-controlled schema migrations (V001 through V005), runs on startup and exits
- **PostgREST** -- auto-generates a RESTful JSON API from the PostgreSQL schema, accessible at `http://localhost:3000`

## Database Schema (14 tables)

| Table                    | Purpose                                        |
|--------------------------|-------------------------------------------------|
| business                 | Client businesses receiving assessments         |
| contact                  | Business point-of-contact records               |
| cohort                   | Academic term groupings for consultants         |
| consultant               | Student consultants with competency levels      |
| faculty_advisor          | Faculty overseeing engagements                  |
| industry_mentor          | Industry mentors assigned to engagements        |
| mou                      | Memoranda of understanding per business         |
| partner                  | Referral and community partner organizations    |
| referral                 | Partner-to-business referral tracking           |
| engagement               | Full engagement lifecycle (Intake to Closed)    |
| assignment               | Consultant-to-engagement assignments            |
| questionnaire_response   | Cybersecurity intake questionnaire results      |
| knowledge_base_entry     | Findings, severity, remediation, DBIR refs      |
| audit_log_entry          | Immutable audit trail (INSERT-only for app role)|

## Operational Views

| View                                | Purpose                                    |
|-------------------------------------|--------------------------------------------|
| v_active_engagements_by_status      | Engagement counts grouped by status        |
| v_referral_conversion_by_partner    | Partner referral-to-engagement conversion  |
| v_consultant_workload               | Consultant assignment and hours summary    |
| v_questionnaire_risk_summary        | Risk band distribution from questionnaires |

## Role-Based Access Control

| Role            | Permissions                                                        |
|-----------------|--------------------------------------------------------------------|
| cybersafe_admin | Full access (database owner)                                       |
| cybersafe_read  | SELECT only on all tables and views                                |
| cybersafe_app   | SELECT/INSERT/UPDATE on data tables, INSERT-only on audit_log_entry|

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running
- PowerShell (Windows) or Bash (macOS/Linux)
- `curl` available in your terminal

## Quickstart

```powershell
# 1. Clone the repository
git clone https://github.com/<your-username>/cybersafe-la-db.git
cd cybersafe-la-db

# 2. Create your local .env from the template
Copy-Item .env.example .env

# 3. Start PostgreSQL
docker compose up -d db

# 4. Run Flyway migrations (creates tables, triggers, roles, views, seed data)
docker compose run --rm flyway

# 5. Start the PostgREST API
docker compose up -d postgrest

# 6. Test it
curl.exe http://localhost:3000/business?limit=1
```

Or use the one-command rebuild:

```powershell
powershell -ExecutionPolicy Bypass -File .\db\scripts\rebuild.ps1
```

## Scripts

| Script                     | Purpose                                            |
|----------------------------|----------------------------------------------------|
| `db/scripts/rebuild.ps1`   | Tear down, rebuild, and restart everything          |
| `db/scripts/rebuild.sh`    | Same as above for Bash (Linux/macOS)                |
| `db/scripts/test.ps1`      | Run all evidence checks (tables, views, roles, API) |
| `db/scripts/backup.ps1`    | pg_dump to backups/cybersafe_la_backup.sql           |
| `db/scripts/restore.ps1`   | Clean restore from backup file                      |

## API Documentation

See [api/openapi.yaml](api/openapi.yaml) for the OpenAPI 3.0.3 specification covering all table endpoints and operational view endpoints. See [api/README.md](api/README.md) for endpoint details.

## Project File Structure

```
cybersafe-la-db/
  compose.yaml                              # Docker Compose services
  .env.example                              # Environment variable template
  .gitignore                                # Git ignore rules
  README.md                                 # This file
  api/
    openapi.yaml                            # OpenAPI 3.0.3 spec
    README.md                               # API endpoint docs
  backups/
    .gitkeep                                # Placeholder (backups are gitignored)
  db/
    migrations/
      V001__create_schema.sql               # Tables and indexes
      V002__timestamps_soft_delete.sql      # updated_at triggers
      V003__roles_permissions.sql           # PostgreSQL roles
      V004__views.sql                       # Operational views
      V005__seed_data.sql                   # Fake demo seed data
    scripts/
      rebuild.ps1                           # One-command rebuild (PowerShell)
      rebuild.sh                            # One-command rebuild (Bash)
      test.ps1                              # Evidence test runner
      backup.ps1                            # Database backup
      restore.ps1                           # Database restore
  docs/
    docker-runbook.md                       # Teammate-facing operations guide
    test-evidence.md                        # Evidence checklist
    development-guide.md                    # Step-by-step build instructions
    screenshots/
      final-package-inventory-check.png     # File inventory verification
      final-docker-compose-health.png       # Docker version and container status
      final-postgresql-version-connection.png # PostgreSQL version and connection
      final-flyway-migration-history.png    # Flyway migration history
      final-table-creation-proof.png        # Table list verification
      final-operational-views-proof.png     # View list verification
      final-seed-data-row-counts.png        # All 14 table row counts
      final-postgrest-api-route-proof.png   # All API route checks (10 endpoints)
      final-openapi-documentation-proof.png # OpenAPI spec pattern checks
      final-role-permission-proof.png       # RBAC permission test output
      final-backup-proof.png               # Backup file evidence
      final-restore-proof.png              # Restore output evidence
      final-runbook-proof.png              # Runbook content checks
      final-test-evidence-proof.png        # Evidence checklist checks
      final-permission-tests-output.txt    # Permission test command output
      final-backup-output.txt              # Backup command output
      final-restore-output.txt             # Restore command output
      final-verification-transcript.txt    # Full PowerShell transcript
```

## Evidence Screenshots

The `docs/screenshots/` directory contains 14 PNG screenshots and 4 text output files that serve as proof-of-work evidence for every component of the database build. Each screenshot was captured by running a specific proof command in PowerShell and using Win + Shift + S to capture the output. The exact commands used are documented in [Step 36C of the Development Guide](docs/development-guide.md#step-36c-required-screenshots-with-proof-commands).

| Screenshot | What It Proves |
|------------|---------------|
| final-package-inventory-check.png | All 18 required project files exist |
| final-docker-compose-health.png | Docker Desktop running, containers healthy |
| final-postgresql-version-connection.png | PostgreSQL 15 accepting connections |
| final-flyway-migration-history.png | All 5 migrations applied successfully |
| final-table-creation-proof.png | All 14 tables created in the database |
| final-operational-views-proof.png | All 4 operational views created |
| final-seed-data-row-counts.png | 20 demo rows per table loaded correctly |
| final-postgrest-api-route-proof.png | All 10 API endpoints responding with JSON |
| final-openapi-documentation-proof.png | OpenAPI spec covers all endpoints |
| final-role-permission-proof.png | RBAC roles enforced (read-only denied inserts, app role denied audit updates) |
| final-backup-proof.png | pg_dump backup file created successfully |
| final-restore-proof.png | Clean restore completed, data intact |
| final-runbook-proof.png | Runbook covers all required operations |
| final-test-evidence-proof.png | Evidence checklist covers all required sections |

## Documentation

- [Docker Runbook](docs/docker-runbook.md) -- how to operate, rebuild, test, backup, and restore
- [Test Evidence Checklist](docs/test-evidence.md) -- what was verified and how
- [Development Guide](docs/development-guide.md) -- the complete 36-step instructions for how this project was built from scratch, including all screenshot proof commands

## How This Was Developed

This project was built step-by-step following a structured 36-step development process documented in [docs/development-guide.md](docs/development-guide.md). The guide covers everything from initial directory scaffolding through schema creation, migration execution, API verification, role permission testing, backup/restore validation, and final evidence packaging with 14 proof-of-work screenshots. Every file in this repository traces back to a specific step in that guide.

## Tech Stack

- PostgreSQL 15 (Alpine)
- Flyway 12.7.0 (Redgate) for version-controlled migrations
- PostgREST for automatic REST API generation
- Docker Compose for local environment orchestration
- PowerShell / Bash for automation scripts
- OpenAPI 3.0.3 for API documentation

## License

This project was developed for academic purposes as part of the CIS 4900 capstone course at California State University, Los Angeles.
