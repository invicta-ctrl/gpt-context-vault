---
schema_version: 1
status: active
scope: protocols
last_reviewed: 2026-08-20
---

# Context Retrieval Protocol

## Procedure

1. Read the root [`../AGENTS.md`](../AGENTS.md).
2. Determine the request's intent, target, authority, risk, deliverable, and verification needs.
3. Scan the available skill descriptions and select only directly relevant playbooks.
4. Retrieve the minimum relevant Context Vault files.
5. When token, context, delegation, evidence reuse, review, or verification efficiency is in scope, follow the canonical [`CODEX_TOKEN_OPTIMIZATION_AND_CONTEXT_EFFICIENCY_RULES.md`](CODEX_TOKEN_OPTIMIZATION_AND_CONTEXT_EFFICIENCY_RULES.md) at repository path `protocols/CODEX_TOKEN_OPTIMIZATION_AND_CONTEXT_EFFICIENCY_RULES.md`.
6. For registered project work, consult [`../projects/PROJECT_REGISTRY.md`](../projects/PROJECT_REGISTRY.md) only when routing remains unresolved, then use the project repository as authority.
7. In the project repository, read its applicable `AGENTS.md` files and `.codex/CURRENT.md` when present.
8. Use [`../START_HERE.md`](../START_HERE.md) and [`../CONTEXT_INDEX.md`](../CONTEXT_INDEX.md) only when routing remains unresolved or non-project context must be located.
9. Stop retrieving once the request is sufficiently grounded.
10. Do not pull unrelated personal context.
11. Do not treat archived or superseded material as active.
12. Identify uncertainty and conflicts.
13. Prefer Earl's current instruction over stored context, while recording material project scope changes as amendments.

## Project implementation retrieval

When `.codex/CURRENT.md` exists in the authoritative project repository:

- use its listed files as the initial context budget;
- read the active step packet and immediately relevant checkpoint;
- read only listed project-capsule and codebase-map sections;
- read only listed source and test files;
- do not perform a broad repository scan;
- expand context only through direct dependencies, targeted symbol references, verification failures, acceptance criteria, repository contradictions, or material risk;
- record why additional context was necessary;
- follow [`INCREMENTAL_CODEX_CONTEXT_PROTOCOL.md`](INCREMENTAL_CODEX_CONTEXT_PROTOCOL.md).

## Stop conditions

Stop retrieval when:

- the authoritative source has been located;
- the current step is adequately grounded;
- additional files would repeat established context;
- the required decision or verification can be completed safely;
- the active repository's pointer provides a sufficient read set.

## Examples

### Engineering question

Read only the relevant combination of:

- [`../academics/CIVIL_ENGINEERING_CONTEXT.md`](../academics/CIVIL_ENGINEERING_CONTEXT.md)
- [`../academics/FORMULA_FORMATTING.md`](../academics/FORMULA_FORMATTING.md)
- a subject-specific file when it affects the solution.

### HAU-USC development

Read:

- [`../projects/PROJECT_REGISTRY.md`](../projects/PROJECT_REGISTRY.md)
- [`../projects/HAU_USC_LOGISTICS.md`](../projects/HAU_USC_LOGISTICS.md) only when its routing summary adds value.

Then use the HAU-USC repository's `AGENTS.md`, `.codex/CURRENT.md`, accepted step packet, checkpoint, and listed code or tests. Do not reread the whole repository by default.

### General writing request

Read response preferences only when they materially improve the output. Do not load academic or project files.

### Thesis planning

Read:

- [`../academics/THESIS_CONSTRAINTS.md`](../academics/THESIS_CONSTRAINTS.md)
- [`../projects/THESIS_PROJECT.md`](../projects/THESIS_PROJECT.md)

Then consult the thesis repository after one is registered.
