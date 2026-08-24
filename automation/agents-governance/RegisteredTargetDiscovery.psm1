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

function Get-NormalizedAbsolutePath {
    param([Parameter(Mandatory)][string]$Path)

    $full = [IO.Path]::GetFullPath($Path)
    $root = [IO.Path]::GetPathRoot($full)
    if ($full.Length -gt $root.Length) {
        $full = $full.TrimEnd([char[]]@('\', '/'))
    }
    return $full
}

function Get-GitExecutable {
    $previousPathext = $env:PATHEXT
    if ([string]::IsNullOrWhiteSpace($previousPathext) -or $previousPathext -notmatch '(?i)(?:^|;)\.EXE(?:;|$)') {
        $env:PATHEXT = '.COM;.EXE;.BAT;.CMD;.CPL'
    }
    try {
        if ($null -ne (Get-Command -Name 'git' -ErrorAction SilentlyContinue | Select-Object -First 1)) {
            return 'git'
        }
        return $null
    }
    finally {
        $env:PATHEXT = $previousPathext
    }
}

function Invoke-GitText {
    param(
        [Parameter(Mandatory)][string]$GitExecutable,
        [Parameter(Mandatory)][string[]]$Arguments
    )

    $previousPathext = $env:PATHEXT
    if ([string]::IsNullOrWhiteSpace($previousPathext) -or $previousPathext -notmatch '(?i)(?:^|;)\.EXE(?:;|$)') {
        $env:PATHEXT = '.COM;.EXE;.BAT;.CMD;.CPL'
    }
    $exitCode = 1
    try {
        $output = @(& $GitExecutable @Arguments 2>&1 | ForEach-Object { $_.ToString() })
        if (Test-Path -LiteralPath 'Variable:\LASTEXITCODE') {
            $exitCode = $LASTEXITCODE
        }
    }
    finally {
        $env:PATHEXT = $previousPathext
    }
    [pscustomobject]@{
        ExitCode = $exitCode
        Output = $output
    }
}

function Test-ImmediateChildPath {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Parent
    )

    $candidateParent = Get-NormalizedAbsolutePath -Path (Split-Path -Parent $Path)
    $normalizedParent = Get-NormalizedAbsolutePath -Path $Parent
    return $candidateParent.Equals($normalizedParent, [StringComparison]::OrdinalIgnoreCase)
}

function New-DiscoveryBlockedTarget {
    param(
        [Parameter(Mandatory)]$Group,
        [Parameter(Mandatory)][string]$Suffix,
        [Parameter(Mandatory)][string]$Root,
        [Parameter(Mandatory)][string]$GateStatus,
        [Parameter(Mandatory)][string]$RollbackName
    )

    [pscustomobject]@{
        id = "$($Group.id):$Suffix"
        path = (Join-Path $Root 'AGENTS.md')
        extension_path = (Join-Path $Root '.agents\PROJECT_POLICY.md')
        extension_source_id = [string]$Group.extension_source_id
        repository = [string]$Group.repository
        required = [bool]$Group.required
        conditional = $false
        sync_allowed = $false
        gate_status = $GateStatus
        mode = 'worktree'
        dynamic_target = $true
        backup_required = $true
        accept_any_prechange_with_backup = $true
        rollback = (Join-Path ([string]$Group.backup_root) "<timestamp>\$RollbackName\AGENTS.md")
    }
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
        $parent = Get-NormalizedAbsolutePath -Path $parent
        if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
            $targets.Add((New-DiscoveryBlockedTarget -Group $group -Suffix 'root' -Root $parent -GateStatus 'BLOCKED_DISCOVERY_ROOT_MISSING' -RollbackName 'DISCOVERY_ROOT_MISSING'))
            continue
        }

        $anchorRoot = [string](Get-OptionalProperty -Object $group -Name 'anchor_root' -Default '')
        if ([string]::IsNullOrWhiteSpace($anchorRoot) -or -not [IO.Path]::IsPathRooted($anchorRoot)) {
            $targets.Add((New-DiscoveryBlockedTarget -Group $group -Suffix 'anchor' -Root $parent -GateStatus 'BLOCKED_DISCOVERY_ANCHOR_INVALID' -RollbackName 'DISCOVERY_ANCHOR_INVALID'))
            continue
        }
        $anchorRoot = Get-NormalizedAbsolutePath -Path $anchorRoot
        if (-not (Test-Path -LiteralPath $anchorRoot -PathType Container)) {
            $targets.Add((New-DiscoveryBlockedTarget -Group $group -Suffix 'anchor' -Root $anchorRoot -GateStatus 'BLOCKED_DISCOVERY_ANCHOR_MISSING' -RollbackName 'DISCOVERY_ANCHOR_MISSING'))
            continue
        }

        $git = Get-GitExecutable
        if ([string]::IsNullOrWhiteSpace($git)) {
            $targets.Add((New-DiscoveryBlockedTarget -Group $group -Suffix 'anchor' -Root $anchorRoot -GateStatus 'BLOCKED_GIT_UNAVAILABLE' -RollbackName 'GIT_UNAVAILABLE'))
            continue
        }
        $worktreeList = Invoke-GitText -GitExecutable $git -Arguments @('-C', $anchorRoot, 'worktree', 'list', '--porcelain')
        if ($worktreeList.ExitCode -ne 0) {
            $targets.Add((New-DiscoveryBlockedTarget -Group $group -Suffix 'anchor' -Root $anchorRoot -GateStatus 'BLOCKED_WORKTREE_ANCHOR_GIT_FAILED' -RollbackName 'WORKTREE_ANCHOR_GIT_FAILED'))
            continue
        }

        $registeredRoots = [Collections.Generic.List[string]]::new()
        foreach ($line in $worktreeList.Output) {
            $match = [regex]::Match($line, '^worktree (?<path>.+)$')
            if (-not $match.Success) {
                continue
            }
            try {
                $worktreeRoot = Get-NormalizedAbsolutePath -Path $match.Groups['path'].Value
            }
            catch {
                continue
            }
            if (Test-ImmediateChildPath -Path $worktreeRoot -Parent $parent) {
                $registeredRoots.Add($worktreeRoot)
            }
        }

        foreach ($worktreeRoot in @($registeredRoots | Sort-Object -Unique)) {
            $safeName = (Split-Path -Leaf $worktreeRoot) -replace '[^A-Za-z0-9._-]', '_'
            $exists = Test-Path -LiteralPath $worktreeRoot -PathType Container
            $targets.Add([pscustomobject]@{
                id = "$($group.id):$safeName"
                path = (Join-Path $worktreeRoot 'AGENTS.md')
                extension_path = (Join-Path $worktreeRoot '.agents\PROJECT_POLICY.md')
                extension_source_id = [string]$group.extension_source_id
                repository = [string]$group.repository
                required = [bool]$group.required
                conditional = $false
                sync_allowed = [bool]$exists
                gate_status = $(if ($exists) { 'REGISTERED_WORKTREE' } else { 'BLOCKED_REGISTERED_WORKTREE_MISSING' })
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

function Get-TargetWriterState {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$TargetRoot)

    $pointer = Join-Path $TargetRoot '.codex\CURRENT.md'
    if (-not (Test-Path -LiteralPath $pointer -PathType Leaf)) {
        return 'NO_POINTER'
    }
    $text = [IO.File]::ReadAllText($pointer)
    $writer = [regex]::Match($text, '(?mi)^\s*(?:\*\*)?ACTIVE_WRITER\s*:\s*(?:\*\*)?\s*(?<writer>[^\r\n]*)$')
    if ($writer.Success) {
        $value = $writer.Groups['writer'].Value.Trim()
        if ($value -eq 'NONE') {
            return 'NONE'
        }
        if ([string]::IsNullOrWhiteSpace($value)) {
            return 'ACTIVE_WRITER_FIELD_EMPTY'
        }
        return $value
    }

    $status = [regex]::Match($text, '(?mi)^\s*(?:\*\*)?STATUS\s*:\s*(?:\*\*)?\s*(?<status>[^\r\n]*)$')
    if ($status.Success) {
        $value = $status.Groups['status'].Value.Trim()
        if ($value -match '^(?:CLOSED|COMPLETE)\b') {
            return 'NONE_TERMINAL_LEGACY_POINTER'
        }
        if ($value -match '^ACTIVE\b') {
            return 'POINTER_WITHOUT_WRITER_FIELD_ACTIVE'
        }
    }
    return 'POINTER_WITHOUT_WRITER_FIELD'
}

function Get-TargetGitDirtyState {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$TargetRoot)

    if (-not (Test-Path -LiteralPath $TargetRoot -PathType Container)) {
        return [pscustomobject]@{ State = 'BLOCKED_TARGET_ROOT_MISSING'; Detail = $TargetRoot; Paths = @() }
    }
    $gitMarker = Join-Path $TargetRoot '.git'
    if (-not (Test-Path -LiteralPath $gitMarker)) {
        return [pscustomobject]@{ State = 'NON_GIT_TARGET'; Detail = 'no .git marker'; Paths = @() }
    }

    $git = Get-GitExecutable
    if ([string]::IsNullOrWhiteSpace($git)) {
        return [pscustomobject]@{ State = 'BLOCKED_GIT_UNAVAILABLE'; Detail = 'git.exe unavailable'; Paths = @() }
    }
    $identity = Invoke-GitText -GitExecutable $git -Arguments @('-C', $TargetRoot, 'rev-parse', '--show-toplevel')
    if ($identity.ExitCode -ne 0 -or $identity.Output.Count -ne 1) {
        return [pscustomobject]@{ State = 'BLOCKED_GIT_IDENTITY'; Detail = ($identity.Output -join '; '); Paths = @() }
    }
    $resolvedRoot = Get-NormalizedAbsolutePath -Path $identity.Output[0]
    $expectedRoot = Get-NormalizedAbsolutePath -Path $TargetRoot
    if (-not $resolvedRoot.Equals($expectedRoot, [StringComparison]::OrdinalIgnoreCase)) {
        return [pscustomobject]@{ State = 'BLOCKED_GIT_ROOT_MISMATCH'; Detail = "expected=$expectedRoot actual=$resolvedRoot"; Paths = @() }
    }

    $status = Invoke-GitText -GitExecutable $git -Arguments @('-C', $TargetRoot, 'status', '--porcelain=v1', '--untracked-files=all')
    if ($status.ExitCode -ne 0) {
        return [pscustomobject]@{ State = 'BLOCKED_GIT_STATUS_FAILED'; Detail = ($status.Output -join '; '); Paths = @() }
    }
    $paths = [Collections.Generic.List[string]]::new()
    foreach ($line in $status.Output) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }
        if ($line.Length -lt 4) {
            $paths.Add($line)
            continue
        }
        $paths.Add($line.Substring(3))
    }
    if ($paths.Count -eq 0) {
        return [pscustomobject]@{ State = 'CLEAN'; Detail = 'clean'; Paths = @() }
    }

    $unrelated = [Collections.Generic.List[string]]::new()
    foreach ($path in $paths) {
        $normalized = $path.Replace('\', '/')
        if ($normalized.StartsWith('./')) {
            $normalized = $normalized.Substring(2)
        }
        $allowed = $normalized.Equals('AGENTS.md', [StringComparison]::OrdinalIgnoreCase) -or
            $normalized.Equals('.agents/PROJECT_POLICY.md', [StringComparison]::OrdinalIgnoreCase) -or
            $normalized.StartsWith('.ai-bridge/', [StringComparison]::OrdinalIgnoreCase)
        if (-not $allowed) {
            $unrelated.Add($path)
        }
    }
    if ($unrelated.Count -gt 0) {
        return [pscustomobject]@{
            State = 'BLOCKED_UNRELATED_DIRTY_WORK'
            Detail = ($unrelated | Sort-Object -Unique) -join ', '
            Paths = @($paths)
        }
    }
    return [pscustomobject]@{
        State = 'MANAGED_OR_GENERATED_ONLY'
        Detail = (@($paths | Sort-Object -Unique) -join ', ')
        Paths = @($paths)
    }
}

function Get-SupportedGeneratedReplicaDriftState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Replica,
        [Parameter(Mandatory)][string]$ReplicaPath,
        [Parameter(Mandatory)][byte[]]$CanonicalBytes
    )

    if (-not (Test-Path -LiteralPath $ReplicaPath -PathType Leaf)) {
        return [pscustomobject]@{ State = 'NOT_PRESENT'; Detail = 'replica missing' }
    }
    $actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $ReplicaPath).Hash.ToLowerInvariant()
    $canonicalHash = ([BitConverter]::ToString(([Security.Cryptography.SHA256]::Create().ComputeHash($CanonicalBytes))).Replace('-', '').ToLowerInvariant())
    if ($actualHash -eq $canonicalHash) {
        return [pscustomobject]@{ State = 'MATCH'; Detail = $actualHash }
    }
    if ([string]$Replica.id -ne 'global-codex' -or -not ($Replica.PSObject.Properties.Name -contains 'supported_generated_drift')) {
        return [pscustomobject]@{ State = 'NOT_APPLICABLE'; Detail = $actualHash }
    }

    $definition = $Replica.supported_generated_drift
    if ([string](Get-OptionalProperty -Object $definition -Name 'kind' -Default '') -ne 'canonical_plus_exact_lean_ctx_suffix') {
        return [pscustomobject]@{ State = 'INVALID_GENERATED_DRIFT_REGISTRATION'; Detail = 'unsupported kind' }
    }
    $observedHash = [string](Get-OptionalProperty -Object $definition -Name 'observed_sha256' -Default '')
    $registeredSuffixHash = [string](Get-OptionalProperty -Object $definition -Name 'suffix_sha256' -Default '')
    $suffixBase64 = [string](Get-OptionalProperty -Object $definition -Name 'suffix_base64' -Default '')
    try {
        $suffix = [Convert]::FromBase64String($suffixBase64)
        $suffixText = [Text.UTF8Encoding]::new($false).GetString($suffix)
    }
    catch {
        return [pscustomobject]@{ State = 'INVALID_GENERATED_DRIFT_REGISTRATION'; Detail = 'invalid suffix encoding' }
    }
    $beginMarker = '<!-- lean-ctx -->'
    $endMarker = '<!-- /lean-ctx -->'
    if (-not $suffixText.StartsWith("`n$beginMarker`n") -or -not $suffixText.EndsWith("$endMarker`n") -or
        ([regex]::Matches($suffixText, [regex]::Escape($beginMarker))).Count -ne 1 -or
        ([regex]::Matches($suffixText, [regex]::Escape($endMarker))).Count -ne 1) {
        return [pscustomobject]@{ State = 'INVALID_GENERATED_DRIFT_REGISTRATION'; Detail = 'suffix markers are not exact and singular' }
    }

    $actualBytes = [IO.File]::ReadAllBytes($ReplicaPath)
    $expectedBytes = [byte[]]($CanonicalBytes + $suffix)
    $matchesBytes = $actualBytes.Length -eq $expectedBytes.Length
    if ($matchesBytes) {
        for ($index = 0; $index -lt $expectedBytes.Length; $index++) {
            if ($actualBytes[$index] -ne $expectedBytes[$index]) {
                $matchesBytes = $false
                break
            }
        }
    }
    $suffixHash = ([BitConverter]::ToString(([Security.Cryptography.SHA256]::Create().ComputeHash($suffix))).Replace('-', '').ToLowerInvariant())
    if ($registeredSuffixHash -and $suffixHash -ne $registeredSuffixHash.ToLowerInvariant()) {
        return [pscustomobject]@{ State = 'INVALID_GENERATED_DRIFT_REGISTRATION'; Detail = 'suffix hash does not match registry' }
    }
    if ($matchesBytes) {
        return [pscustomobject]@{
            State = 'KNOWN_GENERATED_LEAN_CTX_SUFFIX_DRIFT'
            Detail = "actual=$actualHash registered_observed=$observedHash suffix_sha256=$suffixHash"
        }
    }
    $endsWithRegisteredSuffix = $actualBytes.Length -gt $suffix.Length
    if ($endsWithRegisteredSuffix) {
        $offset = $actualBytes.Length - $suffix.Length
        for ($index = 0; $index -lt $suffix.Length; $index++) {
            if ($actualBytes[$offset + $index] -ne $suffix[$index]) {
                $endsWithRegisteredSuffix = $false
                break
            }
        }
    }
    if ($observedHash -and $actualHash -eq $observedHash.ToLowerInvariant() -and $endsWithRegisteredSuffix) {
        return [pscustomobject]@{
            State = 'KNOWN_GENERATED_LEAN_CTX_SUFFIX_DRIFT'
            Detail = "registered_historical_observation=$actualHash suffix_sha256=$suffixHash"
        }
    }
    return [pscustomobject]@{ State = 'NOT_RECOGNIZED'; Detail = "actual=$actualHash" }
}

Export-ModuleMember -Function Get-RegisteredWorktreeTargets, Get-TargetWriterState, Get-TargetGitDirtyState, Get-SupportedGeneratedReplicaDriftState
