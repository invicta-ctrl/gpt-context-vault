---
schema_version: 1
status: active
scope: account-wide-project-work
last_reviewed: 2026-07-13
---

# Spec-Driven Development Protocol

## Purpose

Use Spec-Driven Development (SDD) for non-trivial work in every current and future project. A project should define the intended outcome, scope, requirements, acceptance criteria, permissions, risks, and verification before consequential implementation begins.

This protocol is account-wide guidance. An active project's authoritative repository, `AGENTS.md`, ruleset, and accepted specification control the details of that project.

## Authority order

1. Earl's current explicit instruction.
2. The active project's authoritative repository, including `AGENTS.md` and governing rules.
3. The accepted active project specification.
4. Active Context Vault files relevant to routing and working preferences.
5. Chat history, local notes, and archived context.

Do not use the Context Vault to override newer project facts. Do not use chat history as a substitute for a committed or otherwise durable accepted specification.

## When SDD is required

Create and accept a spec before any non-trivial:

- software feature, behavior change, defect repair, refactor, integration, schema/API change, security change, migration, deployment, or external write;
- research, academic, design, operations, process, or documentation project with multiple requirements or meaningful consequences;
- project-wide rule, workflow, architecture, data, or governance change;
- work likely to span multiple sessions, agents, files, or tools.

A typo, formatting-only correction, or deterministic regeneration from an already accepted source change may use a short inline spec. Emergency security work may proceed only when delay increases risk; add a retrospective spec and evidence in the same change record.

## Required lifecycle

Use this sequence:

1. **Ground** — read `START_HERE.md`, `CONTEXT_INDEX.md`, and only the relevant vault files; then inspect the active project repository.
2. **Specify** — write one bounded spec with scope, non-goals, requirements, acceptance criteria, permissions, risks, verification, and stop conditions.
3. **Review** — resolve ambiguity and conflicts before implementation.
4. **Accept** — Earl approves the spec, or explicitly delegates approval.
5. **Plan** — break the accepted requirements into small tasks.
6. **Implement** — perform only the accepted work.
7. **Verify** — map evidence to every acceptance criterion.
8. **Close** — update status, decisions, handoff, and project records.

Suggested statuses:

`DRAFT` → `IN_REVIEW` → `ACCEPTED` → `IMPLEMENTING` → `VERIFYING` → `VERIFIED`

Alternative terminal statuses are `CANCELLED` and `SUPERSEDED`.

## Minimum specification

Every non-trivial spec should contain:

- stable ID, title, owner, status, dates, and approval record;
- authority and source references;
- problem statement and intended outcome;
- scope and non-goals;
- assumptions and constraints;
- numbered requirements;
- numbered acceptance criteria;
- implementation plan and task list;
- external-write and destructive-action permissions;
- security, privacy, and data considerations;
- verification plan and required evidence;
- rollback, recovery, or reversibility expectations;
- risks, open questions, and stop conditions;
- decision/amendment log;
- completion evidence and handoff.

Use [`templates/PROJECT_SPEC_TEMPLATE.md`](../templates/PROJECT_SPEC_TEMPLATE.md) when the project does not already provide a stricter template.

## No-implementation gate

Do not begin consequential implementation while the spec is `DRAFT` or `IN_REVIEW`. Planning, repository inspection, research, and spec drafting may continue, but code changes, external writes, deployments, migrations, destructive actions, and final deliverables must wait for acceptance unless Earl explicitly authorizes an exception.

## Amendment rule

Stop implementation and return the spec to review when a material change is needed, including:

- new or removed requirements;
- weakened or replaced acceptance criteria;
- expanded scope or affected systems;
- changed privacy, security, authorization, or data behavior;
- changed external-write, deployment, migration, or destructive-action permission;
- a new risk that invalidates the accepted plan.

Record the amendment, affected IDs, reason, approval, and date. Do not silently treat scope expansion as a task-list adjustment.

## Traceability

A completion record must identify:

- the spec path or durable location;
- spec status and acceptance record;
- requirements completed;
- acceptance-criteria evidence;
- amendments and deviations;
- tests/checks run and exact results;
- external actions performed and not performed;
- unresolved defects or blockers;
- the authoritative project status after the change.

## Future-project bootstrap

For every new project repository:

1. add a root `AGENTS.md` or equivalent instruction file;
2. add an SDD rule using [`templates/AGENTS_SDD_BLOCK.md`](../templates/AGENTS_SDD_BLOCK.md);
3. create a `specs/` directory and project-specific template;
4. register the repository in `projects/PROJECT_REGISTRY.md` when it becomes authoritative;
5. keep the Context Vault as the routing layer and the project repository as the source of truth.

## Privacy and retrieval boundary

Use only the minimum relevant vault context. Do not retrieve unrelated personal information. Do not commit secrets, raw chat dumps, private messages, credentials, hidden metadata, or unsupported claims into a spec or project repository.
