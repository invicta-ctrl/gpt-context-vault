[CmdletBinding()]
param([string]$VaultRoot = '')

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($VaultRoot)) {
    $VaultRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
}

function Assert-Test {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "A5_GOVERNANCE_TEST_FAILURE: $Message" }
    Write-Output ('PASS ' + $Message)
}

function Invoke-FixtureGit {
    param([Parameter(Mandatory)][string[]]$Arguments)
    $previousPathext = $env:PATHEXT
    $env:PATHEXT = '.COM;.EXE;.BAT;.CMD;.CPL'
    try {
        $null = & git @Arguments
        $exitCode = if (Test-Path -LiteralPath 'Variable:\LASTEXITCODE') { $LASTEXITCODE } else { 1 }
    }
    finally {
        $env:PATHEXT = $previousPathext
    }
    if ($exitCode -ne 0) { throw "fixture git failed: $($Arguments -join ' ')" }
}

$modulePath = Join-Path $PSScriptRoot 'RegisteredTargetDiscovery.psm1'
$registryPath = Join-Path $VaultRoot 'governance\agents\AGENTS_REGISTRY.json'
$canonicalPath = Join-Path $VaultRoot 'AGENTS.md'
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ('agents-a5-' + [Guid]::NewGuid().ToString('N'))

try {
    Import-Module $modulePath -Force
    $registry = Get-Content -LiteralPath $registryPath -Raw | ConvertFrom-Json
    $globalReplica = @($registry.managed_replicas | Where-Object { [string]$_.id -eq 'global-codex' }) | Select-Object -First 1
    Assert-Test ($null -ne $globalReplica) 'global Codex replica is registered'
    $canonicalBytes = [IO.File]::ReadAllBytes($canonicalPath)
    $suffix = [Convert]::FromBase64String([string]$globalReplica.supported_generated_drift.suffix_base64)

    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    $exactDriftPath = Join-Path $tempRoot 'exact-generated-drift.md'
    [IO.File]::WriteAllBytes($exactDriftPath, [byte[]]($canonicalBytes + $suffix))
    $exactDrift = Get-SupportedGeneratedReplicaDriftState -Replica $globalReplica -ReplicaPath $exactDriftPath -CanonicalBytes $canonicalBytes
    Assert-Test ($exactDrift.State -eq 'KNOWN_GENERATED_LEAN_CTX_SUFFIX_DRIFT') 'exact LeanCTX suffix is accepted only as known generated drift'

    $arbitraryPath = Join-Path $tempRoot 'arbitrary-generated-drift.md'
    [IO.File]::WriteAllBytes($arbitraryPath, [byte[]]($canonicalBytes + $suffix + [Text.UTF8Encoding]::new($false).GetBytes('arbitrary')))
    $arbitraryDrift = Get-SupportedGeneratedReplicaDriftState -Replica $globalReplica -ReplicaPath $arbitraryPath -CanonicalBytes $canonicalBytes
    Assert-Test ($arbitraryDrift.State -eq 'NOT_RECOGNIZED') 'arbitrary appended suffix is rejected'

    $anchorRoot = Join-Path $tempRoot 'anchor'
    $worktreeParent = Join-Path $tempRoot 'worktrees'
    $registeredWorktree = Join-Path $worktreeParent 'registered'
    $staleMarker = Join-Path $worktreeParent 'stale-marker'
    New-Item -ItemType Directory -Force -Path $anchorRoot,$worktreeParent,$staleMarker | Out-Null
    [IO.File]::WriteAllText((Join-Path $anchorRoot 'AGENTS.md'), "fixture canonical`n", [Text.UTF8Encoding]::new($false))
    New-Item -ItemType Directory -Force -Path (Join-Path $anchorRoot '.agents') | Out-Null
    [IO.File]::WriteAllText((Join-Path $anchorRoot '.agents\PROJECT_POLICY.md'), "fixture extension`n", [Text.UTF8Encoding]::new($false))
    Invoke-FixtureGit -Arguments @('init', $anchorRoot)
    Invoke-FixtureGit -Arguments @('-C', $anchorRoot, 'config', 'user.name', 'A5 Fixture')
    Invoke-FixtureGit -Arguments @('-C', $anchorRoot, 'config', 'user.email', 'a5-fixture@example.invalid')
    Invoke-FixtureGit -Arguments @('-C', $anchorRoot, 'add', 'AGENTS.md', '.agents/PROJECT_POLICY.md')
    Invoke-FixtureGit -Arguments @('-C', $anchorRoot, 'commit', '-m', 'fixture baseline')
    Invoke-FixtureGit -Arguments @('-C', $anchorRoot, 'worktree', 'add', '-b', 'fixture-registered', $registeredWorktree)
    [IO.File]::WriteAllText((Join-Path $staleMarker '.git'), "gitdir: retired`n", [Text.UTF8Encoding]::new($false))

    $fixtureRegistry = [pscustomobject]@{
        managed_worktree_groups = @([pscustomobject]@{
            id = 'fixture-worktree'
            root = $worktreeParent
            anchor_root = $anchorRoot
            repository = 'fixture'
            extension_source_id = 'minimal-project-extension-template'
            backup_root = (Join-Path $tempRoot 'backups')
            required = $true
        })
    }
    $targets = @(Get-RegisteredWorktreeTargets -Registry $fixtureRegistry)
    Assert-Test (@($targets.id) -contains 'fixture-worktree:registered') 'authoritative worktree list includes registered child'
    Assert-Test (-not (@($targets.id) -contains 'fixture-worktree:stale-marker')) 'stale .git marker child is excluded and preserved'

    $terminalRoot = Join-Path $tempRoot 'terminal-pointer'
    $activeRoot = Join-Path $tempRoot 'active-pointer'
    $explicitWriterRoot = Join-Path $tempRoot 'explicit-writer-pointer'
    New-Item -ItemType Directory -Force -Path (Join-Path $terminalRoot '.codex'),(Join-Path $activeRoot '.codex'),(Join-Path $explicitWriterRoot '.codex') | Out-Null
    [IO.File]::WriteAllText((Join-Path $terminalRoot '.codex\CURRENT.md'), "**Status:** CLOSED - VERIFIED AND PUSHED`n", [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $activeRoot '.codex\CURRENT.md'), "STATUS: ACTIVE`n", [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $explicitWriterRoot '.codex\CURRENT.md'), "STATUS: CLOSED`nACTIVE_WRITER: fixture-writer`n", [Text.UTF8Encoding]::new($false))
    Assert-Test ((Get-TargetWriterState -TargetRoot $terminalRoot) -eq 'NONE_TERMINAL_LEGACY_POINTER') 'terminal legacy pointer resolves to no writer'
    Assert-Test ((Get-TargetWriterState -TargetRoot $activeRoot) -eq 'POINTER_WITHOUT_WRITER_FIELD_ACTIVE') 'active pointer without writer remains blocked'
    Assert-Test ((Get-TargetWriterState -TargetRoot $explicitWriterRoot) -eq 'fixture-writer') 'explicit ACTIVE_WRITER wins over terminal status'

    [IO.File]::WriteAllText((Join-Path $anchorRoot 'AGENTS.md'), "managed drift`n", [Text.UTF8Encoding]::new($false))
    New-Item -ItemType Directory -Force -Path (Join-Path $anchorRoot '.ai-bridge') | Out-Null
    [IO.File]::WriteAllText((Join-Path $anchorRoot '.ai-bridge\residue.json'), "{}", [Text.UTF8Encoding]::new($false))
    Assert-Test ((Get-TargetGitDirtyState -TargetRoot $anchorRoot).State -eq 'MANAGED_OR_GENERATED_ONLY') 'managed policy and .ai-bridge residue are allowed dirty paths'
    New-Item -ItemType Directory -Force -Path (Join-Path $anchorRoot 'src') | Out-Null
    [IO.File]::WriteAllText((Join-Path $anchorRoot 'src\unrelated.py'), "x = 1`n", [Text.UTF8Encoding]::new($false))
    Assert-Test ((Get-TargetGitDirtyState -TargetRoot $anchorRoot).State -eq 'BLOCKED_UNRELATED_DIRTY_WORK') 'unrelated dirty source blocks synchronization'

    Write-Output 'SUMMARY PASS generated_drift=2 worktree_discovery=2 pointer=3 dirty=2'
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
