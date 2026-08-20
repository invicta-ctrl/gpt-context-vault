---
schema_version: 1
spec_id: TOKEN-OPT-001-A1
parent_spec: TOKEN-OPT-001
title: Sol Advisor Current/Next Slice Pipeline and Read-Only Scout-Ahead Governance Amendment
status: accepted
owner: Earl
accepted_date: 2026-08-20
timezone: Asia/Manila
risk: high
execution_plane: Astral Bridge only
classification: stable-account-wide-governance
---

# TOKEN-OPT-001-A1

## Acceptance record

Earl explicitly approved this amendment on 2026-08-20 with:

```text
APPROVE TOKEN-OPT-001-A1 AS WRITTEN
```

Earl separately authorized merging Context Vault PR #12. The merged base is commit
`7b3d9be9912c54954247a974a245fd6b51a42d04` with tree
`9f81e5ede95a1a62cc995d7a606c881676292b53`.

This approval authorizes only the bounded specification, canonical-policy,
machine-contract, versioned-fixture, validator, routing, verification, branch,
commit, push, PR, handoff, and rollback work below. It does not authorize an A1
merge, A2/Odysseus retirement, HAU-USC mutation, deployment, migration, provider,
database, Cloudflare, Google, Figma, Production, secret, or destructive action.

## Objective

Establish a deterministic Current/Next Slice Pipeline with one current writer, an
optional bounded read-only scout, ending-SHA revalidation, no automatic next-slice
execution, safe context compaction, telemetry-gated cache claims, task-relevant tool
context, and stable per-slice configuration.

## Governing invariants

- Zero children by default.
- At most one active child.
- Delegation depth one.
- Exactly one writer.
- A scout is read-only and may not delegate.
- Deterministic tools and parent execution come first.
- A scout never authorizes or starts the next slice.
- The next slice must already have accepted authority.
- Project-specific stricter rules win.
- Ordinary reasoning does not exceed High by default.
- Security, privacy, data integrity, rollback, Git safety, and owner gates outrank efficiency.

## Current/next-slice pipeline

1. Freeze the current slice, accepted authority, baseline SHA, objective, owned paths,
   exclusions, acceptance criteria, and next accepted candidate.
2. Spawn no scout unless all scout gates pass.
3. Finish and verify the current slice through its authorized path.
4. Record the ending SHA and worktree state.
5. Compare the scout baseline with the ending SHA. Same SHA skips only Git-delta
   revalidation after checking `STALE_IF`, relevant configuration, artifact identity,
   environment, and relevant external state; inspect any triggered invalidators.
6. Classify the packet as `VALID`, `PARTIALLY_STALE`, `STALE`, `BLOCKED`, or `NO_OP`.
7. Adopt only revalidated facts.
8. If the next slice lacks approval, produce a handoff and stop.
9. Never automatically implement the next slice.

## Scout eligibility and disable rules

A scout is permitted only when a named next slice already has sufficient drafting
authority, bounded preparation is independent and useful, the single child slot is
available, the current writer remains the sole writer, paths and stop conditions are
explicit, and no stricter project rule prohibits it.

The scout is disabled for trivial work, inferred future work, critical mutation,
security or privacy ambiguity, destructive maintenance, migration, Production,
provider or database operations, writer conflict, dirty unknown state, missing
authority, or when the child slot is needed by the writer or a required reviewer.

The scout may interrupt the current slice only for wrong repository, branch, or
baseline; controlling authority conflict; writer conflict; or a security, privacy,
or data-integrity risk affecting current work.

## Required scout packet

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

Runtime zero-mutation evidence requires parent-observed before/after HEAD, tree,
status, and changed paths. Static policy alone cannot prove it.

## Cache, context, tools, and configuration

Where ordering is controllable, stable authority, safety rules, repository rules,
workflow contracts, and tool schemas precede volatile SHA, failures, PR state,
timestamps, and run identifiers.

Cache hits or savings may be reported only from runtime telemetry. Without telemetry,
report `UNVERIFIED/UNAVAILABLE`. Unsupported universal efficiency percentages are
prohibited.

Manual compaction requires a durable checkpoint recording authority, HEAD and tree,
worktree, writer, objective, completed work, changed files, tests, blockers, next
action, and actions not to repeat. Rehydration must reread minimum authority and
recheck Git identity. Compaction never replaces Git, accepted specifications, tests,
backups, audit evidence, migrations, or provider records.

Material tool-context expansion requires `TOOL_CONTEXT_EXPANSION_REASON`. Shared MCP
disablement requires separate authority. A mid-slice configuration change must record
reason, old and new values, authority, invalidated evidence, and rollback.

## Machine contract and fixture versioning

Extend the existing canonical policy, fixture artifact, and validator. Do not create
a second token policy, fixture artifact, validator, or current-state document.

The existing fixture artifact is versioned into two named suites:

- `TOKEN-OPT-001` version 1: exactly the existing ten fixtures and meanings.
- `TOKEN-OPT-001-A1` version 1: exactly 26 unique fixtures covering the approved
  current/next-slice, scout, cache, compaction, tool-context, configuration, and
  truthful-claim scenarios.

The machine policy must represent the complete pipeline contract, packet schema,
revalidation classes, disable rules, stable-before-dynamic prompt guidance,
telemetry-gated cache claims, durable compaction, task-relevant tools, configuration
change records, and unsupported-percentage prohibition.

## Static validation limits

The validator may prove policy and fixture parity, suite counts, required active
guidance, data-return purity, contradiction absence, configuration contracts, and
unsupported numeric percentage absence.

It must not claim that a runtime scout made zero writes, a cache hit occurred, a token
quantity was saved, compaction preserved every semantic detail, or an MCP consumed a
particular token amount.

## Authorized repository paths

```text
governance/agents/specs/TOKEN-OPT-001-A1.md
protocols/CODEX_TOKEN_OPTIMIZATION_AND_CONTEXT_EFFICIENCY_RULES.md
automation/codex-model-routing/token-optimization.policy.json
automation/codex-model-routing/token-optimization.behavior-fixtures.json
automation/codex-model-routing/verify-token-optimization.ps1
CONTEXT_INDEX.md when needed for discoverability
automation/codex-model-routing/README.md when needed for discoverability
automation/codex-model-routing/ROUTING_STANDARD.md when needed for active routing
AGENTS.md only if a universal top-level invariant is otherwise undiscoverable
```

Personal configuration is a no-op while already compliant. Any required future
personal change needs a fresh timestamped, SHA-256-verified, byte-identical backup.

## Existing-project adoption

Adoption requires no active writer, a released writer lock, a ready handoff, a known
baseline, preserved working state, project-spec authority, and no stricter-rule
conflict. HAU-USC remains excluded and pending separate authority.

## Future-project adoption

Future registered projects inherit this account-wide pipeline through the canonical
policy reference. They may add stricter concurrency, writer, security, privacy,
migration, release, or verification rules in their registered project extension.
They must not copy the complete account-wide policy into a competing local authority.

## Verification

- Reverify root, branch, HEAD, upstream, divergence, status, and writer state.
- Parse policy and fixture JSON.
- Prove the base suite remains exactly the original ten fixtures.
- Prove the base suite's canonical serialized SHA-256 remains
  `eb5314d707734395ebf2a23b9294cda6855a2dfbeacf6e4645fba1de5513ba58`.
- Prove the A1 suite contains exactly 26 unique fixtures with policy parity.
- Preserve and pass file-content purity, marker-present, and marker-absent regressions.
- Run a bounded active-governance contradiction scan, excluding archive and history.
- Run repository-only validation before personal checks.
- Run `git diff --check`, changed-path allowlist, redaction scan, and complete diff review.
- Prove zero HAU, A2, provider, database, deployment, migration, Production, and Figma changes.
- Report runtime-only controls as observed evidence, not static-validator results.

## Branch, PR, merge, and rollback

Implementation uses one isolated branch from the verified merged base and one A1 PR.
Normal push is permitted. Force-push, direct protected-main push, and A1 merge without
separate authorization are prohibited.

Rollback uses a normal revert commit for repository changes and verified timestamped
backups for any separately authorized personal configuration change. Never reset,
force-push, rewrite history, or delete unknown work.

## Stop conditions

Stop on missing authority, wrong baseline, dirty unknown work, writer conflict,
authority contradiction, base-fixture drift, static/runtime proof confusion, failed
verification, unsafe personal backup, out-of-scope change, HAU/A2/external mutation
requirement, two failed strategies for one root cause, or absent merge authority.

Stop when the accepted A1 implementation is green and its PR has been read back. Do
not merge A1 without separate owner authorization.
