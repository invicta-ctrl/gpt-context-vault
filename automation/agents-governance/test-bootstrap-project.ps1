[CmdletBinding()]
param([string]$VaultRoot = '')

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($VaultRoot)) { $VaultRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..')) }
function Assert-Test([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw "BOOTSTRAP_TEST_FAILURE: $Message" }
    Write-Output ('PASS ' + $Message)
}
function Write-Json([string]$Path, $Value) {
    [IO.File]::WriteAllText($Path, (($Value | ConvertTo-Json -Depth 40) + "`n"), [Text.UTF8Encoding]::new($false))
}

$bootstrap = Join-Path $PSScriptRoot 'bootstrap-project.ps1'
$registryPath = Join-Path $VaultRoot 'governance\agents\AGENTS_REGISTRY.json'
$canonicalPath = Join-Path $VaultRoot 'AGENTS.md'
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ('agents-bootstrap-' + [Guid]::NewGuid().ToString('N'))

try {
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    $fixtureRegistryPath = Join-Path $tempRoot 'registry.json'
    $registry = Get-Content -LiteralPath $registryPath -Raw | ConvertFrom-Json
    $registry.managed_replicas = @()
    $registry.managed_worktree_groups = @()
    Write-Json -Path $fixtureRegistryPath -Value $registry
    $projectRoot = Join-Path $tempRoot 'project'
    $worktreeRoot = Join-Path $tempRoot 'worktrees'
    $backupRoot = Join-Path $tempRoot 'backups'
    New-Item -ItemType Directory -Force -Path $projectRoot,$worktreeRoot | Out-Null

    $params = @{
        ProjectRoot = $projectRoot
        ProjectId = 'bootstrap-fixture'
        RegistryPath = $fixtureRegistryPath
        ExtensionSourceId = 'minimal-project-extension-template'
        WorktreeRoot = $worktreeRoot
        BackupRoot = $backupRoot
        Register = $true
        Activate = $true
        InstallCanonical = $true
        CreateProjectExtension = $true
    }
    $dry = ((& $bootstrap @params) -join "`n") | ConvertFrom-Json
    Assert-Test ($dry.registration_action -eq 'WOULD_REGISTER') 'dry run registers only declaratively'
    Assert-Test ($dry.root_action -eq 'WOULD_CREATE') 'dry run reports missing canonical replica'
    Assert-Test (-not (Test-Path -LiteralPath (Join-Path $projectRoot 'AGENTS.md'))) 'dry run creates no AGENTS replica'

    $params.Apply = $true
    $apply = ((& $bootstrap @params) -join "`n") | ConvertFrom-Json
    Assert-Test ($apply.registration_action -eq 'REGISTERED') 'apply registers fixture target'
    Assert-Test ($apply.root_action -eq 'CREATED') 'apply installs canonical replica'
    Assert-Test ($apply.extension_action -eq 'CREATED') 'apply creates separate project extension'
    Assert-Test ($apply.worktree_action -eq 'REGISTERED') 'apply registers worktree group'
    Assert-Test ((Get-FileHash -LiteralPath (Join-Path $projectRoot 'AGENTS.md') -Algorithm SHA256).Hash.ToLowerInvariant() -eq (Get-FileHash -LiteralPath $canonicalPath -Algorithm SHA256).Hash.ToLowerInvariant()) 'installed replica is byte-identical'
    Assert-Test (Test-Path -LiteralPath $apply.backup_manifest -PathType Leaf) 'apply writes backup manifest'

    $repeat = ((& $bootstrap @params) -join "`n") | ConvertFrom-Json
    Assert-Test ($repeat.registration_action -eq 'MATCH' -and $repeat.root_action -eq 'MATCH') 'repeat apply is idempotent'
    Assert-Test ($repeat.extension_action -eq 'PRESERVED_EXISTING' -and $repeat.worktree_action -eq 'MATCH') 'repeat preserves extension and worktree group'

    [IO.File]::WriteAllText((Join-Path $projectRoot 'AGENTS.md'), 'deliberate fixture drift' + "`n", [Text.UTF8Encoding]::new($false))
    $driftParams = @{
        ProjectRoot = $projectRoot
        ProjectId = 'bootstrap-fixture'
        RegistryPath = $fixtureRegistryPath
        ExtensionSourceId = 'minimal-project-extension-template'
        BackupRoot = $backupRoot
        InstallCanonical = $true
    }
    $drift = ((& $bootstrap @driftParams) -join "`n") | ConvertFrom-Json
    Assert-Test ($drift.replica_state_before -eq 'DRIFT' -and $drift.root_action -eq 'WOULD_UPDATE') 'dry run detects deliberate replica drift'
    Assert-Test ((Get-Content -LiteralPath (Join-Path $projectRoot 'AGENTS.md') -Raw) -eq ('deliberate fixture drift' + "`n")) 'drift check does not overwrite replica'
    Write-Output 'SUMMARY PASS bootstrap_dry_run=3 bootstrap_apply=6 bootstrap_idempotence=2 drift_detection=2'
}
finally {
    if (Test-Path -LiteralPath $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force }
}
