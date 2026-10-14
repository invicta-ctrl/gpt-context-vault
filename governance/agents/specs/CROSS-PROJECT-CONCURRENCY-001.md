---
schema_version: 1
spec_id: CROSS-PROJECT-CONCURRENCY-001
status: accepted
owner_approved_date: 2026-10-14
scope: account-wide-agent-governance
risk: medium
---

# CROSS-PROJECT-CONCURRENCY-001 — Independent Project Writers

## Owner acceptance
On 2026-10-14 the owner explicitly directed adoption, repository update and immediate commit. The owner separately authorized temporary policy-only PR branches despite the Logistics Hub normal one-slice branch budget. This amendment changes scheduling and project ownership, not the model execution or production authorization gates.

## Objective and contract
Permit up to **two independently authorized agent writers account-wide**, but only **one active writer per authoritative project**. Codex and Claude may implement concurrently in unrelated projects; they must serialize implementation inside the same project.

Project identity follows the authoritative product/initiative, not folder, process, Git branch, repository mirror, clone, module, or worktree. Multiple repositories/worktrees forming the same product count as one project. All writes to source, configuration, tests, specs, migrations, release evidence and deployment controls count as project writes.

Before writing, each agent confirms the authoritative project, accepted task/scope, repository root/branch/HEAD/upstream/dirty state, active project writer/lock and dependencies. A second writer on the same project waits for a verified handoff and lock yield, even if files do not overlap. Concurrent read-only reviews, UX research and planning remain permitted.

Distinct projects may have concurrent writers only after checking they do not share mutable files, pointers, artifacts, credentials/secrets, databases, provider resources, migrations, CI release switches or unmerged dependencies. If shared resources exist, serialize the affected operations and record ownership. This policy does not authorize two agents to bypass an individual project's stricter single-worktree/single-slice rule.

## Preserved constraints
- Maximum two active writers account-wide, maximum one per project; a writer does not gain permission simply from different repository/worktree paths.
- Existing manual-start Codex execution lock, usage/billing-reset controls, explicit approvals, native routing, delegation limits, privacy and credentials restrictions remain unchanged.
- No unattended AI starts, automatic fallback/substitution, provider writes, production changes, merges, migrations, deployments or quota redemptions gain automatic authorization.
- Specifications, verification, CI, branch protections, rollback and acceptance gates still govern.
- Logistics Hub retains one writable shared worktree, one active implementation slice and its existing writer lock. V1.16 stays OPEN/NO-GO until independently qualified.

## Integration exception
For adoption only, the owner authorized one temporary documentation/policy PR branch per affected repository, starting from its verified remote `main`, without disturbing the active Logistics Hub V1.16 slice or Context Vault's dirty, unpublished checkout. This exception permits policy publication, not parallel Logistics Hub product implementation. Preserve existing local changes and reconcile them before later synchronization. Never force/reset/clean/delete them.

## Verification and stop gates
1. Inspect the full policy-only diff; confirm zero application/runtime/schema/model/provider change and no personal data.
2. Check cases: independent Project A + Project B = allowed when independently authorized and isolated; two writers anywhere in one project = denied; shared mutable resources across projects = serialize; read-only reviewers = allowed.
3. Confirm existing writer ceilings and execution locks are still present and unchanged.
4. Record exact branch/commit/PR and CI results. Merge only after required checks and no active-writer or source conflict; independently verify merged remote `main`.
5. Registered managed-AGENTS replica sync is a separate guarded operation: dry-run, inspect drift, apply only eligible backed-up targets, verify hashes. Do not claim local synchronization from a GitHub commit.

Stop on conflicting writer, unknown or divergent source, failed verification, blocked branch protection, or unexpected local changes. This amendment does not itself start either agent.
