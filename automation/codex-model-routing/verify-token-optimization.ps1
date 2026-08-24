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
if ([string]::IsNullOrWhiteSpace($VaultRoot)) { $VaultRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..')) }

function Pass([string]$Name) { Write-Host ('PASS ' + $Name) }
function Assert-True([bool]$Condition, [string]$Name) {
    if (-not $Condition) { throw ('FAIL ' + $Name) }
    Pass $Name
}
function Read-Required([string]$Path) {
    Assert-True (Test-Path -LiteralPath $Path -PathType Leaf) ('file exists: ' + $Path)
    [IO.File]::ReadAllText($Path)
}
function Get-StringSha256([string]$Text) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try { (($sha.ComputeHash([Text.UTF8Encoding]::new($false).GetBytes($Text)) | ForEach-Object { $_.ToString('x2') }) -join '') }
    finally { $sha.Dispose() }
}
function Assert-Parse([string]$Path) {
    $tokens = $null; $errors = $null
    [Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors) | Out-Null
    Assert-True ($errors.Count -eq 0) ('PowerShell parse: ' + $Path)
}

$paths = [ordered]@{
    agents = Join-Path $VaultRoot 'AGENTS.md'
    policy_md = Join-Path $VaultRoot 'protocols\CODEX_TOKEN_OPTIMIZATION_AND_CONTEXT_EFFICIENCY_RULES.md'
    policy_json = Join-Path $VaultRoot 'automation\codex-model-routing\token-optimization.policy.json'
    fixtures = Join-Path $VaultRoot 'automation\codex-model-routing\token-optimization.behavior-fixtures.json'
    profile = Join-Path $VaultRoot 'automation\codex-model-routing\current-routing-profile.json'
    gate = Join-Path $VaultRoot 'automation\codex-model-routing\manual-codex-execution-gate.json'
    compiler = Join-Path $VaultRoot 'automation\codex-model-routing\route-compiler.ps1'
    a4_test = Join-Path $VaultRoot 'automation\codex-model-routing\test-a4-routing.ps1'
    a6_test = Join-Path $VaultRoot 'automation\codex-model-routing\test-a6-manual-execution-gate.ps1'
    readme = Join-Path $VaultRoot 'automation\codex-model-routing\README.md'
    standard = Join-Path $VaultRoot 'automation\codex-model-routing\ROUTING_STANDARD.md'
    extension = Join-Path $VaultRoot 'governance\agents\extensions\global-codex.PROJECT_POLICY.md'
    a2 = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A2.md'
    a3 = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A3.md'
    a4 = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A4.md'
    a5 = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A5.md'
    a6 = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A6.md'
}

$content = @{}
foreach ($entry in $paths.GetEnumerator()) { $content[$entry.Key] = Read-Required $entry.Value }
foreach ($marker in @('BILLABLE CODEX EXECUTION: LOCKED BY DEFAULT','CHATGPT WEB SELF-AUTHORIZATION: PROHIBITED','ASTRAL BRIDGE SELF-AUTHORIZATION: PROHIBITED','ABSOLUTELY NECESSARY MEANS STOP AND ASK EARL')) {
    Assert-True (($content.agents + "`n" + $content.policy_md).Contains($marker)) ('canonical A6 marker: ' + $marker)
}
Assert-True ([regex]::IsMatch($content.readme, '(?i)routing metadata never authorizes')) 'routing README denies implicit execution authority'
Assert-True $content.standard.Contains('Routing is selection metadata, not permission') 'routing standard separates selection and execution'
Assert-True $content.extension.Contains('Native Multi-Agent V2 is disabled') 'global Codex extension disables Native V2'

$specHashes = [ordered]@{
    a2 = 'fda3b018dbdf7e3f597cfb07d797633cc8ebbb30cab23f94e1806f9d960918e2'
    a3 = 'dc31c20cef4bc39f4165339e323ebee07c26a3499b8705f840648932f9eec8be'
    a4 = 'd9c94e95430b8f4e510620d2262aa788acfc6160d5be0dcb3a98aa38ece27fa2'
    a5 = '26506857adafe95f523aa927a4562034d20a5b10a615053f30ff4012f3f96843'
}
foreach ($key in @('a2','a3','a4','a5')) {
    $hash = (Get-FileHash -LiteralPath $paths[$key] -Algorithm SHA256).Hash.ToLowerInvariant()
    Assert-True ($hash -eq $specHashes[$key]) ("preserved $($key.ToUpperInvariant()) hash")
}
Assert-True $content.a6.Contains('status: accepted') 'A6 accepted specification status'
Assert-True $content.a6.Contains('Manual-Only Billable Codex Execution Boundary') 'A6 specification identity'

$policy = $content.policy_json | ConvertFrom-Json
$profile = $content.profile | ConvertFrom-Json
$gate = $content.gate | ConvertFrom-Json
$fixtureData = $content.fixtures | ConvertFrom-Json
Assert-True ([int]$policy.schema_version -eq 4) 'policy schema version 4'
foreach ($amendment in @('TOKEN-OPT-001-A1','TOKEN-OPT-001-A2','TOKEN-OPT-001-A3','TOKEN-OPT-001-A4','TOKEN-OPT-001-A5','TOKEN-OPT-001-A6')) {
    Assert-True (@($policy.accepted_amendments) -contains $amendment) ('accepted amendment: ' + $amendment)
}
Assert-True (-not [bool]$policy.defaults.agents_enabled) 'policy agents disabled'
Assert-True (-not [bool]$policy.defaults.multi_agent_v2_enabled) 'policy Native V2 disabled'
Assert-True ([int]$policy.defaults.max_concurrent_threads_per_session -eq 1) 'policy thread cap one'
Assert-True ([int]$policy.defaults.default_read_only_workers -eq 0) 'policy default children zero'
Assert-True ([int]$policy.defaults.max_adaptive_read_only_workers -eq 0) 'policy adaptive children zero'
Assert-True ([int]$policy.defaults.max_total_active_workers -eq 1) 'policy total active process cap one'
Assert-True ([int]$policy.defaults.max_children -eq 0) 'policy max children zero'
Assert-True (-not [bool]$policy.defaults.allow_subagents) 'policy subagents disabled'
Assert-True (-not [bool]$policy.defaults.background_continuation) 'policy background continuation disabled'
Assert-True (-not [bool]$policy.defaults.automatic_fallback) 'policy automatic fallback disabled'
Assert-True ([string]$policy.billable_execution_boundary.default_state -eq 'LOCKED') 'policy usage default locked'
Assert-True ([string]$policy.billable_execution_boundary.absolutely_necessary_behavior -eq 'STOP_AND_ASK_EARL') 'policy absolutely-necessary behavior'
Assert-True (-not [bool]$policy.billable_execution_boundary.route_compiler_is_dispatcher) 'policy compiler non-dispatching'

Assert-True ([string]$profile.profile_id -eq 'TOKEN-OPT-001-A6-current') 'profile identity A6'
Assert-True ([string]$profile.role_catalog_status -eq 'DORMANT_REFERENCE_ONLY') 'profile role catalog dormant'
Assert-True ([string]$profile.execution_boundary.default_state -eq 'LOCKED') 'profile execution locked'
Assert-True ([int]$profile.execution_boundary.max_processes -eq 1 -and [int]$profile.execution_boundary.max_children -eq 0) 'profile one process zero children'
Assert-True (-not [bool]$profile.execution_boundary.allow_subagents) 'profile subagents disabled'
Assert-True (@($profile.fallbacks.ox).Count -eq 0) 'profile active Ox fallback empty'
Assert-True ([string]$profile.ox_eligibility.failure_behavior -like '*stop*new_manual_permit*') 'profile Ox failure requires new permit'
Assert-True ([string]$profile.roles.orchestrator.model -eq 'gpt-5.6-sol' -and [string]$profile.roles.orchestrator.reasoning_effort -eq 'high') 'dormant Sol High identity'
Assert-True ([string]$profile.roles.writer.model -eq 'gpt-5.6-terra' -and [string]$profile.roles.writer.reasoning_effort -eq 'max') 'dormant Terra Max identity'
Assert-True ([string]$profile.roles.read_only_worker.durable.model -eq 'gpt-5.6-luna') 'dormant Luna identity'
Assert-True ([string]$profile.roles.read_only_worker.ephemeral.model -eq 'openrouter/stealth/ox-alpha') 'dormant Ox identity'

Assert-True ([string]$gate.policy_id -eq 'TOKEN-OPT-001-A6') 'gate policy identity'
Assert-True ([string]$gate.default_state -eq 'LOCKED' -and [bool]$gate.manual_only) 'gate locked and manual-only'
Assert-True ([int]$gate.max_processes -eq 1 -and [int]$gate.max_children -eq 0) 'gate one process zero children'
Assert-True (-not [bool]$gate.allow_subagents) 'gate subagents disabled'
Assert-True (-not [bool]$gate.background_continuation -and -not [bool]$gate.automatic_fallback) 'gate background and fallback disabled'
Assert-True (-not [bool]$gate.wildcard_model_or_reasoning) 'gate wildcards disabled'
Assert-True (-not [bool]$gate.route_compiler_is_dispatcher) 'gate compiler non-dispatching'
foreach ($origin in @('ChatGPT_Web','Astral_Bridge','automation','scheduled_task','background_agent')) {
    Assert-True (@($gate.prohibited_origins) -contains $origin) ('gate prohibited origin: ' + $origin)
}

$baseSuite = $fixtureData.fixture_suites.PSObject.Properties['TOKEN-OPT-001'].Value
$a1Suite = $fixtureData.fixture_suites.PSObject.Properties['TOKEN-OPT-001-A1'].Value
$a4Suite = $fixtureData.fixture_suites.PSObject.Properties['TOKEN-OPT-001-A4'].Value
Assert-True (@($baseSuite.fixtures).Count -eq 10 -and [int]$baseSuite.fixture_count -eq 10) 'base behavior fixtures preserved'
Assert-True (@($a1Suite.fixtures).Count -eq 26 -and [int]$a1Suite.fixture_count -eq 26) 'A1 behavior fixtures preserved'
Assert-True (@($a4Suite.fixtures).Count -eq 22 -and [int]$a4Suite.fixture_count -eq 22) 'A4 behavior fixtures preserved'
$allFixtures = @(@($baseSuite.fixtures) + @($a1Suite.fixtures) + @($a4Suite.fixtures))
Assert-True (@($allFixtures | ForEach-Object { $_.id } | Sort-Object -Unique).Count -eq 58) 'historical fixture ids unique'
foreach ($fixture in $allFixtures) {
    $contract = $policy.behavior_contract.PSObject.Properties[$fixture.contract_key].Value
    Assert-True ($null -ne $contract) ('behavior contract exists: ' + $fixture.id)
    Assert-True (($contract | ConvertTo-Json -Depth 20 -Compress) -eq ($fixture.expected | ConvertTo-Json -Depth 20 -Compress)) ('historical behavior fixture: ' + $fixture.id)
}
$routeFixture = (Read-Required (Join-Path $PSScriptRoot 'fixtures\a4-route-compiler-fixtures.json')) | ConvertFrom-Json
Assert-True (@($routeFixture.scenarios).Count -eq 27) 'A4 route fixture scenarios preserved'

foreach ($script in @($paths.compiler,$paths.a4_test,$paths.a6_test)) { Assert-Parse $script }
$guardSource = Join-Path $VaultRoot 'automation\codex-usage-guard'
foreach ($name in @('CodexUsageGuard.ps1','Enable-CodexUsage.ps1','Disable-CodexUsage.ps1','Get-CodexUsageStatus.ps1','Install-CodexUsageGuard.ps1','Test-CodexUsageGuard.ps1')) {
    Assert-Parse (Join-Path $guardSource $name)
}
Assert-True ((Read-Required (Join-Path $guardSource 'Enable-CodexUsage.ps1')).Contains('[Parameter(Mandatory)][ValidateSet(''orchestrator'',''writer'',''read_only_worker'')][string]$Role')) 'manual permit requires exact role'
Assert-True ((Read-Required (Join-Path $guardSource 'Enable-CodexUsage.ps1')).Contains('allow_subagents = $false')) 'manual permit records subagents disabled'

$a4Output = @(& $paths.a4_test -VaultRoot $VaultRoot)
Assert-True (($a4Output -join "`n") -like '*SUMMARY PASS*') 'A4 historical routing suite under A6'
$a6Output = @(& $paths.a6_test -VaultRoot $VaultRoot)
Assert-True (($a6Output -join "`n") -like '*real_codex_calls=0*') 'A6 manual execution gate suite'

if (-not $SkipCatalog) {
    $catalog = (Read-Required $CatalogPath) | ConvertFrom-Json
    $models = @($catalog.models)
    Assert-True ($models.Count -ge 1) 'router catalog populated'
    Assert-True (@($models | Where-Object {
        $_.PSObject.Properties.Name -contains 'multi_agent_version' -and
        [string]$_.multi_agent_version -eq 'v2'
    }).Count -eq 0) 'router catalog has zero v2 child entries'
}

if (-not $SkipPersonal) {
    $configPath = Join-Path $CodexHome 'config.toml'
    $config = Read-Required $configPath
    Assert-True ([regex]::IsMatch($config, '(?ms)^\[agents\]\s*\r?\nenabled\s*=\s*false\s*\r?\nmax_concurrent_threads_per_session\s*=\s*1\s*$')) 'personal agents disabled and thread cap one'
    Assert-True ([regex]::IsMatch($config, '(?m)^multi_agent_v2\s*=\s*\{\s*enabled\s*=\s*false,')) 'personal managed Native V2 disabled'
    Assert-True ($config.Contains('expose_spawn_agent_model_overrides = false')) 'personal child model overrides hidden'

    $router = (Read-Required $RouterStatePath) | ConvertFrom-Json
    Assert-True (@($router.enabled).Count -eq 0) 'router enabled child models zero'
    Assert-True ([string]$router.execution_gate.default_state -eq 'LOCKED') 'router execution gate locked'
    Assert-True ([int]$router.execution_gate.max_processes -eq 1 -and [int]$router.execution_gate.max_children -eq 0) 'router one process zero children'
    Assert-True (-not [bool]$router.execution_gate.allow_subagents) 'router subagents disabled'
    Assert-True (-not [bool]$router.execution_gate.background_continuation -and -not [bool]$router.execution_gate.automatic_fallback) 'router background and fallback disabled'

    $installedGuard = Join-Path $CodexHome 'usage-guard'
    foreach ($name in @('CodexUsageGuard.ps1','Enable-CodexUsage.ps1','Disable-CodexUsage.ps1','Get-CodexUsageStatus.ps1','Install-CodexUsageGuard.ps1','Test-CodexUsageGuard.ps1','README.md')) {
        $source = Join-Path $guardSource $name
        $installed = Join-Path $installedGuard $name
        Assert-True (Test-Path -LiteralPath $installed -PathType Leaf) ('installed guard file: ' + $name)
        Assert-True ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -eq (Get-FileHash -LiteralPath $installed -Algorithm SHA256).Hash) ('installed guard equals source: ' + $name)
    }
    $statusText = @(& (Join-Path $installedGuard 'Get-CodexUsageStatus.ps1')) -join "`n"
    $status = $statusText | ConvertFrom-Json
    Assert-True ([string]$status.status -eq 'PROTECTED') 'usage guard status protected'
    Assert-True ([int]$status.billable_or_interactive_codex.count -eq 0) 'zero billable or interactive Codex processes'
    Assert-True ([int]$status.guard.watcher_process_count -eq 1) 'one usage guard watcher'
    Assert-True ([string]$status.guard.task_state -eq 'Running') 'usage guard task running'
    Assert-True ([string]$status.permit.state -ne 'ACTIVE') 'no active manual permit'
    $guardTestOutput = @(& (Join-Path $installedGuard 'Test-CodexUsageGuard.ps1'))
    Assert-True (($guardTestOutput -join "`n") -like '*SUMMARY PASS guard=dummy_terminated permit=single_use real_codex_calls=0*') 'usage guard harmless-dummy self-test'
}

if (-not [string]::IsNullOrWhiteSpace($BackupManifest)) {
    Assert-True (Test-Path -LiteralPath $BackupManifest -PathType Leaf) 'requested backup manifest exists'
    $manifest = (Read-Required $BackupManifest) | ConvertFrom-Json
    Assert-True ($null -ne $manifest) 'requested backup manifest parses'
}

$newFiles = @(
    $paths.agents,$paths.policy_md,$paths.policy_json,$paths.profile,$paths.gate,$paths.compiler,$paths.a4_test,$paths.a6_test,$paths.readme,$paths.standard,$paths.extension,$paths.a6
) + @(Get-ChildItem -LiteralPath $guardSource -File | ForEach-Object { $_.FullName })
$redactedText = @($newFiles | ForEach-Object { [IO.File]::ReadAllText($_) }) -join "`n"
Assert-True (-not [regex]::IsMatch($redactedText, '(?i)(?:(?:^|[^A-Za-z0-9])sk-[A-Za-z0-9_-]{12,}|api[_-]?key\s*[=:]\s*["''][^"'']{12,}|password\s*[=:]\s*["''][^"'']{8,})')) 'A6 source redaction scan'

Write-Output ('SUMMARY PASS policy=A6 manual_only=true max_processes=1 max_children=0 a4_fixtures=27 behavior_fixtures=58 personal=' + $(if ($SkipPersonal) { 'SKIPPED' } else { 'PASS' }) + ' catalog=' + $(if ($SkipCatalog) { 'SKIPPED' } else { 'PASS' }) + ' real_codex_calls=0')
