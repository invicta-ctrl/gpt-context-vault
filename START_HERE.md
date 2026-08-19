---
schema_version: 1
status: active
scope: account-wide
last_reviewed: 2026-08-19
---

# Start Here

The root [`AGENTS.md`](AGENTS.md) is the required agent entrypoint.

Use this file for human onboarding, unresolved routing, or non-project requests that need additional Context Vault context. Do not read it automatically after `AGENTS.md` has already identified the authoritative project and minimum required context.

## Retrieval procedure

1. Read the root [`AGENTS.md`](AGENTS.md) when it has not already been loaded.
2. Determine whether the request is general, academic, personal, or project-specific.
3. For project-specific work, consult [`projects/PROJECT_REGISTRY.md`](projects/PROJECT_REGISTRY.md) only when routing is unresolved.
4. Follow the registered project's authoritative repository, applicable project extension, `.codex/CURRENT.md` when present, bounded current task and handoff, and accepted specification.
5. For non-project work, use [`CONTEXT_INDEX.md`](CONTEXT_INDEX.md) to locate only the relevant file or category.
6. When the task needs instruction refinement or model routing, consult [`automation/codex-model-routing/README.md`](automation/codex-model-routing/README.md).
7. Ignore archived and superseded information unless history is requested.
8. Do not retrieve unrelated personal context.
9. Do not automatically save anything after merely reading this vault.

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
3. Active project's authoritative repository and applicable project policy
4. Active files in this vault
5. Native memory and relevant recent context
6. Archived or superseded information

## Before writing

Do not modify this repository unless Earl explicitly requests an update.

When an update is requested, follow:

- [`protocols/MEMORY_UPDATE_PROTOCOL.md`](protocols/MEMORY_UPDATE_PROTOCOL.md)
- [`security/REDACTION_CHECKLIST.md`](security/REDACTION_CHECKLIST.md)
- [`protocols/CONFLICT_RESOLUTION_PROTOCOL.md`](protocols/CONFLICT_RESOLUTION_PROTOCOL.md)
