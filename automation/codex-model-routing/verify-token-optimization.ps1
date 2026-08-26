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
    context_index = Join-Path $VaultRoot 'CONTEXT_INDEX.md'
    current = Join-Path $VaultRoot '.codex\CURRENT.md'
    policy_md = Join-Path $VaultRoot 'protocols\CODEX_TOKEN_OPTIMIZATION_AND_CONTEXT_EFFICIENCY_RULES.md'
    policy_json = Join-Path $VaultRoot 'automation\codex-model-routing\token-optimization.policy.json'
    fixtures = Join-Path $VaultRoot 'automation\codex-model-routing\token-optimization.behavior-fixtures.json'
    profile = Join-Path $VaultRoot 'automation\codex-model-routing\current-routing-profile.json'
    gate = Join-Path $VaultRoot 'automation\codex-model-routing\manual-codex-execution-gate.json'
    compiler = Join-Path $VaultRoot 'automation\codex-model-routing\route-compiler.ps1'
    a4_test = Join-Path $VaultRoot 'automation\codex-model-routing\test-a4-routing.ps1'
    a6_test = Join-Path $VaultRoot 'automation\codex-model-routing\test-a6-manual-execution-gate.ps1'
    a7_test = Join-Path $VaultRoot 'automation\codex-model-routing\test-a7-owner-started-sol-routing.ps1'
    a8_test = Join-Path $VaultRoot 'automation\codex-model-routing\test-a8-sol-advisor-routing.ps1'
    sol_advisor_global_test = Join-Path $VaultRoot 'automation\codex-model-routing\test-sol-advisor-global-routing.ps1'
    ox_contract = Join-Path $VaultRoot 'automation\codex-model-routing\contracts\ox-writer-contract.json'
    readme = Join-Path $VaultRoot 'automation\codex-model-routing\README.md'
    standard = Join-Path $VaultRoot 'automation\codex-model-routing\ROUTING_STANDARD.md'
    usage_guard_readme = Join-Path $VaultRoot 'automation\codex-usage-guard\README.md'
    extension = Join-Path $VaultRoot 'governance\agents\extensions\global-codex.PROJECT_POLICY.md'
    a2 = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A2.md'
    a3 = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A3.md'
    a4 = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A4.md'
    a5 = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A5.md'
    a6 = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A6.md'
    a7 = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A7.md'
    a8 = Join-Path $VaultRoot 'governance\agents\specs\TOKEN-OPT-001-A8.md'
}
$content = @{}
foreach ($entry in $paths.GetEnumerator()) { $content[$entry.Key] = Read-Required $entry.Value }

foreach ($marker in @('GOVERNANCE_REVISION: SOL-ADVISOR-GLOBAL-001','SOL-ADVISOR-GLOBAL-001 routing contract','solo|delegate|audit|full','one auxiliary','BILLABLE CODEX EXECUTION: LOCKED BY DEFAULT','SOL SUBAGENTS: PROHIBITED','A8 is retained only as historical safety-boundary provenance','DeepSeek is disabled')) {
    Assert-True (($content.agents + "`n" + $content.policy_md).Contains($marker)) ('canonical SOL marker: ' + $marker)
}
Assert-True (-not [regex]::IsMatch(($content.agents + "`n" + $content.policy_md), '(?m)^DEFAULT CHILDREN:\s*0\s*$|^MAX (?:DIRECT )?SOL (?:CHILDREN|SUBAGENTS):\s*16\s*$')) 'active governance has no mandatory zero-start or Sol-child ceiling'
Assert-True ([regex]::IsMatch($content.readme, '(?i)routing metadata never authorizes')) 'routing README denies implicit execution authority'
Assert-True $content.standard.Contains('Routing is selection metadata, not permission') 'routing standard separates selection and execution'
Assert-True $content.extension.Contains('SOL-ADVISOR-GLOBAL-001') 'global Codex extension inherits current contract'
foreach ($documentKey in @('context_index','readme','standard','usage_guard_readme','policy_md')) {
    $document = $content[$documentKey]
    Assert-True $document.Contains('SOL-ADVISOR-GLOBAL-001') ("current routing document names Sol Advisor: $documentKey")
    Assert-True ([regex]::IsMatch($document, 'solo\s+(?:is|as)\s+the\s+default')) ("current routing document preserves solo default: $documentKey")
    Assert-True ([regex]::IsMatch($document, 'at\s+most\s+one\s+auxiliary')) ("current routing document preserves one auxiliary: $documentKey")
    Assert-True ([regex]::IsMatch($document, 'Luna\s*/\s*Max')) ("current routing document preserves Luna Max lane: $documentKey")
    Assert-True ([regex]::IsMatch($document, 'Terra\s*/\s*High')) ("current routing document preserves Terra High lane: $documentKey")
    Assert-True ([regex]::IsMatch($document, 'Ox\s+is(?:\s+a\s+temporary)?\s+implementation-only(?:,?\s+and)?\s*,?\s*fail-closed')) ("current routing document preserves fail-closed Ox: $documentKey")
    Assert-True ([regex]::IsMatch($document, 'A8\s+is\s+locked\s+safety/history\s+only')) ("current routing document marks A8 historical safety only: $documentKey")
}
foreach ($staleA8Default in @(
    @{ document = 'context_index'; text = 'Active Sol-parent topology' },
    @{ document = 'readme'; text = 'active A8 selection profile' },
    @{ document = 'standard'; text = 'Under A8, the' },
    @{ document = 'usage_guard_readme'; text = 'multiple useful bounded direct' },
    @{ document = 'policy_md'; text = 'use no workers or multiple useful bounded direct workers' }
)) {
    Assert-True (-not $content[$staleA8Default.document].Contains($staleA8Default.text)) ("current routing document has no stale A8 default: $($staleA8Default.document)")
}
Assert-True $content.current.Contains('CURRENT_STATUS:') 'CURRENT has one active status block'
Assert-True $content.current.Contains('## Historical / superseded role-discovery boundary') 'CURRENT labels retained role-discovery record historical'
Assert-True (-not [regex]::IsMatch($content.current, '(?m)^(?:TASK|STATUS|BASELINE_HEAD|BLOCKER|NEXT_EXACT_ACTION):')) 'CURRENT has no ambiguous unprefixed historical state'

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
Assert-True ($content.a7.Contains('status: accepted') -and $content.a7.Contains('TOKEN-OPT-001-A7')) 'A7 historical safety specification preserved'
Assert-True ($content.a8.Contains('status: accepted') -and $content.a8.Contains('TOKEN-OPT-001-A8')) 'A8 historical safety specification preserved'

$policy = $content.policy_json | ConvertFrom-Json
$profile = $content.profile | ConvertFrom-Json
$gate = $content.gate | ConvertFrom-Json
$fixtureData = $content.fixtures | ConvertFrom-Json
Assert-True ([int]$policy.schema_version -eq 6) 'policy schema version 6'
foreach ($amendment in @('TOKEN-OPT-001-A1','TOKEN-OPT-001-A2','TOKEN-OPT-001-A3','TOKEN-OPT-001-A4','TOKEN-OPT-001-A5','TOKEN-OPT-001-A6','TOKEN-OPT-001-A7','TOKEN-OPT-001-A8','SOL-ADVISOR-GLOBAL-001')) {
    Assert-True (@($policy.accepted_amendments) -contains $amendment) ('accepted amendment: ' + $amendment)
}
Assert-True ([bool]$policy.defaults.agents_enabled -and [bool]$policy.defaults.multi_agent_v2_enabled) 'policy Native V2 enabled'
Assert-True ([string]$policy.current_routing_v2.contract_id -eq 'SOL-ADVISOR-GLOBAL-001' -and ((@($policy.current_routing_v2.modes) -join '|') -eq 'solo|delegate|audit|full')) 'policy current Sol Advisor contract'
Assert-True ([bool]$policy.current_routing_v2.solo_default -and [int]$policy.current_routing_v2.default_auxiliaries_max -eq 1) 'policy solo default one auxiliary'
Assert-True ([string]$policy.current_routing_v2.native_implementation_lanes.bounded.model -eq 'gpt-5.6-luna' -and [string]$policy.current_routing_v2.native_implementation_lanes.bounded.reasoning_effort -eq 'max') 'policy Luna Max bounded implementation'
Assert-True ([string]$policy.current_routing_v2.native_implementation_lanes.high_risk.model -eq 'gpt-5.6-terra' -and [string]$policy.current_routing_v2.native_implementation_lanes.high_risk.reasoning_effort -eq 'high') 'policy Terra High high-risk implementation'
Assert-True ([string]$policy.current_routing_v2.fresh_sol_review.model -eq 'gpt-5.6-sol' -and [bool]$policy.current_routing_v2.fresh_sol_review.read_only) 'policy fresh Sol High review'
Assert-True ([bool]$policy.current_routing_v2.ox_overlay.implementation_only -and [string]$policy.current_routing_v2.ox_overlay.status -eq 'OX_OVERLAY_DISABLED') 'policy Ox overlay disabled implementation-only'
Assert-True (-not [bool]$policy.defaults.sol_subagents_allowed -and [int]$policy.defaults.max_delegation_depth -eq 1 -and -not [bool]$policy.defaults.recursive_worker_spawning) 'policy depth-one no recursive Sol children'
Assert-True ([int]$policy.defaults.max_overlapping_writers -eq 2 -and [int]$policy.defaults.max_writers_per_repository_or_worktree -eq 1) 'policy writer safety caps'
Assert-True (-not [bool]$policy.defaults.background_continuation -and -not [bool]$policy.defaults.automatic_fallback) 'policy background and fallback disabled'

Assert-True ([int]$profile.schema_version -eq 5 -and [string]$profile.profile_id -eq 'SOL-ADVISOR-GLOBAL-001-current') 'profile identity schema 5'
Assert-True ((@($profile.sol_advisor.modes) -join '|') -eq 'solo|delegate|audit|full' -and [bool]$profile.sol_advisor.solo_default -and [int]$profile.sol_advisor.default_auxiliaries_max -eq 1) 'profile Sol Advisor exact modes and default'
Assert-True ([string]$profile.sol_advisor.native_roles.luna_implementer.model -eq 'gpt-5.6-luna' -and [string]$profile.sol_advisor.native_roles.luna_implementer.reasoning_effort -eq 'max') 'profile Luna Max native lane'
Assert-True ([string]$profile.sol_advisor.native_roles.terra_implementer.model -eq 'gpt-5.6-terra' -and [string]$profile.sol_advisor.native_roles.terra_implementer.reasoning_effort -eq 'high') 'profile Terra High native lane'
Assert-True ([string]$profile.sol_advisor.native_roles.sol_reviewer.model -eq 'gpt-5.6-sol' -and [bool]$profile.sol_advisor.native_roles.sol_reviewer.read_only -and [bool]$profile.sol_advisor.native_roles.sol_reviewer.fresh_context_required) 'profile fresh Sol reviewer lane'
Assert-True ([string]$profile.ox_overlay.status -eq 'OX_OVERLAY_DISABLED' -and [bool]$profile.ox_overlay.implementation_only -and ((@($profile.ox_overlay.allowed_route_modes) -join '|') -eq 'delegate|full')) 'profile fail-closed Ox overlay'
Assert-True ([int]$profile.concurrency.default_auxiliaries_max -eq 1 -and [int]$profile.concurrency.max_active_auxiliaries -eq 1 -and [bool]$profile.concurrency.fresh_sol_reviewer_allowed) 'profile one auxiliary and reviewer'
Assert-True (-not [bool]$profile.concurrency.sol_subagents_allowed -and [int]$profile.concurrency.max_delegation_depth -eq 1 -and -not [bool]$profile.concurrency.recursive_worker_spawning) 'profile depth-one no Sol child'
Assert-True ([int]$profile.concurrency.legacy_guard_safety_caps.max_luna_max_subagents -eq 16 -and [int]$profile.concurrency.legacy_guard_safety_caps.max_terra_max_subagents -eq 2 -and [int]$profile.concurrency.legacy_guard_safety_caps.max_ox_alpha_subagents -eq 16 -and [int]$profile.concurrency.legacy_guard_safety_caps.max_total_direct_subagents -eq 16) 'profile A8 guard caps retained as safety metadata'
Assert-True ($null -ne $profile.historical_roles -and $null -ne $profile.historical_active_roles -and $null -ne $profile.historical_fallbacks) 'A8 routing metadata retained only as historical provenance'
Assert-True (@($profile.catalog.disabled_models | Where-Object { [string]$_ -like '*deepseek*' }).Count -ge 4) 'DeepSeek disabled aliases recorded'

Assert-True ([string]$gate.policy_id -eq 'SOL-ADVISOR-GLOBAL-001' -and [string]$gate.default_state -eq 'LOCKED' -and [bool]$gate.manual_only -and [bool]$gate.owner_started_sol_session) 'gate locked manual owner-started'
Assert-True ([int]$gate.default_auxiliaries_max -eq 1 -and [bool]$gate.fresh_sol_reviewer_allowed -and [int]$gate.max_fresh_sol_reviewers -eq 1) 'gate one auxiliary fresh reviewer'
Assert-True (-not [bool]$gate.sol_subagents_allowed -and [bool]$gate.allow_subagents -and [int]$gate.max_delegation_depth -eq 1 -and -not [bool]$gate.recursive_spawning) 'gate depth-one non-recursive safety'
Assert-True ([int]$gate.max_luna_max_subagents -eq 16 -and [int]$gate.max_terra_max_subagents -eq 2 -and [int]$gate.max_ox_alpha_subagents -eq 16 -and [int]$gate.max_total_direct_subagents -eq 16 -and [bool]$gate.legacy_guard_safety_caps_only) 'gate A8 caps only safety compatibility'
Assert-True ([int]$gate.max_active_writers_account_wide -eq 2 -and [int]$gate.max_writers_per_repository_or_worktree -eq 1) 'gate writer safety caps'
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

foreach ($script in @($paths.compiler,$paths.a4_test,$paths.a6_test,$paths.a7_test,$paths.a8_test,$paths.sol_advisor_global_test)) { Assert-Parse $script }
foreach ($marker in @('Get-RequiredBoolean','OX_PROVIDER_AVAILABLE_BOOLEAN_REQUIRED','OX_CALLABLE_BOOLEAN_REQUIRED','OX_BILLING_UNAMBIGUOUS_BOOLEAN_REQUIRED','OX_CAPABILITIES_PRESENT_BOOLEAN_REQUIRED','Assert-SolAdvisorRouteTopology','SOL_ADVISOR_SOLO_AUXILIARY_COUNT_INVALID','SOL_ADVISOR_DELEGATE_IMPLEMENTATION_AUXILIARY_REQUIRED','SOL_ADVISOR_FULL_WRITER_IMPLEMENTATION_AUXILIARY_REQUIRED','SOL_ADVISOR_FULL_REVIEWER_AUXILIARY_REQUIRED')) {
    Assert-True $content.compiler.Contains($marker) ('active compiler invariant marker: ' + $marker)
}
$guardSource = Join-Path $VaultRoot 'automation\codex-usage-guard'
foreach ($name in @('CodexUsageGuard.ps1','Enable-CodexUsage.ps1','Disable-CodexUsage.ps1','Get-CodexUsageStatus.ps1','Install-CodexUsageGuard.ps1','Test-CodexUsageGuard.ps1')) {
    Assert-Parse (Join-Path $guardSource $name)
}
$guardRuntimeSource = Read-Required (Join-Path $guardSource 'CodexUsageGuard.ps1')
foreach ($marker in @('PermitContractProbe','PermitContractProbePath','Test-ManualPermitContract','Get-PermitContractFromPath','MANUAL_PERMIT_REVIEWER_CONTRACT_INVALID','MANUAL_PERMIT_FRESH_SOL_REVIEWER_ALLOWED_BOOLEAN_INVALID','legacy_guard_safety_caps_only','active_reviewer_contract_valid','legacy_active_shape_denied','string_boolean_denied')) {
    Assert-True $guardRuntimeSource.Contains($marker) ('guard active contract marker: ' + $marker)
}
$issuerSource = Read-Required (Join-Path $guardSource 'Enable-CodexUsage.ps1')
foreach ($marker in @('ContractProbe','Assert-ManualPermitContract','New-ManualCodexPermit','sol_subagents_allowed = $false','default_auxiliaries_max = 1','fresh_sol_reviewer_allowed = $true','max_fresh_sol_reviewers = 1','legacy_guard_safety_caps_only = $true','Reviewer permits require exact gpt-5.6-sol with high reasoning.')) {
    Assert-True $issuerSource.Contains($marker) ('manual issuer active contract marker: ' + $marker)
}

$a4Output = @(& $paths.a4_test -VaultRoot $VaultRoot)
Assert-True (($a4Output -join "`n") -like '*SUMMARY PASS a4_historical_fixtures=*') 'A4 historical routing suite'
$a6Output = @(& $paths.a6_test -VaultRoot $VaultRoot)
Assert-True (($a6Output -join "`n") -like '*real_codex_calls=0*') 'A6 historical manual gate suite'
$a7Output = @(& $paths.a7_test -VaultRoot $VaultRoot)
Assert-True (($a7Output -join "`n") -like '*SUMMARY PASS a7_owner_started_sol_routing=*real_codex_calls=0*') 'A7 historical owner-started Sol suite'
$a8Output = @(& $paths.a8_test -VaultRoot $VaultRoot)
Assert-True (($a8Output -join "`n") -like '*SUMMARY PASS a8_sol_advisor_routing=*real_codex_calls=0*') 'A8 historical Sol advisor suite'
$solAdvisorGlobalOutput = @(& $paths.sol_advisor_global_test -VaultRoot $VaultRoot)
Assert-True (($solAdvisorGlobalOutput -join "`n") -like '*SUMMARY PASS sol_advisor_global_routing=19 negative_regressions=14 actual_issuer_probe=1 guard_contract_probe=1 real_codex_calls=0*') 'SOL-ADVISOR-GLOBAL-001 active routing suite uses issuer and guard contract probes'

if (-not $SkipCatalog) {
    $catalog = (Read-Required $CatalogPath) | ConvertFrom-Json
    foreach ($required in @(
        @{ id = 'gpt-5.6-sol'; effort = 'high' },
        @{ id = 'gpt-5.6-terra'; effort = 'high' },
        @{ id = 'gpt-5.6-luna'; effort = 'max' }
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
    Assert-True (@($router.enabled | Where-Object { [string]$_ -like '*deepseek*' }).Count -eq 0) 'DeepSeek absent from enabled routing'
    Assert-True (-not [bool]$router.execution_gate.sol_subagents_allowed -and [int]$router.execution_gate.max_luna_max_subagents -eq 16 -and [int]$router.execution_gate.max_terra_max_subagents -eq 2 -and [int]$router.execution_gate.max_ox_alpha_subagents -eq 16) 'router retained A8 safety gate'
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
$newFiles = @($paths.agents,$paths.policy_md,$paths.policy_json,$paths.profile,$paths.gate,$paths.compiler,$paths.readme,$paths.standard,$paths.extension) + @(Get-ChildItem -LiteralPath $guardSource -File | ForEach-Object { $_.FullName })
$redactedText = @($newFiles | ForEach-Object { [IO.File]::ReadAllText($_) }) -join "`n"
Assert-True (-not [regex]::IsMatch($redactedText, '(?i)(?:(?:^|[^A-Za-z0-9])sk-[A-Za-z0-9_-]{12,}|api[_-]?key\s*[=:]\s*["''][^"'']{12,}|password\s*[=:]\s*["''][^"'']{8,})')) 'SOL source redaction scan'
Write-Output ('SUMMARY PASS policy=SOL-ADVISOR-GLOBAL-001 one_auxiliary=1 fresh_sol_review=1 legacy_guard_caps=16/2/16/16 depth=1 writer_caps=2/1 behavior_fixtures=58 personal=' + $(if ($SkipPersonal) { 'SKIPPED' } else { 'PASS' }) + ' catalog=' + $(if ($SkipCatalog) { 'SKIPPED' } else { 'PASS' }) + ' real_codex_calls=0')
