---
schema_version: 1
status: template
scope: projects
last_reviewed: 2026-07-13
---

# AI Implementation Task Brief Template

## Task identity

- Project:
- Repository:
- Branch:
- Task ID:
- Accepted specification:
- Primary goal:

## Authoritative context to read first

1. Context Vault entrypoint and relevant project registration.
2. Repository `AGENTS.md` and nested agent instructions.
3. Accepted specification and amendments.
4. Current project status and continuation notes.
5. Relevant architecture, domain rules, tests, and reference files.

Stop retrieval when the task is adequately grounded. Do not load unrelated context.

## Exact scope

### Required behavior

- 

### Allowed files or modules

- 

### Off-limits files, modules, and behavior

- 

### Explicit non-goals

- 

## Constraints and invariants

- Preserve:
- Do not introduce:
- Compatibility requirements:
- Security and privacy requirements:
- Performance or accessibility requirements:

## Assumptions

List every assumption that affects implementation. Verify material assumptions against the repository before coding.

- 

## Required planning step

Before editing, provide a concise implementation plan that maps each acceptance criterion to the files, tests, and verification steps expected to change. Do not implement beyond the accepted scope.

## Implementation rules

- Complete one focused task or vertical slice.
- Prefer the smallest clear diff.
- Preserve established architecture and conventions.
- Do not add dependencies, abstractions, schema changes, public API changes, or unrelated cleanup without an accepted amendment.
- Add or update tests with the behavior.
- For bug fixes, reproduce the defect with a failing regression test before fixing it when practical.
- Never commit secrets or sensitive data.

## Required verification

Run and report the exact commands and results for:

- focused tests:
- full test suite:
- lint or formatting:
- type checks:
- build or artifact verification:
- integration or E2E workflow:
- security checks:
- any project-specific verification:

Do not continue stacking changes on top of an unexplained failing state.

## Diff-review checklist

Confirm that the final diff contains no unintended:

- file deletions or renames;
- public API changes;
- dependencies;
- configuration or environment changes;
- schema or migration changes;
- authentication or authorization changes;
- hard-coded secrets;
- business-rule changes;
- edits outside accepted scope.

## Completion report

Return:

- accepted scope implemented;
- starting and ending commit or repository state;
- files changed;
- behavior completed;
- acceptance criteria with evidence;
- exact verification commands and results;
- amendments made;
- risks and known limitations;
- rollback information;
- recommended next accepted task.

Do not claim completion solely because code was generated or the interface appeared to work.
