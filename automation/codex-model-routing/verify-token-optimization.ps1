[CmdletBinding()]
param(
    [string]$VaultRoot = '',
    [string]$CodexHome = "$env:USERPROFILE\.codex",
    [string]$CatalogPath = "$env:USERPROFILE\.codex\codex-router\merged-models.json",
    [string]$RouterStatePath = "$env:USERPROFILE\.codex\codex-router\multi-agent-settings.json",
    [string]$BackupManifest = '',
    [switch]$SkipPersonal,
    [switch]$SkipCatalog
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($VaultRoot)) {
    $VaultRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
}

function Pass([string]$Name) { Write-Host ('PASS ' + $Name) }
function Assert-True([bool]$Condition, [string]$Name) {
    if (-not $Condition) { throw ('FAIL ' + $Name) }
    Pass $Name
}
function Read-Required([string]$Path) {
    Assert-True (Test-Path -LiteralPath $Path -PathType Leaf) ('file exists: ' + $Path)
    return [IO.File]::ReadAllText($Path)
}
function Get-OptionalProperty($Object, [string]$Name, $Default = $null) {
    if ($null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name) { return $Object.$Name }
    return $Default
}
function Get-SingleStringSetting([string]$Text, [string]$Key, [string]$Label) {
    $matches = [regex]::Matches($Text, "(?m)^\s*" + [regex]::Escape($Key) + "\s*=\s*`"([^`"]+)`"\s*$")
    Assert-True ($matches.Count -eq 1) ('single active setting: ' + $Label)
    return $matches[0].Groups[1].Value
}
function Get-SingleIntSetting([string]$Text, [string]$Key, [string]$Label) {
    $matches = [regex]::Matches($Text, "(?m)^\s*" + [regex]::Escape($Key) + "\s*=\s*(\d+)\s*$")
    Assert-True ($matches.Count -eq 1) ('single active setting: ' + $Label)
    return [int]$matches[0].Groups[1].Value
}
function Get-StringSha256([string]$Text) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return (($sha.ComputeHash([Text.UTF8Encoding]::new($false).GetBytes($Text)) | ForEach-Object { $_.ToString('x2') }) -join '') }
    finally { $sha.Dispose() }
}
function Test-CatalogRoute($Catalog, [string]$ModelId, [string]$Effort) {
    $model = @($Catalog.models | Where-Object { [string]$_.slug -eq $ModelId }) | Select-Object -First 1
    Assert-True ($null -ne $model) ('catalog model exists: ' + $ModelId)
    $efforts = @($model.supported_reasoning_levels | ForEach-Object { if ($_ -is [string]) { [string]$_ } else { [string]$_.effort } })
    Assert-True ($efforts -contains $Effort) ('catalog effort supported: ' + $ModelId + '/' + $Effort)
}

$policyMarkdownPath = Join-Path $VaultRoot 'protocols\CODEX_TOKEN_OPTIMIZATION_AND_CONTEXT_EFFICIENCY_RULES.md'
$policyJsonPath = Join-Path $VaultRoot 'automation\codex-model-routing\token-optimization.policy.json'
$fixturesPath = Join-Path $VaultRoot 'automation\codex-model-routing\token-optimization.behavior-fixtures.json'
$profilePath = Join-Path $VaultRoot 'automation\codex-model-routing\current-routing-profile.json'
$compilerPath = Join-Path $VaultRoot 'automation\codex-model-routing\route-compiler.ps1'
$receiptToolPath = Join-Path $VaultRoot 'automation\codex-model-routing\verification-receipts.ps1'
$benchmarkToolPath = Join-Path $VaultRoot 'automation\codex-model-routing\report-seven-day-benchmark.ps1'
$a4FixturePath = Join-Path $VaultRoot 'automation\codex-model-routing\fixtures\a4-route-compiler-fixtures.json'
$readOnlyContractPath = Join-Path $VaultRoot 'automation\codex-model-routing\contracts\read-only-worker-contract.json'
$terraContractPath = Join-Path $VaultRoot 'automation\codex-model-routing\contracts\terra-writer-contract.json'
$agentsPath = Join-Path $VaultRoot 'AGENTS.md'
$startPath = Join-Path $VaultRoot 'START_HERE.md'
$indexPath = Join-Path $VaultRoot 'CONTEXT_INDEX.md'
$retrievalPath = Join-Path $VaultRoot 'protocols\CONTEXT_RETRIEVAL_PROTOCOL.md'
$routingReadmePath = Join-Path $VaultRoot 'automation\codex-model-routing\README.md'
$routingStandardPath = Join-Path $VaultRoot 'automation\codex-model-routing\ROUTING_STANDARD.md'
$specPath = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001.md'
$a1SpecPath = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A1.md'
$a2SpecPath = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A2.md'
$a3SpecPath = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A3.md'
$a4SpecPath = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A4.md'

$policyMarkdown = Read-Required $policyMarkdownPath
$agents = Read-Required $agentsPath
$start = Read-Required $startPath
$index = Read-Required $indexPath
$retrieval = Read-Required $retrievalPath
$routingReadme = Read-Required $routingReadmePath
$routingStandard = Read-Required $routingStandardPath
$spec = Read-Required $specPath
$a1Spec = Read-Required $a1SpecPath
$a2Spec = Read-Required $a2SpecPath
$a3Spec = Read-Required $a3SpecPath
$a4Spec = Read-Required $a4SpecPath

foreach ($marker in @(
    'MAXIMIZE VERIFIED PROGRESS PER TOKEN',
    'GOVERNANCE WINS OVER TOKEN SAVINGS',
    'OVERSIZE_CONTEXT_REASON',
    'CURRENT WRITER FINISHES CURRENT SLICE',
    'NEVER AUTO-START THE NEXT SLICE',
    'STOP WHEN GREEN',
    'gpt-5.6-terra',
    'openrouter/stealth/ox-alpha',
    'one Terra writer plus two read-only workers',
    'verification receipt'
)) { Assert-True $policyMarkdown.Contains($marker) ('canonical marker: ' + $marker) }

Assert-True $spec.Contains('APPROVE TOKEN-OPT-001 AS WRITTEN') 'accepted base specification evidence'
Assert-True $a1Spec.Contains('APPROVE TOKEN-OPT-001-A1 AS WRITTEN') 'accepted A1 specification evidence'
Assert-True ((Get-FileHash -LiteralPath $a2SpecPath -Algorithm SHA256).Hash.ToLowerInvariant() -eq 'fda3b018dbdf7e3f597cfb07d797633cc8ebbb30cab23f94e1806f9d960918e2') 'A2 preserved hash'
Assert-True ((Get-FileHash -LiteralPath $a3SpecPath -Algorithm SHA256).Hash.ToLowerInvariant() -eq 'dc31c20cef4bc39f4165339e323ebee07c26a3499b8705f840648932f9eec8be') 'A3 preserved hash'
Assert-True $a4Spec.Contains('status: accepted') 'accepted A4 specification status'

$canonicalRelative = 'protocols/CODEX_TOKEN_OPTIMIZATION_AND_CONTEXT_EFFICIENCY_RULES.md'
Assert-True $agents.Contains($canonicalRelative) 'AGENTS routes to canonical policy'
Assert-True $agents.Contains('current-routing-profile.json') 'AGENTS points to current routing enforcement'
Assert-True $start.Contains($canonicalRelative) 'START_HERE routes to canonical policy'
Assert-True $index.Contains($canonicalRelative) 'CONTEXT_INDEX indexes canonical policy'
Assert-True $retrieval.Contains($canonicalRelative) 'retrieval protocol routes to canonical policy'
Assert-True $routingReadme.Contains('current-routing-profile.json') 'routing README discovers current profile'
Assert-True $routingStandard.Contains('one Terra writer') 'routing standard has A4 writer capacity'
Assert-True $routingStandard.Contains('read-only') 'routing standard retains read-only worker rule'

$policy = (Read-Required $policyJsonPath) | ConvertFrom-Json
$fixtureData = (Read-Required $fixturesPath) | ConvertFrom-Json
$profile = (Read-Required $profilePath) | ConvertFrom-Json
$readOnlyContract = (Read-Required $readOnlyContractPath) | ConvertFrom-Json
$terraContract = (Read-Required $terraContractPath) | ConvertFrom-Json

Assert-True ([int]$policy.schema_version -eq 3) 'policy schema version'
foreach ($amendment in @('TOKEN-OPT-001-A1', 'TOKEN-OPT-001-A2', 'TOKEN-OPT-001-A3', 'TOKEN-OPT-001-A4')) {
    Assert-True (@($policy.accepted_amendments) -contains $amendment) ('accepted amendment in policy: ' + $amendment)
}
Assert-True ($policy.defaults.global_model -eq 'gpt-5.6-sol') 'machine global parent model'
Assert-True ($policy.defaults.ordinary_reasoning_effort -eq 'high') 'machine global parent reasoning'
Assert-True ([int]$policy.defaults.max_concurrent_threads_per_session -eq 6) 'machine thread cap'
Assert-True ([int]$policy.defaults.default_read_only_workers -eq 2) 'machine default read-only workers'
Assert-True ([int]$policy.defaults.max_adaptive_read_only_workers -eq 4) 'machine adaptive read-only workers'
Assert-True ([int]$policy.defaults.max_total_active_workers -eq 6) 'machine total worker cap'
Assert-True ([int]$policy.defaults.max_overlapping_writers -eq 1) 'machine writer cap'
Assert-True (-not [bool]$policy.defaults.recursive_worker_spawning) 'machine recursion disabled'

$pipeline = $policy.current_next_slice_pipeline
foreach ($entry in ([ordered]@{
    zero_children_default = $true; max_active_children = 1; max_depth = 1; one_writer = $true
    scout_read_only = $true; scout_may_delegate = $false; auto_start_next_slice = $false
    ending_sha_revalidation_required = $true; stale_if_required = $true; project_stricter_rule_wins = $true
}).GetEnumerator()) {
    Assert-True ($pipeline.PSObject.Properties[$entry.Key].Value -eq $entry.Value) ('A1 specialized pipeline preserved: ' + $entry.Key)
}

Assert-True ($profile.profile_id -eq 'TOKEN-OPT-001-A4-current') 'current profile identity'
Assert-True ($profile.roles.orchestrator.model -eq 'gpt-5.6-sol' -and $profile.roles.orchestrator.reasoning_effort -eq 'high') 'profile Sol High'
Assert-True ($profile.roles.writer.model -eq 'gpt-5.6-terra' -and $profile.roles.writer.reasoning_effort -eq 'max') 'profile Terra Max'
Assert-True ($profile.roles.read_only_worker.durable.model -eq 'gpt-5.6-luna' -and $profile.roles.read_only_worker.durable.reasoning_effort -eq 'max') 'profile Luna Max'
Assert-True ($profile.roles.read_only_worker.ephemeral.model -eq 'openrouter/stealth/ox-alpha' -and $profile.roles.read_only_worker.ephemeral.reasoning_effort -eq 'high') 'profile Ox High'
Assert-True (@($profile.catalog.disabled_models) -contains 'deepseek-v4-pro') 'profile disables short DeepSeek Pro alias'
Assert-True (@($profile.catalog.disabled_models) -contains 'deepseek/deepseek-v4-pro') 'profile disables qualified DeepSeek Pro alias'
Assert-True ((@($profile.fallbacks.ox) | ConvertTo-Json -Compress) -eq (@('gpt-5.6-luna') | ConvertTo-Json -Compress)) 'profile Ox fallback is Luna only'
Assert-True ([int]$profile.ox_eligibility.cache_cadence_seconds -gt 0 -and [int]$profile.ox_eligibility.cache_cadence_seconds -le 3600) 'profile Ox cache cadence bounded'
Assert-True ([int]$profile.context_envelope.dispatch_seed_tokens_max -eq 12000) 'profile seed envelope'
Assert-True ([int]$profile.context_envelope.worker_working_tokens_max -eq 32000) 'profile worker envelope'
Assert-True ([int]$profile.context_envelope.normal_hard_ceiling_tokens -eq 64000) 'profile hard ceiling'
Assert-True ([int]$profile.context_envelope.split_or_exception_threshold_tokens -eq 100000) 'profile split threshold'
Assert-True ($readOnlyContract.may_write -eq $false -and $readOnlyContract.may_delegate -eq $false) 'shared worker contract read-only and non-delegating'
Assert-True ($terraContract.model -eq 'gpt-5.6-terra' -and [int]$terraContract.max_overlapping_writers -eq 1) 'Terra writer contract bound'
foreach ($path in @($compilerPath, $receiptToolPath, $benchmarkToolPath, $a4FixturePath)) { Assert-True (Test-Path -LiteralPath $path -PathType Leaf) ('A4 routing artifact: ' + $path) }

if (-not $SkipCatalog) {
    $catalog = (Read-Required $CatalogPath) | ConvertFrom-Json
    foreach ($model in @($profile.catalog.required_models)) { Test-CatalogRoute -Catalog $catalog -ModelId ([string]$model.id) -Effort ([string]$model.effort) }
}

$baseSuite = $fixtureData.fixture_suites.PSObject.Properties['TOKEN-OPT-001'].Value
$a1Suite = $fixtureData.fixture_suites.PSObject.Properties['TOKEN-OPT-001-A1'].Value
$a4Suite = $fixtureData.fixture_suites.PSObject.Properties['TOKEN-OPT-001-A4'].Value
$baseFixtures = @($baseSuite.fixtures)
$a1Fixtures = @($a1Suite.fixtures)
$a4Fixtures = @($a4Suite.fixtures)
Assert-True ($baseFixtures.Count -eq 10 -and [int]$baseSuite.fixture_count -eq 10) 'base fixture count = 10'
Assert-True ((Get-StringSha256 ($baseFixtures | ConvertTo-Json -Depth 20 -Compress)) -eq 'eb5314d707734395ebf2a23b9294cda6855a2dfbeacf6e4645fba1de5513ba58') 'base fixture meanings unchanged'
Assert-True ($a1Fixtures.Count -eq 26 -and [int]$a1Suite.fixture_count -eq 26) 'A1 fixture count = 26'
Assert-True ($a4Fixtures.Count -eq 22 -and [int]$a4Suite.fixture_count -eq 22) 'A4 fixture count = 22'
$allFixtures = @($baseFixtures + $a1Fixtures + $a4Fixtures)
Assert-True ((@($allFixtures | ForEach-Object { $_.id } | Sort-Object -Unique)).Count -eq 58) 'all fixture ids globally unique'
foreach ($fixture in $allFixtures) {
    $contract = $policy.behavior_contract.PSObject.Properties[$fixture.contract_key].Value
    Assert-True ($null -ne $contract) ('behavior contract exists: ' + $fixture.id)
    Assert-True (($contract | ConvertTo-Json -Depth 20 -Compress) -eq ($fixture.expected | ConvertTo-Json -Depth 20 -Compress)) ('behavior fixture: ' + $fixture.id)
}

$a4ExpectedIds = @('a4_catalog_validation','a4_sol_high','a4_terra_writer','a4_luna_worker','a4_ox_eligible','a4_ox_provider_unavailable','a4_ox_price_nonzero','a4_ox_health_unacceptable','a4_ox_data_unsuitable','a4_ox_failure','a4_disabled_deepseek','a4_context_envelope','a4_context_split','a4_concurrency','a4_recursion','a4_duplicate_work','a4_receipt_reuse','a4_receipt_invalidation','a4_findings','a4_benchmark','a4_stop_when_green','a4_profile_replacement')
foreach ($id in $a4ExpectedIds) { Assert-True (@($a4Fixtures | ForEach-Object { $_.id }) -contains $id) ('A4 fixture exists: ' + $id) }

$boundedActiveGovernance = @($agents, $start, $index, $retrieval, $routingReadme, $routingStandard, $policyMarkdown, $spec, $a1Spec, $a2Spec, $a3Spec, $a4Spec, (Read-Required $policyJsonPath), (Read-Required $fixturesPath), (Read-Required $profilePath)) -join "`n"
Assert-True (-not [regex]::IsMatch($boundedActiveGovernance, '(?i)deepseek-v4-pro[^\r\n]{0,120}(?:fallback|active)')) 'disabled DeepSeek Pro aliases are not active fallback routes'
Assert-True (-not [regex]::IsMatch($boundedActiveGovernance, '\b\d+(?:\.\d+)?\s*%')) 'unsupported universal percentage absent'
Pass 'bounded active-governance contradiction scan excludes archive and history'

if (-not $SkipPersonal) {
    $configPath = Join-Path $CodexHome 'config.toml'
    $config = Read-Required $configPath
    Assert-True ((Get-SingleStringSetting $config 'model' 'global model') -eq 'gpt-5.6-sol') 'active global model'
    Assert-True ((Get-SingleStringSetting $config 'model_reasoning_effort' 'global reasoning') -eq 'high') 'active global reasoning'
    Assert-True ((Get-SingleIntSetting $config 'max_concurrent_threads_per_session' 'concurrent threads') -eq 6) 'active concurrent-thread cap'
    $routerState = (Read-Required $RouterStatePath) | ConvertFrom-Json
    Assert-True ([int]$routerState.version -eq 2 -and [string]$routerState.mode -eq 'selected') 'router v2 selected state'
    foreach ($model in @('gpt-5.6-terra','gpt-5.6-luna','openrouter/stealth/ox-alpha','deepseek/deepseek-v4-flash','deepseek/deepseek-v4-flash-vision-exp')) {
        $label = 'router enabled model: ' + $model
        Assert-True (@($routerState.enabled) -contains $model) $label
    }
    foreach ($model in @('gpt-5.6-sol','deepseek-v4-pro','deepseek/deepseek-v4-pro')) {
        $label = 'router disabled model: ' + $model
        Assert-True (@($routerState.disabled) -contains $model) $label
    }
    $efforts = Get-OptionalProperty $routerState 'efforts' $null
    Assert-True ($null -ne $efforts) 'router effort map exists'
    Assert-True ([string]$efforts.'gpt-5.6-terra' -eq 'max') 'router Terra child effort'
    Assert-True ([string]$efforts.'gpt-5.6-luna' -eq 'max') 'router Luna child effort'
    Assert-True ([string]$efforts.'openrouter/stealth/ox-alpha' -eq 'high') 'router Ox child effort'

    if (-not [string]::IsNullOrWhiteSpace($BackupManifest)) {
        $manifest = (Read-Required $BackupManifest) | ConvertFrom-Json
        Assert-True ($manifest.change_id -eq 'TOKEN-OPT-001-A4') 'A4 backup manifest change id'
        foreach ($entry in @($manifest.files)) {
            Assert-True (Test-Path -LiteralPath $entry.backup_path -PathType Leaf) ('backup exists: ' + $entry.backup_path)
            $backupHash = (Get-FileHash -LiteralPath $entry.backup_path -Algorithm SHA256).Hash.ToLowerInvariant()
            $backupBytes = (Get-Item -LiteralPath $entry.backup_path).Length
            Assert-True ($backupHash -eq [string]$entry.backup_sha256) ('backup hash: ' + $entry.backup_path)
            Assert-True ($backupHash -eq [string]$entry.source_sha256) ('backup equals source hash: ' + $entry.backup_path)
            Assert-True ($backupBytes -eq [int64]$entry.byte_count) ('backup bytes: ' + $entry.backup_path)
            Assert-True ([bool]$entry.equality) ('backup equality attested: ' + $entry.backup_path)
        }
    }
}

Write-Output ('SUMMARY PASS base_fixtures=' + $baseFixtures.Count + ' a1_fixtures=' + $a1Fixtures.Count + ' a4_fixtures=' + $a4Fixtures.Count + ' personal=' + $(if ($SkipPersonal) { 'SKIPPED' } else { 'PASS' }) + ' catalog=' + $(if ($SkipCatalog) { 'SKIPPED' } else { 'PASS' }))
