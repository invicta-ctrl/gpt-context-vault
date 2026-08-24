[CmdletBinding()]
param([string]$VaultRoot = '')

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($VaultRoot)) { $VaultRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..')) }

function Assert-Test([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw "TEST_FAILURE: $Message" }
    Write-Output "PASS $Message"
}
function Write-TestJson([string]$Path, $Value) {
    [IO.File]::WriteAllText($Path, (($Value | ConvertTo-Json -Depth 30) + "`n"), [Text.UTF8Encoding]::new($false))
}
function Set-ObjectProperty($Object, [string]$Name, $Value) {
    if ($Object.PSObject.Properties.Name -contains $Name) { $Object.$Name = $Value }
    else { $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Value }
}
function New-Request([string]$Role = 'orchestrator') {
    [pscustomobject]@{
        role = $Role; run_id = 'a6-manual-gate'; task_id = [Guid]::NewGuid().ToString('N');
        dispatch_seed_tokens = 0; worker_working_tokens = 0; context_tokens = 0;
        active_writers = 0; active_read_only_workers = 0; active_total_workers = 0;
        recursion_depth = 0; spawned_by_worker = $false;
        execution_origin = 'manual_user'; manual_interactive = $true;
        approval_id = [Guid]::NewGuid().ToString('D'); purpose = 'A6 deterministic route test';
        subagent_requested = $false; background_continuation = $false; automatic_fallback = $false
    }
}
function Write-Permit {
    param([string]$Path, $Request, [string]$Model = 'gpt-5.6-sol', [string]$Effort = 'high', [string[]]$Roles = @('orchestrator'), [string]$State = 'ACTIVE', [bool]$Consumed = $false, [int]$ExpiryMinutes = 10, [string]$ApprovalId = '')
    if ([string]::IsNullOrWhiteSpace($ApprovalId)) { $ApprovalId = [string]$Request.approval_id }
    Write-TestJson -Path $Path -Value ([ordered]@{
        schema_version = 1; approval_id = $ApprovalId; state = $State; issued_by = 'A6 deterministic test';
        issued_at = ([DateTimeOffset]::UtcNow.AddMinutes(-1).ToString('o')); expires_at = ([DateTimeOffset]::UtcNow.AddMinutes($ExpiryMinutes).ToString('o'));
        purpose = 'A6 deterministic route test'; origin = 'manual_user'; manual_interactive = $true;
        allowed_model = $Model; allowed_reasoning = $Effort; allowed_role = if ($Roles.Count -eq 1) { $Roles[0] } else { '' }; allowed_roles = $Roles;
        allow_subagents = $false; max_processes = 1; max_children = 0; background_continuation = $false; automatic_fallback = $false;
        consumed = $Consumed; process_id = $null
    })
}
function Invoke-Compiler {
    param([string]$Compiler, [string]$Profile, [string]$Catalog, [string]$Gate, [string]$Permit, [string]$Request)
    @(& $Compiler -ProfilePath $Profile -CatalogPath $Catalog -ExecutionGatePath $Gate -ManualPermitPath $Permit -RequestPath $Request) -join "`n"
}
function Expect-Error {
    param([string]$Name, [string]$Code, [scriptblock]$Action)
    try { $null = & $Action; throw "Expected $Code" }
    catch { Assert-Test ($_.Exception.Message -like ('*' + $Code + '*')) ($Name + ' -> ' + $Code) }
}

$compiler = Join-Path $PSScriptRoot 'route-compiler.ps1'
$profile = Join-Path $PSScriptRoot 'current-routing-profile.json'
$fixturePath = Join-Path $PSScriptRoot 'fixtures\a4-route-compiler-fixtures.json'
$fixture = Get-Content -LiteralPath $fixturePath -Raw | ConvertFrom-Json
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ('token-opt-a6-gate-' + [Guid]::NewGuid().ToString('N'))

try {
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    $catalog = Join-Path $tempRoot 'catalog.json'
    $gate = Join-Path $tempRoot 'gate.json'
    $permit = Join-Path $tempRoot 'permit.json'
    $requestPath = Join-Path $tempRoot 'request.json'
    Write-TestJson -Path $catalog -Value $fixture.catalog
    Write-TestJson -Path $gate -Value ([ordered]@{
        schema_version = 1; policy_id = 'TOKEN-OPT-001-A6'; default_state = 'LOCKED'; manual_only = $true;
        permit_path = $permit; require_exact_purpose = $true; max_processes = 1; max_children = 0; allow_subagents = $false; background_continuation = $false;
        automatic_fallback = $false; route_compiler_is_dispatcher = $false
    })

    $green = New-Request -Role 'writer'
    Set-ObjectProperty $green 'acceptance_green' $true
    Write-TestJson $requestPath $green
    $greenResult = (Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath) | ConvertFrom-Json
    Assert-Test ([string]$greenResult.action -eq 'STOP') 'green no-execution check works while locked'
    Assert-Test ([string]$greenResult.execution_boundary.state -eq 'LOCKED_NO_EXECUTION') 'green result records locked boundary'

    $missing = New-Request
    Write-TestJson $requestPath $missing
    Remove-Item -LiteralPath $permit -Force -ErrorAction SilentlyContinue
    Expect-Error 'missing permit' 'CODEX_USAGE_LOCKED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    foreach ($origin in @('ChatGPT_Web','Astral_Bridge','automation','scheduled_task','background_agent')) {
        $request = New-Request
        $request.execution_origin = $origin
        Write-Permit $permit $request
        Write-TestJson $requestPath $request
        Expect-Error ("origin $origin") 'MANUAL_USER_ORIGIN_REQUIRED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }
    }

    foreach ($flag in @('prior_owner_approval','prior_accepted_specification','autonomous_completion','absolutely_necessary')) {
        $request = New-Request
        Set-ObjectProperty $request $flag $true
        Write-Permit $permit $request
        Write-TestJson $requestPath $request
        Expect-Error $flag 'MANUAL_CODEX_EXECUTION_REQUIRED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }
    }

    $request = New-Request
    Write-Permit $permit $request -ExpiryMinutes -1
    Write-TestJson $requestPath $request
    Expect-Error 'expired permit' 'MANUAL_PERMIT_EXPIRED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request
    Write-Permit $permit $request -ApprovalId ([Guid]::NewGuid().ToString('D'))
    Write-TestJson $requestPath $request
    Expect-Error 'approval mismatch' 'MANUAL_PERMIT_APPROVAL_MISMATCH' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request
    Write-Permit $permit $request -Consumed $true
    Write-TestJson $requestPath $request
    Expect-Error 'consumed permit' 'MANUAL_PERMIT_ALREADY_CONSUMED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request
    Write-Permit $permit $request -State 'REVOKED'
    Write-TestJson $requestPath $request
    Expect-Error 'revoked permit' 'CODEX_USAGE_LOCKED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request
    Write-Permit $permit $request
    $request.purpose = 'different purpose'
    Write-TestJson $requestPath $request
    Expect-Error 'purpose mismatch' 'MANUAL_PERMIT_PURPOSE_MISMATCH' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request
    Write-Permit $permit $request -Roles @('writer')
    Write-TestJson $requestPath $request
    Expect-Error 'role mismatch' 'MANUAL_PERMIT_ROLE_MISMATCH' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request
    $request.subagent_requested = $true
    Write-Permit $permit $request
    Write-TestJson $requestPath $request
    Expect-Error 'subagent requested' 'SUBAGENTS_DISABLED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request
    Write-Permit $permit $request
    $permitObject = Get-Content -LiteralPath $permit -Raw | ConvertFrom-Json
    $permitObject.allow_subagents = $true
    Write-TestJson $permit $permitObject
    Write-TestJson $requestPath $request
    Expect-Error 'permit allows subagent' 'SUBAGENTS_DISABLED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request
    Write-Permit $permit $request -Model 'gpt-5.6-terra'
    Write-TestJson $requestPath $request
    Expect-Error 'model mismatch' 'MANUAL_PERMIT_MODEL_MISMATCH' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request
    Write-Permit $permit $request -Effort 'max'
    Write-TestJson $requestPath $request
    Expect-Error 'reasoning mismatch' 'MANUAL_PERMIT_REASONING_MISMATCH' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request
    $request.background_continuation = $true
    Write-Permit $permit $request
    Write-TestJson $requestPath $request
    Expect-Error 'background continuation' 'BACKGROUND_CONTINUATION_DISABLED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request
    $request.automatic_fallback = $true
    Write-Permit $permit $request
    Write-TestJson $requestPath $request
    Expect-Error 'automatic fallback flag' 'AUTOMATIC_FALLBACK_DISABLED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request
    $request.active_total_workers = 1
    Write-Permit $permit $request
    Write-TestJson $requestPath $request
    Expect-Error 'second process' 'SECOND_PROCESS_DISABLED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request -Role 'read_only_worker'
    Set-ObjectProperty $request 'prefer_ephemeral' $true
    Set-ObjectProperty $request 'data_classification' 'internal'
    Set-ObjectProperty $request 'provider_observation' ([pscustomobject]@{ provider_available = $false; prompt_price = 0; completion_price = 0; health = 'healthy' })
    Write-Permit $permit $request -Model 'gpt-5.6-luna' -Effort 'max' -Roles @('read_only_worker')
    Write-TestJson $requestPath $request
    Expect-Error 'fallback requires a new permit' 'AUTOMATIC_FALLBACK_DISABLED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request
    Write-Permit $permit $request
    Write-TestJson $requestPath $request
    $validText = Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath
    $valid = $validText | ConvertFrom-Json
    Assert-Test ([string]$valid.action -eq 'ROUTE') 'valid exact manual permit routes'
    Assert-Test ([string]$valid.selected_model -eq 'gpt-5.6-sol' -and [string]$valid.reasoning_effort -eq 'high') 'valid route identity is exact'
    Assert-Test ([string]$valid.execution_boundary.state -eq 'MANUAL_PERMIT_VALIDATED') 'valid route records A6 boundary'
    Assert-Test (-not [bool]$valid.execution_boundary.dispatcher) 'route compiler remains non-dispatching'
    Assert-Test (-not $validText.Contains('codex exec') -and -not $validText.Contains('Start-Process')) 'route output contains no dispatch command'

    Write-Output 'SUMMARY PASS a6_manual_gate=28 real_codex_calls=0'
}
finally {
    if (Test-Path -LiteralPath $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force }
}
