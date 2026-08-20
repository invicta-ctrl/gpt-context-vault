[CmdletBinding()]
param(
    [string]$VaultRoot = "",
    [string]$CodexHome = "$env:USERPROFILE\.codex",
    [string]$BackupManifest = "",
    [switch]$SkipPersonal
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($VaultRoot)) {
    $VaultRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
}

function Pass([string]$Name) {
    Write-Host ("PASS " + $Name)
}

function Assert-True([bool]$Condition, [string]$Name) {
    if (-not $Condition) {
        throw ("FAIL " + $Name)
    }
    Pass $Name
}

function Read-Required([string]$Path) {
    Assert-True (Test-Path -LiteralPath $Path -PathType Leaf) ("file exists: " + $Path)
    return [IO.File]::ReadAllText($Path)
}

function Assert-ReadRequiredPurity {
    $tempPath = [IO.Path]::GetTempFileName()
    $expected = "TOKEN_OPT_PRESENT_MARKER"

    try {
        [IO.File]::WriteAllText($tempPath, $expected)
        $actual = Read-Required $tempPath

        Assert-True (($actual -is [string]) -and ($actual -ceq $expected)) "Read-Required returns file content only"
        Assert-True $actual.Contains("TOKEN_OPT_PRESENT_MARKER") "regression marker present passes"

        $missingMarkerFailed = $false
        try {
            Assert-True $actual.Contains("TOKEN_OPT_ABSENT_MARKER") "regression marker absent"
        }
        catch {
            $missingMarkerFailed = $_.Exception.Message -eq "FAIL regression marker absent"
        }
        Assert-True $missingMarkerFailed "regression marker absent fails"
    }
    finally {
        if ([IO.File]::Exists($tempPath)) {
            [IO.File]::Delete($tempPath)
        }
    }
}

function Get-SingleStringSetting([string]$Text, [string]$Key, [string]$Label) {
    $pattern = "(?m)^\s*" + [regex]::Escape($Key) + "\s*=\s*`"([^`"]+)`"\s*$"
    $matches = [regex]::Matches($Text, $pattern)
    Assert-True ($matches.Count -eq 1) ("single active setting: " + $Label)
    return $matches[0].Groups[1].Value
}

function Get-SingleIntSetting([string]$Text, [string]$Key, [string]$Label) {
    $pattern = "(?m)^\s*" + [regex]::Escape($Key) + "\s*=\s*(\d+)\s*$"
    $matches = [regex]::Matches($Text, $pattern)
    Assert-True ($matches.Count -eq 1) ("single active setting: " + $Label)
    return [int]$matches[0].Groups[1].Value
}

Assert-ReadRequiredPurity

$policyMarkdownPath = Join-Path $VaultRoot "protocols\CODEX_TOKEN_OPTIMIZATION_AND_CONTEXT_EFFICIENCY_RULES.md"
$policyJsonPath = Join-Path $VaultRoot "automation\codex-model-routing\token-optimization.policy.json"
$fixturesPath = Join-Path $VaultRoot "automation\codex-model-routing\token-optimization.behavior-fixtures.json"
$agentsPath = Join-Path $VaultRoot "AGENTS.md"
$startPath = Join-Path $VaultRoot "START_HERE.md"
$indexPath = Join-Path $VaultRoot "CONTEXT_INDEX.md"
$retrievalPath = Join-Path $VaultRoot "protocols\CONTEXT_RETRIEVAL_PROTOCOL.md"
$routingReadmePath = Join-Path $VaultRoot "automation\codex-model-routing\README.md"
$routingStandardPath = Join-Path $VaultRoot "automation\codex-model-routing\ROUTING_STANDARD.md"
$specPath = Join-Path $VaultRoot "governance\agents\specs\TOKEN-OPT-001.md"

$policyMarkdown = Read-Required $policyMarkdownPath
$agents = Read-Required $agentsPath
$start = Read-Required $startPath
$index = Read-Required $indexPath
$retrieval = Read-Required $retrievalPath
$routingReadme = Read-Required $routingReadmePath
$routingStandard = Read-Required $routingStandardPath
$spec = Read-Required $specPath

$requiredPolicyMarkers = @(
    "MAXIMIZE VERIFIED PROGRESS PER TOKEN",
    "GOVERNANCE WINS OVER TOKEN SAVINGS",
    "CONTEXT_EXPANSION_REASON:",
    "REVERIFY_REASON:",
    "ZERO CHILDREN BY DEFAULT",
    "ONE ACTIVE CHILD MAX",
    "STOP WHEN GREEN"
)
foreach ($marker in $requiredPolicyMarkers) {
    Assert-True $policyMarkdown.Contains($marker) ("canonical marker: " + $marker)
}

Assert-True $spec.Contains("status: accepted") "accepted specification status"
Assert-True $spec.Contains("APPROVE TOKEN-OPT-001 AS WRITTEN") "approval evidence in specification"

$canonicalRelative = "protocols/CODEX_TOKEN_OPTIMIZATION_AND_CONTEXT_EFFICIENCY_RULES.md"
Assert-True $agents.Contains($canonicalRelative) "AGENTS routes to canonical policy"
Assert-True $start.Contains($canonicalRelative) "START_HERE routes to canonical policy"
Assert-True $index.Contains($canonicalRelative) "CONTEXT_INDEX indexes canonical policy"
Assert-True $retrieval.Contains($canonicalRelative) "retrieval protocol routes to canonical policy"
Assert-True $routingReadme.Contains($canonicalRelative) "routing README routes to canonical policy"
Assert-True $routingStandard.Contains("zero children by default") "routing standard zero-child default"
Assert-True $routingStandard.Contains("one active child") "routing standard one-child maximum"
Assert-True $routingStandard.Contains("Independent review is conditional") "routing standard conditional review"
Assert-True $routingStandard.Contains("Do not run a full suite after every small module") "routing standard focused test escalation"

$policy = (Read-Required $policyJsonPath) | ConvertFrom-Json
$fixtureData = (Read-Required $fixturesPath) | ConvertFrom-Json

Assert-True ($policy.schema_version -eq 1) "policy schema version"
Assert-True ($policy.policy_id -eq "TOKEN-OPT-001") "policy id"
Assert-True ($policy.canonical_policy -eq $canonicalRelative) "canonical policy path"
Assert-True ($policy.defaults.global_model -eq "gpt-5.6-sol") "machine global model"
Assert-True ($policy.defaults.ordinary_reasoning_effort -eq "high") "machine ordinary reasoning"
Assert-True ([int]$policy.defaults.max_concurrent_threads_per_session -le 2) "machine thread maximum"
Assert-True ([int]$policy.defaults.default_children -eq 0) "machine zero-child default"
Assert-True ([int]$policy.defaults.max_active_children -le 1) "machine active-child maximum"
Assert-True ([int]$policy.defaults.max_delegation_depth -le 1) "machine delegation depth"
Assert-True (-not [bool]$policy.defaults.routine_independent_review) "machine routine review disabled"
Assert-True (-not [bool]$policy.defaults.routine_full_suite_after_small_module) "machine routine full suite disabled"
Assert-True ($policy.context.expansion_reason_label -eq "CONTEXT_EXPANSION_REASON") "context expansion label"
Assert-True ($policy.verification.reverify_reason_label -eq "REVERIFY_REASON") "reverification label"

$fixtures = @($fixtureData.fixtures)
Assert-True ($fixtures.Count -eq 10) "fixture count = 10"

$ids = @($fixtures | ForEach-Object { $_.id })
Assert-True ((@($ids | Sort-Object -Unique)).Count -eq 10) "fixture ids unique"

$expectedIds = @(
    "small_bug",
    "new_session_continuation",
    "missing_specification",
    "failing_focused_test",
    "fresh_existing_verification",
    "stale_verification",
    "large_repository",
    "subagent_opportunity",
    "conflicting_governance",
    "optimization_versus_safety"
)
foreach ($id in $expectedIds) {
    Assert-True ($ids -contains $id) ("fixture exists: " + $id)
}

foreach ($fixture in $fixtures) {
    $contract = $policy.behavior_contract.PSObject.Properties[$fixture.contract_key].Value
    Assert-True ($null -ne $contract) ("behavior contract exists: " + $fixture.id)
    $actualJson = $contract | ConvertTo-Json -Depth 20 -Compress
    $expectedJson = $fixture.expected | ConvertTo-Json -Depth 20 -Compress
    Assert-True ($actualJson -eq $expectedJson) ("behavior fixture: " + $fixture.id)
}

if (-not $SkipPersonal) {
    $configPath = Join-Path $CodexHome "config.toml"
    $advisorPath = Join-Path $CodexHome "agents\sol-advisor.toml"
    $config = Read-Required $configPath
    $advisor = Read-Required $advisorPath

    Assert-True ((Get-SingleStringSetting $config "model" "global model") -eq "gpt-5.6-sol") "active global model"
    Assert-True ((Get-SingleStringSetting $config "model_reasoning_effort" "ordinary reasoning") -eq "high") "active ordinary reasoning"
    Assert-True ((Get-SingleIntSetting $config "max_concurrent_threads_per_session" "concurrent threads") -le 2) "active concurrent-thread maximum"
    Assert-True ((Get-SingleStringSetting $advisor "model" "Sol Advisor model") -eq "gpt-5.6-sol") "Sol Advisor model"
    Assert-True ((Get-SingleStringSetting $advisor "model_reasoning_effort" "Sol Advisor reasoning") -eq "high") "Sol Advisor reasoning"

    if (-not [string]::IsNullOrWhiteSpace($BackupManifest)) {
        $manifest = (Read-Required $BackupManifest) | ConvertFrom-Json
        Assert-True ($manifest.change_id -eq "TOKEN-OPT-001") "backup manifest change id"
        foreach ($entry in @($manifest.files)) {
            Assert-True (Test-Path -LiteralPath $entry.backup_path -PathType Leaf) ("backup exists: " + $entry.backup_path)
            $backupHash = (Get-FileHash -LiteralPath $entry.backup_path -Algorithm SHA256).Hash.ToLowerInvariant()
            $backupBytes = (Get-Item -LiteralPath $entry.backup_path).Length
            Assert-True ($backupHash -eq $entry.backup_sha256) ("backup hash: " + $entry.backup_path)
            Assert-True ($backupHash -eq $entry.original_sha256) ("backup equals original hash: " + $entry.backup_path)
            Assert-True ($backupBytes -eq [int64]$entry.byte_count) ("backup bytes: " + $entry.backup_path)
        }
    }
}

Write-Output ("SUMMARY PASS fixtures=" + $fixtures.Count + " personal=" + ($(if ($SkipPersonal) { "SKIPPED" } else { "PASS" })))
