[CmdletBinding()]
param(
    [string]$ProfilePath = (Join-Path $PSScriptRoot 'current-routing-profile.json'),
    [string]$CatalogPath = "$env:USERPROFILE\.codex\codex-router\merged-models.json",
    [string]$ExecutionGatePath = (Join-Path $PSScriptRoot 'manual-codex-execution-gate.json'),
    [string]$ManualPermitPath = "$env:USERPROFILE\.codex\usage-guard\permit.json",
    [Parameter(Mandatory)][string]$RequestPath,
    [string]$StatePath,
    [string]$TelemetryPath,
    [string]$FindingsPath,
    [string]$VerificationReceiptPath,
    [switch]$RecordOxFailure
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Route {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw "ROUTE_VALIDATION: $Message"
    }
}

function Get-OptionalProperty {
    param($Object, [string]$Name, $Default = $null)
    if ($null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name) {
        return $Object.$Name
    }
    return $Default
}

function Set-ObjectProperty {
    param($Object, [string]$Name, $Value)
    if ($Object.PSObject.Properties.Name -contains $Name) {
        $Object.$Name = $Value
    }
    else {
        $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Value
    }
}

function Read-JsonRequired {
    param([string]$Path, [string]$Label)
    Assert-Route (Test-Path -LiteralPath $Path -PathType Leaf) "$Label is missing: $Path"
    try {
        return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
    }
    catch {
        throw "ROUTE_VALIDATION: $Label is not valid JSON: $Path"
    }
}

function Get-NormalizedPath {
    param([string]$Path)
    try { return [IO.Path]::GetFullPath($Path).TrimEnd([IO.Path]::DirectorySeparatorChar) }
    catch { throw "ROUTE_VALIDATION: MANUAL_PERMIT_PATH_INVALID" }
}

function Get-ManualExecutionGate {
    param([string]$Path)
    $gate = Read-JsonRequired -Path $Path -Label 'manual Codex execution gate'
    $policyId = [string](Get-OptionalProperty $gate 'policy_id' '')
    Assert-Route ($policyId -in @('TOKEN-OPT-001-A6', 'TOKEN-OPT-001-A7', 'TOKEN-OPT-001-A8', 'SOL-ADVISOR-GLOBAL-001')) 'MANUAL_EXECUTION_GATE_POLICY_MISMATCH'
    Assert-Route ([int](Get-OptionalProperty $gate 'schema_version' 0) -in @(1, 2)) 'MANUAL_EXECUTION_GATE_INVALID'
    Assert-Route ([string](Get-OptionalProperty $gate 'default_state' '') -eq 'LOCKED') 'MANUAL_EXECUTION_GATE_NOT_LOCKED'
    Assert-Route ([bool](Get-OptionalProperty $gate 'manual_only' $false)) 'MANUAL_EXECUTION_GATE_NOT_MANUAL_ONLY'
    Assert-Route ([int](Get-OptionalProperty $gate 'max_processes' 0) -eq 1) 'MANUAL_EXECUTION_GATE_PROCESS_LIMIT_INVALID'
    if ($policyId -eq 'TOKEN-OPT-001-A6') {
        Assert-Route ([int](Get-OptionalProperty $gate 'max_children' -1) -eq 0) 'MANUAL_EXECUTION_GATE_CHILD_LIMIT_INVALID'
        Assert-Route (-not [bool](Get-OptionalProperty $gate 'allow_subagents' $true)) 'SUBAGENTS_DISABLED'
    }
    elseif ($policyId -eq 'TOKEN-OPT-001-A7') {
        Assert-Route ([bool](Get-OptionalProperty $gate 'owner_started_sol_session' $false)) 'OWNER_STARTED_SOL_SESSION_REQUIRED'
        Assert-Route ([int](Get-OptionalProperty $gate 'default_children' -1) -eq 0) 'MANUAL_EXECUTION_GATE_DEFAULT_CHILDREN_INVALID'
        Assert-Route ([int](Get-OptionalProperty $gate 'max_children' -1) -eq 16) 'MANUAL_EXECUTION_GATE_CHILD_LIMIT_INVALID'
        Assert-Route ([bool](Get-OptionalProperty $gate 'allow_subagents' $false)) 'SUBAGENTS_MUST_BE_AVAILABLE'
        Assert-Route ([int](Get-OptionalProperty $gate 'max_delegation_depth' 0) -eq 1) 'DELEGATION_DEPTH_INVALID'
        Assert-Route (-not [bool](Get-OptionalProperty $gate 'recursive_spawning' $true)) 'RECURSIVE_SPAWNING_DISABLED'
        Assert-Route ([int](Get-OptionalProperty $gate 'max_active_writers_account_wide' 0) -eq 2) 'ACCOUNT_WRITER_LIMIT_INVALID'
        Assert-Route ([int](Get-OptionalProperty $gate 'max_writers_per_repository_or_worktree' 0) -eq 1) 'TARGET_WRITER_LIMIT_INVALID'
    }
    else {
        Assert-Route ([bool](Get-OptionalProperty $gate 'owner_started_sol_session' $false)) 'OWNER_STARTED_SOL_SESSION_REQUIRED'
        Assert-Route (-not [bool](Get-OptionalProperty $gate 'sol_subagents_allowed' $true)) 'SOL_SUBAGENTS_PROHIBITED'
        Assert-Route ([int](Get-OptionalProperty $gate 'max_luna_max_subagents' 0) -eq 16) 'LUNA_MAX_SUBAGENT_LIMIT_INVALID'
        Assert-Route ([int](Get-OptionalProperty $gate 'max_terra_max_subagents' 0) -eq 2) 'TERRA_MAX_SUBAGENT_LIMIT_INVALID'
        Assert-Route ([int](Get-OptionalProperty $gate 'max_ox_alpha_subagents' 0) -eq 16) 'OX_ALPHA_SUBAGENT_LIMIT_INVALID'
        Assert-Route ([int](Get-OptionalProperty $gate 'max_total_direct_subagents' 0) -eq 16) 'TOTAL_DIRECT_SUBAGENT_LIMIT_INVALID'
        Assert-Route ([bool](Get-OptionalProperty $gate 'allow_subagents' $false)) 'SUBAGENTS_MUST_BE_AVAILABLE'
        Assert-Route ([int](Get-OptionalProperty $gate 'max_delegation_depth' 0) -eq 1) 'DELEGATION_DEPTH_INVALID'
        Assert-Route (-not [bool](Get-OptionalProperty $gate 'recursive_spawning' $true)) 'RECURSIVE_SPAWNING_DISABLED'
        Assert-Route ([int](Get-OptionalProperty $gate 'max_active_writers_account_wide' 0) -eq 2) 'ACCOUNT_WRITER_LIMIT_INVALID'
        Assert-Route ([int](Get-OptionalProperty $gate 'max_writers_per_repository_or_worktree' 0) -eq 1) 'TARGET_WRITER_LIMIT_INVALID'
        if ($policyId -eq 'SOL-ADVISOR-GLOBAL-001') {
            Assert-Route ([int](Get-OptionalProperty $gate 'default_auxiliaries_max' 0) -eq 1) 'SOL_ADVISOR_DEFAULT_AUXILIARY_LIMIT_INVALID'
            Assert-Route ([bool](Get-OptionalProperty $gate 'fresh_sol_reviewer_allowed' $false)) 'SOL_ADVISOR_FRESH_REVIEWER_REQUIRED'
            Assert-Route ([int](Get-OptionalProperty $gate 'max_fresh_sol_reviewers' 0) -eq 1) 'SOL_ADVISOR_FRESH_REVIEWER_LIMIT_INVALID'
        }
    }
    Assert-Route (-not [bool](Get-OptionalProperty $gate 'background_continuation' $true)) 'BACKGROUND_CONTINUATION_DISABLED'
    Assert-Route (-not [bool](Get-OptionalProperty $gate 'automatic_fallback' $true)) 'AUTOMATIC_FALLBACK_DISABLED'
    Assert-Route (-not [bool](Get-OptionalProperty $gate 'route_compiler_is_dispatcher' $true)) 'ROUTE_COMPILER_MUST_NOT_DISPATCH'
    return $gate
}

function Read-ManualPermit {
    param([string]$Path)
    Assert-Route (Test-Path -LiteralPath $Path -PathType Leaf) 'CODEX_USAGE_LOCKED'
    try { return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json) }
    catch { throw "ROUTE_VALIDATION: MANUAL_PERMIT_INVALID" }
}

function Get-NonInfrastructureCodexProcesses {
    try {
        return @(Get-CimInstance Win32_Process -Filter "Name='codex.exe'" -ErrorAction Stop | Where-Object {
            [string]$_.CommandLine -notmatch '(?i)(^|\s)app-server(?:\s|$)'
        })
    }
    catch { throw "ROUTE_VALIDATION: CODEX_PROCESS_STATE_UNAVAILABLE" }
}

function Assert-ManualExecutionPreconditions {
    param(
        $Gate,
        $Request,
        [string]$Role,
        [int]$ActiveWriters,
        [int]$ActiveReadOnly,
        [int]$ActiveTotal,
        [string]$PermitPath
    )

    $policyId = [string](Get-OptionalProperty $Gate 'policy_id' '')
    $configuredPermitPath = [string](Get-OptionalProperty $Gate 'permit_path' '')
    Assert-Route (-not [string]::IsNullOrWhiteSpace($configuredPermitPath)) 'MANUAL_PERMIT_PATH_INVALID'
    Assert-Route ((Get-NormalizedPath $configuredPermitPath) -ieq (Get-NormalizedPath $PermitPath)) 'MANUAL_PERMIT_PATH_MISMATCH'
    Assert-Route ([string](Get-OptionalProperty $Request 'execution_origin' '') -eq 'manual_user') 'MANUAL_USER_ORIGIN_REQUIRED'
    Assert-Route ([bool](Get-OptionalProperty $Request 'manual_interactive' $false)) 'MANUAL_INTERACTIVE_APPROVAL_REQUIRED'
    foreach ($priorAuthorityFlag in @('prior_owner_approval','prior_accepted_specification','autonomous_completion','absolutely_necessary')) {
        Assert-Route (-not [bool](Get-OptionalProperty $Request $priorAuthorityFlag $false)) 'MANUAL_CODEX_EXECUTION_REQUIRED'
    }
    Assert-Route ($Request.PSObject.Properties.Name -contains 'background_continuation') 'BACKGROUND_CONTINUATION_DISABLED'
    Assert-Route (-not [bool](Get-OptionalProperty $Request 'background_continuation' $true)) 'BACKGROUND_CONTINUATION_DISABLED'
    Assert-Route ($Request.PSObject.Properties.Name -contains 'automatic_fallback') 'AUTOMATIC_FALLBACK_DISABLED'
    Assert-Route (-not [bool](Get-OptionalProperty $Request 'automatic_fallback' $true)) 'AUTOMATIC_FALLBACK_DISABLED'

    if ($policyId -eq 'TOKEN-OPT-001-A6') {
        Assert-Route ($Request.PSObject.Properties.Name -contains 'subagent_requested') 'SUBAGENTS_DISABLED'
        Assert-Route (-not [bool](Get-OptionalProperty $Request 'subagent_requested' $true)) 'SUBAGENTS_DISABLED'
        Assert-Route ($ActiveWriters -eq 0 -and $ActiveReadOnly -eq 0 -and $ActiveTotal -eq 0) 'SECOND_PROCESS_DISABLED'
        Assert-Route (@(Get-NonInfrastructureCodexProcesses).Count -eq 0) 'SECOND_PROCESS_DISABLED'
    }
    elseif ($policyId -eq 'TOKEN-OPT-001-A7') {
        Assert-Route ([bool](Get-OptionalProperty $Request 'owner_started_sol_session' $false)) 'OWNER_STARTED_SOL_SESSION_REQUIRED'
        $requestedChildren = Get-Integer -Value (Get-OptionalProperty $Request 'requested_children' 0) -Label 'requested_children'
        Assert-Route ($requestedChildren -le 16) 'SOL_CHILD_LIMIT_EXCEEDED'
        Assert-Route ($ActiveTotal -le 16) 'SOL_CHILD_LIMIT_EXCEEDED'
        $subagentRequested = [bool](Get-OptionalProperty $Request 'subagent_requested' ($requestedChildren -gt 0))
        Assert-Route (($requestedChildren -gt 0) -eq $subagentRequested) 'SUBAGENT_REQUEST_COUNT_MISMATCH'
        $depth = Get-Integer -Value (Get-OptionalProperty $Request 'delegation_depth' 0) -Label 'delegation_depth'
        Assert-Route ($depth -le 1) 'DELEGATION_DEPTH_EXCEEDED'
        Assert-Route (-not [bool](Get-OptionalProperty $Request 'spawned_by_worker' $false)) 'RECURSIVE_SPAWNING_DISABLED'
        if ($Role -eq 'writer') {
            $targetWriters = Get-Integer -Value (Get-OptionalProperty $Request 'active_writers_target' 0) -Label 'active_writers_target'
            Assert-Route ($ActiveWriters -lt 2) 'ACCOUNT_WRITER_LIMIT_EXCEEDED'
            Assert-Route ($targetWriters -lt 1) 'TARGET_WRITER_LIMIT_EXCEEDED'
        }
    }
    else {
        Assert-Route ([bool](Get-OptionalProperty $Request 'owner_started_sol_session' $false)) 'OWNER_STARTED_SOL_SESSION_REQUIRED'
        $requestedLuna = Get-Integer -Value (Get-OptionalProperty $Request 'requested_luna_max_subagents' 0) -Label 'requested_luna_max_subagents'
        $requestedTerra = Get-Integer -Value (Get-OptionalProperty $Request 'requested_terra_max_subagents' 0) -Label 'requested_terra_max_subagents'
        $requestedOx = Get-Integer -Value (Get-OptionalProperty $Request 'requested_ox_alpha_subagents' 0) -Label 'requested_ox_alpha_subagents'
        $requestedSol = Get-Integer -Value (Get-OptionalProperty $Request 'requested_sol_subagents' 0) -Label 'requested_sol_subagents'
        $requestedReviewer = if ($policyId -eq 'SOL-ADVISOR-GLOBAL-001') { Get-Integer -Value (Get-OptionalProperty $Request 'requested_sol_reviewer_auxiliaries' 0) -Label 'requested_sol_reviewer_auxiliaries' } else { 0 }
        $requestedTotal = $requestedLuna + $requestedTerra + $requestedOx + $requestedSol + $requestedReviewer
        Assert-Route ($requestedSol -eq 0) 'SOL_SUBAGENTS_PROHIBITED'
        Assert-Route ($requestedLuna -le 16) 'LUNA_MAX_SUBAGENT_LIMIT_EXCEEDED'
        Assert-Route ($requestedTerra -le 2) 'TERRA_MAX_SUBAGENT_LIMIT_EXCEEDED'
        Assert-Route ($requestedOx -le 16) 'OX_ALPHA_SUBAGENT_LIMIT_EXCEEDED'
        Assert-Route ($requestedTotal -le 16 -and $ActiveTotal -le 16) 'TOTAL_DIRECT_SUBAGENT_LIMIT_EXCEEDED'
        if ($policyId -eq 'SOL-ADVISOR-GLOBAL-001') {
            Assert-Route ($requestedReviewer -le 1) 'SOL_ADVISOR_FRESH_REVIEWER_LIMIT_INVALID'
            Assert-Route ($requestedTotal -le [int](Get-OptionalProperty $Gate 'default_auxiliaries_max' 0)) 'SOL_ADVISOR_ONE_AUXILIARY_DEFAULT_EXCEEDED'
            if ($Role -eq 'reviewer') {
                Assert-Route ($requestedReviewer -eq 1 -and $requestedLuna -eq 0 -and $requestedTerra -eq 0 -and $requestedOx -eq 0) 'SOL_ADVISOR_REVIEWER_REQUEST_INVALID'
            }
            else {
                Assert-Route ($requestedReviewer -eq 0) 'SOL_ADVISOR_REVIEWER_REQUEST_INVALID'
            }
        }
        $subagentRequested = [bool](Get-OptionalProperty $Request 'subagent_requested' ($requestedTotal -gt 0))
        Assert-Route (($requestedTotal -gt 0) -eq $subagentRequested) 'SUBAGENT_REQUEST_COUNT_MISMATCH'
        $requestedModel = [string](Get-OptionalProperty $Request 'requested_model' '')
        Assert-Route (-not ($subagentRequested -and $requestedModel -eq 'gpt-5.6-sol' -and $Role -ne 'reviewer')) 'SOL_SUBAGENTS_PROHIBITED'
        $depth = Get-Integer -Value (Get-OptionalProperty $Request 'delegation_depth' 0) -Label 'delegation_depth'
        Assert-Route ($depth -le 1) 'DELEGATION_DEPTH_EXCEEDED'
        Assert-Route (-not [bool](Get-OptionalProperty $Request 'spawned_by_worker' $false)) 'RECURSIVE_SPAWNING_DISABLED'
        if ($Role -eq 'writer') {
            $targetWriters = Get-Integer -Value (Get-OptionalProperty $Request 'active_writers_target' 0) -Label 'active_writers_target'
            Assert-Route ($ActiveWriters -lt 2) 'ACCOUNT_WRITER_LIMIT_EXCEEDED'
            Assert-Route ($targetWriters -lt 1) 'TARGET_WRITER_LIMIT_EXCEEDED'
        }
    }

    $permit = Read-ManualPermit -Path $PermitPath
    if ($policyId -eq 'SOL-ADVISOR-GLOBAL-001') {
        $activeBooleanValues = [ordered]@{
            manual_interactive = $true
            allow_subagents = $true
            sol_subagents_allowed = $false
            fresh_sol_reviewer_allowed = $true
            legacy_guard_safety_caps_only = $true
            recursive_spawning = $false
            background_continuation = $false
            automatic_fallback = $false
            consumed = $false
        }
        foreach ($entry in $activeBooleanValues.GetEnumerator()) {
            $actual = Get-RequiredBoolean -Object $permit -Name $entry.Key -ValidationCode ('MANUAL_PERMIT_' + $entry.Key.ToUpperInvariant() + '_BOOLEAN_INVALID')
            Assert-Route ($actual -eq [bool]$entry.Value) ('MANUAL_PERMIT_' + $entry.Key.ToUpperInvariant() + '_INVALID')
        }
        Assert-Route ([int](Get-OptionalProperty $permit 'schema_version' 0) -eq 2) 'MANUAL_PERMIT_SCHEMA_INVALID'
        Assert-Route ([int](Get-OptionalProperty $permit 'default_auxiliaries_max' 0) -eq 1) 'SOL_ADVISOR_DEFAULT_AUXILIARY_LIMIT_INVALID'
        Assert-Route ([int](Get-OptionalProperty $permit 'max_fresh_sol_reviewers' 0) -eq 1) 'SOL_ADVISOR_FRESH_REVIEWER_LIMIT_INVALID'
    }
    Assert-Route ([string](Get-OptionalProperty $permit 'state' '') -eq 'ACTIVE') 'CODEX_USAGE_LOCKED'
    Assert-Route ([string](Get-OptionalProperty $permit 'origin' '') -eq 'manual_user') 'MANUAL_USER_ORIGIN_REQUIRED'
    Assert-Route ([bool](Get-OptionalProperty $permit 'manual_interactive' $false)) 'MANUAL_INTERACTIVE_APPROVAL_REQUIRED'
    Assert-Route ([int](Get-OptionalProperty $permit 'max_processes' 0) -eq 1) 'MANUAL_PERMIT_PROCESS_LIMIT_INVALID'
    if ($policyId -eq 'TOKEN-OPT-001-A6') {
        Assert-Route ([int](Get-OptionalProperty $permit 'max_children' -1) -eq 0) 'MANUAL_PERMIT_CHILD_LIMIT_INVALID'
        Assert-Route (-not [bool](Get-OptionalProperty $permit 'allow_subagents' $true)) 'SUBAGENTS_DISABLED'
    }
    elseif ($policyId -eq 'TOKEN-OPT-001-A7') {
        Assert-Route ([int](Get-OptionalProperty $permit 'default_children' -1) -eq 0) 'MANUAL_PERMIT_DEFAULT_CHILDREN_INVALID'
        Assert-Route ([int](Get-OptionalProperty $permit 'max_children' -1) -eq 16) 'MANUAL_PERMIT_CHILD_LIMIT_INVALID'
        Assert-Route ([bool](Get-OptionalProperty $permit 'allow_subagents' $false)) 'SUBAGENTS_MUST_BE_AVAILABLE'
        Assert-Route ([int](Get-OptionalProperty $permit 'max_delegation_depth' 0) -eq 1) 'DELEGATION_DEPTH_INVALID'
        Assert-Route (-not [bool](Get-OptionalProperty $permit 'recursive_spawning' $true)) 'RECURSIVE_SPAWNING_DISABLED'
    }
    else {
        Assert-Route (-not [bool](Get-OptionalProperty $permit 'sol_subagents_allowed' $true)) 'SOL_SUBAGENTS_PROHIBITED'
        Assert-Route ([int](Get-OptionalProperty $permit 'max_luna_max_subagents' 0) -eq 16) 'LUNA_MAX_SUBAGENT_LIMIT_INVALID'
        Assert-Route ([int](Get-OptionalProperty $permit 'max_terra_max_subagents' 0) -eq 2) 'TERRA_MAX_SUBAGENT_LIMIT_INVALID'
        Assert-Route ([int](Get-OptionalProperty $permit 'max_ox_alpha_subagents' 0) -eq 16) 'OX_ALPHA_SUBAGENT_LIMIT_INVALID'
        Assert-Route ([int](Get-OptionalProperty $permit 'max_total_direct_subagents' 0) -eq 16) 'TOTAL_DIRECT_SUBAGENT_LIMIT_INVALID'
        Assert-Route ([bool](Get-OptionalProperty $permit 'allow_subagents' $false)) 'SUBAGENTS_MUST_BE_AVAILABLE'
        Assert-Route ([int](Get-OptionalProperty $permit 'max_delegation_depth' 0) -eq 1) 'DELEGATION_DEPTH_INVALID'
        Assert-Route (-not [bool](Get-OptionalProperty $permit 'recursive_spawning' $true)) 'RECURSIVE_SPAWNING_DISABLED'
    }
    Assert-Route (-not [bool](Get-OptionalProperty $permit 'background_continuation' $true)) 'BACKGROUND_CONTINUATION_DISABLED'
    Assert-Route (-not [bool](Get-OptionalProperty $permit 'automatic_fallback' $true)) 'AUTOMATIC_FALLBACK_DISABLED'
    Assert-Route (-not [bool](Get-OptionalProperty $permit 'consumed' $true)) 'MANUAL_PERMIT_ALREADY_CONSUMED'

    $approvalId = [string](Get-OptionalProperty $Request 'approval_id' '')
    Assert-Route (-not [string]::IsNullOrWhiteSpace($approvalId)) 'MANUAL_PERMIT_APPROVAL_MISMATCH'
    Assert-Route ($approvalId -eq [string](Get-OptionalProperty $permit 'approval_id' '')) 'MANUAL_PERMIT_APPROVAL_MISMATCH'
    $requestedPurpose = [string](Get-OptionalProperty $Request 'purpose' '')
    Assert-Route (-not [string]::IsNullOrWhiteSpace($requestedPurpose)) 'MANUAL_PERMIT_PURPOSE_MISMATCH'
    Assert-Route ($requestedPurpose -eq [string](Get-OptionalProperty $permit 'purpose' '')) 'MANUAL_PERMIT_PURPOSE_MISMATCH'
    $allowedRoles = @((Get-OptionalProperty $permit 'allowed_roles' @()) | ForEach-Object { [string]$_ })
    if ($policyId -eq 'SOL-ADVISOR-GLOBAL-001') {
        Assert-Route ($allowedRoles.Count -eq 1 -and $allowedRoles[0] -in @('orchestrator','writer','reviewer')) 'MANUAL_PERMIT_ROLE_MISMATCH'
    }
    Assert-Route ($allowedRoles -contains $Role) 'MANUAL_PERMIT_ROLE_MISMATCH'
    Assert-Route ([string](Get-OptionalProperty $permit 'allowed_role' '') -eq $Role) 'MANUAL_PERMIT_ROLE_MISMATCH'
    $allowedModel = [string](Get-OptionalProperty $permit 'allowed_model' '')
    $allowedReasoning = [string](Get-OptionalProperty $permit 'allowed_reasoning' '')
    Assert-Route ($allowedModel -notin @('', 'default', '*')) 'MANUAL_PERMIT_MODEL_MISMATCH'
    Assert-Route ($allowedReasoning -notin @('', 'default', '*')) 'MANUAL_PERMIT_REASONING_MISMATCH'
    if ($policyId -eq 'SOL-ADVISOR-GLOBAL-001' -and $Role -eq 'reviewer') {
        Assert-Route ($allowedModel -eq 'gpt-5.6-sol' -and $allowedReasoning -eq 'high') 'MANUAL_PERMIT_REVIEWER_CONTRACT_INVALID'
    }
    $expiresText = [string](Get-OptionalProperty $permit 'expires_at' '')
    try { $expiresAt = [DateTimeOffset]::Parse($expiresText, [Globalization.CultureInfo]::InvariantCulture) }
    catch { throw "ROUTE_VALIDATION: MANUAL_PERMIT_INVALID" }
    Assert-Route ($expiresAt -gt [DateTimeOffset]::UtcNow) 'MANUAL_PERMIT_EXPIRED'
    return $permit
}

function Assert-ManualSelectedRoute {
    param($Permit, $Request, [string]$SelectedModel, [string]$SelectedEffort, [string]$FallbackReason)
    Assert-Route ([string]::IsNullOrWhiteSpace($FallbackReason)) 'AUTOMATIC_FALLBACK_DISABLED'
    Assert-Route ([string](Get-OptionalProperty $Permit 'allowed_model' '') -eq $SelectedModel) 'MANUAL_PERMIT_MODEL_MISMATCH'
    Assert-Route ([string](Get-OptionalProperty $Permit 'allowed_reasoning' '') -eq $SelectedEffort) 'MANUAL_PERMIT_REASONING_MISMATCH'
    $requestedModel = [string](Get-OptionalProperty $Request 'requested_model' '')
    if (-not [string]::IsNullOrWhiteSpace($requestedModel)) {
        Assert-Route ($requestedModel -eq $SelectedModel) 'MANUAL_PERMIT_MODEL_MISMATCH'
    }
}

function Write-JsonAtomic {
    param([string]$Path, $Value)
    $fullPath = [IO.Path]::GetFullPath($Path)
    $parent = Split-Path -Parent $fullPath
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    $tempPath = Join-Path $parent ('.token-opt-route-' + [Guid]::NewGuid().ToString('N') + '.tmp')
    try {
        $text = ($Value | ConvertTo-Json -Depth 30) + "`n"
        [IO.File]::WriteAllText($tempPath, $text, [Text.UTF8Encoding]::new($false))
        Move-Item -Force -LiteralPath $tempPath -Destination $fullPath
    }
    finally {
        if (Test-Path -LiteralPath $tempPath) {
            Remove-Item -Force -LiteralPath $tempPath
        }
    }
}

function Get-StringSha256 {
    param([string]$Value)
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        (($sha.ComputeHash([Text.UTF8Encoding]::new($false).GetBytes($Value)) | ForEach-Object { $_.ToString('x2') }) -join '')
    }
    finally {
        $sha.Dispose()
    }
}

function Get-Integer {
    param($Value, [string]$Label)
    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) {
        return 0
    }
    $parsed = 0
    Assert-Route ([int]::TryParse([string]$Value, [ref]$parsed)) "$Label must be an integer"
    Assert-Route ($parsed -ge 0) "$Label must be non-negative"
    return $parsed
}

function Get-RequiredBoolean {
    param($Object, [string]$Name, [string]$ValidationCode)
    Assert-Route ($null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name) $ValidationCode
    $value = $Object.$Name
    Assert-Route ($value -is [bool]) $ValidationCode
    return $value
}

function Assert-SolAdvisorRouteTopology {
    param($Request, [string]$Role, [string]$RouteMode)

    $requestedLuna = Get-Integer -Value (Get-OptionalProperty $Request 'requested_luna_max_subagents' 0) -Label 'requested_luna_max_subagents'
    $requestedTerra = Get-Integer -Value (Get-OptionalProperty $Request 'requested_terra_max_subagents' 0) -Label 'requested_terra_max_subagents'
    $requestedOx = Get-Integer -Value (Get-OptionalProperty $Request 'requested_ox_alpha_subagents' 0) -Label 'requested_ox_alpha_subagents'
    $requestedSol = Get-Integer -Value (Get-OptionalProperty $Request 'requested_sol_subagents' 0) -Label 'requested_sol_subagents'
    $requestedReviewer = Get-Integer -Value (Get-OptionalProperty $Request 'requested_sol_reviewer_auxiliaries' 0) -Label 'requested_sol_reviewer_auxiliaries'
    $requestedImplementation = $requestedLuna + $requestedTerra + $requestedOx
    $requestedTotal = $requestedImplementation + $requestedSol + $requestedReviewer

    Assert-Route ($requestedSol -eq 0) 'SOL_SUBAGENTS_PROHIBITED'
    Assert-Route ($requestedTotal -le 1) 'SOL_ADVISOR_ONE_AUXILIARY_DEFAULT_EXCEEDED'
    $subagentRequested = [bool](Get-OptionalProperty $Request 'subagent_requested' ($requestedTotal -gt 0))
    Assert-Route (($requestedTotal -gt 0) -eq $subagentRequested) 'SUBAGENT_REQUEST_COUNT_MISMATCH'

    switch ($RouteMode) {
        'solo' {
            Assert-Route ($Role -eq 'orchestrator' -and $requestedTotal -eq 0) 'SOL_ADVISOR_SOLO_AUXILIARY_COUNT_INVALID'
        }
        'delegate' {
            Assert-Route ($Role -eq 'writer' -and $requestedImplementation -eq 1 -and $requestedReviewer -eq 0) 'SOL_ADVISOR_DELEGATE_IMPLEMENTATION_AUXILIARY_REQUIRED'
        }
        'audit' {
            Assert-Route ($Role -eq 'reviewer' -and $requestedImplementation -eq 0 -and $requestedReviewer -eq 1) 'SOL_ADVISOR_AUDIT_REVIEWER_AUXILIARY_REQUIRED'
        }
        'full' {
            if ($Role -eq 'writer') {
                Assert-Route ($requestedImplementation -eq 1 -and $requestedReviewer -eq 0) 'SOL_ADVISOR_FULL_WRITER_IMPLEMENTATION_AUXILIARY_REQUIRED'
            }
            elseif ($Role -eq 'reviewer') {
                Assert-Route ($requestedImplementation -eq 0 -and $requestedReviewer -eq 1) 'SOL_ADVISOR_FULL_REVIEWER_AUXILIARY_REQUIRED'
            }
            else {
                Assert-Route $false 'SOL_ADVISOR_FULL_ROLE_INVALID'
            }
        }
    }
}

function Test-ExactZero {
    param($Value)
    if ($null -eq $Value) { return $false }
    $parsed = [decimal]0
    if (-not [decimal]::TryParse(
            [string]$Value,
            [Globalization.NumberStyles]::Number,
            [Globalization.CultureInfo]::InvariantCulture,
            [ref]$parsed)) {
        return $false
    }
    return $parsed -eq [decimal]0
}

function Get-ModelEfforts {
    param($Model)
    @($Model.supported_reasoning_levels | ForEach-Object {
        if ($_ -is [string]) { [string]$_ } else { [string]$_.effort }
    } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Get-ModelById {
    param($Catalog, [string]$ModelId)
    @($Catalog.models | Where-Object { [string]$_.slug -eq $ModelId }) | Select-Object -First 1
}

function Get-HistoricalCompatibility {
    param($Profile)
    if ([int]$Profile.schema_version -ge 5) {
        return [pscustomobject]@{
            Roles = $Profile.historical_roles
            ActiveRoles = $Profile.historical_active_roles
            Fallbacks = $Profile.historical_fallbacks
        }
    }
    return [pscustomobject]@{
        Roles = $Profile.roles
        ActiveRoles = $Profile.active_roles
        Fallbacks = $Profile.fallbacks
    }
}

function Assert-CatalogContract {
    param($Profile, $Catalog, [string]$ExecutionPolicyId)
    $requiredModels = if ($ExecutionPolicyId -eq 'SOL-ADVISOR-GLOBAL-001') {
        @($Profile.catalog.required_models)
    }
    else {
        $historical = Get-HistoricalCompatibility -Profile $Profile
        @(
            [pscustomobject]@{ id = [string]$historical.Roles.orchestrator.model; effort = [string]$historical.Roles.orchestrator.reasoning_effort },
            [pscustomobject]@{ id = [string]$historical.Roles.writer.model; effort = [string]$historical.Roles.writer.reasoning_effort },
            [pscustomobject]@{ id = [string]$historical.Roles.read_only_worker.durable.model; effort = [string]$historical.Roles.read_only_worker.durable.reasoning_effort },
            [pscustomobject]@{ id = [string]$historical.Roles.read_only_worker.ephemeral.model; effort = [string]$historical.Roles.read_only_worker.ephemeral.reasoning_effort }
        )
    }
    foreach ($required in $requiredModels) {
        $id = [string]$required.id
        $model = Get-ModelById -Catalog $Catalog -ModelId $id
        Assert-Route ($null -ne $model) "catalog does not contain required model $id"
        Assert-Route ((Get-ModelEfforts -Model $model) -contains [string]$required.effort) "catalog does not support $($required.effort) for $id"
    }

    $disabled = @($Profile.catalog.disabled_models | ForEach-Object { [string]$_ })
    if ($ExecutionPolicyId -ne 'SOL-ADVISOR-GLOBAL-001') {
        $historical = Get-HistoricalCompatibility -Profile $Profile
        if ([int]$Profile.schema_version -ge 3) {
            $activeModels = @(
                [string]$historical.ActiveRoles.orchestrator.model,
                [string]$historical.ActiveRoles.writers.backend_primary.model,
                [string]$historical.ActiveRoles.writers.integration_fallback.model,
                [string]$historical.ActiveRoles.writers.hau_frontend.model,
                [string]$historical.ActiveRoles.read_only_workers.luna.model,
                [string]$historical.ActiveRoles.read_only_workers.ox.model
            ) + @($historical.Fallbacks.active | ForEach-Object { [string]$_ })
        }
        else {
            $activeModels = @(
                [string]$historical.Roles.orchestrator.model,
                [string]$historical.Roles.writer.model,
                [string]$historical.Roles.read_only_worker.durable.model,
                [string]$historical.Roles.read_only_worker.ephemeral.model
            ) + @($historical.Fallbacks.ox | ForEach-Object { [string]$_ })
        }
    }
    elseif ([int]$Profile.schema_version -ge 5) {
        $activeModels = @(
            [string]$Profile.sol_advisor.native_roles.luna_implementer.model,
            [string]$Profile.sol_advisor.native_roles.terra_implementer.model,
            [string]$Profile.sol_advisor.native_roles.sol_reviewer.model
        )
        if ([string](Get-OptionalProperty $Profile.ox_overlay 'status' '') -eq 'ENABLED') {
            $overlay = Get-ModelById -Catalog $Catalog -ModelId ([string]$Profile.ox_overlay.model)
            Assert-Route ($null -ne $overlay) 'OX_OVERLAY_MODEL_UNAVAILABLE'
            Assert-Route ((Get-ModelEfforts -Model $overlay) -contains [string]$Profile.ox_overlay.reasoning_effort) 'OX_OVERLAY_REASONING_UNAVAILABLE'
            $activeModels += [string]$Profile.ox_overlay.model
        }
    }
    elseif ([int]$Profile.schema_version -ge 3) {
        $activeModels = @(
            [string]$Profile.active_roles.orchestrator.model,
            [string]$Profile.active_roles.writers.backend_primary.model,
            [string]$Profile.active_roles.writers.integration_fallback.model,
            [string]$Profile.active_roles.writers.hau_frontend.model,
            [string]$Profile.active_roles.read_only_workers.luna.model,
            [string]$Profile.active_roles.read_only_workers.ox.model
        ) + @($Profile.fallbacks.active | ForEach-Object { [string]$_ })
    }
    else {
        $activeModels = @(
            [string]$Profile.roles.orchestrator.model,
            [string]$Profile.roles.writer.model,
            [string]$Profile.roles.read_only_worker.durable.model,
            [string]$Profile.roles.read_only_worker.ephemeral.model
        ) + @($Profile.fallbacks.ox | ForEach-Object { [string]$_ })
    }
    foreach ($id in $activeModels) {
        Assert-Route ($id -notin $disabled) "disabled model appears in active or fallback routing: $id"
    }
}

function Get-RunState {
    param([string]$Path, [string]$RunId)
    $state = $null
    if (-not [string]::IsNullOrWhiteSpace($Path) -and (Test-Path -LiteralPath $Path -PathType Leaf)) {
        try { $state = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json } catch { throw "ROUTE_VALIDATION: state is not valid JSON: $Path" }
    }
    if ($null -eq $state -or [string](Get-OptionalProperty $state 'run_id' '') -ne $RunId) {
        $state = [pscustomobject]@{
            schema_version = 1
            run_id = $RunId
            ox = [pscustomobject]@{
                eligible = $false
                failed = $false
                failure_count = 0
                checked_at = $null
                reason = 'UNVERIFIED'
            }
            ordinary_work_keys = @()
        }
    }
    if ($null -eq (Get-OptionalProperty $state 'ox' $null)) {
        Set-ObjectProperty -Object $state -Name 'ox' -Value ([pscustomobject]@{ eligible = $false; failed = $false; failure_count = 0; checked_at = $null; reason = 'UNVERIFIED' })
    }
    if ($null -eq (Get-OptionalProperty $state 'ordinary_work_keys' $null)) {
        Set-ObjectProperty -Object $state -Name 'ordinary_work_keys' -Value @()
    }
    return $state
}

function Test-FreshOxCache {
    param($OxState, [int]$CadenceSeconds)
    $value = [string](Get-OptionalProperty $OxState 'checked_at' '')
    if ([string]::IsNullOrWhiteSpace($value)) { return $false }
    try {
        $checked = [datetime]::Parse($value, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::RoundtripKind).ToUniversalTime()
        return (((Get-Date).ToUniversalTime() - $checked).TotalSeconds -ge 0 -and ((Get-Date).ToUniversalTime() - $checked).TotalSeconds -le $CadenceSeconds)
    }
    catch { return $false }
}

function Get-OxEligibility {
    param($Profile, $Request, $State, [string]$ExecutionPolicyId)
    $oxState = $State.ox
    $isCurrentSolPolicy = $ExecutionPolicyId -eq 'SOL-ADVISOR-GLOBAL-001'
    if (-not $isCurrentSolPolicy) {
        if ([bool](Get-OptionalProperty $oxState 'failed' $false)) {
            return [pscustomobject]@{ Eligible = $false; Reason = 'OX_PREVIOUS_FAILURE'; Cached = $true }
        }
        if (Test-FreshOxCache -OxState $oxState -CadenceSeconds ([int]$Profile.ox_eligibility.cache_cadence_seconds)) {
            return [pscustomobject]@{
                Eligible = [bool](Get-OptionalProperty $oxState 'eligible' $false)
                Reason = 'OX_CACHED_' + [string](Get-OptionalProperty $oxState 'reason' 'UNVERIFIED')
                Cached = $true
            }
        }
    }

    $observation = Get-OptionalProperty $Request 'provider_observation' $null
    if ($isCurrentSolPolicy) {
        $providerAvailable = Get-RequiredBoolean -Object $observation -Name 'provider_available' -ValidationCode 'OX_PROVIDER_AVAILABLE_BOOLEAN_REQUIRED'
        $callable = Get-RequiredBoolean -Object $observation -Name 'callable' -ValidationCode 'OX_CALLABLE_BOOLEAN_REQUIRED'
        $billingUnambiguous = Get-RequiredBoolean -Object $observation -Name 'billing_unambiguous' -ValidationCode 'OX_BILLING_UNAMBIGUOUS_BOOLEAN_REQUIRED'
        $capabilitiesOk = Get-RequiredBoolean -Object $observation -Name 'capabilities_present' -ValidationCode 'OX_CAPABILITIES_PRESENT_BOOLEAN_REQUIRED'
        $promptZero = Test-ExactZero (Get-OptionalProperty $observation 'prompt_price' $null)
        $completionZero = Test-ExactZero (Get-OptionalProperty $observation 'completion_price' $null)
        $health = [string](Get-OptionalProperty $observation 'health' '')
        $healthOk = @($Profile.ox_eligibility.acceptable_health | ForEach-Object { [string]$_ }) -contains $health.ToLowerInvariant()
        $dataClassification = [string](Get-OptionalProperty $Request 'data_classification' '')
        $dataOk = @($Profile.ox_eligibility.allowed_data_classifications | ForEach-Object { [string]$_ }) -contains $dataClassification.ToLowerInvariant()
        $observedModel = [string](Get-OptionalProperty $observation 'model' '')
        $identityOk = $observedModel -eq [string]$Profile.ox_overlay.model
        $eligible = $identityOk -and $callable -and $providerAvailable -and $promptZero -and $completionZero -and $billingUnambiguous -and $healthOk -and $capabilitiesOk -and $dataOk
        $reason = if (-not $identityOk) { 'OX_RUNTIME_IDENTITY_UNVERIFIED' }
            elseif (-not $callable) { 'OX_NOT_CALLABLE' }
            elseif (-not $providerAvailable) { 'PROVIDER_UNAVAILABLE' }
            elseif (-not $promptZero -or -not $completionZero) { 'PRICE_NOT_EXACTLY_ZERO' }
            elseif (-not $billingUnambiguous) { 'BILLING_AMBIGUOUS' }
            elseif (-not $healthOk) { 'HEALTH_UNACCEPTABLE' }
            elseif (-not $capabilitiesOk) { 'CAPABILITIES_UNAVAILABLE' }
            elseif (-not $dataOk) { 'DATA_CLASSIFICATION_UNSUITABLE' }
            else { 'ELIGIBLE' }
    }
    else {
        $providerAvailable = [bool](Get-OptionalProperty $observation 'provider_available' $false)
        $promptZero = Test-ExactZero (Get-OptionalProperty $observation 'prompt_price' $null)
        $completionZero = Test-ExactZero (Get-OptionalProperty $observation 'completion_price' $null)
        $health = [string](Get-OptionalProperty $observation 'health' '')
        $healthOk = @($Profile.ox_eligibility.acceptable_health | ForEach-Object { [string]$_ }) -contains $health.ToLowerInvariant()
        $dataClassification = [string](Get-OptionalProperty $Request 'data_classification' '')
        $dataOk = @($Profile.ox_eligibility.allowed_data_classifications | ForEach-Object { [string]$_ }) -contains $dataClassification.ToLowerInvariant()
        $eligible = $providerAvailable -and $promptZero -and $completionZero -and $healthOk -and $dataOk
        $reason = if (-not $providerAvailable) { 'PROVIDER_UNAVAILABLE' }
            elseif (-not $promptZero -or -not $completionZero) { 'PRICE_NOT_EXACTLY_ZERO' }
            elseif (-not $healthOk) { 'HEALTH_UNACCEPTABLE' }
            elseif (-not $dataOk) { 'DATA_CLASSIFICATION_UNSUITABLE' }
            else { 'ELIGIBLE' }
    }

    Set-ObjectProperty -Object $oxState -Name 'eligible' -Value $eligible
    Set-ObjectProperty -Object $oxState -Name 'checked_at' -Value ((Get-Date).ToUniversalTime().ToString('o'))
    Set-ObjectProperty -Object $oxState -Name 'reason' -Value $reason
    return [pscustomobject]@{ Eligible = $eligible; Reason = $reason; Cached = $false }
}

function Get-VerificationReuse {
    param($Request, [string]$ReceiptPath)
    $fingerprints = Get-OptionalProperty $Request 'verification_fingerprints' $null
    if ($null -eq $fingerprints) {
        return [pscustomobject]@{ State = 'UNVERIFIED'; Invalidators = @('NO_FINGERPRINTS') }
    }
    $fields = @('source', 'configuration', 'test', 'dependency', 'external_state')
    foreach ($field in $fields) {
        $value = [string](Get-OptionalProperty $fingerprints $field '')
        if ($value -notmatch '^[a-f0-9]{64}$') {
            return [pscustomobject]@{ State = 'REVERIFY'; Invalidators = @("INVALID_$($field.ToUpperInvariant())_FINGERPRINT") }
        }
    }
    if ([string]::IsNullOrWhiteSpace($ReceiptPath) -or -not (Test-Path -LiteralPath $ReceiptPath -PathType Leaf)) {
        return [pscustomobject]@{ State = 'REVERIFY'; Invalidators = @('NO_RECEIPT') }
    }
    try { $receipt = Get-Content -LiteralPath $ReceiptPath -Raw | ConvertFrom-Json } catch { return [pscustomobject]@{ State = 'REVERIFY'; Invalidators = @('INVALID_RECEIPT') } }
    if ([string](Get-OptionalProperty $receipt 'status' '') -ne 'PASS') {
        return [pscustomobject]@{ State = 'REVERIFY'; Invalidators = @('PRIOR_STATUS_NOT_PASS') }
    }
    $invalidators = @()
    foreach ($field in $fields) {
        if ([string](Get-OptionalProperty $receipt.fingerprints $field '') -ne [string](Get-OptionalProperty $fingerprints $field '')) {
            $invalidators += "CHANGED_$($field.ToUpperInvariant())"
        }
    }
    if ($invalidators.Count -gt 0) {
        return [pscustomobject]@{ State = 'REVERIFY'; Invalidators = $invalidators }
    }
    return [pscustomobject]@{ State = 'REUSE'; Invalidators = @() }
}

function Get-MaterialFindings {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return @() }
    $input = Read-JsonRequired -Path $Path -Label 'findings input'
    $findings = if ($input.PSObject.Properties.Name -contains 'findings') { @($input.findings) } else { @($input) }
    $seen = @{}
    $result = [Collections.Generic.List[object]]::new()
    foreach ($finding in $findings) {
        $severity = [string](Get-OptionalProperty $finding 'severity' '')
        $material = [bool](Get-OptionalProperty $finding 'material' $false) -or $severity.ToLowerInvariant() -in @('critical', 'high', 'blocker')
        if (-not $material) { continue }
        $id = [string](Get-OptionalProperty $finding 'id' '')
        $keySource = if (-not [string]::IsNullOrWhiteSpace($id)) { $id } else {
            ([string](Get-OptionalProperty $finding 'category' '')) + '|' +
            ([string](Get-OptionalProperty $finding 'path' '')) + '|' +
            ([string](Get-OptionalProperty $finding 'line' '')) + '|' +
            ([string](Get-OptionalProperty $finding 'message' ''))
        }
        $key = Get-StringSha256 $keySource
        if (-not $seen.ContainsKey($key)) {
            $seen[$key] = $true
            $result.Add($finding)
        }
    }
    return @($result)
}

function Write-RouteTelemetry {
    param([string]$Path, $Record)
    if ([string]::IsNullOrWhiteSpace($Path)) { return $false }
    $fullPath = [IO.Path]::GetFullPath($Path)
    $parent = Split-Path -Parent $fullPath
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    [IO.File]::AppendAllText($fullPath, (($Record | ConvertTo-Json -Compress -Depth 12) + "`n"), [Text.UTF8Encoding]::new($false))
    return $true
}

$profile = Read-JsonRequired -Path $ProfilePath -Label 'routing profile'
$catalog = Read-JsonRequired -Path $CatalogPath -Label 'model catalog'
$executionGate = Get-ManualExecutionGate -Path $ExecutionGatePath
$executionPolicyId = [string](Get-OptionalProperty $executionGate 'policy_id' '')
$request = Read-JsonRequired -Path $RequestPath -Label 'route request'
Assert-Route ([int]$profile.schema_version -in @(1, 2, 3, 4, 5)) 'unsupported routing profile schema'
Assert-CatalogContract -Profile $profile -Catalog $catalog -ExecutionPolicyId $executionPolicyId

$role = [string](Get-OptionalProperty $request 'role' '')
Assert-Route ($role -in @('orchestrator', 'writer', 'reviewer', 'read_only_worker')) 'role must be orchestrator, writer, reviewer, or read_only_worker'
$requestedModel = [string](Get-OptionalProperty $request 'requested_model' '')
$routeMode = if ($executionPolicyId -eq 'SOL-ADVISOR-GLOBAL-001') { [string](Get-OptionalProperty $request 'route_mode' '') } else { 'historical' }
    if ($executionPolicyId -eq 'SOL-ADVISOR-GLOBAL-001') {
        Assert-Route ($routeMode -in @($profile.sol_advisor.modes | ForEach-Object { [string]$_ })) 'SOL_ADVISOR_ROUTE_MODE_INVALID'
        if ($routeMode -eq 'solo') { Assert-Route ($role -eq 'orchestrator') 'SOL_ADVISOR_SOLO_ROLE_INVALID' }
        elseif ($routeMode -eq 'delegate') { Assert-Route ($role -eq 'writer') 'SOL_ADVISOR_DELEGATE_ROLE_INVALID' }
        elseif ($routeMode -eq 'audit') { Assert-Route ($role -eq 'reviewer') 'SOL_ADVISOR_AUDIT_ROLE_INVALID' }
        else { Assert-Route ($role -in @('writer', 'reviewer')) 'SOL_ADVISOR_FULL_ROLE_INVALID' }
        Assert-SolAdvisorRouteTopology -Request $request -Role $role -RouteMode $routeMode
    }
$acceptanceGreen = [bool](Get-OptionalProperty $request 'acceptance_green' $false)
Assert-Route ($requestedModel -notin @($profile.catalog.disabled_models | ForEach-Object { [string]$_ })) "requested model is disabled: $requestedModel"

$seedTokens = Get-Integer -Value (Get-OptionalProperty $request 'dispatch_seed_tokens' 0) -Label 'dispatch_seed_tokens'
$workingTokens = Get-Integer -Value (Get-OptionalProperty $request 'worker_working_tokens' 0) -Label 'worker_working_tokens'
$contextTokens = Get-Integer -Value (Get-OptionalProperty $request 'context_tokens' $workingTokens) -Label 'context_tokens'
Assert-Route ($seedTokens -le [int]$profile.context_envelope.dispatch_seed_tokens_max) 'dispatch seed exceeds 12K envelope'
Assert-Route ($workingTokens -le [int]$profile.context_envelope.worker_working_tokens_max) 'worker working context exceeds 32K envelope'
if ($contextTokens -gt [int]$profile.context_envelope.normal_hard_ceiling_tokens) {
    Assert-Route (-not [string]::IsNullOrWhiteSpace([string](Get-OptionalProperty $request 'oversize_context_reason' ''))) 'OVERSIZE_CONTEXT_REASON is required above 64K'
}
if ($contextTokens -gt [int]$profile.context_envelope.split_or_exception_threshold_tokens) {
    $splitPlan = [string](Get-OptionalProperty $request 'split_plan' '')
    $exception = [string](Get-OptionalProperty $request 'oversize_exception_type' '')
    Assert-Route ((-not [string]::IsNullOrWhiteSpace($splitPlan)) -or ($exception -in @($profile.context_envelope.exception_types))) 'context above 100K requires a split plan or correctness/safety exception'
}

$recursionDepth = Get-Integer -Value (Get-OptionalProperty $request 'recursion_depth' 0) -Label 'recursion_depth'
if ($executionPolicyId -eq 'TOKEN-OPT-001-A6') {
    Assert-Route ($recursionDepth -eq 0) 'recursive worker spawning is disabled'
}
else {
    Assert-Route ($recursionDepth -le 1) 'DELEGATION_DEPTH_EXCEEDED'
}
Assert-Route (-not [bool](Get-OptionalProperty $request 'spawned_by_worker' $false)) 'worker-originated recursive dispatch is disabled'
$activeWriters = Get-Integer -Value (Get-OptionalProperty $request 'active_writers' 0) -Label 'active_writers'
$activeReadOnly = Get-Integer -Value (Get-OptionalProperty $request 'active_read_only_workers' 0) -Label 'active_read_only_workers'
$activeTotal = Get-Integer -Value (Get-OptionalProperty $request 'active_total_workers' 0) -Label 'active_total_workers'
$manualPermit = $null
if (-not $acceptanceGreen) {
    $manualPermit = Assert-ManualExecutionPreconditions -Gate $executionGate -Request $request -Role $role -ActiveWriters $activeWriters -ActiveReadOnly $activeReadOnly -ActiveTotal $activeTotal -PermitPath $ManualPermitPath
}
$prospective = 1
if ($role -eq 'writer') {
    if ($executionPolicyId -eq 'TOKEN-OPT-001-A6') {
        Assert-Route (($activeWriters + $prospective) -le [int]$profile.concurrency.max_overlapping_writers) 'one overlapping Terra writer maximum exceeded'
    }
    else {
        Assert-Route (($activeWriters + $prospective) -le [int]$profile.concurrency.max_active_writers_account_wide) 'ACCOUNT_WRITER_LIMIT_EXCEEDED'
    }
}
Assert-Route (($activeTotal + $prospective) -le [int]$profile.concurrency.independent_burst_total_workers_max) 'total worker capacity exceeded'
if ($role -eq 'read_only_worker' -and -not [bool](Get-OptionalProperty $request 'independent_burst' $false)) {
    Assert-Route (($activeReadOnly + $prospective) -le [int]$profile.concurrency.adaptive_read_only_workers_max) 'adaptive read-only worker capacity exceeded'
}

$runId = [string](Get-OptionalProperty $request 'run_id' 'default')
if ([string]::IsNullOrWhiteSpace($runId)) { $runId = 'default' }
$state = Get-RunState -Path $StatePath -RunId $runId
$workKey = [string](Get-OptionalProperty $request 'ordinary_work_key' '')
if (-not [string]::IsNullOrWhiteSpace($workKey)) {
    Assert-Route ($workKey -notin @($state.ordinary_work_keys)) 'duplicate ordinary work is prohibited'
    Set-ObjectProperty -Object $state -Name 'ordinary_work_keys' -Value @(@($state.ordinary_work_keys) + $workKey | Sort-Object -Unique)
}

$verificationReuse = Get-VerificationReuse -Request $request -ReceiptPath $VerificationReceiptPath
$taskId = [string](Get-OptionalProperty $request 'task_id' '')
$sliceFingerprint = [string](Get-OptionalProperty $request 'accepted_slice_fingerprint' '')
if ($sliceFingerprint -notmatch '^[a-f0-9]{64}$') { $sliceFingerprint = Get-StringSha256 $taskId }

if ($acceptanceGreen) {
    if (-not [string]::IsNullOrWhiteSpace($StatePath)) { Write-JsonAtomic -Path $StatePath -Value $state }
    $stopResult = [ordered]@{
        schema_version = 1
        action = 'STOP'
        reason = 'STOP_WHEN_GREEN'
        verification_reuse = $verificationReuse
        selected_model = $null
        execution_boundary = [ordered]@{ policy_id = $executionPolicyId; state = 'LOCKED_NO_EXECUTION'; manual_only = $true; dispatcher = $false }
    }
    $null = Write-RouteTelemetry -Path $TelemetryPath -Record ([ordered]@{
        schema_version = 1; observed_at = (Get-Date).ToUniversalTime().ToString('o'); accepted_slice_fingerprint = $sliceFingerprint
        action = 'STOP'; reason = 'STOP_WHEN_GREEN'; role = $role; selected_model = $null; fallback_reason = $null
        verification_reuse = $verificationReuse.State; native_weighted_quota = $null; quality_evidence = 'UNOBSERVED'
    })
    $stopResult | ConvertTo-Json -Depth 12
    exit 0
}

$selectedModel = $null
$selectedEffort = $null
$contract = $null
$fallbackReason = $null
$overlayResolution = 'NOT_APPLICABLE'
$oxEligibility = [pscustomobject]@{ Eligible = $false; Reason = 'NOT_REQUESTED'; Cached = $false }
if ($executionPolicyId -eq 'TOKEN-OPT-001-A6') {
    $historical = Get-HistoricalCompatibility -Profile $profile
    if ($role -eq 'orchestrator') {
        $selectedModel = [string]$historical.Roles.orchestrator.model
        $selectedEffort = [string]$historical.Roles.orchestrator.reasoning_effort
    }
    elseif ($role -eq 'writer') {
        Assert-Route ([string]::IsNullOrWhiteSpace($requestedModel) -or $requestedModel -eq [string]$historical.Roles.writer.model) 'writer route is Terra only'
        $selectedModel = [string]$historical.Roles.writer.model
        $selectedEffort = [string]$historical.Roles.writer.reasoning_effort
        $contract = [string]$historical.Roles.writer.contract
    }
    else {
        $preferOx = [bool](Get-OptionalProperty $request 'prefer_ephemeral' $false) -or $requestedModel -eq [string]$historical.Roles.read_only_worker.ephemeral.model
        Assert-Route ([string]::IsNullOrWhiteSpace($requestedModel) -or $requestedModel -in @([string]$historical.Roles.read_only_worker.durable.model, [string]$historical.Roles.read_only_worker.ephemeral.model)) 'read-only worker model is not allowed by the shared contract'
        if ($preferOx) {
            $oxEligibility = Get-OxEligibility -Profile $profile -Request $request -State $state -ExecutionPolicyId $executionPolicyId
            $oxFailedNow = $RecordOxFailure -or [bool](Get-OptionalProperty $request 'ox_failure' $false)
            if ($oxEligibility.Eligible -and -not $oxFailedNow) {
                $selectedModel = [string]$historical.Roles.read_only_worker.ephemeral.model
                $selectedEffort = [string]$historical.Roles.read_only_worker.ephemeral.reasoning_effort
            }
            else {
                if ($oxFailedNow) {
                    Set-ObjectProperty -Object $state.ox -Name 'eligible' -Value $false
                    Set-ObjectProperty -Object $state.ox -Name 'failed' -Value $true
                    Set-ObjectProperty -Object $state.ox -Name 'failure_count' -Value 1
                    Set-ObjectProperty -Object $state.ox -Name 'reason' -Value 'OX_FAILURE_RECORDED'
                    $fallbackReason = 'OX_FAILURE_RECORDED_ONCE'
                }
                else { $fallbackReason = [string]$oxEligibility.Reason }
                $selectedModel = [string]$historical.Roles.read_only_worker.durable.model
                $selectedEffort = [string]$historical.Roles.read_only_worker.durable.reasoning_effort
            }
        }
        else {
            $selectedModel = [string]$historical.Roles.read_only_worker.durable.model
            $selectedEffort = [string]$historical.Roles.read_only_worker.durable.reasoning_effort
        }
        $contract = [string]$historical.Roles.read_only_worker.contract
    }
}
else {
    if ($executionPolicyId -eq 'SOL-ADVISOR-GLOBAL-001') {
        if ($role -eq 'orchestrator') {
            Assert-Route ([string]::IsNullOrWhiteSpace($requestedModel) -or $requestedModel -eq 'gpt-5.6-sol') 'SOL_ADVISOR_ORCHESTRATOR_MODEL_INVALID'
            $selectedModel = 'gpt-5.6-sol'
            $selectedEffort = 'high'
            $contract = 'sol_advisor'
        }
        elseif ($role -eq 'reviewer') {
            Assert-Route ([bool]$profile.concurrency.fresh_sol_reviewer_allowed) 'SOL_ADVISOR_FRESH_REVIEWER_REQUIRED'
            Assert-Route ([string]::IsNullOrWhiteSpace($requestedModel) -or $requestedModel -eq [string]$profile.sol_advisor.native_roles.sol_reviewer.model) 'SOL_ADVISOR_REVIEWER_MODEL_INVALID'
            $selectedModel = [string]$profile.sol_advisor.native_roles.sol_reviewer.model
            $selectedEffort = [string]$profile.sol_advisor.native_roles.sol_reviewer.reasoning_effort
            $contract = [string]$profile.sol_advisor.native_roles.sol_reviewer.role
        }
        elseif ($role -eq 'writer') {
            $shape = [string](Get-OptionalProperty $request 'implementation_shape' 'bounded')
            Assert-Route ($shape -in @('bounded', 'high_risk')) 'IMPLEMENTATION_SHAPE_INVALID'
            $oxEnabled = [string](Get-OptionalProperty $profile.ox_overlay 'status' '') -eq 'ENABLED'
            $oxEligibility = if ($oxEnabled) { Get-OxEligibility -Profile $profile -Request $request -State $state -ExecutionPolicyId $executionPolicyId } else { [pscustomobject]@{ Eligible = $false; Reason = 'OX_OVERLAY_DISABLED'; Cached = $false } }
            $overlayResolution = [string]$oxEligibility.Reason
            if ($oxEligibility.Eligible) {
                Assert-Route ($routeMode -in @($profile.ox_overlay.allowed_route_modes | ForEach-Object { [string]$_ })) 'OX_OVERLAY_ROUTE_MODE_INVALID'
                $selectedModel = [string]$profile.ox_overlay.model
                $selectedEffort = [string]$profile.ox_overlay.reasoning_effort
                $contract = [string]$profile.ox_overlay.role
            }
            elseif ($shape -eq 'bounded') {
                $selectedModel = [string]$profile.sol_advisor.native_roles.luna_implementer.model
                $selectedEffort = [string]$profile.sol_advisor.native_roles.luna_implementer.reasoning_effort
                $contract = [string]$profile.sol_advisor.native_roles.luna_implementer.role
            }
            else {
                $selectedModel = [string]$profile.sol_advisor.native_roles.terra_implementer.model
                $selectedEffort = [string]$profile.sol_advisor.native_roles.terra_implementer.reasoning_effort
                $contract = [string]$profile.sol_advisor.native_roles.terra_implementer.role
            }
        }
        else {
            Assert-Route $false 'SOL_ADVISOR_READ_ONLY_SCOUT_ROUTE_NOT_ACTIVE'
        }
    }
    else {
        $historical = Get-HistoricalCompatibility -Profile $profile
        $legacyRoles = $historical.ActiveRoles
        if ($role -eq 'orchestrator') {
            Assert-Route ([string]::IsNullOrWhiteSpace($requestedModel) -or $requestedModel -eq [string]$legacyRoles.orchestrator.model) 'orchestrator route is Sol only'
            $selectedModel = [string]$legacyRoles.orchestrator.model
            $selectedEffort = [string]$legacyRoles.orchestrator.reasoning_effort
        }
        elseif ($role -eq 'writer') {
            $routeScope = [string](Get-OptionalProperty $request 'route_scope' 'backend')
            if ($routeScope -eq 'hau_frontend') {
                $writerRoute = $legacyRoles.writers.hau_frontend
                Assert-Route ([string]::IsNullOrWhiteSpace($requestedModel) -or $requestedModel -eq [string]$writerRoute.model) 'HAU_FRONTEND_TERRA_WRITER_REQUIRED'
            }
            elseif ($routeScope -eq 'integration_fallback') {
                Assert-Route ([bool](Get-OptionalProperty $request 'explicit_sol_reroute' $false)) 'EXPLICIT_SOL_REROUTE_REQUIRED'
                $writerRoute = $legacyRoles.writers.integration_fallback
                Assert-Route ([string]::IsNullOrWhiteSpace($requestedModel) -or $requestedModel -eq [string]$writerRoute.model) 'TERRA_FALLBACK_REQUIRES_EXPLICIT_SOL_REROUTE'
            }
            else {
                Assert-Route ($routeScope -eq 'backend') 'WRITER_ROUTE_SCOPE_INVALID'
                $writerRoute = $legacyRoles.writers.backend_primary
                Assert-Route ([string]::IsNullOrWhiteSpace($requestedModel) -or $requestedModel -eq [string]$writerRoute.model) 'BACKEND_OX_WRITER_REQUIRED'
                $oxEligibility = Get-OxEligibility -Profile $profile -Request $request -State $state -ExecutionPolicyId $executionPolicyId
                Assert-Route ([bool]$oxEligibility.Eligible) 'OX_INELIGIBLE_EXPLICIT_SOL_REROUTE_REQUIRED'
            }
            $selectedModel = [string]$writerRoute.model
            $selectedEffort = [string]$writerRoute.reasoning_effort
            $contract = [string]$writerRoute.contract
        }
        else {
            $lunaRoute = $legacyRoles.read_only_workers.luna
            $oxRoute = $legacyRoles.read_only_workers.ox
            Assert-Route ([string]::IsNullOrWhiteSpace($requestedModel) -or $requestedModel -in @([string]$lunaRoute.model, [string]$oxRoute.model)) 'READ_ONLY_MODEL_NOT_ALLOWED'
            $useOx = $requestedModel -eq [string]$oxRoute.model -or [bool](Get-OptionalProperty $request 'prefer_ephemeral' $false)
            if ($useOx) {
                Assert-Route ($ActiveWriters -eq 0) 'OX_READ_ONLY_REQUIRES_NO_WRITER_LOCK'
                $oxEligibility = Get-OxEligibility -Profile $profile -Request $request -State $state -ExecutionPolicyId $executionPolicyId
                Assert-Route ([bool]$oxEligibility.Eligible) 'OX_INELIGIBLE_EXPLICIT_SOL_REROUTE_REQUIRED'
                $selectedModel = [string]$oxRoute.model
                $selectedEffort = [string]$oxRoute.reasoning_effort
                $contract = [string]$oxRoute.contract
            }
            else {
                $selectedModel = [string]$lunaRoute.model
                $selectedEffort = [string]$lunaRoute.reasoning_effort
                $contract = [string]$lunaRoute.contract
            }
        }
    }
}

if (-not [string]::IsNullOrWhiteSpace($fallbackReason) -and -not [string]::IsNullOrWhiteSpace($StatePath)) {
    Write-JsonAtomic -Path $StatePath -Value $state
}
Assert-ManualSelectedRoute -Permit $manualPermit -Request $request -SelectedModel $selectedModel -SelectedEffort $selectedEffort -FallbackReason $fallbackReason
Assert-Route ($selectedModel -notin @($profile.catalog.disabled_models | ForEach-Object { [string]$_ })) "selected disabled model: $selectedModel"
$materialFindings = Get-MaterialFindings -Path $FindingsPath
if (-not [string]::IsNullOrWhiteSpace($StatePath)) { Write-JsonAtomic -Path $StatePath -Value $state }

$quota = Get-OptionalProperty $request 'native_weighted_quota' $null
if ($null -ne $quota -and -not ($quota -is [int] -or $quota -is [long] -or $quota -is [double] -or $quota -is [decimal])) { $quota = $null }
$quality = [string](Get-OptionalProperty $request 'quality_evidence' 'UNOBSERVED')
if ($quality -notin @('ACCEPTED', 'REJECTED', 'UNOBSERVED')) { $quality = 'UNOBSERVED' }
$telemetry = [ordered]@{
    schema_version = 1
    observed_at = (Get-Date).ToUniversalTime().ToString('o')
    accepted_slice_fingerprint = $sliceFingerprint
    action = 'ROUTE'
    route_mode = $routeMode
    role = $role
    selected_model = $selectedModel
    reasoning_effort = $selectedEffort
    fallback_reason = $fallbackReason
    ox_overlay_resolution = $overlayResolution
    ox_eligibility = [string]$oxEligibility.Reason
    ox_cache_used = [bool]$oxEligibility.Cached
    context_tokens = $contextTokens
    verification_reuse = [string]$verificationReuse.State
    material_finding_count = @($materialFindings).Count
    native_weighted_quota = $quota
    quality_evidence = $quality
    execution_boundary = 'MANUAL_PERMIT_VALIDATED'
    manual_origin = $true
}
$telemetryWritten = Write-RouteTelemetry -Path $TelemetryPath -Record $telemetry
$result = [ordered]@{
    schema_version = 1
    action = 'ROUTE'
    route_mode = $routeMode
    selected_model = $selectedModel
    reasoning_effort = $selectedEffort
    role = $role
    contract = $contract
    fallback_reason = $fallbackReason
    ox_overlay_resolution = $overlayResolution
    ox_eligibility = $oxEligibility
    context = [ordered]@{
        dispatch_seed_tokens = $seedTokens
        worker_working_tokens = $workingTokens
        context_tokens = $contextTokens
        oversize_reason_required = ($contextTokens -gt [int]$profile.context_envelope.normal_hard_ceiling_tokens)
    }
    concurrency = [ordered]@{
        max_overlapping_writers = [int]$profile.concurrency.max_overlapping_writers
        default_read_only_workers = [int]$profile.concurrency.default_read_only_workers
        adaptive_read_only_workers_max = [int]$profile.concurrency.adaptive_read_only_workers_max
        total_workers_max = [int]$profile.concurrency.independent_burst_total_workers_max
        recursive_worker_spawning = [bool]$profile.concurrency.recursive_worker_spawning
    }
    verification_reuse = $verificationReuse
    material_findings = @($materialFindings)
    execution_boundary = [ordered]@{
        policy_id = $executionPolicyId
        state = 'MANUAL_PERMIT_VALIDATED'
        approval_id = [string]$manualPermit.approval_id
        manual_only = $true
        max_processes = 1
        default_children = if ($executionPolicyId -eq 'TOKEN-OPT-001-A7') { 0 } else { $null }
        max_children = if ($executionPolicyId -eq 'TOKEN-OPT-001-A7') { [int](Get-OptionalProperty $executionGate 'max_children' 0) } else { 0 }
        default_auxiliaries_max = if ($executionPolicyId -eq 'SOL-ADVISOR-GLOBAL-001') { [int](Get-OptionalProperty $executionGate 'default_auxiliaries_max' 1) } else { $null }
        fresh_sol_reviewer_allowed = if ($executionPolicyId -eq 'SOL-ADVISOR-GLOBAL-001') { [bool](Get-OptionalProperty $executionGate 'fresh_sol_reviewer_allowed' $false) } else { $null }
        sol_subagents_allowed = if ($executionPolicyId -in @('TOKEN-OPT-001-A8','SOL-ADVISOR-GLOBAL-001')) { [bool](Get-OptionalProperty $executionGate 'sol_subagents_allowed' $false) } else { $null }
        max_luna_max_subagents = if ($executionPolicyId -in @('TOKEN-OPT-001-A8','SOL-ADVISOR-GLOBAL-001')) { [int](Get-OptionalProperty $executionGate 'max_luna_max_subagents' 0) } else { 0 }
        max_terra_max_subagents = if ($executionPolicyId -in @('TOKEN-OPT-001-A8','SOL-ADVISOR-GLOBAL-001')) { [int](Get-OptionalProperty $executionGate 'max_terra_max_subagents' 0) } else { 0 }
        max_ox_alpha_subagents = if ($executionPolicyId -in @('TOKEN-OPT-001-A8','SOL-ADVISOR-GLOBAL-001')) { [int](Get-OptionalProperty $executionGate 'max_ox_alpha_subagents' 0) } else { 0 }
        max_total_direct_subagents = if ($executionPolicyId -in @('TOKEN-OPT-001-A8','SOL-ADVISOR-GLOBAL-001')) { [int](Get-OptionalProperty $executionGate 'max_total_direct_subagents' 0) } else { 0 }
        max_delegation_depth = if ($executionPolicyId -in @('TOKEN-OPT-001-A7','TOKEN-OPT-001-A8','SOL-ADVISOR-GLOBAL-001')) { 1 } else { 0 }
        background_continuation = $false
        automatic_fallback = $false
        dispatcher = $false
    }
    telemetry_written = $telemetryWritten
}
$result | ConvertTo-Json -Depth 20
