---
title: AGENTS Consolidation Report
status: complete-local-activation
spec_id: AGENTS-CONSOLIDATION-002
updated: 2026-08-21
---

# AGENTS Consolidation Report

## Result

The requested local governance activation is verification-green.

- The Context Vault root remains the sole editable general-policy master.
- Global Codex, active Astral Bridge, active HAU-USC Logistics, 37 registered HAU
  worktrees, and two registered Astral worktrees are byte-identical to the canonical
  root.
- Every eligible root has its registered project extension; Global Codex activation is
  also `MATCH`.
- The Odysseus target remains `BLOCKED_EXTENSION_LOADER`, is conditional, is outside the
  requested `D:\Documents\Codex` inventory scope, and was not modified.
- The two HAU archival/evidence roots were preserved unchanged.
- No application build, browser suite, deployment, migration, database/provider,
  Production, credential, model/provider, or external-system action ran.

## Canonical and inventory evidence

```text
Context Vault baseline HEAD: fe69dc2191deac683d09eebaee56ff922f870e7a
Context Vault baseline branch: main
Baseline upstream divergence: 0 ahead / 0 behind
Canonical pre-change SHA-256: ab378cb86ca0b6d6064b1e6e64a3da145f44ca1e3d7afdc7312ca6db09acf92d
Canonical active SHA-256: 83e75b3899b38b8aef61ea35961744e97e48b3271c12c9d3c4e582e753f6589f
Pre-change exact AGENTS.md count: 45
Eligible managed/worktree targets: 42
Post-change requested managed matches: 42
New timestamped root-policy backups: 42
Backup/pre-change SHA-256 multiset equality: PASS
Post-change unknown classifications: 0
```

The pre/post JSON and CSV inventories under `governance/agents/inventory/` contain the
exact path, classification, length, SHA-256, target ID, and canonical-match result.

## Preservation

Backup timestamp: `20260820T173802Z` (UTC).

```text
C:\Users\adria\.codex\backups\agents-consolidation-002\20260820T173802Z
D:\Documents\Codex\HAU-USC Logistics\backups\agents-consolidation-002\20260820T173802Z
D:\Documents\Codex\backups\agents-consolidation-002\20260820T173802Z
D:\Documents\Codex\backups\agents-consolidation-002\astral-bridge-worktrees\20260820T173802Z
```

The default Codex backup SHA-256 is
`667edea5b9e4f73dc29308c682f424f82bf3d83040233de9e8e2b4ff9feabc3e`.
The remaining exact backup hashes are present in the post-change inventory.

The unique v0.7.3 frontend worktree instruction was extracted before synchronization
to `.agents/WORKTREE_POLICY_APPENDIX.md` with SHA-256
`b524237fe7c140d1cc98c1b38af8cfdfd515507f5bab47aeb3f2db9f4c31741b`.
Its complete original root bytes are also preserved by the backup with SHA-256
`ca53d79b4d6a3fd07912f087eac26e9b8a9fb52cc88914f7224ae2caef10b150`
and by Git history.

Unrelated pre-existing HAU work remained untouched:

```text
M docs/SECURITY_AND_ACCESS.md
?? .ai-bridge/
?? docs/reference/SECURITY_AUDIT_CONSOLIDATED_RECOMMENDATIONS_2026-08-18.md
```

## TOKEN-OPT and HAU reconciliation

The approved optional-step parking heuristic appears once in TOKEN-OPT-001. Base
fixture version 1 remains exactly ten fixtures with canonical serialized SHA-256
`eb5314d707734395ebf2a23b9294cda6855a2dfbeacf6e4645fba1de5513ba58`.
The A1 suite remains 26 unique fixtures.

HAU keeps its read-only Sol orchestrator, one Terra Integration Writer when a child
writer is required, conditional read-only Luna review, writer lock, recovery branches,
Playground/Production release gates, rollback, environment isolation, privacy, and data
invariants. Routine defaults are now zero children, one active child maximum, depth one,
High-or-lower reasoning, no routine independent review, no routine full-suite loop, and
stop when green. Project threads changed from 32 to 2; the two routine Luna profiles
changed from MAX to High.

Historical accepted specifications with exact operation-specific concurrency remain
historical or operation-scoped authority and were not rewritten.

## Tooling hardening

The existing `automation/agents-governance/` framework now:

- discovers immediate child Git roots only under exact registered worktree parents;
- treats immediate-child Git roots under exact registered worktree parents as managed targets and preserves unknown/non-Git children;
- dry-runs by default and applies only with `-Apply`;
- backs up every `backup_required` target before replacement;
- reports `MATCH`, `DRIFT`, `MISSING`, or `BLOCKED`;
- produces bounded pre/post inventory evidence;
- detects new eligible registered worktrees; and
- is idempotent (the post-apply dry run reported only `MATCH` for all eligible targets).

## Verification

```text
verify-agents.ps1 -FailOnBlocked: PASS for all 42 requested eligible targets
sync-agents.ps1 post-apply dry run: PASS / all eligible MATCH
verify-token-optimization.ps1: PASS
TOKEN-OPT base fixtures: 10/10 PASS and canonical fixture hash unchanged
TOKEN-OPT A1 fixtures: 26/26 PASS
Global Codex model: gpt-5.6-sol PASS
Global ordinary reasoning: high PASS
Global concurrent-thread maximum: PASS
Sol Advisor model/reasoning: gpt-5.6-sol / high PASS
HAU npm run check:agents: PASS (12 project files)
HAU targeted codex-governance tests: 14/14 PASS
PowerShell parser for governance scripts/modules: PASS
Registry JSON parse: PASS
```

Application builds, browser/E2E suites, deployment checks, migrations, and Production
checks were intentionally not run.

## Git closeout

```text
Context Vault branch: governance/agents-consolidation-002
Context Vault implementation commit: 602fb0eb43da470dcdc78a63347ea241380e5831
HAU active governance branch: governance/agents-main-sync
HAU active governance commit: b96c44bbf5b1a60d8e3154f47c7b6b2ced5ad2dc
Astral Bridge branch: governance/agents-consolidation-002
Astral Bridge governance commit: a93b1b571d829ee63d0382eba62363c30fcb3eba
HAU v0.7.3 preserved-appendix commit: c20bfd1cd78b87a5489415af1b316e3ffc70280b
Pushes: NONE
Pull requests: NONE
Merges: NONE
```

The remaining HAU/Astral worktree replicas are generated local operating copies. They
remain visibly modified/untracked on their existing branches rather than rewriting
dozens of historical or in-progress branch histories. Their exact pre-change bytes are
backed up, their live bytes verify `MATCH`, and the deterministic command can recreate
them. This is intentional preservation, not unreported clean state.

The complete logical diffs were reviewed, targeted files were staged explicitly, and
unrelated HAU work was not staged. No remote action is assumed or reported. The
accepted local activation work unit is complete; stop before push, PR, merge, cleanup,
Odysseus work, or another audit pass.


## A1 remote publication completion - 2026-08-21

The owner explicitly reopened the completed local activation to publish the governance repository-wide. AGENTS-CONSOLIDATION-002-A1 records that authority.

The default Codex managed root drifted again only by the known lean-ctx injected footer. The footer already exists in the registered global project extension and LEAN-CTX guidance, so the managed root was backed up at C:/Users/adria/.codex/backups/agents-consolidation-002/20260821T003744Z/AGENTS.md and restored byte-for-byte to the canonical Context Vault root. lean-ctx automatic root injection remains disabled.

Registered worktree discovery now uses the presence of the .git marker inside already registered immediate-child worktree roots instead of shell-specific Git executable discovery. This removes false BLOCKED results while keeping discovery bounded to explicit owned parent directories.

Remote publication results:

- Context Vault main and governance/agents-consolidation-002: canonical AGENTS present.
- Astral Bridge main plus all three governance branches: canonical AGENTS and registered Astral project extension present.
- HAU-USC main: governance commit a2d205c3dbe93e56bf448fca14304351ee54b068 applies the universal root, HAU project extension, TOKEN-OPT-aligned usage policy, High Luna profiles, two-thread project cap, and coupled governance validators to parent 7d826f2683fbca8058ff08e8ae40acc1e095c076 without changing application/runtime files.
- HAU-USC governance/agents-main-sync: b96c44bbf5b1a60d8e3154f47c7b6b2ced5ad2dc published.
- Every other non-recovery HAU-USC remote branch observed at final verification carries the canonical root and HAU project extension.
- backup/last-known-good and regression/r1 through regression/r3 remain intentionally unchanged because moving those pointers would destroy their exact verified recovery-state meaning. Their older AGENTS content is preserved historical state, not active synchronization drift.
- A release/v0.8.4-live-operations-performance branch appeared during execution; it was fetched, audited, synchronized by a fast-forward governance-only descendant commit, and reverified.

Final deterministic evidence:

- Active local AGENTS inventory under D:/Documents/Codex plus the default Codex root: 85 of 85 current/non-historical files match canonical SHA-256 83e75b3899b38b8aef61ea35961744e97e48b3271c12c9d3c4e582e753f6589f.
- verify-agents.ps1 -IncludeCandidateTargets: PASS for every eligible target; Odysseus remains the pre-existing out-of-scope conditional block.
- verify-token-optimization.ps1: PASS, base fixtures 10/10, A1 fixtures 26/26, personal defaults PASS.
- HAU agent instruction check: PASS for 12 project files.
- HAU focused codex-governance Vitest: 14/14 PASS on the reviewed governance branch.
- HAU remote final audit: 15 active/non-recovery branches MATCH; 4 recovery pointers intentionally PRESERVED; 0 actionable stale branches.
- Astral remote final audit: 4/4 branches MATCH.
- Context Vault remote audit before this closure entry: main and governance branch MATCH.

No application build, browser/E2E suite, migration, deployment, database/provider write, Production change, recovery-pointer rotation, branch deletion, force-push, reset, or unrelated dirty-work mutation was performed. The pre-existing HAU security-document dirty work remained preserved.
