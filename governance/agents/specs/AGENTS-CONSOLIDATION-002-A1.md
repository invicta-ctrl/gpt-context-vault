---
schema_version: 1
spec_id: AGENTS-CONSOLIDATION-002-A1
parent_spec: AGENTS-CONSOLIDATION-002
title: Local and Remote AGENTS Publication Completion
status: accepted
owner: Earl
accepted_date: 2026-08-21
timezone: Asia/Manila
risk: high
---

# AGENTS-CONSOLIDATION-002-A1

## Acceptance record

Earl explicitly instructed the agent on 2026-08-21 to audit and update all stale AGENTS.md files locally and repository-wide now. This amendment authorizes publication and completion work that the parent specification had left unpushed.

## In scope

- Re-audit the canonical Context Vault, default Codex root, registered active project roots, and registered HAU-USC/Astral worktrees.
- Repair known managed-root drift after preserving current bytes.
- Preserve historical backups, archives, frozen verification snapshots, private evidence history, and third-party material unchanged.
- Push the already-reviewed governance branches for Context Vault, Astral Bridge, and HAU-USC.
- Promote the accepted governance changes to each repository main branch when the resulting change is governance-only and current upstream identity is reverified.
- For every existing non-archived HAU-USC remote branch whose root AGENTS.md is stale, add one governance-only descendant commit that replaces AGENTS.md with the canonical master and ensures .agents/PROJECT_POLICY.md contains the registered HAU project extension. Preserve every other tree entry byte-for-byte.
- Do not force-push or rewrite history. Do not delete branches.
- Run focused governance verification once after publication.

## Exclusions

No application source change, deployment, migration, database/provider write, Production action, recovery-pointer rotation, destructive cleanup, secret change, or unrelated dirty-work mutation is authorized.

## Completion

Complete when the global Codex replica and all registered local live/worktree replicas match the canonical master; Context Vault, Astral Bridge, and HAU-USC main contain the accepted governance; every existing non-archived HAU-USC remote branch contains the canonical root policy plus HAU project extension; validators are green; and preserved historical evidence remains unchanged.
