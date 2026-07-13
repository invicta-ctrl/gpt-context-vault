---
schema_version: 1
status: active
scope: protocols
last_reviewed: 2026-07-13
source_basis: roadmap.sh/vibe-coding
---

# AI-Assisted Spec-Driven Development Protocol

## Governing principle

AI-generated software must be developed through controlled, specification-driven engineering rather than blind acceptance of generated code. The human project owner remains the architect, reviewer, risk owner, and final decision-maker.

This protocol applies account-wide to non-trivial software projects unless an active project's authoritative repository defines a stricter process.

## Required operating sequence

For every non-trivial project task:

1. Start with the connected Context Vault and retrieve only the minimum relevant context.
2. Read the active repository's `AGENTS.md`, authoritative documentation, current status, ruleset, and accepted specification.
3. Confirm the authoritative source and current repository state before proposing changes.
4. Prepare or retrieve a written feature specification.
5. Record assumptions, risks, exclusions, affected files, off-limits areas, acceptance criteria, and verification requirements.
6. Obtain acceptance of the specification before implementation.
7. Implement one focused task or vertical slice at a time.
8. Review the complete diff before accepting the change.
9. Run all required verification commands.
10. Record exact evidence, risks, known limitations, and amendments.
11. Commit only verified, intentionally scoped changes.
12. Update project status and continuation documentation when materially affected.

Small, obvious, low-risk edits may use a lightweight specification, but the intended behavior and verification method must still be explicit.

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

## Task-brief requirements

Each implementation instruction must include:

- one primary goal;
- accepted specification reference;
- exact scope;
- constraints and prohibited changes;
- relevant reference files or examples;
- expected files or modules;
- required planning step;
- required verification commands;
- required evidence and completion report;
- rollback or recovery instructions when risk is material.

## Context discipline

- Keep repository agent instructions lean, current, and operational.
- Store durable architecture and rationale in authoritative project documentation.
- Remove stale, reversed, temporary, or contradictory instructions.
- Use one feature or tightly related workstream per session.
- Start a fresh context for unrelated work.
- Retrieve only the files needed to make the current decision.
- Never replace authoritative repository facts with conversational assumptions.

## Implementation discipline

- Prefer small, modular, reviewable changes.
- Do not perform unrelated cleanup during a scoped task.
- Do not silently introduce dependencies, abstractions, API changes, schema changes, or architectural decisions.
- Preserve existing public behavior unless the accepted specification explicitly changes it.
- Use established, supported technologies unless the accepted architecture documents another choice.
- Treat generated code as untrusted until reviewed and verified.

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
- behavior outside the accepted scope.

Unexpected material changes must be rejected or documented as a proposed amendment.

## Verification gate

After every accepted implementation unit:

- run relevant focused tests;
- run the complete required test suite;
- run linting and formatting checks;
- run type checks where applicable;
- run build and artifact verification;
- exercise critical workflows through integration or end-to-end tests;
- record exact commands and results.

A bug fix must normally begin with a reproducible failing regression test. Work must not continue on top of an unexplained failing verification state.

## Git discipline

- Start from a known clean working state.
- Use a dedicated branch for non-trivial work.
- Make small, descriptive commits after verified milestones.
- Use Git history for rollback and recovery.
- Do not automatically push, merge, rewrite history, delete branches, or perform destructive actions without explicit authorization.
- Keep each pull request aligned to one accepted scope as closely as practical.

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

## Debugging discipline

- Capture the exact error and reproduction steps.
- Compare expected and observed behavior.
- Inspect logs, tests, state, and relevant runtime evidence.
- Form and rank possible causes before broad changes.
- Change one variable at a time.
- After repeated unsuccessful attempts, stop random modification, reassess assumptions, and restart from a clean context or checkpoint.
- Preserve a regression test for every confirmed defect when practical.

## Repeatable workflows

Once a high-stakes workflow has succeeded consistently, convert it into a reusable project template or skill. Priority workflows include:

- feature specification;
- implementation task briefing;
- regression-test generation;
- security review;
- safe refactoring;
- schema migration planning;
- release verification;
- repository handoff and continuation reporting.

## Completion evidence

A completed task must report:

- accepted scope;
- files changed;
- behavior implemented;
- verification commands and exact results;
- acceptance-criteria evidence;
- security or migration review when applicable;
- risks and known limitations;
- amendments made;
- rollback information;
- recommended next accepted task.

No task is complete solely because code was generated or the interface appears to work.
