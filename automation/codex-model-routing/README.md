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
- [`../../governance/agents/specs/TOKEN-OPT-001-A4.md`](../../governance/agents/specs/TOKEN-OPT-001-A4.md)
  defines the accepted account-wide current routing, context-envelope, receipt, benchmark,
  and managed-AGENTS baseline.
- [`current-routing-profile.json`](current-routing-profile.json) is the replaceable live
  role profile. [`route-compiler.ps1`](route-compiler.ps1) validates its catalog,
  context, concurrency, fallback, receipt, and telemetry contracts.
- `contracts/` contains the shared read-only Luna/Ox contract and bounded Terra writer
  contract; `verification-receipts.ps1` and `report-seven-day-benchmark.ps1` provide
  redacted evidence reuse and observed-only seven-day reporting.
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

The A4 current slice defaults to one Terra writer plus two read-only workers and may
adapt to two-to-four read-only workers, with at most six total active workers. The A1
Current/Next Slice Pipeline still permits only one read-only scout for an already
authorized next slice; it is a specialized non-delegating lane, not A4's total
current-slice capacity. The parent revalidates the scout packet against the current
slice's ending SHA and never auto-starts the next slice.

## Capability compatibility

Projects must verify the installed Codex version and supported model,
reasoning, hook, agent, sandbox, and `codex exec` behavior before enabling
automation. Logical route tiers are portable; model identifiers are not. A
project must reject unsupported identifiers instead of silently substituting a
more expensive or less safe model.

## Deterministic A4 commands

Use a project-local, redacted run-state and telemetry path; do not store live prompts,
credentials, or raw external state in this vault.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File automation\codex-model-routing\route-compiler.ps1 `
  -RequestPath <redacted-request.json> -StatePath <project-run-state.json> `
  -TelemetryPath <project-telemetry.jsonl>

powershell -NoProfile -ExecutionPolicy Bypass -File automation\codex-model-routing\verification-receipts.ps1 `
  -Action Check -ReceiptPath <receipt.json> -SourceFingerprint <sha256> `
  -ConfigurationFingerprint <sha256> -TestFingerprint <sha256> `
  -DependencyFingerprint <sha256> -ExternalStateFingerprint <sha256>

powershell -NoProfile -ExecutionPolicy Bypass -File automation\codex-model-routing\report-seven-day-benchmark.ps1 `
  -TelemetryPath <project-telemetry.jsonl> -OutputPath <observed-report.json> -Days 7
```

Ox routes only with an observed eligible provider, exactly-zero prompt and completion
prices, acceptable health, and a suitable data class. A failed Ox run becomes ineligible
for that run and falls back once to Luna. It is safe to leave Ox disabled.

