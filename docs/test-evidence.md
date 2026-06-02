# CyberSafe LA Docker PostgreSQL Test Evidence

## Environment Verification

- Docker Desktop running
- docker --version completed
- docker compose version completed
- docker compose config completed without errors

## Database Build Evidence

- docker compose up -d db completed
- docker compose ps showed PostgreSQL healthy
- pg_isready returned accepting connections
- psql connection worked
- Initial \dt showed no relations before migrations
- Flyway applied V001 through V005 successfully
- flyway_schema_history showed all migrations with success = true
- \dt showed all CyberSafe LA tables

## Seed Data Evidence

- business count = 20
- contact count = 20
- engagement count = 20
- questionnaire_response count = 20
- knowledge_base_entry count = 20

## PostgREST Application Programming Interface Evidence

- PostgREST started successfully
- curl http://localhost:3000/business?limit=1 returned JSON
- curl http://localhost:3000/v_active_engagements_by_status returned JSON
- API write test inserted Docker Test Business successfully

## OpenAPI Documentation Evidence

- api/openapi.yaml exists and is non-zero
- api/openapi.yaml includes openapi: and paths:
- api/openapi.yaml documents /business, /contact, /referral, /engagement, /questionnaire_response, and /knowledge_base_entry
- api/openapi.yaml documents /v_active_engagements_by_status, /v_referral_conversion_by_partner, /v_consultant_workload, and /v_questionnaire_risk_summary

## Role Permission Evidence

- cybersafe_read insert test failed as expected
- cybersafe_app audit insert test succeeded
- cybersafe_app audit update test failed as expected

## Backup and Restore Evidence

- backup.ps1 created backups/cybersafe_la_backup.sql
- restore.ps1 completed successfully
- restored database row-count check passed
