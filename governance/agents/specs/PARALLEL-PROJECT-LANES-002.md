---
schema_version: 1
spec_id: PARALLEL-PROJECT-LANES-002
status: accepted
accepted_date: 2026-10-14
scope: account-wide-governance
supersedes_in_part: CROSS-PROJECT-CONCURRENCY-001
risk: high
---

# PARALLEL-PROJECT-LANES-002 — Safe Concurrent Writers Inside One Project

## Owner decision and precedence

On 2026-10-14 the owner explicitly approved Codex and Claude **simultaneously implementing separate frontend and backend tasks in Logistics Hub** using distinct writable Git worktrees, explicit ownership of files and responsibilities, one integration authority, and all existing verification and deployment safeguards.

This amendment replaces only the prior blanket prohibition on two writers in one authoritative project in `CROSS-PROJECT-CONCURRENCY-001`. That earlier accepted record remains immutable history. The default for any project without a specifically accepted, enforced two-lane arrangement remains one writer. Never infer permission from merely having different branches, folders, or processes.

## Global limits and eligibility

- **At most two active implementation writers account-wide; at most two in a project with an accepted parallel-lanes plan.** Any third writer must be read-only or await a handoff; subagent count is not writer permission.
- Different projects still require proven isolation of shared mutable state. Same-project concurrency is permitted only when an accepted project amendment and live lane manifest specify two separate writable worktrees/branches, distinct exact owned paths and APIs, role/lock ownership, integration authority, and a stop protocol.
- Each active worktree has exactly one writer. No simultaneous writes to an overlapping path or shared generated artifact, schema, contract, migration, pointer, dependency, configuration, lockfile, build output or provider state. Overlap means **stop and request serial ownership transfer**, not make a best-effort merge.
- A changed shared interface/data contract needs an explicit reviewed interface handoff before either dependent implementation proceeds; do not assume frontend/backend boundaries imply dependency isolation.
- Preserve the canonical project identity, current accepted specs, Git cleanliness and upstream checks; detached read-only reviewers are not additional writers.

## Logistics Hub lane arrangement

### Existing Codex lane — backend/release

Preserve the existing shared worktree `D:\Documents\HAU-USC Logistics Hub\workspace\logistics-hub` and active `slice/v1.16-release-controls` branch. Codex alone owns its current V1.16 release/control evidence, `.codex/CURRENT.md`, `.codex/SESSION_HANDOFF.md`, provider/worker/backend, migrations and release qualification. V1.16 remains OPEN/NO-GO until verified and accepted; no release status promotion or replay.

### New Claude lane — frontend/UX

Only after accepting a **separate bounded UI implementation specification** and its file-level ownership manifest, provision one additional dedicated **writable Git worktree** on a new short-lived `slice/ui-<bounded-scope>` branch based on verified `origin/main`. Claude's worktree must not be the existing shared worktree; it must not reuse Codex's branch or a detached MausBot read-only worktree. Claude owns only the exact frontend layout, typography, illustration, interaction and corresponding scoped test files listed in that accepted manifest.

The exploratory high-fidelity visual reference is research, **not** authorization for a redesign or installation. While its implementation specification is unaccepted, Claude may research, audit and prototype read-only without claiming an implementation writer slot.

### Shared and exclusive integration authority

Reserve `AGENTS.md`, `CLAUDE.md`, `.agents/**`, `.codex/**`, `.github/**`, `ops/**`, `migrations/**`, `wrangler.jsonc`, `package*.json`, product release identity/changelog, cloud/provider settings and shared API/DTO/contracts to a **single nominated integration steward** unless a narrow approved transfer grants a named lane a specified path. The steward alone updates shared coordination/active pointers, resolves cross-lane interfaces and merges PRs, **serially**. Writers may review the other lane but must not silently edit its files.

Each lane independently claims its own worktree lock and records branch, HEAD, accepted spec, **complete allowlisted path set**, upstream, status, expected dependencies and checkpoints. Existing `scripts/agent-lock.mjs` enforces only its own worktree's local lock: it is **not** a global two-lane scheduler. Before parallel writing, the steward must positively verify both worktrees, disjoint ownership and the two account-wide writer slots; otherwise stay one-writer.

## Integration, release and stop gates

1. Each writer works on its own short-lived slice branch; no direct write/push to `main`; no cross-branch cherry-pick, rebase of a live other-writer branch, or concurrent merge.
2. Integrator examines changed-file sets against the accepted lane manifest; unexpected files, shared contracts, cross-lane dependencies or conflicting Git changes are blockers requiring deliberate serial reassignment and updated acceptance.
3. Only independently usable, accepted and fully verified changes may merge. Refresh/reconcile `main`, recheck the entire affected behavior on exact integration SHA, require existing build/typecheck/unit/browser/Worker E2E/privacy/security checks and protected branch rules. Do not make an unverified UI half-feature appear released.
4. Merge **one PR at a time**, verify actual main/CI and approved deployment/rollback evidence, then rebase/retest the other lane against the new base with its author paused, before the next PR. An unfinished V1.16 or UI lane can remain in its isolated branch without claiming release completion.
5. Cloudflare Worker/D1/R2, credential, migration, production toggle, deployment and billable model operations remain separately authorized and gated exactly as before. No direct production writes from a frontend worktree; no extra auto-deploy path. Main pushes may trigger existing Workers Builds: verify the current deployment configuration and readiness before merge.
6. If writer ownership, path disjointness, source/upstream, mutable-state isolation, lock state, authorization or required CI cannot be proven: **stop the affected writes and fall back to one writer.** Never reset, clean, force-push, delete unknown branches/files, seize a writer lock or overwrite someone else's work.

## Acceptance checks

- Positive: separate accepted UI and V1.16 tasks, distinct worktrees, branch/owner/paths, no shared writes, two writers total = permitted.
- Negative: same files, shared global CSS without assignment, shared `.codex` pointer, changed API/schema, unsynchronized deployment/DB, missing accepted UI slice, third writer, dirty/unknown state or uncertain lock = block.
- Read-only visual review during Codex work remains permitted.
- Rollback to the default single-writer arrangement by stopping and yielding one lane, preserving its checkpoint/unique commits, and confirming no unmerged source was destroyed.
- Canonical managed-AGENTS replica synchronization requires its normal gated dry-run, backup, hash and eligibility checks. Publishing this governance in GitHub does **not** imply local agents have loaded it. Stale sessions must rehydrate before writing.

This changes concurrency permission and project coordination, not product scope, deployment approval, V1.16 acceptance, or model-usage entitlements.
