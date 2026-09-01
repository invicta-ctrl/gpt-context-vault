---
schema_version: 1
status: template
scope: project-extension
---

# Project Policy Extension

This extension is subordinate to the canonical Context Vault `AGENTS.md` and
contains only project-specific accepted rules. Keep product authority, current
state, specifications, writer locks, data invariants, deployment gates, and
verification commands in the authoritative project repository.

## Project-specific additions

- Add only accepted stricter constraints, ownership, release, migration, privacy,
  or verification rules here.
- Do not copy or modify the account-wide canonical policy in this extension.
- Point substantial work to the project's `.codex/CURRENT.md` and accepted
  specification when those files exist.
- Inherit `MAEOS-v1`: Sol / High is root; zero children is default; Luna / Max is read-only only; Terra / High handles every native non-Ox implementation, write, and integration task; fresh Sol / High review is risk-triggered; Ox is temporary implementation-only and fail-closed. Project policy may tighten this contract for an accepted task, but may not silently replace it.
