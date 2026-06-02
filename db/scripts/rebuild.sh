#!/usr/bin/env bash
set -euo pipefail

echo "Stopping and removing the prior Docker test database volume..."
docker compose down -v

echo "Starting PostgreSQL..."
docker compose up -d db

echo "Running Flyway migrations and seed data..."
docker compose run --rm flyway

echo "Starting PostgREST local Application Programming Interface service..."
docker compose up -d postgrest

echo "Current Docker Compose status:"
docker compose ps
