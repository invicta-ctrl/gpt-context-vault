---
schema_version: 1
status: template
scope: projects
last_reviewed: 2026-07-17
---

# Project `AGENTS.md` Template

Use this as a lean repository-level entrypoint. Keep project history, detailed architecture, plans, checkpoints, and rationale in dedicated files rather than expanding `AGENTS.md` indefinitely.

---

# AGENTS.md

## Required entry sequence

1. Apply the connected Context Vault's root `AGENTS.md` only for account-wide routing and governance.
2. Confirm this repository is authoritative for project requirements, code, decisions, implementation state, tests, and technical documentation.
3. Read this file and any nested `AGENTS.md` files governing the directories being changed.
4. When `.codex/CURRENT.md` exists, read it before broad project documentation.
5. Read only the active step packet, checkpoint, capsule or map sections, source files, and tests listed by the pointer.
6. Stop and report material conflicts. Earl's current instruction has highest authority, but accepted scope changes require amendments before implementation.

Do not start by scanning or explaining the entire repository.

## Skills and intent

Scan the available skill descriptions and apply only the smallest directly relevant skill set.

Infer this routing envelope internally:

```text
INTENT: <primary intent>
MODE: <answer | plan | execute | review | monitor>
TARGET: <repository, system, file, artifact, or topic>
SKILLS: <matched skills or none>
AUTHORITY: <governing specifications and files>
RISK: <low | medium | high | critical>
DELIVERABLE: <required completed state>
VERIFICATION: <evidence required>
```

Skills may refine execution but may not override safety, current instructions, repository authority, accepted specifications, or project invariants.

## Authority order

1. Earl's current explicit instruction
2. Accepted specification and approved amendments
3. Repository instructions and invariants
4. Active step packet and verified checkpoint
5. Stable project capsule and codebase map
6. Context Vault governance and preferences
7. Older summaries and archived material

A step packet narrows execution scope but cannot override an accepted specification or invariant.

## Specification gate

- Do not begin non-trivial implementation from chat instructions alone.
- Locate or prepare a written specification covering scope, exclusions, user flows, data structures, invariants, risks, verification, rollback, and acceptance criteria.
- Implement only after the specification is accepted.
- Record material scope, behavior, architecture, dependency, interface, schema, security, or acceptance changes as amendments before implementation.

## Incremental context gate

When `.codex/CURRENT.md` exists:

- Treat it as the pointer to the single active step.
- Use only its listed files as initial context.
- Do not reread completed steps, old checkpoints, unrelated modules, generated output, or the full documentation set.
- Expand context only through direct imports or calls, targeted symbol references, verification failures, acceptance criteria, repository contradictions, or material risk.
- Record the additional file and exact reason for reading it.
- Context expansion does not expand implementation scope.

A broad repository review is allowed only when explicitly accepted, when adopting this workflow for the first time, or when targeted reconciliation cannot restore reliable context.

## Work-unit discipline

- Implement one `ACTIVE` step only.
- Prefer the smallest clear, modular, reviewable diff.
- Do not perform unrelated cleanup.
- Do not add dependencies, abstractions, public API changes, schema changes, architecture changes, or new behavior without accepted scope.
- Preserve existing behavior unless the accepted specification explicitly changes it.
- Keep the main agent as the only writer to the branch unless the accepted task authorizes another arrangement.
- Do not begin the next step automatically.

## Testing and verification

- Map every acceptance criterion to code, tests, and evidence before editing.
- Add or update tests with behavior changes.
- For bug fixes, reproduce the defect with a failing regression test first when practical.
- Run focused checks, the complete required suite, lint, formatting, type checks, build, artifact, integration, E2E, and security checks applicable to the project.
- Record exact commands and results.
- Do not stack work on an unexplained failing state.
- Do not repeat unchanged verification merely because a new session started; confirm that its commit, artifact, environment, and external state remain valid.

## Diff review

Review every final diff for unintended:

- deletions or renames;
- dependency or configuration changes;
- public interface changes;
- schema or migration changes;
- authentication or authorization changes;
- hard-coded secrets;
- sensitive-data exposure;
- domain-invariant changes;
- edits outside accepted scope;
- inaccurate plan, pointer, or checkpoint updates.

High-risk changes require explicit authorization, rollback planning, and additional verification.

## Checkpoint and handoff

Before declaring the active step complete:

1. Review the complete diff.
2. Verify every acceptance criterion.
3. Write `.codex/checkpoints/<STEP-ID>.md` with meaningful file effects, interfaces, decisions, preserved invariants, exact results, risks, amendments, rollback, and the smallest next-step read set.
4. Mark the step `COMPLETE` in `.plans/IMPLEMENTATION_PLAN.md`.
5. Activate the next dependency-satisfied step.
6. Regenerate `.codex/CURRENT.md` for that step.
7. Commit when authorized.
8. Stop without implementing the next step.

A checkpoint is a compressed technical handoff, not a transcript or raw diff.

## Git discipline

- Begin non-trivial work from a clean state on a dedicated branch or isolated worktree.
- Confirm the expected starting commit before editing.
- Use small descriptive commits after verified milestones.
- Do not push, merge, rewrite history, delete branches, or perform destructive Git operations without explicit authorization.
- Use Git checkpoints for recovery rather than relying on AI undo behavior.

## Completion report

Every completed task must state:

- routed intent and skills used;
- accepted specification and active step;
- starting and ending repository state;
- behavior implemented;
- files changed;
- context expansion and justification;
- acceptance criteria and evidence;
- exact verification commands and results;
- risks, limitations, amendments, and rollback;
- checkpoint path;
- next active step without implementing it.

A task is not complete merely because code was generated or the interface appears to work.
