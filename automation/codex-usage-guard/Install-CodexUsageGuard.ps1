[CmdletBinding()]
param(
    [string]$SourceRoot = $PSScriptRoot,
    [string]$InstallRoot = (Join-Path $env:USERPROFILE '.codex\usage-guard'),
    [string]$BackupRoot = '',
    [string]$TaskName = 'Earl Codex Usage Guard'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Utf8NoBom = [Text.UTF8Encoding]::new($false)
$Timestamp = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ')
if ([string]::IsNullOrWhiteSpace($BackupRoot)) {
    $BackupRoot = Join-Path $env:USERPROFILE ".codex\backups\TOKEN-OPT-001-A6-GUARD-$Timestamp"
}

$required = @(
    'CodexUsageGuard.ps1',
    'Enable-CodexUsage.ps1',
    'Disable-CodexUsage.ps1',
    'Get-CodexUsageStatus.ps1',
    'Install-CodexUsageGuard.ps1',
    'Test-CodexUsageGuard.ps1',
    'README.md'
)
foreach ($name in $required) {
    $path = Join-Path $SourceRoot $name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required guard source is missing: $path"
    }
}

function Get-Sha256([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Stop-ExistingGuardProcesses {
    param([string]$InstalledScript)
    $needle = [regex]::Escape([IO.Path]::GetFullPath($InstalledScript))
    $targets = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue | Where-Object {
        [string]$_.CommandLine -match $needle -and [int]$_.ProcessId -ne $PID
    })
    foreach ($target in $targets) {
        $result = Start-Process -FilePath (Join-Path $env:SystemRoot 'System32\taskkill.exe') `
            -ArgumentList @('/PID',[string]$target.ProcessId,'/T','/F') -Wait -PassThru -WindowStyle Hidden
        if ($result.ExitCode -ne 0) {
            $stillRunning = Get-CimInstance Win32_Process -Filter "ProcessId=$($target.ProcessId)" -ErrorAction SilentlyContinue
            if ($stillRunning) { throw "Failed to stop prior usage guard PID $($target.ProcessId)" }
        }
    }
}

New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null
$manifestEntries = [Collections.Generic.List[object]]::new()

$existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existingTask) {
    $taskXmlPath = Join-Path $BackupRoot 'scheduled-task.xml'
    [IO.File]::WriteAllText($taskXmlPath, (Export-ScheduledTask -TaskName $TaskName), $Utf8NoBom)
    $manifestEntries.Add([ordered]@{
        source = "scheduled-task:$TaskName"
        backup = $taskXmlPath
        bytes = (Get-Item -LiteralPath $taskXmlPath).Length
        sha256 = Get-Sha256 $taskXmlPath
        equality = $true
    })
    Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
}

if (Test-Path -LiteralPath $InstallRoot -PathType Container) {
    $existingBackup = Join-Path $BackupRoot 'prior-usage-guard'
    New-Item -ItemType Directory -Force -Path $existingBackup | Out-Null
    foreach ($file in @(Get-ChildItem -LiteralPath $InstallRoot -File -ErrorAction SilentlyContinue)) {
        $destination = Join-Path $existingBackup $file.Name
        Copy-Item -LiteralPath $file.FullName -Destination $destination -Force
        $sourceHash = Get-Sha256 $file.FullName
        $backupHash = Get-Sha256 $destination
        if ($sourceHash -ne $backupHash) { throw "Guard backup hash mismatch: $($file.FullName)" }
        $manifestEntries.Add([ordered]@{
            source = $file.FullName
            backup = $destination
            bytes = $file.Length
            sha256 = $sourceHash
            equality = $true
        })
    }
}

$installedWatcher = Join-Path $InstallRoot 'CodexUsageGuard.ps1'
Stop-ExistingGuardProcesses -InstalledScript $installedWatcher
New-Item -ItemType Directory -Force -Path $InstallRoot | Out-Null

foreach ($name in $required) {
    $source = Join-Path $SourceRoot $name
    $destination = Join-Path $InstallRoot $name
    Copy-Item -LiteralPath $source -Destination $destination -Force
    if ((Get-Sha256 $source) -ne (Get-Sha256 $destination)) {
        throw "Installed guard hash mismatch: $name"
    }
}

$permit = [ordered]@{
    schema_version = 1
    approval_id = $null
    state = 'LOCKED'
    issued_by = $null
    issued_at = $null
    expires_at = $null
    purpose = 'Default A6 manual-only lock'
    origin = $null
    manual_interactive = $false
    allowed_model = 'default'
    allowed_reasoning = 'default'
    allowed_role = $null
    allowed_roles = @()
    allow_subagents = $false
    max_processes = 1
    max_children = 0
    background_continuation = $false
    automatic_fallback = $false
    consumed = $false
    process_id = $null
    process_started_at = $null
}
$permitPath = Join-Path $InstallRoot 'permit.json'
[IO.File]::WriteAllText($permitPath, (($permit | ConvertTo-Json -Depth 8) + "`n"), $Utf8NoBom)

$powerShell = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$installedWatcher`""
$action = New-ScheduledTaskAction -Execute $powerShell -Argument $arguments
$trigger = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -RestartCount 999 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -ExecutionTimeLimit ([TimeSpan]::Zero) `
    -MultipleInstances IgnoreNew
$principal = New-ScheduledTaskPrincipal `
    -UserId "$env:USERDOMAIN\$env:USERNAME" `
    -LogonType Interactive `
    -RunLevel Limited
Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Description 'Separates Codex app-server infrastructure from manually approved one-process Codex execution.' `
    -Force | Out-Null
Start-ScheduledTask -TaskName $TaskName
Start-Sleep -Seconds 2

$task = Get-ScheduledTask -TaskName $TaskName
$watchNeedle = [regex]::Escape([IO.Path]::GetFullPath($installedWatcher))
$watchers = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object {
    [string]$_.CommandLine -match $watchNeedle
})
$codex = @(Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'codex.exe' })
$appServers = @($codex | Where-Object { [string]$_.CommandLine -match '(?i)(^|\s)app-server(?:\s|$)' })
$billable = @($codex | Where-Object { [string]$_.CommandLine -notmatch '(?i)(^|\s)app-server(?:\s|$)' })
if ([string]$task.State -ne 'Running') { throw "Usage guard task is not running: $($task.State)" }
if ($watchers.Count -ne 1) { throw "Expected one permanent guard watcher, found $($watchers.Count)" }
if ($billable.Count -ne 0) { throw "Non-app-server Codex process remains after guard install: $($billable.ProcessId -join ',')" }

$manifest = [ordered]@{
    schema_version = 1
    change_id = 'TOKEN-OPT-001-A6-GUARD-INSTALL'
    installed_at = (Get-Date).ToUniversalTime().ToString('o')
    source_root = [IO.Path]::GetFullPath($SourceRoot)
    install_root = [IO.Path]::GetFullPath($InstallRoot)
    task_name = $TaskName
    task_state = [string]$task.State
    watcher_process_ids = @($watchers | ForEach-Object { [int]$_.ProcessId })
    app_server_process_ids = @($appServers | ForEach-Object { [int]$_.ProcessId })
    non_app_server_codex_count = $billable.Count
    prior_state = @($manifestEntries)
    installed_files = @($required + 'permit.json' | ForEach-Object {
        $path = Join-Path $InstallRoot $_
        [ordered]@{ path = $path; bytes = (Get-Item -LiteralPath $path).Length; sha256 = Get-Sha256 $path }
    })
}
$manifestPath = Join-Path $BackupRoot 'install-manifest.json'
[IO.File]::WriteAllText($manifestPath, (($manifest | ConvertTo-Json -Depth 12) + "`n"), $Utf8NoBom)

[ordered]@{
    status = 'PASS'
    task_state = [string]$task.State
    watcher_process_ids = $manifest.watcher_process_ids
    app_server_process_ids = $manifest.app_server_process_ids
    non_app_server_codex_count = 0
    install_root = $InstallRoot
    backup_root = $BackupRoot
    manifest = $manifestPath
} | ConvertTo-Json -Depth 8
