---
name: rdmo
description: Connect to an RDMO (Research Data Management Organiser) instance via its REST API using RDMO_URL and RDMO_TOKEN environment variables. Use when the user asks about RDMO, their RDMO projects, catalogs, questions, options, domain attributes, tasks, views, or wants to inspect/modify RDMO resources.
---

# RDMO API

Connect to an RDMO instance and interact with its REST API.

## Credentials

Read from environment:
- `RDMO_URL` — base URL
- `RDMO_TOKEN` — API token

Always send `Authorization: Token $RDMO_TOKEN`. If either var is missing, ask the user.

## OpenAPI schema

The full OpenAPI 3.0 schema is at `/api/v1/schema/` (~500 KB).
