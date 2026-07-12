---
schema_version: 1
status: active
scope: protocols
last_reviewed: 2026-07-12
---

# Context Retrieval Protocol

## Procedure

1. Determine the request's scope.
2. Read [`../START_HERE.md`](../START_HERE.md).
3. Read [`../CONTEXT_INDEX.md`](../CONTEXT_INDEX.md).
4. Retrieve the minimum relevant context.
5. Consult project-specific sources for project work.
6. Stop retrieving once the request is sufficiently grounded.
7. Do not pull unrelated personal context.
8. Do not treat archived or superseded material as active.
9. Identify uncertainty and conflicts.
10. Prefer the current instruction over stored context.

## Examples

### Engineering question

Read:

- [`../academics/CIVIL_ENGINEERING_CONTEXT.md`](../academics/CIVIL_ENGINEERING_CONTEXT.md)
- [`../academics/FORMULA_FORMATTING.md`](../academics/FORMULA_FORMATTING.md)

Retrieve subject-specific files only when they affect the solution.

### HAU-USC development

Read:

- [`../projects/PROJECT_REGISTRY.md`](../projects/PROJECT_REGISTRY.md)
- [`../projects/HAU_USC_LOGISTICS.md`](../projects/HAU_USC_LOGISTICS.md)

Then use the project repository as the authority for code, requirements, status, and tests.

### General writing request

Read response preferences only if they materially improve the output. Do not load academic or project files.

### Thesis planning

Read:

- [`../academics/THESIS_CONSTRAINTS.md`](../academics/THESIS_CONSTRAINTS.md)
- [`../projects/THESIS_PROJECT.md`](../projects/THESIS_PROJECT.md)

Then consult the thesis repository after one is registered.
