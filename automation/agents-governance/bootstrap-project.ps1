[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ProjectRoot,
    [Parameter(Mandatory)][ValidatePattern('^[a-z0-9][a-z0-9-]*$')][string]$ProjectId,
    [string]$RegistryPath = '',
    [string]$ExtensionSourceId = 'minimal-project-extension-template',
    [string]$WorktreeRoot = '',
    [string]$Repository = '',
    [string]$BackupRoot = '',
    [switch]$Register,
    [switch]$Activate,
    [switch]$InstallCanonical,
    [switch]$CreateProjectExtension,
    [switch]$Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Bootstrap {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "BOOTSTRAP_VALIDATION: $Message" }
}
function Get-Sha256([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Get-OptionalProperty($Object, [string]$Name, $Default = $null) {
    if ($null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name) { return $Object.$Name }
    return $Default
}
function Write-JsonAtomic([string]$Path, $Value) {
    $fullPath = [IO.Path]::GetFullPath($Path)
    $parent = Split-Path -Parent $fullPath
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    $tempPath = Join-Path $parent ('.agents-bootstrap-' + [Guid]::NewGuid().ToString('N') + '.tmp')
    try {
        [IO.File]::WriteAllText($tempPath, (($Value | ConvertTo-Json -Depth 40) + "`n"), [Text.UTF8Encoding]::new($false))
        Move-Item -Force -LiteralPath $tempPath -Destination $fullPath
    }
    finally {
        if (Test-Path -LiteralPath $tempPath) { Remove-Item -Force -LiteralPath $tempPath }
    }
}
function Write-BytesAtomic([string]$Path, [byte[]]$Bytes) {
    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    $tempPath = Join-Path $parent ('.agents-bootstrap-' + [Guid]::NewGuid().ToString('N') + '.tmp')
    try {
        [IO.File]::WriteAllBytes($tempPath, $Bytes)
        Move-Item -Force -LiteralPath $tempPath -Destination $Path
    }
    finally {
        if (Test-Path -LiteralPath $tempPath) { Remove-Item -Force -LiteralPath $tempPath }
    }
}
function Get-WriterState([string]$Root) {
    $pointer = Join-Path $Root '.codex\CURRENT.md'
    if (-not (Test-Path -LiteralPath $pointer -PathType Leaf)) { return 'NO_POINTER' }
    $text = [IO.File]::ReadAllText($pointer)
    $match = [regex]::Match($text, '(?m)^ACTIVE_WRITER:\s*(?<value>[^\r\n]+)')
    if (-not $match.Success) { return 'POINTER_WITHOUT_WRITER_FIELD' }
    return $match.Groups['value'].Value.Trim()
}

$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
if ([string]::IsNullOrWhiteSpace($RegistryPath)) { $RegistryPath = Join-Path $repoRoot 'governance\agents\AGENTS_REGISTRY.json' }
$RegistryPath = [IO.Path]::GetFullPath($RegistryPath)
$ProjectRoot = [IO.Path]::GetFullPath($ProjectRoot)
Assert-Bootstrap (Test-Path -LiteralPath $ProjectRoot -PathType Container) "project root is missing: $ProjectRoot"
Assert-Bootstrap (Test-Path -LiteralPath $RegistryPath -PathType Leaf) "registry is missing: $RegistryPath"
if (-not [string]::IsNullOrWhiteSpace($WorktreeRoot)) {
    $WorktreeRoot = [IO.Path]::GetFullPath($WorktreeRoot)
    Assert-Bootstrap (Test-Path -LiteralPath $WorktreeRoot -PathType Container) "worktree root is missing: $WorktreeRoot"
    Assert-Bootstrap ($WorktreeRoot -ne $ProjectRoot) 'worktree root must differ from project root'
}
if (($Register -or $InstallCanonical -or $CreateProjectExtension) -and [string]::IsNullOrWhiteSpace($BackupRoot)) {
    Assert-Bootstrap $false 'BackupRoot is required for a bootstrap mutation plan.'
}
if (-not [string]::IsNullOrWhiteSpace($BackupRoot)) {
    Assert-Bootstrap ([IO.Path]::IsPathRooted($BackupRoot)) 'BackupRoot must be absolute.'
    $BackupRoot = [IO.Path]::GetFullPath($BackupRoot)
}

$registry = Get-Content -LiteralPath $RegistryPath -Raw | ConvertFrom-Json
$canonicalPath = Join-Path $repoRoot ([string]$registry.canonical.relative_path)
Assert-Bootstrap (Test-Path -LiteralPath $canonicalPath -PathType Leaf) "canonical AGENTS.md is missing: $canonicalPath"
$canonicalBytes = [IO.File]::ReadAllBytes($canonicalPath)
$canonicalHash = Get-Sha256 $canonicalPath
$extensionSourceEntry = @($registry.extension_sources | Where-Object { [string]$_.id -eq $ExtensionSourceId }) | Select-Object -First 1
Assert-Bootstrap ($null -ne $extensionSourceEntry) "extension source is not registered: $ExtensionSourceId"
$extensionSourcePath = [IO.Path]::GetFullPath((Join-Path $repoRoot ([string]$extensionSourceEntry.source_relative_path)))
Assert-Bootstrap (Test-Path -LiteralPath $extensionSourcePath -PathType Leaf) "extension source is missing: $extensionSourcePath"
$extensionBytes = [IO.File]::ReadAllBytes($extensionSourcePath)
$extensionHash = Get-Sha256 $extensionSourcePath

$agentsPath = Join-Path $ProjectRoot 'AGENTS.md'
$extensionPath = Join-Path $ProjectRoot '.agents\PROJECT_POLICY.md'
$agentsExists = Test-Path -LiteralPath $agentsPath -PathType Leaf
$extensionExists = Test-Path -LiteralPath $extensionPath -PathType Leaf
$agentsHash = if ($agentsExists) { Get-Sha256 $agentsPath } else { $null }
$extensionCurrentHash = if ($extensionExists) { Get-Sha256 $extensionPath } else { $null }
$replicaState = if (-not $agentsExists) { 'MISSING' } elseif ($agentsHash -eq $canonicalHash) { 'MATCH' } else { 'DRIFT' }
$extensionState = if (-not $extensionExists) { 'MISSING' } elseif ($extensionCurrentHash -eq $extensionHash) { 'MATCH' } else { 'PRESERVED_PROJECT_SPECIFIC_OR_DRIFT' }
$writerState = Get-WriterState -Root $ProjectRoot

$registered = @($registry.managed_replicas | Where-Object { [IO.Path]::GetFullPath([string]$_.path).ToLowerInvariant() -eq $agentsPath.ToLowerInvariant() }) | Select-Object -First 1
$registrationAction = 'NOT_REQUESTED'
if ($Register) {
    if ($null -ne $registered) {
        Assert-Bootstrap ([string]$registered.id -eq $ProjectId) "project root is already registered under a different id: $($registered.id)"
        Assert-Bootstrap ([string](Get-OptionalProperty $registered 'extension_source_id' $ExtensionSourceId) -eq $ExtensionSourceId) 'existing registration has a different extension source'
        $registrationAction = 'MATCH'
    }
    else {
        $registrationAction = if ($Apply) { 'REGISTERED' } else { 'WOULD_REGISTER' }
    }
}

$activationAllowed = $null -ne $registered -and [bool](Get-OptionalProperty $registered 'sync_allowed' $false)
if ($Register -and $Activate) { $activationAllowed = $true }
$rootAction = if (-not $InstallCanonical) { 'NOT_REQUESTED' } elseif (-not $activationAllowed) { 'BLOCKED_PENDING_ACCEPTED_GATE' } elseif ($replicaState -eq 'MATCH') { 'MATCH' } elseif ($Apply) { if ($agentsExists) { 'UPDATED' } else { 'CREATED' } } elseif ($agentsExists) { 'WOULD_UPDATE' } else { 'WOULD_CREATE' }
$extensionAction = if (-not $CreateProjectExtension) { 'NOT_REQUESTED' } elseif ($extensionExists) { 'PRESERVED_EXISTING' } elseif ($Apply) { 'CREATED' } else { 'WOULD_CREATE' }
$worktreeAction = if ([string]::IsNullOrWhiteSpace($WorktreeRoot)) { 'NOT_REQUESTED' } else { 'PENDING' }

if ($InstallCanonical -and $writerState -notin @('NO_POINTER', 'NONE')) {
    $rootAction = 'BLOCKED_ACTIVE_WRITER'
}

$result = [ordered]@{
    schema_version = 1
    project_id = $ProjectId
    project_root = $ProjectRoot
    apply = [bool]$Apply
    canonical_sha256 = $canonicalHash
    replica_state_before = $replicaState
    extension_state_before = $extensionState
    writer_state = $writerState
    registration_action = $registrationAction
    root_action = $rootAction
    extension_action = $extensionAction
    worktree_action = $worktreeAction
    backup_root = $BackupRoot
    note = 'Dry run by default. Existing project extensions are never overwritten by this command; subsequent updates use sync-agents.ps1.'
}

if (-not $Apply) {
    $result | ConvertTo-Json -Depth 12
    exit 0
}
if ($rootAction -like 'BLOCKED*') {
    throw "BOOTSTRAP_VALIDATION: canonical installation is blocked: $rootAction"
}

$timestamp = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ')
$backupDirectory = Join-Path $BackupRoot $timestamp
New-Item -ItemType Directory -Force -Path $backupDirectory | Out-Null
$manifestFiles = [Collections.Generic.List[object]]::new()
function Backup-IfPresent([string]$Source, [string]$RelativeName) {
    if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) { return }
    $destination = Join-Path $backupDirectory $RelativeName
    $parent = Split-Path -Parent $destination
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    Copy-Item -LiteralPath $Source -Destination $destination
    $sourceHash = Get-Sha256 $Source
    $backupHash = Get-Sha256 $destination
    Assert-Bootstrap ($sourceHash -eq $backupHash) "backup hash mismatch: $Source"
    $manifestFiles.Add([ordered]@{ source_path = $Source; backup_path = $destination; byte_count = (Get-Item -LiteralPath $Source).Length; source_sha256 = $sourceHash; backup_sha256 = $backupHash; equality = $true })
}

if ($Register -and $registrationAction -eq 'REGISTERED') { Backup-IfPresent -Source $RegistryPath -RelativeName 'AGENTS_REGISTRY.json' }
if ($rootAction -eq 'UPDATED') { Backup-IfPresent -Source $agentsPath -RelativeName 'AGENTS.md' }
if ($extensionAction -eq 'PRESERVED_EXISTING') { Backup-IfPresent -Source $extensionPath -RelativeName 'PROJECT_POLICY.md' }

if ($Register -and $registrationAction -eq 'REGISTERED') {
    $newReplica = [pscustomobject]@{
        id = $ProjectId
        path = $agentsPath
        extension_path = $extensionPath
        extension_source_id = $ExtensionSourceId
        repository = if ([string]::IsNullOrWhiteSpace($Repository)) { $null } else { $Repository }
        required = $false
        conditional = $true
        sync_allowed = [bool]$Activate
        gate_status = if ($Activate) { 'ACTIVE_EXPLICIT_BOOTSTRAP' } else { 'PENDING_ACCEPTED_GATE' }
        prechange_sha256 = if ($agentsExists) { $agentsHash } else { $canonicalHash }
        prechange_extension_exists = [bool]($extensionExists -or $CreateProjectExtension)
        prechange_extension_sha256 = if ($extensionExists) { $extensionCurrentHash } else { $extensionHash }
        rollback = (Join-Path $BackupRoot '<timestamp>\AGENTS.md')
        backup_required = $true
        inventory_classification_when_drift = 'MANAGED_REPLICA_DRIFT'
        notes = 'Created by explicit dry-run-first bootstrap; activate only under accepted authority.'
    }
    $registry.managed_replicas = @($registry.managed_replicas) + @($newReplica)
}

if (-not [string]::IsNullOrWhiteSpace($WorktreeRoot)) {
    $groupId = $ProjectId + '-worktree'
    $group = @($registry.managed_worktree_groups | Where-Object { [string]$_.id -eq $groupId }) | Select-Object -First 1
    if ($null -eq $group) {
        $worktreeAction = 'REGISTERED'
        $newGroup = [pscustomobject]@{
            id = $groupId
            root = $WorktreeRoot
            anchor_root = $ProjectRoot
            repository = if ([string]::IsNullOrWhiteSpace($Repository)) { $null } else { $Repository }
            extension_source_id = $ExtensionSourceId
            backup_root = (Join-Path $BackupRoot 'worktrees')
            required = $false
            discovery = 'authoritative-anchor-git-worktree-list'
            unknown_non_git_children = 'ignored_and_preserved'
        }
        $registry.managed_worktree_groups = @($registry.managed_worktree_groups) + @($newGroup)
    }
    else {
        Assert-Bootstrap ([IO.Path]::GetFullPath([string]$group.root).ToLowerInvariant() -eq $WorktreeRoot.ToLowerInvariant()) 'existing worktree group has a different root'
        Assert-Bootstrap ([IO.Path]::GetFullPath([string]$group.anchor_root).ToLowerInvariant() -eq $ProjectRoot.ToLowerInvariant()) 'existing worktree group has a different anchor root'
        $worktreeAction = 'MATCH'
    }
}

if ($rootAction -in @('UPDATED', 'CREATED')) { Write-BytesAtomic -Path $agentsPath -Bytes $canonicalBytes }
if ($extensionAction -eq 'CREATED') { Write-BytesAtomic -Path $extensionPath -Bytes $extensionBytes }
if ($Register -and $registrationAction -eq 'REGISTERED') { Write-JsonAtomic -Path $RegistryPath -Value $registry }

if ($rootAction -in @('UPDATED', 'CREATED')) { Assert-Bootstrap ((Get-Sha256 $agentsPath) -eq $canonicalHash) 'installed AGENTS.md is not byte-identical to canonical' }
if ($extensionAction -eq 'CREATED') { Assert-Bootstrap ((Get-Sha256 $extensionPath) -eq $extensionHash) 'created project extension does not match its registered source' }
$manifest = [ordered]@{ schema_version = 1; change_id = 'AGENTS-BOOTSTRAP'; generated_at = (Get-Date).ToUniversalTime().ToString('o'); files = @($manifestFiles) }
Write-JsonAtomic -Path (Join-Path $backupDirectory 'manifest.json') -Value $manifest

$result.registration_action = $registrationAction
$result.root_action = $rootAction
$result.extension_action = $extensionAction
$result.worktree_action = $worktreeAction
$result.backup_manifest = Join-Path $backupDirectory 'manifest.json'
$result | ConvertTo-Json -Depth 12
