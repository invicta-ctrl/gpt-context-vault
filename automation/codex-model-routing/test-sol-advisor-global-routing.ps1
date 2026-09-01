[CmdletBinding()]
param([string]$VaultRoot = '')

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($VaultRoot)) { $VaultRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..')) }

function Assert-Test([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw "TEST_FAILURE: $Message" }
    Write-Output "PASS $Message"
}
function Write-TestJson([string]$Path, $Value) {
    [IO.File]::WriteAllText($Path, (($Value | ConvertTo-Json -Depth 40) + "`n"), [Text.UTF8Encoding]::new($false))
}
function Copy-TestObject($Value) {
    return (($Value | ConvertTo-Json -Depth 40) | ConvertFrom-Json)
}
function Set-ObjectProperty($Object, [string]$Name, $Value) {
    if ($Object.PSObject.Properties.Name -contains $Name) { $Object.$Name = $Value }
    else { $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Value }
}
function New-TestCatalog($Profile) {
    $models = [Collections.Generic.List[object]]::new()
    foreach ($entry in @($Profile.catalog.required_models)) {
        $models.Add([pscustomobject]@{ slug = [string]$entry.id; supported_reasoning_levels = @([string]$entry.effort) })
    }
    foreach ($entry in @($Profile.catalog.optional_overlay_models)) {
        $models.Add([pscustomobject]@{ slug = [string]$entry.id; supported_reasoning_levels = @([string]$entry.effort) })
    }
    return [pscustomobject]@{ models = $models.ToArray() }
}
function New-OverlayProfile($BaseProfile, [string]$Status) {
    $profile = Copy-TestObject $BaseProfile
    Set-ObjectProperty -Object $profile.ox_overlay -Name 'status' -Value $Status
    return $profile
}
function New-EligibleObservation {
    return [pscustomobject]@{
        model = 'openrouter/stealth/ox-alpha'; callable = $true; provider_available = $true;
        prompt_price = 0; completion_price = 0; billing_unambiguous = $true;
        health = 'healthy'; capabilities_present = $true
    }
}
function New-Request([string]$Role, [string]$RouteMode, [string]$Shape = 'bounded') {
    return [pscustomobject]@{
        role = $Role; route_mode = $RouteMode; implementation_shape = $Shape;
        run_id = 'sol-advisor-global-smoke'; task_id = [Guid]::NewGuid().ToString('N');
        dispatch_seed_tokens = 0; worker_working_tokens = 0; context_tokens = 0;
        active_writers = 0; active_writers_target = 0; active_read_only_workers = 0; active_total_workers = 0;
        recursion_depth = 0; delegation_depth = 0; spawned_by_worker = $false;
        execution_origin = 'manual_user'; manual_interactive = $true; owner_started_sol_session = $true;
        approval_id = [Guid]::NewGuid().ToString('D'); purpose = 'SOL-ADVISOR-GLOBAL-001 deterministic smoke';
        requested_luna_max_subagents = 0; requested_terra_max_subagents = 0;
        requested_ox_alpha_subagents = 0; requested_sol_subagents = 0; requested_sol_reviewer_auxiliaries = 0;
        subagent_requested = $false; background_continuation = $false; automatic_fallback = $false
    }
}
function Request-OneAuxiliary($Request, [string]$Lane) {
    if ($Lane -eq 'luna') { $Request.requested_luna_max_subagents = 1 }
    elseif ($Lane -eq 'terra') { $Request.requested_terra_max_subagents = 1 }
    elseif ($Lane -eq 'ox') { $Request.requested_ox_alpha_subagents = 1 }
    elseif ($Lane -eq 'reviewer') { $Request.requested_sol_reviewer_auxiliaries = 1 }
    else { throw "Unknown auxiliary lane: $Lane" }
    $Request.subagent_requested = $true
}
function New-IssuerProbePermit {
    param($Request, [string]$Model, [string]$Effort, [string]$Role)
    $probeRaw = @(& $permitIssuer -ContractProbe -DurationMinutes 10 -Model $Model -Reasoning $Effort -Role $Role -ProbeApprovalId ([string]$Request.approval_id) -ProbePurpose ([string]$Request.purpose)) -join "`n"
    return ($probeRaw | ConvertFrom-Json)
}
function Write-Permit {
    param([string]$Path, $Request, [string]$Model, [string]$Effort, [string]$Role)
    $permit = New-IssuerProbePermit -Request $Request -Model $Model -Effort $Effort -Role $Role
    Write-TestJson -Path $Path -Value $permit
    return $permit
}
function Test-GuardPermit {
    param([string]$Path)
    $guardRaw = @(& $guardValidator -PermitContractProbe -PermitContractProbePath $Path) -join "`n"
    return ($guardRaw | ConvertFrom-Json)
}
function Invoke-CompilerWithPermit {
    param($Profile, $Request, $Permit, [string]$StatePath = '')
    Write-TestJson -Path $profilePath -Value $Profile
    Write-TestJson -Path $permitPath -Value $Permit
    Write-TestJson -Path $requestPath -Value $Request
    $compilerArguments = @{
        ProfilePath = $profilePath; CatalogPath = $catalogPath; ExecutionGatePath = $gatePath;
        ManualPermitPath = $permitPath; RequestPath = $requestPath
    }
    if (-not [string]::IsNullOrWhiteSpace($StatePath)) { $compilerArguments['StatePath'] = $StatePath }
    return (@(& $compiler @compilerArguments) -join "`n")
}
function Invoke-Route {
    param($Profile, $Request, [string]$PermitModel, [string]$PermitEffort, [string]$PermitRole, [string]$StatePath = '')
    Write-TestJson -Path $profilePath -Value $Profile
    $permit = Write-Permit -Path $permitPath -Request $Request -Model $PermitModel -Effort $PermitEffort -Role $PermitRole
    $guard = Test-GuardPermit -Path $permitPath
    if (-not [bool]$guard.Valid) { throw "TEST_FAILURE: guard rejected actual issuer permit: $([string]$guard.Reason)" }
    Write-TestJson -Path $requestPath -Value $Request
    $compilerArguments = @{
        ProfilePath = $profilePath; CatalogPath = $catalogPath; ExecutionGatePath = $gatePath;
        ManualPermitPath = $permitPath; RequestPath = $requestPath
    }
    if (-not [string]::IsNullOrWhiteSpace($StatePath)) { $compilerArguments['StatePath'] = $StatePath }
    $raw = @(& $compiler @compilerArguments) -join "`n"
    return [pscustomobject]@{ Raw = $raw; Result = ($raw | ConvertFrom-Json); Permit = $permit; Guard = $guard }
}
function Assert-NoDispatch($Route, [string]$Name) {
    Assert-Test (-not [bool]$Route.Result.execution_boundary.dispatcher) "$Name remains non-dispatching"
    Assert-Test (-not $Route.Raw.Contains('codex exec') -and -not $Route.Raw.Contains('Start-Process')) "$Name output contains no dispatch command"
}
function Assert-NativePreDispatch($Route, [string]$Name, [string]$Model, [string]$Effort, [string]$Reason) {
    Assert-Test ([string]$Route.Result.selected_model -eq $Model -and [string]$Route.Result.reasoning_effort -eq $Effort) "$Name resolves to the native lane"
    Assert-Test ([string]$Route.Result.ox_overlay_resolution -eq $Reason) "$Name records pre-dispatch Ox resolution"
    Assert-Test ([string]$Route.Result.fallback_reason -eq '') "$Name records no retry or automatic fallback"
    Assert-NoDispatch -Route $Route -Name $Name
}
function Assert-Rejected([scriptblock]$Action, [string]$ExpectedMarker, [string]$Name) {
    $threw = $false
    $message = ''
    try { & $Action | Out-Null }
    catch {
        $threw = $true
        $message = $_.Exception.Message
    }
    Assert-Test $threw "$Name rejects the invalid route"
    Assert-Test ($message.Contains($ExpectedMarker)) "$Name reports $ExpectedMarker"
}

$compiler = Join-Path $PSScriptRoot 'route-compiler.ps1'
$permitIssuer = Join-Path $VaultRoot 'automation\codex-usage-guard\Enable-CodexUsage.ps1'
$guardValidator = Join-Path $VaultRoot 'automation\codex-usage-guard\CodexUsageGuard.ps1'
$baseProfile = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'current-routing-profile.json') -Raw | ConvertFrom-Json
$baseGate = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'manual-codex-execution-gate.json') -Raw | ConvertFrom-Json
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ('sol-advisor-global-routing-' + [Guid]::NewGuid().ToString('N'))

try {
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    $profilePath = Join-Path $tempRoot 'profile.json'
    $catalogPath = Join-Path $tempRoot 'catalog.json'
    $gatePath = Join-Path $tempRoot 'gate.json'
    $permitPath = Join-Path $tempRoot 'permit.json'
    $requestPath = Join-Path $tempRoot 'request.json'
    Write-TestJson -Path $catalogPath -Value (New-TestCatalog -Profile $baseProfile)
    $gate = Copy-TestObject $baseGate
    # Historical SOL coverage must not read MAEOS routing state as though it were
    # the old contract.  Build the smallest isolated legacy gate fixture instead.
    Set-ObjectProperty -Object $gate -Name 'policy_id' -Value 'SOL-ADVISOR-GLOBAL-001'
    Set-ObjectProperty -Object $gate -Name 'default_auxiliaries_max' -Value 1
    Set-ObjectProperty -Object $gate -Name 'fresh_sol_reviewer_allowed' -Value $true
    Set-ObjectProperty -Object $gate -Name 'max_fresh_sol_reviewers' -Value 1
    Set-ObjectProperty -Object $gate -Name 'permit_path' -Value $permitPath
    Write-TestJson -Path $gatePath -Value $gate

    $disabledProfile = New-OverlayProfile -BaseProfile $baseProfile -Status 'OX_OVERLAY_DISABLED'
    $soloRequest = New-Request -Role 'orchestrator' -RouteMode 'solo'
    $solo = Invoke-Route -Profile $disabledProfile -Request $soloRequest -PermitModel 'gpt-5.6-sol' -PermitEffort 'high' -PermitRole 'orchestrator'
    Assert-Test ([string]$solo.Result.selected_model -eq 'gpt-5.6-sol' -and [string]$solo.Result.reasoning_effort -eq 'high') 'solo selects Sol High'
    Assert-Test (-not [bool]$soloRequest.subagent_requested -and [string]$solo.Result.route_mode -eq 'solo') 'solo declares no auxiliary'
    Assert-NoDispatch -Route $solo -Name 'solo'

    $boundedRequest = New-Request -Role 'writer' -RouteMode 'delegate' -Shape 'bounded'
    Request-OneAuxiliary -Request $boundedRequest -Lane 'luna'
    $bounded = Invoke-Route -Profile $disabledProfile -Request $boundedRequest -PermitModel 'gpt-5.6-luna' -PermitEffort 'max' -PermitRole 'writer'
    Assert-NativePreDispatch -Route $bounded -Name 'delegate bounded with Ox disabled' -Model 'gpt-5.6-luna' -Effort 'max' -Reason 'OX_OVERLAY_DISABLED'

    $highRiskRequest = New-Request -Role 'writer' -RouteMode 'delegate' -Shape 'high_risk'
    Request-OneAuxiliary -Request $highRiskRequest -Lane 'terra'
    $highRisk = Invoke-Route -Profile $disabledProfile -Request $highRiskRequest -PermitModel 'gpt-5.6-terra' -PermitEffort 'high' -PermitRole 'writer'
    Assert-NativePreDispatch -Route $highRisk -Name 'delegate high-risk with Ox disabled' -Model 'gpt-5.6-terra' -Effort 'high' -Reason 'OX_OVERLAY_DISABLED'

    $auditRequest = New-Request -Role 'reviewer' -RouteMode 'audit'
    Request-OneAuxiliary -Request $auditRequest -Lane 'reviewer'
    $audit = Invoke-Route -Profile $disabledProfile -Request $auditRequest -PermitModel 'gpt-5.6-sol' -PermitEffort 'high' -PermitRole 'reviewer'
    Assert-Test ([string]$audit.Result.selected_model -eq 'gpt-5.6-sol' -and [string]$audit.Result.contract -eq 'sol_advisor_sol_reviewer') 'audit selects only fresh Sol High reviewer'
    Assert-Test ([bool]$audit.Result.execution_boundary.fresh_sol_reviewer_allowed) 'audit preserves fresh reviewer permission'
    Assert-Test ([int]$audit.Permit.default_auxiliaries_max -eq 1 -and [bool]$audit.Permit.fresh_sol_reviewer_allowed -and [int]$audit.Permit.max_fresh_sol_reviewers -eq 1 -and [bool]$audit.Permit.legacy_guard_safety_caps_only -and [string]$audit.Permit.issued_by_account -eq 'CONTRACT_PROBE') 'actual issuer probe emits the active reviewer permit contract without a permit write'
    Assert-Test ([bool]$audit.Guard.Valid -and [string]$audit.Guard.Reason -eq 'MANUAL_PERMIT_VALID') 'actual guard probe accepts the issuer reviewer permit before compiler routing'
    Assert-NoDispatch -Route $audit -Name 'audit'

    $fullWriterRequest = New-Request -Role 'writer' -RouteMode 'full' -Shape 'bounded'
    Request-OneAuxiliary -Request $fullWriterRequest -Lane 'luna'
    $fullWriter = Invoke-Route -Profile $disabledProfile -Request $fullWriterRequest -PermitModel 'gpt-5.6-luna' -PermitEffort 'max' -PermitRole 'writer'
    $fullReviewerRequest = New-Request -Role 'reviewer' -RouteMode 'full'
    Request-OneAuxiliary -Request $fullReviewerRequest -Lane 'reviewer'
    $fullReviewer = Invoke-Route -Profile $disabledProfile -Request $fullReviewerRequest -PermitModel 'gpt-5.6-sol' -PermitEffort 'high' -PermitRole 'reviewer'
    Assert-Test ([string]$fullWriter.Result.contract -eq 'sol_advisor_luna_implementer' -and [string]$fullReviewer.Result.contract -eq 'sol_advisor_sol_reviewer') 'full keeps writer and fresh reviewer lanes separate'
    Assert-NoDispatch -Route $fullWriter -Name 'full writer'
    Assert-NoDispatch -Route $fullReviewer -Name 'full reviewer'

    $enabledProfile = New-OverlayProfile -BaseProfile $baseProfile -Status 'ENABLED'
    $eligibleOxRequest = New-Request -Role 'writer' -RouteMode 'delegate' -Shape 'bounded'
    Request-OneAuxiliary -Request $eligibleOxRequest -Lane 'ox'
    Set-ObjectProperty -Object $eligibleOxRequest -Name 'data_classification' -Value 'internal'
    Set-ObjectProperty -Object $eligibleOxRequest -Name 'provider_observation' -Value (New-EligibleObservation)
    $eligibleOx = Invoke-Route -Profile $enabledProfile -Request $eligibleOxRequest -PermitModel 'openrouter/stealth/ox-alpha' -PermitEffort 'high' -PermitRole 'writer'
    Assert-Test ([string]$eligibleOx.Result.selected_model -eq 'openrouter/stealth/ox-alpha' -and [string]$eligibleOx.Result.reasoning_effort -eq 'high') 'eligible Ox overlay selects Ox High implementation'
    Assert-Test ([string]$eligibleOx.Result.ox_overlay_resolution -eq 'ELIGIBLE') 'eligible Ox records exact eligibility'
    Assert-NoDispatch -Route $eligibleOx -Name 'eligible Ox overlay'

    $unavailableRequest = New-Request -Role 'writer' -RouteMode 'delegate' -Shape 'bounded'
    Request-OneAuxiliary -Request $unavailableRequest -Lane 'luna'
    Set-ObjectProperty -Object $unavailableRequest -Name 'data_classification' -Value 'internal'
    $unavailableObservation = New-EligibleObservation
    Set-ObjectProperty -Object $unavailableObservation -Name 'provider_available' -Value $false
    Set-ObjectProperty -Object $unavailableRequest -Name 'provider_observation' -Value $unavailableObservation
    $unavailable = Invoke-Route -Profile $enabledProfile -Request $unavailableRequest -PermitModel 'gpt-5.6-luna' -PermitEffort 'max' -PermitRole 'writer'
    Assert-NativePreDispatch -Route $unavailable -Name 'unavailable Ox bounded delegate' -Model 'gpt-5.6-luna' -Effort 'max' -Reason 'PROVIDER_UNAVAILABLE'

    $unfreeRequest = New-Request -Role 'writer' -RouteMode 'delegate' -Shape 'high_risk'
    Request-OneAuxiliary -Request $unfreeRequest -Lane 'terra'
    Set-ObjectProperty -Object $unfreeRequest -Name 'data_classification' -Value 'internal'
    $unfreeObservation = New-EligibleObservation
    Set-ObjectProperty -Object $unfreeObservation -Name 'prompt_price' -Value 0.01
    Set-ObjectProperty -Object $unfreeRequest -Name 'provider_observation' -Value $unfreeObservation
    $unfree = Invoke-Route -Profile $enabledProfile -Request $unfreeRequest -PermitModel 'gpt-5.6-terra' -PermitEffort 'high' -PermitRole 'writer'
    Assert-NativePreDispatch -Route $unfree -Name 'unfree Ox high-risk delegate' -Model 'gpt-5.6-terra' -Effort 'high' -Reason 'PRICE_NOT_EXACTLY_ZERO'

    $staleStatePath = Join-Path $tempRoot 'stale-active-ox-state.json'
    $staleOxRequest = New-Request -Role 'writer' -RouteMode 'delegate' -Shape 'bounded'
    Request-OneAuxiliary -Request $staleOxRequest -Lane 'ox'
    Write-TestJson -Path $staleStatePath -Value ([ordered]@{
        schema_version = 1; run_id = [string]$staleOxRequest.run_id;
        ox = [ordered]@{ eligible = $true; failed = $false; failure_count = 0; checked_at = ([DateTimeOffset]::UtcNow.ToString('o')); reason = 'ELIGIBLE' };
        ordinary_work_keys = @()
    })
    Assert-Rejected -Action { Invoke-Route -Profile $enabledProfile -Request $staleOxRequest -PermitModel 'openrouter/stealth/ox-alpha' -PermitEffort 'high' -PermitRole 'writer' -StatePath $staleStatePath } -ExpectedMarker 'OX_PROVIDER_AVAILABLE_BOOLEAN_REQUIRED' -Name 'stale cached Ox eligibility without current proof'

    foreach ($booleanCase in @(
        [pscustomobject]@{ Property = 'provider_available'; Marker = 'OX_PROVIDER_AVAILABLE_BOOLEAN_REQUIRED' },
        [pscustomobject]@{ Property = 'callable'; Marker = 'OX_CALLABLE_BOOLEAN_REQUIRED' },
        [pscustomobject]@{ Property = 'billing_unambiguous'; Marker = 'OX_BILLING_UNAMBIGUOUS_BOOLEAN_REQUIRED' },
        [pscustomobject]@{ Property = 'capabilities_present'; Marker = 'OX_CAPABILITIES_PRESENT_BOOLEAN_REQUIRED' }
    )) {
        $stringBooleanRequest = New-Request -Role 'writer' -RouteMode 'delegate' -Shape 'bounded'
        Request-OneAuxiliary -Request $stringBooleanRequest -Lane 'ox'
        Set-ObjectProperty -Object $stringBooleanRequest -Name 'data_classification' -Value 'internal'
        $stringBooleanObservation = New-EligibleObservation
        Set-ObjectProperty -Object $stringBooleanObservation -Name $booleanCase.Property -Value 'false'
        Set-ObjectProperty -Object $stringBooleanRequest -Name 'provider_observation' -Value $stringBooleanObservation
        Assert-Rejected -Action { Invoke-Route -Profile $enabledProfile -Request $stringBooleanRequest -PermitModel 'openrouter/stealth/ox-alpha' -PermitEffort 'high' -PermitRole 'writer' } -ExpectedMarker $booleanCase.Marker -Name ("string false " + $booleanCase.Property)
    }

    $legacyPermitRequest = New-Request -Role 'reviewer' -RouteMode 'audit'
    Request-OneAuxiliary -Request $legacyPermitRequest -Lane 'reviewer'
    $legacyPermit = New-IssuerProbePermit -Request $legacyPermitRequest -Model 'gpt-5.6-sol' -Effort 'high' -Role 'reviewer'
    [void]$legacyPermit.PSObject.Properties.Remove('default_auxiliaries_max')
    Write-TestJson -Path $permitPath -Value $legacyPermit
    $legacyGuard = Test-GuardPermit -Path $permitPath
    Assert-Test (-not [bool]$legacyGuard.Valid -and [string]$legacyGuard.Reason -eq 'MANUAL_PERMIT_MISSING_DEFAULT_AUXILIARIES_MAX') 'guard rejects legacy permit missing active fields'
    Assert-Rejected -Action { Invoke-CompilerWithPermit -Profile $disabledProfile -Request $legacyPermitRequest -Permit $legacyPermit } -ExpectedMarker 'SOL_ADVISOR_DEFAULT_AUXILIARY_LIMIT_INVALID' -Name 'compiler rejects legacy permit missing active fields'

    $rolePermitRequest = New-Request -Role 'reviewer' -RouteMode 'audit'
    Request-OneAuxiliary -Request $rolePermitRequest -Lane 'reviewer'
    $rolePermit = New-IssuerProbePermit -Request $rolePermitRequest -Model 'gpt-5.6-sol' -Effort 'high' -Role 'reviewer'
    $rolePermit.allowed_role = 'read_only_worker'
    $rolePermit.allowed_roles = @('read_only_worker')
    Write-TestJson -Path $permitPath -Value $rolePermit
    $roleGuard = Test-GuardPermit -Path $permitPath
    Assert-Test (-not [bool]$roleGuard.Valid -and [string]$roleGuard.Reason -eq 'MANUAL_PERMIT_ROLE_INVALID') 'guard rejects malformed reviewer role'
    Assert-Rejected -Action { Invoke-CompilerWithPermit -Profile $disabledProfile -Request $rolePermitRequest -Permit $rolePermit } -ExpectedMarker 'MANUAL_PERMIT_ROLE_MISMATCH' -Name 'compiler rejects malformed reviewer role'

    $reviewerModelRequest = New-Request -Role 'reviewer' -RouteMode 'audit'
    Request-OneAuxiliary -Request $reviewerModelRequest -Lane 'reviewer'
    $reviewerModelPermit = New-IssuerProbePermit -Request $reviewerModelRequest -Model 'gpt-5.6-sol' -Effort 'high' -Role 'reviewer'
    $reviewerModelPermit.allowed_model = 'gpt-5.6-terra'
    Write-TestJson -Path $permitPath -Value $reviewerModelPermit
    $reviewerModelGuard = Test-GuardPermit -Path $permitPath
    Assert-Test (-not [bool]$reviewerModelGuard.Valid -and [string]$reviewerModelGuard.Reason -eq 'MANUAL_PERMIT_REVIEWER_CONTRACT_INVALID') 'guard rejects malformed reviewer model'
    Assert-Rejected -Action { Invoke-CompilerWithPermit -Profile $disabledProfile -Request $reviewerModelRequest -Permit $reviewerModelPermit } -ExpectedMarker 'MANUAL_PERMIT_REVIEWER_CONTRACT_INVALID' -Name 'compiler rejects malformed reviewer model'

    $stringBooleanPermitRequest = New-Request -Role 'reviewer' -RouteMode 'audit'
    Request-OneAuxiliary -Request $stringBooleanPermitRequest -Lane 'reviewer'
    $stringBooleanPermit = New-IssuerProbePermit -Request $stringBooleanPermitRequest -Model 'gpt-5.6-sol' -Effort 'high' -Role 'reviewer'
    $stringBooleanPermit.fresh_sol_reviewer_allowed = 'true'
    Write-TestJson -Path $permitPath -Value $stringBooleanPermit
    $stringBooleanGuard = Test-GuardPermit -Path $permitPath
    Assert-Test (-not [bool]$stringBooleanGuard.Valid -and [string]$stringBooleanGuard.Reason -eq 'MANUAL_PERMIT_FRESH_SOL_REVIEWER_ALLOWED_BOOLEAN_INVALID') 'guard rejects string-coerced reviewer Boolean'
    Assert-Rejected -Action { Invoke-CompilerWithPermit -Profile $disabledProfile -Request $stringBooleanPermitRequest -Permit $stringBooleanPermit } -ExpectedMarker 'MANUAL_PERMIT_FRESH_SOL_REVIEWER_ALLOWED_BOOLEAN_INVALID' -Name 'compiler rejects string-coerced reviewer Boolean'

    $soloWithAuxiliary = New-Request -Role 'orchestrator' -RouteMode 'solo'
    Request-OneAuxiliary -Request $soloWithAuxiliary -Lane 'luna'
    Assert-Rejected -Action { Invoke-Route -Profile $disabledProfile -Request $soloWithAuxiliary -PermitModel 'gpt-5.6-sol' -PermitEffort 'high' -PermitRole 'orchestrator' } -ExpectedMarker 'SOL_ADVISOR_SOLO_AUXILIARY_COUNT_INVALID' -Name 'solo with auxiliary'

    $delegateWithoutWorker = New-Request -Role 'writer' -RouteMode 'delegate'
    Assert-Rejected -Action { Invoke-Route -Profile $disabledProfile -Request $delegateWithoutWorker -PermitModel 'gpt-5.6-luna' -PermitEffort 'max' -PermitRole 'writer' } -ExpectedMarker 'SOL_ADVISOR_DELEGATE_IMPLEMENTATION_AUXILIARY_REQUIRED' -Name 'delegate without implementation auxiliary'

    $auditWithoutReviewer = New-Request -Role 'reviewer' -RouteMode 'audit'
    Assert-Rejected -Action { Invoke-Route -Profile $disabledProfile -Request $auditWithoutReviewer -PermitModel 'gpt-5.6-sol' -PermitEffort 'high' -PermitRole 'reviewer' } -ExpectedMarker 'SOL_ADVISOR_AUDIT_REVIEWER_AUXILIARY_REQUIRED' -Name 'audit without reviewer auxiliary'

    $fullWriterWithoutWorker = New-Request -Role 'writer' -RouteMode 'full'
    Assert-Rejected -Action { Invoke-Route -Profile $disabledProfile -Request $fullWriterWithoutWorker -PermitModel 'gpt-5.6-luna' -PermitEffort 'max' -PermitRole 'writer' } -ExpectedMarker 'SOL_ADVISOR_FULL_WRITER_IMPLEMENTATION_AUXILIARY_REQUIRED' -Name 'full writer without implementation auxiliary'

    $fullReviewerWithoutReviewer = New-Request -Role 'reviewer' -RouteMode 'full'
    Assert-Rejected -Action { Invoke-Route -Profile $disabledProfile -Request $fullReviewerWithoutReviewer -PermitModel 'gpt-5.6-sol' -PermitEffort 'high' -PermitRole 'reviewer' } -ExpectedMarker 'SOL_ADVISOR_FULL_REVIEWER_AUXILIARY_REQUIRED' -Name 'full reviewer without reviewer auxiliary'

    Write-Output 'SUMMARY PASS sol_advisor_global_routing=19 negative_regressions=14 actual_issuer_probe=1 guard_contract_probe=1 real_codex_calls=0'
}
finally {
    if (Test-Path -LiteralPath $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force }
}
