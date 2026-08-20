---
schema_version: 1
status: active
scope: account-wide
last_reviewed: 2026-08-20
---

# Codex model routing

This directory contains the reusable account-wide standard for turning natural
instructions into safe, repository-grounded Codex work. It is governance and
templates, not a project runtime directory.

## Authority boundary

Use the following order for every routed task:

1. The user's current explicit instruction.
2. The registered project's authoritative repository.
3. Active Context Vault guidance.
4. Historical handoffs and summaries.

The project repository owns technical facts, source code, tests, commands,
architecture, status, and implementation decisions. A project adapter may copy
the standard into its own runtime, but the vault must not store live prompts,
generated briefs, route decisions, logs, diffs, secrets, or build artifacts.

The canonical account-wide token and context-efficiency policy is
[`../../protocols/CODEX_TOKEN_OPTIMIZATION_AND_CONTEXT_EFFICIENCY_RULES.md`](../../protocols/CODEX_TOKEN_OPTIMIZATION_AND_CONTEXT_EFFICIENCY_RULES.md).
It governs ordinary reasoning, delegation, evidence reuse, review, verification
escalation, and stop-when-green behavior. Project rules may be stricter but may
not weaken safety.

## Standard contents

- [`../../protocols/CODEX_TOKEN_OPTIMIZATION_AND_CONTEXT_EFFICIENCY_RULES.md`](../../protocols/CODEX_TOKEN_OPTIMIZATION_AND_CONTEXT_EFFICIENCY_RULES.md)
  is the single account-wide token/context-efficiency authority.
- [`../../governance/agents/specs/TOKEN-OPT-001-A1.md`](../../governance/agents/specs/TOKEN-OPT-001-A1.md)
  defines the accepted Current/Next Slice Pipeline and read-only scout-ahead amendment.
- [`INSTRUCTION_REFINEMENT_STANDARD.md`](INSTRUCTION_REFINEMENT_STANDARD.md)
  defines the preflight gate and safe-stop behavior.
- [`REFINED_EXECUTION_BRIEF_TEMPLATE.md`](REFINED_EXECUTION_BRIEF_TEMPLATE.md)
  is the concise brief shape.
- [`ROUTING_STANDARD.md`](ROUTING_STANDARD.md) defines model, reasoning,
  subagent, worktree, escalation, and verification decisions.
- [`ROUTING_DECISION_TEMPLATE.md`](ROUTING_DECISION_TEMPLATE.md) documents a
  reviewable decision.
- [`PROJECT_ADOPTION_CHECKLIST.md`](PROJECT_ADOPTION_CHECKLIST.md) separates
  reusable governance from project-specific implementation.
- `templates/` contains schemas and starter configuration only.

## Retrieval sequence

For a project task, read the normal vault entrypoint and project registry first,
then retrieve this standard only when refinement or routing is relevant. Read
the registered project repository for current technical facts. Stop when the
brief and route can be decided without speculative context.

When token, context, delegation, evidence reuse, review, or verification
efficiency is in scope, retrieve the canonical policy above and expand context
only for a recorded reason it permits.

The Current/Next Slice Pipeline uses zero children by default and at most one
read-only scout for an already authorized next slice. The parent revalidates the
scout packet against the current slice's ending SHA and never auto-starts the next
slice.

## Capability compatibility

Projects must verify the installed Codex version and supported model,
reasoning, hook, agent, sandbox, and `codex exec` behavior before enabling
automation. Logical route tiers are portable; model identifiers are not. A
project must reject unsupported identifiers instead of silently substituting a
more expensive or less safe model.

