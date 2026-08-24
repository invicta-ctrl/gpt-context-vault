[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$TelemetryPath,
    [string]$OutputPath,
    [datetime]$EndUtc = ([datetime]::UtcNow),
    [ValidateRange(1, 31)][int]$Days = 7
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Read-TelemetryRecords {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "BENCHMARK_VALIDATION: telemetry is missing: $Path" }
    $records = [Collections.Generic.List[object]]::new()
    foreach ($line in Get-Content -LiteralPath $Path) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try { $records.Add(($line | ConvertFrom-Json)) } catch { throw 'BENCHMARK_VALIDATION: telemetry contains invalid JSONL.' }
    }
    return @($records)
}

function Write-BenchmarkAtomic {
    param([string]$Path, $Value)
    $fullPath = [IO.Path]::GetFullPath($Path)
    $parent = Split-Path -Parent $fullPath
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    $tempPath = Join-Path $parent ('.token-opt-benchmark-' + [Guid]::NewGuid().ToString('N') + '.tmp')
    try {
        [IO.File]::WriteAllText($tempPath, (($Value | ConvertTo-Json -Depth 20) + "`n"), [Text.UTF8Encoding]::new($false))
        Move-Item -Force -LiteralPath $tempPath -Destination $fullPath
    }
    finally {
        if (Test-Path -LiteralPath $tempPath) { Remove-Item -Force -LiteralPath $tempPath }
    }
}

$end = $EndUtc.ToUniversalTime()
$start = $end.AddDays(-$Days)
$records = @(Read-TelemetryRecords -Path $TelemetryPath | Where-Object {
    try {
        $observed = [datetime]::Parse([string]$_.observed_at, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::RoundtripKind).ToUniversalTime()
        $observed -ge $start -and $observed -le $end -and -not [string]::IsNullOrWhiteSpace([string]$_.accepted_slice_fingerprint)
    }
    catch { $false }
})

$slices = foreach ($group in ($records | Group-Object accepted_slice_fingerprint)) {
    $observations = @($group.Group | Where-Object { $null -ne $_.native_weighted_quota -and [string]$_.quality_evidence -in @('ACCEPTED', 'REJECTED') })
    $models = @($observations | Group-Object selected_model | ForEach-Object {
        $quotas = @($_.Group | ForEach-Object { [decimal]$_.native_weighted_quota })
        [ordered]@{
            model = $_.Name
            observations = $_.Count
            native_weighted_quota_total = if ($quotas.Count) { [decimal]($quotas | Measure-Object -Sum).Sum } else { $null }
            quality_evidence = @($_.Group | Select-Object -ExpandProperty quality_evidence | Sort-Object -Unique)
        }
    })
    [ordered]@{
        accepted_slice_fingerprint = $group.Name
        total_route_observations = $group.Count
        comparable_observations = $observations.Count
        comparison_state = if ($observations.Count -gt 0 -and $models.Count -gt 1) { 'OBSERVED_COMPARISON' } else { 'INSUFFICIENT_OBSERVATIONS' }
        models = $models
        missing_observations = if ($observations.Count -eq 0) { @('native_weighted_quota_or_quality_evidence') } else { @() }
    }
}

$report = [ordered]@{
    schema_version = 1
    report_type = 'TOKEN-OPT-001-A4-seven-day-benchmark'
    generated_at = (Get-Date).ToUniversalTime().ToString('o')
    window = [ordered]@{ start_utc = $start.ToString('o'); end_utc = $end.ToString('o'); days = $Days }
    source = [IO.Path]::GetFullPath($TelemetryPath)
    accepted_slice_count = @($slices).Count
    slices = @($slices)
    quality_claim_rule = 'No quality or quota conclusion is made where required observations are missing.'
    native_weighted_quota_metric = 'Only caller-observed native weighted quota values are aggregated.'
}
if (-not [string]::IsNullOrWhiteSpace($OutputPath)) { Write-BenchmarkAtomic -Path $OutputPath -Value $report }
$report | ConvertTo-Json -Depth 20
