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
- Inherit `SOL-ADVISOR-GLOBAL-001`: Sol / High declares `solo|delegate|audit|full` (solo default); Luna / Max and Terra / High are implementation lanes; fresh Sol / High is the audit/full reviewer; Ox is temporary implementation-only and fail-closed. Project policy may narrow this contract or force solo for an accepted task, but may not silently replace it.
