---
schema_version: 1
status: active
scope: account-wide
last_reviewed: 2026-07-12
---

# Start Here

This is the required entrypoint for any assistant using this repository.

## Retrieval procedure

1. Read this file.
2. Read [`CONTEXT_INDEX.md`](CONTEXT_INDEX.md).
3. Determine whether the request is general, academic, personal, or project-specific.
4. Retrieve only the minimum files needed.
5. For project-specific work, consult [`projects/PROJECT_REGISTRY.md`](projects/PROJECT_REGISTRY.md).
6. Follow the authoritative project repository when one is registered.
7. Ignore archived and superseded information unless historical context is requested.
8. Treat Earl's current explicit instruction as the highest authority.
9. Do not retrieve unrelated personal context.
10. Do not automatically save anything after merely reading this vault.

## Stop condition

Stop retrieving when:

- the task is adequately grounded;
- the relevant source-of-truth file has been found;
- additional files would add repetition rather than decision value;
- the request can be completed without expanding into unrelated context.

Do not load the entire repository by default.

## Authority order

1. Current explicit instruction
2. Active project's authoritative repository
3. Active files in this vault
4. Native ChatGPT memory
5. Recent session summaries
6. Archived or superseded information

## Before writing

Do not modify this repository unless Earl explicitly asks for an update.

When an update is requested, follow:

- [`protocols/MEMORY_UPDATE_PROTOCOL.md`](protocols/MEMORY_UPDATE_PROTOCOL.md)
- [`security/REDACTION_CHECKLIST.md`](security/REDACTION_CHECKLIST.md)
- [`protocols/CONFLICT_RESOLUTION_PROTOCOL.md`](protocols/CONFLICT_RESOLUTION_PROTOCOL.md)
