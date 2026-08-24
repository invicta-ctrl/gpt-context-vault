[CmdletBinding()]
param(
    [string]$InstallRoot = (Join-Path $env:USERPROFILE '.codex\usage-guard'),
    [string]$TaskName = 'Earl Codex Usage Guard',
    [string]$EvidencePath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Utf8NoBom = [Text.UTF8Encoding]::new($false)

function Assert-Test([bool]$Condition, [string]$Name) {
    if (-not $Condition) { throw "TEST_FAILURE: $Name" }
    Write-Output "PASS $Name"
}

$watcherPath = Join-Path $InstallRoot 'CodexUsageGuard.ps1'
$statusPath = Join-Path $InstallRoot 'Get-CodexUsageStatus.ps1'
$permitPath = Join-Path $InstallRoot 'permit.json'
foreach ($path in @($watcherPath,$statusPath,$permitPath)) {
    Assert-Test (Test-Path -LiteralPath $path -PathType Leaf) "file exists: $path"
}

$parseTargets = @(
    'CodexUsageGuard.ps1',
    'Enable-CodexUsage.ps1',
    'Disable-CodexUsage.ps1',
    'Get-CodexUsageStatus.ps1',
    'Install-CodexUsageGuard.ps1',
    'Test-CodexUsageGuard.ps1'
)
foreach ($name in $parseTargets) {
    $path = Join-Path $InstallRoot $name
    $null = [scriptblock]::Create([IO.File]::ReadAllText($path))
    Assert-Test $true "PowerShell parse: $name"
}

$selfTestText = (& $watcherPath -SelfTest) -join "`n"
$selfTest = $selfTestText | ConvertFrom-Json
Assert-Test ([string]$selfTest.status -eq 'PASS') 'guard classification self-test'

$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
Assert-Test ([string]$task.State -eq 'Running') 'scheduled usage guard is running'
$watchNeedle = [regex]::Escape([IO.Path]::GetFullPath($watcherPath))
$watchers = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object {
    [string]$_.CommandLine -match $watchNeedle
})
Assert-Test ($watchers.Count -eq 1) 'exactly one permanent guard watcher'

$permit = Get-Content -LiteralPath $permitPath -Raw | ConvertFrom-Json
Assert-Test ([string]$permit.state -ne 'ACTIVE') 'no active manual permit during verification'

$preCodex = @(Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'codex.exe' })
$preAppServers = @($preCodex | Where-Object { [string]$_.CommandLine -match '(?i)(^|\s)app-server(?:\s|$)' })
$preAppServerIds = @($preAppServers | ForEach-Object { [int]$_.ProcessId } | Sort-Object)
Assert-Test ($preAppServers.Count -ge 1) 'at least one app-server infrastructure process exists'
Assert-Test (@($preCodex | Where-Object { [string]$_.CommandLine -notmatch '(?i)(^|\s)app-server(?:\s|$)' }).Count -eq 0) 'no non-app-server Codex before dummy test'

$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ('a6-codex-usage-guard-' + [Guid]::NewGuid().ToString('N'))
$dummy = $null
try {
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    $dummyPath = Join-Path $tempRoot 'codex.exe'
    Copy-Item -LiteralPath (Join-Path $env:SystemRoot 'System32\ping.exe') -Destination $dummyPath
    $dummy = Start-Process -FilePath $dummyPath -ArgumentList @('-t','127.0.0.1') -WindowStyle Hidden -PassThru
    $deadline = [DateTime]::UtcNow.AddSeconds(8)
    do {
        Start-Sleep -Milliseconds 100
        $alive = Get-Process -Id $dummy.Id -ErrorAction SilentlyContinue
    } while ($alive -and [DateTime]::UtcNow -lt $deadline)
    Assert-Test ($null -eq $alive) 'harmless dummy codex.exe is terminated by the guard'
}
finally {
    if ($dummy) {
        Stop-Process -Id $dummy.Id -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

Start-Sleep -Milliseconds 500
$postCodex = @(Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'codex.exe' })
$postAppServers = @($postCodex | Where-Object { [string]$_.CommandLine -match '(?i)(^|\s)app-server(?:\s|$)' })
$postAppServerIds = @($postAppServers | ForEach-Object { [int]$_.ProcessId } | Sort-Object)
Assert-Test (($preAppServerIds -join ',') -eq ($postAppServerIds -join ',')) 'app-server infrastructure process identities are preserved'
Assert-Test (@($postCodex | Where-Object { [string]$_.CommandLine -notmatch '(?i)(^|\s)app-server(?:\s|$)' }).Count -eq 0) 'no non-app-server Codex after dummy test'

$statusText = (& $statusPath) -join "`n"
$status = $statusText | ConvertFrom-Json
Assert-Test ([string]$status.status -eq 'PROTECTED') 'status command reports PROTECTED'
Assert-Test ([int]$status.billable_or_interactive_codex.count -eq 0) 'status reports zero billable or interactive Codex processes'

$result = [ordered]@{
    schema_version = 1
    change_id = 'TOKEN-OPT-001-A6'
    verified_at = (Get-Date).ToUniversalTime().ToString('o')
    status = 'PASS'
    task_name = $TaskName
    task_state = [string]$task.State
    watcher_process_ids = @($watchers | ForEach-Object { [int]$_.ProcessId })
    app_server_process_ids_before = $preAppServerIds
    app_server_process_ids_after = $postAppServerIds
    dummy_codex_terminated = $true
    real_codex_invoked = $false
    active_manual_permit = $false
    non_app_server_codex_count = 0
}
if (-not [string]::IsNullOrWhiteSpace($EvidencePath)) {
    $full = [IO.Path]::GetFullPath($EvidencePath)
    $parent = Split-Path -Parent $full
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    [IO.File]::WriteAllText($full, (($result | ConvertTo-Json -Depth 8) + "`n"), $Utf8NoBom)
}
$result | ConvertTo-Json -Depth 8
Write-Output 'SUMMARY PASS guard=dummy_terminated permit=single_use real_codex_calls=0'
