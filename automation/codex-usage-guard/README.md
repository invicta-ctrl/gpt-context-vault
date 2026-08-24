# Codex Usage Guard

`TOKEN-OPT-001-A6` separates always-on Codex infrastructure from Codex model execution.

## Default state

```text
Codex app-server infrastructure: allowed
Codex model execution: locked
Automated Codex runs: 0
Background continuations: 0
Codex children/subagents: 0
Automatic fallback: disabled
Maximum processes after one manual permit: 1
```

The scheduled task `Earl Codex Usage Guard` keeps this boundary active. It permits only
`codex.exe ... app-server ...` infrastructure while the usage lock is closed. Every
other `codex.exe` process tree is terminated unless it is the single process bound to a
live manual permit.

## Check the lock

Run from PowerShell:

```powershell
& "$env:USERPROFILE\.codex\usage-guard\Get-CodexUsageStatus.ps1"
```

The normal result is `PROTECTED`, with zero billable or interactive Codex processes.

## Manually approve one Codex run

Run this yourself in Windows Terminal or an interactive PowerShell console:

```powershell
& "$env:USERPROFILE\.codex\usage-guard\Enable-CodexUsage.ps1" `
  -DurationMinutes 60 `
  -Model gpt-5.6-terra `
  -Reasoning max `
  -Role writer
```

The command requires an exact model, reasoning level, role, purpose, and random challenge. It refuses redirected input and
common automation parents. It creates a single-use permit but **does not start Codex**.
After the permit is active, manually start the one approved Codex task. The first
eligible process consumes the permit; a second process, child, retry, fallback, or later
continuation is blocked.

When the task is finished, or whenever the permit should be withdrawn, run:

```powershell
& "$env:USERPROFILE\.codex\usage-guard\Disable-CodexUsage.ps1"
```

That restores the lock and terminates every non-`app-server` Codex process while
preserving infrastructure.

Direct, deliberate work started by Earl inside Codex Desktop is a manual interaction.
The app-server remains running so the desktop application and connectors stay healthy.
Automated CLI execution, delegated workers, and background continuation remain locked.

## Verify the guard

```powershell
& "$env:USERPROFILE\.codex\usage-guard\Test-CodexUsageGuard.ps1"
```

The test never invokes the real Codex CLI. It uses a harmless copy of Windows `ping.exe`
named `codex.exe` to prove the watcher terminates non-infrastructure processes while
preserving the existing app-server process IDs.

## Rollback

Every installation creates a timestamped backup under:

```text
C:\Users\adria\.codex\backups\TOKEN-OPT-001-A6-GUARD-<timestamp>
```

The backup contains the prior scheduled-task XML, the prior local guard files, hashes,
and an install manifest. Restore only from a verified manifest. A rollback must never
restart a Codex model task automatically.

## Boundary limitation

This is a strong accidental-automation and workflow control. It is not an adversarial
security boundary against a malicious program or administrator already running as
Earl's Windows user and deliberately disabling the scheduled task or modifying its
files.
