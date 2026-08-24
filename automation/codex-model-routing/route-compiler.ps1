[CmdletBinding()]
param(
    [string]$ProfilePath = (Join-Path $PSScriptRoot 'current-routing-profile.json'),
    [string]$CatalogPath = "$env:USERPROFILE\.codex\codex-router\merged-models.json",
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

function Assert-CatalogContract {
    param($Profile, $Catalog)
    foreach ($required in @($Profile.catalog.required_models)) {
        $id = [string]$required.id
        $model = Get-ModelById -Catalog $Catalog -ModelId $id
        Assert-Route ($null -ne $model) "catalog does not contain required model $id"
        Assert-Route ((Get-ModelEfforts -Model $model) -contains [string]$required.effort) "catalog does not support $($required.effort) for $id"
    }

    $disabled = @($Profile.catalog.disabled_models | ForEach-Object { [string]$_ })
    $activeModels = @(
        [string]$Profile.roles.orchestrator.model,
        [string]$Profile.roles.writer.model,
        [string]$Profile.roles.read_only_worker.durable.model,
        [string]$Profile.roles.read_only_worker.ephemeral.model
    ) + @($Profile.fallbacks.ox | ForEach-Object { [string]$_ })
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
    param($Profile, $Request, $State)
    $oxState = $State.ox
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

    $observation = Get-OptionalProperty $Request 'provider_observation' $null
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
$request = Read-JsonRequired -Path $RequestPath -Label 'route request'
Assert-Route ([int]$profile.schema_version -eq 1) 'unsupported routing profile schema'
Assert-CatalogContract -Profile $profile -Catalog $catalog

$role = [string](Get-OptionalProperty $request 'role' '')
Assert-Route ($role -in @('orchestrator', 'writer', 'read_only_worker')) 'role must be orchestrator, writer, or read_only_worker'
$requestedModel = [string](Get-OptionalProperty $request 'requested_model' '')
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
Assert-Route ($recursionDepth -eq 0) 'recursive worker spawning is disabled'
Assert-Route (-not [bool](Get-OptionalProperty $request 'spawned_by_worker' $false)) 'worker-originated recursive dispatch is disabled'
$activeWriters = Get-Integer -Value (Get-OptionalProperty $request 'active_writers' 0) -Label 'active_writers'
$activeReadOnly = Get-Integer -Value (Get-OptionalProperty $request 'active_read_only_workers' 0) -Label 'active_read_only_workers'
$activeTotal = Get-Integer -Value (Get-OptionalProperty $request 'active_total_workers' 0) -Label 'active_total_workers'
$prospective = 1
if ($role -eq 'writer') {
    Assert-Route (($activeWriters + $prospective) -le [int]$profile.concurrency.max_overlapping_writers) 'one overlapping Terra writer maximum exceeded'
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

if ([bool](Get-OptionalProperty $request 'acceptance_green' $false)) {
    if (-not [string]::IsNullOrWhiteSpace($StatePath)) { Write-JsonAtomic -Path $StatePath -Value $state }
    $stopResult = [ordered]@{
        schema_version = 1
        action = 'STOP'
        reason = 'STOP_WHEN_GREEN'
        verification_reuse = $verificationReuse
        selected_model = $null
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
$fallbackReason = $null
$oxEligibility = [pscustomobject]@{ Eligible = $false; Reason = 'NOT_REQUESTED'; Cached = $false }
if ($role -eq 'orchestrator') {
    $selectedModel = [string]$profile.roles.orchestrator.model
    $selectedEffort = [string]$profile.roles.orchestrator.reasoning_effort
}
elseif ($role -eq 'writer') {
    Assert-Route ([string]::IsNullOrWhiteSpace($requestedModel) -or $requestedModel -eq [string]$profile.roles.writer.model) 'writer route is Terra only'
    $selectedModel = [string]$profile.roles.writer.model
    $selectedEffort = [string]$profile.roles.writer.reasoning_effort
}
else {
    $preferOx = [bool](Get-OptionalProperty $request 'prefer_ephemeral' $false) -or $requestedModel -eq [string]$profile.roles.read_only_worker.ephemeral.model
    Assert-Route ([string]::IsNullOrWhiteSpace($requestedModel) -or $requestedModel -in @([string]$profile.roles.read_only_worker.durable.model, [string]$profile.roles.read_only_worker.ephemeral.model)) 'read-only worker model is not allowed by the shared contract'
    if ($preferOx) {
        $oxEligibility = Get-OxEligibility -Profile $profile -Request $request -State $state
        $oxFailedNow = $RecordOxFailure -or [bool](Get-OptionalProperty $request 'ox_failure' $false)
        if ($oxEligibility.Eligible -and -not $oxFailedNow) {
            $selectedModel = [string]$profile.roles.read_only_worker.ephemeral.model
            $selectedEffort = [string]$profile.roles.read_only_worker.ephemeral.reasoning_effort
        }
        else {
            if ($oxFailedNow) {
                Set-ObjectProperty -Object $state.ox -Name 'eligible' -Value $false
                Set-ObjectProperty -Object $state.ox -Name 'failed' -Value $true
                Set-ObjectProperty -Object $state.ox -Name 'failure_count' -Value 1
                Set-ObjectProperty -Object $state.ox -Name 'reason' -Value 'OX_FAILURE_RECORDED'
                $fallbackReason = 'OX_FAILURE_RECORDED_ONCE'
            }
            else {
                $fallbackReason = [string]$oxEligibility.Reason
            }
            $selectedModel = [string]$profile.roles.read_only_worker.durable.model
            $selectedEffort = [string]$profile.roles.read_only_worker.durable.reasoning_effort
        }
    }
    else {
        $selectedModel = [string]$profile.roles.read_only_worker.durable.model
        $selectedEffort = [string]$profile.roles.read_only_worker.durable.reasoning_effort
    }
}

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
    role = $role
    selected_model = $selectedModel
    reasoning_effort = $selectedEffort
    fallback_reason = $fallbackReason
    ox_eligibility = [string]$oxEligibility.Reason
    ox_cache_used = [bool]$oxEligibility.Cached
    context_tokens = $contextTokens
    verification_reuse = [string]$verificationReuse.State
    material_finding_count = @($materialFindings).Count
    native_weighted_quota = $quota
    quality_evidence = $quality
}
$telemetryWritten = Write-RouteTelemetry -Path $TelemetryPath -Record $telemetry
$contract = if ($role -eq 'writer') { [string]$profile.roles.writer.contract } elseif ($role -eq 'read_only_worker') { [string]$profile.roles.read_only_worker.contract } else { $null }
$result = [ordered]@{
    schema_version = 1
    action = 'ROUTE'
    selected_model = $selectedModel
    reasoning_effort = $selectedEffort
    role = $role
    contract = $contract
    fallback_reason = $fallbackReason
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
    telemetry_written = $telemetryWritten
}
$result | ConvertTo-Json -Depth 20
