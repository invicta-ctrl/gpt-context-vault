[CmdletBinding()]
param([string]$VaultRoot = '')
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
if([string]::IsNullOrWhiteSpace($VaultRoot)){$VaultRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))}
function Assert-Case([bool]$Value,[string]$Name){if(-not $Value){throw "TEST_FAILURE: $Name"};Write-Output "PASS $Name"}
$root=Join-Path ([IO.Path]::GetTempPath()) ('maeos-audit-'+[Guid]::NewGuid().ToString('N'))
try{
  $audit=Join-Path $PSScriptRoot 'audit-maeos-project.ps1';$legacy=Join-Path $root 'legacy';$modern=Join-Path $root 'modern';New-Item -ItemType Directory -Force -Path (Join-Path $legacy '.agents'),(Join-Path $modern '.agents')|Out-Null
  [IO.File]::WriteAllText((Join-Path $legacy '.agents\PROJECT_POLICY.md'),'SOL-ADVISOR-GLOBAL-001: Luna / Max implementation; solo|delegate|audit|full',[Text.UTF8Encoding]::new($false));[IO.File]::WriteAllText((Join-Path $modern '.agents\PROJECT_POLICY.md'),'MAEOS-v1: Luna read-only; Terra native writer',[Text.UTF8Encoding]::new($false))
  $legacyResult=(@(& $audit -ProjectRoot $legacy)-join "`n")|ConvertFrom-Json;$modernResult=(@(& $audit -ProjectRoot $modern)-join "`n")|ConvertFrom-Json
  Assert-Case ([string]$legacyResult.classification -eq 'PRE_MAEOS_OVERRIDE_REQUIRES_BOUNDED_ADOPTION' -and [string]$legacyResult.result -eq 'READ_ONLY_NO_PROJECT_MUTATION') 'legacy override requires bounded adoption without mutation'
  Assert-Case ([string]$modernResult.classification -eq 'ACTIVE_OR_REVIVED_REQUIRES_BOUNDED_ADOPTION_AUDIT' -and [string]$modernResult.result -eq 'READ_ONLY_NO_PROJECT_MUTATION') 'MAEOS-compatible policy remains read-only audit'
  Write-Output 'SUMMARY PASS maeos_project_audit_fixture=1 real_codex_calls=0'
}finally{Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue}
