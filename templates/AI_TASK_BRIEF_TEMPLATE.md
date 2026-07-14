---
schema_version: 1
status: template
scope: projects
last_reviewed: 2026-07-15
---

# AI Implementation Task Brief Template

## Routing envelope

- Intent:
- Mode: `answer | plan | execute | review | monitor`
- Target:
- Matched skills:
- Authority:
- Risk: `low | medium | high | critical`
- Deliverable:
- Verification:
- Stop conditions:

Preserve the owner's original instruction. Infer this routing envelope automatically when safe, and ask only for the smallest genuinely missing decision.

Before formulating the brief, scan the available skill descriptions. When a skill matches the intent, implicitly apply its playbook. Do not invent unavailable skills, and do not allow a skill to override repository authority, accepted specifications, security, or project invariants.

## Task identity

- Project:
- Repository:
- Branch:
- Task ID:
- Accepted specification:
- Primary goal:
- Original owner instruction:

## Authoritative context to read first

1. Context Vault `AGENTS.md`, entrypoint, and relevant project registration.
2. Repository `AGENTS.md` and nested agent instructions.
3. Accepted specification and amendments.
4. Current project status and continuation notes.
5. Relevant architecture, domain rules, tests, and reference files.
6. Matched skill playbooks required by the routing envelope.

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
- Keep the main agent as the only writer unless the accepted task explicitly authorizes otherwise.
- Delegate only bounded, independent work with explicit intent, target, scope, output limit, and verification requirements.

## Required verification

Run and report the exact commands and results for:

- focused tests:
- full test suite:
- lint or formatting:
- type checks:
- build or artifact verification:
- integration or E2E workflow:
- security checks:
- skill-specific verification:
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

- routed intent and matched skills;
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
