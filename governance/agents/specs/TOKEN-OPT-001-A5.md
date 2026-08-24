---
schema_version: 1
spec_id: TOKEN-OPT-001-A5
parent_spec: TOKEN-OPT-001-A4
title: Remaining Material Risk Closure
status: accepted
owner: Earl
accepted_date: 2026-08-25
timezone: Asia/Manila
risk: high
execution_plane: Local machine through Codex
classification: post-publication-governance-reconciliation
compatible_with:
  - TOKEN-OPT-001
  - TOKEN-OPT-001-A1
  - TOKEN-OPT-001-A2
  - TOKEN-OPT-001-A3
  - TOKEN-OPT-001-A4
---

# TOKEN-OPT-001-A5
## Remaining Material Risk Closure

## Acceptance record

Earl explicitly accepted the completed TOKEN-OPT-001-A4 implementation and
publication receipts on 2026-08-25 (Asia/Manila), then authorized the smallest
accepted amendment necessary to reconcile the material risks recorded by A4 and
the immediately following independent verification.

This amendment permits only the bounded personal/router/LeanCTX and
registered-governance writes defined below, each with backup and rollback
evidence. It does not authorize unrelated product features, deployments,
migrations, destructive cleanup, force pushes, protected-main merges,
credentials, provider purchases, or deletion of historical worktrees or
artifacts.

## Objective

Close the known A4 reconciliation risks while preserving the A4 routing profile,
A2/A3/A4 hashes, canonical general-policy authority, project-specific
extensions, active-writer safety, and immutable historical evidence.

## In scope

### Exact LeanCTX generated drift

- Extend the existing AGENTS-governance tooling to recognize only the exact
  canonical root bytes followed by the registered marker-delimited LeanCTX
  suffix for the `global-codex` target.
- Require the observed registered hash and exact suffix bytes; reject arbitrary
  suffixes, prefix changes, duplicate markers, altered marker content, and all
  other unknown hashes.
- Classify the state precisely in verification, require a timestamped
  hash-verified backup before explicit apply, and restore the canonical bytes
  only through the existing sync path.
- Preserve the observed A4 post-publication backup and record it in the
  registry/evidence.
- Preserve `rules_injection = "off"` and `[setup] auto_inject_rules = false`.
  Back up and extend `C:\Users\adria\.codex\LEAN-CTX.md` with the concise rule
  that Context Vault owns managed AGENTS replicas and `lean-ctx rules sync`
  must not target Codex/Claude shared governance.

### Registered-worktree discovery and safety gates

- Use an explicit authoritative Git anchor root for every registered worktree
  group and `git worktree list --porcelain` to determine live worktrees.
- Add anchors for HAU-USC Logistics and Astral Bridge. Preserve unavailable
  discovery roots as blocked.
- Exclude, preserve, and classify the six listed HAU immediate-child stale
  `.git` marker directories as retired/unregistered worktree artifacts; they
  are never synchronization targets.
- Treat explicit `ACTIVE_WRITER` as authoritative. A terminal CLOSED/COMPLETE
  legacy pointer without that field is no-writer; a nonterminal/ACTIVE pointer
  without it remains blocked.
- Permit managed AGENTS/project-policy changes and preserved `.ai-bridge/`
  residue only; block unrelated dirty source/config work.

### Odysseus and preserved evidence classifications

- Inspect only the exact Odysseus governance loader/config required to establish
  whether the separate `.agents\PROJECT_POLICY.md` is deterministically loaded.
  If it is safe, writer-free, bounded, and synthetically testable, activate and
  synchronize the registered target after backups; otherwise retain its gate
  with exact evidence.
- Classify the two listed immutable verification AGENTS copies explicitly and
  never synchronize or modify them.
- Reclassify the unavailable preserved appendix as a historical/unavailable
  reference while retaining its recorded hash and provenance. Do not recreate
  it from inference.

### Router hardening

- Before supported router repair commands, create
  `C:\Users\adria\.codex\backups\TOKEN-OPT-001-A5-<timestamp>` and record
  source/backup paths, byte counts, SHA-256 values, and excluded
  credential-bearing material without copying or printing credentials.
- Run only supported router install/fix commands needed to correct the doctor
  failures. Revalidate the A4 routing profile and restore it from a verified
  backup only if an installer changed it incompatibly.
- Final required router gates are `Codex config privacy: OK`, `Codex skill pack:
  OK`, and routing-profile/personal-validator PASS. Optional-provider warnings
  remain informational.

## Required tests and evidence

Run JSON and PowerShell parse checks; unchanged A4 routing/base/A1/personal
validator checks; existing bootstrap tests; focused A5 governance regressions
for exact generated drift, authoritative worktree inclusion, stale-marker
exclusion, legacy terminal pointer handling, active-pointer block, and unrelated
dirty-work block; dry-run/apply/post-verify synchronization; inventory proof that
the two classified verification artifacts are not unknown; LeanCTX
configuration/status/doctor checks; and router doctor before/after checks.

Persist compact, redacted evidence under
`governance/agents/evidence/TOKEN_OPT_A5_2026-08-25/`, including authority and
baseline, personal backup manifests, classifications, synchronization receipts,
test results, router results, publication receipts, genuine remaining risks, and
`STOP`.

## Delivery and stop conditions

Create one coherent implementation commit and a closure/evidence commit only if
repository convention requires it, then normally push
`governance/agents-consolidation-002`. Verify local, upstream, and remote
identity plus a clean worktree. Do not force-push, merge main, rewrite history,
reset, clean, stash, delete retired worktrees, modify credentials, or mutate
protected active targets.

Stop the affected target for a missing authority, unknown unsafe drift, active
writer, unrelated dirty work, unsafe loader condition, backup failure, or failed
verification. A genuinely active target remains a protected safety control, not
an unresolved managed-replica drift.
