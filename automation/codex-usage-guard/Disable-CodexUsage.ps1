[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$GuardRoot = Join-Path $env:USERPROFILE '.codex\usage-guard'
$PermitPath = Join-Path $GuardRoot 'permit.json'
$LogPath = Join-Path $GuardRoot 'guard-events.jsonl'
$Utf8NoBom = [Text.UTF8Encoding]::new($false)

$approvalId = $null
if (Test-Path -LiteralPath $PermitPath -PathType Leaf) {
    try {
        $permit = Get-Content -LiteralPath $PermitPath -Raw | ConvertFrom-Json
        $approvalId = if ($permit.PSObject.Properties.Name -contains 'approval_id') { [string]$permit.approval_id } else { $null }
        if ($permit.PSObject.Properties.Name -contains 'state') { $permit.state = 'REVOKED' }
        else { $permit | Add-Member -NotePropertyName state -NotePropertyValue 'REVOKED' }
        if ($permit.PSObject.Properties.Name -contains 'revoked_at') { $permit.revoked_at = (Get-Date).ToUniversalTime().ToString('o') }
        else { $permit | Add-Member -NotePropertyName revoked_at -NotePropertyValue ((Get-Date).ToUniversalTime().ToString('o')) }
        $temp = Join-Path $GuardRoot ('.revoke-codex-permit-' + [Guid]::NewGuid().ToString('N') + '.tmp')
        [IO.File]::WriteAllText($temp, (($permit | ConvertTo-Json -Depth 10) + "`n"), $Utf8NoBom)
        Move-Item -Force -LiteralPath $temp -Destination $PermitPath
    }
    catch {
        $invalid = [ordered]@{
            schema_version = 1
            state = 'REVOKED_INVALID_PRIOR_PERMIT'
            revoked_at = (Get-Date).ToUniversalTime().ToString('o')
        }
        [IO.File]::WriteAllText($PermitPath, (($invalid | ConvertTo-Json) + "`n"), $Utf8NoBom)
    }
}

$terminated = [Collections.Generic.List[int]]::new()
$failed = [Collections.Generic.List[int]]::new()
$targets = @(Get-CimInstance Win32_Process -Filter "Name='codex.exe'" -ErrorAction SilentlyContinue | Where-Object {
    [string]$_.CommandLine -notmatch '(?i)(^|\s)app-server(?:\s|$)'
})
foreach ($target in $targets) {
    $processId = [int]$target.ProcessId
    $result = Start-Process -FilePath (Join-Path $env:SystemRoot 'System32\taskkill.exe') -ArgumentList @('/PID',[string]$processId,'/T','/F') -Wait -PassThru -WindowStyle Hidden
    if ($result.ExitCode -eq 0) { $terminated.Add($processId) } else { $failed.Add($processId) }
}

New-Item -ItemType Directory -Force -Path $GuardRoot | Out-Null
$event = [ordered]@{
    observed_at = (Get-Date).ToUniversalTime().ToString('o')
    action = 'MANUAL_LOCK_RESTORED'
    reason = 'PERMIT_REVOKED'
    approval_id = $approvalId
    terminated_process_ids = @($terminated)
    failed_process_ids = @($failed)
}
[IO.File]::AppendAllText($LogPath, (($event | ConvertTo-Json -Compress) + "`n"), $Utf8NoBom)

[ordered]@{
    status = if ($failed.Count -eq 0) { 'CODEX_USAGE_LOCKED' } else { 'LOCK_WITH_TERMINATION_FAILURE' }
    approval_id = $approvalId
    terminated_process_ids = @($terminated)
    failed_process_ids = @($failed)
    app_server_processes_preserved = @(Get-CimInstance Win32_Process -Filter "Name='codex.exe'" -ErrorAction SilentlyContinue | Where-Object { [string]$_.CommandLine -match '(?i)(^|\s)app-server(?:\s|$)' }).Count
} | ConvertTo-Json -Depth 6

if ($failed.Count -ne 0) { exit 1 }
