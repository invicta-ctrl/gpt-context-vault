---
schema_version: 1
status: template
scope: projects
last_reviewed: 2026-07-17
---

# Project `AGENTS.md` Template

Use this as a lean operational entrypoint. Keep architecture, rationale, plans, checkpoints, task history, and detailed procedures in dedicated repository files.

---

# AGENTS.md

## Start here

1. Apply the connected Context Vault's root `AGENTS.md` only for account-wide routing and governance.
2. Confirm this repository is authoritative for its specifications, code, decisions, status, plans, checkpoints, tests, and evidence.
3. Read this file and any nested `AGENTS.md` governing the directories being changed.
4. When `.codex/CURRENT.md` exists, read it before broad project documentation.
5. Confirm its `verified_through_commit` exists and is an ancestor of the current branch `HEAD`.
6. Inspect only unexplained commits after that baseline.
7. Read only the active step's listed packet, checkpoint, capsule or map sections, source files, and tests.
8. Stop and report material conflicts instead of silently merging them.

Do not begin by scanning or explaining the whole repository.

## Authority order

1. Earl's current explicit instruction
2. Accepted specification and approved amendments
3. Applicable repository instructions and invariants
4. Active step packet and verified checkpoint
5. Stable project capsule and codebase map
6. Context Vault governance and preferences
7. Older summaries and archived material

Current instructions do not silently bypass the amendment process for material changes.

## Specification gate

- Do not begin non-trivial implementation from chat instructions alone.
- Implement only a written and accepted specification.
- Record material scope, behavior, architecture, dependency, interface, schema, security, migration, or acceptance changes as amendments before implementation.
- A step packet narrows execution scope but cannot override the accepted specification or project invariants.

## Incremental context gate

When `.codex/CURRENT.md` exists:

- treat it as the pointer to the single active step;
- use only its listed files as initial context;
- do not reread completed steps, old checkpoints, unrelated modules, generated output, or the full documentation set;
- expand context only through direct dependencies, targeted symbol references, verification failures, acceptance criteria, repository contradictions, or material risk;
- record each added file and the exact reason it was needed;
- remember that context expansion does not expand implementation scope.

A tracked pointer must reference a known verified implementation commit; it must not attempt to contain the SHA of the same metadata commit containing the pointer.

A broad repository review is allowed only when explicitly accepted, during initial workflow adoption, or when targeted reconciliation cannot restore reliable context.

## Work-unit rules

- Implement one `ACTIVE` step only.
- Prefer the smallest modular and reviewable diff.
- Do not perform unrelated cleanup.
- Preserve established architecture, interfaces, and behavior unless accepted scope changes them.
- Do not add dependencies or broad abstractions without an accepted amendment.
- Keep one writer per branch unless the accepted task explicitly authorizes another arrangement.
- Do not begin the next step automatically.

## Verification and review

- Map every acceptance criterion to implementation and evidence before editing.
- Add or update tests with behavior changes.
- Reproduce bugs with a failing regression test first when practical.
- Run the focused and complete checks listed by the active step.
- Record exact commands and exact results.
- Do not continue on an unexplained failing state.
- Review the complete diff for unintended deletions, dependencies, configuration, interfaces, schemas, access control, sensitive data, invariants, out-of-scope edits, and inaccurate workflow metadata.
- Do not repeat unchanged verification solely because a new session started; confirm the prior evidence is still fresh and applicable.

## Commit, checkpoint, and stop gate

After implementation and verification:

1. Move the active step to `VERIFYING`.
2. Create the implementation commit when authorized and capture its SHA.
3. Write `.codex/checkpoints/<STEP-ID>.md` with the verified baseline, implementation commit, meaningful file effects, interfaces, decisions, preserved invariants, exact results, context expansion, risks, amendments, rollback, and smallest next-step read set.
4. Mark the step `COMPLETE`.
5. Activate the next dependency-satisfied step.
6. Regenerate `.codex/CURRENT.md` with `verified_through_commit` set to the implementation commit.
7. Create a separate handoff metadata commit when authorized.
8. Stop without implementing the next step.

When commits are not authorized, keep the step in `VERIFYING`, record `implementation_commit: pending`, do not activate the next step, and report the pending authorization.

A checkpoint is a compressed technical handoff, not a transcript or raw diff.

## Git safeguards

- Begin non-trivial work from a known clean state on a dedicated branch or isolated worktree.
- Confirm the verified baseline commit is an ancestor of the current branch head and explain later commits.
- Use small descriptive commits after verified milestones.
- Do not push, merge, rewrite history, delete branches, or perform destructive Git operations without explicit authorization.

## Completion report

Report the accepted specification and active step, verified baseline and current state, behavior implemented, files changed, context expansion, acceptance evidence, exact verification results, implementation commit or pending authorization, handoff state, risks, amendments, rollback, checkpoint path, and next active step without implementing it.

A task is not complete merely because code was generated or the interface appears to work.
