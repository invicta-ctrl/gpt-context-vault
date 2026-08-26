[CmdletBinding()]
param(
    [string]$GuardRoot = (Join-Path $env:USERPROFILE '.codex\usage-guard'),
    [ValidateRange(100, 5000)][int]$PollMilliseconds = 200,
    [switch]$SelfTest,
    [switch]$RunOnce,
    [switch]$PermitContractProbe,
    [string]$PermitContractProbePath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$PermitPath = Join-Path $GuardRoot 'permit.json'
$LogPath = Join-Path $GuardRoot 'guard-events.jsonl'
$Utf8NoBom = [Text.UTF8Encoding]::new($false)
$TaskKillPath = Join-Path $env:SystemRoot 'System32\taskkill.exe'
$AllowedProcessIds = [Collections.Generic.HashSet[int]]::new()

function Write-JsonAtomic {
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)]$Value)
    $parent = Split-Path -Parent $Path
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    $temp = Join-Path $parent ('.codex-usage-guard-' + [Guid]::NewGuid().ToString('N') + '.tmp')
    try {
        [IO.File]::WriteAllText($temp, (($Value | ConvertTo-Json -Depth 12) + "`n"), $Utf8NoBom)
        Move-Item -Force -LiteralPath $temp -Destination $Path
    }
    finally {
        if (Test-Path -LiteralPath $temp) { Remove-Item -Force -LiteralPath $temp }
    }
}

function Write-GuardEvent {
    param(
        [Parameter(Mandatory)][string]$Action,
        [Parameter(Mandatory)][string]$Reason,
        [int]$ProcessId = 0,
        [string]$CommandClass = 'N/A',
        [string]$ApprovalId = ''
    )
    New-Item -ItemType Directory -Force -Path $GuardRoot | Out-Null
    $record = [ordered]@{
        observed_at = (Get-Date).ToUniversalTime().ToString('o')
        action = $Action
        reason = $Reason
        process_id = $ProcessId
        command_class = $CommandClass
        approval_id = if ([string]::IsNullOrWhiteSpace($ApprovalId)) { $null } else { $ApprovalId }
    }
    [IO.File]::AppendAllText($LogPath, (($record | ConvertTo-Json -Compress) + "`n"), $Utf8NoBom)
}

function Get-CommandClass {
    param([AllowNull()][string]$CommandLine)
    if (-not [string]::IsNullOrWhiteSpace($CommandLine) -and
        $CommandLine -match '(?i)(^|\s)app-server(?:\s|$)') {
        return 'INFRASTRUCTURE_APP_SERVER'
    }
    return 'BILLABLE_OR_INTERACTIVE_CODEX'
}

function Get-CommandOption {
    param([string]$CommandLine, [string[]]$Names)
    if ([string]::IsNullOrWhiteSpace($CommandLine)) { return $null }
    foreach ($name in $Names) {
        $pattern = '(?i)(?:^|\s)' + [regex]::Escape($name) + '(?:=|\s+)(?<v>"[^"]+"|''[^'']+''|[^\s]+)'
        $match = [regex]::Match($CommandLine, $pattern)
        if ($match.Success) {
            return $match.Groups['v'].Value.Trim([char[]]@([char]34,[char]39))
        }
    }
    return $null
}

function New-PermitContractState {
    param([bool]$Valid, [string]$Reason, $Permit = $null)
    return [pscustomobject]@{ Valid = $Valid; Reason = $Reason; Permit = $Permit }
}

function Test-ManualPermitContract {
    param($Permit)
    if ($null -eq $Permit) { return New-PermitContractState -Valid $false -Reason 'MANUAL_PERMIT_INVALID' }
    foreach ($field in @('schema_version','approval_id','state','issued_by','issued_at','expires_at','purpose','origin','manual_interactive','allowed_model','allowed_reasoning','allowed_role','allowed_roles','allow_subagents','max_processes','sol_subagents_allowed','default_auxiliaries_max','fresh_sol_reviewer_allowed','max_fresh_sol_reviewers','legacy_guard_safety_caps_only','max_luna_max_subagents','max_terra_max_subagents','max_ox_alpha_subagents','max_total_direct_subagents','max_delegation_depth','recursive_spawning','background_continuation','automatic_fallback','consumed')) {
        if ($permit.PSObject.Properties.Name -notcontains $field) {
            return New-PermitContractState -Valid $false -Reason "MANUAL_PERMIT_MISSING_$($field.ToUpperInvariant())" -Permit $Permit
        }
    }
    foreach ($field in @('manual_interactive','allow_subagents','sol_subagents_allowed','fresh_sol_reviewer_allowed','legacy_guard_safety_caps_only','recursive_spawning','background_continuation','automatic_fallback','consumed')) {
        if ($Permit.PSObject.Properties[$field].Value -isnot [bool]) {
            return New-PermitContractState -Valid $false -Reason "MANUAL_PERMIT_$($field.ToUpperInvariant())_BOOLEAN_INVALID" -Permit $Permit
        }
    }
    if ([int]$Permit.schema_version -ne 2) { return New-PermitContractState -Valid $false -Reason 'MANUAL_PERMIT_SCHEMA_INVALID' -Permit $Permit }
    if ([string]$permit.state -ne 'ACTIVE') {
        return New-PermitContractState -Valid $false -Reason "MANUAL_PERMIT_$([string]$permit.state)" -Permit $Permit
    }
    if (-not [bool]$permit.manual_interactive) {
        return New-PermitContractState -Valid $false -Reason 'MANUAL_PERMIT_NOT_INTERACTIVE' -Permit $Permit
    }
    if ([int]$permit.max_processes -ne 1) {
        return New-PermitContractState -Valid $false -Reason 'MANUAL_PERMIT_PROCESS_LIMIT_INVALID' -Permit $Permit
    }
    if (-not [bool]$permit.allow_subagents -or [bool]$permit.sol_subagents_allowed -or [int]$permit.default_auxiliaries_max -ne 1 -or -not [bool]$permit.fresh_sol_reviewer_allowed -or [int]$permit.max_fresh_sol_reviewers -ne 1 -or -not [bool]$permit.legacy_guard_safety_caps_only -or [int]$permit.max_luna_max_subagents -ne 16 -or [int]$permit.max_terra_max_subagents -ne 2 -or [int]$permit.max_ox_alpha_subagents -ne 16 -or [int]$permit.max_total_direct_subagents -ne 16 -or [int]$permit.max_delegation_depth -ne 1 -or [bool]$permit.recursive_spawning -or [bool]$permit.background_continuation -or [bool]$permit.automatic_fallback) {
        return New-PermitContractState -Valid $false -Reason 'MANUAL_PERMIT_ACTIVE_CONTRACT_INVALID' -Permit $Permit
    }
    $allowedModel = if ($permit.PSObject.Properties.Name -contains 'allowed_model') { [string]$permit.allowed_model } else { '' }
    $allowedReasoning = if ($permit.PSObject.Properties.Name -contains 'allowed_reasoning') { [string]$permit.allowed_reasoning } else { '' }
    $allowedRoles = @(if ($permit.PSObject.Properties.Name -contains 'allowed_roles') { $permit.allowed_roles | ForEach-Object { [string]$_ } })
    if ($allowedModel -in @('', 'default', '*')) {
        return New-PermitContractState -Valid $false -Reason 'MANUAL_PERMIT_MODEL_INVALID' -Permit $Permit
    }
    if ($allowedReasoning -in @('', 'default', '*')) {
        return New-PermitContractState -Valid $false -Reason 'MANUAL_PERMIT_REASONING_INVALID' -Permit $Permit
    }
    if ($allowedRoles.Count -ne 1 -or $allowedRoles[0] -notin @('orchestrator','writer','reviewer')) {
        return New-PermitContractState -Valid $false -Reason 'MANUAL_PERMIT_ROLE_INVALID' -Permit $Permit
    }
    if ([string]$permit.allowed_role -ne $allowedRoles[0]) {
        return New-PermitContractState -Valid $false -Reason 'MANUAL_PERMIT_ROLE_INVALID' -Permit $Permit
    }
    if ($allowedRoles[0] -eq 'reviewer' -and ($allowedModel -ne 'gpt-5.6-sol' -or $allowedReasoning -ne 'high')) {
        return New-PermitContractState -Valid $false -Reason 'MANUAL_PERMIT_REVIEWER_CONTRACT_INVALID' -Permit $Permit
    }
    try { $issued = [DateTimeOffset]::Parse([string]$permit.issued_at); $expires = [DateTimeOffset]::Parse([string]$permit.expires_at) }
    catch { return New-PermitContractState -Valid $false -Reason 'MANUAL_PERMIT_EXPIRY_INVALID' -Permit $Permit }
    if ($expires -le $issued) { return New-PermitContractState -Valid $false -Reason 'MANUAL_PERMIT_EXPIRY_INVALID' -Permit $Permit }
    if ($expires -le [DateTimeOffset]::UtcNow) {
        return New-PermitContractState -Valid $false -Reason 'MANUAL_PERMIT_EXPIRED' -Permit $Permit
    }
    return New-PermitContractState -Valid $true -Reason 'MANUAL_PERMIT_VALID' -Permit $Permit
}

function Get-PermitContractFromPath {
    param([string]$Path, [string]$MissingReason = 'CODEX_USAGE_LOCKED')
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return New-PermitContractState -Valid $false -Reason $MissingReason }
    try { $permit = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json }
    catch { return New-PermitContractState -Valid $false -Reason 'MANUAL_PERMIT_INVALID_JSON' }
    return Test-ManualPermitContract -Permit $permit
}

function Get-ManualPermit {
    return Get-PermitContractFromPath -Path $PermitPath
}

if ($PermitContractProbe) {
    if ([string]::IsNullOrWhiteSpace($PermitContractProbePath)) { throw 'Permit-contract probe requires an explicit temporary JSON permit path.' }
    $probePath = [IO.Path]::GetFullPath($PermitContractProbePath)
    $tempPath = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    if (-not $probePath.StartsWith($tempPath, [StringComparison]::OrdinalIgnoreCase) -or [IO.Path]::GetExtension($probePath) -ne '.json') {
        throw 'Permit-contract probe accepts only an explicit temporary JSON permit path.'
    }
    $probeState = Get-PermitContractFromPath -Path $probePath -MissingReason 'MANUAL_PERMIT_PROBE_PATH_INVALID'
    [ordered]@{ Valid = [bool]$probeState.Valid; Reason = [string]$probeState.Reason } | ConvertTo-Json -Depth 4
    return
}

function Test-PermitForProcess {
    param([Parameter(Mandatory)]$Process, [Parameter(Mandatory)]$PermitState)
    if (-not $PermitState.Valid) { return $PermitState }
    $permit = $PermitState.Permit
    $processId = [int]$Process.ProcessId

    if ([bool]$permit.consumed) {
        if ($permit.PSObject.Properties.Name -contains 'process_id' -and [int]$permit.process_id -eq $processId) {
            return [pscustomobject]@{ Valid = $true; Reason = 'MANUAL_PERMIT_BOUND_PROCESS'; Permit = $permit }
        }
        return [pscustomobject]@{ Valid = $false; Reason = 'MANUAL_PERMIT_ALREADY_CONSUMED'; Permit = $permit }
    }

    $commandLine = [string]$Process.CommandLine
    $observedModel = Get-CommandOption -CommandLine $commandLine -Names @('-m','--model')
    $observedReasoning = Get-CommandOption -CommandLine $commandLine -Names @('model_reasoning_effort','--reasoning-effort')
    $allowedModel = [string]$permit.allowed_model
    $allowedReasoning = [string]$permit.allowed_reasoning

    if ($observedModel -ne $allowedModel) {
        return [pscustomobject]@{ Valid = $false; Reason = 'MANUAL_PERMIT_MODEL_MISMATCH'; Permit = $permit }
    }
    if ($observedReasoning -ne $allowedReasoning) {
        return [pscustomobject]@{ Valid = $false; Reason = 'MANUAL_PERMIT_REASONING_MISMATCH'; Permit = $permit }
    }

    $permit.consumed = $true
    if ($permit.PSObject.Properties.Name -contains 'process_id') { $permit.process_id = $processId }
    else { $permit | Add-Member -NotePropertyName process_id -NotePropertyValue $processId }
    $started = if ($Process.CreationDate) { ([DateTimeOffset]$Process.CreationDate).ToUniversalTime().ToString('o') } else { (Get-Date).ToUniversalTime().ToString('o') }
    if ($permit.PSObject.Properties.Name -contains 'process_started_at') { $permit.process_started_at = $started }
    else { $permit | Add-Member -NotePropertyName process_started_at -NotePropertyValue $started }
    Write-JsonAtomic -Path $PermitPath -Value $permit
    return [pscustomobject]@{ Valid = $true; Reason = 'MANUAL_PERMIT_CONSUMED'; Permit = $permit }
}

function Stop-CodexProcessTree {
    param([Parameter(Mandatory)][int]$ProcessId, [Parameter(Mandatory)][string]$Reason)
    $result = Start-Process -FilePath $TaskKillPath -ArgumentList @('/PID',[string]$ProcessId,'/T','/F') -Wait -PassThru -WindowStyle Hidden
    Write-GuardEvent -Action $(if ($result.ExitCode -eq 0) { 'TERMINATED' } else { 'TERMINATION_FAILED' }) -Reason $Reason -ProcessId $ProcessId -CommandClass 'BILLABLE_OR_INTERACTIVE_CODEX'
}

function Complete-SpentPermitIfNeeded {
    $state = Get-ManualPermit
    if (-not $state.Valid -or -not [bool]$state.Permit.consumed) { return }
    $boundId = if ($state.Permit.PSObject.Properties.Name -contains 'process_id') { [int]$state.Permit.process_id } else { 0 }
    if ($boundId -le 0) { return }
    $stillRunning = Get-CimInstance Win32_Process -Filter "ProcessId=$boundId" -ErrorAction SilentlyContinue
    if ($null -eq $stillRunning) {
        $state.Permit.state = 'SPENT'
        if ($state.Permit.PSObject.Properties.Name -contains 'completed_at') { $state.Permit.completed_at = (Get-Date).ToUniversalTime().ToString('o') }
        else { $state.Permit | Add-Member -NotePropertyName completed_at -NotePropertyValue ((Get-Date).ToUniversalTime().ToString('o')) }
        Write-JsonAtomic -Path $PermitPath -Value $state.Permit
        Write-GuardEvent -Action 'PERMIT_SPENT' -Reason 'BOUND_PROCESS_EXITED' -ApprovalId ([string]$state.Permit.approval_id)
    }
}

function Invoke-GuardPass {
    $processes = @(Get-CimInstance Win32_Process -Filter "Name='codex.exe'" -ErrorAction SilentlyContinue)
    foreach ($process in $processes) {
        $processId = [int]$process.ProcessId
        $class = Get-CommandClass -CommandLine ([string]$process.CommandLine)
        if ($class -eq 'INFRASTRUCTURE_APP_SERVER') { continue }

        $permitState = Get-ManualPermit
        $decision = Test-PermitForProcess -Process $process -PermitState $permitState
        if ($decision.Valid) {
            if ($AllowedProcessIds.Add($processId)) {
                Write-GuardEvent -Action 'ALLOWED_MANUAL_PROCESS' -Reason $decision.Reason -ProcessId $processId -CommandClass $class -ApprovalId ([string]$decision.Permit.approval_id)
            }
            continue
        }
        Stop-CodexProcessTree -ProcessId $processId -Reason $decision.Reason
        [void]$AllowedProcessIds.Remove($processId)
    }
    Complete-SpentPermitIfNeeded
}

if ($SelfTest) {
    $selfTestRoot = Join-Path ([IO.Path]::GetTempPath()) ('codex-usage-guard-self-test-' + [Guid]::NewGuid().ToString('N'))
    $PermitPath = Join-Path $selfTestRoot 'permit.json'
    $LogPath = Join-Path $selfTestRoot 'guard-events.jsonl'
    try {
        New-Item -ItemType Directory -Force -Path $selfTestRoot | Out-Null
        $now = [DateTimeOffset]::UtcNow
        $permit = [ordered]@{
            schema_version = 2
            approval_id = [Guid]::NewGuid().ToString('D')
            state = 'ACTIVE'
            issued_by = 'Earl'
            issued_at = $now.AddMinutes(-1).ToString('o')
            expires_at = $now.AddMinutes(5).ToString('o')
            purpose = 'deterministic guard self-test'
            origin = 'manual_user'
            manual_interactive = $true
            allowed_model = 'gpt-5.6-sol'
            allowed_reasoning = 'high'
            allowed_role = 'reviewer'
            allowed_roles = @('reviewer')
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
        Write-JsonAtomic -Path $PermitPath -Value $permit
        $validReviewerState = Get-ManualPermit
        $legacyPermit = (($permit | ConvertTo-Json -Depth 12) | ConvertFrom-Json)
        [void]$legacyPermit.PSObject.Properties.Remove('default_auxiliaries_max')
        $legacyState = Test-ManualPermitContract -Permit $legacyPermit
        $malformedReviewerPermit = (($permit | ConvertTo-Json -Depth 12) | ConvertFrom-Json)
        $malformedReviewerPermit.allowed_model = 'gpt-5.6-terra'
        $malformedReviewerState = Test-ManualPermitContract -Permit $malformedReviewerPermit
        $stringBooleanPermit = (($permit | ConvertTo-Json -Depth 12) | ConvertFrom-Json)
        $stringBooleanPermit.fresh_sol_reviewer_allowed = 'true'
        $stringBooleanState = Test-ManualPermitContract -Permit $stringBooleanPermit
        $firstProcess = [pscustomobject]@{
            ProcessId = 424201
            CommandLine = 'codex exec -m gpt-5.6-sol model_reasoning_effort=high -'
            CreationDate = Get-Date
        }
        $firstDecision = Test-PermitForProcess -Process $firstProcess -PermitState (Get-ManualPermit)
        $consumedPermit = Get-Content -LiteralPath $PermitPath -Raw | ConvertFrom-Json
        $secondProcess = [pscustomobject]@{
            ProcessId = 424202
            CommandLine = 'codex exec -m gpt-5.6-sol model_reasoning_effort=high -'
            CreationDate = Get-Date
        }
        $secondDecision = Test-PermitForProcess -Process $secondProcess -PermitState (Get-ManualPermit)

        $expiredPermit = $consumedPermit.PSObject.Copy()
        $expiredPermit.consumed = $false
        $expiredPermit.process_id = $null
        $expiredPermit.expires_at = $now.AddSeconds(-1).ToString('o')
        Write-JsonAtomic -Path $PermitPath -Value $expiredPermit
        $expiredState = Get-ManualPermit

        $revokedPermit = $consumedPermit.PSObject.Copy()
        $revokedPermit.state = 'REVOKED'
        $revokedPermit.consumed = $false
        $revokedPermit.process_id = $null
        Write-JsonAtomic -Path $PermitPath -Value $revokedPermit
        $revokedState = Get-ManualPermit

        $checks = [ordered]@{
            app_server_allowed = (Get-CommandClass 'codex app-server') -eq 'INFRASTRUCTURE_APP_SERVER'
            desktop_app_server_allowed = (Get-CommandClass 'codex.exe -c features.code_mode_host=true app-server --analytics-default-enabled') -eq 'INFRASTRUCTURE_APP_SERVER'
            exec_blocked = (Get-CommandClass 'codex exec -m gpt-5.6-terra -') -eq 'BILLABLE_OR_INTERACTIVE_CODEX'
            resume_blocked = (Get-CommandClass 'codex exec resume 1234 -') -eq 'BILLABLE_OR_INTERACTIVE_CODEX'
            empty_command_blocked = (Get-CommandClass '') -eq 'BILLABLE_OR_INTERACTIVE_CODEX'
            active_reviewer_contract_valid = [bool]$validReviewerState.Valid -and [string]$validReviewerState.Reason -eq 'MANUAL_PERMIT_VALID'
            legacy_active_shape_denied = -not [bool]$legacyState.Valid -and [string]$legacyState.Reason -eq 'MANUAL_PERMIT_MISSING_DEFAULT_AUXILIARIES_MAX'
            malformed_reviewer_denied = -not [bool]$malformedReviewerState.Valid -and [string]$malformedReviewerState.Reason -eq 'MANUAL_PERMIT_REVIEWER_CONTRACT_INVALID'
            string_boolean_denied = -not [bool]$stringBooleanState.Valid -and [string]$stringBooleanState.Reason -eq 'MANUAL_PERMIT_FRESH_SOL_REVIEWER_ALLOWED_BOOLEAN_INVALID'
            exact_permit_allowed_once = [bool]$firstDecision.Valid
            exact_permit_consumed = [bool]$consumedPermit.consumed -and [int]$consumedPermit.process_id -eq 424201
            second_process_denied = -not [bool]$secondDecision.Valid -and [string]$secondDecision.Reason -eq 'MANUAL_PERMIT_ALREADY_CONSUMED'
            expired_permit_denied = -not [bool]$expiredState.Valid -and [string]$expiredState.Reason -eq 'MANUAL_PERMIT_EXPIRED'
            revoked_permit_denied = -not [bool]$revokedState.Valid -and [string]$revokedState.Reason -eq 'MANUAL_PERMIT_REVOKED'
            subagent_boundary_recorded = [bool]$consumedPermit.allow_subagents -and -not [bool]$consumedPermit.sol_subagents_allowed -and [int]$consumedPermit.default_auxiliaries_max -eq 1 -and [bool]$consumedPermit.fresh_sol_reviewer_allowed -and [int]$consumedPermit.max_fresh_sol_reviewers -eq 1 -and [bool]$consumedPermit.legacy_guard_safety_caps_only -and [int]$consumedPermit.max_luna_max_subagents -eq 16 -and [int]$consumedPermit.max_terra_max_subagents -eq 2 -and [int]$consumedPermit.max_ox_alpha_subagents -eq 16 -and [int]$consumedPermit.max_total_direct_subagents -eq 16 -and [int]$consumedPermit.max_delegation_depth -eq 1 -and -not [bool]$consumedPermit.recursive_spawning -and -not [bool]$consumedPermit.background_continuation -and -not [bool]$consumedPermit.automatic_fallback
            exact_role_recorded = [string]$consumedPermit.allowed_role -eq 'reviewer' -and @($consumedPermit.allowed_roles).Count -eq 1
        }
        $failed = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
        [ordered]@{ status = if ($failed.Count -eq 0) { 'PASS' } else { 'FAIL' }; checks = $checks } | ConvertTo-Json -Depth 6
        if ($failed.Count -ne 0) { exit 1 }
        exit 0
    }
    finally {
        if (Test-Path -LiteralPath $selfTestRoot) { Remove-Item -LiteralPath $selfTestRoot -Recurse -Force }
    }
}

New-Item -ItemType Directory -Force -Path $GuardRoot | Out-Null
$created = $false
$mutex = [Threading.Mutex]::new($true, 'Local\EarlCodexUsageGuard', [ref]$created)
if (-not $created) { exit 0 }

try {
    do {
        try { Invoke-GuardPass }
        catch { Write-GuardEvent -Action 'GUARD_ERROR' -Reason $_.Exception.GetType().Name }
        if ($RunOnce) { break }
        Start-Sleep -Milliseconds $PollMilliseconds
    } while ($true)
}
finally {
    if ($mutex) { $mutex.ReleaseMutex(); $mutex.Dispose() }
}
