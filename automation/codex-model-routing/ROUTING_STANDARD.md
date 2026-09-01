# Codex routing standard

## Objective

Select the least expensive model and reasoning level that can reliably complete
the validated brief. Routing is a constrained decision, not a claim that the
largest model is always better.

## Manual execution boundary

Routing is selection metadata, not permission to spend Codex allowance. `MAEOS-v1` is
the active routing standard: Sol / High is root; zero children is default; Luna / Max
is read-only only; Terra / High handles every native non-Ox implementation, writer, and
integration task; Ox is implementation-only and fail-closed. Historical
`SOL-ADVISOR-GLOBAL-001` labels are fixture provenance only. A8 is locked safety/history only. ChatGPT Web,
Astral Bridge, automation, scheduling, prior prompts, and accepted autonomous
continuations may not start or resume Codex. Only an explicit owner-started Sol session
may route billable work.

One permit names one exact purpose, model, reasoning level, and role. MAEOS topology
starts with zero children; permits may authorize 0–4 normal read-only Luna leaves and
normally at most five total children including at most one Terra/Ox writer. A finite
root-authored graph may authorize a read-only burst through sixteen; it never authorizes
another writer. Retained A8 numeric caps are safety ceilings, not staffing defaults.
Delegation depth remains one, Sol subagents and recursive spawning are prohibited, and
automatic fallback or background continuation is disabled. The route compiler never dispatches.

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
ordinary implementation, exploration, or consequential judgment. MAEOS-v1 assigns Sol
`high` root/review, Luna `max` read-only leaves, Terra `high` native non-Ox writing and
integration, and eligible Ox implementation `high`. Never use an unsupported value or substitute a
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
DEFAULT CHILDREN: 0
NORMAL READ-ONLY LUNA LEAVES: 0..4
NORMAL TOTAL CHILDREN: 5 INCLUDING AT MOST ONE TERRA/OX WRITER
GRAPH-GATED READ-ONLY BURST CEILING: 16
HISTORICAL SOL MODE LABELS: FIXTURE PROVENANCE ONLY
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
is never child-eligible. MAEOS starts with zero children; 0–4 normal Luna / Max leaves
are read-only, while a graph-gated read-only burst may reach sixteen. Terra / High is
the native non-Ox writer/integration lane. Fresh read-only Sol / High review is
risk-triggered. Ox / High is implementation-only when its exact gate passes; otherwise
the selector chooses Terra before dispatch. Depth is one; recursion, background
continuation, and automatic fallback are disabled. A8 is locked safety/history only.
DeepSeek is disabled. A second writer requires proven isolation and no target may have
more than one writer.

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

