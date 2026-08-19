---
schema_version: 1
spec_id: AGENTS-CONSOLIDATION-001
title: Universal AGENTS.md Governance Consolidation
status: accepted
owner: Earl
accepted_date: 2026-08-19
timezone: Asia/Manila
risk: high
execution_plane: Astral Bridge only
classification: stable-account-wide-governance
---

# AGENTS-CONSOLIDATION-001
## Universal AGENTS.md Governance Consolidation

## Acceptance record

Earl explicitly approved this specification on 2026-08-19 with:

```text
APPROVE AGENTS-CONSOLIDATION-001 AS WRITTEN
```

This accepted specification authorizes the bounded consolidation described below. It does not waive dirty-work preservation, extension-loading proof, rollback, repository handshakes, active-writer locks, third-party exclusions, or the stop conditions in this document.

## Objective

Establish exactly one editable account-wide/general `AGENTS.md` authority in the live Context Vault, create byte-identical managed replicas for active owned agent entrypoints, move project/runtime-specific rules into durable extensions, install deterministic synchronization and drift verification, and preserve historical, vendor, worktree, backup, and unknown work.

## Authorized canonical master

```text
D:\Documents\Codex\GitHub\gpt-context-vault\AGENTS.md
```

## Authorized managed replicas

```text
C:\Users\adria\.codex\AGENTS.md

D:\Documents\Codex\HAU-USC Logistics\
active\hau-usc-logistics-management-system\AGENTS.md

D:\Documents\Codex\Astral-Bridge\AGENTS.md

D:\AI_Workspace\AGENTS.md
```

The Odysseus replica is conditional on proving that its runtime follows or explicitly injects the registered project extension. Failure of that proof is a stop condition, not permission to weaken the policy.

## Authorized project extensions

```text
C:\Users\adria\.codex\.agents\PROJECT_POLICY.md
  Local Codex tools and host-specific extensions

D:\Documents\Codex\HAU-USC Logistics\
active\hau-usc-logistics-management-system\.agents\PROJECT_POLICY.md
  HAU orchestration, continuity, release, data, and environment rules

D:\Documents\Codex\Astral-Bridge\.agents\PROJECT_POLICY.md
  AB-000, product, security, and protected-source rules

D:\AI_Workspace\.agents\PROJECT_POLICY.md
  Odysseus injection, memory, canary, and runtime rules
```

## Authorized durable deliverables

```text
AGENTS.md
governance\agents\AGENTS_REGISTRY.json
governance\agents\AGENTS_AUDIT.md
governance\agents\AGENTS_RULE_MATRIX.md
governance\agents\AGENTS_GOVERNANCE.md
governance\agents\AGENTS_CONSOLIDATION_REPORT.md
automation\agents-governance\sync-agents.ps1
automation\agents-governance\verify-agents.ps1
governance\agents\specs\AGENTS-CONSOLIDATION-001.md
the four project/local extension files
```

## Explicit exclusions

- No mass-editing of the HAU worktree-area copies.
- No third-party, vendor, package, cache, marketplace, or plugin modification.
- No modification of temporary CodexPro test fixtures.
- No provider, database, deployment, credential, model, or application-runtime change.
- No Git reset, clean, rebase, force-push, or history rewrite.
- No deletion before unique-content preservation and reference verification.
- No use of a managed replica as a new canonical source.
- No “last edited file wins” synchronization.
- No symlink or hardlink design unless separately proven and approved.
- No merge into a protected main branch unless separately and explicitly authorized by applicable repository governance.
- No branch, PR, release, or recovery-pointer cleanup outside the exact accepted scope.

## Execution sequence

1. Preserve and classify existing dirty work in the Context Vault and every affected repository.
2. Record this specification durably in the Context Vault.
3. Create a pre-change manifest containing every target’s original hash, length, path, Git identity, and rollback location.
4. Create project extensions first and verify that all unique project/runtime rules have durable homes.
5. Create the canonical universal master.
6. Create the registry and deterministic scripts.
7. Run synchronization in dry-run mode.
8. Verify that only registered managed replicas would change.
9. Synchronize each replica only after its repository and runtime gates pass.
10. Verify byte equality and SHA-256 equality.
11. Run repository-specific documentation/governance checks.
12. Audit and update only references proven stale because of this migration.
13. Archive the nested Odysseus policy and loose Download copy only after unique-content and reference gates pass.
14. Leave historical worktrees and third-party copies unchanged.
15. Produce the final consolidation report and exact count.
16. Stop before any additional cleanup not explicitly authorized here.

## Universal master content requirements

The canonical universal policy must include:

- authority hierarchy;
- live-repository precedence;
- minimal-context retrieval;
- skill registry routing;
- intent-first routing;
- specification gates;
- one focused task or vertical slice;
- preservation of unknown work;
- no destructive cleanup without inventory;
- complete diff review;
- regression-test expectations;
- read-only code review by default;
- deployment and migration preflight, backup, rollback or reversal, reconciliation, and post-change verification;
- deterministic verification;
- no fabricated success claims;
- artifact-specific workflows;
- privacy and secrets safeguards;
- durable project state in project repositories;
- direct, practical owner-decision handling;
- canonical `AGENTS.md` synchronization policy;
- a requirement to load the registered project extension when one exists.

The universal master must not hard-code HAU release topology, HAU recovery pointers, Astral Bridge implementation details, Odysseus runtime details, or local Codex helper configuration.

## Project-extension disposition

### HAU-USC Logistics extension

Preserve:

- Sol/Terra/Luna orchestration and writer classes;
- `ACTIVE_WRITER` and delegation-ledger rules;
- HAU continuity chain;
- permanent recovery pointers and release path;
- Playground-first promotion;
- D1/R2 isolation and one-way baseline rules;
- recovery rotation;
- Quick Document Fix Mode;
- HAU private-data, ledger, release, and provider constraints;
- HAUSC Access helper guidance.

### Astral Bridge extension

Preserve:

- AB-000 boundary;
- protected CodexPro checkout;
- Astral product and plugin identifiers;
- skills-only plugin-shell restriction;
- scaffold verification;
- local-machine privilege and least-privilege threat model;
- Astral-specific stop conditions and AB-001 boundary.

### Global Codex extension

Preserve:

- CodeGraph usage;
- lean-ctx routing;
- Hallmark frontend trigger;
- local Codex executable and helper paths;
- current Native V2 delegation details that remain account-local rather than universal.

HAUSC Access helper guidance belongs in the HAU extension rather than the universal or global Codex policy.

### Odysseus extension

Preserve:

- governance injection and inheritance requirements;
- `EARL-ODYSSEUS-GLOBAL-V2` canary;
- model-switch and subagent inheritance tests;
- utility-model exception;
- Odysseus memory path and organization;
- provider-message construction;
- Windows host/runtime behavior;
- deterministic enforcement boundary.

## Synchronization contract

Only the canonical master is editable as general policy.

When a general-policy change is requested against a managed replica:

1. redirect the change to the canonical master;
2. modify the canonical master;
3. run the synchronization script;
4. update every eligible registered managed replica;
5. verify byte equality and SHA-256 equality;
6. report every modified repository or local target;
7. never update excluded copies.

The registry must explicitly classify:

```text
canonical
managed_replicas
project_extensions
stale_owned
worktree_derived
historical_immutable
backup_or_test
third_party_excluded
```

`verify-agents.ps1` must report `MATCH`, `DRIFT`, or `MISSING` for managed replicas and exit non-zero on managed drift or missing required targets.

## Repository-write rules

Before modifying each Git repository, record:

- repository root;
- branch;
- `HEAD`;
- upstream;
- ahead/behind when available and authorized;
- `git status --short`;
- applicable `AGENTS` chain;
- accepted specification;
- active-writer state.

Unexpected dirty work, divergence, wrong branch, missing authority, or a conflicting active writer is a stop condition for that repository.

Use an isolated branch or worktree where needed to preserve existing work. Stage and commit only exact accepted files. Do not merge protected branches without separate explicit authority.

## Rollback

- Git-tracked policies are recoverable from exact pre-change commits and dedicated branches.
- Non-Git managed files receive timestamped, hash-verified backups.
- Every moved or archived file retains its original SHA-256 and previous path.
- If any project-specific rule is lost, any managed replica drifts, or any runtime cannot load its extension, stop and restore the exact original files.
- Cleanup begins only after successful synchronization, extension-loading proof, and recovery verification.

## Required verification

```text
one canonical editable authority exists
registered managed replicas exist only where their gates passed
all synchronized managed replica SHA-256 values equal canonical SHA-256
verify-agents.ps1 exits 0 for every required active target
project extensions exist and preserve unique rules
Context Vault indexes and links are valid
no HAU worktree was mass-mutated
representative vendor hashes remain unchanged
no unrelated repository or local file changed
all touched repository diffs are reviewed
all touched repositories end clean or with documented intended changes
no runtime/provider/database/deployment behavior changed
unclassified exact AGENTS files = 0 within accessible scanned areas
inaccessible areas are reported honestly
```

## Stop conditions

Stop the affected operation when any of the following occurs:

- unresolved dirty work or active-writer conflict;
- Context Vault authority becomes ambiguous;
- Odysseus cannot load or inject the project extension;
- a unique rule has no safe destination;
- vendor/owned classification changes or remains uncertain;
- a repository’s current accepted specification forbids the migration;
- synchronization would touch an unregistered path;
- a historical worktree would need mutation;
- a secret or unnecessary private value is detected;
- rollback cannot be demonstrated;
- required Git or runtime authority is missing;
- a protected mainline merge would be needed without separate explicit authorization.

A stop in one target does not authorize bypassing its gate. Other independent targets may proceed only when their own gates pass.

## Completion state

Completion requires:

- one durable canonical master;
- deterministic registry, synchronization, and verification tooling;
- preserved project-specific extensions;
- synchronized eligible replicas;
- classified and preserved excluded copies;
- reviewed evidence and rollback records;
- an exact final count and unresolved-gate report.

If a conditional replica remains blocked, the final report must say so plainly and must not claim full consolidation.
