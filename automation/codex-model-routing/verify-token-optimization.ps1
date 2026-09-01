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
function Pass([string]$Name) { Write-Output ('PASS ' + $Name) }
function Assert-True([bool]$Condition,[string]$Name) { if (-not $Condition) { throw ('VERIFY_FAILURE: ' + $Name) }; Pass $Name }
function Read-Required([string]$Path) { Assert-True (Test-Path -LiteralPath $Path -PathType Leaf) ('file exists: ' + $Path) | Out-Null; [IO.File]::ReadAllText($Path) }
function Assert-Parse([string]$Path) { $tokens=$null;$errors=$null;[Management.Automation.Language.Parser]::ParseFile($Path,[ref]$tokens,[ref]$errors)|Out-Null;Assert-True ($errors.Count -eq 0) ('PowerShell parse: '+$Path) }
function Get-Efforts($Model) { @($Model.supported_reasoning_levels|ForEach-Object { if($_ -is [string]){[string]$_}else{[string]$_.effort} }) }
$p=[ordered]@{
 agents=Join-Path $VaultRoot 'AGENTS.md'; context=Join-Path $VaultRoot 'CONTEXT_INDEX.md'; current=Join-Path $VaultRoot '.codex\CURRENT.md';
 policy=Join-Path $VaultRoot 'protocols\CODEX_TOKEN_OPTIMIZATION_AND_CONTEXT_EFFICIENCY_RULES.md'; policyJson=Join-Path $VaultRoot 'automation\codex-model-routing\token-optimization.policy.json'; fixtures=Join-Path $VaultRoot 'automation\codex-model-routing\token-optimization.behavior-fixtures.json';
 profile=Join-Path $VaultRoot 'automation\codex-model-routing\current-routing-profile.json'; gate=Join-Path $VaultRoot 'automation\codex-model-routing\manual-codex-execution-gate.json'; compiler=Join-Path $VaultRoot 'automation\codex-model-routing\route-compiler.ps1';
 a4=Join-Path $VaultRoot 'automation\codex-model-routing\test-a4-routing.ps1'; a6=Join-Path $VaultRoot 'automation\codex-model-routing\test-a6-manual-execution-gate.ps1'; a7=Join-Path $VaultRoot 'automation\codex-model-routing\test-a7-owner-started-sol-routing.ps1'; a8=Join-Path $VaultRoot 'automation\codex-model-routing\test-a8-sol-advisor-routing.ps1'; sol=Join-Path $VaultRoot 'automation\codex-model-routing\test-sol-advisor-global-routing.ps1'; maeos=Join-Path $VaultRoot 'automation\codex-model-routing\test-maeos-routing.ps1';
 readme=Join-Path $VaultRoot 'automation\codex-model-routing\README.md'; standard=Join-Path $VaultRoot 'automation\codex-model-routing\ROUTING_STANDARD.md'; extension=Join-Path $VaultRoot 'governance\agents\extensions\global-codex.PROJECT_POLICY.md'; contract=Join-Path $VaultRoot 'automation\codex-model-routing\contracts\maeos-role-contracts.json'
}
$content=@{};foreach($e in $p.GetEnumerator()){$content[$e.Key]=Read-Required $e.Value}
# Immutable A1-A8 material remains; MAEOS supersedes only active routing defaults.
foreach($name in @('TOKEN-OPT-001-A2.md','TOKEN-OPT-001-A3.md','TOKEN-OPT-001-A4.md','TOKEN-OPT-001-A5.md','TOKEN-OPT-001-A6.md','TOKEN-OPT-001-A7.md','TOKEN-OPT-001-A8.md')){Assert-True (Test-Path -LiteralPath (Join-Path $VaultRoot ('governance\agents\specs\'+$name))) ('historical specification preserved: '+$name)}
foreach($marker in @('GOVERNANCE_REVISION: MAEOS-v1','MAEOS-v1 routing contract','BILLABLE CODEX EXECUTION: LOCKED BY DEFAULT','SOL SUBAGENTS: PROHIBITED')){Assert-True (($content.agents+"`n"+$content.policy).Contains($marker)) ('active governance marker: '+$marker)}
Assert-True ($content.agents -match 'SOL-ADVISOR-GLOBAL-001.*historical|historical.*SOL-ADVISOR-GLOBAL-001') 'Sol contract explicitly historical for routing'
Assert-True ($content.context.Contains('MAEOS-v1')) 'context index points to MAEOS'
Assert-True ($content.current.Contains('CURRENT_STATUS:')) 'CURRENT has one active status'
Assert-True ([regex]::IsMatch($content.readme,'(?i)routing metadata never authorizes')) 'README denies implicit execution authority'
Assert-True ($content.extension.Contains('MAEOS-v1')) 'global extension inherits MAEOS'
foreach($stale in @('SOL-ADVISOR-GLOBAL-001 is the active','solo is the default','one auxiliary is normal','one auxiliary default maximum','at most one auxiliary','Apply the SOL-ADVISOR-GLOBAL-001 routing contract')){Assert-True (-not (($content.agents+"`n"+$content.policy+"`n"+$content.readme+"`n"+$content.extension).Contains($stale))) ('no executable stale SOL phrase: '+$stale)}
$routingText=$content.agents+"`n"+$content.policy+"`n"+$content.readme+"`n"+$content.extension
Assert-True (-not [regex]::IsMatch($routingText,'(?is)SOL-ADVISOR-GLOBAL-001[^.\r\n]{0,120}\b(is\s+the\s+active|sole\s+routing\s+default|solo\s+is\s+default|one\s+auxiliary\s+(?:is\s+)?(?:normal|default))')) 'SOL active/default language is historical only'
Assert-True (-not [regex]::IsMatch($routingText,'(?is)(?:fresh\s+session[^.\r\n]{0,160}SOL-ADVISOR-GLOBAL-001\s+was\s+loaded|SOL-ADVISOR-GLOBAL-001\s+was\s+loaded[^.\r\n]{0,160}fresh\s+session)')) 'fresh-session governance proof requires MAEOS, not historical SOL'
$maeosRouting=Read-Required (Join-Path $VaultRoot 'automation\codex-model-routing\MAEOS_ROUTING.md')
Assert-True (-not [regex]::IsMatch($maeosRouting,'(?is)ENGINEER.{0,120}(?:Luna\s*/\s*Max).{0,80}(?:bounded\s+work|implement|write)')) 'active MAEOS routing never assigns Luna engineering or writing'
Assert-True ($maeosRouting -match '(?is)Terra\s*/\s*High.{0,120}(?:native non-Ox|implementation, write, and integration)') 'active MAEOS routing assigns native non-Ox writing to Terra'
$routingStandard=Read-Required (Join-Path $VaultRoot 'automation\codex-model-routing\ROUTING_STANDARD.md')
Assert-True (-not [regex]::IsMatch($routingStandard,'(?is)SOL-ADVISOR-GLOBAL-001.{0,160}(?:defines|current|solo\s+is\s+the\s+default)|Luna.{0,100}(?:bounded\s+implementation|implementer)')) 'routing standard has no active SOL route or Luna implementation assignment'
Assert-True ($routingStandard -match '(?is)Terra.{0,140}(?:native non-Ox|implementation, writer, and integration)') 'routing standard assigns native non-Ox work to Terra'
Assert-True (-not [regex]::IsMatch($routingStandard,'(?is)(?:active\s+Sol.{0,180}one\s+(?:native\s+)?(?:implementer|reviewer)|MAXIMUM\s+AUXILIARIES\s+PER\s+DECLARED\s+ROUTE\s*:\s*1|CURRENT\s+MODES\s*:\s*solo)')) 'routing standard has no active historical one-auxiliary capacity'
Assert-True ($routingStandard -match '(?is)DEFAULT\s+CHILDREN\s*:\s*0.{0,240}NORMAL\s+READ-ONLY\s+LUNA\s+LEAVES\s*:\s*0\.\.4.{0,240}NORMAL\s+TOTAL\s+CHILDREN\s*:\s*5.{0,240}GRAPH-GATED\s+READ-ONLY\s+BURST\s+CEILING\s*:\s*16') 'routing standard states MAEOS normal and burst topology'
$readmeText=$content.readme
Assert-True (-not [regex]::IsMatch($readmeText,'(?is)active\s+`?SOL-ADVISOR-GLOBAL-001.{0,100}selection\s+profile|Luna\s*/\s*Max\s+and\s+Terra\s*/\s*High\s+are\s+bounded\s+native\s+lanes|Ineligibility\s+resolves.{0,100}Luna\s*/\s*Max\s+or\s+Terra')) 'README has no active SOL or Luna-writer ambiguity'
Assert-True ($readmeText -match '(?is)active\s+`?MAEOS-v1`?\s+selection\s+profile.{0,180}historical compatibility only') 'README identifies MAEOS profile and historical SOL metadata'
Assert-True ($readmeText -match '(?is)Luna\s*/\s*Max\s+only\s+for\s+read-only\s+work.{0,180}Terra\s*/\s*High\s+for\s+every\s+native non-Ox') 'README pre-dispatch selection never routes writers to Luna'
$projectTemplate=Read-Required (Join-Path $VaultRoot 'templates\PROJECT_POLICY_TEMPLATE.md');$maeosProtocol=Read-Required (Join-Path $VaultRoot 'protocols\MAEOS.md')
Assert-True (-not [regex]::IsMatch($projectTemplate,'(?is)Inherit\s+`?SOL-ADVISOR-GLOBAL-001|solo\s+default|Luna.{0,100}implementation\s+lanes|audit/full\s+reviewer')) 'registered project template has no active SOL or Luna-writer default'
Assert-True ($projectTemplate -match '(?is)Inherit\s+`?MAEOS-v1.{0,240}Luna.{0,80}read-only.{0,180}Terra.{0,140}(?:implementation, write, and integration|native non-Ox)') 'registered project template inherits MAEOS Luna/Terra roles'
Assert-True (-not [regex]::IsMatch($maeosProtocol,'(?is)Luna.{0,100}bounded\s+leaf|Terra.{0,100}only\s+for\s+integration-sensitive')) 'canonical MAEOS protocol has no Luna writer or Terra-only restriction'
Assert-True ($maeosProtocol -match '(?is)Luna.{0,80}read-only.{0,220}Terra.{0,160}(?:implementation, write, and integration|native non-Ox)') 'canonical MAEOS protocol assigns Luna/Terra active roles'
Assert-True (-not [regex]::IsMatch($content.policy,'(?is)(?:current|active)\s+`?solo\|delegate\|audit\|full|Luna\s*/\s*Max.{0,80}bounded\s+implementation|audit/full\s+review|reviewer.{0,100}only.{0,50}audit.{0,50}full')) 'token policy has no active historical SOL route or Luna-writer language'
Assert-True (-not [regex]::IsMatch(($content.agents+"`n"+$content.policy),'(?is)Terra\s*/\s*High.{0,160}integration-sensitive.{0,80}only')) 'active authority has no Terra integration-sensitive-only restriction'
Assert-True (-not [regex]::IsMatch($content.policy,'(?is)SOL-ADVISOR-GLOBAL-001\s+supersedes')) 'historical SOL does not supersede the active MAEOS contract'
Assert-True (-not [regex]::IsMatch($content.policy,'(?is)current\s+Sol\s+Advisor\s+route\s+contract')) 'token policy names MAEOS rather than a current Sol Advisor route contract'
Assert-True (($content.agents+"`n"+$content.policy) -match '(?m)^OWNER-STARTED SOL SESSION: MAEOS-v1 GOVERNS; SOL / HIGH IS ROOT$') 'owner-started session names MAEOS-v1 with Sol High root'
$specHashes=[ordered]@{ 'TOKEN-OPT-001-A2.md'='fda3b018dbdf7e3f597cfb07d797633cc8ebbb30cab23f94e1806f9d960918e2';'TOKEN-OPT-001-A3.md'='dc31c20cef4bc39f4165339e323ebee07c26a3499b8705f840648932f9eec8be';'TOKEN-OPT-001-A4.md'='d9c94e95430b8f4e510620d2262aa788acfc6160d5be0dcb3a98aa38ece27fa2';'TOKEN-OPT-001-A5.md'='26506857adafe95f523aa927a4562034d20a5b10a615053f30ff4012f3f96843';'TOKEN-OPT-001-A6.md'='7036975cc0ef3ec3580f060c49759e8d07871f927a06f9e91674fd5d9c95de47'}
foreach($name in $specHashes.Keys){$actual=(Get-FileHash -LiteralPath (Join-Path $VaultRoot ('governance\agents\specs\'+$name)) -Algorithm SHA256).Hash.ToLowerInvariant();Assert-True ($actual -eq $specHashes[$name]) ('preserved immutable hash: '+$name)}
$policy=$content.policyJson|ConvertFrom-Json;$profile=$content.profile|ConvertFrom-Json;$gate=$content.gate|ConvertFrom-Json;$fixtureData=$content.fixtures|ConvertFrom-Json;$contract=$content.contract|ConvertFrom-Json
Assert-True ([int]$policy.schema_version -eq 6) 'historical policy schema version 6'
foreach($amendment in @('TOKEN-OPT-001-A1','TOKEN-OPT-001-A2','TOKEN-OPT-001-A3','TOKEN-OPT-001-A4','TOKEN-OPT-001-A5','TOKEN-OPT-001-A6','TOKEN-OPT-001-A7','TOKEN-OPT-001-A8','SOL-ADVISOR-GLOBAL-001')){Assert-True (@($policy.accepted_amendments)-contains $amendment) ('accepted historical amendment: '+$amendment)}
Assert-True ([bool]$policy.defaults.agents_enabled -and [bool]$policy.defaults.multi_agent_v2_enabled) 'historical policy native-v2 flags'
Assert-True (([string]$policy.current_routing_v2.contract_id -eq 'SOL-ADVISOR-GLOBAL-001') -and [bool]$policy.current_routing_v2.solo_default -and [int]$policy.current_routing_v2.default_auxiliaries_max -eq 1) 'historical Sol routing retained as provenance'
$base=$fixtureData.fixture_suites.PSObject.Properties['TOKEN-OPT-001'].Value;$a1=$fixtureData.fixture_suites.PSObject.Properties['TOKEN-OPT-001-A1'].Value;$a4f=$fixtureData.fixture_suites.PSObject.Properties['TOKEN-OPT-001-A4'].Value;$all=@(@($base.fixtures)+@($a1.fixtures)+@($a4f.fixtures));Assert-True (@($all).Count -eq 58 -and @($all|ForEach-Object id|Sort-Object -Unique).Count -eq 58) '58 historical behavior fixtures preserved'
foreach($fixture in $all){$expected=$policy.behavior_contract.PSObject.Properties[$fixture.contract_key].Value;Assert-True ($null -ne $expected -and (($expected|ConvertTo-Json -Depth 20 -Compress) -eq ($fixture.expected|ConvertTo-Json -Depth 20 -Compress))) ('historical behavior fixture: '+$fixture.id)}
$routeFixture=(Read-Required (Join-Path $PSScriptRoot 'fixtures\a4-route-compiler-fixtures.json'))|ConvertFrom-Json;Assert-True (@($routeFixture.scenarios).Count -eq 27) '27 historical A4 route fixtures preserved'
Assert-True ([int]$profile.schema_version -eq 6 -and [string]$profile.governance_revision -eq 'MAEOS-v1' -and [string]$profile.role_catalog_status -like 'ACTIVE_MAEOS_V1*') 'MAEOS profile active identity'
Assert-True ([int]$profile.concurrency.default_auxiliaries_max -eq 0 -and [int]$profile.concurrency.adaptive_read_only_workers_max -eq 4 -and [int]$profile.concurrency.independent_burst_total_workers_max -eq 16) 'MAEOS profile zero default normal four burst sixteen'
Assert-True ([int]$profile.concurrency.max_active_writers_account_wide -eq 2 -and [int]$profile.concurrency.max_writers_per_repository_or_worktree -eq 1) 'MAEOS writer caps'
Assert-True ([string]$profile.maeos_roles.status -eq 'ACTIVE_MAEOS_V1' -and [string]$profile.maeos_roles.read_only_leaf.model -eq 'gpt-5.6-luna' -and [bool]$profile.maeos_roles.read_only_leaf.read_only -and [string]$profile.maeos_roles.writer.model -eq 'gpt-5.6-terra' -and [string]$profile.maeos_roles.writer.reasoning_effort -eq 'high' -and -not [bool]$profile.maeos_roles.writer.read_only) 'MAEOS active Luna-read-only and Terra-writer roles'
Assert-True ([string]$profile.sol_advisor.status -eq 'HISTORICAL_COMPATIBILITY_ONLY' -and [string]$profile.role_catalog_status -eq 'ACTIVE_MAEOS_V1') 'SOL profile metadata historical only'
Assert-True ([string]$gate.policy_id -eq 'MAEOS-v1' -and [int]$gate.default_children -eq 0 -and [int]$gate.normal_read_only_workers_max -eq 4 -and [int]$gate.native_burst_ceiling -eq 16) 'MAEOS gate topology'
Assert-True ([string]$gate.default_state -eq 'LOCKED' -and [bool]$gate.manual_only -and -not [bool]$gate.automatic_fallback -and -not [bool]$gate.recursive_spawning) 'manual gate safety unchanged'
foreach($role in @('ROOT_ORCHESTRATOR','FAST_LEAF','READER','DOCS_RESEARCH','PLANNER','ENGINEER','WRITER','TESTER','REVIEWER','BRANCH_COORDINATOR')){Assert-True ($contract.semantic_roles.PSObject.Properties.Name -contains $role) ('MAEOS semantic role: '+$role)}
foreach($marker in @('MAEOS_FINITE_TASK_GRAPH_REQUIRED','MAEOS_BURST_READ_ONLY_ONLY','MAEOS_PERMIT_LEGACY_COMPAT_INVALID','Assert-SolAdvisorRouteTopology')){Assert-True ($content.compiler.Contains($marker)) ('compiler invariant marker: '+$marker)}
$guard=Join-Path $VaultRoot 'automation\codex-usage-guard';foreach($name in @('CodexUsageGuard.ps1','Enable-CodexUsage.ps1','Disable-CodexUsage.ps1','Get-CodexUsageStatus.ps1','Install-CodexUsageGuard.ps1','Test-CodexUsageGuard.ps1')){Assert-Parse (Join-Path $guard $name)}
foreach($script in @($p.compiler,$p.a4,$p.a6,$p.a7,$p.a8,$p.sol,$p.maeos)){Assert-Parse $script}
foreach($suite in @(@{path=$p.a4;summary='SUMMARY PASS a4_historical_fixtures='},@{path=$p.a6;summary='real_codex_calls=0'},@{path=$p.a7;summary='SUMMARY PASS a7_owner_started_sol_routing='},@{path=$p.a8;summary='SUMMARY PASS a8_sol_advisor_routing='},@{path=$p.sol;summary='SUMMARY PASS sol_advisor_global_routing='},@{path=$p.maeos;summary='SUMMARY PASS maeos_routing=functional real_codex_calls=0'})){$out=@(& $suite.path -VaultRoot $VaultRoot);Assert-True (($out-join "`n").Contains($suite.summary)) ('regression suite: '+[IO.Path]::GetFileName($suite.path))}
if(-not $SkipCatalog){$catalog=(Read-Required $CatalogPath)|ConvertFrom-Json;foreach($required in @(@{id='gpt-5.6-sol';effort='high'},@{id='gpt-5.6-terra';effort='high'},@{id='gpt-5.6-luna';effort='max'})){$m=@($catalog.models|Where-Object{[string]$_.slug -eq $required.id}|Select-Object -First 1);Assert-True ($null -ne $m -and (Get-Efforts $m)-contains $required.effort) ('catalog model: '+$required.id)}}
if(-not $SkipPersonal){$config=Read-Required (Join-Path $CodexHome 'config.toml');Assert-True ([regex]::IsMatch($config,'(?ms)^\[agents\]\s*\r?\nenabled\s*=\s*true\s*\r?\nmax_concurrent_threads_per_session\s*=\s*16\s*$')) 'personal agents enabled native cap sixteen';Assert-True (-not $config.Contains('TOKEN-OPT-001-A7:')) 'personal stale A7 hint removed'}
if(-not [string]::IsNullOrWhiteSpace($BackupManifest)){$backup=(Read-Required $BackupManifest)|ConvertFrom-Json;Assert-True ($null -ne $backup) 'supplied backup manifest parses'}
$redacted=@($p.agents,$p.policy,$p.profile,$p.gate,$p.compiler,$p.maeos|ForEach-Object{[IO.File]::ReadAllText($_)})-join "`n";Assert-True (-not [regex]::IsMatch($redacted,'(?i)(?:(?:^|[^A-Za-z0-9])sk-[A-Za-z0-9_-]{12,}|api[_-]?key\s*[=:]\s*["''][^"'']{12,}|password\s*[=:]\s*["''][^"'']{8,})')) 'routing and MAEOS redaction scan'
Write-Output ('SUMMARY PASS policy=historical-A1-A8-and-SOL MAEOS=active normal_readers=0..4 native_burst=16 depth=1 writer_caps=2/1 behavior_fixtures=58 personal='+$(if($SkipPersonal){'SKIPPED'}else{'PASS'})+' catalog='+$(if($SkipCatalog){'SKIPPED'}else{'PASS'})+' real_codex_calls=0')
