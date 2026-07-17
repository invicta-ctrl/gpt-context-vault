---
schema_version: 1
status: template
scope: projects
last_reviewed: 2026-07-17
---

# Incremental Codex Project Setup Template

Use this bundle to adopt [`protocols/INCREMENTAL_CODEX_CONTEXT_PROTOCOL.md`](../protocols/INCREMENTAL_CODEX_CONTEXT_PROTOCOL.md) in an authoritative project repository.

Copy the relevant sections into repository-local files. Replace every placeholder and delete unused guidance before accepting the setup.

## Recommended repository structure

```text
project/
├── AGENTS.md
├── PROJECT_STATUS.md
├── .agents/
│   └── skills/
│       └── continue-step/
│           └── SKILL.md
├── .codex/
│   ├── CURRENT.md
│   └── checkpoints/
│       └── <STEP-ID>.md
├── .plans/
│   ├── IMPLEMENTATION_PLAN.md
│   ├── amendments/
│   └── steps/
│       └── <STEP-ID>.md
├── docs/
│   ├── PROJECT_CAPSULE.md
│   ├── CODEBASE_MAP.md
│   ├── ARCHITECTURE.md
│   ├── DOMAIN_RULES.md
│   └── specs/
│       └── accepted/
├── scripts/
│   ├── activate-step.*
│   ├── complete-step.*
│   ├── step-status.*
│   └── verify-context.*
├── src/
└── tests/
```

Only create scripts and directories the project actually needs.

---

# Template A — `docs/PROJECT_CAPSULE.md`

````md
---
schema_version: 1
status: active
last_verified: YYYY-MM-DD
verified_commit: <commit-sha>
---

# Project Capsule

## Product

<One concise paragraph describing the product, primary users, and outcome.>

## Current delivery state

- Version or milestone:
- Environment mode:
- Production status:
- Authoritative repository:

## Stack

- Runtime:
- Frontend:
- Backend:
- Persistence:
- Testing:
- Build and deployment:

## Architectural boundaries

| Area | Path | Responsibility | Must not do |
|---|---|---|---|
| | | | |

## Critical invariants

- INV-001:
- INV-002:

## Stable interfaces

- `<interface>` — <purpose and compatibility rule>

## Standard commands

- Install:
- Development:
- Focused tests:
- Full verification:
- Build:
- Artifact verification:

## Deeper authoritative documents

Read only when the active step requires them:

- `docs/ARCHITECTURE.md`
- `docs/DOMAIN_RULES.md`
- `docs/DEPLOYMENT.md`

## Capsule maintenance

Update this file only when durable stack, architecture, module boundaries, commands, or invariants change.
````

---

# Template B — `docs/CODEBASE_MAP.md`

````md
---
schema_version: 1
status: active
last_verified: YYYY-MM-DD
verified_commit: <commit-sha>
---

# Codebase Map

## Module map

| Area | Entry point | Responsibility | Main dependencies | Tests |
|---|---|---|---|---|
| | | | | |

## Dependency direction

```text
<entry point>
    -> <domain or service>
    -> <state or persistence boundary>
```

## Stable public interfaces

| Interface | Defined in | Consumers | Compatibility rule |
|---|---|---|---|
| | | | |

## Generated or protected paths

- `<path>` — <reason it must not be edited directly>

## Nested instruction areas

- `<directory>/AGENTS.md` — <special rules>

## Targeted-discovery hints

- To locate <behavior>, search for `<symbol or identifier>`.
- To locate <tests>, inspect `<path or pattern>`.

## Map maintenance

Update this file when entry points, module ownership, dependency direction, public interfaces, or protected paths change.
````

---

# Template C — `.plans/IMPLEMENTATION_PLAN.md`

````md
---
schema_version: 1
status: accepted
plan_version: 1.0
accepted_date: YYYY-MM-DD
accepted_by: Earl
base_commit: <commit-sha>
accepted_specification: docs/specs/accepted/<SPEC>.md
---

# Implementation Plan

## Status legend

- `BLOCKED`
- `READY`
- `ACTIVE`
- `VERIFYING`
- `COMPLETE`

## Execution rules

- Only one step may be `ACTIVE` unless an accepted amendment authorizes isolated parallel work.
- Each step must have a packet in `.plans/steps/<STEP-ID>.md`.
- Material plan changes require an accepted amendment.
- Completing a step advances the pointer but does not authorize implementation of the next step in the same run.

## Steps

| ID | Step | Depends on | Packet | Status |
|---|---|---|---|---|
| S-001 | | — | `.plans/steps/S-001.md` | ACTIVE |
| S-002 | | S-001 | `.plans/steps/S-002.md` | BLOCKED |

## Milestone completion criteria

- [ ] All required steps complete
- [ ] Full verification passes
- [ ] Documentation reconciled
- [ ] Rollback checkpoint recorded
````

---

# Template D — `.codex/CURRENT.md`

````md
---
schema_version: 1
status: active
updated: YYYY-MM-DD
current_branch: <branch>
expected_head: <commit-sha>
active_step: S-001
---

# Current Codex Context

## Required reading order

1. `AGENTS.md`
2. `.plans/steps/S-001.md`
3. `docs/PROJECT_CAPSULE.md` — only sections: <sections>
4. `docs/CODEBASE_MAP.md` — only sections: <sections>
5. `.codex/checkpoints/<PREVIOUS-STEP>.md` when applicable

## Initial source and test files

- `<path>`
- `<path>`

## Initially off-limits

- `<path or module>`
- Completed step packets and unrelated checkpoints
- Unrelated feature directories
- Generated output

## Previous verified result

- <Small set of facts the active step may rely on.>

## Active objective

<One implementation objective.>

## Targeted discovery allowed

Read an unlisted file only when required by:

- a direct import, call, extension, configuration, or generation relationship;
- a targeted symbol reference;
- a verification failure;
- an acceptance criterion;
- a security, migration, compatibility, or invariant concern;
- a contradiction between the repository and this pointer.

Do not perform a broad repository scan.

## Required verification

- `<command>`
- `<command>`

## Completion actions

1. Write `.codex/checkpoints/S-001.md`.
2. Mark S-001 `COMPLETE` in `.plans/IMPLEMENTATION_PLAN.md`.
3. Activate the next dependency-satisfied step.
4. Regenerate this file for the next step.
5. Commit when authorized.
6. Stop without implementing the next step.
````

---

# Template E — `.plans/steps/<STEP-ID>.md`

````md
---
schema_version: 1
status: active
step_id: S-001
accepted_specification: docs/specs/accepted/<SPEC>.md
accepted_amendments: []
depends_on: []
starting_commit: <commit-sha>
---

# S-001 — <Step Name>

## Objective

<One measurable outcome.>

## Included

- 

## Excluded

- 

## Allowed files or modules

- 

## Off-limits files, modules, and behavior

- 

## Existing interfaces and invariants

- `<interface>` must remain compatible.
- `INV-001` must remain true.

## Required behavior

1. 
2. 

## Error and edge-case behavior

- 

## Acceptance criteria

- [ ] AC-001:
- [ ] AC-002:

## Verification

### Focused

```bash
<command>
```

### Complete gate

```bash
<command>
<command>
```

### Manual checks

1. 

## Rollback or recovery

- 

## Required checkpoint content

Record:

- behavior implemented;
- meaningful file effects;
- interfaces added or changed;
- preserved invariants;
- exact verification results;
- acceptance-criteria evidence;
- risks, limitations, and amendments;
- rollback information;
- smallest recommended read set for the next step.
````

---

# Template F — `.codex/checkpoints/<STEP-ID>.md`

````md
---
schema_version: 1
status: complete
step_id: S-001
completed: YYYY-MM-DD
branch: <branch>
starting_commit: <commit-sha>
ending_commit: <commit-sha-or-pending>
---

# S-001 Completion Checkpoint

## Implemented behavior

- 

## Meaningful file effects

### `<path>`

- 

## Interfaces available to later steps

```text
<interface signature or contract>
```

## Decisions and assumptions

- 

## Preserved invariants

- 

## Acceptance-criteria evidence

| Criterion | Evidence | Result |
|---|---|---|
| AC-001 | `<test, command, or manual check>` | Passed |

## Verification results

- `<exact command>` — <exact result>

## Context expansion performed

- None; or
- `<path>` — required because <direct reason>.

## Risks and known limitations

- 

## Amendments

- None; or
- `<amendment reference>`

## Rollback

- 

## Recommended initial read set for next step

- `.plans/steps/<NEXT-STEP>.md`
- This checkpoint
- `<source or test file>`
````

---

# Template G — `.agents/skills/continue-step/SKILL.md`

````md
---
name: continue-step
description: Continue the single active implementation step from the repository's bounded Codex context without rescanning the whole repository.
---

# Continue Active Step

1. Read the applicable `AGENTS.md` files.
2. Read `.codex/CURRENT.md`.
3. Verify branch, expected HEAD, worktree state, active step, and accepted specification.
4. Read only the pointer's required files and initial source/test set.
5. Do not perform a broad repository scan.
6. Expand context only through direct dependencies, targeted symbol searches, verification failures, acceptance criteria, or material safety and compatibility risks.
7. Map every acceptance criterion to implementation and verification evidence.
8. Implement only the active step.
9. Run focused verification, then the complete required gate.
10. Review the complete diff.
11. Write the completion checkpoint.
12. Advance the implementation plan and `.codex/CURRENT.md`.
13. Commit when authorized.
14. Stop without implementing the next step.

Report:

- routed intent and matched skills;
- active step and accepted scope;
- starting and ending repository state;
- behavior implemented;
- files changed;
- context expansion and justification;
- acceptance-criteria evidence;
- exact verification results;
- risks, limitations, amendments, and rollback;
- checkpoint path;
- next active step.
````

---

# Optional deterministic workflow scripts

Projects may implement commands equivalent to:

```json
{
  "scripts": {
    "step:status": "node scripts/step-status.mjs",
    "step:activate": "node scripts/activate-step.mjs",
    "step:complete": "node scripts/complete-step.mjs",
    "context:verify": "node scripts/verify-context.mjs"
  }
}
```

The language and command names may differ by project.

`context:verify` should fail when:

- zero or multiple steps are active unexpectedly;
- a referenced file does not exist;
- pointer and plan disagree;
- expected branch or commit is wrong;
- required dependencies or checkpoints are missing;
- a completed step remains active;
- a step is advanced without verification evidence.

Scripts must not fabricate acceptance evidence or silently approve amendments.

## Adoption checklist

- [ ] Accepted repository-maintenance or architecture specification exists
- [ ] Repository inspected once from a known commit
- [ ] Project capsule matches actual architecture
- [ ] Codebase map matches actual entry points and dependencies
- [ ] Implementation plan references an accepted specification
- [ ] Exactly one step is active
- [ ] Active step packet is complete
- [ ] `.codex/CURRENT.md` lists a bounded initial read set
- [ ] Baseline checkpoint exists when continuing existing work
- [ ] Validation commands pass
- [ ] No project runtime state was copied into the Context Vault
