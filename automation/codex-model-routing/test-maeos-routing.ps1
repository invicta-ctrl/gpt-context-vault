[CmdletBinding()]
param([string]$VaultRoot = '')
Set-StrictMode -Version Latest; $ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($VaultRoot)) { $VaultRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..')) }
function Assert-Case([bool]$Value, [string]$Name) { if (-not $Value) { throw "TEST_FAILURE: $Name" }; Write-Output "PASS $Name" }
function Write-Json([string]$Path,$Value) { [IO.File]::WriteAllText($Path,(($Value|ConvertTo-Json -Depth 30)+"`n"),[Text.UTF8Encoding]::new($false)) }
function New-Request([int]$Readers=0,[string]$Role='orchestrator') { [ordered]@{ role=$Role; route_mode=if($Role -eq 'orchestrator'){'solo'}else{'delegate'}; implementation_shape='bounded'; run_id='maeos-test'; task_id=[Guid]::NewGuid().ToString('N'); dispatch_seed_tokens=0;worker_working_tokens=0;context_tokens=0;active_writers=0;active_writers_target=0;active_read_only_workers=0;active_total_workers=0;recursion_depth=0;delegation_depth=0;spawned_by_worker=$false;execution_origin='manual_user';manual_interactive=$true;owner_started_sol_session=$true;approval_id=[Guid]::NewGuid().ToString('D');purpose='MAEOS deterministic compiler test';requested_luna_max_subagents=$Readers;requested_terra_max_subagents=0;requested_ox_alpha_subagents=0;requested_sol_subagents=0;requested_sol_reviewer_auxiliaries=0;subagent_requested=($Readers -gt 0);background_continuation=$false;automatic_fallback=$false } }
$compiler=Join-Path $PSScriptRoot 'route-compiler.ps1';$issuer=Join-Path $VaultRoot 'automation\codex-usage-guard\Enable-CodexUsage.ps1';$profile=Get-Content -Raw (Join-Path $PSScriptRoot 'current-routing-profile.json')|ConvertFrom-Json;$gate=Get-Content -Raw (Join-Path $PSScriptRoot 'manual-codex-execution-gate.json')|ConvertFrom-Json
$root=Join-Path ([IO.Path]::GetTempPath()) ('maeos-routing-'+[Guid]::NewGuid().ToString('N'));New-Item -ItemType Directory -Force -Path $root|Out-Null
try {
  $profilePath=Join-Path $root 'profile.json';$gatePath=Join-Path $root 'gate.json';$catalogPath=Join-Path $root 'catalog.json';$permitPath=Join-Path $root 'permit.json';$requestPath=Join-Path $root 'request.json'
  $gate.permit_path=$permitPath; Write-Json $profilePath $profile; Write-Json $gatePath $gate; Assert-Case ([string]$gate.policy_id -eq 'MAEOS-v1') 'fixture gate policy MAEOS'
  $models=@();foreach($m in @($profile.catalog.required_models)+@($profile.catalog.optional_overlay_models)){$models += [ordered]@{slug=$m.id;supported_reasoning_levels=@($m.effort)}};Write-Json $catalogPath ([ordered]@{models=$models})
  function Invoke-Route($request,[string]$permitRole='orchestrator',[string]$model='gpt-5.6-sol',[string]$effort='high') { $issuerRole=if($permitRole -eq 'read_only_worker'){'writer'}else{$permitRole};$permit=(@(& $issuer -ContractProbe -DurationMinutes 10 -Model $model -Reasoning $effort -Role $issuerRole -ProbeApprovalId $request.approval_id -ProbePurpose $request.purpose)-join "`n")|ConvertFrom-Json;if($permitRole -eq 'read_only_worker'){$permit.allowed_roles=@('read_only_worker');$permit.allowed_role='read_only_worker'};Write-Json $permitPath $permit;Write-Json $requestPath $request;@(& $compiler -ProfilePath $profilePath -CatalogPath $catalogPath -ExecutionGatePath $gatePath -ManualPermitPath $permitPath -RequestPath $requestPath)-join "`n" }
  $zero=New-Request; $raw=Invoke-Route $zero; Assert-Case (($raw|ConvertFrom-Json).selected_model -eq 'gpt-5.6-sol') 'zero-child route'
  foreach($count in 1..4){$r=New-Request $count 'read_only_worker';$out=Invoke-Route $r 'read_only_worker' 'gpt-5.6-luna' 'max';Assert-Case (($out|ConvertFrom-Json).selected_model -eq 'gpt-5.6-luna') "reader-count-$count permitted"}
  $writer=New-Request 1 'writer';$out=Invoke-Route $writer 'writer' 'gpt-5.6-terra' 'high';Assert-Case (($out|ConvertFrom-Json).selected_model -eq 'gpt-5.6-terra') 'single-writer Terra route'
  $burst=New-Request 6 'read_only_worker';$burst.finite_task_graph=$true;$burst.task_graph_node_id='R-06';$out=Invoke-Route $burst 'read_only_worker' 'gpt-5.6-luna' 'max';Assert-Case (($out|ConvertFrom-Json).selected_model -eq 'gpt-5.6-luna') 'graph-gated six-reader burst'
  foreach($case in @(
    @{name='over16';role='read_only_worker';permitRole='read_only_worker';mutator={param($r)$r.requested_luna_max_subagents=17}},
    @{name='missingGraph';role='read_only_worker';permitRole='read_only_worker';mutator={param($r)$r.requested_luna_max_subagents=6}},
    @{name='missingGraphNode';role='read_only_worker';permitRole='read_only_worker';mutator={param($r)$r.requested_luna_max_subagents=6;$r.finite_task_graph=$true}},
    @{name='mixedRoleBurst';role='read_only_worker';permitRole='read_only_worker';mutator={param($r)$r.requested_luna_max_subagents=5;$r.requested_terra_max_subagents=1;$r.finite_task_graph=$true;$r.task_graph_node_id='R-MIXED'}},
    @{name='depth';role='writer';permitRole='writer';mutator={param($r)$r.delegation_depth=2}},
    @{name='childOrigin';role='writer';permitRole='writer';mutator={param($r)$r.spawned_by_worker=$true}},
    @{name='fallback';role='writer';permitRole='writer';mutator={param($r)$r.automatic_fallback=$true}},
    @{name='targetWriter';role='writer';permitRole='writer';mutator={param($r)$r.active_writers_target=1}},
    @{name='accountWriter';role='writer';permitRole='writer';mutator={param($r)$r.active_writers=2}},
    @{name='reviewerMisuse';role='reviewer';permitRole='reviewer';mutator={param($r)$r.route_mode='delegate'}},
    @{name='unsupportedRole';role='unsupported';permitRole='writer';mutator={param($r)$null}},
    @{name='unsupportedReaderModel';role='read_only_worker';permitRole='read_only_worker';model='gpt-5.6-terra';effort='high';mutator={param($r)$null}}
  )){$r=New-Request 1 $case.role;& $case.mutator $r;$failed=$false;try{$model=if($case.ContainsKey('model')){$case.model}else{'gpt-5.6-luna'};$effort=if($case.ContainsKey('effort')){$case.effort}else{'max'};Invoke-Route $r $case.permitRole $model $effort|Out-Null}catch{$failed=$true};Assert-Case $failed ("reject-"+$case.name)}
  Write-Output 'SUMMARY PASS maeos_routing=functional real_codex_calls=0'
} finally { Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue }
