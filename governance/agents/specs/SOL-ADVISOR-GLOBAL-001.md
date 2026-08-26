---
schema_version: 1
status: accepted
amendment_id: SOL-ADVISOR-GLOBAL-001
accepted_date: 2026-08-26
owner: Earl
upstream_sol_advisor_version: 0.6.0
upstream_main_sha: 37b75cad535abdd46531f0227483a8842d045ab8
---

# SOL-ADVISOR-GLOBAL-001 — Global Sol Advisor with temporary Ox overlay

## Supersession and preserved boundaries

This amendment supersedes prior routing, delegation, reviewer-selection, and model-pin clauses only where they conflict. Historical A1–A8 specifications and fixtures remain immutable provenance. Product scope, writer locks, security, privacy, secrets, migrations, Production, backups, rollback, evidence preservation, and unknown-work rules remain unchanged.

## Canonical software orchestration contract

- Installed upstream Sol Advisor 0.6.0 is the account-wide default for eligible owned software work. Primary Sol is `gpt-5.6-sol` / `high`.
- Sol declares `SELECTIVE ROUTE` with exactly `solo`, `delegate`, `audit`, or `full` before task tools. Solo is default; one auxiliary is normal; full is the explicit broad/high-risk exception; depth is one; recursive spawning is forbidden.
- Sol owns architecture, routing, worker specification, verification, escalation, and acceptance. Luna / `max` handles bounded specified implementation; Terra / `high` handles judgment-heavy, high-risk, context-heavy, or wide-blast-radius implementation; fresh read-only Sol / `high` reviews audit/full with `ship|fix-first|rethink`.
- Ox is a temporary implementation-only overlay, never a fifth route, primary architect, final reviewer, recursive spawner, or independent executor for Production, migration, destructive, secret, or external-state work. It requires exact callable `openrouter/stealth/ox-alpha` / `high`, verified zero input/output pricing without ambiguity, acceptable health, capability, and data suitability. Failure is `OX_OVERLAY_DISABLED`.
- In an already owner-started interactive Sol task, the deterministic selector/validator may return Luna or Terra when Ox is disabled. That is not provider automatic fallback, dispatch, silent substitution, background continuation, recursive spawning, or independent retry.
- The selector never dispatches; the manual owner-started gate remains locked by default; `real_codex_calls=0` tests remain required. At most two isolated writers account-wide and one writer per repository/worktree are permitted.

## Adoption

Mutable project extensions and future templates inherit this contract but may tighten product and safety constraints. An active task with a valid no-subagent restriction resolves to solo; it does not replace this contract.
