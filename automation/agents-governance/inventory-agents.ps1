[CmdletBinding()]
param(
    [ValidateSet('PRECHANGE', 'POSTCHANGE')][string]$Phase = 'PRECHANGE',
    [string]$OutputDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-InventoryOptionalProperty {
    param($Object, [string]$Name, $Default = $null)
    if ($null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name) {
        return $Object.$Name
    }
    return $Default
}

$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$registryPath = Join-Path $repoRoot 'governance\agents\AGENTS_REGISTRY.json'
$registry = Get-Content -LiteralPath $registryPath -Raw | ConvertFrom-Json
$canonicalPath = [IO.Path]::GetFullPath((Join-Path $repoRoot $registry.canonical.relative_path))
$canonicalHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $canonicalPath).Hash.ToLowerInvariant()
$canonicalBytes = [IO.File]::ReadAllBytes($canonicalPath)
$scanRoot = [IO.Path]::GetFullPath([string]$registry.inventory_scope.project_root)
$globalPath = [IO.Path]::GetFullPath([string]$registry.inventory_scope.global_codex_agents)

$discoveryModulePath = Join-Path $PSScriptRoot 'RegisteredTargetDiscovery.psm1'
Import-Module $discoveryModulePath -Force
$worktreeTargets = @(Get-RegisteredWorktreeTargets -Registry $registry)

$staticByPath = @{}
foreach ($target in $registry.managed_replicas) {
    $staticByPath[[IO.Path]::GetFullPath([string]$target.path).ToLowerInvariant()] = $target
}
$worktreeByPath = @{}
foreach ($target in $worktreeTargets) {
    $worktreeByPath[[IO.Path]::GetFullPath([string]$target.path).ToLowerInvariant()] = $target
}
$retiredWorktreeByPath = @{}
if ($registry.PSObject.Properties.Name -contains 'managed_worktree_groups') {
    foreach ($group in $registry.managed_worktree_groups) {
        foreach ($artifact in @(Get-InventoryOptionalProperty -Object $group -Name 'retired_unregistered_worktree_artifacts' -Default @())) {
            $artifactPath = if ($artifact -is [string]) { [string]$artifact } else { [string]$artifact.path }
            if ([string]::IsNullOrWhiteSpace($artifactPath)) { continue }
            $agentsPath = Join-Path ([IO.Path]::GetFullPath($artifactPath)) 'AGENTS.md'
            $retiredWorktreeByPath[$agentsPath.ToLowerInvariant()] = [pscustomobject]@{
                id = "$($group.id):retired:" + (Split-Path -Leaf $artifactPath)
                artifact = $artifact
            }
        }
    }
}
$verificationArtifactByPath = @{}
foreach ($artifact in @(Get-InventoryOptionalProperty -Object $registry -Name 'immutable_verification_artifacts' -Default @())) {
    $artifactPath = [string](Get-InventoryOptionalProperty -Object $artifact -Name 'path' -Default '')
    if ([string]::IsNullOrWhiteSpace($artifactPath)) { continue }
    $verificationArtifactByPath[[IO.Path]::GetFullPath($artifactPath).ToLowerInvariant()] = $artifact
}

$files = @(Get-ChildItem -LiteralPath $scanRoot -File -Recurse -Force -Filter 'AGENTS.md' -ErrorAction Stop)
if (Test-Path -LiteralPath $globalPath -PathType Leaf) {
    $files += Get-Item -LiteralPath $globalPath
}
$files = @($files | Sort-Object FullName -Unique)

$rows = foreach ($file in $files) {
    $path = [IO.Path]::GetFullPath($file.FullName)
    $key = $path.ToLowerInvariant()
    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLowerInvariant()
    $classification = 'UNKNOWN_REQUIRES_PRESERVATION'
    $targetId = $null

    if ($path -eq $canonicalPath) {
        $classification = 'CANONICAL_MASTER'
        $targetId = [string]$registry.canonical.id
    }
    elseif ($staticByPath.ContainsKey($key)) {
        $target = $staticByPath[$key]
        $targetId = [string]$target.id
        if ($hash -eq $canonicalHash) {
            $classification = 'MANAGED_REPLICA_MATCH'
        }
        elseif ((Get-SupportedGeneratedReplicaDriftState -Replica $target -ReplicaPath $path -CanonicalBytes $canonicalBytes).State -eq 'KNOWN_GENERATED_LEAN_CTX_SUFFIX_DRIFT') {
            $classification = 'KNOWN_GENERATED_LEAN_CTX_SUFFIX_DRIFT'
        }
        elseif ($target.PSObject.Properties.Name -contains 'inventory_classification_when_drift') {
            $classification = [string]$target.inventory_classification_when_drift
        }
        else {
            $classification = 'MANAGED_REPLICA_DRIFT'
        }
    }
    elseif ($worktreeByPath.ContainsKey($key)) {
        $classification = 'WORKTREE_REPLICA'
        $targetId = [string]$worktreeByPath[$key].id
    }
    elseif ($retiredWorktreeByPath.ContainsKey($key)) {
        $classification = 'RETIRED_UNREGISTERED_WORKTREE_ARTIFACT'
        $targetId = [string]$retiredWorktreeByPath[$key].id
    }
    elseif ($verificationArtifactByPath.ContainsKey($key)) {
        $classification = 'IMMUTABLE_VERIFICATION_ARTIFACT'
        $targetId = [string](Get-InventoryOptionalProperty -Object $verificationArtifactByPath[$key] -Name 'id' -Default 'verification-artifact')
    }
    elseif ($path -match '(?i)\\archives\\|\\backups\\|\\private-config\\evidence\\|\\archive\\|\\historical\\') {
        $classification = 'ARCHIVED_OR_HISTORICAL'
    }
    elseif ($path -match '(?i)\\node_modules\\|\\vendor\\|\\packages?\\|\\plugins?\\cache\\') {
        $classification = 'THIRD_PARTY_OR_VENDOR'
    }

    [pscustomobject]@{
        Path = $path
        Classification = $classification
        TargetId = $targetId
        Length = [int64]$file.Length
        Sha256 = $hash
        MatchesCanonical = ($hash -eq $canonicalHash)
    }
}

$counts = @($rows | Group-Object Classification | Sort-Object Name | ForEach-Object {
    [pscustomobject]@{ Classification = $_.Name; Count = $_.Count }
})
$document = [ordered]@{
    schema_version = 1
    generated_at = (Get-Date).ToUniversalTime().ToString('o')
    phase = $Phase
    scan_root = $scanRoot
    global_codex_agents = $globalPath
    canonical_path = $canonicalPath
    canonical_prechange_sha256 = [string]$registry.canonical.prechange_sha256
    canonical_sha256 = $canonicalHash
    total = $rows.Count
    counts = $counts
    files = @($rows)
}

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $repoRoot 'governance\agents\inventory'
}
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$date = (Get-Date).ToString('yyyy-MM-dd')
$base = "AGENTS_INVENTORY_${Phase}_$date"
$jsonPath = Join-Path $OutputDirectory "$base.json"
$csvPath = Join-Path $OutputDirectory "$base.csv"
$utf8NoBom = [Text.UTF8Encoding]::new($false)
[IO.File]::WriteAllText($jsonPath, (($document | ConvertTo-Json -Depth 8) + "`n"), $utf8NoBom)
$csvText = (@($rows | ConvertTo-Csv -NoTypeInformation) -join "`r`n") + "`r`n"
[IO.File]::WriteAllText($csvPath, $csvText, $utf8NoBom)

Write-Output "CANONICAL $canonicalHash $canonicalPath"
Write-Output "TOTAL $($rows.Count)"
$counts | Format-Table -AutoSize | Out-String | Write-Output
Write-Output "JSON $jsonPath"
Write-Output "CSV $csvPath"

$unknown = @($rows | Where-Object Classification -eq 'UNKNOWN_REQUIRES_PRESERVATION')
if ($unknown.Count -gt 0) {
    Write-Error "Inventory contains $($unknown.Count) unknown target(s); preserve and classify before synchronization."
    exit 1
}
