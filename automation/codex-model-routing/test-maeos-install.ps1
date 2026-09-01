[CmdletBinding()]
param([string]$VaultRoot = '',[switch]$AccountInstall)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($VaultRoot)) { $VaultRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..')) }
function Assert-Case([bool]$Value,[string]$Name){if(-not $Value){throw "TEST_FAILURE: $Name"};Write-Output "PASS $Name"}
$installer=Join-Path $PSScriptRoot 'install-maeos.ps1';$root=Join-Path ([IO.Path]::GetTempPath()) ('maeos-install-'+[Guid]::NewGuid().ToString('N'))
if($AccountInstall){
  $plan=(@(& $installer -Mode Plan -VaultRoot $VaultRoot)-join "`n")|ConvertFrom-Json;Assert-Case ([string]$plan.mode -eq 'Plan') 'account install plan'
  $expectedFirstApply=if(@($plan.managed_changes).Count -gt 0 -or [bool]$plan.manifest_update){'APPLIED'}else{'NOOP'}
  $apply=(@(& $installer -Mode Apply -VaultRoot $VaultRoot)-join "`n")|ConvertFrom-Json;Assert-Case ([string]$apply.status -eq $expectedFirstApply) ('account install first apply derived '+$expectedFirstApply)
  $noop=(@(& $installer -Mode Apply -VaultRoot $VaultRoot)-join "`n")|ConvertFrom-Json;Assert-Case ([string]$noop.status -eq 'NOOP') 'account install idempotent noop'
  Write-Output ('SUMMARY PASS maeos_account_install_plan_first_'+$expectedFirstApply+'_second_NOOP=1 real_codex_calls=0');return
}
try{
  $codex=Join-Path $root 'codex';$skills=Join-Path $root 'skills';$backup=Join-Path $root 'backup';$lean=Join-Path $root 'lean-config.toml';New-Item -ItemType Directory -Force -Path (Join-Path $codex 'agents')|Out-Null;New-Item -ItemType Directory -Force -Path (Join-Path $codex '.agents')|Out-Null
  [IO.File]::WriteAllText((Join-Path $codex 'agents\sol-advisor.toml'),'depth-one A7 routing and final acceptance`n# at most 16 direct children`nUse Terra Max only after an explicit Sol fallback/integration decision`n',[Text.UTF8Encoding]::new($false))
  [IO.File]::WriteAllText((Join-Path $codex 'config.toml'),'TOKEN-OPT-001-A7: owner-started Sol only; default children 0, maximum direct children 16, depth 1, no recursive spawning, no background continuation, no automatic fallback.',[Text.UTF8Encoding]::new($false))
  [IO.File]::WriteAllText($lean,'shell_security = "strict"',[Text.UTF8Encoding]::new($false));[IO.File]::WriteAllText((Join-Path $codex 'hooks.json'),'{"hooks":{"SessionStart":[{"type":"command","command":"lean-ctx.exe hook codex-session-start"},{"type":"command","command":"lean-ctx.exe hook observe"}]}}',[Text.UTF8Encoding]::new($false));Copy-Item -LiteralPath (Join-Path $VaultRoot 'AGENTS.md') -Destination (Join-Path $codex 'AGENTS.md');Copy-Item -LiteralPath (Join-Path $VaultRoot 'governance\agents\extensions\global-codex.PROJECT_POLICY.md') -Destination (Join-Path $codex '.agents\PROJECT_POLICY.md')
  $plan=(@(& $installer -Mode Plan -VaultRoot $VaultRoot -CodexHome $codex -SkillsHome $skills -LeanConfigPath $lean -BackupPath $backup)-join "`n")|ConvertFrom-Json;Assert-Case ([string]$plan.mode -eq 'Plan') 'isolated install plan'
  $apply=(@(& $installer -Mode Apply -VaultRoot $VaultRoot -CodexHome $codex -SkillsHome $skills -LeanConfigPath $lean -BackupPath $backup)-join "`n")|ConvertFrom-Json;Assert-Case ([string]$apply.status -eq 'APPLIED') 'isolated install apply'
  $manifest=([IO.File]::ReadAllText((Join-Path $codex 'maeos\INSTALL_MANIFEST.json'))|ConvertFrom-Json);Assert-Case ([int]$manifest.schema_version -eq 3 -and [string]$manifest.later_edits -eq 'FAIL_CLOSED_ON_HASH_DRIFT') 'isolated manifest rollback contract'
  foreach($name in @('active-work-record.md','task-graph.md','worktree-manifest.md')){Assert-Case (Test-Path -LiteralPath (Join-Path $codex ('references\maeos\'+$name))) ('isolated reference installed: '+$name)}
  Assert-Case ((@($manifest.files|Where-Object{[string]$_.kind -eq 'skill'}).Count -eq 6) -and (@($manifest.files|Where-Object{[string]$_.kind -eq 'reference'}).Count -eq 3)) 'isolated manifest includes all curated assets'
  $audit=Join-Path $PSScriptRoot 'audit-maeos-project.ps1';$legacy=Join-Path $root 'legacy-audit';$modern=Join-Path $root 'modern-audit';New-Item -ItemType Directory -Force -Path (Join-Path $legacy '.agents'),(Join-Path $modern '.agents')|Out-Null;[IO.File]::WriteAllText((Join-Path $legacy '.agents\PROJECT_POLICY.md'),'SOL-ADVISOR-GLOBAL-001: Luna / Max implementation; solo|delegate|audit|full',[Text.UTF8Encoding]::new($false));[IO.File]::WriteAllText((Join-Path $modern '.agents\PROJECT_POLICY.md'),'MAEOS-v1: Luna read-only; Terra native writer',[Text.UTF8Encoding]::new($false));$legacyAudit=(@(& $audit -ProjectRoot $legacy)-join "`n")|ConvertFrom-Json;$modernAudit=(@(& $audit -ProjectRoot $modern)-join "`n")|ConvertFrom-Json;Assert-Case ([string]$legacyAudit.classification -eq 'PRE_MAEOS_OVERRIDE_REQUIRES_BOUNDED_ADOPTION' -and [string]$legacyAudit.result -eq 'READ_ONLY_NO_PROJECT_MUTATION') 'legacy project override audit is read-only bounded adoption';Assert-Case ([string]$modernAudit.classification -eq 'ACTIVE_OR_REVIVED_REQUIRES_BOUNDED_ADOPTION_AUDIT' -and [string]$modernAudit.result -eq 'READ_ONLY_NO_PROJECT_MUTATION') 'MAEOS project policy audit is read-only'
  $noop=(@(& $installer -Mode Apply -VaultRoot $VaultRoot -CodexHome $codex -SkillsHome $skills -LeanConfigPath $lean -BackupPath $backup)-join "`n")|ConvertFrom-Json;Assert-Case ([string]$noop.status -eq 'NOOP') 'isolated install idempotent noop'
  foreach($entry in @($manifest.files)){
    $original=[IO.File]::ReadAllText([string]$entry.destination);[IO.File]::WriteAllText([string]$entry.destination,($original+"`n# unexpected local drift"),[Text.UTF8Encoding]::new($false));$refused=$false
    try{& $installer -Mode Plan -VaultRoot $VaultRoot -CodexHome $codex -SkillsHome $skills -LeanConfigPath $lean -BackupPath $backup|Out-Null}catch{$refused=$_.Exception.Message -match 'INSTALL_REFUSES_(LOCAL_|PROFILE_|CONFIG_|HOOKS_)DRIFT'}
    [IO.File]::WriteAllText([string]$entry.destination,$original,[Text.UTF8Encoding]::new($false));Assert-Case $refused ('isolated fail-closed drift: '+[string]$entry.kind)
  }
  Write-Output 'SUMMARY PASS maeos_install_plan_apply_noop=1 references=3 skills=6 real_codex_calls=0'
}finally{Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue}
