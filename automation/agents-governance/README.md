# AGENTS Governance Automation

These scripts implement `AGENTS-CONSOLIDATION-001` and the active
`AGENTS-CONSOLIDATION-002` synchronization hardening.

## Safety defaults

- `sync-agents.ps1` is dry-run unless `-Apply` is supplied.
- Only registered eligible paths are considered.
- Registered worktree groups discover immediate child Git roots deterministically;
  non-Git children are ignored and preserved, and failed Git identity is `BLOCKED`.
- Candidate worktrees require `-IncludeCandidateTargets`.
- Blocked, historical, worktree-derived, stale, backup/test, and third-party paths are never synchronized.
- Unexpected replica or extension pre-change hashes stop the operation.
- Eligible non-Git replica and extension files receive timestamped, hash-verified backups when they already exist.
- Every `backup_required` target, including registered project/worktree roots, receives
  a timestamped, hash-verified backup before noncanonical bytes are replaced.
- Synchronization copies both the canonical root policy and the target's registered project-extension source.
- `verify-agents.ps1` independently hashes both root and extension and reports `MATCH`, `DRIFT`, `MISSING`, `SOURCE_MISSING`, or `BLOCKED`.
- `-FailOnBlocked` is reserved for the final all-required-target completion gate.

## Bounded inventory

The inventory command scans only `D:\Documents\Codex` plus the default Codex root
registered in `AGENTS_REGISTRY.json`. It emits one required classification and SHA-256
for every exact `AGENTS.md`; unknown targets fail closed.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File automation\agents-governance\inventory-agents.ps1 `
  -Phase PRECHANGE
```

Use `-Phase POSTCHANGE` after synchronization. Generated JSON and CSV evidence live
under `governance\agents\inventory\`.

## Future worktree inheritance

Add an owned worktree parent only through `managed_worktree_groups` in the canonical
registry. The group identifies its exact parent, project extension source, rollback
root, and required state. New immediate child Git roots then appear automatically in
dry-run and verification as `MATCH`, `DRIFT`, `MISSING`, or `BLOCKED`; apply remains
explicit and idempotent. Do not register a broad mixed vendor/package root.

## Candidate verification

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File automation\agents-governance\sync-agents.ps1 `
  -IncludeCandidateTargets

powershell -NoProfile -ExecutionPolicy Bypass `
  -File automation\agents-governance\verify-agents.ps1 `
  -IncludeCandidateTargets
```

Review dry-run output before applying any candidate change.

## Live activation

Live activation requires every target's registry gate to be changed through accepted authority. Do not bypass a blocked registry entry from the command line.
