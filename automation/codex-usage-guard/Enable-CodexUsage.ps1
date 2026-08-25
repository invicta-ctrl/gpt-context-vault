[CmdletBinding()]
param(
    [ValidateRange(5, 240)][int]$DurationMinutes = 60,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Model,
    [Parameter(Mandatory)][ValidateSet('low','medium','high','xhigh','max','ultra')][string]$Reasoning,
    [Parameter(Mandatory)][ValidateSet('orchestrator','writer','read_only_worker')][string]$Role
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$GuardRoot = Join-Path $env:USERPROFILE '.codex\usage-guard'
$PermitPath = Join-Path $GuardRoot 'permit.json'
$Utf8NoBom = [Text.UTF8Encoding]::new($false)

if ($Host.Name -ne 'ConsoleHost') {
    throw 'Manual Codex approval requires an interactive Windows console.'
}
try {
    if ([Console]::IsInputRedirected) { throw 'Manual Codex approval refuses redirected input.' }
}
catch [System.Management.Automation.RuntimeException] { throw }
catch { }

$current = Get-CimInstance Win32_Process -Filter "ProcessId=$PID"
$parent = if ($current) { Get-CimInstance Win32_Process -Filter "ProcessId=$($current.ParentProcessId)" -ErrorAction SilentlyContinue } else { $null }
if ($parent -and $parent.Name -match '^(bash|node|tunnel-client|codex)\.exe$') {
    throw "Manual Codex approval refuses automation parent: $($parent.Name)"
}

if (Test-Path -LiteralPath $PermitPath -PathType Leaf) {
    try {
        $existing = Get-Content -LiteralPath $PermitPath -Raw | ConvertFrom-Json
        if ([string]$existing.state -eq 'ACTIVE' -and [DateTimeOffset]::Parse([string]$existing.expires_at) -gt [DateTimeOffset]::UtcNow) {
            throw "An active permit already exists: $([string]$existing.approval_id)"
        }
    }
    catch [System.Management.Automation.RuntimeException] { throw }
    catch { }
}

if ($Model -in @('default','*')) { throw 'An exact model is required.' }
$purpose = (Read-Host 'Describe the one Codex task being approved').Trim()
if ([string]::IsNullOrWhiteSpace($purpose)) { throw 'Purpose is required.' }
$challenge = Get-Random -Minimum 100000 -Maximum 999999
Write-Host ''
Write-Host 'This creates one time-bounded permit. It does not start Codex.'
Write-Host 'It authorizes one owner-started Sol session with zero children by default, up to 16 direct children, zero background continuation, and no automatic fallback.'
Write-Host "Type this challenge exactly to approve: $challenge"
$typed = (Read-Host 'Challenge').Trim()
if ($typed -ne [string]$challenge) { throw 'Approval challenge did not match.' }

$now = [DateTimeOffset]::UtcNow
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$permit = [ordered]@{
    schema_version = 2
    approval_id = [Guid]::NewGuid().ToString('D')
    state = 'ACTIVE'
    issued_by = 'Earl'
    issued_by_account = $identity.Name
    issued_at = $now.ToString('o')
    expires_at = $now.AddMinutes($DurationMinutes).ToString('o')
    purpose = $purpose
    origin = 'manual_user'
    manual_interactive = $true
    allowed_model = $Model
    allowed_reasoning = $Reasoning
    allowed_role = $Role
    allowed_roles = @($Role)
    allow_subagents = $true
    max_processes = 1
    default_children = 0
    max_children = 16
    max_delegation_depth = 1
    recursive_spawning = $false
    background_continuation = $false
    automatic_fallback = $false
    consumed = $false
    process_id = $null
    process_started_at = $null
}

New-Item -ItemType Directory -Force -Path $GuardRoot | Out-Null
$temp = Join-Path $GuardRoot ('.manual-codex-permit-' + [Guid]::NewGuid().ToString('N') + '.tmp')
try {
    [IO.File]::WriteAllText($temp, (($permit | ConvertTo-Json -Depth 8) + "`n"), $Utf8NoBom)
    Move-Item -Force -LiteralPath $temp -Destination $PermitPath
}
finally {
    if (Test-Path -LiteralPath $temp) { Remove-Item -Force -LiteralPath $temp }
}

try {
    $sid = $identity.User.Value
    $grant = ('*{0}:(F)' -f $sid)
    & (Join-Path $env:SystemRoot 'System32\icacls.exe') $PermitPath '/inheritance:r' '/grant:r' $grant | Out-Null
}
catch { }

[ordered]@{
    status = 'MANUAL_PERMIT_ACTIVE'
    approval_id = $permit.approval_id
    expires_at = $permit.expires_at
    allowed_model = $permit.allowed_model
    allowed_reasoning = $permit.allowed_reasoning
    allowed_role = $Role
    max_processes = 1
    default_children = 0
    max_children = 16
    max_delegation_depth = 1
    codex_started = $false
    next_action = 'Earl must manually start the one approved Codex task. Run Disable-CodexUsage.ps1 when finished.'
} | ConvertTo-Json -Depth 6
