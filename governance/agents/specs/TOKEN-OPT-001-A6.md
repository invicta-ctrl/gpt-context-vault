---
schema_version: 1
spec_id: TOKEN-OPT-001-A6
parent_spec: TOKEN-OPT-001-A5
title: Manual-Only Billable Codex Execution Boundary
status: accepted
owner: Earl
accepted_date: 2026-08-25
timezone: Asia/Manila
risk: high
execution_plane: deterministic local tools only; no Codex model execution
classification: emergency-owner-superseding-usage-control
compatible_with:
  - TOKEN-OPT-001
  - TOKEN-OPT-001-A1
  - TOKEN-OPT-001-A2
  - TOKEN-OPT-001-A3
  - TOKEN-OPT-001-A4
  - TOKEN-OPT-001-A5
supersedes:
  - A4 and A5 execution-plane authority wherever it permits automatic or background Codex model use
  - A4 default delegation, adaptive-worker, burst-worker, and automatic-fallback activation
---

# TOKEN-OPT-001-A6
## Manual-Only Billable Codex Execution Boundary

## Acceptance record

Earl explicitly instructed ChatGPT on 2026-08-25 (Asia/Manila) that ChatGPT Web
and Astral Bridge are prohibited from consuming Codex usage unless it is absolutely
necessary, and that any work requiring Codex must be started manually with Earl's
explicit approval. Earl approved separating background infrastructure from billable
execution and authorized implementation of the complete protective baseline without
calling Codex.

This amendment is accepted directly from that owner instruction. It supersedes any
earlier prompt, continuation authority, routing profile, or autonomous-completion
language that could be read as permission for ChatGPT Web, Astral Bridge, an
automation, or a delegated agent to start Codex model work.

## Confirmed incident and root cause

The A4/A5 route treated a general instruction to execute TOKEN-OPT work as permission
to launch `codex exec`, including delegated workers and a Terra Max writer. That
conflated configuration of Codex routing with authorization to spend Codex allowance.

During A6 preflight, one still-running process was verified as:

```text
codex.exe exec
model: gpt-5.6-terra
reasoning: max
workspace: D:\Documents\Codex\GitHub\gpt-context-vault
started: 2026-08-25 00:35:57 Asia/Manila
PID at containment: 26800
```

A6 authorizes exact termination of that execution tree while preserving its session
log, stderr log, partial repository files, and provenance. The two existing
`codex app-server` processes are infrastructure and must remain running.

## Mandatory execution boundary

### Infrastructure plane â€” allowed to remain running

The following are non-billable infrastructure unless direct evidence proves otherwise:

- Codex `app-server` listeners;
- Astral Bridge and its deterministic MCP/file/Git/command tools;
- the ChatGPT-to-local tunnel;
- Codex Router and its tray;
- connector health checks;
- Headroom, LeanCTX, Serena, CodeGraph, and other local tools when they are not
  launched as children of a billable Codex turn;
- deterministic configuration, file, Git, test, build, and verification commands.

Infrastructure availability is not authorization to start a model turn.

### Billable or model-execution plane â€” locked by default

The following require a new, explicit, per-run owner approval:

- `codex exec`, an interactive Codex CLI task, task/thread creation, task continuation,
  or sending a message to an existing Codex task;
- Codex subagents, scouts, writers, reviewers, model capability probes, or real-agent
  checks;
- any model-routed fallback, retry, continuation, scheduled run, heartbeat, watchdog
  action, or background process capable of consuming Codex allowance;
- any ChatGPT Web or Astral Bridge action that would call an OpenAI Codex model,
  even when a prior task, prompt, or accepted amendment used Codex.

â€œAbsolutely necessaryâ€ is a reason to stop and ask Earl. It is never
self-authorization. A prior approval does not carry into a new run, retry, fallback,
child, continuation, or later task.

Direct, deliberate interaction by Earl inside the Codex Desktop UI is treated as Earl
manually starting that specific task. Automated CLI execution remains locked until Earl
runs the interactive local permit command.

## Effective defaults

```text
BILLABLE CODEX EXECUTION: LOCKED
AUTOMATED CODEX RUNS: 0
BACKGROUND CODEX CONTINUATIONS: 0
CODEX CHILDREN/SUBAGENTS: 0
ACTIVE BILLABLE CODEX PROCESSES: 0
MAXIMUM AFTER ONE MANUAL PERMIT: 1
AUTOMATIC MODEL FALLBACK: DISABLED
APP-SERVER INFRASTRUCTURE: ALLOWED
```

The A4 model-role catalog may remain as dormant reference metadata for a future
owner-approved manual run. It does not authorize dispatch. The machine defaults must
disable Native Multi-Agent V2, expose no spawnable child models, and cap concurrent
Codex execution at one.

## Required implementation

1. Stop and verify termination of the exact unauthorized A5 Terra Max execution tree.
   Preserve all files and logs it created; do not reset, clean, delete, or silently
   overwrite them.
2. Install an owner-local Codex usage guard under
   `C:\Users\adria\.codex\usage-guard\`:
   - persistent scheduled guard task;
   - exact `app-server` infrastructure allowlist;
   - fail-closed termination of every other `codex.exe` process without a live permit;
   - one-process, time-bounded, single-use permit;
   - interactive challenge-based enable command that starts no Codex process;
   - disable and status commands;
   - redacted local event log;
   - deterministic self-test using a harmless dummy executable named `codex.exe`,
     never the real Codex binary.
3. Back up and change personal Codex configuration so agents are disabled,
   concurrent threads are capped at one, Multi-Agent V2 is disabled, child-model
   overrides are hidden, and the router exposes no spawnable child models.
4. Add an account-wide manual-execution gate in the Context Vault. The route compiler
   must reject non-manual origins, missing/expired/mismatched permits, unapproved
   models/roles/reasoning, automatic fallback outside the permit, and second-process
   attempts before any dispatch.
5. Update canonical AGENTS governance, the canonical TOKEN-OPT policy, routing
   documentation, machine-readable policy, global Codex extension, focused tests, and
   validators. Preserve A2/A3/A4 bytes and retain A5 unchanged as a paused accepted
   scope.
6. Synchronize only registered, writer-safe managed AGENTS/extension targets after a
   dry run and hash-verified backups. A blocked active project remains untouched.
7. Record compact redacted evidence and normal Git provenance. Do not use Codex,
   subagents, provider calls, or model capability checks to implement or verify A6.

## Approval contract for a future manual CLI run

The interactive permit must record:

```text
approval_id
issued_by
issued_at
expires_at
purpose
allowed_model
allowed_reasoning
allowed_roles
max_processes = 1
manual_interactive = true
```

The permit does not start Codex. Earl must manually start the approved task after the
permit is created. It is consumed by the first eligible process, cannot authorize a
second process, and expires automatically. Ending or revoking the permit terminates any
non-infrastructure Codex process it authorized.

This is a strong accidental-automation and workflow boundary. Because local automation
runs under Earl's Windows account, it is not a security boundary against a malicious
same-user administrator deliberately disabling the guard. That limitation must be
reported plainly.

## Out of scope

- completing the paused A5 material-risk work;
- deleting, rewriting, or fabricating the A5 spec or its partial files;
- shutting down app-server infrastructure, the router, tunnel, or health checks;
- provider purchases, credentials, API calls, model probes, or test turns;
- production deployment, migration, protected-main merge, force push, reset, clean,
  stash, or unrelated repository maintenance.

## Verification

Required evidence:

- no running `codex.exe` process except verified `app-server` infrastructure;
- no launcher/watchdog capable of restarting the terminated A5 job;
- guard self-test PASS;
- harmless dummy `codex.exe` is terminated while app-server classification is allowed;
- scheduled guard task registered and running;
- personal config shows agents disabled and concurrency one;
- router multi-agent state exposes zero enabled/spawnable child models;
- route-compiler focused gate tests PASS without real model execution;
- canonical and machine-readable policy validators PASS;
- AGENTS sync dry-run, bounded apply, and post-verify receipts;
- complete logical diff review, `git diff --check`, and redaction scan;
- exact backup manifest and rollback instructions.

## Rollback

Rollback is limited to restoring the timestamped A6 backups for personal configuration,
router state, guard task definition, managed AGENTS/extension files, and repository
files. Rollback must never restart a Codex model task automatically. A later owner
decision may remove or relax A6 only through a new accepted amendment and explicit
manual action.

## Stop conditions

Stop on a new non-app-server Codex process, conflicting writer, unexpected repository
drift, backup failure, unsafe target, failed guard test, failed policy test, failed sync,
secret exposure, or inability to prove the system is locked. Stop when A6 is green.
Do not resume A5 or start any Codex task.