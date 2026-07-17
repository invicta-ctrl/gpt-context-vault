---
schema_version: 1
status: active
scope: account-wide
last_reviewed: 2026-07-17
---

# Start Here

The root [`AGENTS.md`](AGENTS.md) is the required agent entrypoint.

Use this file for human onboarding, unresolved routing, or non-project requests that need additional Context Vault context. Do not read it automatically after `AGENTS.md` has already identified the authoritative project and minimum required context.

## Retrieval procedure

1. Determine whether the request is general, academic, personal, or project-specific.
2. For project-specific work, consult [`projects/PROJECT_REGISTRY.md`](projects/PROJECT_REGISTRY.md).
3. Follow the registered project's authoritative repository.
4. In that repository, read its applicable `AGENTS.md` files and `.codex/CURRENT.md` when present.
5. For non-project work, use [`CONTEXT_INDEX.md`](CONTEXT_INDEX.md) to locate only the relevant file or category.
6. Ignore archived and superseded information unless history is requested.
7. Do not retrieve unrelated personal context.
8. Do not automatically save anything after merely reading this vault.

## Stop condition

Stop retrieving when:

- the authoritative source has been found;
- the task is adequately grounded;
- the active project's current pointer defines the required read set;
- additional files would add repetition rather than decision value;
- the request can be completed safely without expanding into unrelated context.

Do not load the entire repository by default.

## Authority order

1. Earl's current explicit instruction
2. Active project's accepted specification and approved amendments
3. Active project's authoritative repository
4. Active files in this vault
5. Native ChatGPT memory and recent summaries
6. Archived or superseded information

## Before writing

Do not modify this repository unless Earl explicitly requests an update.

When an update is requested, follow:

- [`protocols/MEMORY_UPDATE_PROTOCOL.md`](protocols/MEMORY_UPDATE_PROTOCOL.md)
- [`security/REDACTION_CHECKLIST.md`](security/REDACTION_CHECKLIST.md)
- [`protocols/CONFLICT_RESOLUTION_PROTOCOL.md`](protocols/CONFLICT_RESOLUTION_PROTOCOL.md)
