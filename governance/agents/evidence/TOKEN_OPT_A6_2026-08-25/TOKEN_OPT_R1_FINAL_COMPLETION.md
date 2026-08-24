# TOKEN-OPT manual Codex gate and Cognee final completion — R1 evidence

Date: 2026-08-25 Asia/Manila

## Authority and starting state

- Manual run authority: Earl's `TOKEN_OPT_MANUAL_CODEX_GATE_AND_COGNEE_FINAL_COMPLETION_R1_2026-08-25.md` execution request.
- Context Vault: `D:\Documents\Codex\GitHub\gpt-context-vault`, branch `governance/agents-consolidation-002`, starting local/upstream HEAD `e1d4bdbd8a43937a6ef0d87fd66a117249d5c69c`, divergence `0 / 0`.
- Astral Bridge: `D:\Documents\Codex\Astral-Bridge`, branch `feature/ab-002-chatgpt-control-surface`, starting local/upstream HEAD `4d154543f1d96a3178477241ae6d43ea9f686d05`, divergence `0 / 0`.
- Existing A5/A6 and AB-002.6/AB-002.7 worktree residue was preserved. No reset, clean, stash, force push, destructive cleanup, subagent, child task, `codex exec`, `codex resume`, or model-backed probe was used.

## Manual Codex execution boundary

Root cause: the prior routing policy and Astral surfaces still allowed automated Codex launches, subagent intent, or fallback semantics, and the personal host did not have a deterministic process-level kill guard enforcing the desired manual-only boundary.

Enforcement completed:

- canonical manual gate, policy, routing profile, compiler, verifier, tests, and usage-guard source are present in the Context Vault;
- personal agents and Multi-Agent V2 are disabled; thread/process capacity is one;
- router enabled providers are empty, `max_processes=1`, `max_children=0`, automatic fallback is false, and `allow_subagents=false`;
- `Earl Codex Usage Guard` is installed, enabled, running, reports `PROTECTED`, has one watcher, and has no active permit;
- only current Codex Desktop app-server infrastructure is allowed; non-app-server `exec` and `resume` launches are denied and terminated;
- deterministic permit validation requires exact purpose, role, expiry, process identity, and manual authorization and rejects prior approval, autonomous, speculative, and subagent wording.

Verification:

```text
test-a4-routing.ps1                  PASS
test-a6-manual-execution-gate.ps1   PASS — 28 scenarios
usage-guard self-test               PASS
usage-guard harmless dummy test     PASS
verify-token-optimization.ps1       PASS
SUMMARY PASS policy=A6 manual_only=true max_processes=1 max_children=0 a4_fixtures=27 behavior_fixtures=58 personal=PASS catalog=PASS real_codex_calls=0
```

All source, installed guard, and tracked manifest hashes matched at final verification. The current run made zero real Codex model calls.

Backups:

- `C:\Users\adria\.codex\backups\TOKEN-OPT-001-A6-GUARD-20260824T195613Z`
- `C:\Users\adria\.codex\backups\TOKEN-OPT-R1-PERSONAL-20260824T195017Z`

## Managed AGENTS synchronization

Dry-run and apply evidence:

- `agents-sync-dry-run-r1.json`
- `agents-sync-apply-r1.json`

Canonical hash: `64f2bdf6f8de3d257ff31b6ed986fc5fe87a558c5d6c85bff863023654b80b92`.

Updated eligible targets:

- global Codex managed replica and extension;
- HAU-USC Logistics live replica;
- Odysseus live replica;
- HAU-USC Logistics registered worktrees `backend-r3-a1-a2-b1`, `frontend-design-integration`, and `v084-live-operations-performance`.

Preserved blocked targets:

- Astral Bridge live replica;
- Astral Bridge registered worktrees `astral-bridge-agents-authorized-efc7a12` and `astral-bridge-agents-consolidation-001`.

The Astral targets were not mutated because their active pointer did not expose a safe writer state. Final managed verification passed every eligible target; historical appendix material remained unavailable and untouched.

Managed-replica backups are recorded per target in `agents-sync-apply-r1.json`, with the global backup rooted at `C:\Users\adria\.codex\backups\TOKEN-OPT-001-A5-20260824T203738Z`.

## Astral hard deny

Accepted amendment: `D:\Documents\Codex\Astral-Bridge\.codex\specs\accepted\2026-08-25-astral-bridge-ab002-r1-a2-manual-codex-execution-boundary.md`.

Implemented boundary:

- direct and wrapped Codex commands are denied in shell and managed-process surfaces;
- Codex handoff, execute, watch, loop, controller start/continue/instruction/approval/review, and `handoff_to_agent(agent=codex)` are denied with `CODEX_MANUAL_EXECUTION_REQUIRED`;
- read-only task observability, cancellation, and ordinary non-Codex process execution remain available;
- deterministic tests contain no real Codex invocation.

Verification:

```text
npm run build                         PASS
npm run codex:guard                   PASS — real_codex_calls=0
npm run controller:smoke              PASS — mock app-server only
npm run control:process               PASS
node scripts/execute-handoff-smoke.mjs PASS
npm run smoke                         PASS with Git Bash prepended to test-process PATH only
git diff --check                      PASS
```

The final TypeScript build was restarted through `C:\Users\adria\CodexTools\CodexBridgeStartup\Start-CodexPro.ps1 -Force`. Live acceptance on `127.0.0.1:8787` passed all four Codex denial paths, retained an ordinary Node process, registered 41 tools, and made zero real Codex calls. `Codex Connectors Health Audit` remains enabled; Astral/CodexPro passes, while the independent Native2 connector keeps the aggregate task result nonzero.

Existing rollback backup: `C:\Users\adria\CodexTools\CodexBridgeStartup\backups\AB-002.5-20260824-193455`.

## Cognee final-green

Root cause: the local health task was disabled, the plugin exit watcher exposed the API key in its process argument, and a complete authenticated remember/restart/recall acceptance had not yet been recorded.

Final state:

- plugin `cognee@cognee` version `1.4.3` is enabled;
- local/server runtime is `1.5.2` on `127.0.0.1:8011`;
- LLM is local Ollama `llama3.2:3b`;
- embeddings use FastEmbed `all-MiniLM-L6-v2`, dimension 384;
- detailed health reports relational, vector, graph, file, LLM, and embedding components healthy;
- authenticated remember and cognify completed in dataset `token_opt_r1_e2e`;
- marker SHA-256 is `4081F2D3737FF3FD588EFA41030D15EEF78B04269AFBAFD9035AEB394EF61B04`;
- recall contained the marker before restart;
- managed stop reached zero listener/workers with no respawn;
- managed start restored one listener and healthy service;
- recall contained the same marker after restart without rewriting it;
- persistent database root is `C:\Users\adria\.cognee\system\databases`;
- `Cognee Local Memory Health` was repaired, enabled, returned result `0`, and advanced on its approximately five-minute schedule with a stable listener;
- no current lock error, orphan watcher, traceback, or post-restart bad-service event was found.

Credential incident and repair:

- one process-inspection diagnostic exposed the then-current key because its redactor did not cover JSON-style arguments;
- that key was immediately treated as compromised, rotated, and revoked;
- the old and replacement keys are identified only by non-secret fingerprints `CE92C31FFAA9` and `367C774475F4`;
- stale watcher processes were stopped;
- the installed Cognee plugin was patched so the watcher receives the credential only through inherited environment state, not its command line;
- a replacement session-start fixture verified that watcher arguments contain neither the field nor live credential and that authenticated recall still succeeds.

Backups and evidence:

- task/runtime backup: `C:\Users\adria\.cognee-backups\R1-20260824T201741219Z`
- plugin security backup: `C:\Users\adria\.cognee-backups\R1-plugin-security-20260824T202712752Z`
- detailed report: `C:\Users\adria\.cognee-plugin\service\evidence\COGNEE_R1_FINAL_GREEN_2026-08-25.md`

Remaining limitation: `/api/v1/checks/connection` is the cloud-instance checker and tests `localhost:8001`, so it returns 503 for this local configuration. Local LLM and embedding acceptance is instead proven directly by `/health/detailed` and the authenticated remember/recall sequence.

## Router, tasks, and final resting-state audit

- router service version `0.4.0-beta.4` reports healthy and idle with zero active requests;
- router listener health passed on ports 4200 and 4202; the protected 4203 endpoint correctly requires caller authentication;
- the startup/automation scan found no `codex exec`, `codex resume`, `agent-check`, or `handoff_to_codex` launch reference;
- `Codex Router`, `Codex Router Tray`, `Earl Codex Usage Guard`, and `Cognee Local Memory Server` are running;
- `Cognee Local Memory Health`, `CodexPro MCP Startup`, and `Codex Connectors Health Audit` remain enabled;
- the manual Codex boundary remains locked; Astral is live with its hard deny; Cognee is live with one listener and persistent recall.

## Rollback

Use the exact timestamped backup listed for the affected subsystem, then rerun its deterministic verifier before re-enabling any scheduled task or managed service. Do not restore the revoked Cognee credential. Do not restore a routing configuration that enables subagents, automatic fallback, or automated Codex execution.
