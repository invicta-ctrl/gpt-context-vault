---
schema_version: 1
status: template
scope: projects
last_reviewed: 2026-07-17
---

# AI Implementation Task Brief Template

Use this template for one accepted implementation step. When `.codex/CURRENT.md` and a step packet already exist, reference them instead of duplicating their full contents.

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

Preserve the owner's original instruction. Infer this envelope when safe and ask only for a genuinely blocking owner decision.

## Task identity

- Project:
- Repository:
- Branch or worktree:
- Verified baseline commit:
- Task or step ID:
- Accepted specification:
- Approved amendments:
- Primary objective:
- Original owner instruction:

## Baseline validation

Before reading broadly or editing:

- confirm the verified baseline commit exists and is an ancestor of the current branch `HEAD`;
- inspect only later commits not already explained as handoff metadata;
- stop when unexplained later implementation changes affect the active step;
- confirm the worktree is clean or every existing change is understood and non-overlapping.

A tracked pointer must not attempt to contain the SHA of the same commit containing that pointer.

## Bounded context to read

Read in this order:

1. applicable repository `AGENTS.md` files;
2. `.codex/CURRENT.md` when present;
3. the active step packet;
4. the immediately relevant checkpoint;
5. only project-capsule and codebase-map sections listed by the pointer;
6. only source and test files listed by the pointer;
7. matched skill playbooks required by the routing envelope.

Do not begin with a broad repository scan. Do not automatically read every specification, architecture document, status file, completed step, checkpoint, or feature directory.

## Targeted context expansion

An unlisted file may be read only when required by:

- a direct import, call, extension, configuration, or generation relationship;
- a targeted symbol reference;
- a focused or required verification failure;
- an acceptance criterion;
- a repository contradiction;
- a material security, migration, compatibility, or invariant risk.

Record the file and why the listed context was insufficient. Additional context does not authorize additional implementation scope.

## Exact scope

### Required behavior

- 

### Allowed files or modules

- 

### Initially off-limits files, modules, and behavior

- 

### Explicit non-goals

- 

## Constraints and invariants

- Preserve:
- Do not introduce:
- Compatibility requirements:
- Security and privacy requirements:
- Performance or accessibility requirements:

## Established interfaces

- `<interface>`:

## Assumptions

List only assumptions that affect this step. Verify material assumptions against bounded repository context before editing.

- 

## Required planning step

Before editing, map each acceptance criterion to:

- expected files or modules;
- implementation action;
- focused test or evidence;
- complete verification command;
- rollback or recovery mechanism.

Do not implement beyond the accepted active step.

## Implementation rules

- Complete one focused task or vertical slice.
- Prefer the smallest clear diff.
- Preserve established architecture and conventions.
- Do not add dependencies, abstractions, schema changes, public API changes, architecture changes, or unrelated cleanup without an accepted amendment.
- Add or update tests with behavior changes.
- For bug fixes, reproduce the defect with a failing regression test first when practical.
- Do not place credentials or private data in the repository.
- Keep the main agent as the only writer unless the accepted task explicitly authorizes another arrangement.
- Do not begin the next step automatically.

## Acceptance criteria

- [ ] AC-001:
- [ ] AC-002:

## Required verification

Run and report exact commands and results for applicable checks:

- focused tests:
- full test suite:
- lint or formatting:
- type checks:
- build or artifact verification:
- integration or E2E workflow:
- security checks:
- project-specific checks:
- manual checks:

Do not continue stacking changes on an unexplained failing state.

## Diff-review checklist

Confirm that the final diff contains no unintended:

- file deletions or renames;
- public interface changes;
- dependencies;
- configuration or environment changes;
- schema or migration changes;
- access-control changes;
- embedded credentials;
- business-rule or invariant changes;
- edits outside accepted scope;
- inaccurate plan, pointer, checkpoint, or commit-reference changes.

## Commit, checkpoint, and stop condition

After implementation and verification:

1. move the active step to `VERIFYING`;
2. create the implementation commit when authorized and capture its SHA;
3. write `.codex/checkpoints/<STEP-ID>.md` referencing the verified baseline and implementation commit;
4. record meaningful file effects, interfaces, decisions, preserved invariants, exact results, acceptance evidence, context expansion, risks, amendments, and rollback;
5. mark the step `COMPLETE`;
6. activate the next dependency-satisfied step;
7. regenerate `.codex/CURRENT.md` with `verified_through_commit` set to the known implementation commit;
8. create a separate handoff metadata commit when authorized;
9. stop without implementing the next step.

When commits are not authorized, keep the step in `VERIFYING`, use `implementation_commit: pending`, do not activate the next step, and report the pending authorization.

## Completion report

Return:

- routed intent and matched skills;
- accepted specification and active step;
- verified baseline and current repository state;
- behavior implemented;
- files changed;
- context expansion and exact justification;
- acceptance criteria with evidence;
- exact verification commands and results;
- implementation commit or pending authorization;
- handoff metadata state;
- amendments;
- risks and known limitations;
- rollback information;
- checkpoint path;
- next active step without implementation.

Do not claim completion solely because code was generated or the interface appeared to work.
