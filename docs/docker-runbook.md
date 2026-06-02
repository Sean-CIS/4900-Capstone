# CyberSafe LA Docker PostgreSQL Runbook

## Purpose

This runbook explains how to operate the local CyberSafe LA Clinic Operations Database using Docker Compose.

This project does not use Docker instead of PostgreSQL. It uses PostgreSQL 15 through Docker Compose so every team member can run the same database environment without manually installing PostgreSQL on Windows.

## Project Folder

All commands must be run from the project root folder:

```powershell
cd C:\Users\<your-username>\Desktop\cybersafe-la-db
```

## Start PostgreSQL

```powershell
docker compose up -d db
docker compose ps
```

Expected result: cybersafe_postgres is Up and healthy.

## Check PostgreSQL readiness

```powershell
docker compose exec db pg_isready -U cybersafe_admin -d cybersafe_la
```

Expected result: PostgreSQL reports accepting connections.

## Run migrations and seed data

```powershell
docker compose run --rm flyway
```

Expected result: Flyway applies V001 through V005 successfully.

## Verify migration history

```powershell
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -c "SELECT installed_rank, version, description, success FROM flyway_schema_history ORDER BY installed_rank;"
```

Expected result: every migration row shows success = true.

## Show database tables

```powershell
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -c "\dt public.*"
```

Expected result: CyberSafe LA tables appear, including business, contact, referral, engagement, questionnaire_response, knowledge_base_entry, and audit_log_entry.

## Start PostgREST Application Programming Interface service

```powershell
docker compose up -d postgrest
docker compose ps
```

Expected result: the PostgREST service is running on localhost port 3000.

## Test the Application Programming Interface

```powershell
curl.exe http://localhost:3000/business?limit=1
curl.exe http://localhost:3000/v_active_engagements_by_status
```

Expected result: both commands return JSON.

## Verify OpenAPI documentation

OpenAPI documentation is required because the Project 2 database package includes documented Application Programming Interface routes for table endpoints and operational view endpoints.

```powershell
Get-Item .\api\openapi.yaml | Select-Object FullName, Length, LastWriteTime

$openApiChecks = @(
  "openapi:",
  "paths:",
  "/business",
  "/contact",
  "/referral",
  "/engagement",
  "/questionnaire_response",
  "/knowledge_base_entry",
  "/v_active_engagements_by_status",
  "/v_referral_conversion_by_partner",
  "/v_consultant_workload",
  "/v_questionnaire_risk_summary"
)
foreach ($pattern in $openApiChecks) {
  if (Select-String -Path .\api\openapi.yaml -SimpleMatch $pattern -Quiet) {
    Write-Host "OK: $pattern" -ForegroundColor Green
  } else {
    Write-Host "MISSING: $pattern" -ForegroundColor Red
  }
}
```

Expected result: every OpenAPI check prints OK.

If only an OpenAPI route is missing, patch api\openapi.yaml only. Do not rebuild PostgreSQL, do not reset Docker volumes, and do not rerun migrations.

## One-command rebuild

```powershell
powershell -ExecutionPolicy Bypass -File .\db\scripts\rebuild.ps1
```

Use this only when you intentionally want a clean local rebuild from the migration files and seed data.

## Run the test script

```powershell
powershell -ExecutionPolicy Bypass -File .\db\scripts\test.ps1
```

Expected results:

- Container status prints
- PostgreSQL readiness succeeds
- Migration history prints
- Table list prints
- Seed row counts print
- Operational views print
- cybersafe_read insert fails as expected
- cybersafe_app audit insert succeeds
- cybersafe_app audit update fails as expected
- Application Programming Interface JSON check returns data

## Backup the database

```powershell
powershell -ExecutionPolicy Bypass -File .\db\scripts\backup.ps1
Get-Item .\backups\cybersafe_la_backup.sql | Select-Object FullName, Length, LastWriteTime
```

Expected result: backups\cybersafe_la_backup.sql exists and has a non-zero length.

## Restore the database

```powershell
powershell -ExecutionPolicy Bypass -File .\db\scripts\restore.ps1
```

Expected result: restore completes successfully, then row-count checks confirm restored data.

## Stop services

```powershell
docker compose down
```

## Full reset

Only use this when you intentionally want to remove the local database volume and rebuild from scratch:

```powershell
docker compose down -v
powershell -ExecutionPolicy Bypass -File .\db\scripts\rebuild.ps1
```
