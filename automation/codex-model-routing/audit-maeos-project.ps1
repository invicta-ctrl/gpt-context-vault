[CmdletBinding()]
param([Parameter(Mandatory)][string]$ProjectRoot)
Set-StrictMode -Version Latest; $ErrorActionPreference = 'Stop'
$policy = Join-Path $ProjectRoot '.agents\PROJECT_POLICY.md'
$present=Test-Path -LiteralPath $policy;$text=if($present){[IO.File]::ReadAllText($policy)}else{''}
$classification=if(-not $present){'NEW_OR_UNMANAGED'}elseif($text -match 'SOL-ADVISOR-GLOBAL-001|solo\|delegate\|audit\|full|Luna\s*/\s*Max.{0,80}implement'){'PRE_MAEOS_OVERRIDE_REQUIRES_BOUNDED_ADOPTION'}else{'ACTIVE_OR_REVIVED_REQUIRES_BOUNDED_ADOPTION_AUDIT'}
[ordered]@{ project_root=[IO.Path]::GetFullPath($ProjectRoot); classification=$classification; policy_present=$present; result='READ_ONLY_NO_PROJECT_MUTATION' } | ConvertTo-Json
