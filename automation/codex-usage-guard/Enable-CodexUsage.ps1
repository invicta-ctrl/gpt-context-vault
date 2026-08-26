[CmdletBinding()]
param(
    [ValidateRange(5, 240)][int]$DurationMinutes = 60,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Model,
    [Parameter(Mandatory)][ValidateSet('low','medium','high','xhigh','max','ultra')][string]$Reasoning,
    [Parameter(Mandatory)][ValidateSet('orchestrator','writer','reviewer')][string]$Role,
    [switch]$ContractProbe,
    [string]$ProbeApprovalId = '',
    [string]$ProbePurpose = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$GuardRoot = Join-Path $env:USERPROFILE '.codex\usage-guard'
$PermitPath = Join-Path $GuardRoot 'permit.json'
$Utf8NoBom = [Text.UTF8Encoding]::new($false)

function Assert-ManualPermitContract {
    param(
        [string]$PermitModel,
        [string]$PermitReasoning,
        [string]$PermitRole,
        [string]$Purpose,
        [string]$ApprovalId
    )

    if ($PermitModel -in @('default','*')) { throw 'An exact model is required.' }
    if ([string]::IsNullOrWhiteSpace($Purpose)) { throw 'Purpose is required.' }
    if ([string]::IsNullOrWhiteSpace($ApprovalId)) { throw 'Approval ID is required.' }
    if ($PermitRole -eq 'reviewer' -and ($PermitModel -ne 'gpt-5.6-sol' -or $PermitReasoning -ne 'high')) {
        throw 'Reviewer permits require exact gpt-5.6-sol with high reasoning.'
    }
}

function New-ManualCodexPermit {
    param(
        [string]$PermitModel,
        [string]$PermitReasoning,
        [string]$PermitRole,
        [string]$Purpose,
        [string]$ApprovalId,
        [string]$IssuedByAccount,
        [DateTimeOffset]$IssuedAt,
        [int]$PermitDurationMinutes
    )

    Assert-ManualPermitContract -PermitModel $PermitModel -PermitReasoning $PermitReasoning -PermitRole $PermitRole -Purpose $Purpose -ApprovalId $ApprovalId
    return [ordered]@{
        schema_version = 2
        approval_id = $ApprovalId
        state = 'ACTIVE'
        issued_by = 'Earl'
        issued_by_account = $IssuedByAccount
        issued_at = $IssuedAt.ToString('o')
        expires_at = $IssuedAt.AddMinutes($PermitDurationMinutes).ToString('o')
        purpose = $Purpose
        origin = 'manual_user'
        manual_interactive = $true
        allowed_model = $PermitModel
        allowed_reasoning = $PermitReasoning
        allowed_role = $PermitRole
        allowed_roles = @($PermitRole)
        allow_subagents = $true
        max_processes = 1
        sol_subagents_allowed = $false
        default_auxiliaries_max = 1
        fresh_sol_reviewer_allowed = $true
        max_fresh_sol_reviewers = 1
        legacy_guard_safety_caps_only = $true
        max_luna_max_subagents = 16
        max_terra_max_subagents = 2
        max_ox_alpha_subagents = 16
        max_total_direct_subagents = 16
        max_delegation_depth = 1
        recursive_spawning = $false
        background_continuation = $false
        automatic_fallback = $false
        consumed = $false
        process_id = $null
        process_started_at = $null
    }
}

if ($ContractProbe) {
    $probeId = if ([string]::IsNullOrWhiteSpace($ProbeApprovalId)) { [Guid]::NewGuid().ToString('D') } else { $ProbeApprovalId }
    $probePurpose = if ([string]::IsNullOrWhiteSpace($ProbePurpose)) { 'SOL-ADVISOR-GLOBAL-001 contract probe' } else { $ProbePurpose }
    $probePermit = New-ManualCodexPermit -PermitModel $Model -PermitReasoning $Reasoning -PermitRole $Role -Purpose $probePurpose -ApprovalId $probeId -IssuedByAccount 'CONTRACT_PROBE' -IssuedAt ([DateTimeOffset]::UtcNow) -PermitDurationMinutes $DurationMinutes
    $probePermit | ConvertTo-Json -Depth 8
    return
}

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

$purpose = (Read-Host 'Describe the one Codex task being approved').Trim()
$challenge = Get-Random -Minimum 100000 -Maximum 999999
Write-Host ''
Write-Host 'This creates one time-bounded permit. It does not start Codex.'
Write-Host 'It authorizes one owner-started Sol advisor session with no Sol subagents; bounded Luna Max (16), Terra Max (2), and Ox Alpha (16) direct-worker ceilings; zero background continuation; and no automatic fallback.'
Write-Host "Type this challenge exactly to approve: $challenge"
$typed = (Read-Host 'Challenge').Trim()
if ($typed -ne [string]$challenge) { throw 'Approval challenge did not match.' }

$now = [DateTimeOffset]::UtcNow
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$permit = New-ManualCodexPermit -PermitModel $Model -PermitReasoning $Reasoning -PermitRole $Role -Purpose $purpose -ApprovalId ([Guid]::NewGuid().ToString('D')) -IssuedByAccount $identity.Name -IssuedAt $now -PermitDurationMinutes $DurationMinutes

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
    sol_subagents_allowed = $false
    default_auxiliaries_max = 1
    fresh_sol_reviewer_allowed = $true
    max_fresh_sol_reviewers = 1
    legacy_guard_safety_caps_only = $true
    max_luna_max_subagents = 16
    max_terra_max_subagents = 2
    max_ox_alpha_subagents = 16
    max_total_direct_subagents = 16
    max_delegation_depth = 1
    codex_started = $false
    next_action = 'Earl must manually start the one approved Codex task. Run Disable-CodexUsage.ps1 when finished.'
} | ConvertTo-Json -Depth 6
