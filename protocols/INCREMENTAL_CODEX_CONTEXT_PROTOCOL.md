---
schema_version: 1
status: active
scope: protocols
last_reviewed: 2026-07-17
source_basis: Earl's explicit approval of the incremental Codex workflow on 2026-07-17
---

# Incremental Codex Context Protocol

## Purpose

This protocol prevents Codex and similar coding agents from repeatedly rereading an entire repository before every implementation step.

It creates a small continuation chain of verified plans, bounded step packets, and compressed checkpoints while preserving specification, safety, Git, and evidence requirements.

This protocol applies account-wide to non-trivial software projects unless an active project's authoritative repository defines a stricter process.

## Governing principles

1. Perform one deliberate repository onboarding, not one full repository reconstruction per task.
2. Keep the Context Vault as the account-wide routing and governance layer.
3. Keep live code, plans, pointers, checkpoints, tests, diffs, and technical truth in the active project repository.
4. Use a current-step pointer to tell the agent exactly what to read.
5. Read only the smallest context needed to implement and verify the active step.
6. Expand context through direct evidence, not broad exploratory scans.
7. End every completed step with a compressed technical checkpoint.
8. Never begin the next step automatically after finishing the current one.
9. Never design tracked metadata that must contain the SHA of the same commit creating it.

## Authority boundary

The Context Vault may define this reusable workflow and provide templates, but it must not store a project's live `.codex/CURRENT.md`, implementation plan, codebase map, step status, checkpoint, branch state, test output, diff, or runtime log.

For project-specific work, authority remains:

1. Earl's current explicit instruction;
2. the active project's accepted specification and approved amendments;
3. the active project's repository instructions and invariants;
4. the active project's current-step packet and verified checkpoint;
5. stable Context Vault governance and preferences;
6. older summaries and archived material.

A step packet may narrow execution scope but may not override an accepted specification or project invariant.

## Required project artifacts

| Artifact | Purpose | Update cadence |
|---|---|---|
| `AGENTS.md` | Lean operational rules and entrypoint | Only when repository workflow changes |
| `docs/PROJECT_CAPSULE.md` | Concise stable product, stack, architecture, commands, and invariant summary | When durable architecture or domain rules change |
| `docs/CODEBASE_MAP.md` | Entry points, module boundaries, dependencies, interfaces, tests, and protected paths | When module structure changes |
| `.plans/IMPLEMENTATION_PLAN.md` | Accepted ordered steps, dependencies, and statuses | When accepted plan or step status changes |
| `.plans/steps/<STEP-ID>.md` | Complete implementation packet for one step | Before activation; amended only through approval |
| `.codex/CURRENT.md` | Small pointer to the single active step and bounded initial read set | At every verified handoff |
| `.codex/checkpoints/<STEP-ID>.md` | Verified handoff describing what changed and what later work may rely on | After each completed step |
| `.agents/skills/continue-step/SKILL.md` | Optional reusable continuation command | When workflow mechanics change |

Do not place secrets, generated build output, raw chat dumps, transient logs, or private credentials in these files.

## Required entry sequence

When `.codex/CURRENT.md` exists:

1. Apply the Context Vault's root `AGENTS.md` only for routing and account-wide governance.
2. Resolve the authoritative project repository when needed.
3. Read the project's root and applicable nested `AGENTS.md` files.
4. Read `.codex/CURRENT.md`.
5. Read only its listed step packet, checkpoint, capsule or map sections, source files, and tests.
6. Verify the listed baseline commit is an ancestor of the current branch head and inspect only unexplained commits after that baseline.
7. Perform targeted discovery only when justified by a direct dependency, symbol reference, verification failure, acceptance criterion, repository contradiction, or material risk.
8. Implement and verify only the active step.
9. Write the checkpoint, advance the pointer through a verified handoff, and stop.

`START_HERE.md`, the full Vault index, broad architecture documentation, old specifications, completed task packets, unrelated checkpoints, and unrelated modules are not mandatory reads when the current pointer already identifies the governing context.

## Initial context budget

The default initial project context is limited to:

- the applicable `AGENTS.md` instruction chain;
- `.codex/CURRENT.md`;
- the active step packet;
- the immediately relevant checkpoint;
- explicitly listed project-capsule or codebase-map sections;
- explicitly listed source and test files.

Prohibited starting behavior includes:

- recursively reading all source files;
- reading every Markdown document;
- dumping complete directory contents into the prompt;
- rereading all completed packets or checkpoints;
- reconstructing architecture already captured in a verified capsule;
- scanning unrelated modules “for context”;
- repeating completed tests or reviews when the relevant state has not changed.

A concise directory listing or targeted filename search is allowed when necessary to locate an explicitly relevant dependency.

## Justified context expansion

An unlisted file may be read only when at least one condition is true:

1. A listed file directly imports, calls, extends, configures, or generates it.
2. A targeted symbol search shows it defines or consumes affected behavior.
3. A focused or required verification failure points to it.
4. An acceptance criterion cannot be verified without it.
5. The repository contradicts the step packet, pointer, or checkpoint.
6. A security, migration, compatibility, or domain-invariant risk requires it.

Record:

- the missing information;
- why the listed context was insufficient;
- the smallest additional file or directory set required.

Context expansion does not expand implementation scope.

## Project capsule requirements

`docs/PROJECT_CAPSULE.md` should contain only stable, high-value context:

- product purpose and current delivery mode;
- current stack;
- authoritative module boundaries;
- critical invariants and stable interfaces;
- standard development and verification commands;
- links to deeper documents read only when needed;
- the implementation commit or date against which it was verified.

Do not turn the capsule into a duplicate README, architecture manual, changelog, or task history.

## Codebase-map requirements

`docs/CODEBASE_MAP.md` should identify current:

- feature and service entry points;
- module responsibilities and dependency direction;
- public interfaces later steps may use;
- generated or protected paths;
- test locations;
- nested instruction areas;
- targeted symbol or filename hints.

The map must describe actual structure, not aspirational architecture.

## Implementation-plan requirements

`.plans/IMPLEMENTATION_PLAN.md` must:

- reference an accepted specification;
- use unique step identifiers;
- order steps by dependency;
- allow exactly one `ACTIVE` step unless an accepted amendment authorizes isolated parallel work;
- distinguish `BLOCKED`, `READY`, `ACTIVE`, `VERIFYING`, and `COMPLETE`;
- point each step to a dedicated packet;
- avoid duplicating every packet's full content.

Material changes to scope, behavior, architecture, dependencies, interfaces, schema, security, migration, or acceptance criteria require an accepted amendment before the plan or packet changes.

## Current-pointer requirements

`.codex/CURRENT.md` must remain small and operational. It should state:

- active branch or worktree;
- `verified_through_commit`: the latest verified implementation commit the active step may rely on;
- active step ID;
- exact reading order;
- initial source and test files;
- initially off-limits areas;
- previous verified result;
- active objective;
- targeted-discovery rules;
- required verification;
- completion and stop actions.

`verified_through_commit` must be an ancestor of the current branch head. Later commits between it and `HEAD` must be explainable as handoff metadata or explicitly documented work.

Do not use an `expected_head` field that attempts to contain the SHA of the same commit containing `.codex/CURRENT.md`.

## Step-packet requirements

Each `.plans/steps/<STEP-ID>.md` must define:

- one primary objective;
- accepted specification and amendment references;
- dependencies and verified baseline state;
- included and excluded behavior;
- allowed and off-limits files or modules;
- established interfaces and invariants;
- implementation and edge-case requirements;
- acceptance criteria;
- focused and complete verification commands;
- manual checks when relevant;
- rollback or recovery requirements;
- required checkpoint content.

A step packet should provide enough context to implement the step without a broad repository scan.

## Checkpoint requirements

Each `.codex/checkpoints/<STEP-ID>.md` must record only decision-relevant continuation context:

- completed step and date;
- verified baseline commit;
- implementation commit when one was created;
- implemented behavior;
- files changed and their meaningful effects;
- interfaces added, changed, or confirmed;
- decisions and assumptions later steps may rely on;
- preserved invariants;
- exact verification commands and results;
- acceptance-criteria evidence;
- context expansion and justification;
- known limitations and risks;
- amendments and rollback information;
- smallest recommended read set for the next step.

A checkpoint is a compressed technical handoff, not a transcript, raw diff, or narrative diary.

## Commit and handoff sequencing

When Git commits are authorized, use two logical commits for a completed step:

1. **Implementation commit** — code, tests, and directly required product documentation for the active step.
2. **Handoff metadata commit** — checkpoint, plan status, next step packet when needed, and regenerated `.codex/CURRENT.md` referencing the known implementation commit SHA.

This sequencing avoids a self-referential commit hash.

The handoff metadata commit may reference the implementation commit through `verified_through_commit`. It does not need to contain its own SHA. The next agent verifies that the implementation commit is an ancestor of the current `HEAD` and that later commits are expected workflow metadata.

When commits are not yet authorized:

- keep the step in `VERIFYING`;
- prepare the checkpoint with `implementation_commit: pending`;
- do not mark the step `COMPLETE` or activate the next step;
- report the exact pending authorization.

Do not fabricate a commit SHA, repeatedly amend a commit to chase its changing SHA, or claim a handoff is complete before its evidence is durable.

## Step lifecycle

```text
READY -> ACTIVE -> VERIFYING -> COMPLETE
```

A step may become `BLOCKED` when a dependency, owner decision, repository conflict, or verification failure prevents safe completion.

For each step:

1. Confirm the pointer, branch, clean or understood worktree, and verified baseline ancestry.
2. Read the bounded context.
3. Map acceptance criteria to planned code, tests, and evidence.
4. Implement the smallest valid change.
5. Run focused verification.
6. Run the required complete verification gate.
7. Review the full diff.
8. Move the step to `VERIFYING`.
9. Create the implementation commit when authorized and capture its SHA.
10. Write the checkpoint referencing that implementation commit.
11. Mark the step `COMPLETE`.
12. Activate the next dependency-satisfied step and regenerate `.codex/CURRENT.md` with `verified_through_commit` set to the implementation commit.
13. Create the handoff metadata commit when authorized.
14. Stop without implementing the next step.

## Session continuity

Use the same Codex session for adjacent steps in the same tightly related feature only while context remains clear and reliable.

Start a fresh session when:

- entering a different major module or milestone;
- the conversation is long or heavily compacted;
- the repository changed outside the tracked workflow;
- the checkpoint, capsule, or map may be stale;
- a security-sensitive or architecture-changing task requires independent review.

A fresh session resumes from `.codex/CURRENT.md` and the verified checkpoint rather than rereading the repository.

## Parallel work

Parallel agents or worktrees are allowed only when:

- the accepted plan identifies independent steps;
- each step has its own branch or worktree and context packet;
- allowed files do not overlap;
- one orchestrator owns integration;
- one writer owns each branch unless explicitly authorized otherwise.

Do not use parallel agents merely to accelerate a tightly coupled feature.

## Staleness and invalidation

Treat a capsule, map, pointer, packet, or checkpoint as stale when:

- its verified commit no longer exists in active history;
- the verified commit is not an ancestor of the current branch head;
- unexplained commits exist after the verified baseline;
- module paths, interfaces, or invariants changed materially;
- a merge introduced relevant unrecorded work;
- required verification no longer passes;
- the accepted specification or amendment changed;
- actual code contradicts the document.

Perform the smallest targeted reconciliation necessary. A full repository re-onboarding is justified only when targeted reconciliation cannot restore reliable context.

## Automation

Projects may add deterministic commands such as:

- `step:status`;
- `step:activate`;
- `step:complete`;
- `context:verify`.

They should verify:

- exactly one step is active when expected;
- referenced files exist;
- the current branch is correct;
- `verified_through_commit` exists and is an ancestor of `HEAD`;
- commits after the verified baseline are explained;
- required checkpoints and dependencies exist;
- the pointer and plan agree;
- no completed step remains active;
- no step advances without verification evidence.

Automation may update workflow metadata, but it must not fabricate evidence or silently approve amendments.

## Adoption rule

For an existing project, adoption should be one accepted repository-maintenance or architecture task:

1. inspect the repository once from a known state;
2. create and verify the project capsule and codebase map;
3. convert the accepted roadmap or specification into ordered step packets;
4. create the initial current pointer using a verified baseline commit;
5. add the optional continuation skill and validation scripts;
6. run the project's required checks;
7. record a baseline checkpoint or adoption handoff;
8. stop before implementing unrelated product behavior.

## Completion evidence

A step is complete only when its durable checkpoint contains exact evidence for every acceptance criterion, its implementation commit is identified when applicable, and the current pointer has advanced through a handoff without beginning the next step.
