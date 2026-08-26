# Codex routing standard

## Objective

Select the least expensive model and reasoning level that can reliably complete
the validated brief. Routing is a constrained decision, not a claim that the
largest model is always better.

## Manual execution boundary

Routing is selection metadata, not permission to spend Codex allowance.
`SOL-ADVISOR-GLOBAL-001` defines `solo|delegate|audit|full`: solo is the default with at
most one auxiliary; Luna / Max and Terra / High are native implementation lanes; Ox is
implementation-only and fail-closed. A8 is locked safety/history only. ChatGPT Web,
Astral Bridge, automation, scheduling, prior prompts, and accepted autonomous
continuations may not start or resume Codex. Only an explicit owner-started Sol session
may route billable work.

One permit names one exact purpose, model, reasoning level, and role. The active Sol
route uses zero auxiliaries for `solo`, one native implementer for `delegate`, one fresh
Sol reviewer for `audit`, and one implementer or one reviewer per `full` compiler
invocation. Retained A8 numeric caps are safety ceilings; they do not authorize a larger
default topology. Delegation depth remains one, Sol subagents and recursive spawning are
prohibited, and automatic fallback or background continuation is disabled. The route
compiler never dispatches.

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
ordinary implementation, exploration, or consequential judgment. The active
`SOL-ADVISOR-GLOBAL-001` profile is the role-specific exception: Sol uses `high`, Luna
bounded implementation uses `max`, Terra high-risk implementation uses `high`, and
eligible Ox implementation uses `high`. Never use an unsupported value or substitute a
model outside the current profile.

## Current Codex compatibility rule

Use the static local catalog to validate exact aliases and supported reasoning values.
A real capability probe is billable Codex execution and must not be launched by ChatGPT
Web, Astral Bridge, or automation. A probe requires its own manual permit. Never treat a
UI label as a CLI value or silently substitute another model.

## Selection guidance

- Prefer the fast tier for localized documentation or deterministic transforms.
- Prefer implementation for a bounded feature or refactor in a known design.
- Prefer exploration when the files and root cause are not yet known.
- Prefer judgment when a design choice, schema change, permission boundary,
  migration, or data-integrity decision is the hard part.
- Prefer deep review only when risk or evidence justifies it.
- Explain why a cheaper tier is insufficient and why a more expensive tier is
  unnecessary.

## Current execution capacity

```text
DEFAULT PROCESSES: 0
MANUALLY PERMITTED OWNER-STARTED SOL PROCESSES: 1
CURRENT MODES: solo | delegate | audit | full
SOLO DEFAULT: TRUE
MAXIMUM AUXILIARIES PER DECLARED ROUTE: 1
SOL SUBAGENTS: 0
RETAINED A8 LUNA MAX SAFETY CEILING: 16
RETAINED A8 TERRA MAX SAFETY CEILING: 2
RETAINED A8 OX ALPHA SAFETY CEILING: 16
RETAINED A8 TOTAL DIRECT SUBAGENT SAFETY CEILING: 16
MAXIMUM DELEGATION DEPTH: 1
MAXIMUM ACTIVE WRITERS ACCOUNT-WIDE: 2
MAXIMUM WRITERS PER REPOSITORY/WORKTREE: 1
BACKGROUND CONTINUATION: 0
AUTOMATIC FALLBACK: 0
```

Sol / High is the parent planner, router, integrator, and final acceptance authority and
is never child-eligible. `solo` has zero auxiliaries; `delegate` has one Luna / Max or
Terra / High implementer; `audit` has one fresh read-only Sol / High reviewer; and each
`full` invocation has exactly one implementer or one reviewer. Ox / High is
implementation-only when its exact gate passes; otherwise the selector chooses the native
lane before dispatch. A8 is locked safety/history only. DeepSeek is disabled. A second
writer requires proven isolation and no target may have more than one writer.

## Historical current/next-slice scouting

A1 scout-ahead semantics and A8 routing topology remain historical policy evidence.
A8 is locked safety/history only: deterministic non-model tools may prepare bounded
evidence when otherwise authorized, but neither tools nor children may auto-start the
next slice.

## Escalation

Escalation to a different model, reasoning level, role, retry, or fallback requires an
explicit Sol decision and a matching exact permit. Evidence may justify the decision,
but it never authorizes an automatic route. Do not escalate merely because work took time.

## Verification and safe stops

Every route names an allowlisted verification profile. Use targeted checks
first, then affected and required acceptance checks. Do not run a full suite after every small module.
Independent review is conditional on material risk,
uncertainty, or explicit owner request rather than routine ceremony. Reuse
same-SHA evidence only through a passing verification receipt whose source,
configuration, test, dependency, and external-state fingerprints all match. Record
only redacted telemetry and stop when accepted evidence is green.

Block when the refinement is invalid, the route is unsupported, a fresh exact manual
permit is missing, the origin is ChatGPT Web/Astral/automation, another Codex process
exists, the worktree is unsafe, documentation conflicts materially, or a destructive/
deployment/migration/external-write action lacks explicit approval. A hook can add context
or block supported tool calls, but it is not the sole routing boundary.

