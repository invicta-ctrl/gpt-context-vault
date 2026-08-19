---
schema_version: 1
spec_id: TOKEN-OPT-001
title: Deterministic Codex Token Optimization and Context-Efficiency Hardening
status: accepted
owner: Earl
accepted_date: 2026-08-19
timezone: Asia/Manila
risk: high
execution_plane: Astral Bridge only
classification: stable-account-wide-governance
---

# TOKEN-OPT-001
## Deterministic Codex Token Optimization and Context-Efficiency Hardening

## Acceptance record

Earl explicitly approved this specification on 2026-08-19 with:

```text
APPROVE TOKEN-OPT-001 AS WRITTEN
```

This approval authorizes only the bounded governance, configuration, documentation,
backup, deterministic-enforcement, verification, commit/handoff, and rollback work
below. It does not waive repository handshakes, accepted-specification gates,
active-writer locks, dirty-work preservation, privacy, security, data invariants,
or any stop condition.

## Objective

Maximize useful verified progress per token and per context window while preserving
correctness, authority, security, privacy, traceability, continuity, accepted scope,
Git safety, backups, rollback evidence, data and migration safety, and truthful
reporting.

Use one architecture:

```text
Context Vault canonical policy
-> personal Codex routing/configuration
-> project AGENTS reference and stricter local rules
-> project configuration
-> deterministic validators and focused tests
```

Project repositories remain authoritative for project code, state, specifications,
tests, migrations, release evidence, and runtime facts.

## Authorized targets

### Context Vault

```text
D:\Documents\Codex\GitHub\gpt-context-vault
```

Only directly coupled files may change:

```text
AGENTS.md
START_HERE.md
CONTEXT_INDEX.md
CURRENT_FOCUS.md
protocols\CONTEXT_RETRIEVAL_PROTOCOL.md
protocols\CODEX_TOKEN_OPTIMIZATION_AND_CONTEXT_EFFICIENCY_RULES.md
automation\codex-model-routing\README.md
automation\codex-model-routing\ROUTING_STANDARD.md
automation\codex-model-routing\ directly coupled policy/fixture/validator files
governance\agents\specs\TOKEN-OPT-001.md
```

### Personal Codex

```text
C:\Users\adria\.codex\config.toml
C:\Users\adria\.codex\agents\sol-advisor.toml
C:\Users\adria\.codex\AGENTS.md
C:\Users\adria\.codex\instructions.md
```

`AGENTS.md` may change only through the canonical managed-replica process.
`instructions.md` may change only to remove an active contradictory override.

Required effective values:

```text
global model = gpt-5.6-sol
ordinary reasoning = high
Sol Advisor = gpt-5.6-sol / high
max concurrent threads per session <= 2
```

### HAU-USC Logistics governance

```text
D:\Documents\Codex\HAU-USC Logistics
```

Only an authoritative clean worktree with a released or validly transferred writer
lock may be changed. Authorized project targets are limited to:

```text
AGENTS.md
.agents\PROJECT_POLICY.md
.codex\config.toml
.codex\USAGE_POLICY.md
.codex\PHASE_AND_CONTEXT_POLICY.md
.codex\TASK_ROUTING.md
.codex\CAVEMAN_WORKFLOW.md
.codex\agents\log-triage.toml
.codex\agents\repo-mapper.toml
tools\codex\context-packet.mjs
scripts\check-agent-instructions.mjs
scripts\check-work-continuation.mjs
tests\unit\codex-governance.test.js
package.json
.codex\specs\active\ directly required accepted governance records
```

Required project limits:

```text
max_threads <= 2
max_depth <= 1
MAX_SOL_SUBAGENTS = 0
MAX_TERRA_SUBAGENTS <= 1
MAX_LUNA_SUBAGENTS <= 1
default children = 0
one active child maximum only with explicit justification
ordinary reasoning <= high
routine independent review is not mandatory
routine full-suite execution after each small module is not mandatory
```

A project may remain stricter where its accepted specification or security boundary
requires it.

## Explicit exclusions

- No runtime, product, frontend, domain, API, authentication, authorization, or
  business-behavior change.
- No migration or schema change.
- No D1, R2, Google, provider, Production, Playground, deployment, secret,
  credential, recipient, recovery-pointer, or data mutation.
- No active v0.8.3-v0.8.5 product-worktree or current-chain mutation while another
  writer owns it.
- No archive, backup, vendor, plugin, cache, marketplace, generated-output, or
  third-party package modification.
- No unrelated cleanup or historical-worktree mass synchronization.
- No weakening of sandbox, permissions, privacy, backup, rollback, migration,
  release, data, or Git safety.
- No reset, clean, rebase, force-push, history rewrite, deletion of unknown work,
  or stashing of unknown work.
- No capability, skill, Serena, or Headroom installation.

## Operating defaults

### Context

- Start from the smallest authoritative chain.
- Use `.codex/CURRENT.md` as the operational pointer when present.
- Read the bounded task, handoff, and accepted specification before broad retrieval.
- Prefer targeted search, symbols, line ranges, and direct dependencies.
- Expand only for an acceptance criterion, direct dependency, verification failure,
  contradiction, security/privacy concern, migration/compatibility risk, important
  invariant, or unclear authority.
- Stop retrieving when the next correct action is grounded.

### Reasoning and delegation

- Ordinary work uses no higher than High reasoning.
- Escalate only for material ambiguity, repeated bounded failure, security,
  migration, data integrity, architecture, or release risk.
- Use deterministic tools or the parent first.
- Default to zero children.
- Permit one active child maximum only when bounded, independent, non-overlapping,
  and explicitly justified.
- Keep delegation depth at one.

### Review and verification

- Match verification to changed behavior and risk.
- Reuse evidence only when SHA, artifact, configuration, environment, and relevant
  external state remain unchanged.
- Record the exact invalidator when re-verification is required.
- Do not rerun a full suite after each small module when focused checks prove it.
- Use stronger gates at real release, migration, security, provider, data, or
  destructive boundaries.
- Independent review is conditional, not routine ceremony.
- Stop when accepted evidence is green.

## Scope, isolation, and backup gates

This accepted specification authorizes isolated branches/worktrees, timestamped
backups, the listed governance/configuration changes, directly coupled validators
and fixtures, one coherent commit per changed repository, and push/PR only through
the repository's authorized path. It does not authorize a protected-main merge
when separate approval is required.

Use an isolated branch such as:

```text
governance/token-opt-001
```

Record root, worktree, branch, HEAD, upstream, divergence, status, instruction chain,
accepted specification, active writer, and target-file status before editing. Never
switch an occupied worktree, overwrite another task, stage unrelated files, or
delete unknown branches/worktrees.

A blocked target remains untouched. Independent targets may proceed only when their
own authority, overlap, backup, and verification gates pass. Partial completion must
be reported plainly.

Before any personal Codex write, create:

```text
C:\Users\adria\.codex\backups\TOKEN-OPT-001-YYYYMMDD-HHMMSS
```

Copy every personal file to be changed. Record original path, backup path, byte
length, and SHA-256. Verify byte identity and SHA-256 identity before editing.
Stop if a target is unexpectedly missing, unreadable, ambiguous, changing
concurrently, or cannot be backed up. Do not delete backups.

## Deterministic enforcement

Maintain one canonical Markdown policy plus machine-readable defaults, ten fixtures,
and a focused validator. The validator must fail closed on:

- missing policy or routing references;
- global model other than `gpt-5.6-sol`;
- ordinary reasoning above High;
- Sol Advisor drift;
- concurrent threads above two;
- delegation depth above one;
- default children above zero;
- active-child maximum above one;
- mandatory routine independent review or routine full-suite rules;
- missing or duplicate fixtures;
- optimization taking precedence over authority, security, rollback, migration,
  data, privacy, or Git safety.

## Ten lightweight behavior checks

Run deterministic fixtures or focused tests, not an agent swarm:

1. **Small bug** — targeted source/test discovery; no repository scan.
2. **New session continuation** — Context Vault `AGENTS.md` -> repository -> project
   `AGENTS.md` -> `.codex/CURRENT.md` -> accepted active specification/step.
3. **Missing specification** — stop before substantial implementation.
4. **Failing focused test** — expand only into affected dependencies with a compact
   reason.
5. **Fresh existing verification** — reuse when SHA, artifact, configuration,
   environment, and external state remain valid.
6. **Stale verification** — changed relevant state produces a re-verification reason.
7. **Large repository** — targeted discovery rather than broad reading.
8. **Subagent opportunity** — deterministic tool or parent first; zero children by
   default; one maximum with explicit justification.
9. **Conflicting governance** — stop with the exact conflict.
10. **Optimization Versus Safety** — security, authority, rollback, migration, data,
    privacy, and Git safety win.

Record `PASS` or `FAIL` with exact fixture/test evidence.

## Execution order

1. Verify exact owner approval.
2. Read the minimum Context Vault authority.
3. Perform Context Vault Git/worktree handshake.
4. Resolve `AGENTS-CONSOLIDATION-001` overlap and reuse only fresh evidence.
5. Inspect effective personal model/reasoning/thread/profile/agent settings without
   printing secrets.
6. Inspect authoritative HAU current chain and writer.
7. Classify every target: clean and owned, dirty unrelated, dirty overlap, owned by
   another task, missing but authorized, or missing and unauthorized.
8. Stop the affected target on conflict.
9. Create this accepted specification when absent; then re-run authority.
10. Create isolated worktrees for eligible repositories.
11. Record starting state.
12. Create and verify personal backups before personal writes.
13. Create the canonical policy.
14. Update only minimum routing/index references.
15. Create deterministic defaults, fixtures, and validator.
16. Set personal model/reasoning/thread values when needed.
17. Verify Sol Advisor remains `gpt-5.6-sol/high`.
18. Repair only authorized active contradictory overrides.
19. Update HAU only after its independent gate passes.
20. Run syntax/parse checks.
21. Run all ten fixtures.
22. Run directly coupled focused validators/tests.
23. Run `git diff --check`.
24. Review every complete logical diff once.
25. Search changed scope for contradictions and out-of-scope changes.
26. Repair material defects and rerun only invalidated checks.
27. Commit one coherent change per changed repository when authorized.
28. Prepare rollback evidence and compact handoff.
29. Stop.

## Commit, push, and rollback

- Commit only exact accepted files in one coherent governance commit per repository.
- Exclude unrelated dirty work and private backups.
- Push or open a PR only when current repository policy authorizes it.
- Do not merge protected main without separate required authority.
- Do not deploy.

Rollback uses a normal revert commit for pushed/merged governance changes and exact
timestamped SHA-256-verified backups for personal files. Never use reset, force-push,
history rewrite, deletion of unknown work, or deletion of backups.

## Required verification

```text
approval evidence present
accepted specification present
isolated Context Vault branch/worktree based on verified main
personal backups byte-identical and SHA-256-identical
global model = gpt-5.6-sol
ordinary reasoning = high
Sol Advisor = gpt-5.6-sol/high
max concurrent threads <= 2
max delegation depth <= 1
default children = 0
active child maximum <= 1
canonical policy exists and is indexed
all ten fixtures PASS
configuration and policy data parse
focused validators/tests PASS
no routine mandatory review/full-suite rule in changed active scope
no safeguard weakened
no runtime/product/provider/database/deployment behavior changed
no unrelated or unknown work changed
complete diffs reviewed
rollback evidence present
blocked targets reported honestly
```

Do not claim checks that did not run.

## Stop conditions

Stop the affected target on:

- missing approval or scope;
- material authority conflict;
- unresolved `AGENTS-CONSOLIDATION-001` overlap;
- conflicting writer;
- dirty overlap or unknown work;
- ambiguous authoritative worktree or effective config;
- personal backup failure or hash mismatch;
- need to install a capability, skill, Serena, or Headroom;
- weakened security, sandbox, permissions, privacy, rollback, migration, data, or
  Git safety;
- provider, database, Production, deployment, migration, recovery-pointer,
  destructive, or product-behavior work;
- out-of-scope diff;
- unresolved validator/focused-test failure;
- two failed strategies for the same root cause;
- secret or unnecessary private-data exposure.

A stopped target stays untouched. Other independent eligible targets may proceed.

## Required handoff

```text
TASK
AUTHORITY
STARTING SHA
ENDING SHA
BRANCH
ACTIVE_WRITER
BACKUPS
CONTEXT VAULT CHANGES
PERSONAL CODEX CHANGES
HAU-USC CHANGES
CAPABILITIES USED / NOT INSTALLED
VERIFICATION AND EXACT RESULTS
UNRUN CHECKS
BLOCKED TARGETS
ROLLBACK
NEXT SAFE ACTION
DO NOT REPEAT
HANDOFF_STATUS
```

Full completion requires all required eligible targets. With a required target still
blocked, report:

```text
PARTIAL — BLOCKED TARGET PRESERVED
```

## Final operating contract

Use the simplest correct accepted solution. Use deterministic tools first. Use zero
children by default and one maximum only with justification. Retrieve targeted
context, reuse fresh evidence, run targeted checks, preserve unknown work, hand off
before context bloat, and stop when green. Never trade authority, security,
correctness, traceability, rollback, migration safety, data safety, privacy, or Git
safety for token savings.
