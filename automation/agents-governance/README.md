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
- An active `.codex\CURRENT.md` writer blocks synchronization and is reported as `BLOCKED` by default verification; use `-FailOnBlocked` only for a strict all-target gate.
- Eligible non-Git replica and extension files receive timestamped, hash-verified backups when they already exist.
- Every `backup_required` target, including registered project/worktree roots, receives
  a timestamped, hash-verified backup before noncanonical bytes are replaced.
- Synchronization copies both the canonical root policy and the target's registered project-extension source.
- `sync-agents.ps1 -EvidencePath <absolute-json-path>` writes a secret-free dry-run or apply receipt with actions, hashes, failures, and backup locations.
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

## Dry-run-first project bootstrap

`bootstrap-project.ps1` is the only coupled future-project bootstrap/register path.
It reads the canonical registry and canonical root policy, reports `MISSING`, `MATCH`,
or `DRIFT` without writing by default, and requires explicit `-Apply` for every write.
It never overwrites an existing `.agents/PROJECT_POLICY.md`; use
`-CreateProjectExtension` only to create the registered minimal extension source when
the extension is absent. It makes timestamped hash-verified backups before changing an
existing root or registry.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File automation\agents-governance\bootstrap-project.ps1 `
  -ProjectRoot <absolute-project-root> -ProjectId <stable-id> `
  -ExtensionSourceId minimal-project-extension-template `
  -BackupRoot <absolute-backup-root> -Register -CreateProjectExtension
```

`-Activate`, `-InstallCanonical`, `-WorktreeRoot`, and `-Apply` are separate explicit
choices under accepted authority. A new registration remains `PENDING_ACCEPTED_GATE`
unless `-Activate` is supplied. After registration, use `sync-agents.ps1` and
`verify-agents.ps1`; do not hand-edit a managed replica.

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
