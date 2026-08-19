[CmdletBinding()]
param(
    [switch]$IncludeCandidateTargets,
    [switch]$FailOnBlocked,
    [string[]]$TargetId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-Sha256 {
    param([Parameter(Mandatory)][string]$Path)
    (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Resolve-ExtensionSource {
    param(
        [Parameter(Mandatory)]$Registry,
        [Parameter(Mandatory)][string]$ReplicaId,
        [Parameter(Mandatory)][string]$RepoRoot
    )
    $entry = $Registry.extension_sources | Where-Object {
        $_.id -eq "$ReplicaId-extension-source"
    } | Select-Object -First 1
    if ($null -eq $entry) { return $null }
    [IO.Path]::GetFullPath((Join-Path $RepoRoot $entry.source_relative_path))
}

$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$registryPath = Join-Path $repoRoot 'governance\agents\AGENTS_REGISTRY.json'
$registry = Get-Content -LiteralPath $registryPath -Raw | ConvertFrom-Json
$canonicalPath = Join-Path $repoRoot $registry.canonical.relative_path

if (-not (Test-Path -LiteralPath $canonicalPath -PathType Leaf)) {
    Write-Error "MISSING canonical master: $canonicalPath"
    exit 1
}

$canonicalHash = Get-Sha256 $canonicalPath
$results = [Collections.Generic.List[object]]::new()
$failureCount = 0

foreach ($replica in $registry.managed_replicas) {
    if ($TargetId -and $replica.id -notin $TargetId) {
        continue
    }

    $path = [string]$replica.path
    $extensionPath = [string]$replica.extension_path
    $eligible = [bool]$replica.sync_allowed
    $mode = 'live'

    if (-not $eligible -and $IncludeCandidateTargets -and
        $replica.PSObject.Properties.Name -contains 'candidate_sync_allowed' -and
        [bool]$replica.candidate_sync_allowed) {
        $path = [string]$replica.candidate_worktree_path
        $extensionPath = [string]$replica.candidate_extension_path
        $eligible = $true
        $mode = 'candidate'
    }

    if (-not $eligible) {
        $results.Add([pscustomobject]@{
            Id = $replica.id
            Mode = $mode
            Replica = 'BLOCKED'
            Extension = 'BLOCKED'
            ReplicaPath = $path
            ExtensionPath = $extensionPath
            Detail = [string]$replica.gate_status
        })
        if ($FailOnBlocked -and [bool]$replica.required) {
            $failureCount++
        }
        continue
    }

    $replicaState = 'MISSING'
    $replicaDetail = ''
    if (Test-Path -LiteralPath $path -PathType Leaf) {
        $hash = Get-Sha256 $path
        if ($hash -eq $canonicalHash) {
            $replicaState = 'MATCH'
            $replicaDetail = $hash
        }
        else {
            $replicaState = 'DRIFT'
            $replicaDetail = "expected=$canonicalHash actual=$hash"
        }
    }

    $extensionSource = Resolve-ExtensionSource -Registry $registry -ReplicaId $replica.id -RepoRoot $repoRoot
    $extensionState = 'SOURCE_MISSING'
    $extensionDetail = [string]$extensionSource
    if ($extensionSource -and (Test-Path -LiteralPath $extensionSource -PathType Leaf)) {
        $extensionSourceHash = Get-Sha256 $extensionSource
        if (-not (Test-Path -LiteralPath $extensionPath -PathType Leaf)) {
            $extensionState = 'MISSING'
            $extensionDetail = "expected=$extensionSourceHash"
        }
        else {
            $extensionHash = Get-Sha256 $extensionPath
            if ($extensionHash -eq $extensionSourceHash) {
                $extensionState = 'MATCH'
                $extensionDetail = $extensionHash
            }
            else {
                $extensionState = 'DRIFT'
                $extensionDetail = "expected=$extensionSourceHash actual=$extensionHash"
            }
        }
    }

    $results.Add([pscustomobject]@{
        Id = $replica.id
        Mode = $mode
        Replica = $replicaState
        Extension = $extensionState
        ReplicaPath = $path
        ExtensionPath = $extensionPath
        Detail = "replica: $replicaDetail; extension: $extensionDetail"
    })

    if ($replicaState -ne 'MATCH') {
        $failureCount++
    }
    if ($extensionState -ne 'MATCH') {
        $failureCount++
    }
}

Write-Host "CANONICAL $canonicalHash $canonicalPath"
$results | Format-Table -AutoSize | Out-String | Write-Host

if ($failureCount -gt 0) {
    Write-Error "AGENTS verification failed with $failureCount blocking result(s)."
    exit 1
}

Write-Host 'AGENTS verification passed for every eligible target.'
