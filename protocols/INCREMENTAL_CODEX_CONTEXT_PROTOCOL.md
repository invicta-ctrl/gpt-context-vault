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

It establishes a small, explicit context chain that lets an agent continue work from verified plans and checkpoints while preserving the Context Vault's specification, safety, and evidence requirements.

This protocol applies account-wide to non-trivial software projects unless an active project's authoritative repository defines a stricter process.

## Governing principles

1. Perform one deliberate repository onboarding, not one full repository reconstruction per task.
2. Keep the Context Vault as the account-wide routing and governance layer.
3. Keep live code, project state, plans, step packets, checkpoints, tests, and technical truth in the active project repository.
4. Use a current-step pointer to tell the agent exactly what to read.
5. Read only the smallest context needed to implement and verify the active step.
6. Expand context through direct evidence, not broad exploratory scans.
7. End every completed step with a compressed technical checkpoint.
8. Never begin the next step automatically after finishing the current one.

## Authority boundary

The Context Vault may define this reusable workflow and provide templates, but it must not store a project's live `.codex/CURRENT.md`, implementation plan, source map, step status, task checkpoint, branch state, test output, or runtime logs.

For project-specific work, authority remains:

1. Earl's current explicit instruction;
2. the active project's accepted specification and approved amendments;
3. the active project's repository instructions and invariants;
4. the active project's current-step packet and verified checkpoint;
5. stable Context Vault governance and preferences;
6. older summaries and archived material.

A current-step packet may narrow execution scope, but it may not override an accepted specification or project invariant.

## Required project artifacts

Projects adopting this protocol should maintain these repository-local artifacts:

| Artifact | Purpose | Update cadence |
|---|---|---|
| `AGENTS.md` | Lean operational rules and entrypoint | Only when repository workflow changes |
| `docs/PROJECT_CAPSULE.md` | Concise stable product, stack, architecture, and invariant summary | When durable architecture or domain rules change |
| `docs/CODEBASE_MAP.md` | Entry points, module boundaries, dependencies, and protected generated areas | When module structure changes |
| `.plans/IMPLEMENTATION_PLAN.md` | Accepted ordered steps, dependencies, and statuses | When the accepted plan or step status changes |
| `.plans/steps/<STEP-ID>.md` | Complete implementation packet for one active step | Before the step becomes active; amended only through approval |
| `.codex/CURRENT.md` | Small pointer to the single active step and exact initial read set | At every step transition |
| `.codex/checkpoints/<STEP-ID>.md` | Verified handoff describing what changed and what the next step may rely on | After each completed step |
| `.agents/skills/continue-step/SKILL.md` | Optional reusable command for executing the protocol | When workflow mechanics change |

Do not place secrets, generated build output, raw chat dumps, transient logs, or private credentials in these files.

## Required entry sequence for project implementation

When `.codex/CURRENT.md` exists, the agent must use this sequence:

1. Apply the connected Context Vault's root `AGENTS.md` only for routing and account-wide governance.
2. Resolve the authoritative project repository through the project registry when needed.
3. Read the project repository's root and applicable nested `AGENTS.md` files.
4. Read `.codex/CURRENT.md`.
5. Read only the files listed under its required reading order.
6. Read only the source and test files listed as the initial context set.
7. Perform targeted discovery only when justified by a direct dependency, symbol reference, verification failure, or acceptance criterion.
8. Implement and verify only the active step.
9. Write the step checkpoint, advance the pointer, and stop.

`START_HERE.md`, the full Context Vault index, broad architecture documentation, old specifications, previous task packets, and unrelated modules are not mandatory reads when `.codex/CURRENT.md` already identifies the governing context.

## Initial context budget

The default initial project context is limited to:

- the applicable `AGENTS.md` instruction chain;
- `.codex/CURRENT.md`;
- the active step packet;
- the immediately preceding checkpoint when relevant;
- the project capsule or codebase-map sections explicitly listed by the pointer;
- the source and test files explicitly listed by the pointer.

Prohibited starting behavior includes:

- recursively reading all source files;
- reading every Markdown document;
- dumping complete directory contents into the prompt;
- rereading all completed step packets or checkpoints;
- reconstructing architecture already captured in a verified project capsule;
- scanning unrelated feature modules “for context”;
- repeating completed tests or reviews when the relevant repository state has not changed.

A concise directory listing or targeted filename search is allowed when necessary to locate an explicitly relevant dependency.

## Justified context expansion

The agent may read an unlisted file only when at least one of these conditions is true:

1. A listed file directly imports, calls, extends, configures, or generates it.
2. A targeted symbol search shows it defines or consumes behavior being changed.
3. A focused or required verification failure points to it.
4. An acceptance criterion cannot be verified without it.
5. The repository state contradicts the current-step packet or checkpoint.
6. A security, migration, compatibility, or domain-invariant risk requires inspection.

Before broadening context, the agent should record internally or in its progress report:

- the missing information;
- why the listed context is insufficient;
- the smallest additional file or directory set required.

Context expansion does not automatically expand implementation scope.

## Project capsule requirements

`docs/PROJECT_CAPSULE.md` must be concise and stable. It should normally contain:

- product purpose;
- current stack;
- authoritative module boundaries;
- critical domain invariants;
- environment or deployment mode;
- standard development and verification commands;
- links to deeper authoritative documents that are read only when needed;
- the commit or date against which the capsule was last verified.

Do not turn the capsule into a duplicate README, complete architecture manual, changelog, or task history.

## Codebase-map requirements

`docs/CODEBASE_MAP.md` should identify:

- feature and service entry points;
- module responsibilities;
- important dependency directions;
- public interfaces used by later steps;
- generated or protected paths;
- test locations;
- areas requiring nested instructions.

The map must describe current structure, not aspirational architecture.

## Implementation-plan requirements

`.plans/IMPLEMENTATION_PLAN.md` must:

- reference an accepted specification;
- use unique step identifiers;
- order steps by dependency;
- allow exactly one `ACTIVE` implementation step unless the accepted plan explicitly authorizes isolated parallel work;
- distinguish `BLOCKED`, `READY`, `ACTIVE`, `VERIFYING`, and `COMPLETE` states;
- point each step to a dedicated step packet;
- avoid duplicating the full implementation packet for every step.

A material change to scope, behavior, architecture, dependencies, interfaces, schema, security, or acceptance criteria must be recorded as an accepted amendment before the plan or active packet is changed.

## Current-pointer requirements

`.codex/CURRENT.md` must remain small and operational. It should state:

- active branch or worktree;
- expected starting commit;
- active step ID;
- exact reading order;
- initial source and test files;
- initially off-limits areas;
- previous-step result that the active step may rely on;
- active objective;
- targeted-discovery rules;
- required verification;
- completion actions;
- stop condition.

It must not contain the whole project history or duplicate the entire accepted specification.

## Step-packet requirements

Each `.plans/steps/<STEP-ID>.md` must define:

- one primary objective;
- accepted specification and amendment references;
- dependencies and starting state;
- included and excluded behavior;
- allowed and off-limits files or modules;
- established interfaces that must be preserved;
- implementation requirements;
- acceptance criteria;
- focused and complete verification commands;
- manual checks when relevant;
- rollback or recovery requirements;
- required checkpoint content.

A step packet should provide enough context to implement the step without a broad repository scan.

## Checkpoint requirements

Each `.codex/checkpoints/<STEP-ID>.md` must record only decision-relevant continuation context:

- completed step and date;
- starting and ending commit or repository state;
- implemented behavior;
- files changed and their meaningful effects;
- interfaces added, changed, or confirmed;
- decisions and assumptions later steps may rely on;
- preserved invariants;
- exact verification commands and results;
- acceptance-criteria evidence;
- known limitations;
- amendments;
- rollback information;
- smallest recommended read set for the next step.

A checkpoint is a compressed technical handoff, not a transcript, raw diff, or narrative diary.

## Step lifecycle

Use this state transition:

```text
READY -> ACTIVE -> VERIFYING -> COMPLETE
```

A step may become `BLOCKED` when a dependency, owner decision, repository conflict, or verification failure prevents safe completion.

For each step:

1. Confirm the pointer, branch, expected commit, and worktree state.
2. Read the bounded context.
3. Map acceptance criteria to planned code and tests.
4. Implement the smallest valid change.
5. Run focused verification.
6. Run the required complete verification gate.
7. Review the full diff.
8. Write the checkpoint.
9. Mark the step complete.
10. Activate the next dependency-satisfied step.
11. Regenerate `.codex/CURRENT.md`.
12. Commit the verified step when authorized.
13. Stop without implementing the next step.

## Session continuity

Use the same Codex session for adjacent steps in the same tightly related feature only when context remains clear and reliable.

Start a fresh session when:

- entering a different major module;
- beginning a new milestone;
- the conversation has become long or heavily compacted;
- the repository changed outside the current workflow;
- the checkpoint or capsule may be stale;
- a security-sensitive or architecture-changing task requires independent review.

A fresh session should resume from `.codex/CURRENT.md` and the verified checkpoint rather than rereading the repository.

## Parallel work

Parallel agents or worktrees are allowed only when:

- the accepted plan explicitly identifies independent steps;
- each step has its own branch or worktree and context packet;
- allowed files do not overlap;
- one orchestrator owns integration;
- the main agent remains the only writer to a given branch unless explicitly authorized.

Do not use parallel agents merely to accelerate a tightly coupled feature.

## Staleness and invalidation

The project capsule, codebase map, pointer, or checkpoint must be treated as stale when:

- its verified commit no longer exists in the active history;
- module paths or public interfaces changed materially;
- a merge introduced relevant work not represented in the checkpoint;
- required verification no longer passes;
- the accepted specification or amendment changed;
- the actual code contradicts the document.

When stale, perform the smallest targeted reconciliation necessary and update the affected artifact before implementation continues.

A full repository re-onboarding is justified only when targeted reconciliation cannot restore reliable context.

## Automation

Projects may add deterministic scripts such as:

- `step:status`;
- `step:activate`;
- `step:complete`;
- `context:verify`.

These scripts should verify that:

- exactly one step is active;
- referenced files exist;
- the expected commit or branch matches;
- required checkpoints exist;
- step dependencies are satisfied;
- the current pointer and implementation plan agree;
- no completed step remains active.

Automation may update workflow metadata, but it must not mark acceptance criteria verified without evidence.

## Adoption rule

For an existing project, adoption should occur as one accepted repository-maintenance or architecture task:

1. inspect the repository once;
2. create and verify the project capsule and codebase map;
3. convert the accepted roadmap or specification into ordered step packets;
4. create the initial current pointer;
5. add the optional continuation skill and validation scripts;
6. run the project's required checks;
7. record a baseline checkpoint;
8. stop before implementing unrelated product behavior.

## Completion evidence

An implementation step governed by this protocol is complete only when its checkpoint contains exact evidence for every acceptance criterion and the current pointer has advanced without beginning the next step.
