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
        role = $Role; run_id = 'a7-owner-sol'; task_id = [Guid]::NewGuid().ToString('N');
        dispatch_seed_tokens = 0; worker_working_tokens = 0; context_tokens = 0;
        active_writers = 0; active_writers_target = 0; active_read_only_workers = 0; active_total_workers = 0;
        recursion_depth = 0; delegation_depth = 0; spawned_by_worker = $false;
        execution_origin = 'manual_user'; manual_interactive = $true; owner_started_sol_session = $true;
        approval_id = [Guid]::NewGuid().ToString('D'); purpose = 'A7 deterministic route test';
        requested_children = 0; subagent_requested = $false; background_continuation = $false; automatic_fallback = $false
    }
}
function Write-Permit {
    param([string]$Path, $Request, [string]$Model, [string]$Effort, [string]$Role)
    Write-TestJson -Path $Path -Value ([ordered]@{
        schema_version = 2; approval_id = [string]$Request.approval_id; state = 'ACTIVE'; issued_by = 'A7 deterministic test';
        issued_at = ([DateTimeOffset]::UtcNow.AddMinutes(-1).ToString('o')); expires_at = ([DateTimeOffset]::UtcNow.AddMinutes(10).ToString('o'));
        purpose = 'A7 deterministic route test'; origin = 'manual_user'; manual_interactive = $true;
        allowed_model = $Model; allowed_reasoning = $Effort; allowed_role = $Role; allowed_roles = @($Role);
        allow_subagents = $true; max_processes = 1; default_children = 0; max_children = 16; max_delegation_depth = 1;
        recursive_spawning = $false; background_continuation = $false; automatic_fallback = $false;
        consumed = $false; process_id = $null
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
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ('token-opt-a7-route-' + [Guid]::NewGuid().ToString('N'))

try {
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    $catalog = Join-Path $tempRoot 'catalog.json'
    $gate = Join-Path $tempRoot 'gate.json'
    $permit = Join-Path $tempRoot 'permit.json'
    $requestPath = Join-Path $tempRoot 'request.json'
    Write-TestJson $catalog $fixture.catalog
    Write-TestJson $gate ([ordered]@{
        schema_version = 2; policy_id = 'TOKEN-OPT-001-A7'; default_state = 'LOCKED'; manual_only = $true; owner_started_sol_session = $true;
        permit_path = $permit; max_processes = 1; default_children = 0; max_children = 16; allow_subagents = $true;
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

    $request = New-Request; $request.requested_children = 17; $request.subagent_requested = $true
    Write-Permit $permit $request 'gpt-5.6-sol' 'high' 'orchestrator'; Write-TestJson $requestPath $request
    Expect-Error 'child limit' 'SOL_CHILD_LIMIT_EXCEEDED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

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
    Expect-Error 'account writer cap' 'ACCOUNT_WRITER_LIMIT_EXCEEDED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request 'writer'; $request.active_writers_target = 1
    Write-Permit $permit $request 'openrouter/stealth/ox-alpha' 'high' 'writer'; Write-TestJson $requestPath $request
    Expect-Error 'target writer cap' 'TARGET_WRITER_LIMIT_EXCEEDED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $oxObservation = [pscustomobject]@{ provider_available = $true; prompt_price = 0; completion_price = 0; health = 'healthy' }
    $request = New-Request 'writer'; Set-ObjectProperty $request 'requested_model' 'openrouter/stealth/ox-alpha'; Set-ObjectProperty $request 'data_classification' 'internal'; Set-ObjectProperty $request 'provider_observation' $oxObservation
    Write-Permit $permit $request 'openrouter/stealth/ox-alpha' 'high' 'writer'; Write-TestJson $requestPath $request
    $backend = (Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath) | ConvertFrom-Json
    Assert-Test ([string]$backend.selected_model -eq 'openrouter/stealth/ox-alpha') 'backend primary writer is Ox Alpha'

    $request = New-Request 'writer'; Set-ObjectProperty $request 'route_scope' 'integration_fallback'; Set-ObjectProperty $request 'explicit_sol_reroute' $true; Set-ObjectProperty $request 'requested_model' 'gpt-5.6-terra'
    Write-Permit $permit $request 'gpt-5.6-terra' 'max' 'writer'; Write-TestJson $requestPath $request
    $terra = (Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath) | ConvertFrom-Json
    Assert-Test ([string]$terra.selected_model -eq 'gpt-5.6-terra') 'explicit Sol fallback routes Terra'

    $request = New-Request 'writer'; Set-ObjectProperty $request 'route_scope' 'hau_frontend'; Set-ObjectProperty $request 'requested_model' 'gpt-5.6-terra'
    Write-Permit $permit $request 'gpt-5.6-terra' 'max' 'writer'; Write-TestJson $requestPath $request
    $frontend = (Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath) | ConvertFrom-Json
    Assert-Test ([string]$frontend.selected_model -eq 'gpt-5.6-terra') 'HAU frontend writer is Terra Max'

    $request = New-Request 'writer'; Set-ObjectProperty $request 'route_scope' 'hau_frontend'; Set-ObjectProperty $request 'requested_model' 'openrouter/stealth/ox-alpha'
    Write-Permit $permit $request 'openrouter/stealth/ox-alpha' 'high' 'writer'; Write-TestJson $requestPath $request
    Expect-Error 'HAU frontend rejects Ox writer' 'HAU_FRONTEND_TERRA_WRITER_REQUIRED' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request 'read_only_worker'; Set-ObjectProperty $request 'requested_model' 'gpt-5.6-luna'
    Write-Permit $permit $request 'gpt-5.6-luna' 'max' 'read_only_worker'; Write-TestJson $requestPath $request
    $luna = (Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath) | ConvertFrom-Json
    Assert-Test ([string]$luna.selected_model -eq 'gpt-5.6-luna') 'Luna remains read-only worker'

    $request = New-Request; Set-ObjectProperty $request 'requested_model' 'deepseek-v4-pro'
    Write-Permit $permit $request 'deepseek-v4-pro' 'high' 'orchestrator'; Write-TestJson $requestPath $request
    Expect-Error 'DeepSeek disabled' 'requested model is disabled' { Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath }

    $request = New-Request
    Write-Permit $permit $request 'gpt-5.6-sol' 'high' 'orchestrator'; Write-TestJson $requestPath $request
    $validText = Invoke-Compiler $compiler $profile $catalog $gate $permit $requestPath
    $valid = $validText | ConvertFrom-Json
    Assert-Test ([string]$valid.selected_model -eq 'gpt-5.6-sol') 'owner-started parent is Sol High'
    Assert-Test ([int]$valid.execution_boundary.max_children -eq 16) 'A7 child ceiling is 16'
    Assert-Test (-not [bool]$valid.execution_boundary.dispatcher) 'route compiler remains non-dispatching'
    Assert-Test (-not $validText.Contains('codex exec') -and -not $validText.Contains('Start-Process')) 'route output contains no dispatch command'
    Write-Output 'SUMMARY PASS a7_owner_started_sol_routing=21 real_codex_calls=0'
}
finally {
    if (Test-Path -LiteralPath $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force }
}
