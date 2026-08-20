---
schema_version: 1
status: active
scope: account-wide
policy_id: TOKEN-OPT-001
last_reviewed: 2026-08-21
---

# Codex Token Optimization and Context-Efficiency Rules

## Purpose

Maximize verified progress per token and per context window while preserving authority,
security, privacy, correctness, traceability, rollback, migration safety, data safety,
Git safety, and truthful reporting.

```text
MAXIMIZE VERIFIED PROGRESS PER TOKEN
GOVERNANCE WINS OVER TOKEN SAVINGS
STOP WHEN GREEN
```

This policy is the single account-wide token/context-efficiency authority. Project
repositories may add stricter local rules. They may not weaken accepted specifications,
security boundaries, privacy, data invariants, backup, rollback, release, migration, or
Git safeguards.

## Normal route

```text
ROUTE
-> READ MINIMUM AUTHORITY
-> ESTABLISH ACTIVE STEP
-> EXECUTE ONE ACCEPTED SCOPE
-> EXPAND ONLY WHEN JUSTIFIED
-> REUSE FRESH VERIFIED EVIDENCE
-> VERIFY PROPORTIONATELY
-> RECORD COMPACT DURABLE STATE
-> STOP
```

For project work:

```text
Context Vault AGENTS.md
-> authoritative repository
-> project AGENTS.md / registered project extension
-> .codex/CURRENT.md when present
-> bounded current task and handoff
-> accepted active specification or step
-> directly relevant source and tests
```

Do not start from the whole Context Vault, an entire repository, all documentation,
all tests, all migrations, historical prompts, generated output, or raw operational logs.

## Minimum sufficient context

Read only what is required to establish the next correct action.

Prefer:

- exact current pointers over broad documentation;
- exact files, symbols, and bounded ranges over directories;
- deterministic search and generated inventories over model inference;
- accepted specifications over rough prompts;
- live repository evidence over chat memory;
- verified current state over historical snapshots;
- reusable evidence tied to exact source and environment state.

Expand context only for:

- a direct dependency;
- an unresolved acceptance criterion;
- a targeted symbol or reference;
- a focused verification failure;
- a material contradiction;
- a security or privacy concern;
- a migration, compatibility, or data-invariant risk;
- a missing authoritative fact.

Use this compact abnormal-route record when expansion is material:

```text
CONTEXT_EXPANSION_REASON:
<trigger, affected scope, and why the normal route was insufficient>
```

Do not require this record for an obvious cheap read that is already inside accepted
scope.

## Accepted scope is a hard boundary

Before changing a file, identify the accepted criterion or required dependency that
needs it. When no accepted criterion or dependency requires the file, do not change it.

- Implement only the active accepted task.
- Do not repair nearby warnings, naming, formatting, tests, abstractions, architecture,
  or stale code unless they directly block accepted work.
- Record adjacent non-blocking issues briefly instead of fixing them.
- Never turn a bounded fix into a cleanup, refactor, migration, or redesign program.
- A material scope change requires an accepted amendment.

Before investigating an optional step, ask:
**If this step failed or were omitted, could the accepted DONE condition still
pass?**
If yes, park it as a brief non-blocking note and do not investigate or
implement it during the current task.

## Simplest correct implementation

Prefer the smallest direct implementation that satisfies the accepted requirement.

- Modify an existing straightforward path before creating a subsystem.
- Prefer a local function or direct change over a new class, service, registry, adapter,
  event system, framework, or abstraction.
- Do not create abstractions for hypothetical reuse.
- Do not add dependencies when the existing stack can solve the requirement clearly.
- Do not add feature flags, compatibility layers, fallback systems, duplicated
  architecture, or migration bridges unless accepted scope requires them.
- Do not refactor unrelated code.
- Avoid extra files, indirection, and cleverness.

“Cleaner,” “more scalable,” “best practice,” or “might be useful later” is not a current
accepted requirement.

## Model and reasoning defaults

```text
ORDINARY MODEL: gpt-5.6-sol
ORDINARY REASONING: high or lower
ULTRA / MAX / XHIGH: risk-gated exceptions only
```

Task size alone does not justify higher-than-High reasoning. Escalation requires a
bounded high-consequence decision involving material architecture ambiguity,
security/authorization, migration versus no migration, a difficult reproduced P0/P1
defect, irreversible data, Production/recovery, or material UX architecture that
deterministic evidence cannot decide.

## Delegation

```text
ZERO CHILDREN BY DEFAULT
ONE ACTIVE CHILD MAX
DELEGATION DEPTH: 1
```

Use deterministic tools or the parent first. A child is justified only when:

- deterministic tools are insufficient;
- the work is genuinely independent or requires the governed writer/reviewer role;
- it has one bounded output;
- owned and excluded paths are explicit;
- total context or latency is expected to decrease;
- one stop condition is explicit;
- no concurrent writer or shared-state conflict exists.

Do not run writer and reviewer children concurrently by default. Finish the writer,
review the complete diff, and add one bounded independent review only when material
risk or uncertainty remains.

## Evidence reuse

Expensive successful evidence is reusable only when it records:

```text
commit SHA
artifact hash when applicable
command
environment
exact result
timestamp
relevant paths
relevant external state
```

Before rerunning, ask:

```text
Did relevant source change?
Did relevant configuration change?
Did the artifact change?
Did the relevant environment or external state change?
```

When every answer is no, reuse the prior pass. When any answer is yes, record:

```text
REVERIFY_REASON:
<changed state and the exact evidence invalidated>
```

Do not repeat tests, builds, reviews, deployments, migrations, or analyses without an
invalidator.

## Test escalation

Use this route:

```text
targeted test
-> affected subsystem or family
-> required acceptance checks
-> one final appropriate gate
```

Do not run a full suite after every small module. Run a full gate only when:

- candidate or release authority requires it;
- a shared/core contract changed;
- cross-cutting behavior changed;
- dependency or build configuration materially changed;
- schema or migration changed;
- targeted evidence cannot establish safety.

## Review policy

Routine bounded work:

```text
implementation
-> targeted deterministic verification
-> parent complete-diff review
-> done
```

Independent review is conditional. Use it for material security, authentication,
authorization, privacy, migration, irreversible data invariants, Production/release,
destructive maintenance, difficult cross-layer defects, significant architecture,
repeated failed implementation, material contradiction, or an explicit owner request.

Do not use review as routine ceremony. Do not weaken sandbox or approval safety to
reduce review cost.

## Context packet and durable state

A context packet follows the active pointer. It includes the accepted specification and
only explicitly referenced continuation or step files. It must not unconditionally load
fixed historical plans or continuation files.

Pointers must:

- resolve only within the repository;
- reject invalid or escaping paths;
- use explicit byte caps and safe UTF-8 truncation;
- fail visibly instead of reading arbitrary files;
- stay compact.

Durable current state should answer:

```text
where are we
what is active
what authority governs it
what was verified
what happens next
what blockers exist
```

Keep project runtime state, technical logs, checkpoints, diffs, and evidence in the
authoritative project repository, not in chat memory or the Context Vault.

## Polling and loop fuse

Do not use repeated short model-mediated polling. Prefer one bounded wait, a suitable
timeout, a watcher, or resumption on completion/failure/material change.

Soft checkpoint after approximately:

```text
8 substantial model-tool cycles
OR one child completed
OR two attempts at the same strategy
OR scope begins expanding
```

Choose finish, narrow, handoff, or escalate once.

Hard checkpoint before continuing past approximately:

```text
12 substantial cycles
multiple polling loops
two failed strategies
one implementation plus one review already complete
acceptance already green
```

Then finish, checkpoint, hand off fresh context, or stop for a material decision.

Failure fuse:

```text
first same-root failure -> diagnose
second same-root failure -> stop repeating
```

## Safety precedence

Optimization never overrides:

1. current owner instructions and accepted specifications;
2. security, authorization, privacy, and secrets;
3. immutable records, data invariants, migrations, backups, and rollback;
4. repository authority, writer locks, unknown-work preservation, and Git safety;
5. deployment, Production, recovery, and external-state gates;
6. truthful evidence and reporting.

When optimization conflicts with any item above, safety wins and the affected target
stops.

## Compact task contract

For non-trivial work, establish internally:

```text
objective
authority
active_step
scope
non_goals
acceptance_criteria
verified_baseline
required_context
permitted_expansion_triggers
verification
stop_conditions
```

Do not dump this contract into chat unless it helps the owner decide or verify the work.

## Compact handoff

A handoff records only verified facts:

```text
task
authority
branch / worktree / HEAD
active writer
completed accepted scope
exact verification
blocked targets
rollback
next exact action
do not repeat
handoff status
```

Do not turn the current pointer into a historical archive. Prefer one exact next action
over artificial future-action lists.

## Current/Next Slice Pipeline

The accepted [`TOKEN-OPT-001-A1`](../governance/agents/specs/TOKEN-OPT-001-A1.md)
amendment defines one optional read-only scout-ahead lane:

```text
CURRENT WRITER FINISHES CURRENT SLICE
OPTIONAL READ-ONLY SCOUT PREPARES AN ALREADY AUTHORIZED NEXT SLICE
ENDING SHA REVALIDATES THE SCOUT PACKET
UNAPPROVED NEXT SLICE -> HANDOFF AND STOP
NEVER AUTO-START THE NEXT SLICE
```

Freeze the current authority, baseline SHA, objective, owned and excluded paths,
acceptance criteria, and named next candidate before scouting. A scout is permitted
only when the next slice already has drafting authority, the single child slot is
free, preparation is bounded and independent, paths and stop conditions are explicit,
and no stricter project rule prohibits it.

Disable scouting for trivial or inferred future work, critical or destructive
operations, migrations, Production, provider or database mutations, security or
privacy ambiguity, writer conflict, dirty unknown state, missing authority, or when
the child slot is required by the writer or a required reviewer.

The scout is read-only, may not delegate, and may interrupt the current slice only for
a wrong repository, branch, or baseline; controlling authority conflict; writer
conflict; or a security, privacy, or data-integrity risk affecting current work.

The scout packet must contain:

```text
SCOUT_STATUS
NEXT_SLICE_ID
NEXT_SLICE_AUTHORITY
SCOUT_BASELINE_SHA
OBSERVED_AT
STALE_IF
FACTS
INFERENCES
UNVERIFIED
OBJECTIVE
IN_SCOPE
OUT_OF_SCOPE
LIKELY_OWNED_PATHS
EXCLUDED_PATHS
DEPENDENCIES
CURRENT_INVARIANTS
EXPECTED_ACCEPTANCE_CRITERIA
FOCUSED_TEST_PLAN
SECURITY_OR_PRIVACY_GATES
CONFIGURATION_GATES
OWNER_DECISIONS_REQUIRED
RISKS
BLOCKERS
DO_NOT_REPEAT
NO_WRITE_ATTESTATION
```

At current-slice closeout, compare the scout baseline SHA with the ending SHA and
inspect only the delta capable of invalidating the packet. Classify it as `VALID`,
`PARTIALLY_STALE`, `STALE`, `BLOCKED`, or `NO_OP`. Static policy cannot prove runtime
zero-write behavior; parent-observed before/after Git state is required.

An identical ending SHA skips only Git-delta revalidation. Before reusing evidence,
check `STALE_IF`, relevant configuration, artifact identity, environment, and relevant
external state; any triggered invalidator requires scoped revalidation.

## Cache-friendly prompt ordering

Where ordering is controllable, place stable authority, safety rules, durable project
rules, workflow contracts, and stable tool schemas before the current slice, SHA,
failures, changed paths, live PR/provider state, timestamps, and run identifiers.

Prompt shape alone does not prove a cache hit or savings. Cache claims require runtime
telemetry. When telemetry is unavailable, report:

```text
CACHE HIT: UNVERIFIED / UNAVAILABLE
```

Unsupported universal efficiency percentages are prohibited.

## Safe compaction and tool context

Manual compaction is permitted only at a durable checkpoint recording authority, HEAD
and tree, worktree, writer, objective, completed work, changed files, verification,
blockers, next action, and actions not to repeat. Rehydration must reread minimum
authority, recheck Git identity, compare the checkpoint, and mark missing load-bearing
facts `UNVERIFIED`.

Compaction never replaces Git, accepted specifications, tests, backups, audit evidence,
migrations, recovery evidence, or provider records.

Use external tools and MCPs only when accepted scope needs them. Record
`TOOL_CONTEXT_EXPANSION_REASON` for material additions. Shared MCP disablement requires
separate authority; do not globally disable shared capabilities for theoretical savings.

Keep repository/worktree, writer, model role, reasoning, sandbox, authority, tools, and
acceptance entrypoints stable within a slice. A required change records:

```text
CONFIG_CHANGE_REASON
OLD_VALUE
NEW_VALUE
AUTHORITY
EVIDENCE_INVALIDATED
ROLLBACK / REVERSION
```

## Deterministic anti-drift defaults

Active account-wide defaults:

```text
model = gpt-5.6-sol
model_reasoning_effort = high
max concurrent threads per session <= 2
default children = 0
max active children = 1
max delegation depth = 1
routine independent review = false
routine full suite after each small module = false
```

The machine-readable defaults, the unchanged ten-fixture base suite, the versioned
26-fixture A1 suite, and the focused validator live under
`automation/codex-model-routing/`.

## Stop condition

Stop when the accepted scope is complete and the proportionate deterministic evidence is
green. Do not continue polishing, auditing, spawning, or rerunning work merely because
capacity remains.
