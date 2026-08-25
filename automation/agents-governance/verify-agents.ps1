[CmdletBinding()]
param(
    [switch]$IncludeCandidateTargets,
    [switch]$FailOnBlocked,
    [string[]]$TargetId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$activationModulePath = Join-Path $PSScriptRoot 'CodexExtensionActivation.psm1'
if (-not (Test-Path -LiteralPath $activationModulePath -PathType Leaf)) {
    throw "Activation module is missing: $activationModulePath"
}
Import-Module $activationModulePath -Force

$discoveryModulePath = Join-Path $PSScriptRoot 'RegisteredTargetDiscovery.psm1'
if (-not (Test-Path -LiteralPath $discoveryModulePath -PathType Leaf)) {
    throw "Registered-target discovery module is missing: $discoveryModulePath"
}
Import-Module $discoveryModulePath -Force

function Get-Sha256 {
    param([Parameter(Mandatory)][string]$Path)
    (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Get-OptionalProperty {
    param(
        [Parameter(Mandatory)]$Object,
        [Parameter(Mandatory)][string]$Name,
        $Default = $null
    )
    if ($Object.PSObject.Properties.Name -contains $Name) {
        return $Object.$Name
    }
    return $Default
}

function Resolve-ExtensionSource {
    param(
        [Parameter(Mandatory)]$Registry,
        [Parameter(Mandatory)][string]$ReplicaId,
        [Parameter(Mandatory)][string]$RepoRoot,
        $Replica = $null
    )
    $sourceId = "$ReplicaId-extension-source"
    if ($null -ne $Replica -and
        $Replica.PSObject.Properties.Name -contains 'extension_source_id') {
        $sourceId = [string]$Replica.extension_source_id
    }
    $entry = $Registry.extension_sources | Where-Object {
        $_.id -eq $sourceId
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
$appendixResults = [Collections.Generic.List[object]]::new()
$failureCount = 0
$allReplicas = @($registry.managed_replicas) + @(Get-RegisteredWorktreeTargets -Registry $registry)

foreach ($replica in $allReplicas) {
    if ($TargetId -and $replica.id -notin $TargetId) {
        continue
    }

    $path = [string]$replica.path
    $extensionPath = [string]$replica.extension_path
    $eligible = [bool]$replica.sync_allowed
    $mode = [string](Get-OptionalProperty -Object $replica -Name 'mode' -Default 'live')
    $activation = Get-OptionalProperty -Object $replica -Name 'extension_activation' -Default $null

    if (-not $eligible -and $IncludeCandidateTargets -and
        $replica.PSObject.Properties.Name -contains 'candidate_sync_allowed' -and
        [bool]$replica.candidate_sync_allowed) {
        $path = [string]$replica.candidate_worktree_path
        $extensionPath = [string]$replica.candidate_extension_path
        $eligible = $true
        $mode = 'candidate'
        $activation = $null
    }

    if (-not $eligible) {
        $blockedActivationState = if ($null -ne $activation) { 'BLOCKED' } else { 'N/A' }
        $results.Add([pscustomobject]@{
            Id = $replica.id
            Mode = $mode
            Replica = 'BLOCKED'
            Extension = 'BLOCKED'
            Activation = $blockedActivationState
            ReplicaPath = $path
            ExtensionPath = $extensionPath
            Detail = [string]$replica.gate_status
        })
        if ($FailOnBlocked -and [bool]$replica.required) {
            $failureCount++
        }
        continue
    }

    $targetRoot = [IO.Path]::GetFullPath((Split-Path -Parent $path))
    $writerState = Get-TargetWriterState -TargetRoot $targetRoot
    if ($writerState -notin @('NO_POINTER', 'NONE', 'NONE_TERMINAL_LEGACY_POINTER')) {
        $results.Add([pscustomobject]@{
            Id = $replica.id
            Mode = $mode
            Replica = 'BLOCKED'
            Extension = 'BLOCKED'
            Activation = 'BLOCKED'
            ReplicaPath = $path
            ExtensionPath = $extensionPath
            Detail = "active writer state=$writerState"
        })
        if ($FailOnBlocked -and [bool]$replica.required) {
            $failureCount++
        }
        continue
    }

    $dirtyState = Get-TargetGitDirtyState -TargetRoot $targetRoot
    if ($dirtyState.State -notin @('CLEAN', 'MANAGED_OR_GENERATED_ONLY', 'NON_GIT_TARGET')) {
        $results.Add([pscustomobject]@{
            Id = $replica.id
            Mode = $mode
            Replica = 'BLOCKED'
            Extension = 'BLOCKED'
            Activation = 'BLOCKED'
            ReplicaPath = $path
            ExtensionPath = $extensionPath
            Detail = "dirty state=$($dirtyState.State): $($dirtyState.Detail)"
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

    $extensionSource = Resolve-ExtensionSource -Registry $registry -ReplicaId $replica.id -RepoRoot $repoRoot -Replica $replica
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

    $activationState = 'N/A'
    $activationDetail = 'no activation mechanism registered'
    if ($null -ne $activation) {
        try {
            $activationResult = Test-CodexDeveloperInstructionsActivation `
                -Activation $activation `
                -ExtensionSource $extensionSource
            $activationState = [string]$activationResult.State
            $activationDetail = [string]$activationResult.Detail
        }
        catch {
            $activationState = 'ERROR'
            $activationDetail = $_.Exception.Message
        }
    }

    $results.Add([pscustomobject]@{
        Id = $replica.id
        Mode = $mode
        Replica = $replicaState
        Extension = $extensionState
        Activation = $activationState
        ReplicaPath = $path
        ExtensionPath = $extensionPath
        Detail = "replica: $replicaDetail; extension: $extensionDetail; activation: $activationDetail; dirty=$($dirtyState.State)"
    })

    if ($replicaState -ne 'MATCH') {
        $failureCount++
    }
    if ($extensionState -ne 'MATCH') {
        $failureCount++
    }
    if ($null -ne $activation -and $activationState -ne 'MATCH') {
        $failureCount++
    }
}

if ($registry.PSObject.Properties.Name -contains 'preserved_worktree_appendices') {
    foreach ($appendix in $registry.preserved_worktree_appendices) {
        $appendixPath = [string]$appendix.path
        $expectedHash = [string]$appendix.sha256
        $state = 'MISSING'
        $detail = "expected=$expectedHash"
        $worktreeRoot = Split-Path -Parent (Split-Path -Parent $appendixPath)
        $worktreeGitMarker = Join-Path $worktreeRoot '.git'
        if ([string](Get-OptionalProperty -Object $appendix -Name 'disposition' -Default '') -eq 'historical_unavailable_reference') {
            $state = 'HISTORICAL_UNAVAILABLE'
            $detail = "historical appendix unavailable; hash record and provenance preserved without replacement: $worktreeRoot"
        }
        elseif (-not (Test-Path -LiteralPath $worktreeRoot -PathType Container) -or
            -not (Test-Path -LiteralPath $worktreeGitMarker)) {
            $state = 'BLOCKED'
            $detail = "registered appendix target is not an available worktree; hash record preserved and no replacement was created: $worktreeRoot"
        }
        elseif (Test-Path -LiteralPath $appendixPath -PathType Leaf) {
            $actualHash = Get-Sha256 $appendixPath
            if ($actualHash -eq $expectedHash) {
                $state = 'MATCH'
                $detail = $actualHash
            }
            else {
                $state = 'DRIFT'
                $detail = "expected=$expectedHash actual=$actualHash"
            }
        }
        $appendixResults.Add([pscustomobject]@{
            State = $state
            Path = $appendixPath
            Detail = $detail
        })
        if ($state -ne 'MATCH' -and $state -ne 'HISTORICAL_UNAVAILABLE' -and -not ($state -eq 'BLOCKED' -and -not $FailOnBlocked)) {
            $failureCount++
        }
    }
}

Write-Host "CANONICAL $canonicalHash $canonicalPath"
$results | Format-Table -AutoSize | Out-String | Write-Host
if ($appendixResults.Count -gt 0) {
    Write-Host 'PRESERVED WORKTREE APPENDICES'
    $appendixResults | Format-Table -AutoSize | Out-String | Write-Host
}

if ($failureCount -gt 0) {
    Write-Error "AGENTS verification failed with $failureCount blocking result(s)."
    exit 1
}

Write-Host 'AGENTS verification passed for every eligible target.'
