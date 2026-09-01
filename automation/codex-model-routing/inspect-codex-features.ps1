[CmdletBinding()]
param()
Set-StrictMode -Version Latest; $ErrorActionPreference = 'Stop'
$command = Get-Command codex -ErrorAction SilentlyContinue
if ($null -eq $command) { [ordered]@{ status='UNRUN'; reason='installed Codex executable unavailable'; runtime_model_proof='UNAVAILABLE' } | ConvertTo-Json; exit 0 }
try {
  $output = @(& $command.Source features list 2>&1) -join "`n"
  [ordered]@{ status='OBSERVED'; executable=$command.Name; feature_mentions=@($output -split "`n" | Where-Object { $_ -match '(?i)multi.agent|agent' } | Select-Object -First 20); runtime_model_proof='UNAVAILABLE_FROM_FEATURE_LIST' } | ConvertTo-Json -Depth 4
} catch { [ordered]@{ status='UNRUN'; reason='feature command failed'; runtime_model_proof='UNAVAILABLE' } | ConvertTo-Json }
