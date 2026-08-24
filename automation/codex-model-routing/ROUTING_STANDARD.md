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
ordinary implementation, exploration, or consequential judgment. The accepted A4
current profile is the explicit role-specific exception: Sol uses `high`, Terra
writer and Luna durable worker use `max`, and eligible Ox uses `high`. Never use
an unsupported value or substitute a model outside the current profile.

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

## Current worker capacity and worktrees

Use the current profile and compiler rather than hand-selecting a child model.
Default capacity is one Terra writer plus two read-only workers; adaptive capacity
is one writer plus two-to-four read-only workers, and an independent burst never
exceeds six total active workers. There is exactly one overlapping writer.

Luna and Ox share one read-only, non-delegating contract. Terra alone owns the
bounded workspace-write contract. Recursive worker spawning and duplicate ordinary
work are prohibited. Ox is eligible only with observed provider availability,
exactly-zero prompt and completion prices, acceptable health, and a suitable data
class; on one failure it becomes ineligible for the run and falls back once to
Luna. A sequential task stays with the parent even when it is large.

## Current/next-slice scouting

An optional read-only A1 scout may prepare one already authorized next slice while the
sole writer finishes the current slice. The scout may not write or delegate. It is
disabled for trivial, inferred, critical, destructive, migration, Production,
provider, database, security-ambiguous, writer-conflicted, or dirty-unknown work.
This specialized one-scout rule does not reduce the A4 current-slice read-only capacity.

The parent records the scout baseline SHA, requires `STALE_IF`, and compares the
packet with the current slice's ending SHA. Reuse only revalidated facts. Never auto-start
the next slice; an unapproved next slice receives a handoff and stops.

Where controllable, keep stable authority and workflow schemas before volatile SHA,
failure, PR, provider, timestamp, and run state. Cache claims require runtime
telemetry. Manual compaction requires a durable checkpoint and post-compaction Git
and authority rehydration. Material tool-context expansion requires
`TOOL_CONTEXT_EXPANSION_REASON`. Mid-slice configuration changes require their
recorded reason, old and new values, authority, invalidated evidence, and rollback.

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
same-SHA evidence only through a passing verification receipt whose source,
configuration, test, dependency, and external-state fingerprints all match. Record
only redacted telemetry and stop when accepted evidence is green.

Block when the refinement is invalid, the route is unsupported, the worktree
is unsafe, documentation conflicts materially, or a destructive/deployment/
migration/external-write action lacks explicit approval. A hook can add context
or block supported tool calls, but it is not the sole routing boundary.

