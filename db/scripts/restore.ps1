$ErrorActionPreference = "Stop"

if (!(Test-Path backups\cybersafe_la_backup.sql)) {
  throw "Backup file not found: backups\cybersafe_la_backup.sql"
}

Write-Host "Stopping containers..."
docker compose down

Write-Host "Starting PostgreSQL..."
docker compose up -d db

Write-Host "Waiting for PostgreSQL readiness..."
Start-Sleep -Seconds 8

Write-Host "Dropping and recreating database for clean restore..."
docker compose exec -T db psql -U cybersafe_admin -d postgres -c "DROP DATABASE IF EXISTS cybersafe_la WITH (FORCE);"
docker compose exec -T db psql -U cybersafe_admin -d postgres -c "CREATE DATABASE cybersafe_la;"

Write-Host "Restoring database from backup..."
Get-Content backups\cybersafe_la_backup.sql | docker compose exec -T db psql -U cybersafe_admin -d cybersafe_la

Write-Host "Restore completed from backups\cybersafe_la_backup.sql"
