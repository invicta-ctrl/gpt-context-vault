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

$fixturePath = Join-Path $PSScriptRoot 'fixtures\a4-route-compiler-fixtures.json'
$compiler = Join-Path $PSScriptRoot 'route-compiler.ps1'
$receiptTool = Join-Path $PSScriptRoot 'verification-receipts.ps1'
$benchmarkTool = Join-Path $PSScriptRoot 'report-seven-day-benchmark.ps1'
$fixture = Get-Content -LiteralPath $fixturePath -Raw | ConvertFrom-Json
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ('token-opt-a4-' + [Guid]::NewGuid().ToString('N'))

try {
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    $catalogPath = Join-Path $tempRoot 'catalog.json'
    $telemetryPath = Join-Path $tempRoot 'telemetry.jsonl'
    Write-TestJson -Path $catalogPath -Value $fixture.catalog
    $states = @{}

    foreach ($scenario in @($fixture.scenarios)) {
        $requestPath = Join-Path $tempRoot ($scenario.id + '.request.json')
        Write-TestJson -Path $requestPath -Value $scenario.request
        $stateKey = [string]$(if ($scenario.PSObject.Properties.Name -contains 'state_key') { $scenario.state_key } else { $scenario.id })
        if (-not $states.ContainsKey($stateKey)) { $states[$stateKey] = Join-Path $tempRoot ($stateKey + '.state.json') }
        $findingsPath = $null
        if ($scenario.PSObject.Properties.Name -contains 'findings') {
            $findingsPath = Join-Path $tempRoot ($scenario.id + '.findings.json')
            Write-TestJson -Path $findingsPath -Value ([ordered]@{ findings = @($scenario.findings) })
        }
        $expectedError = [string]$(if ($scenario.PSObject.Properties.Name -contains 'expected_error') { $scenario.expected_error } else { '' })
        try {
            $invokeParams = @{
                ProfilePath = (Join-Path $PSScriptRoot 'current-routing-profile.json')
                CatalogPath = $catalogPath
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
            Assert-Test ($_.Exception.Message -like ('*' + $expectedError + '*')) ($scenario.id + ' rejected')
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
    Write-Output "SUMMARY PASS a4_route_compiler=$(@($fixture.scenarios).Count) receipt=2 benchmark=3"
}
finally {
    if (Test-Path -LiteralPath $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force }
}
