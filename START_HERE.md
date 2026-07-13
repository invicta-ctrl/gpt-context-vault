---
schema_version: 1
status: active
scope: account-wide
last_reviewed: 2026-07-13
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
7. Before non-trivial project implementation, read the project's `AGENTS.md` or equivalent ruleset and its accepted active specification. Follow [`protocols/SPEC_DRIVEN_DEVELOPMENT_PROTOCOL.md`](protocols/SPEC_DRIVEN_DEVELOPMENT_PROTOCOL.md).
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
2. Active project's authoritative repository, including `AGENTS.md` and governing rules
3. Accepted active project specification
4. Active files in this vault
5. Native ChatGPT memory
6. Recent session summaries
7. Archived or superseded information

## Before writing

Do not modify this repository unless Earl explicitly asks for an update.

When an update is requested, follow:

- [`protocols/MEMORY_UPDATE_PROTOCOL.md`](protocols/MEMORY_UPDATE_PROTOCOL.md)
- [`security/REDACTION_CHECKLIST.md`](security/REDACTION_CHECKLIST.md)
- [`protocols/CONFLICT_RESOLUTION_PROTOCOL.md`](protocols/CONFLICT_RESOLUTION_PROTOCOL.md)

For non-trivial project work, also follow:

- [`protocols/SPEC_DRIVEN_DEVELOPMENT_PROTOCOL.md`](protocols/SPEC_DRIVEN_DEVELOPMENT_PROTOCOL.md)
