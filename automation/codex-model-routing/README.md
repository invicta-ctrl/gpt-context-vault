---
schema_version: 1
status: active
scope: account-wide
last_reviewed: 2026-08-25
---

# Codex model routing

This directory contains the reusable account-wide standard for turning natural
instructions into safe, repository-grounded Codex work. It is governance and
templates, not a project runtime directory.

## Current routing contract

`MAEOS-v1` defines profitable task-dependent delegation: zero children is the default,
0–4 readers are normal, and finite task graphs justify larger read-only bursts through
the native ceiling of sixteen. Sol / High remains root; Luna / Max is read-only only,
Terra / High is the native non-Ox writer/integration lane, and Ox is implementation-only
and fail-closed. A8 and
SOL-ADVISOR-GLOBAL-001 remain locked safety/history provenance.

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
  preserves the historical role catalog, context envelope, receipts, and benchmark baseline.
- [`../../governance/agents/specs/SOL-ADVISOR-GLOBAL-001.md`](../../governance/agents/specs/SOL-ADVISOR-GLOBAL-001.md)
  is immutable historical routing provenance; MAEOS-v1 is the active contract.
- [`../../governance/agents/specs/TOKEN-OPT-001-A8.md`](../../governance/agents/specs/TOKEN-OPT-001-A8.md)
  is locked safety/history provenance for the manual billable-execution guard; A7 remains
  immutable historical evidence.
- [`manual-codex-execution-gate.json`](manual-codex-execution-gate.json) and
  [`../codex-usage-guard/`](../codex-usage-guard/) implement the deterministic route gate
  and local process guard.
- [`current-routing-profile.json`](current-routing-profile.json) is the active
  `MAEOS-v1` selection profile; its SOL-ADVISOR-GLOBAL-001 fields are historical compatibility only. [`route-compiler.ps1`](route-compiler.ps1) validates context,
  receipts, the exact manual permit, role topology, writer locks, and route identity; it
  never starts Codex. Routing metadata never authorizes execution.
- `contracts/` contains the shared read-only contract and bounded Ox/Terra writer
  contracts; `verification-receipts.ps1` and `report-seven-day-benchmark.ps1` provide
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

Historical `SOL-ADVISOR-GLOBAL-001` fixtures use declared `solo`, `delegate`, `audit`, or `full`
routes. Their solo/one-auxiliary convention is not an active default: MAEOS-v1 makes Luna / Max
read-only only, Terra / High the native writer/integration lane, and fresh
Sol / High review is risk-triggered. A8 remains locked safety/history only; its numeric
caps preserve guard compatibility, not active staffing. No recursive spawning,
unattended/background continuation, or automatic fallback is allowed. Historical A4/A6
fixture data remains deterministic evidence, not reusable spending authority.

## Capability compatibility

Static catalog and configuration validation may run while locked. A real model probe,
`codex exec`, task creation, task continuation, subagent, retry, or fallback is billable
execution and requires a new exact manual permit. ChatGPT Web, Astral Bridge, and
automation must stop and ask Earl rather than performing that probe themselves.
Unsupported identifiers are rejected; silent substitution is prohibited.

## Deterministic current routing checks

Use a project-local, redacted run-state and telemetry path; do not store live prompts,
credentials, or raw external state in this vault.

```powershell
& "$env:USERPROFILE\.codex\usage-guard\Get-CodexUsageStatus.ps1"

powershell -NoProfile -ExecutionPolicy Bypass -File automation\codex-model-routing\route-compiler.ps1 `
  -ExecutionGatePath automation\codex-model-routing\manual-codex-execution-gate.json `
  -ManualPermitPath "$env:USERPROFILE\.codex\usage-guard\permit.json" `
  -RequestPath <redacted-manually-approved-request.json> -StatePath <project-run-state.json> `
  -TelemetryPath <project-telemetry.jsonl>

powershell -NoProfile -ExecutionPolicy Bypass -File automation\codex-model-routing\verification-receipts.ps1 `
  -Action Check -ReceiptPath <receipt.json> -SourceFingerprint <sha256> `
  -ConfigurationFingerprint <sha256> -TestFingerprint <sha256> `
  -DependencyFingerprint <sha256> -ExternalStateFingerprint <sha256>

powershell -NoProfile -ExecutionPolicy Bypass -File automation\codex-model-routing\report-seven-day-benchmark.ps1 `
  -TelemetryPath <project-telemetry.jsonl> -OutputPath <observed-report.json> -Days 7
```

Active Ox implementation selection requires current exact runtime identity, callable
provider availability, exact zero input/output price, unambiguous billing, acceptable
health, required capabilities, suitable data, and an exact permit. Ineligibility resolves
before dispatch without retry or automatic fallback: Luna / Max only for read-only work,
or Terra / High for every native non-Ox write, implementation, and integration task. A8 is locked safety/history only; it does not select a model, effort,
reviewer, or staffing topology.

