---
schema_version: 1
status: active
scope: account-wide
policy_id: TOKEN-OPT-001
last_reviewed: 2026-08-20
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

The machine-readable defaults, ten behavior fixtures, and focused validator live under
`automation/codex-model-routing/`.

## Stop condition

Stop when the accepted scope is complete and the proportionate deterministic evidence is
green. Do not continue polishing, auditing, spawning, or rerunning work merely because
capacity remains.
