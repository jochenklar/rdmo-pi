---
name: rdmo
description: Connect to an RDMO (Research Data Management Organiser) instance via its REST API using RDMO_URL and RDMO_TOKEN environment variables. Use when the user asks about RDMO, their RDMO projects, catalogs, questions, options, domain attributes, tasks, views, or wants to inspect/modify RDMO resources.
---

# RDMO API

Connect to an RDMO instance and interact with its REST API.

## Credentials

Read from environment or from `~/.env`:
- `RDMO_URL` — base URL
- `RDMO_TOKEN` — API token

Always send `Authorization: Token $RDMO_TOKEN`. If either var is missing, ask the user.

## OpenAPI schema

The full OpenAPI 3.0 schema is at `/api/v1/schema/`. If not accessible, ask the user.

## Project listing

When the user asks for "my projects", use `/api/v1/projects/projects/user/`.

Be careful with `/api/v1/projects/projects/`: for users with elevated permissions, this endpoint can return all projects, not just the user's own projects. Use it only when the user explicitly asks for all visible projects or when that broader scope is intended.

## Values and collection pages (set markers)

When writing values into a project (`/api/v1/projects/projects/<id>/values/`), respect the page semantics:

- A "set" (e.g. a dataset, a partner, …) is identified by `set_prefix` + `set_index`.
- If the catalog page that contains the question has `is_collection = true`, then for every `set_index` that has any value, there **must** also be a value on the **page's own attribute** (`pages[].attribute`) with the same `set_prefix` and `set_index`. This row acts as the set marker. Its `text` should be a meaningful label for the set (e.g. the set's title / name) — either provided by the user or inferred from context. Use a number, if no label can reasonably be determined.
- Find the page's attribute via `GET /api/v1/projects/<id>/pages/<page_id>/` and use the `attribute` field of that page — **not** a parent domain attribute that merely shares part of the URI. Never guess the attribute from the page URI.
- Workflow when adding a new entry to a collection page:
  1. Pick the next free `set_index` (max existing + 1, or 0).
  2. POST a marker value: `{attribute: <page.attribute>, set_prefix: "", set_index: N, collection_index: 0, text: "<label>"}` where `<label>` is the set's name/title (asked from the user or inferred).
  3. POST the actual question values with the same `set_prefix` / `set_index`.
