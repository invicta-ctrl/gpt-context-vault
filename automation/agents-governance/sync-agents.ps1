[CmdletBinding()]
param(
    [switch]$Apply,
    [switch]$IncludeCandidateTargets,
    [string[]]$TargetId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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

function Get-RepoRoot {
    $root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
    if (-not (Test-Path -LiteralPath (Join-Path $root 'AGENTS.md') -PathType Leaf)) {
        throw "Canonical AGENTS.md is missing from repository root: $root"
    }
    $root
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

function Write-AtomicBytes {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][byte[]]$Bytes
    )
    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    $temp = Join-Path $parent ('.agents-sync-' + [Guid]::NewGuid().ToString('N') + '.tmp')
    try {
        [IO.File]::WriteAllBytes($temp, $Bytes)
        Move-Item -Force -LiteralPath $temp -Destination $Path
    }
    finally {
        if (Test-Path -LiteralPath $temp) {
            Remove-Item -Force -LiteralPath $temp
        }
    }
}

function Get-PlannedAction {
    param(
        [bool]$Exists,
        [AllowNull()][string]$CurrentHash,
        [Parameter(Mandatory)][string]$DesiredHash,
        [bool]$Applying
    )
    if ($Exists -and $CurrentHash -eq $DesiredHash) { return 'MATCH' }
    if ($Applying) {
        if ($Exists) { return 'UPDATED' }
        return 'CREATED'
    }
    if ($Exists) { return 'WOULD_UPDATE' }
    return 'WOULD_CREATE'
}

$repoRoot = Get-RepoRoot
$registryPath = Join-Path $repoRoot 'governance\agents\AGENTS_REGISTRY.json'
if (-not (Test-Path -LiteralPath $registryPath -PathType Leaf)) {
    throw "Registry is missing: $registryPath"
}

$registry = Get-Content -LiteralPath $registryPath -Raw | ConvertFrom-Json
$canonicalPath = Join-Path $repoRoot $registry.canonical.relative_path
$canonicalBytes = [IO.File]::ReadAllBytes($canonicalPath)
$canonicalHash = Get-Sha256 $canonicalPath
$timestamp = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ')

$results = [Collections.Generic.List[object]]::new()
$failures = [Collections.Generic.List[string]]::new()

foreach ($replica in $registry.managed_replicas) {
    if ($TargetId -and $replica.id -notin $TargetId) {
        continue
    }

    $targetPath = [string]$replica.path
    $extensionPath = [string]$replica.extension_path
    $mode = 'live'
    $allowed = [bool]$replica.sync_allowed

    if (-not $allowed -and $IncludeCandidateTargets -and
        $replica.PSObject.Properties.Name -contains 'candidate_sync_allowed' -and
        [bool]$replica.candidate_sync_allowed) {
        $targetPath = [string]$replica.candidate_worktree_path
        $extensionPath = [string]$replica.candidate_extension_path
        $allowed = $true
        $mode = 'candidate'
    }

    if (-not $allowed) {
        $results.Add([pscustomobject]@{
            Id = $replica.id
            Mode = $mode
            ReplicaAction = 'BLOCKED'
            ExtensionAction = 'BLOCKED'
            ReplicaPath = $targetPath
            ExtensionPath = $extensionPath
            Detail = [string]$replica.gate_status
        })
        continue
    }

    if ([string]::IsNullOrWhiteSpace($targetPath) -or
        -not [IO.Path]::IsPathRooted($targetPath)) {
        $failures.Add("$($replica.id): unsafe or non-absolute replica path")
        continue
    }
    if ([string]::IsNullOrWhiteSpace($extensionPath) -or
        -not [IO.Path]::IsPathRooted($extensionPath)) {
        $failures.Add("$($replica.id): unsafe or non-absolute extension path")
        continue
    }

    $extensionSource = Resolve-ExtensionSource -Registry $registry -ReplicaId $replica.id -RepoRoot $repoRoot
    if (-not $extensionSource -or
        -not (Test-Path -LiteralPath $extensionSource -PathType Leaf)) {
        $failures.Add("$($replica.id): extension source is missing: $extensionSource")
        continue
    }

    $extensionBytes = [IO.File]::ReadAllBytes($extensionSource)
    $extensionSourceHash = Get-Sha256 $extensionSource

    $replicaExists = Test-Path -LiteralPath $targetPath -PathType Leaf
    $replicaCurrentHash = if ($replicaExists) { Get-Sha256 $targetPath } else { $null }
    $extensionExists = Test-Path -LiteralPath $extensionPath -PathType Leaf
    $extensionCurrentHash = if ($extensionExists) { Get-Sha256 $extensionPath } else { $null }

    if ($replicaExists -and $replicaCurrentHash -ne $canonicalHash) {
        $prechangeProperty = if ($mode -eq 'candidate') { 'candidate_prechange_sha256' } else { 'prechange_sha256' }
        $expected = [string](Get-OptionalProperty -Object $replica -Name $prechangeProperty -Default '')
        if ([string]::IsNullOrWhiteSpace($expected) -or $replicaCurrentHash -ne $expected) {
            $failures.Add(
                "$($replica.id): replica changed since preflight; expected " +
                "$expected, found $replicaCurrentHash"
            )
            continue
        }
    }

    if ($extensionExists -and $extensionCurrentHash -ne $extensionSourceHash) {
        $extensionExistsProperty = if ($mode -eq 'candidate') { 'candidate_prechange_extension_exists' } else { 'prechange_extension_exists' }
        $extensionHashProperty = if ($mode -eq 'candidate') { 'candidate_prechange_extension_sha256' } else { 'prechange_extension_sha256' }
        $expectedExtensionExists = [bool](Get-OptionalProperty -Object $replica -Name $extensionExistsProperty -Default $false)
        $expectedExtensionHash = [string](Get-OptionalProperty -Object $replica -Name $extensionHashProperty -Default '')
        if (-not $expectedExtensionExists -or
            [string]::IsNullOrWhiteSpace($expectedExtensionHash) -or
            $extensionCurrentHash -ne $expectedExtensionHash) {
            $failures.Add(
                "$($replica.id): extension is unexpected or changed since preflight; " +
                "expected=$expectedExtensionHash found=$extensionCurrentHash"
            )
            continue
        }
    }

    $replicaAction = Get-PlannedAction -Exists $replicaExists -CurrentHash $replicaCurrentHash -DesiredHash $canonicalHash -Applying ([bool]$Apply)
    $extensionAction = Get-PlannedAction -Exists $extensionExists -CurrentHash $extensionCurrentHash -DesiredHash $extensionSourceHash -Applying ([bool]$Apply)

    if (-not $Apply) {
        $results.Add([pscustomobject]@{
            Id = $replica.id
            Mode = $mode
            ReplicaAction = $replicaAction
            ExtensionAction = $extensionAction
            ReplicaPath = $targetPath
            ExtensionPath = $extensionPath
            Detail = "replica=$canonicalHash extension=$extensionSourceHash"
        })
        continue
    }

    if (-not $replica.repository) {
        $backupPattern = [string]$replica.rollback
        $backupPath = $backupPattern.Replace('<timestamp>', $timestamp)
        $backupDir = Split-Path -Parent $backupPath
        New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

        if ($replicaExists -and $replicaCurrentHash -ne $canonicalHash) {
            Copy-Item -LiteralPath $targetPath -Destination $backupPath
            if ((Get-Sha256 $backupPath) -ne $replicaCurrentHash) {
                throw "$($replica.id): replica backup hash verification failed"
            }
        }

        if ($extensionExists -and $extensionCurrentHash -ne $extensionSourceHash) {
            $extensionBackup = Join-Path $backupDir 'PROJECT_POLICY.md'
            Copy-Item -LiteralPath $extensionPath -Destination $extensionBackup
            if ((Get-Sha256 $extensionBackup) -ne $extensionCurrentHash) {
                throw "$($replica.id): extension backup hash verification failed"
            }
        }
    }

    if ($replicaCurrentHash -ne $canonicalHash) {
        Write-AtomicBytes -Path $targetPath -Bytes $canonicalBytes
    }
    if ($extensionCurrentHash -ne $extensionSourceHash) {
        Write-AtomicBytes -Path $extensionPath -Bytes $extensionBytes
    }

    $afterReplicaHash = Get-Sha256 $targetPath
    $afterExtensionHash = Get-Sha256 $extensionPath
    if ($afterReplicaHash -ne $canonicalHash) {
        throw "$($replica.id): synchronized replica hash mismatch"
    }
    if ($afterExtensionHash -ne $extensionSourceHash) {
        throw "$($replica.id): synchronized extension hash mismatch"
    }

    $results.Add([pscustomobject]@{
        Id = $replica.id
        Mode = $mode
        ReplicaAction = $replicaAction
        ExtensionAction = $extensionAction
        ReplicaPath = $targetPath
        ExtensionPath = $extensionPath
        Detail = "replica=$afterReplicaHash extension=$afterExtensionHash"
    })
}

$results | Format-Table -AutoSize | Out-String | Write-Host

if ($failures.Count -gt 0) {
    foreach ($failure in $failures) {
        Write-Error $failure
    }
    exit 1
}

if (-not $Apply) {
    Write-Host 'DRY RUN ONLY. Re-run with -Apply after reviewing every eligible target.'
}
