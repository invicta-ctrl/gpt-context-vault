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

function Get-StringSha256([string]$Text) {
    $algorithm = [Security.Cryptography.SHA256]::Create()
    try {
        return (($algorithm.ComputeHash([Text.Encoding]::UTF8.GetBytes($Text)) | ForEach-Object { $_.ToString("x2") }) -join "")
    }
    finally {
        $algorithm.Dispose()
    }
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
$a1SpecPath = Join-Path $VaultRoot "governance\agents\specs\TOKEN-OPT-001-A1.md"

$policyMarkdown = Read-Required $policyMarkdownPath
$agents = Read-Required $agentsPath
$start = Read-Required $startPath
$index = Read-Required $indexPath
$retrieval = Read-Required $retrievalPath
$routingReadme = Read-Required $routingReadmePath
$routingStandard = Read-Required $routingStandardPath
$spec = Read-Required $specPath
$a1Spec = Read-Required $a1SpecPath

$requiredPolicyMarkers = @(
    "MAXIMIZE VERIFIED PROGRESS PER TOKEN",
    "GOVERNANCE WINS OVER TOKEN SAVINGS",
    "CONTEXT_EXPANSION_REASON:",
    "REVERIFY_REASON:",
    "ZERO CHILDREN BY DEFAULT",
    "ONE ACTIVE CHILD MAX",
    "CURRENT WRITER FINISHES CURRENT SLICE",
    "NEVER AUTO-START THE NEXT SLICE",
    "CACHE HIT: UNVERIFIED / UNAVAILABLE",
    "TOOL_CONTEXT_EXPANSION_REASON",
    "CONFIG_CHANGE_REASON",
    "STOP WHEN GREEN"
)
foreach ($marker in $requiredPolicyMarkers) {
    Assert-True $policyMarkdown.Contains($marker) ("canonical marker: " + $marker)
}

Assert-True $spec.Contains("status: accepted") "accepted specification status"
Assert-True $spec.Contains("APPROVE TOKEN-OPT-001 AS WRITTEN") "approval evidence in specification"
Assert-True $a1Spec.Contains("status: accepted") "accepted A1 specification status"
Assert-True $a1Spec.Contains("APPROVE TOKEN-OPT-001-A1 AS WRITTEN") "approval evidence in A1 specification"

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
Assert-True $routingStandard.Contains("read-only scout") "routing standard read-only scout"
Assert-True $routingStandard.Contains("Never auto-start") "routing standard no auto-start"

$policy = (Read-Required $policyJsonPath) | ConvertFrom-Json
$fixtureData = (Read-Required $fixturesPath) | ConvertFrom-Json

Assert-True ($policy.schema_version -eq 2) "policy schema version"
Assert-True ($policy.policy_id -eq "TOKEN-OPT-001") "policy id"
Assert-True (@($policy.accepted_amendments) -contains "TOKEN-OPT-001-A1") "accepted A1 amendment in policy"
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

$pipeline = $policy.current_next_slice_pipeline
$requiredPipelineValues = [ordered]@{
    pipeline_name = "CURRENT_NEXT_SLICE_PIPELINE"
    zero_children_default = $true
    max_active_children = 1
    max_depth = 1
    one_writer = $true
    scout_read_only = $true
    scout_may_delegate = $false
    next_slice_must_be_authorized = $true
    auto_start_next_slice = $false
    scout_packet_required = $true
    ending_sha_revalidation_required = $true
    stale_if_required = $true
    critical_operation_disable_rules = $true
    project_stricter_rule_wins = $true
    cache_friendly_prompt_ordering = $true
    static_context_before_dynamic_context = $true
    cache_claim_requires_telemetry = $true
    context_compaction_supported = $true
    manual_compaction_requires_checkpoint = $true
    post_compaction_rehydration_required = $true
    durable_evidence_preserved = $true
    task_relevant_tool_context = $true
    progressive_disclosure_preferred = $true
    shared_mcp_disable_requires_separate_authority = $true
    stable_slice_configuration = $true
    config_change_reason_required = $true
    unsupported_efficiency_percentages_prohibited = $true
}
foreach ($entry in $requiredPipelineValues.GetEnumerator()) {
    Assert-True ($pipeline.PSObject.Properties[$entry.Key].Value -eq $entry.Value) ("A1 machine contract: " + $entry.Key)
}

$expectedScoutSpawnConditions = @(
    "named_next_slice_has_drafting_authority",
    "bounded_independent_preparation_reduces_reconstruction",
    "single_child_slot_available",
    "current_writer_remains_sole_writer",
    "read_paths_and_stop_conditions_explicit",
    "no_stricter_project_prohibition"
)
$expectedScoutDisableConditions = @(
    "trivial_task",
    "inferred_future_work",
    "critical_or_destructive_operation",
    "migration_or_production",
    "provider_or_database_mutation",
    "security_or_privacy_ambiguity",
    "writer_conflict",
    "dirty_unknown_state",
    "missing_authority",
    "child_slot_required_by_writer_or_reviewer"
)
$expectedScoutInterruptConditions = @(
    "wrong_repository_branch_or_baseline",
    "controlling_authority_conflict",
    "writer_conflict",
    "security_privacy_or_data_integrity_risk_affecting_current_work"
)
Assert-True ((@($pipeline.scout_spawn_conditions) | ConvertTo-Json -Compress) -eq ($expectedScoutSpawnConditions | ConvertTo-Json -Compress)) "A1 scout spawn conditions"
Assert-True ((@($pipeline.scout_disable_conditions) | ConvertTo-Json -Compress) -eq ($expectedScoutDisableConditions | ConvertTo-Json -Compress)) "A1 scout disable conditions"
Assert-True ((@($pipeline.scout_interrupt_conditions) | ConvertTo-Json -Compress) -eq ($expectedScoutInterruptConditions | ConvertTo-Json -Compress)) "A1 scout interrupt conditions"

$expectedRevalidationStates = @("VALID", "PARTIALLY_STALE", "STALE", "BLOCKED", "NO_OP")
Assert-True ((@($pipeline.revalidation_states) | ConvertTo-Json -Compress) -eq ($expectedRevalidationStates | ConvertTo-Json -Compress)) "A1 revalidation states"

$expectedPacketFields = @(
    "SCOUT_STATUS", "NEXT_SLICE_ID", "NEXT_SLICE_AUTHORITY", "SCOUT_BASELINE_SHA",
    "OBSERVED_AT", "STALE_IF", "FACTS", "INFERENCES", "UNVERIFIED", "OBJECTIVE",
    "IN_SCOPE", "OUT_OF_SCOPE", "LIKELY_OWNED_PATHS", "EXCLUDED_PATHS", "DEPENDENCIES",
    "CURRENT_INVARIANTS", "EXPECTED_ACCEPTANCE_CRITERIA", "FOCUSED_TEST_PLAN",
    "SECURITY_OR_PRIVACY_GATES", "CONFIGURATION_GATES", "OWNER_DECISIONS_REQUIRED",
    "RISKS", "BLOCKERS", "DO_NOT_REPEAT", "NO_WRITE_ATTESTATION"
)
Assert-True ((@($pipeline.scout_packet_fields) | ConvertTo-Json -Compress) -eq ($expectedPacketFields | ConvertTo-Json -Compress)) "A1 scout packet schema"
$expectedStablePrefix = @("authority_hierarchy", "universal_safety_and_one_writer_rules", "durable_project_rules", "stable_workflow_contract", "stable_tool_schemas")
$expectedDynamicSuffix = @("current_slice", "baseline_sha", "current_failures_and_changed_paths", "volatile_pr_provider_tool_state", "timestamps_and_run_ids")
$expectedCompactionFields = @("AUTHORITY", "HEAD_TREE", "WORKTREE", "WRITER_LOCK", "OBJECTIVE", "COMPLETED", "CHANGED_FILES", "TESTS", "BLOCKERS", "NEXT_SAFE_ACTION", "DO_NOT_REPEAT")
$expectedConfigChangeFields = @("CONFIG_CHANGE_REASON", "OLD_VALUE", "NEW_VALUE", "AUTHORITY", "EVIDENCE_INVALIDATED", "ROLLBACK_REVERSION")
Assert-True ((@($pipeline.stable_prompt_prefix) | ConvertTo-Json -Compress) -eq ($expectedStablePrefix | ConvertTo-Json -Compress)) "A1 stable prompt prefix"
Assert-True ((@($pipeline.dynamic_prompt_suffix) | ConvertTo-Json -Compress) -eq ($expectedDynamicSuffix | ConvertTo-Json -Compress)) "A1 dynamic prompt suffix"
Assert-True ((@($pipeline.compaction_checkpoint_fields) | ConvertTo-Json -Compress) -eq ($expectedCompactionFields | ConvertTo-Json -Compress)) "A1 compaction checkpoint schema"
Assert-True ((@($pipeline.configuration_change_fields) | ConvertTo-Json -Compress) -eq ($expectedConfigChangeFields | ConvertTo-Json -Compress)) "A1 configuration-change schema"
$expectedStaticLimits = @("runtime_scout_zero_writes", "cache_hit", "token_quantity_saved", "compaction_preserved_every_semantic_detail", "mcp_token_consumption")
Assert-True ((@($pipeline.static_validator_cannot_prove) | ConvertTo-Json -Compress) -eq ($expectedStaticLimits | ConvertTo-Json -Compress)) "A1 static-validator limits"

$baseSuite = $fixtureData.fixture_suites.PSObject.Properties["TOKEN-OPT-001"].Value
$a1Suite = $fixtureData.fixture_suites.PSObject.Properties["TOKEN-OPT-001-A1"].Value
$fixtures = @($baseSuite.fixtures)
$a1Fixtures = @($a1Suite.fixtures)
Assert-True ([int]$baseSuite.suite_version -eq 1) "base fixture suite version"
Assert-True ([int]$baseSuite.fixture_count -eq 10) "base declared fixture count"
Assert-True ($fixtures.Count -eq 10) "base fixture count = 10"
$baseFixtureCanonicalJson = $fixtures | ConvertTo-Json -Depth 20 -Compress
Assert-True ((Get-StringSha256 $baseFixtureCanonicalJson) -eq "eb5314d707734395ebf2a23b9294cda6855a2dfbeacf6e4645fba1de5513ba58") "base fixture meanings unchanged from merged TOKEN-OPT-001"
Assert-True ([int]$a1Suite.suite_version -eq 1) "A1 fixture suite version"
Assert-True ([int]$a1Suite.fixture_count -eq 26) "A1 declared fixture count"
Assert-True ($a1Fixtures.Count -eq 26) "A1 fixture count = 26"

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

$a1Ids = @($a1Fixtures | ForEach-Object { $_.id })
$expectedA1Ids = @(
    "a1_trivial_task",
    "a1_authorized_next_slice",
    "a1_inferred_next_slice",
    "a1_critical_mutation",
    "a1_scout_write_attempt",
    "a1_scout_child_spawn_attempt",
    "a1_second_active_child",
    "a1_stale_if_change",
    "a1_current_green_next_unapproved",
    "a1_stricter_project_rule",
    "a1_scout_authority_conflict",
    "a1_same_sha_evidence",
    "a1_writer_occupies_child_slot",
    "a1_reviewer_needed",
    "a1_completion_proven",
    "a1_stable_before_volatile",
    "a1_cache_without_telemetry",
    "a1_safe_checkpoint_compaction",
    "a1_critical_midflight_compaction",
    "a1_duplicate_logs",
    "a1_durable_audit_history",
    "a1_unused_external_mcp",
    "a1_stable_tool_schema",
    "a1_unrecorded_config_change",
    "a1_required_config_change",
    "a1_unsupported_efficiency_percentage"
)
Assert-True ((@($a1Ids | Sort-Object -Unique)).Count -eq 26) "A1 fixture ids unique"
foreach ($id in $expectedA1Ids) {
    Assert-True ($a1Ids -contains $id) ("A1 fixture exists: " + $id)
}
Assert-True ((@($ids + $a1Ids | Sort-Object -Unique)).Count -eq 36) "all fixture ids globally unique"

foreach ($fixture in $fixtures) {
    $contract = $policy.behavior_contract.PSObject.Properties[$fixture.contract_key].Value
    Assert-True ($null -ne $contract) ("behavior contract exists: " + $fixture.id)
    $actualJson = $contract | ConvertTo-Json -Depth 20 -Compress
    $expectedJson = $fixture.expected | ConvertTo-Json -Depth 20 -Compress
    Assert-True ($actualJson -eq $expectedJson) ("behavior fixture: " + $fixture.id)
}

foreach ($fixture in $a1Fixtures) {
    $contract = $policy.behavior_contract.PSObject.Properties[$fixture.contract_key].Value
    Assert-True ($null -ne $contract) ("A1 behavior contract exists: " + $fixture.id)
    $actualJson = $contract | ConvertTo-Json -Depth 20 -Compress
    $expectedJson = $fixture.expected | ConvertTo-Json -Depth 20 -Compress
    Assert-True ($actualJson -eq $expectedJson) ("A1 behavior fixture: " + $fixture.id)
}

$activeGovernance = @(
    $agents,
    $start,
    $index,
    $retrieval,
    $routingReadme,
    $routingStandard,
    $policyMarkdown,
    $spec,
    $a1Spec,
    (Read-Required $policyJsonPath),
    (Read-Required $fixturesPath)
) -join "`n"

$contradictionPatterns = @(
    '"default_children"\s*:\s*[1-9]',
    '"max_active_children"\s*:\s*[2-9]',
    '"max_delegation_depth"\s*:\s*[2-9]',
    '"max_depth"\s*:\s*[2-9]',
    '"auto_start_next_slice"\s*:\s*true',
    '(?i)scout on every task',
    '(?i)reviewer on every task'
)
foreach ($pattern in $contradictionPatterns) {
    Assert-True (-not [regex]::IsMatch($activeGovernance, $pattern)) ("active contradiction absent: " + $pattern)
}
Assert-True (-not [regex]::IsMatch($activeGovernance, '\b\d+(?:\.\d+)?\s*%')) "unsupported universal percentage absent"
Pass "active governance scan excludes archive and history"

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

Write-Output ("SUMMARY PASS base_fixtures=" + $fixtures.Count + " a1_fixtures=" + $a1Fixtures.Count + " personal=" + ($(if ($SkipPersonal) { "SKIPPED" } else { "PASS" })))
