---
schema_version: 1
status: active
scope: projects
last_reviewed: 2026-07-12
---

# HAU-USC Logistics Management System

## Purpose

A logistics-management system for the Holy Angel University University Student Council Department of Logistics.

## Authoritative repository

- Repository: [`invicta-ctrl/hau-usc-logistics-management-system`](https://github.com/invicta-ctrl/hau-usc-logistics-management-system)
- Default branch: `main`
- Default-branch commit observed during registration: `91a30ee2de015bce1471a2d4fd71d9325af3e936`

The project repository is authoritative for requirements, code, implementation decisions, test results, status, and technical documentation. This vault file is only an account-wide routing summary.

## Current authoritative snapshot

As recorded from the project repository on 2026-07-12:

- Current documented version: `0.3.0`, dated 2026-07-11.
- Operating mode: preview only.
- Active backend: mock browser adapter.
- Standalone build artifact: `dist/index.html`.
- Baseline preservation, priority integrity fixes, preview UX/accessibility work, and modular Vite source are documented as implemented.
- Later roadmap phases remain unstarted.
- ESLint, Vitest unit/integration tests, and the Vite single-file build are documented as passing.
- Thirty Playwright responsive checks are defined, but their last documented run was blocked by browser-installation failure rather than executed assertion failures.

## Current direction

The project began as a front-end prototype and now uses a modular Vite and vanilla JavaScript architecture. Its intended production architecture includes:

- a modular frontend;
- a Google Apps Script backend;
- Google Sheets as an operational and reporting layer;
- Google Drive integration where appropriate;
- simplified workflows for nontechnical maintainers;
- deeper monitoring and maintenance tools for technical maintainers.

## Key domains

- Request Center
- Inventory management
- Predictive item search
- Controlled ledger
- Release Desk
- Office Lending Hub
- Restocking
- Registration
- Canvass-reference library
- Reporting and exports

## Production boundary

The repository currently documents preview permissions and browser-local mock data rather than production security or shared institutional storage. Production identity, authorization, locking, balances, transitions, IDs, idempotency, evidence validation, and audit records must be enforced by the server layer.

The current documented next full-stack task is an Apps Script `api_acceptRequest(command)` vertical slice with institutional identity, centralized role resolution, `LockService`, idempotency records, server-allocated IDs, batched writes, and normalized response objects.

## Authoritative starting files

Before project implementation work, consult the repository's current versions of:

- `AGENTS.md`
- `README.md`
- `PROJECT_STATUS.md`
- `CHANGELOG.md`
- `docs/ARCHITECTURE.md`
- `docs/DOMAIN_RULES.md`
- `docs/ROADMAP_TO_V1.md`

Do not assume unfinished backend functionality is complete. Recheck the project repository before relying on this snapshot because project status may have advanced after registration.
