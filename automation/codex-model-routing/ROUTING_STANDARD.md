# Codex routing standard

## Objective

Select the least expensive model and reasoning level that can reliably complete
the validated brief. Routing is a constrained decision, not a claim that the
largest model is always better.

## Dimensions

Score the refined brief for ambiguity, repository exploration, breadth, required
judgment, parallelizability, risk, and objective verifiability. Also record the
usage budget and reserve enough capacity for deterministic checks and review.

## Logical route tiers

Projects map these logical tiers to models supported by their installed Codex
catalog:

| Tier | Use when |
|---|---|
| `fast` | Small, explicit, reversible, one-to-three-file work with direct checks |
| `implementation` | Clear multi-step work in a known architecture with objective tests |
| `exploration` | The main cost is tracing unfamiliar modules or cross-file behavior |
| `judgment` | Architecture, schema, permissions, migration, security, or data-integrity decisions dominate |
| `deep_review` | High-risk work, release blockers, or a lower tier failed with evidence |

Reasoning should be `low` or `medium` for fast work and may use `high` for
ordinary implementation, exploration, or consequential judgment. Ordinary work
does not exceed High by default. Higher installed values are risk-gated
exceptions, not routine routing choices. Never use an unsupported value.

## Current Codex compatibility rule

The project must verify actual model aliases before routing. Current local
profiles may expose account-specific aliases such as `gpt-5.6-terra`,
`gpt-5.6-luna`, and `gpt-5.6-sol`; public Codex documentation also describes
`gpt-5.6`, `gpt-5.6-terra`, and `gpt-5.3-codex-spark`. The route schema must
allow only the project's verified set. Do not silently treat `Ultra`, `Max`, or
another UI label as a CLI reasoning value.

## Selection guidance

- Prefer the fast tier for localized documentation or deterministic transforms.
- Prefer implementation for a bounded feature or refactor in a known design.
- Prefer exploration when the files and root cause are not yet known.
- Prefer judgment when a design choice, schema change, permission boundary,
  migration, or data-integrity decision is the hard part.
- Prefer deep review only when risk or evidence justifies it.
- Explain why a cheaper tier is insufficient and why a more expensive tier is
  unnecessary.

## Subagents and worktrees

Use zero children by default. Permit one active child maximum only when the work
is bounded, independent, non-overlapping, explicitly justified, and expected to
reduce total context or latency without weakening verification. Keep delegation
depth at one. Prefer read-only exploration, testing, or review to parallel
writes; any child write requires isolated ownership and the repository's writer
rules. A sequential task stays with the parent even when it is large.

## Current/next-slice scouting

An optional read-only scout may prepare one already authorized next slice while the
sole writer finishes the current slice. The scout may not write or delegate. It is
disabled for trivial, inferred, critical, destructive, migration, Production,
provider, database, security-ambiguous, writer-conflicted, or dirty-unknown work.

The parent records the scout baseline SHA, requires `STALE_IF`, and compares the
packet with the current slice's ending SHA. Reuse only revalidated facts. Never auto-start
the next slice; an unapproved next slice receives a handoff and stops.

Where controllable, keep stable authority and workflow schemas before volatile SHA,
failure, PR, provider, timestamp, and run state. Cache claims require runtime
telemetry. Manual compaction requires a durable checkpoint and post-compaction Git
and authority rehydration. Material tool-context or slice-configuration changes
require their recorded reason, authority, invalidated evidence, and rollback.

## Escalation

Escalate one meaningful level at a time only when evidence shows the root cause
is unresolved, architecture is more ambiguous, scope expanded, tests reveal
broader risk, or security/data-integrity impact is higher than routed. Do not
escalate merely because a worker took time.

## Verification and safe stops

Every route names an allowlisted verification profile. Use targeted checks
first, then affected and required acceptance checks. Do not run a full suite after every small module.
Independent review is conditional on material risk,
uncertainty, or explicit owner request rather than routine ceremony. Reuse
same-SHA evidence while its source, configuration, environment, artifact, and
external-state assumptions remain valid, and stop when accepted evidence is
green.

Block when the refinement is invalid, the route is unsupported, the worktree
is unsafe, documentation conflicts materially, or a destructive/deployment/
migration/external-write action lacks explicit approval. A hook can add context
or block supported tool calls, but it is not the sole routing boundary.

