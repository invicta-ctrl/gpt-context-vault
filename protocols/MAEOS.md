---
schema_version: 1
status: active
standard_id: MAEOS-v1
accepted_date: 2026-09-01
---

# MAEOS v1 — Multi-Agent Engineering Orchestration Standard

MAEOS is the Context Vault's account-wide engineering-orchestration integration layer. Authority remains: Earl's current instruction, accepted project specification, authoritative repository and project policy, canonical Context Vault, MAEOS support assets, then third-party material. TOKEN-OPT-001 remains the sole token/context-efficiency authority.

## Preserved safety boundary

Execution is locked and manual-owner-started only. Sol High remains the root orchestrator; the route compiler is non-dispatching; no automatic fallback, unattended/background continuation, recursive child spawning, or model-catalog patch is permitted. One writer is allowed per repository/worktree; a second account-wide writer requires the existing proven-isolation contract. Stop when green.

## Operating topology

- DEFAULT_CHILDREN: 0. Delegate only when benefit exceeds coordination cost.
- Normal read-only envelope: 0–4 workers; normal total children: at most five including at most one writer.
- Larger read-only bursts: at most the verified native ceiling of 16, only with a finite root-authored task graph and independent nodes.
- Depth: 1. Children never spawn or coordinate new children.
- Review: risk-triggered. This cross-cutting MAEOS change requires an independent fresh Sol review.

Semantic roles are runtime-mapped: `ROOT_ORCHESTRATOR`, `FAST_LEAF`, `READER`, `DOCS_RESEARCH`, `PLANNER`, `ENGINEER`, `WRITER`, `TESTER`, `REVIEWER`, and `BRANCH_COORDINATOR`. Current mappings preserve Sol/High root, Luna/Max read-only leaf only, Terra/High for every native non-Ox implementation, write, and integration task, and the fail-closed Ox implementation overlay. Spark is `REFERENCE_ONLY/SKIPPED` unless the installed client explicitly exposes its supported profile; MAEOS never patches a catalog to create it.

## Upstream adoption

ArcanEdge and augiefra are MIT-licensed advisory sources pinned in `vendor/maeos/UPSTREAM_MANIFEST.json`. MAEOS curates their task-graph, context-isolation, worktree lifecycle, coordination, reference-routing, review, config-merge, runtime-truth, and completion-guard mechanics. It rejects ArcanEdge's mandatory child and depth-two model, and augiefra's recursive Terra leaves and automatic Spark-to-Luna fallback. Their global instruction blocks and installers are not installed because the Context Vault is the sole global authority.

## Reversal

Revert the bounded Context Vault commit through normal Git history. Restore only manifest-listed local files from the timestamped backup, and remove a MAEOS-managed new file only when its current SHA-256 equals the manifest's installed hash. Preserve later user customizations and unrelated settings.
