---
schema_version: 1
spec_id: AGENTS-CONSOLIDATION-001-A2
status: proposed-not-accepted
title: Odysseus Scope Removal, Local Retirement, and Governance Cleanup
owner: Earl
prepared: 2026-08-20
timezone: Asia/Manila
risk: critical-destructive-maintenance
execution_plane: Astral Bridge only
parent_spec: AGENTS-CONSOLIDATION-001
supersedes_after_acceptance: AGENTS-CONSOLIDATION-001-A1
---

# AGENTS-CONSOLIDATION-001-A2
## Odysseus Scope Removal, Local Retirement, and Governance Cleanup

## Approval gate

This is a proposed destructive-maintenance amendment. It is not accepted merely because it exists in Git.

Execution requires Earl to approve this exact document with:

```text
APPROVE AGENTS-CONSOLIDATION-001-A2 AS WRITTEN
```

Until that approval is recorded, this amendment authorizes only read-only inventory, plan preparation, and preservation of the HAU-USC Logistics stop condition. It authorizes no Odysseus deletion and no HAU-USC Logistics mutation.

## Owner instruction being normalized

```text
Forget about odysseus, remove it from project scope and delete all of the files regarding with it. Do not touch the logistics system and others. Then proceed now with the read-only HAU authority reconciliation and isolated candidate preparation.
```

## Objective

Retire Odysseus from the active AGENTS governance program and remove its local runtime/source checkout, data, active project policy, integration bridge, launch references, and Odysseus-specific rollback files without modifying HAU-USC Logistics, Astral Bridge, Global Codex, other projects, providers, deployments, databases, credentials, or unrelated local files.

## Scope interpretation

“Remove it from project scope” means:

1. remove the `odysseus` managed-replica target from `AGENTS_REGISTRY.json`;
2. remove the `odysseus-extension-source` entry;
3. remove the active Context Vault extension source;
4. supersede A1 and remove Odysseus from current synchronization, verification, and blocker status;
5. remove current operational prose that presents Odysseus as active or pending.

“Delete all files regarding it” means delete the exact active/local artifacts below. Immutable Context Vault inventories, accepted specifications, and evidence remain as superseded historical records so the audit trail is not falsified. They must no longer appear as current scope.

`D:\AI_Workspace\AGENTS.md` is a generic universal replica, not an Odysseus-specific file. It remains unchanged because Earl excluded unrelated files and systems.

## Exact local deletion targets

After approval and a fresh preflight, delete:

```text
D:\AI_Workspace\odysseus\
D:\AI_Workspace\odysseus_data\
D:\AI_Workspace\.agents\PROJECT_POLICY.md
D:\AI_Workspace\bridge\odysseus_openclaw_bridge.py
```

Remove only the Odysseus launch block from:

```text
D:\AI_Workspace\Important codes\Codes.txt
```

Delete these Odysseus-specific rollback files last, after all other removal and verification succeeds:

```text
D:\AI_Workspace\backups\agents-consolidation-001\20260819T101817880Z\odysseus-a1-f2eb141.bundle
D:\AI_Workspace\backups\agents-consolidation-001\20260819T101817880Z\odysseus-a1-f2eb141.patch
D:\AI_Workspace\backups\agents-consolidation-001\20260819T101817880Z\odysseus-sync-dry-run.txt
```

Remove a parent directory only when it becomes empty. Preserve non-Odysseus backup material and unrelated `Codes.txt` lines.

## Context Vault changes after approval

Delete from active source:

```text
governance/agents/extensions/odysseus.PROJECT_POLICY.md
```

Update only as required:

```text
governance/agents/AGENTS_REGISTRY.json
governance/agents/AGENTS_GOVERNANCE.md
governance/agents/AGENTS_RULE_MATRIX.md
governance/agents/AGENTS_CONSOLIDATION_REPORT.md
governance/agents/AGENTS_AUDIT.md
memory/RECENT_CHANGES.md
CONTEXT_INDEX.md
```

Required disposition:

- remove the live Odysseus target and extension source;
- make Odysseus neither required, conditional, blocked, nor pending;
- mark A1 superseded by A2;
- retain A1, pre-change manifests, inventories, and prior evidence as historical records;
- ensure sync/verification tools no longer target `D:\AI_Workspace` for Odysseus;
- remove current prose that treats Odysseus as a remaining blocker.

## Explicit exclusions

Do not modify, create a worktree in, stage, commit, push, merge, deploy, migrate, reset, clean, or delete anything in:

```text
D:\Documents\Codex\HAU-USC Logistics\
D:\Documents\Codex\Astral-Bridge\
C:\Users\adria\.codex\
```

The Context Vault verifier may read registered hashes there, but no write is allowed.

Also excluded:

- every HAU-USC Logistics source, worktree, provider, D1/R2, Playground, Production, and release record;
- Astral Bridge and protected CodexPro material;
- Global Codex configuration and managed files;
- unrelated `D:\AI_Workspace` files;
- providers, models, credentials, secrets, email, Google resources, databases, and deployments;
- deletion of the third-party upstream repository `https://github.com/pewdiepie-archdaemon/odysseus.git`.

## Destructive-maintenance preflight

Before deletion:

1. verify this amendment is accepted on the current Context Vault `main` lineage;
2. verify Context Vault branch, HEAD, upstream, and working state;
3. re-run exact Odysseus target inventory and hashes;
4. verify `D:\AI_Workspace\odysseus` is clean or stop on new/unknown work;
5. record its branch, HEAD, tree, remote, and lack/presence of upstream;
6. verify no Odysseus process, Windows service, scheduled task, Docker container, WSL service, or active file handle is running;
7. detect the checkout `.env` only by metadata and never read or print its contents;
8. verify the bundle and patch can reconstruct the local A1 state before deletion;
9. verify the `Codes.txt` replacement is exact;
10. prove no excluded HAU, Astral, Global Codex, or unrelated `D:\AI_Workspace` path is in the deletion set;
11. produce a final deletion manifest with path, type, bytes where practical, and pre-delete hash or Git identity;
12. stop if any target changed materially since the recorded preflight.

## Execution sequence

1. Stop only a verified Odysseus process/service if one appears during the fresh preflight.
2. Remove the exact Odysseus launch block from `Codes.txt`.
3. Delete `odysseus_openclaw_bridge.py`.
4. Delete the local Odysseus project extension; remove `.agents` only if empty.
5. Delete `D:\AI_Workspace\odysseus_data`.
6. Delete `D:\AI_Workspace\odysseus`, including ignored `.env`, virtual environment, caches, local Git metadata, and the local-only A1 branch.
7. Verify the local targets are absent and unrelated siblings remain.
8. Update the Context Vault registry, current governance documents, report, and verification expectations.
9. Run candidate-aware and strict verification. Strict success may remain blocked by HAU, but it must contain zero Odysseus result.
10. Delete the three Odysseus rollback files last.
11. Re-run bounded filename/content/reference scans outside immutable history.
12. Commit and push only Context Vault governance/evidence changes through its protected path.
13. Stop. Do not continue into HAU implementation or unrelated stale cleanup.

## Irreversibility and rollback

The existing bundle and patch temporarily protect the local A1 commit. This amendment deletes them at final closeout because Earl requested removal of all local Odysseus files.

After final purge, the local checkout, local data, local A1 branch, extension, bridge, launch instructions, and rollback bundle/patch are intentionally unrecoverable from this laptop. The third-party upstream may remain online but does not contain Earl's local A1 commit unless it was independently pushed. Immutable Context Vault history remains the local governance record of the retired target.

If deletion fails before rollback files are purged, restore from the verified bundle/patch or stop with the exact partial state. Never delete rollback files first.

## Verification

Completion requires:

```text
D:\AI_Workspace\odysseus                              MISSING
D:\AI_Workspace\odysseus_data                         MISSING
D:\AI_Workspace\.agents\PROJECT_POLICY.md             MISSING
D:\AI_Workspace\bridge\odysseus_openclaw_bridge.py    MISSING
Odysseus block in Codes.txt                             ABSENT
three named Odysseus rollback files                     MISSING
D:\AI_Workspace\AGENTS.md                              UNCHANGED
```

And:

- no `odysseus` managed target or extension source in the registry;
- no active sync target into `D:\AI_Workspace` for Odysseus;
- active governance docs do not treat Odysseus as current scope or a blocker;
- historical evidence is marked historical/superseded;
- candidate-aware verification passes for every eligible target;
- strict verification has zero Odysseus result;
- HAU, Astral, Global Codex, and unrelated projects retain their verified starting state;
- no provider, database, deployment, model, secret, credential, or external system changed;
- secret-pattern scan and full Context Vault diff review pass.

## HAU-USC Logistics boundary

Read-only reconciliation on 2026-08-20 identified the authoritative product lineage as:

```text
origin/release/v0.8.3-identity-foundation
8874fc849f387831acf2957cc1259d98d1b11a99
```

Its current chain records:

```text
ACTIVE_WRITER: TERRA_MAX:/root/v83_gate_a_terra_writer
WRITER_LOCK: HELD
LOCK_STATUS: ACTIVE
```

No HAU governance candidate, branch, or worktree may be created while that lock remains held. Only read-only rechecks are authorized. Candidate preparation resumes after the authoritative release chain records `ACTIVE_WRITER: NONE`, `WRITER_LOCK: RELEASED`, `HANDOFF_STATUS: READY_FOR_HANDOFF`, and clean pushed state.

## Stop conditions

Stop when:

- A2 is not accepted;
- a deletion target changed materially;
- the Odysseus checkout is dirty or contains unknown work;
- a process/service/container cannot be safely identified or stopped;
- a target contains unrelated files;
- `Codes.txt` cannot be changed by one exact bounded replacement;
- rollback evidence is invalid before deletion starts;
- a secret would need to be displayed, copied, or moved;
- HAU, Astral, Global Codex, or another project would need modification;
- Context Vault authority is contradictory;
- strict verification reveals a new non-Odysseus regression;
- filesystem access prevents proving absence.

## Final success state

```text
ODYSSEUS_ACTIVE_PROJECT_SCOPE: REMOVED
ODYSSEUS_LOCAL_RUNTIME_SOURCE_DATA: DELETED
ODYSSEUS_ACTIVE_EXTENSION_AND_INTEGRATION: DELETED
ODYSSEUS_LOCAL_ROLLBACK_FILES: DELETED_LAST
ODYSSEUS_CONTEXT_VAULT_HISTORY: SUPERSEDED_HISTORICAL_ONLY
HAU_USC_LOGISTICS: UNCHANGED_AND_WRITER_LOCK_BLOCKED
ASTRAL_BRIDGE: UNCHANGED
GLOBAL_CODEX: UNCHANGED
STRICT_VERIFICATION: ZERO_ODYSSEUS_RESULT; HAU MAY REMAIN THE ONLY REQUIRED BLOCKER
```
