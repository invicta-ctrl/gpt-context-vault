[CmdletBinding()]
param([string]$VaultRoot = '')

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($VaultRoot)) { $VaultRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..')) }

function Assert-Test {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "TEST_FAILURE: $Message" }
    Write-Output "PASS $Message"
}

function Write-TestJson {
    param([string]$Path, $Value)
    [IO.File]::WriteAllText($Path, (($Value | ConvertTo-Json -Depth 30) + "`n"), [Text.UTF8Encoding]::new($false))
}

function Get-OptionalProperty {
    param($Object, [string]$Name, $Default = $null)
    if ($null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name) { return $Object.$Name }
    return $Default
}

function Set-ObjectProperty {
    param($Object, [string]$Name, $Value)
    if ($Object.PSObject.Properties.Name -contains $Name) { $Object.$Name = $Value }
    else { $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Value }
}

$fixturePath = Join-Path $PSScriptRoot 'fixtures\a4-route-compiler-fixtures.json'
$compiler = Join-Path $PSScriptRoot 'route-compiler.ps1'
$receiptTool = Join-Path $PSScriptRoot 'verification-receipts.ps1'
$benchmarkTool = Join-Path $PSScriptRoot 'report-seven-day-benchmark.ps1'
$fixture = Get-Content -LiteralPath $fixturePath -Raw | ConvertFrom-Json
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ('token-opt-a4-' + [Guid]::NewGuid().ToString('N'))

function Get-ExpectedRouteIdentity {
    param($Scenario)
    $model = [string]$(if ($Scenario.PSObject.Properties.Name -contains 'expected' -and $Scenario.expected -and $Scenario.expected.PSObject.Properties.Name -contains 'selected_model') { $Scenario.expected.selected_model } elseif ([string]$Scenario.request.role -eq 'orchestrator') { 'gpt-5.6-sol' } elseif ([string]$Scenario.request.role -eq 'writer') { 'gpt-5.6-terra' } else { 'gpt-5.6-luna' })
    $effort = switch ($model) { 'gpt-5.6-sol' { 'high' } 'gpt-5.6-terra' { 'max' } 'gpt-5.6-luna' { 'max' } 'openrouter/stealth/ox-alpha' { 'high' } default { 'high' } }
    [pscustomobject]@{ Model = $model; Effort = $effort }
}

function Write-SyntheticManualPermit {
    param([string]$Path, [string]$ApprovalId, [string]$Role, [string]$Model, [string]$Effort)
    Write-TestJson -Path $Path -Value ([ordered]@{
        schema_version = 1; approval_id = $ApprovalId; state = 'ACTIVE'; issued_by = 'A4 deterministic fixture';
        issued_at = ([DateTimeOffset]::UtcNow.ToString('o')); expires_at = ([DateTimeOffset]::UtcNow.AddMinutes(10).ToString('o'));
        purpose = 'Historical A4 route selection under A6'; origin = 'manual_user'; manual_interactive = $true;
        allowed_model = $Model; allowed_reasoning = $Effort; allowed_role = $Role; allowed_roles = @($Role); allow_subagents = $false; max_processes = 1; max_children = 0;
        background_continuation = $false; automatic_fallback = $false; consumed = $false; process_id = $null
    })
}

try {
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    $catalogPath = Join-Path $tempRoot 'catalog.json'
    $telemetryPath = Join-Path $tempRoot 'telemetry.jsonl'
    $gatePath = Join-Path $tempRoot 'manual-codex-execution-gate.json'
    $permitPath = Join-Path $tempRoot 'permit.json'
    Write-TestJson -Path $catalogPath -Value $fixture.catalog
    Write-TestJson -Path $gatePath -Value ([ordered]@{ schema_version = 1; policy_id = 'TOKEN-OPT-001-A6'; default_state = 'LOCKED'; manual_only = $true; permit_path = $permitPath; max_processes = 1; max_children = 0; allow_subagents = $false; background_continuation = $false; automatic_fallback = $false; route_compiler_is_dispatcher = $false })
    $states = @{}

    foreach ($scenario in @($fixture.scenarios)) {
        $requestPath = Join-Path $tempRoot ($scenario.id + '.request.json')
        $request = (($scenario.request | ConvertTo-Json -Depth 30) | ConvertFrom-Json)
        $approvalId = [Guid]::NewGuid().ToString('D')
        $identity = Get-ExpectedRouteIdentity -Scenario $scenario
        if (-not [bool](Get-OptionalProperty $request 'acceptance_green' $false)) {
            Set-ObjectProperty -Object $request -Name 'execution_origin' -Value 'manual_user'
            Set-ObjectProperty -Object $request -Name 'manual_interactive' -Value $true
            Set-ObjectProperty -Object $request -Name 'approval_id' -Value $approvalId
            Set-ObjectProperty -Object $request -Name 'purpose' -Value 'Historical A4 route selection under A6'
            Set-ObjectProperty -Object $request -Name 'subagent_requested' -Value $false
            Set-ObjectProperty -Object $request -Name 'background_continuation' -Value $false
            Set-ObjectProperty -Object $request -Name 'automatic_fallback' -Value $false
            Write-SyntheticManualPermit -Path $permitPath -ApprovalId $approvalId -Role ([string]$request.role) -Model $identity.Model -Effort $identity.Effort
        }
        Write-TestJson -Path $requestPath -Value $request
        $stateKey = [string]$(if ($scenario.PSObject.Properties.Name -contains 'state_key') { $scenario.state_key } else { $scenario.id })
        if (-not $states.ContainsKey($stateKey)) { $states[$stateKey] = Join-Path $tempRoot ($stateKey + '.state.json') }
        $findingsPath = $null
        if ($scenario.PSObject.Properties.Name -contains 'findings') {
            $findingsPath = Join-Path $tempRoot ($scenario.id + '.findings.json')
            Write-TestJson -Path $findingsPath -Value ([ordered]@{ findings = @($scenario.findings) })
        }
        $expectedError = [string]$(if ($scenario.PSObject.Properties.Name -contains 'expected_error') { $scenario.expected_error } else { '' })
        if ($scenario.id -in @('ox-price-falls-back-once','ox-provider-unavailable-falls-back','ox-unhealthy-falls-back','ox-restricted-data-falls-back','ox-failure-marks-run-ineligible','ox-failure-does-not-retry')) { $expectedError = 'AUTOMATIC_FALLBACK_DISABLED' }
        if ($scenario.id -in @('second-writer-rejected','adaptive-read-only-cap-rejected','total-worker-cap-rejected','independent-burst-six-is-routable')) { $expectedError = 'SECOND_PROCESS_DISABLED' }
        try {
            $invokeParams = @{
                ProfilePath = (Join-Path $PSScriptRoot 'current-routing-profile.json')
                CatalogPath = $catalogPath
                ExecutionGatePath = $gatePath
                ManualPermitPath = $permitPath
                RequestPath = $requestPath
                StatePath = $states[$stateKey]
                TelemetryPath = $telemetryPath
            }
            if ($findingsPath) { $invokeParams.FindingsPath = $findingsPath }
            if ($scenario.PSObject.Properties.Name -contains 'record_ox_failure' -and [bool]$scenario.record_ox_failure) { $invokeParams.RecordOxFailure = $true }
            $raw = & $compiler @invokeParams
            if (-not [string]::IsNullOrWhiteSpace($expectedError)) { throw "expected error '$expectedError' but compiler succeeded" }
            $result = ($raw -join "`n") | ConvertFrom-Json
            foreach ($property in $scenario.expected.PSObject.Properties) {
                if ($property.Name -eq 'fallback_contains') {
                    Assert-Test ([string]$result.fallback_reason -like ('*' + [string]$property.Value + '*')) ($scenario.id + ' fallback')
                }
                elseif ($property.Name -eq 'material_finding_count') {
                    Assert-Test (@($result.material_findings).Count -eq [int]$property.Value) ($scenario.id + ' material finding count')
                }
                else {
                    Assert-Test ([string]$result.$($property.Name) -eq [string]$property.Value) ($scenario.id + ' ' + $property.Name)
                }
            }
        }
        catch {
            if ([string]::IsNullOrWhiteSpace($expectedError)) { throw }
            Assert-Test ($_.Exception.Message -like ('*' + $expectedError + '*')) ($scenario.id + ' rejected; actual=' + $_.Exception.Message)
        }
    }

    $telemetryText = Get-Content -LiteralPath $telemetryPath -Raw
    Assert-Test (-not $telemetryText.Contains('"task_id"')) 'route telemetry excludes raw task identifiers'
    Assert-Test (-not $telemetryText.Contains('provider_observation')) 'route telemetry excludes raw provider observations'

    $fingerprintA = 'a' * 64
    $fingerprintB = 'b' * 64
    $receiptPath = Join-Path $tempRoot 'receipt.json'
    $null = & $receiptTool -Action Record -ReceiptPath $receiptPath -SourceFingerprint $fingerprintA -ConfigurationFingerprint $fingerprintA -TestFingerprint $fingerprintA -DependencyFingerprint $fingerprintA -ExternalStateFingerprint $fingerprintA -VerificationId 'a4-test'
    $receiptCheck = ((& $receiptTool -Action Check -ReceiptPath $receiptPath -SourceFingerprint $fingerprintA -ConfigurationFingerprint $fingerprintA -TestFingerprint $fingerprintA -DependencyFingerprint $fingerprintA -ExternalStateFingerprint $fingerprintA) -join "`n") | ConvertFrom-Json
    Assert-Test ([bool]$receiptCheck.reusable) 'verification receipt reuse with matching fingerprints'
    $receiptChanged = ((& $receiptTool -Action Check -ReceiptPath $receiptPath -SourceFingerprint $fingerprintB -ConfigurationFingerprint $fingerprintA -TestFingerprint $fingerprintA -DependencyFingerprint $fingerprintA -ExternalStateFingerprint $fingerprintA) -join "`n") | ConvertFrom-Json
    Assert-Test (-not [bool]$receiptChanged.reusable -and @($receiptChanged.invalidators) -contains 'CHANGED_SOURCE') 'verification receipt invalidates changed source'

    $benchmarkPath = Join-Path $tempRoot 'benchmark.json'
    $benchmark = ((& $benchmarkTool -TelemetryPath $telemetryPath -OutputPath $benchmarkPath -EndUtc ([datetime]::UtcNow) -Days 7) -join "`n") | ConvertFrom-Json
    Assert-Test (Test-Path -LiteralPath $benchmarkPath -PathType Leaf) 'seven-day benchmark writes report'
    Assert-Test (@($benchmark.slices).Count -ge 1) 'seven-day benchmark reports observed accepted slice'
    Assert-Test ($benchmark.quality_claim_rule -like '*No quality*missing*') 'seven-day benchmark does not fabricate missing quality evidence'
    Write-Output "SUMMARY PASS a4_historical_fixtures=$(@($fixture.scenarios).Count) a6_supersession=10 receipt=2 benchmark=3"
}
finally {
    if (Test-Path -LiteralPath $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force }
}
