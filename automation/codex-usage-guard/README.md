# Codex Usage Guard

`SOL-ADVISOR-GLOBAL-001` is the active routing contract: `solo|delegate|audit|full`,
with solo as the default and at most one auxiliary; Luna / Max and Terra / High are native
implementation lanes; Ox is implementation-only and fail-closed. A8 is locked
safety/history only and separates always-on Codex infrastructure from owner-started Codex
model execution.

## Default state

```text
Codex app-server infrastructure: allowed
Codex model execution: locked
Automated Codex runs: 0
Background continuations: 0
Sol subagents: prohibited
Mandatory zero-worker start: none
A8 locked-safety ceilings only (not routing defaults):
Maximum Luna Max subagents: 16
Maximum Terra Max subagents: 2
Maximum Ox Alpha subagents: 16
Maximum total direct subagents: 16
Maximum delegation depth: 1
Automatic fallback: disabled
Maximum primary processes after one manual permit: 1
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
  -Model gpt-5.6-sol `
  -Reasoning high `
  -Role orchestrator
```

The command requires an exact model, reasoning level, role, purpose, and random challenge. It refuses redirected input and
common automation parents. It creates a single-use permit but **does not start Codex**.
After the permit is active, manually start the one approved Codex task. The first
eligible primary process consumes the permit; a second primary process, recursive child,
automatic retry/fallback, or later continuation is blocked. The owner-started Sol advisor
declares `solo`, `delegate`, `audit`, or `full`: solo uses zero auxiliaries and every other
declared compiler route has one auxiliary. A8 caps remain locked safety ceilings, never
active staffing defaults. Sol is never a subagent.

The active permit includes `default_auxiliaries_max=1`,
`fresh_sol_reviewer_allowed=true`, and `max_fresh_sol_reviewers=1`. A reviewer permit is
only `gpt-5.6-sol` with `high` reasoning and represents the compiler's
`requested_sol_reviewer_auxiliaries` lane, not an implementation Sol child. The retained
Luna, Terra, Ox, and total-worker numeric caps are marked `legacy_guard_safety_caps_only`.

For deterministic routing verification, `-ContractProbe` emits the same validated permit
object without prompting, writing a permit, starting a process, or changing guard state.
It is a test-only probe, not an approval mechanism.

The guard independently enforces the same active contract at runtime and through its
test-only `-PermitContractProbe -PermitContractProbePath <temporary-json-path>` interface.
That probe reports only `Valid` and `Reason`, never authorizes execution, and rejects
legacy permits missing active fields, non-Boolean security fields, non-reviewer roles,
and reviewer model/reasoning combinations other than `gpt-5.6-sol` / `high`.

When the task is finished, or whenever the permit should be withdrawn, run:

```powershell
& "$env:USERPROFILE\.codex\usage-guard\Disable-CodexUsage.ps1"
```

That restores the lock and terminates every non-`app-server` Codex process while
preserving infrastructure.

Direct, deliberate work started by Earl inside Codex Desktop is a manual interaction.
The app-server remains running so the desktop application and connectors stay healthy.
Automated CLI execution, recursive delegation, and background continuation remain locked.

## Verify the guard

```powershell
& "$env:USERPROFILE\.codex\usage-guard\Test-CodexUsageGuard.ps1"
```

The test never invokes the real Codex CLI. It uses a harmless copy of Windows `ping.exe`
named `codex.exe` to prove the watcher terminates non-infrastructure processes while
preserving the existing app-server process IDs, and validates active reviewer, legacy,
malformed reviewer, and string-Boolean permit cases through the same contract validator.

## Rollback

Every installation creates a timestamped backup under:

```text
C:\Users\adria\.codex\backups\TOKEN-OPT-001-A8-GUARD-<timestamp>
```

The backup contains the prior scheduled-task XML, the prior local guard files, hashes,
and an install manifest. Restore only from a verified manifest. A rollback must never
restart a Codex model task automatically.

## Boundary limitation

This is a strong accidental-automation and workflow control. It is not an adversarial
security boundary against a malicious program or administrator already running as
Earl's Windows user and deliberately disabling the scheduled task or modifying its
files.
