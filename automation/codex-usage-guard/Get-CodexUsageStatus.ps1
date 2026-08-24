[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$GuardRoot = Join-Path $env:USERPROFILE '.codex\usage-guard'
$PermitPath = Join-Path $GuardRoot 'permit.json'
$TaskName = 'Earl Codex Usage Guard'

$permitSummary = [ordered]@{ state = 'LOCKED'; approval_id = $null; expires_at = $null; consumed = $false; process_id = $null }
if (Test-Path -LiteralPath $PermitPath -PathType Leaf) {
    try {
        $permit = Get-Content -LiteralPath $PermitPath -Raw | ConvertFrom-Json
        $permitSummary.state = [string]$permit.state
        $permitSummary.approval_id = if ($permit.PSObject.Properties.Name -contains 'approval_id') { [string]$permit.approval_id } else { $null }
        $permitSummary.expires_at = if ($permit.PSObject.Properties.Name -contains 'expires_at') { [string]$permit.expires_at } else { $null }
        $permitSummary.consumed = if ($permit.PSObject.Properties.Name -contains 'consumed') { [bool]$permit.consumed } else { $false }
        $permitSummary.process_id = if ($permit.PSObject.Properties.Name -contains 'process_id') { $permit.process_id } else { $null }
        if ($permitSummary.state -eq 'ACTIVE' -and $permitSummary.expires_at) {
            try {
                if ([DateTimeOffset]::Parse($permitSummary.expires_at) -le [DateTimeOffset]::UtcNow) { $permitSummary.state = 'EXPIRED' }
            }
            catch { $permitSummary.state = 'INVALID' }
        }
    }
    catch { $permitSummary.state = 'INVALID' }
}

$codex = @(Get-CimInstance Win32_Process -Filter "Name='codex.exe'" -ErrorAction SilentlyContinue)
$appServers = @($codex | Where-Object { [string]$_.CommandLine -match '(?i)(^|\s)app-server(?:\s|$)' })
$billable = @($codex | Where-Object { [string]$_.CommandLine -notmatch '(?i)(^|\s)app-server(?:\s|$)' })
$watchers = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue | Where-Object { [string]$_.CommandLine -match '(?i)CodexUsageGuard\.ps1' })
$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
$taskInfo = if ($task) { Get-ScheduledTaskInfo -TaskName $TaskName -ErrorAction SilentlyContinue } else { $null }

[ordered]@{
    status = if ($billable.Count -eq 0 -and $task -and $watchers.Count -ge 1) { 'PROTECTED' } else { 'ATTENTION_REQUIRED' }
    usage_default = 'LOCKED'
    permit = $permitSummary
    infrastructure = [ordered]@{
        app_server_count = $appServers.Count
        app_server_process_ids = @($appServers | ForEach-Object { [int]$_.ProcessId })
    }
    billable_or_interactive_codex = [ordered]@{
        count = $billable.Count
        process_ids = @($billable | ForEach-Object { [int]$_.ProcessId })
    }
    guard = [ordered]@{
        task_registered = [bool]$task
        task_state = if ($task) { [string]$task.State } else { 'MISSING' }
        task_last_result = if ($taskInfo) { $taskInfo.LastTaskResult } else { $null }
        watcher_process_count = $watchers.Count
        local_root = $GuardRoot
    }
} | ConvertTo-Json -Depth 10
