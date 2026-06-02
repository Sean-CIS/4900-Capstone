# CyberSafe LA Docker PostgreSQL Development Guide

This document contains the complete step-by-step instructions for how the CyberSafe LA Clinic Operations Database was built from scratch. Every file in this repository traces back to a specific step below.

---

## Step 1: Create the Project Directory Structure

Open PowerShell and navigate to your preferred location, then run:

```powershell
mkdir cybersafe-la-db
cd cybersafe-la-db

mkdir db
mkdir db\migrations
mkdir db\scripts
mkdir api
mkdir docs
mkdir docs\screenshots
mkdir backups

New-Item compose.yaml -ItemType File
New-Item .env.example -ItemType File
New-Item .gitignore -ItemType File
New-Item README.md -ItemType File
New-Item db\migrations\V001__create_schema.sql -ItemType File
New-Item db\migrations\V002__timestamps_soft_delete.sql -ItemType File
New-Item db\migrations\V003__roles_permissions.sql -ItemType File
New-Item db\migrations\V004__views.sql -ItemType File
New-Item db\migrations\V005__seed_data.sql -ItemType File
New-Item db\scripts\rebuild.ps1 -ItemType File
New-Item db\scripts\backup.ps1 -ItemType File
New-Item db\scripts\restore.ps1 -ItemType File
New-Item db\scripts\test.ps1 -ItemType File
New-Item api\openapi.yaml -ItemType File
New-Item api\README.md -ItemType File
New-Item docs\docker-runbook.md -ItemType File
New-Item docs\test-evidence.md -ItemType File
New-Item docs\screenshots\.gitkeep -ItemType File
New-Item backups\.gitkeep -ItemType File

tree /F
```

Verify the tree output shows the full directory structure with all files.

---

## Step 2: Fill in .env.example

```powershell
notepad .env.example
```

Paste the following, save, and close:

```
POSTGRES_DB=cybersafe_la
POSTGRES_USER=cybersafe_admin
POSTGRES_PASSWORD=ChangeThisPasswordBeforeDemo
POSTGRES_PORT=5432
POSTGREST_PORT=3000
```

Verify:

```powershell
type .env.example
```

---

## Step 3: Fill in .gitignore

```powershell
notepad .gitignore
```

Paste the following, save, and close:

```
.env
backups/*.sql
!backups/.gitkeep
.DS_Store
node_modules/
*.log
```

Verify:

```powershell
type .gitignore
```

---

## Step 4: Fill in compose.yaml

```powershell
notepad compose.yaml
```

Paste the Docker Compose YAML that defines three services:

- **db**: PostgreSQL 15 Alpine with health check
- **flyway**: Flyway 12.7.0 reading migrations from `db/migrations/`
- **postgrest**: PostgREST exposing the database as a REST API on port 3000

See [compose.yaml](../compose.yaml) for the full content.

Verify:

```powershell
type compose.yaml
```

---

## Step 5: Fill in V001__create_schema.sql

```powershell
notepad db\migrations\V001__create_schema.sql
```

This migration creates all 14 CyberSafe LA tables with:

- BIGINT identity primary keys
- Foreign key relationships matching the approved ERD
- CHECK constraints for enum-like columns (competency_level, status, domain, severity, action_type)
- Timestamp columns (created_at, updated_at, deleted_at)
- Indexes on all foreign key columns

See [db/migrations/V001__create_schema.sql](../db/migrations/V001__create_schema.sql) for the full SQL.

Verify:

```powershell
Get-Item db\migrations\V001__create_schema.sql
```

---

## Step 6: Fill in V002__timestamps_soft_delete.sql

```powershell
notepad db\migrations\V002__timestamps_soft_delete.sql
```

This migration creates a `set_updated_at()` trigger function and attaches it to all 14 tables so `updated_at` is automatically set on every UPDATE.

Verify:

```powershell
Get-Item db\migrations\V002__timestamps_soft_delete.sql
```

---

## Step 7: Fill in V003__roles_permissions.sql

```powershell
notepad db\migrations\V003__roles_permissions.sql
```

Creates two PostgreSQL roles:

- **cybersafe_read**: SELECT only on all tables
- **cybersafe_app**: SELECT/INSERT/UPDATE on data tables, INSERT-only on audit_log_entry

Verify:

```powershell
Get-Item db\migrations\V003__roles_permissions.sql
```

---

## Step 8: Fill in V004__views.sql

```powershell
notepad db\migrations\V004__views.sql
```

Creates four operational views for reporting metrics:

- `v_active_engagements_by_status`
- `v_referral_conversion_by_partner`
- `v_consultant_workload`
- `v_questionnaire_risk_summary`

Verify:

```powershell
Get-Item db\migrations\V004__views.sql
```

---

## Step 9: Fill in V005__seed_data.sql

```powershell
notepad db\migrations\V005__seed_data.sql
```

Inserts fake, repeatable demo data across all tables using `generate_series()`. Never place real client data in this file.

Verify:

```powershell
Get-Item db\migrations\V005__seed_data.sql
```

---

## Step 10: Verify All Migration Files

```powershell
Get-ChildItem db\migrations | Select-Object Name, Length
```

All five migration files must be present and non-zero. Do NOT start Docker yet.

---

## Step 11: Create the Local .env File

```powershell
Copy-Item .env.example .env
Get-Item .env
```

The `.env` file is the real local file Docker Compose reads. It is gitignored.

---

## Step 12: Validate compose.yaml

```powershell
docker compose config
```

This must complete without errors before starting any containers.

---

## Step 13: Start PostgreSQL Only

```powershell
docker compose up -d db
docker compose ps
```

---

## Step 14: Verify PostgreSQL Accepts Connections

```powershell
docker compose exec db pg_isready -U cybersafe_admin -d cybersafe_la
```

Expected: "accepting connections"

---

## Step 15: Connect to PostgreSQL and Check Empty Database

```powershell
docker compose exec db psql -U cybersafe_admin -d cybersafe_la
```

The prompt changes to `cybersafe_la=#`. Run `\dt` to confirm no tables exist yet, then `\q` to exit.

---

## Step 16: Run Flyway Migrations

```powershell
docker compose run --rm flyway
```

Flyway reads V001 through V005 and creates tables, triggers, roles, views, and seed data.

---

## Step 17: Verify Flyway Migration History

```powershell
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -c "SELECT installed_rank, version, description, success FROM flyway_schema_history ORDER BY installed_rank;"
```

All rows should show `success = t`.

---

## Step 18: Verify Created Tables

```powershell
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -c "\dt"
```

---

## Step 19: Verify Seed Data Row Counts

```powershell
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -c "SELECT 'business' AS table_name, COUNT(*) FROM business UNION ALL SELECT 'contact', COUNT(*) FROM contact UNION ALL SELECT 'engagement', COUNT(*) FROM engagement UNION ALL SELECT 'questionnaire_response', COUNT(*) FROM questionnaire_response UNION ALL SELECT 'knowledge_base_entry', COUNT(*) FROM knowledge_base_entry;"
```

Expected: 20 rows each for business, contact, engagement, questionnaire_response, and knowledge_base_entry.

---

## Step 20: Start PostgREST API

```powershell
docker compose up -d postgrest
docker compose ps
```

---

## Step 21: Test API Response

```powershell
curl.exe http://localhost:3000/business?limit=1
```

Should return a JSON record from the business table.

---

## Step 22: Test Operational View Through API

```powershell
curl.exe http://localhost:3000/v_active_engagements_by_status
```

---

## Step 23: Test API Write

```powershell
Set-Content -Path .\api-write-test.json -Value '{"name":"Docker Test Business","naics":"541213","employee_count":4,"address":"Demo address","ccpa_flag":false}' -Encoding ascii

curl.exe -X POST "http://localhost:3000/business" -H "Content-Type: application/json" -H "Prefer: return=representation" --data-binary "@api-write-test.json"
```

Expected: response includes "Docker Test Business".

---

## Step 23B: Fill and Verify OpenAPI Documentation

Run the PowerShell here-string block to write `api/openapi.yaml` with all table and view endpoints, then verify with the pattern-check loop. See [api/openapi.yaml](../api/openapi.yaml) for the full specification.

---

## Step 24: Create rebuild.ps1

```powershell
notepad db\scripts\rebuild.ps1
```

One-command rebuild script that tears down volumes and rebuilds everything. See [db/scripts/rebuild.ps1](../db/scripts/rebuild.ps1).

---

## Step 25: Create test.ps1

```powershell
notepad db\scripts\test.ps1
```

Evidence check script covering container status, PostgreSQL readiness, migration history, table list, seed row counts, operational views, role permission tests, and API JSON check. See [db/scripts/test.ps1](../db/scripts/test.ps1).

---

## Step 26: Create backup.ps1

```powershell
notepad db\scripts\backup.ps1
```

Runs `pg_dump` to `backups/cybersafe_la_backup.sql`. See [db/scripts/backup.ps1](../db/scripts/backup.ps1).

---

## Step 27: Create restore.ps1

```powershell
notepad db\scripts\restore.ps1
```

Clean restore script that drops and recreates the database before restoring. See [db/scripts/restore.ps1](../db/scripts/restore.ps1).

---

## Step 28: Create rebuild.sh (Bash)

```powershell
notepad db\scripts\rebuild.sh
```

Same rebuild logic for Linux/macOS users. See [db/scripts/rebuild.sh](../db/scripts/rebuild.sh).

---

## Step 29: Run the Rebuild Script

```powershell
powershell -ExecutionPolicy Bypass -File .\db\scripts\rebuild.ps1
```

Proves the database can be rebuilt entirely from the project files.

---

## Step 30: Run the Full Test Script

```powershell
powershell -ExecutionPolicy Bypass -File .\db\scripts\test.ps1
```

Some expected failure messages are correct (role permission denial tests).

---

## Step 31: Run the Backup Script

```powershell
powershell -ExecutionPolicy Bypass -File .\db\scripts\backup.ps1
Get-Item backups\cybersafe_la_backup.sql
```

---

## Step 32: Test Restore

```powershell
powershell -ExecutionPolicy Bypass -File .\db\scripts\restore.ps1
```

---

## Step 33: Verify Restored Data

```powershell
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -c "SELECT 'business' AS table_name, COUNT(*) FROM business UNION ALL SELECT 'contact', COUNT(*) FROM contact UNION ALL SELECT 'engagement', COUNT(*) FROM engagement UNION ALL SELECT 'questionnaire_response', COUNT(*) FROM questionnaire_response UNION ALL SELECT 'knowledge_base_entry', COUNT(*) FROM knowledge_base_entry;"
```

Row counts must match the original seed data.

---

## Step 34: Create the Evidence Checklist

Run the PowerShell here-string block to write `docs/test-evidence.md` with all evidence sections including OpenAPI Documentation Evidence. See [docs/test-evidence.md](../docs/test-evidence.md).

---

## Step 35: Create the Docker Runbook

Run the PowerShell here-string block to write `docs/docker-runbook.md` with all operational sections including OpenAPI verification. See [docs/docker-runbook.md](../docs/docker-runbook.md).

### Step 35A: Verify Docker Runbook

Run the pattern-check loop to confirm the runbook covers: docker compose up, rebuild, backup, restore, test, PostgREST, and OpenAPI. All must print OK.

---

## Step 36: Final Packaging Evidence Capture

This step captures screenshot evidence for the final submission package.

**No-paralysis rule**: create one missing evidence file at a time. Do not rebuild PostgreSQL. Do not reset Docker volumes. Do not rerun migrations. Do not create the final zip until the evidence manifest passes.

### Step 36A: Start the Verification Transcript

```powershell
Start-Transcript -Path .\docs\screenshots\final-verification-transcript.txt -Force
```

### Step 36B: Screenshot Capture Process

For each screenshot:

1. Run the proof command
2. Keep the successful output visible in PowerShell
3. Press `Win + Shift + S`
4. Select the PowerShell output area
5. Save the image into `docs/screenshots/` with the exact filename
6. Verify with `Test-Path`
7. Move to the next screenshot only after the current one prints OK

### Step 36C: Required Screenshots with Proof Commands

After each screenshot, verify it with this pattern (replace the filename each time):

```powershell
if (Test-Path .\docs\screenshots\EXACT-FILENAME-HERE.png) {
  Write-Host "OK: EXACT-FILENAME-HERE.png" -ForegroundColor Green
} else {
  Write-Host "MISSING: EXACT-FILENAME-HERE.png" -ForegroundColor Red
}
```

#### 1. final-package-inventory-check.png

```powershell
$required = @(
"compose.yaml",
".env.example",
".gitignore",
"README.md",
"api\openapi.yaml",
"api\README.md",
"db\migrations\V001__create_schema.sql",
"db\migrations\V002__timestamps_soft_delete.sql",
"db\migrations\V003__roles_permissions.sql",
"db\migrations\V004__views.sql",
"db\migrations\V005__seed_data.sql",
"db\scripts\rebuild.ps1",
"db\scripts\backup.ps1",
"db\scripts\restore.ps1",
"db\scripts\test.ps1",
"docs\docker-runbook.md",
"docs\test-evidence.md",
"backups\cybersafe_la_backup.sql"
)
foreach ($file in $required) {
  if (Test-Path $file) { Write-Host "OK: $file" -ForegroundColor Green }
  else { Write-Host "MISSING: $file" -ForegroundColor Red }
}
```

#### 2. final-docker-compose-health.png

```powershell
docker --version
docker compose version
docker compose up -d db postgrest
docker compose ps
```

#### 3. final-postgresql-version-connection.png

```powershell
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -c "SELECT current_database(), current_user, version();"
```

#### 4. final-flyway-migration-history.png

```powershell
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -c "SELECT installed_rank, version, description, success FROM flyway_schema_history ORDER BY installed_rank;"
```

#### 5. final-table-creation-proof.png

```powershell
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -c "\dt public.*"
```

#### 6. final-operational-views-proof.png

```powershell
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -c "\dv public.*"
```

#### 7. final-seed-data-row-counts.png

```powershell
docker compose exec db psql -U cybersafe_admin -d cybersafe_la -c "SELECT 'business' AS table_name, COUNT(*) AS row_count FROM business UNION ALL SELECT 'contact', COUNT(*) FROM contact UNION ALL SELECT 'cohort', COUNT(*) FROM cohort UNION ALL SELECT 'consultant', COUNT(*) FROM consultant UNION ALL SELECT 'faculty_advisor', COUNT(*) FROM faculty_advisor UNION ALL SELECT 'industry_mentor', COUNT(*) FROM industry_mentor UNION ALL SELECT 'assignment', COUNT(*) FROM assignment UNION ALL SELECT 'mou', COUNT(*) FROM mou UNION ALL SELECT 'partner', COUNT(*) FROM partner UNION ALL SELECT 'referral', COUNT(*) FROM referral UNION ALL SELECT 'engagement', COUNT(*) FROM engagement UNION ALL SELECT 'questionnaire_response', COUNT(*) FROM questionnaire_response UNION ALL SELECT 'knowledge_base_entry', COUNT(*) FROM knowledge_base_entry UNION ALL SELECT 'audit_log_entry', COUNT(*) FROM audit_log_entry ORDER BY table_name;"
```

#### 8. final-postgrest-api-route-proof.png

```powershell
$routes = @(
  "business",
  "contact",
  "referral",
  "engagement",
  "questionnaire_response",
  "knowledge_base_entry",
  "v_active_engagements_by_status",
  "v_referral_conversion_by_partner",
  "v_consultant_workload",
  "v_questionnaire_risk_summary"
)
foreach ($route in $routes) {
  $url = "http://localhost:3000/$($route)?limit=1"
  Write-Host "Checking $url" -ForegroundColor Cyan
  curl.exe --silent --show-error --fail "$url" | Out-Null
  if ($LASTEXITCODE -eq 0) { Write-Host "OK: /$route" -ForegroundColor Green }
  else { Write-Host "FAILED: /$route" -ForegroundColor Red }
}
```

#### 9. final-openapi-documentation-proof.png

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

#### 10. final-role-permission-proof.png

```powershell
Get-Item .\docs\screenshots\final-permission-tests-output.txt | Select-Object FullName, Length, LastWriteTime
Get-Content .\docs\screenshots\final-permission-tests-output.txt
```

#### 11. final-backup-proof.png

```powershell
Get-Item .\docs\screenshots\final-backup-output.txt | Select-Object FullName, Length, LastWriteTime
Get-Item .\backups\cybersafe_la_backup.sql | Select-Object FullName, Length, LastWriteTime
Get-Content .\docs\screenshots\final-backup-output.txt
```

#### 12. final-restore-proof.png

```powershell
Get-Item .\docs\screenshots\final-restore-output.txt | Select-Object FullName, Length, LastWriteTime
Get-Content .\docs\screenshots\final-restore-output.txt
```

#### 13. final-runbook-proof.png

```powershell
Get-Item .\docs\docker-runbook.md | Select-Object FullName, Length, LastWriteTime
$runbookChecks = @(
  "docker compose up",
  "rebuild",
  "backup",
  "restore",
  "test",
  "PostgREST",
  "OpenAPI"
)
foreach ($pattern in $runbookChecks) {
  if (Select-String -Path .\docs\docker-runbook.md -SimpleMatch $pattern -Quiet) {
    Write-Host "OK: $pattern" -ForegroundColor Green
  } else {
    Write-Host "MISSING: $pattern" -ForegroundColor Red
  }
}
```

#### 14. final-test-evidence-proof.png

```powershell
Get-Item .\docs\test-evidence.md | Select-Object FullName, Length, LastWriteTime
$testEvidenceChecks = @(
  "Database Build Evidence",
  "Seed Data Evidence",
  "OpenAPI Documentation Evidence",
  "Role Permission Evidence",
  "Backup and Restore Evidence"
)
foreach ($pattern in $testEvidenceChecks) {
  if (Select-String -Path .\docs\test-evidence.md -SimpleMatch $pattern -Quiet) {
    Write-Host "OK: $pattern" -ForegroundColor Green
  } else {
    Write-Host "MISSING: $pattern" -ForegroundColor Red
  }
}
```

### Important: Verify Screenshot Save Location

When using Win + Shift + S and saving via Snip and Sketch, always check the address bar before saving. The screenshots must go into the project's `docs\screenshots\` folder, not a different folder on your Desktop. If screenshots were saved to the wrong location, copy them over with:

```powershell
Copy-Item "C:\Users\<your-username>\Desktop\<wrong-folder>\docs\screenshots\*.png" .\docs\screenshots\
```

### Step 36D: Stop the Transcript

```powershell
Stop-Transcript
Get-Item .\docs\screenshots\final-verification-transcript.txt | Select-Object FullName, Length, LastWriteTime
```

### Step 36E: Run the Evidence Manifest

Run this only after all 14 PNG screenshots and 4 text files are in `docs\screenshots\`:

```powershell
$expectedEvidence = @(
  "final-package-inventory-check.png",
  "final-docker-compose-health.png",
  "final-postgresql-version-connection.png",
  "final-flyway-migration-history.png",
  "final-table-creation-proof.png",
  "final-operational-views-proof.png",
  "final-seed-data-row-counts.png",
  "final-postgrest-api-route-proof.png",
  "final-openapi-documentation-proof.png",
  "final-role-permission-proof.png",
  "final-backup-proof.png",
  "final-restore-proof.png",
  "final-runbook-proof.png",
  "final-test-evidence-proof.png",
  "final-permission-tests-output.txt",
  "final-backup-output.txt",
  "final-restore-output.txt",
  "final-verification-transcript.txt"
)
$missingEvidence = @()
foreach ($item in $expectedEvidence) {
  $path = Join-Path ".\docs\screenshots" $item
  if (Test-Path $path) {
    Write-Host "OK: $item" -ForegroundColor Green
  } else {
    Write-Host "MISSING: $item" -ForegroundColor Red
    $missingEvidence += $item
  }
}
if ($missingEvidence.Count -eq 0) {
  Write-Host "EVIDENCE MANIFEST PASSED" -ForegroundColor Green
} else {
  Write-Host "EVIDENCE MANIFEST INCOMPLETE. STOP HERE." -ForegroundColor Red
  $missingEvidence
}
```

Expected result: every evidence file prints OK, then **EVIDENCE MANIFEST PASSED**. If only one item is missing, create only that item. Do not go backward into database rebuild steps.
