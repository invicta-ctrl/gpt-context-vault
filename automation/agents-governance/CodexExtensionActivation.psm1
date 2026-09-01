Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-AeSha256 {
    param([Parameter(Mandatory)][string]$Path)
    (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Get-AeUtf8TextSha256 {
    param([Parameter(Mandatory)][string]$Text)
    $bytes = [Text.UTF8Encoding]::new($false).GetBytes($Text)
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

function Get-AeOptionalProperty {
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

function Write-AeAtomicUtf8 {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Text
    )
    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    $temp = Join-Path $parent ('.agents-activation-' + [Guid]::NewGuid().ToString('N') + '.tmp')
    try {
        [IO.File]::WriteAllText($temp, $Text, [Text.UTF8Encoding]::new($false))
        Move-Item -Force -LiteralPath $temp -Destination $Path
    }
    finally {
        if (Test-Path -LiteralPath $temp) {
            Remove-Item -Force -LiteralPath $temp
        }
    }
}

function Get-CodexDeveloperInstructionsState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ConfigPath,
        [Parameter(Mandatory)][string]$BeginMarker,
        [Parameter(Mandatory)][string]$EndMarker
    )

    if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
        return [pscustomobject]@{
            ConfigExists = $false; ConfigText = $null; ConfigHash = $null
            ManagedExists = $false; ManagedContentHash = $null; ManagedMetadataHash = $null
            SpanStart = -1; SpanLength = 0; Eol = "`n"; Conflict = $false; Detail = 'config missing'
        }
    }

    $text = [IO.File]::ReadAllText($ConfigPath)
    $configHash = Get-AeSha256 $ConfigPath
    $beginCount = ([regex]::Matches($text, [regex]::Escape($BeginMarker))).Count
    $endCount = ([regex]::Matches($text, [regex]::Escape($EndMarker))).Count
    $eol = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }

    if ($beginCount -eq 0 -and $endCount -eq 0) {
        return [pscustomobject]@{
            ConfigExists = $true; ConfigText = $text; ConfigHash = $configHash
            ManagedExists = $false; ManagedContentHash = $null; ManagedMetadataHash = $null
            SpanStart = -1; SpanLength = 0; Eol = $eol; Conflict = $false; Detail = 'managed block absent'
        }
    }
    if ($beginCount -ne 1 -or $endCount -ne 1) {
        return [pscustomobject]@{
            ConfigExists = $true; ConfigText = $text; ConfigHash = $configHash
            ManagedExists = $false; ManagedContentHash = $null; ManagedMetadataHash = $null
            SpanStart = -1; SpanLength = 0; Eol = $eol; Conflict = $true
            Detail = "marker count begin=$beginCount end=$endCount"
        }
    }

    $pattern = '(?s)' + [regex]::Escape($BeginMarker) +
        "\r?\n# source_sha256 = (?<metadata>[0-9a-f]{64})\r?\n" +
        "developer_instructions = '''\r?\n(?<content>.*?)'''\r?\n" +
        [regex]::Escape($EndMarker)
    $matches = [regex]::Matches($text, $pattern)
    if ($matches.Count -ne 1) {
        return [pscustomobject]@{
            ConfigExists = $true; ConfigText = $text; ConfigHash = $configHash
            ManagedExists = $false; ManagedContentHash = $null; ManagedMetadataHash = $null
            SpanStart = -1; SpanLength = 0; Eol = $eol; Conflict = $true
            Detail = 'managed block exists but format is invalid'
        }
    }

    $match = $matches[0]
    $content = $match.Groups['content'].Value.Replace("`r`n", "`n")
    [pscustomobject]@{
        ConfigExists = $true; ConfigText = $text; ConfigHash = $configHash
        ManagedExists = $true; ManagedContentHash = Get-AeUtf8TextSha256 $content
        ManagedMetadataHash = $match.Groups['metadata'].Value
        SpanStart = $match.Index; SpanLength = $match.Length; Eol = $eol
        Conflict = $false; Detail = 'managed block parsed'
    }
}

function Get-AeSourceState {
    param([Parameter(Mandatory)][string]$ExtensionSource)
    if (-not (Test-Path -LiteralPath $ExtensionSource -PathType Leaf)) {
        throw "Extension source is missing: $ExtensionSource"
    }
    $sourceText = [IO.File]::ReadAllText($ExtensionSource).Replace("`r`n", "`n")
    if (-not $sourceText.EndsWith("`n")) {
        throw 'Extension source must end with LF.'
    }
    if ($sourceText.Contains("'''")) {
        throw "Extension source contains TOML multiline-literal delimiter '''."
    }
    $sourceHash = Get-AeUtf8TextSha256 $sourceText
    $fileHash = Get-AeSha256 $ExtensionSource
    if ($sourceHash -ne $fileHash) {
        throw "Extension source is not LF-stable: text=$sourceHash file=$fileHash"
    }
    [pscustomobject]@{ Text = $sourceText; Hash = $sourceHash }
}

function Test-CodexDeveloperInstructionsActivation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Activation,
        [Parameter(Mandatory)][string]$ExtensionSource
    )

    $kind = [string](Get-AeOptionalProperty -Object $Activation -Name 'kind' -Default '')
    if ($kind -ne 'codex_developer_instructions') {
        return [pscustomobject]@{ State = 'UNSUPPORTED'; Detail = "kind=$kind" }
    }

    $source = Get-AeSourceState $ExtensionSource
    $state = Get-CodexDeveloperInstructionsState `
        -ConfigPath ([string]$Activation.config_path) `
        -BeginMarker ([string]$Activation.begin_marker) `
        -EndMarker ([string]$Activation.end_marker)

    if (-not $state.ConfigExists) {
        return [pscustomobject]@{ State = 'MISSING'; Detail = [string]$Activation.config_path }
    }
    if ($state.Conflict) {
        return [pscustomobject]@{ State = 'CONFLICT'; Detail = $state.Detail }
    }
    if (-not $state.ManagedExists) {
        return [pscustomobject]@{ State = 'MISSING'; Detail = 'managed developer_instructions block absent' }
    }
    if ($state.ManagedContentHash -eq $source.Hash -and
        $state.ManagedMetadataHash -eq $source.Hash) {
        return [pscustomobject]@{
            State = 'MATCH'
            Detail = "value=$($source.Hash) config=$([string]$Activation.config_path)"
        }
    }

    [pscustomobject]@{
        State = 'DRIFT'
        Detail = "expected=$($source.Hash) metadata=$($state.ManagedMetadataHash) content=$($state.ManagedContentHash)"
    }
}

function Invoke-CodexDeveloperInstructionsSync {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Activation,
        [Parameter(Mandatory)][string]$ExtensionSource,
        [Parameter(Mandatory)][string]$Timestamp,
        [switch]$Apply
    )

    $kind = [string](Get-AeOptionalProperty -Object $Activation -Name 'kind' -Default '')
    if ($kind -ne 'codex_developer_instructions') {
        throw "Unsupported extension activation kind: $kind"
    }

    $configPath = [string]$Activation.config_path
    $beginMarker = [string]$Activation.begin_marker
    $endMarker = [string]$Activation.end_marker
    if ([string]::IsNullOrWhiteSpace($configPath) -or -not [IO.Path]::IsPathRooted($configPath)) {
        throw 'Activation config path is unsafe or non-absolute.'
    }
    if ([string]::IsNullOrWhiteSpace($beginMarker) -or [string]::IsNullOrWhiteSpace($endMarker)) {
        throw 'Activation markers are missing.'
    }

    $source = Get-AeSourceState $ExtensionSource
    $state = Get-CodexDeveloperInstructionsState `
        -ConfigPath $configPath `
        -BeginMarker $beginMarker `
        -EndMarker $endMarker
    if (-not $state.ConfigExists) {
        throw "Global Codex config is missing: $configPath"
    }
    if ($state.Conflict) {
        throw "Managed developer-instructions conflict: $($state.Detail)"
    }

    $textWithoutManaged = $state.ConfigText
    if ($state.ManagedExists) {
        $textWithoutManaged = $state.ConfigText.Remove($state.SpanStart, $state.SpanLength)
    }
    if ([regex]::Matches($textWithoutManaged, '(?m)^[ \t]*developer_instructions[ \t]*=').Count -gt 0) {
        throw 'Unmanaged developer_instructions already exists in Global Codex config.'
    }

    if (-not $state.ManagedExists) {
        $expectedConfigHash = [string](Get-AeOptionalProperty -Object $Activation -Name 'prechange_config_sha256' -Default '')
        if ([string]::IsNullOrWhiteSpace($expectedConfigHash) -or $state.ConfigHash -ne $expectedConfigHash) {
            throw "Global Codex config changed since preflight; expected=$expectedConfigHash actual=$($state.ConfigHash)"
        }
    }
    elseif ($state.ManagedContentHash -ne $source.Hash) {
        $expectedDeployedHashes = @([string](Get-AeOptionalProperty -Object $Activation -Name 'deployed_value_sha256' -Default ''))
        $expectedDeployedHashes += @((Get-AeOptionalProperty -Object $Activation -Name 'allowed_prechange_deployed_value_sha256' -Default @()))
        $expectedDeployedHashes = @($expectedDeployedHashes | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
        if ($expectedDeployedHashes.Count -eq 0 -or
            $state.ManagedContentHash -notin $expectedDeployedHashes) {
            throw "Managed instructions changed outside canonical sync; expected=$($expectedDeployedHashes -join ',') actual=$($state.ManagedContentHash)"
        }
    }

    $action = if ($state.ManagedExists) {
        if ($state.ManagedContentHash -eq $source.Hash -and $state.ManagedMetadataHash -eq $source.Hash) {
            'MATCH'
        }
        elseif ($Apply) { 'UPDATED' }
        else { 'WOULD_UPDATE' }
    }
    elseif ($Apply) { 'CREATED' }
    else { 'WOULD_CREATE' }

    if (-not $Apply -or $action -eq 'MATCH') {
        return [pscustomobject]@{
            Action = $action
            ConfigPath = $configPath
            BackupPath = $null
            DesiredHash = $source.Hash
            Detail = "managed_value=$($source.Hash)"
        }
    }

    $backupPattern = [string]$Activation.rollback
    if ([string]::IsNullOrWhiteSpace($backupPattern)) {
        throw 'Config rollback path is missing.'
    }
    $backupPath = $backupPattern.Replace('<timestamp>', $Timestamp)
    $backupDir = Split-Path -Parent $backupPath
    New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
    Copy-Item -LiteralPath $configPath -Destination $backupPath
    if ((Get-AeSha256 $backupPath) -ne $state.ConfigHash) {
        throw 'Global Codex config backup hash verification failed.'
    }

    $normalizedBlock = $beginMarker + "`n" +
        '# source_sha256 = ' + $source.Hash + "`n" +
        "developer_instructions = '''`n" +
        $source.Text +
        "'''`n" +
        $endMarker
    $block = $normalizedBlock.Replace("`n", $state.Eol)

    if ($state.ManagedExists) {
        $newText = $state.ConfigText.Remove($state.SpanStart, $state.SpanLength).Insert($state.SpanStart, $block)
    }
    else {
        $newText = $block + $state.Eol + $state.Eol + $state.ConfigText
    }
    Write-AeAtomicUtf8 -Path $configPath -Text $newText

    $after = Test-CodexDeveloperInstructionsActivation -Activation $Activation -ExtensionSource $ExtensionSource
    if ($after.State -ne 'MATCH') {
        throw "Managed developer-instructions verification failed after write: $($after.Detail)"
    }

    [pscustomobject]@{
        Action = $action
        ConfigPath = $configPath
        BackupPath = $backupPath
        DesiredHash = $source.Hash
        Detail = "managed_value=$($source.Hash) backup=$backupPath"
    }
}

Export-ModuleMember -Function Invoke-CodexDeveloperInstructionsSync, Test-CodexDeveloperInstructionsActivation
