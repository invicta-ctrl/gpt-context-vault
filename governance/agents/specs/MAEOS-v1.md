---
schema_version: 1
spec_id: MAEOS-v1
title: Multi-Agent Engineering Orchestration Standard v1
status: accepted
owner: Earl
accepted_date: 2026-09-01
risk: high
supersedes: [SOL-ADVISOR-GLOBAL-001 active orchestration defaults only]
---

# MAEOS-v1

MAEOS-v1 succeeds `SOL-ADVISOR-GLOBAL-001` only for active orchestration defaults. A1–A8 and SOL-ADVISOR-GLOBAL-001 remain immutable provenance; TOKEN-OPT-001 remains the efficiency authority and its manual lock, depth-one, no-recursion, no-automatic-fallback, and writer safety boundaries remain active.

MAEOS sets zero default children, 0–4 normal read-only workers, normally at most five total children including at most one writer, and finite-task-graph-only bursts through the native ceiling of sixteen. Sol/High remains root/reviewer. Luna/Max is read-only only; Terra/High is the native writer, integration, and branch-coordination lane; Ox remains a fail-closed optional writer overlay. Spark is optional and skipped unless current supported runtime evidence exists. See `protocols/MAEOS.md`, `protocols/MAEOS_TASK_GRAPH.md`, and `automation/codex-model-routing/MAEOS_ROUTING.md` for the executable contract.

Project policies may tighten this standard but may not create a competing global orchestration authority. Rollback is a normal bounded Git revert plus hash-guarded restoration of MAEOS installation backups.
