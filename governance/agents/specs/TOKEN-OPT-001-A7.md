---
schema_version: 1
spec_id: TOKEN-OPT-001-A7
parent_spec: TOKEN-OPT-001-A6
title: Owner-Started Sol Advisor Delegation and Deterministic Routing Repair
status: accepted
owner: Earl
accepted_date: 2026-08-25
timezone: Asia/Manila
risk: high
execution_plane: active owner-started Sol session plus deterministic local governance tooling
classification: stable-account-wide-governance
compatible_with:
  - TOKEN-OPT-001
  - TOKEN-OPT-001-A1
  - TOKEN-OPT-001-A2
  - TOKEN-OPT-001-A3
  - TOKEN-OPT-001-A4
  - TOKEN-OPT-001-A5
  - TOKEN-OPT-001-A6
supersedes:
  - A6 child-capacity and one-process-only behavior inside an active owner-started Sol session
  - A4 automatic Ox-to-Luna fallback and prior active role ordering
---

# TOKEN-OPT-001-A7
## Owner-Started Sol Advisor Delegation and Deterministic Routing Repair

## Acceptance record

Earl's explicit 2026-08-25 execution prompt authorizes this amendment. A7 preserves
A6's prohibition on unattended, background, scheduled, watchdog, ChatGPT Web, and
Astral-initiated billable Codex work. It corrects A6 only where A6 incorrectly made that
boundary prohibit bounded delegation inside a deliberately owner-started Sol session.

A6 remains immutable history. Its child-capacity and single-primary-only behavior is
superseded by A7 for active owner-started Sol sessions; its fail-closed unattended and
self-authorization controls remain active.

## Effective execution boundary

```text
BILLABLE CODEX EXECUTION: LOCKED BY DEFAULT
CHATGPT WEB SELF-AUTHORIZATION: PROHIBITED
ASTRAL BRIDGE SELF-AUTHORIZATION: PROHIBITED
UNATTENDED OR BACKGROUND CODEX: PROHIBITED WITHOUT EARL'S EXACT AUTHORIZATION
ACTIVE OWNER-STARTED SOL SESSION: BOUNDED DELEGATION ALLOWED
DEFAULT_CHILDREN: 0
MAX_SOL_SUBAGENTS: 16
DELEGATION_DEPTH: 1
RECURSIVE_CHILD_SPAWNING: FORBIDDEN
AUTOMATIC_MODEL_FALLBACK: DISABLED
MAX_ACTIVE_WRITERS_ACCOUNT_WIDE: 2
MAX_WRITERS_PER_REPOSITORY_OR_WORKTREE: 1
```

Capacity is not a staffing target. Sol starts with zero children and delegates only
bounded, independent work that materially improves the active accepted task. Children
cannot spawn children. A fallback is a new explicit Sol route, never provider-driven
substitution or retry.

Two writers may coexist only across proven-isolated repositories or worktrees with
separate locks and owned paths and no shared pointer, migration, release file, generated
artifact, provider resource, database, or dependency race. Otherwise the account uses
one writer.

## Active role routing

```text
Sol High
  top-level planner, router, integrator, reviewer, and final acceptance authority
  repository writes prohibited unless a project extension explicitly authorizes them

Ox Alpha
  preferred backend implementation writer when accepted scope authorizes writes
  read-only scout, auditor, or reviewer when not holding a writer lock

Terra Max
  explicit Sol-routed fallback or integration-sensitive writer
  sole HAU frontend writer when implementation is required

Luna Max
  read-only scout, auditor, reviewer, test-gap, security/privacy, scope, and architecture role
  never a canonical writer

DeepSeek
  disabled from all active writer, scout, reviewer, and fallback routes
```

The active catalog identifiers are `gpt-5.6-sol`, `openrouter/stealth/ox-alpha`,
`gpt-5.6-terra`, and `gpt-5.6-luna`. Sol uses High; Ox uses High; Terra and
Luna use Max. Runtime catalog validation is required before saving or activating a
profile. Provider credentials and historical proof may remain as inactive rollback
material and must never be printed or deleted by this amendment.

## HAU-USC routing extension

The canonical HAU project extension owns these stricter project rules:

- `frontend-design-integration`: Sol High plus exactly one Terra Max writer when
  implementation is required; Ox Alpha and Luna Max are read-only; no DeepSeek.
- Backend: Ox Alpha is the preferred writer; Terra Max is an explicit Sol-routed
  fallback or integration-sensitive writer; Luna Max is read-only.
- One writer per repository/worktree; at most two writers account-wide only across
  proven isolation.
- Every writer requires an explicit lock and delegation-ledger entry.
- Production, provider, database, migration, and external data writes remain gated by
  accepted scope and owner approval.

## Managed AGENTS contract

The only editable universal authority remains:

```text
D:\Documents\Codex\GitHub\gpt-context-vault\AGENTS.md
```

Every eligible managed `AGENTS.md` replica must be byte-identical and SHA-256-identical
to that file. The prior LeanCTX suffix exception is removed. LeanCTX remains enabled
through `LEAN-CTX.md`, hooks, configuration, and tool instructions, with automatic
managed-AGENTS rule injection disabled.

## Session governance revision

```text
GOVERNANCE_REVISION: TOKEN-OPT-001-A7
```

A session snapshots governance. After a canonical governance change, every pre-existing
write-capable session is `STALE_GOVERNANCE` for new repository mutation. It need not be
terminated, but it must not start new governed writes. A fresh session must prove the
current revision and repository authority were loaded before mutation.

## Hook and Cognee compatibility

The compatible LeanCTX `SessionEnd` hook timeout is three seconds. Heavy Cognee graph
synchronization remains asynchronous through its supported session-end or exit-worker
path and must not be forced into the synchronous hook budget.

Cognee acceptance requires API health, local LLM reachability, plugin activation,
session registration, synthetic prompt/answer storage, graph/improve completion,
cross-session recall, SessionEnd handoff, and recent hook-log review. Synthetic test data
must contain no secrets and may be forgotten only through a safe supported cleanup path.

## Deterministic implementation

Update the existing routing profile, gate, contracts, compiler, validators, personal
Codex configuration, Sol Advisor metadata, router state, managed AGENTS tooling, and HAU
extension. Do not create a parallel dispatcher. The compiler remains a selector and
validator and never starts Codex.

The active gate must enforce:

- manual owner origin;
- one exact primary Sol session;
- zero default children and at most sixteen direct Sol children;
- depth one and no worker-originated spawn;
- at most two active writers account-wide and one on the target repo/worktree;
- no background continuation;
- no automatic fallback;
- exact role/model/reasoning selection;
- disabled DeepSeek aliases;
- non-dispatching output.

## Verification

Required local evidence:

1. A2-A6 immutable hash preservation where previously pinned;
2. JSON, TOML, and PowerShell parsing;
3. focused A7 route and negative-gate fixtures with zero real model calls;
4. unchanged base, A1, A4, and A6 historical fixtures;
5. catalog proof for Sol, Ox, Terra, and Luna;
6. personal Codex parse/doctor and router state;
7. DeepSeek absent from active routes and fallback tables;
8. AGENTS inventory, dry-run, explicit apply, independent verification, byte equality,
   and SHA-256 equality;
9. project-extension equality;
10. hook timeout and load-warning proof;
11. Cognee end-to-end synthetic cross-session memory proof;
12. `git diff --check`, complete logical diff, redaction review, and Git/upstream
    reconciliation.

## Stop conditions

Stop only the affected target on an active writer owning the exact path, unknown
pre-change hash, unsafe unique rule destination, runtime capacity below the requested
value that cannot be represented truthfully, secret exposure, owner-choice verification
failure, or a required Production/provider/data mutation. Preserve independent safe
targets and stop when the accepted repair is green.
