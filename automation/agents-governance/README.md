# AGENTS Governance Automation

These scripts implement `AGENTS-CONSOLIDATION-001`.

## Safety defaults

- `sync-agents.ps1` is dry-run unless `-Apply` is supplied.
- Only registered eligible paths are considered.
- Candidate worktrees require `-IncludeCandidateTargets`.
- Blocked, historical, worktree-derived, stale, backup/test, and third-party paths are never synchronized.
- Unexpected replica or extension pre-change hashes stop the operation.
- Eligible non-Git replica and extension files receive timestamped, hash-verified backups when they already exist.
- Synchronization copies both the canonical root policy and the target's registered project-extension source.
- `verify-agents.ps1` independently hashes both root and extension and reports `MATCH`, `DRIFT`, `MISSING`, `SOURCE_MISSING`, or `BLOCKED`.
- `-FailOnBlocked` is reserved for the final all-required-target completion gate.

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
