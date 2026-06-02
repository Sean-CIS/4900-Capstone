# CyberSafe LA PostgREST API

This directory contains the OpenAPI 3.0.3 specification for the CyberSafe LA Clinic Operations Database API.

## Overview

The API is served by [PostgREST](https://postgrest.org/), which automatically generates a RESTful API from the PostgreSQL schema. PostgREST runs as a Docker Compose service defined in `compose.yaml` at the project root.

## Endpoints

### Table Endpoints (GET and POST)

| Endpoint                    | Description                        |
|-----------------------------|------------------------------------|
| `/business`                 | Business client records            |
| `/contact`                  | Business contact records           |
| `/referral`                 | Partner referral records           |
| `/engagement`               | Engagement lifecycle records       |
| `/questionnaire_response`   | Cybersecurity questionnaire data   |
| `/knowledge_base_entry`     | Findings and remediation entries   |

### Operational View Endpoints (GET only)

| Endpoint                              | Description                          |
|---------------------------------------|--------------------------------------|
| `/v_active_engagements_by_status`     | Engagement counts grouped by status  |
| `/v_referral_conversion_by_partner`   | Partner referral conversion rates    |
| `/v_consultant_workload`              | Consultant assignment and hours      |
| `/v_questionnaire_risk_summary`       | Risk band distribution from surveys  |

## Local Access

After starting the PostgREST service:

```
docker compose up -d postgrest
```

The API is available at `http://localhost:3000`.

## OpenAPI Specification

See [openapi.yaml](openapi.yaml) for the full specification.
