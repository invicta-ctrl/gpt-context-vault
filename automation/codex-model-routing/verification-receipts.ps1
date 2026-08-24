[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('Record', 'Check')][string]$Action,
    [Parameter(Mandatory)][string]$ReceiptPath,
    [Parameter(Mandatory)][string]$SourceFingerprint,
    [Parameter(Mandatory)][string]$ConfigurationFingerprint,
    [Parameter(Mandatory)][string]$TestFingerprint,
    [Parameter(Mandatory)][string]$DependencyFingerprint,
    [Parameter(Mandatory)][string]$ExternalStateFingerprint,
    [ValidateSet('PASS', 'FAIL')][string]$Status = 'PASS',
    [string]$VerificationId = 'unspecified'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Receipt {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "RECEIPT_VALIDATION: $Message" }
}

function Write-ReceiptAtomic {
    param([string]$Path, $Value)
    $fullPath = [IO.Path]::GetFullPath($Path)
    $parent = Split-Path -Parent $fullPath
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    $tempPath = Join-Path $parent ('.token-opt-receipt-' + [Guid]::NewGuid().ToString('N') + '.tmp')
    try {
        [IO.File]::WriteAllText($tempPath, (($Value | ConvertTo-Json -Depth 12) + "`n"), [Text.UTF8Encoding]::new($false))
        Move-Item -Force -LiteralPath $tempPath -Destination $fullPath
    }
    finally {
        if (Test-Path -LiteralPath $tempPath) { Remove-Item -Force -LiteralPath $tempPath }
    }
}

$fingerprints = [ordered]@{
    source = $SourceFingerprint
    configuration = $ConfigurationFingerprint
    test = $TestFingerprint
    dependency = $DependencyFingerprint
    external_state = $ExternalStateFingerprint
}
foreach ($entry in $fingerprints.GetEnumerator()) {
    Assert-Receipt ($entry.Value -match '^[a-f0-9]{64}$') "$($entry.Key) must be a SHA-256 fingerprint"
}

if ($Action -eq 'Record') {
    $receipt = [ordered]@{
        schema_version = 1
        receipt_id = $VerificationId
        status = $Status
        observed_at = (Get-Date).ToUniversalTime().ToString('o')
        fingerprints = $fingerprints
        redacted = $true
    }
    Write-ReceiptAtomic -Path $ReceiptPath -Value $receipt
    [pscustomobject]@{ action = 'RECORDED'; path = [IO.Path]::GetFullPath($ReceiptPath); status = $Status; reusable = ($Status -eq 'PASS') } | ConvertTo-Json -Compress
    exit 0
}

if (-not (Test-Path -LiteralPath $ReceiptPath -PathType Leaf)) {
    [pscustomobject]@{ action = 'CHECKED'; reusable = $false; invalidators = @('NO_RECEIPT') } | ConvertTo-Json -Compress
    exit 0
}
try {
    $receipt = Get-Content -LiteralPath $ReceiptPath -Raw | ConvertFrom-Json
}
catch {
    [pscustomobject]@{ action = 'CHECKED'; reusable = $false; invalidators = @('INVALID_RECEIPT') } | ConvertTo-Json -Compress
    exit 0
}
$invalidators = [Collections.Generic.List[string]]::new()
if ([string]$receipt.status -ne 'PASS') { $invalidators.Add('PRIOR_STATUS_NOT_PASS') }
foreach ($entry in $fingerprints.GetEnumerator()) {
    $actual = if ($receipt.fingerprints.PSObject.Properties.Name -contains $entry.Key) { [string]$receipt.fingerprints.$($entry.Key) } else { '' }
    if ($actual -ne $entry.Value) { $invalidators.Add('CHANGED_' + $entry.Key.ToUpperInvariant()) }
}
[pscustomobject]@{
    action = 'CHECKED'
    reusable = ($invalidators.Count -eq 0)
    invalidators = @($invalidators)
} | ConvertTo-Json -Compress
