Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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

function Get-RegisteredWorktreeTargets {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Registry)

    $targets = [Collections.Generic.List[object]]::new()
    if (-not ($Registry.PSObject.Properties.Name -contains 'managed_worktree_groups')) {
        return @($targets)
    }

    foreach ($group in $Registry.managed_worktree_groups) {
        $parent = [string]$group.root
        if ([string]::IsNullOrWhiteSpace($parent) -or -not [IO.Path]::IsPathRooted($parent)) {
            throw "Unsafe managed worktree-group root: $parent"
        }
        $parent = [IO.Path]::GetFullPath($parent)
        if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
            $targets.Add([pscustomobject]@{
                id = "$($group.id):root"
                path = (Join-Path $parent 'AGENTS.md')
                extension_path = (Join-Path $parent '.agents\PROJECT_POLICY.md')
                extension_source_id = [string]$group.extension_source_id
                repository = [string]$group.repository
                required = [bool]$group.required
                conditional = $false
                sync_allowed = $false
                gate_status = 'BLOCKED_DISCOVERY_ROOT_MISSING'
                mode = 'worktree'
                dynamic_target = $true
                backup_required = $true
                accept_any_prechange_with_backup = $true
                rollback = (Join-Path ([string]$group.backup_root) '<timestamp>\DISCOVERY_ROOT_MISSING\AGENTS.md')
            })
            continue
        }

        foreach ($directory in Get-ChildItem -LiteralPath $parent -Directory -Force | Sort-Object FullName) {
            $gitMarker = Join-Path $directory.FullName '.git'
            if (-not (Test-Path -LiteralPath $gitMarker)) {
                continue
            }

            $identityOk = Test-Path -LiteralPath $gitMarker

            $safeName = $directory.Name -replace '[^A-Za-z0-9._-]', '_'
            $targets.Add([pscustomobject]@{
                id = "$($group.id):$safeName"
                path = (Join-Path $directory.FullName 'AGENTS.md')
                extension_path = (Join-Path $directory.FullName '.agents\PROJECT_POLICY.md')
                extension_source_id = [string]$group.extension_source_id
                repository = [string]$group.repository
                required = [bool]$group.required
                conditional = $false
                sync_allowed = $identityOk
                gate_status = $(if ($identityOk) { 'REGISTERED_WORKTREE' } else { 'BLOCKED_GIT_IDENTITY' })
                mode = 'worktree'
                dynamic_target = $true
                backup_required = $true
                accept_any_prechange_with_backup = $true
                rollback = (Join-Path ([string]$group.backup_root) "<timestamp>\$safeName\AGENTS.md")
            })
        }
    }
    return @($targets)
}

Export-ModuleMember -Function Get-RegisteredWorktreeTargets
