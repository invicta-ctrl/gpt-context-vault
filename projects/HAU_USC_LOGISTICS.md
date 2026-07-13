---
schema_version: 1
status: active
scope: projects
last_reviewed: 2026-07-13
---

# HAU-USC Logistics Management System

## Purpose

A logistics-management system for the Holy Angel University University Student
Council Department of Logistics.

## Authoritative repository

- Repository: [`invicta-ctrl/hau-usc-logistics-management-system`](https://github.com/invicta-ctrl/hau-usc-logistics-management-system)
- Project-local routing implementation: `.codex/routing/` and `scripts/codex-route.ps1`

The HAU-USC repository is authoritative for requirements, source code,
architecture, domain rules, tests, commands, implementation decisions, branch
state, and project status. This vault entry is only a concise account-wide
routing reference and must not duplicate those technical facts.

## Retrieval sequence

Read this entry and the project registry, then read the HAU-USC repository's
current `AGENTS.md`, status/continuation files, and task-relevant technical
documents. Retrieve the project routing policy from `.codex/routing/` before
refinement or routing. Always recheck the project repository because this entry
can become stale.

## Domains

Request Center, inventory, predictive item search, controlled ledger, Release
Desk, Office Lending Hub, restocking, registration, canvass references, and
reporting.

## Routing boundary

The shared standard in
[`automation/codex-model-routing/`](../automation/codex-model-routing/) defines
the reusable governance. The project repository defines the verified model
catalog, project-specific risk rules, allowlisted checks, and runtime behavior.
Live prompts, assumptions, route decisions, logs, diffs, secrets, and build
artifacts remain local to the project runtime and are never stored in this
vault.
