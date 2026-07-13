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

Reasoning should be `low` or `medium` for fast work, `medium` for ordinary
implementation/exploration, and `high` or the installed high-end value only
for consequential judgment or review. Never use an unsupported value.

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

Use subagents only when there are at least three independent workstreams,
non-overlapping ownership, and a final integration step. Read-heavy
exploration, testing, and review are safer than parallel writes. Any parallel
write work requires isolated worktrees and explicit ownership. Keep nesting at
one level and the thread cap conservative. A sequential task should use one
worker, even when it is large.

## Escalation

Escalate one meaningful level at a time only when evidence shows the root cause
is unresolved, architecture is more ambiguous, scope expanded, tests reveal
broader risk, or security/data-integrity impact is higher than routed. Do not
escalate merely because a worker took time.

## Verification and safe stops

Every route names an allowlisted verification profile and a read-only review.
Block when the refinement is invalid, the route is unsupported, the worktree
is unsafe, documentation conflicts materially, or a destructive/deployment/
migration/external-write action lacks explicit approval. A hook can add context
or block supported tool calls, but it is not the sole routing boundary.

