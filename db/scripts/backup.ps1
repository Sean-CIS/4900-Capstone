$ErrorActionPreference = "Stop"

New-Item -ItemType Directory -Force -Path backups | Out-Null

docker compose exec -T db pg_dump -U cybersafe_admin -d cybersafe_la > backups\cybersafe_la_backup.sql

Write-Host "Backup written to backups\cybersafe_la_backup.sql"
