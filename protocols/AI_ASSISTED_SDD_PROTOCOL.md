---
schema_version: 1
status: active
scope: protocols
last_reviewed: 2026-07-17
source_basis: roadmap.sh/vibe-coding and Earl's approved incremental Codex workflow
---

# AI-Assisted Spec-Driven Development Protocol

## Governing principle

AI-generated software must be developed through controlled, specification-driven engineering rather than blind acceptance of generated code. The human project owner remains the architect, reviewer, risk owner, and final decision-maker.

This protocol applies account-wide to non-trivial software projects unless an active project's authoritative repository defines a stricter process.

For token-efficient continuation and bounded repository retrieval, also follow [`INCREMENTAL_CODEX_CONTEXT_PROTOCOL.md`](INCREMENTAL_CODEX_CONTEXT_PROTOCOL.md).

## Required operating sequence

For every non-trivial project task:

1. Start with the connected Context Vault's root `AGENTS.md` and retrieve only the minimum relevant routing context.
2. Resolve the active project's authoritative repository.
3. Read the repository's applicable `AGENTS.md` files.
4. When `.codex/CURRENT.md` exists, read it before broad project documentation and use its bounded context set.
5. Retrieve or prepare a written specification defining intended behavior and acceptance.
6. Record assumptions, risks, exclusions, affected files, off-limits areas, acceptance criteria, and verification requirements.
7. Obtain acceptance of the specification before implementation.
8. Convert accepted work into focused implementation steps when more than one work unit is required.
9. Implement one active task or vertical slice at a time.
10. Review the complete diff before accepting the change.
11. Run every required verification command.
12. Record exact evidence, risks, known limitations, amendments, and rollback information.
13. Move the active step to `VERIFYING` and create the verified implementation commit when authorized.
14. Complete the project-local checkpoint, plan transition, and current-step pointer through the separate handoff metadata commit required by the incremental context protocol.
15. Stop before implementing the next step.

When commits are not authorized, keep the step in `VERIFYING`, record the implementation commit as pending, do not activate the next step, and report the pending authorization.

Small, obvious, low-risk edits may use a lightweight specification, but intended behavior, exact scope, and verification must still be explicit.

## Specification gate

A specification must define, where applicable:

- problem and intended outcome;
- users and user flows;
- included and excluded scope;
- functional and non-functional requirements;
- data structures and domain invariants;
- interfaces, APIs, and compatibility requirements;
- security and privacy requirements;
- error and edge-case behavior;
- affected and off-limits files;
- migration and rollback strategy;
- test and verification plan;
- acceptance criteria;
- unresolved assumptions and decisions.

Non-trivial implementation must not begin while material requirements remain unresolved or the specification remains unaccepted.

## Planning and step decomposition

When an accepted change requires multiple work units:

- create an ordered project-local implementation plan;
- use unique step identifiers;
- define dependencies;
- allow only one active step unless an accepted amendment authorizes isolated parallel work;
- give every step a dedicated packet with scope, files, acceptance criteria, and verification;
- end each step with a compressed technical checkpoint;
- advance the project-local `.codex/CURRENT.md` pointer without beginning the next step.

The complete requirements for these artifacts are defined in [`INCREMENTAL_CODEX_CONTEXT_PROTOCOL.md`](INCREMENTAL_CODEX_CONTEXT_PROTOCOL.md).

## Task-brief requirements

Each implementation instruction must include or reference:

- one primary goal;
- accepted specification and amendment references;
- active step identifier;
- exact included and excluded scope;
- constraints and prohibited changes;
- allowed and initially off-limits files or modules;
- relevant interfaces, invariants, and reference files;
- expected tests and verification commands;
- required evidence and completion report;
- rollback or recovery instructions when risk is material;
- stop condition preventing automatic work on the next step.

When `.codex/CURRENT.md` and an active step packet exist, the task brief should reference them rather than repeat the complete project history.

## Context discipline

- Keep repository `AGENTS.md` files lean, current, and operational.
- Store durable architecture and rationale in authoritative project documentation.
- Store the bounded active read set in `.codex/CURRENT.md`.
- Store implementation detail for one step in its step packet.
- Store verified continuation context in the immediately relevant checkpoint.
- Remove stale, reversed, temporary, or contradictory instructions.
- Use one feature or tightly related workstream per session.
- Start a fresh context for unrelated work or milestone boundaries.
- Retrieve only the files needed to make and verify the current decision.
- Never replace authoritative repository facts with conversational assumptions.
- Never begin a task by recursively reading the whole repository when a reliable current pointer exists.
- Expand context only through direct dependencies, targeted symbol searches, verification failures, acceptance criteria, or material risk.
- Record why additional context was necessary.

## Repository onboarding

A complete repository read is appropriate when establishing the initial project capsule and codebase map, reconciling a materially stale handoff, or performing an accepted repository-wide architecture review.

It is not appropriate as the default start of every feature step.

After onboarding, later sessions should resume from the verified project-local capsule, codebase map, implementation plan, current pointer, active packet, and relevant checkpoint.

## Implementation discipline

- Prefer small, modular, reviewable changes.
- Do not perform unrelated cleanup during a scoped task.
- Do not silently introduce dependencies, abstractions, API changes, schema changes, or architectural decisions.
- Preserve existing public behavior unless the accepted specification explicitly changes it.
- Use established, supported technologies unless the accepted architecture documents another choice.
- Treat generated code as untrusted until reviewed and verified.
- Context expansion does not expand implementation scope.
- Do not begin the next step merely because the current step finished early.

## Diff-review gate

Before accepting generated changes, review:

- deleted or renamed files;
- public API and interface changes;
- new dependencies;
- configuration changes;
- schema and migration changes;
- authentication and authorization logic;
- input validation and sensitive-data handling;
- hard-coded secrets or credentials;
- off-limits files;
- business-rule or domain-invariant changes;
- behavior outside the accepted scope;
- workflow metadata changes to plans, pointers, and checkpoints.

Unexpected material changes must be rejected or documented as a proposed amendment.

## Verification gate

After every accepted implementation unit:

- run relevant focused tests;
- run the complete required test suite;
- run linting and formatting checks;
- run type checks where applicable;
- run build and artifact verification;
- exercise critical workflows through integration or end-to-end tests;
- run security or migration checks when required;
- record exact commands and results;
- map every acceptance criterion to evidence.

A bug fix must normally begin with a reproducible failing regression test. Work must not continue on top of an unexplained failing verification state.

Do not repeat already completed verification solely because a new agent session began when the relevant commit, environment, artifact, and external state have not changed. Verify freshness before relying on earlier evidence.

## Checkpoint gate

A completed implementation step must write a project-local checkpoint recording:

- verified baseline commit;
- implementation commit or explicit pending state;
- implemented behavior;
- meaningful file effects;
- interfaces later steps may rely on;
- preserved invariants;
- exact verification results;
- acceptance-criteria evidence;
- context expansion and justification;
- risks, limitations, and amendments;
- rollback information;
- smallest recommended initial read set for the next step.

The checkpoint, plan transition, current pointer, and any capsule or codebase-map verification metadata that reference the implementation SHA belong in the handoff metadata commit.

A checkpoint must not be a raw transcript, complete diff, or duplicated specification.

## Git discipline

- Start from a known clean working state.
- Use a dedicated branch or isolated worktree for non-trivial work.
- Make small, descriptive commits after verified milestones.
- Use the implementation-commit-then-handoff-metadata-commit sequence defined by the incremental context protocol when step metadata references the verified implementation SHA.
- Use Git history for rollback and recovery.
- Do not automatically push, merge, rewrite history, delete branches, or perform destructive actions without explicit authorization.
- Keep each pull request aligned to one accepted scope as closely as practical.
- Do not allow multiple writers to modify the same branch or overlapping files unless explicitly authorized and coordinated.

## Security and high-risk changes

The following require heightened review and explicit authorization:

- authentication and authorization;
- payments and financial operations;
- personal or confidential data;
- production configuration;
- secrets and environment handling;
- database migrations;
- destructive or irreversible operations;
- public API compatibility;
- access-control and role changes.

Secrets must never be committed. Schema changes require a forward plan, reversal plan, compatibility analysis, test plan, and rollback procedure before implementation.

Security, migration, and compatibility risks are valid reasons to expand context beyond the pointer's initial file set, but the expansion must remain targeted and justified.

## Debugging discipline

- Capture the exact error and reproduction steps.
- Compare expected and observed behavior.
- Inspect logs, tests, state, and relevant runtime evidence.
- Form and rank possible causes before broad changes.
- Change one variable at a time.
- Use targeted symbol and dependency searches before repository-wide exploration.
- After repeated unsuccessful attempts, stop random modification, reassess assumptions, and restart from a clean checkpoint or reconciled context.
- Preserve a regression test for every confirmed defect when practical.

## Repeatable workflows

Once a high-stakes workflow has succeeded consistently, convert it into a reusable project template, deterministic script, or skill. Priority workflows include:

- feature specification;
- implementation planning;
- active-step continuation;
- checkpoint creation;
- regression-test generation;
- security review;
- safe refactoring;
- schema migration planning;
- release verification;
- repository handoff and continuation reporting.

## Completion evidence

A completed task must report:

- routed intent and matched skills;
- accepted scope and active step;
- verified baseline and current repository state;
- files changed;
- behavior implemented;
- context expansion and justification;
- verification commands and exact results;
- acceptance-criteria evidence;
- implementation commit or pending authorization;
- handoff metadata state;
- security or migration review when applicable;
- risks and known limitations;
- amendments made;
- rollback information;
- checkpoint path;
- next active step without implementing it.

No task is complete solely because code was generated or the interface appears to work.
