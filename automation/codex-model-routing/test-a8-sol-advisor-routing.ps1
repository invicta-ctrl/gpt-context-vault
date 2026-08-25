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
        role = $Role; run_id = 'a8-owner-sol'; task_id = [Guid]::NewGuid().ToString('N');
        dispatch_seed_tokens = 0; worker_working_tokens = 0; context_tokens = 0;
        active_writers = 0; active_writers_target = 0; active_read_only_workers = 0; active_total_workers = 0;
        recursion_depth = 0; delegation_depth = 0; spawned_by_worker = $false;
        execution_origin = 'manual_user'; manual_interactive = $true; owner_started_sol_session = $true;
        approval_id = [Guid]::NewGuid().ToString('D'); purpose = 'A8 deterministic route test';
        requested_luna_max_subagents = 0; requested_terra_max_subagents = 0;
        requested_ox_alpha_subagents = 0; requested_sol_subagents = 0;
        subagent_requested = $false; background_continuation = $false; automatic_fallback = $false
    }
}
function Write-Permit {
    param([string]$Path, $Request, [string]$Model, [string]$Effort, [string]$Role)
    Write-TestJson -Path $Path -Value ([ordered]@{
        schema_version = 2; approval_id = [string]$Request.approval_id; state = 'ACTIVE'; issued_by = 'A8 deterministic test';
        issued_at = ([DateTimeOffset]::UtcNow.AddMinutes(-1).ToString('o')); expires_at = ([DateTimeOffset]::UtcNow.AddMinutes(10).ToString('o'));
        purpose = 'A8 deterministic route test'; origin = 'manual_user'; manual_interactive = $true;
        allowed_model = $Model; allowed_reasoning = $Effort; allowed_role = $Role; allowed_roles = @($Role);
        allow_subagents = $true; max_processes = 1; sol_subagents_allowed = $false;
        max_luna_max_subagents = 16; max_terra_max_subagents = 2; max_ox_alpha_subagents = 16;
        max_total_direct_subagents = 16; max_delegation_depth = 1; recursive_spawning = $false;
        background_continuation = $false; automatic_fallback = $false; consumed = $false; process_id = $null
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
$fixture = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'fixtures\a4-route-compiler-fixtures.json') -Raw | ConvertFrom-Json
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ('token-opt-a8-route-' + [Guid]::NewGuid().ToString('N'))

try {
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    $catalog = Join-Path $tempRoot 'catalog.json'
    $gate = Join-Path $tempRoot 'gate.json'
    $permit = Join-Path $tempRoot 'permit.json'
    $requestPath = Join-Path $tempRoot 'request.json'
    Write-TestJson $catalog $fixture.catalog
    Write-TestJson $gate ([ordered]@{
        schema_version = 2; policy_id = 'TOKEN-OPT-001-A8'; default_state = 'LOCKED'; manual_only = $true; owner_started_sol_session = $true;
        permit_path = $permit; max_processes = 1; sol_subagents_allowed = $false; max_luna_max_subagents = 16;
        max_terra_max_subagents = 2; max_ox_alpha_subagents = 16; max_total_direct_subagents = 16; allow_subagents = $true;
        max_delegation_depth = 1; recursive_spawning = $false; max_active_writers_account_wide = 2;
        max_writers_per_repository_or_worktree = 1; background_continuation = $false; automatic_fallback = $false;
        route_compiler_is_dispatcher = $false
    })

    $request = New-Request
    Write-TestJson $requestPath $request
    Expect-Error 'missing permit' 'CODEX_USAGE_LOCKED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    foreach ($origin in @('ChatGPT_Web','Astral_Bridge','automation','scheduled_task','background_agent')) {
        $request = New-Request; $request.execution_origin = $origin
        Write-Permit $permit $request 'gpt-5.6-sol' 'high' 'orchestrator'; Write-TestJson $requestPath $request
        Expect-Error "origin $origin" 'MANUAL_USER_ORIGIN_REQUIRED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }
    }

    $request = New-Request; $request.requested_sol_subagents = 1; $request.subagent_requested = $true
    Write-Permit $permit $request 'gpt-5.6-sol' 'high' 'orchestrator'; Write-TestJson $requestPath $request
    Expect-Error 'Sol cannot be its own subagent' 'SOL_SUBAGENTS_PROHIBITED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    foreach ($case in @(
        @{ name = 'Luna ceiling'; field = 'requested_luna_max_subagents'; value = 17; code = 'LUNA_MAX_SUBAGENT_LIMIT_EXCEEDED' },
        @{ name = 'Terra ceiling'; field = 'requested_terra_max_subagents'; value = 3; code = 'TERRA_MAX_SUBAGENT_LIMIT_EXCEEDED' },
        @{ name = 'Ox ceiling'; field = 'requested_ox_alpha_subagents'; value = 17; code = 'OX_ALPHA_SUBAGENT_LIMIT_EXCEEDED' }
    )) {
        $request = New-Request; Set-ObjectProperty $request $case.field $case.value; $request.subagent_requested = $true
        Write-Permit $permit $request 'gpt-5.6-sol' 'high' 'orchestrator'; Write-TestJson $requestPath $request
        Expect-Error $case.name $case.code { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }
    }

    $request = New-Request; $request.requested_luna_max_subagents = 15; $request.requested_terra_max_subagents = 2; $request.subagent_requested = $true
    Write-Permit $permit $request 'gpt-5.6-sol' 'high' 'orchestrator'; Write-TestJson $requestPath $request
    Expect-Error 'total direct ceiling' 'TOTAL_DIRECT_SUBAGENT_LIMIT_EXCEEDED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request; $request.delegation_depth = 2
    Write-Permit $permit $request 'gpt-5.6-sol' 'high' 'orchestrator'; Write-TestJson $requestPath $request
    Expect-Error 'delegation depth' 'DELEGATION_DEPTH_EXCEEDED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request; $request.spawned_by_worker = $true
    Write-Permit $permit $request 'gpt-5.6-sol' 'high' 'orchestrator'; Write-TestJson $requestPath $request
    Expect-Error 'recursive spawning' 'worker-originated recursive dispatch is disabled' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request; $request.background_continuation = $true
    Write-Permit $permit $request 'gpt-5.6-sol' 'high' 'orchestrator'; Write-TestJson $requestPath $request
    Expect-Error 'background' 'BACKGROUND_CONTINUATION_DISABLED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request; $request.automatic_fallback = $true
    Write-Permit $permit $request 'gpt-5.6-sol' 'high' 'orchestrator'; Write-TestJson $requestPath $request
    Expect-Error 'automatic fallback' 'AUTOMATIC_FALLBACK_DISABLED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request 'writer'; $request.active_writers = 2
    Write-Permit $permit $request 'openrouter/stealth/ox-alpha' 'high' 'writer'; Write-TestJson $requestPath $request
    Expect-Error 'account writer cap remains separate' 'ACCOUNT_WRITER_LIMIT_EXCEEDED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request 'writer'; $request.active_writers_target = 1
    Write-Permit $permit $request 'openrouter/stealth/ox-alpha' 'high' 'writer'; Write-TestJson $requestPath $request
    Expect-Error 'target writer cap remains one' 'TARGET_WRITER_LIMIT_EXCEEDED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request
    Write-Permit $permit $request 'gpt-5.6-sol' 'high' 'orchestrator'; Write-TestJson $requestPath $request
    $zero = (Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath) | ConvertFrom-Json
    Assert-Test ([string]$zero.selected_model -eq 'gpt-5.6-sol') 'Sol advisor may choose zero workers'

    $request = New-Request; $request.requested_luna_max_subagents = 3; $request.requested_terra_max_subagents = 2; $request.subagent_requested = $true
    Write-Permit $permit $request 'gpt-5.6-sol' 'high' 'orchestrator'; Write-TestJson $requestPath $request
    $multipleText = Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath
    $multiple = $multipleText | ConvertFrom-Json
    Assert-Test ([string]$multiple.selected_model -eq 'gpt-5.6-sol') 'Sol advisor may choose multiple useful direct workers'
    Assert-Test (-not [bool]$multiple.execution_boundary.sol_subagents_allowed) 'Sol child eligibility is false'
    Assert-Test ([int]$multiple.execution_boundary.max_luna_max_subagents -eq 16) 'Luna Max ceiling is 16'
    Assert-Test ([int]$multiple.execution_boundary.max_terra_max_subagents -eq 2) 'Terra Max ceiling is 2'
    Assert-Test ([int]$multiple.execution_boundary.max_ox_alpha_subagents -eq 16) 'Ox Alpha ceiling is 16'
    Assert-Test ([int]$multiple.execution_boundary.max_delegation_depth -eq 1) 'delegation depth is one'
    Assert-Test (-not [bool]$multiple.execution_boundary.dispatcher) 'route compiler remains non-dispatching'
    Assert-Test (-not $multipleText.Contains('codex exec') -and -not $multipleText.Contains('Start-Process')) 'route output contains no dispatch command'
    Write-Output 'SUMMARY PASS a8_sol_advisor_routing=26 real_codex_calls=0'
}
finally {
    if (Test-Path -LiteralPath $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force }
}
