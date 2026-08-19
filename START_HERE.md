---
schema_version: 1
status: active
scope: account-wide
last_reviewed: 2026-08-19
---

# Start Here

The root AGENTS.md is the account-wide governance entrypoint. This file is the Context Vault retrieval entrypoint that follows it.

## Retrieval procedure

1. Read the root [AGENTS.md](AGENTS.md).
2. Read this file.
3. Read [CONTEXT_INDEX.md](CONTEXT_INDEX.md).
4. Determine whether the request is general, academic, personal, or project-specific.
5. Retrieve only the minimum files needed.
6. For project-specific work, consult [projects/PROJECT_REGISTRY.md](projects/PROJECT_REGISTRY.md), then follow the registered repository, project extension, current pointer, and accepted specification.
7. When the task needs instruction refinement or model routing, consult [automation/codex-model-routing/README.md](automation/codex-model-routing/README.md).
8. Ignore archived and superseded information unless historical context is requested.
9. Treat Earl's current explicit instruction as the highest authority.
10. Do not retrieve unrelated personal context.
11. Do not automatically save anything after merely reading this vault.

## Stop condition

Stop retrieving when:

- the task is adequately grounded;
- the relevant source-of-truth file has been found;
- additional files would add repetition rather than decision value;
- the request can be completed without expanding into unrelated context.

Do not load the entire repository by default.

## Authority order

1. Current explicit instruction
2. Active project's accepted specification and approved amendments
3. Active projects authoritative repository and applicable project policy
4. Active files in this vault
5. Native memory and relevant recent context
6. Archived or superseded information

## Before writing

Do not modify this repository unless Earl explicitly asks for an update.

When an update is requested, follow:

- [`protocols/MEMORY_UPDATE_PROTOCOL.md`](protocols/MEMORY_UPDATE_PROTOCOL.md)
- [`security/REDACTION_CHECKLIST.md`](security/REDACTION_CHECKLIST.md)
- [`protocols/CONFLICT_RESOLUTION_PROTOCOL.md`](protocols/CONFLICT_RESOLUTION_PROTOCOL.md)
