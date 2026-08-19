---
schema_version: 1
spec_id: AGENTS-CONSOLIDATION-001-A1
title: Odysseus Deterministic Project Extension Loading and Activation
status: accepted
owner: Earl
accepted_date: 2026-08-19
timezone: Asia/Manila
risk: high
parent_spec: AGENTS-CONSOLIDATION-001
execution_plane: Astral Bridge only
classification: bounded-runtime-governance-amendment
---

# AGENTS-CONSOLIDATION-001-A1
## Odysseus Deterministic Project Extension Loading and Activation

## Acceptance record

Earl explicitly accepted this amendment on 2026-08-19 with:

```text
APPROVE AGENTS-CONSOLIDATION-001-A1 AS WRITTEN
```

This acceptance authorizes only the bounded Odysseus loader, tests, policy installation, exact runtime restart, canary, rollback, and Context Vault evidence described below. It does not authorize provider, model, endpoint, credential, memory-schema, database, UI, unrelated application behavior, HAU, Astral, or stale-copy cleanup changes.

## Intent

```text
INTENT: SOFTWARE_FEATURE
SECONDARY INTENTS: TESTING, LOCAL_RUNTIME_ACTIVATION, DOCUMENTATION
MODE: EXECUTE
TARGET: D:\AI_Workspace\odysseus and the registered Odysseus governance entrypoints
RISK: HIGH
DELIVERABLE: deterministic root-plus-extension loading, verified live activation, rollback evidence, and durable Context Vault evidence
```

## Objective

Add deterministic, fail-closed Odysseus loading for the registered project extension at:

```text
D:\AI_Workspace\.agents\PROJECT_POLICY.md
```

The root policy at `D:\AI_Workspace\AGENTS.md` remains the first governance input. The project extension follows it in a stable byte-deterministic prefix so Odysseus preserves account-wide authority, runtime-specific rules, and prompt-cache stability.

## Authoritative sources

1. Earl's current explicit approval of this amendment.
2. Accepted parent specification `AGENTS-CONSOLIDATION-001`.
3. The authoritative Odysseus repository and its applicable governance.
4. Current `D:\AI_Workspace\odysseus\src\chat_processor.py` and focused tests.
5. Context Vault canonical `AGENTS.md`, registry, Odysseus extension source, and activation evidence.

## Required preflight

Before the first write:

- verify repository root, branch, `HEAD`, upstream, status, active task, and writer state;
- stop on unknown dirty work, divergence, wrong branch, or a conflicting writer;
- identify the exact Odysseus process or service and its restart command;
- record SHA-256 for `chat_processor.py`, every affected test, `D:\AI_Workspace\AGENTS.md`, the extension target when present, and the nested historical policy;
- prove a source and runtime rollback path;
- confirm the registered Context Vault extension source and canonical root hashes;
- confirm no provider, model, credential, database, HAU, Astral, or stale-copy operation is required.

## In scope

- Add a dedicated environment variable named `ODYSSEUS_PROJECT_POLICY_PATH` with default `D:\AI_Workspace\.agents\PROJECT_POLICY.md`.
- Refactor governance loading so root and extension are read in fixed order.
- Keep the governance prefix static across turns.
- Wrap root and extension in distinct stable markers.
- Fail closed when either required file is missing, unreadable, empty, or unexpectedly not a regular file.
- Preserve the existing `ODYSSEUS_GLOBAL_AGENTS_PATH` override.
- Add focused regression tests before or alongside implementation.
- Install the already registered canonical root and Odysseus extension only after backup and loader tests pass.
- Restart only the exact Odysseus runtime process or service identified during preflight.
- Run a fresh-process canary proving both governance IDs are injected.
- Record hashes, backup paths, tests, process identity, restart result, runtime probe, rollback, and post-change state.
- Update Context Vault registry and consolidation evidence after runtime proof succeeds.

## Out of scope

- Provider, model, endpoint, API key, credential, memory-schema, database, UI, or prompt-persona redesign.
- Changes to HAU-USC Logistics or Astral Bridge.
- Deletion or archival of `D:\AI_Workspace\odysseus\data\AGENTS.md`.
- Broad refactoring of `chat_processor.py`.
- Changing the utility-model exception unless an existing regression requires it.
- Deployment outside the exact local Odysseus runtime.
- Relaxing fail-closed behavior.
- Stale-copy archival or deletion.

## Required design

The effective static governance prefix must be equivalent to:

```text
<GLOBAL_AGENTS_GOVERNANCE>
<exact root content>
</GLOBAL_AGENTS_GOVERNANCE>
<PROJECT_POLICY_EXTENSION>
<exact extension content>
</PROJECT_POLICY_EXTENSION>
```

Requirements:

- root precedes extension;
- no timestamp, per-turn count, retrieval result, or other variable content is included;
- line-ending handling is deterministic and tested;
- error messages identify the failed path without exposing file contents;
- the loader returns one stable system-governance value or another verified cache-safe representation;
- current root behavior remains covered by regression tests;
- extension content cannot silently override higher authority.

## Required tests

At minimum:

1. root and extension load in exact order;
2. configured root and extension path overrides work;
3. missing root fails closed;
4. empty root fails closed;
5. unreadable root fails closed where testable;
6. non-file root fails closed;
7. missing extension fails closed;
8. empty extension fails closed;
9. unreadable extension fails closed where testable;
10. non-file extension fails closed;
11. repeated calls produce byte-identical output;
12. the root governance marker appears exactly once;
13. the project extension marker appears exactly once;
14. `EARL-ODYSSEUS-GLOBAL-V2` appears in the effective prefix after activation;
15. a fresh `ChatProcessor` context places governance before persona and untrusted context;
16. existing focused Odysseus tests remain green.

## Implementation sequence

1. Reverify repository identity, branch, `HEAD`, upstream, status, applicable governance, active task, and runtime process identity.
2. Stop on unknown dirty work or missing authority.
3. Create an isolated task branch or worktree, or a verified file-level rollback package when no authoritative Git path exists.
4. Record pre-change hashes and process or service state.
5. Add regression tests that fail against the old loader when practical.
6. Implement the smallest loader change.
7. Run focused tests.
8. Run the relevant complete Odysseus test set once.
9. Review the complete diff and scan it for secrets.
10. Install the registered canonical root and extension through deterministic synchronization with hash verification.
11. Restart only the exact verified Odysseus runtime.
12. Run a fresh-process governance canary without reading governance files as ordinary user data.
13. Run post-change health checks.
14. Commit and push through the authoritative repository path when Git-backed.
15. Update Context Vault registry and evidence only after runtime proof succeeds.

## Backup and rollback

Before the first source or live-policy write:

- preserve `chat_processor.py` and every modified test by exact Git commit or SHA-256-verified backup;
- preserve current `D:\AI_Workspace\AGENTS.md`;
- record whether the extension target existed and preserve it when present;
- record the exact runtime process or service and restart command;
- prove the previous source and runtime can be restored.

Rollback triggers include any test failure, startup failure, canary failure, missing governance marker, wrong order, unexpected drift, or health regression. Rollback restores source, tests, root and extension files, and prior runtime state, then reruns the pre-change health check.

## Verification

Completion requires concrete evidence for:

```text
accepted amendment present on the Context Vault protected mainline
repository and status handshake PASS
pre-change backups and hash records PASS
focused regression tests PASS
relevant complete test set PASS
complete diff review PASS
secret scan PASS
root SHA equals registered canonical SHA
extension SHA equals registered Odysseus extension SHA
fresh-process root marker PASS
fresh-process extension marker PASS
EARL-ODYSSEUS-GLOBAL-V2 canary PASS
runtime health PASS
rollback proof PASS
Context Vault registry and evidence updated through its accepted repository path
```

## Stop conditions

Stop without improvising when:

- this amendment is not present as accepted authority;
- the authoritative Odysseus repository or current task cannot be resolved;
- unexpected dirty work exists;
- runtime process identity is ambiguous;
- the extension source or target hash differs unexpectedly;
- tests cannot demonstrate fail-closed behavior;
- the runtime canary can succeed only by reading policy files as ordinary user data instead of injected governance;
- a provider, model, credential, database, or unrelated feature change would be required;
- rollback cannot be demonstrated;
- HAU, Astral, or stale-copy cleanup would be pulled into this slice.

## Deliverables

- accepted amendment record;
- focused Odysseus loader and tests;
- verified root and extension installation;
- runtime activation and canary evidence;
- rollback evidence;
- Context Vault registry and report update;
- exact commit and push evidence when applicable.

## Completion boundary

Do not claim Odysseus activation, strict all-target verification, or stale-copy cleanup until every required test and runtime gate above passes.
