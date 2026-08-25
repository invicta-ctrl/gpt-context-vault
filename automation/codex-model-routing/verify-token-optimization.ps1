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
function Assert-Parse([string]$Path) {
    $tokens = $null; $errors = $null
    [Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors) | Out-Null
    Assert-True ($errors.Count -eq 0) ('PowerShell parse: ' + $Path)
}
function Get-ModelEfforts($Model) {
    @($Model.supported_reasoning_levels | ForEach-Object { if ($_ -is [string]) { [string]$_ } else { [string]$_.effort } })
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
    a7_test = Join-Path $VaultRoot 'automation\codex-model-routing\test-a7-owner-started-sol-routing.ps1'
    ox_contract = Join-Path $VaultRoot 'automation\codex-model-routing\contracts\ox-writer-contract.json'
    readme = Join-Path $VaultRoot 'automation\codex-model-routing\README.md'
    standard = Join-Path $VaultRoot 'automation\codex-model-routing\ROUTING_STANDARD.md'
    extension = Join-Path $VaultRoot 'governance\agents\extensions\global-codex.PROJECT_POLICY.md'
    a2 = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A2.md'
    a3 = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A3.md'
    a4 = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A4.md'
    a5 = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A5.md'
    a6 = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A6.md'
    a7 = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A7.md'
}
$content = @{}
foreach ($entry in $paths.GetEnumerator()) { $content[$entry.Key] = Read-Required $entry.Value }

foreach ($marker in @('GOVERNANCE_REVISION: TOKEN-OPT-001-A7','BILLABLE CODEX EXECUTION: LOCKED BY DEFAULT','OWNER-STARTED SOL SESSION','MAX DIRECT SOL CHILDREN: 16','DELEGATION DEPTH: 1','DeepSeek is disabled')) {
    Assert-True (($content.agents + "`n" + $content.policy_md).Contains($marker)) ('canonical A7 marker: ' + $marker)
}
Assert-True ([regex]::IsMatch($content.readme, '(?i)routing metadata never authorizes')) 'routing README denies implicit execution authority'
Assert-True $content.standard.Contains('Routing is selection metadata, not permission') 'routing standard separates selection and execution'
Assert-True $content.extension.Contains('Native Multi-Agent V2 is enabled') 'global Codex extension enables Native V2'

$specHashes = [ordered]@{
    a2 = 'fda3b018dbdf7e3f597cfb07d797633cc8ebbb30cab23f94e1806f9d960918e2'
    a3 = 'dc31c20cef4bc39f4165339e323ebee07c26a3499b8705f840648932f9eec8be'
    a4 = 'd9c94e95430b8f4e510620d2262aa788acfc6160d5be0dcb3a98aa38ece27fa2'
    a5 = '26506857adafe95f523aa927a4562034d20a5b10a615053f30ff4012f3f96843'
    a6 = '7036975cc0ef3ec3580f060c49759e8d07871f927a06f9e91674fd5d9c95de47'
}
foreach ($key in @('a2','a3','a4','a5','a6')) {
    $hash = (Get-FileHash -LiteralPath $paths[$key] -Algorithm SHA256).Hash.ToLowerInvariant()
    Assert-True ($hash -eq $specHashes[$key]) ("preserved $($key.ToUpperInvariant()) hash")
}
Assert-True ($content.a7.Contains('status: accepted') -and $content.a7.Contains('TOKEN-OPT-001-A7')) 'A7 accepted specification'

$policy = $content.policy_json | ConvertFrom-Json
$profile = $content.profile | ConvertFrom-Json
$gate = $content.gate | ConvertFrom-Json
$fixtureData = $content.fixtures | ConvertFrom-Json
Assert-True ([int]$policy.schema_version -eq 5) 'policy schema version 5'
foreach ($amendment in @('TOKEN-OPT-001-A1','TOKEN-OPT-001-A2','TOKEN-OPT-001-A3','TOKEN-OPT-001-A4','TOKEN-OPT-001-A5','TOKEN-OPT-001-A6','TOKEN-OPT-001-A7')) {
    Assert-True (@($policy.accepted_amendments) -contains $amendment) ('accepted amendment: ' + $amendment)
}
Assert-True ([bool]$policy.defaults.agents_enabled -and [bool]$policy.defaults.multi_agent_v2_enabled) 'policy Native V2 enabled'
Assert-True ([int]$policy.defaults.default_children -eq 0 -and [int]$policy.defaults.max_children -eq 16) 'policy children 0 default 16 max'
Assert-True ([int]$policy.defaults.max_delegation_depth -eq 1 -and -not [bool]$policy.defaults.recursive_worker_spawning) 'policy depth one non-recursive'
Assert-True ([int]$policy.defaults.max_overlapping_writers -eq 2 -and [int]$policy.defaults.max_writers_per_repository_or_worktree -eq 1) 'policy writer caps 2 account 1 target'
Assert-True (-not [bool]$policy.defaults.background_continuation -and -not [bool]$policy.defaults.automatic_fallback) 'policy background and fallback disabled'

Assert-True ([string]$profile.profile_id -eq 'TOKEN-OPT-001-A7-current') 'profile identity A7'
Assert-True ([string]$profile.role_catalog_status -eq 'ACTIVE_A7_SELECTION_ONLY') 'profile A7 selection active'
Assert-True ([string]$profile.active_roles.orchestrator.model -eq 'gpt-5.6-sol' -and [string]$profile.active_roles.orchestrator.reasoning_effort -eq 'high') 'Sol High parent'
Assert-True ([string]$profile.active_roles.writers.backend_primary.model -eq 'openrouter/stealth/ox-alpha') 'Ox backend primary'
Assert-True ([string]$profile.active_roles.writers.integration_fallback.model -eq 'gpt-5.6-terra' -and [bool]$profile.active_roles.writers.integration_fallback.requires_explicit_sol_decision) 'Terra explicit fallback'
Assert-True ([string]$profile.active_roles.writers.hau_frontend.model -eq 'gpt-5.6-terra') 'HAU frontend Terra writer'
Assert-True ([string]$profile.active_roles.read_only_workers.luna.model -eq 'gpt-5.6-luna') 'Luna read-only'
Assert-True (@($profile.fallbacks.active).Count -eq 0 -and -not [bool]$profile.fallbacks.automatic) 'no active automatic fallback'
Assert-True (@($profile.catalog.disabled_models | Where-Object { [string]$_ -like '*deepseek*' }).Count -ge 4) 'DeepSeek disabled aliases recorded'

Assert-True ([string]$gate.policy_id -eq 'TOKEN-OPT-001-A7') 'gate policy A7'
Assert-True ([string]$gate.default_state -eq 'LOCKED' -and [bool]$gate.manual_only -and [bool]$gate.owner_started_sol_session) 'gate locked owner-started manual'
Assert-True ([int]$gate.default_children -eq 0 -and [int]$gate.max_children -eq 16 -and [bool]$gate.allow_subagents) 'gate child boundary'
Assert-True ([int]$gate.max_delegation_depth -eq 1 -and -not [bool]$gate.recursive_spawning) 'gate non-recursive depth one'
Assert-True ([int]$gate.max_active_writers_account_wide -eq 2 -and [int]$gate.max_writers_per_repository_or_worktree -eq 1) 'gate writer caps'
Assert-True (-not [bool]$gate.background_continuation -and -not [bool]$gate.automatic_fallback -and -not [bool]$gate.route_compiler_is_dispatcher) 'gate no background fallback or dispatch'
foreach ($origin in @('ChatGPT_Web','Astral_Bridge','automation','scheduled_task','background_agent')) {
    Assert-True (@($gate.prohibited_origins) -contains $origin) ('gate prohibited origin: ' + $origin)
}

$baseSuite = $fixtureData.fixture_suites.PSObject.Properties['TOKEN-OPT-001'].Value
$a1Suite = $fixtureData.fixture_suites.PSObject.Properties['TOKEN-OPT-001-A1'].Value
$a4Suite = $fixtureData.fixture_suites.PSObject.Properties['TOKEN-OPT-001-A4'].Value
$allFixtures = @(@($baseSuite.fixtures) + @($a1Suite.fixtures) + @($a4Suite.fixtures))
Assert-True (@($allFixtures).Count -eq 58 -and @($allFixtures | ForEach-Object { $_.id } | Sort-Object -Unique).Count -eq 58) '58 historical behavior fixtures preserved'
foreach ($fixture in $allFixtures) {
    $contract = $policy.behavior_contract.PSObject.Properties[$fixture.contract_key].Value
    Assert-True ($null -ne $contract -and ($contract | ConvertTo-Json -Depth 20 -Compress) -eq ($fixture.expected | ConvertTo-Json -Depth 20 -Compress)) ('historical behavior fixture: ' + $fixture.id)
}
$routeFixture = (Read-Required (Join-Path $PSScriptRoot 'fixtures\a4-route-compiler-fixtures.json')) | ConvertFrom-Json
Assert-True (@($routeFixture.scenarios).Count -eq 27) '27 A4 route fixtures preserved'

foreach ($script in @($paths.compiler,$paths.a4_test,$paths.a6_test,$paths.a7_test)) { Assert-Parse $script }
$guardSource = Join-Path $VaultRoot 'automation\codex-usage-guard'
foreach ($name in @('CodexUsageGuard.ps1','Enable-CodexUsage.ps1','Disable-CodexUsage.ps1','Get-CodexUsageStatus.ps1','Install-CodexUsageGuard.ps1','Test-CodexUsageGuard.ps1')) {
    Assert-Parse (Join-Path $guardSource $name)
}
Assert-True ((Read-Required (Join-Path $guardSource 'Enable-CodexUsage.ps1')).Contains('allow_subagents = $true')) 'manual permit records A7 subagent availability'

$a4Output = @(& $paths.a4_test -VaultRoot $VaultRoot)
Assert-True (($a4Output -join "`n") -like '*SUMMARY PASS*') 'A4 historical routing suite under A6'
$a6Output = @(& $paths.a6_test -VaultRoot $VaultRoot)
Assert-True (($a6Output -join "`n") -like '*real_codex_calls=0*') 'A6 historical manual gate suite'
$a7Output = @(& $paths.a7_test -VaultRoot $VaultRoot)
Assert-True (($a7Output -join "`n") -like '*real_codex_calls=0*') 'A7 owner-started Sol routing suite'

if (-not $SkipCatalog) {
    $catalog = (Read-Required $CatalogPath) | ConvertFrom-Json
    foreach ($required in @(
        @{ id = 'gpt-5.6-sol'; effort = 'high' },
        @{ id = 'gpt-5.6-terra'; effort = 'max' },
        @{ id = 'gpt-5.6-luna'; effort = 'max' },
        @{ id = 'openrouter/stealth/ox-alpha'; effort = 'high' }
    )) {
        $model = @($catalog.models | Where-Object { [string]$_.slug -eq $required.id }) | Select-Object -First 1
        Assert-True ($null -ne $model -and (Get-ModelEfforts $model) -contains $required.effort) ('catalog model and effort: ' + $required.id)
    }
}

if (-not $SkipPersonal) {
    $config = Read-Required (Join-Path $CodexHome 'config.toml')
    Assert-True ([regex]::IsMatch($config, '(?ms)^\[agents\]\s*\r?\nenabled\s*=\s*true\s*\r?\nmax_concurrent_threads_per_session\s*=\s*16\s*$')) 'personal agents enabled thread cap 16'
    Assert-True ([regex]::IsMatch($config, '(?m)^multi_agent_v2\s*=\s*\{\s*enabled\s*=\s*true,') -and $config.Contains('expose_spawn_agent_model_overrides = true')) 'personal Native V2 and model overrides enabled'
    $router = (Read-Required $RouterStatePath) | ConvertFrom-Json
    $expectedEnabled = @('gpt-5.6-luna','gpt-5.6-terra','openrouter/stealth/ox-alpha')
    Assert-True ((@($router.enabled | Sort-Object) -join '|') -eq ($expectedEnabled -join '|')) 'router enabled child models exact'
    Assert-True (@($router.enabled | Where-Object { [string]$_ -like '*deepseek*' }).Count -eq 0) 'DeepSeek absent from enabled routing'
    Assert-True ([string]$router.execution_gate.policy_id -eq 'TOKEN-OPT-001-A7' -and [int]$router.execution_gate.max_children -eq 16) 'router A7 gate'
    $picker = (Read-Required (Join-Path $CodexHome 'codex-router\model-picker.json')) | ConvertFrom-Json
    Assert-True (@($picker.seeded | Where-Object { [string]$_ -like '*deepseek*' }).Count -eq 0) 'DeepSeek absent from picker seeds'
    $providers = (Read-Required (Join-Path $CodexHome 'codex-router\enabled-providers.json')) | ConvertFrom-Json
    Assert-True (@($providers.providers) -notcontains 'deepseek') 'DeepSeek provider inactive'
    $hooks = (Read-Required (Join-Path $CodexHome 'hooks.json')) | ConvertFrom-Json
    $sessionEnd = @($hooks.hooks.SessionEnd[0].hooks | Where-Object { [string]$_.command -like '*lean-ctx*observe*' })
    Assert-True ($sessionEnd.Count -eq 1 -and [int]$sessionEnd[0].timeout -eq 3) 'SessionEnd lean-ctx timeout 3'
    $installedGuard = Join-Path $CodexHome 'usage-guard'
    foreach ($name in @('CodexUsageGuard.ps1','Enable-CodexUsage.ps1','Disable-CodexUsage.ps1','Get-CodexUsageStatus.ps1','Install-CodexUsageGuard.ps1','Test-CodexUsageGuard.ps1','README.md')) {
        Assert-True ((Get-FileHash -LiteralPath (Join-Path $guardSource $name) -Algorithm SHA256).Hash -eq (Get-FileHash -LiteralPath (Join-Path $installedGuard $name) -Algorithm SHA256).Hash) ('installed guard equals source: ' + $name)
    }
    $status = (@(& (Join-Path $installedGuard 'Get-CodexUsageStatus.ps1')) -join "`n") | ConvertFrom-Json
    Assert-True ([string]$status.status -eq 'PROTECTED' -and [int]$status.billable_or_interactive_codex.count -eq 0) 'usage guard protected with zero billable processes'
    $guardTestOutput = @(& (Join-Path $installedGuard 'Test-CodexUsageGuard.ps1'))
    Assert-True (($guardTestOutput -join "`n") -like '*real_codex_calls=0*') 'usage guard harmless-dummy self-test'
}

if (-not [string]::IsNullOrWhiteSpace($BackupManifest)) {
    $manifest = (Read-Required $BackupManifest) | ConvertFrom-Json
    Assert-True ($null -ne $manifest -and [int]$manifest.verified_count -eq 24) 'A7 backup manifest 24 verified files'
}
$newFiles = @($paths.agents,$paths.policy_md,$paths.policy_json,$paths.profile,$paths.gate,$paths.compiler,$paths.a7_test,$paths.ox_contract,$paths.readme,$paths.standard,$paths.extension,$paths.a7) + @(Get-ChildItem -LiteralPath $guardSource -File | ForEach-Object { $_.FullName })
$redactedText = @($newFiles | ForEach-Object { [IO.File]::ReadAllText($_) }) -join "`n"
Assert-True (-not [regex]::IsMatch($redactedText, '(?i)(?:(?:^|[^A-Za-z0-9])sk-[A-Za-z0-9_-]{12,}|api[_-]?key\s*[=:]\s*["''][^"'']{12,}|password\s*[=:]\s*["''][^"'']{8,})')) 'A7 source redaction scan'
Write-Output ('SUMMARY PASS policy=A7 default_children=0 max_children=16 depth=1 writer_caps=2/1 behavior_fixtures=58 personal=' + $(if ($SkipPersonal) { 'SKIPPED' } else { 'PASS' }) + ' catalog=' + $(if ($SkipCatalog) { 'SKIPPED' } else { 'PASS' }) + ' real_codex_calls=0')
