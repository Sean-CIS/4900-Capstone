$ErrorActionPreference = "Stop"

Write-Host "Stopping and removing the prior Docker test database volume..."
docker compose down -v

Write-Host "Starting PostgreSQL..."
docker compose up -d db

Write-Host "Running Flyway migrations and seed data..."
docker compose run --rm flyway

Write-Host "Starting PostgREST local Application Programming Interface service..."
docker compose up -d postgrest

Write-Host "Current Docker Compose status:"
docker compose ps
