---
schema_version: 1
spec_id: TOKEN-OPT-001-A3
title: Headroom LeanCTX Reintroduction, Codex Tool Parity, and Local Cognee Trial
status: accepted
owner: Earl
accepted_date: 2026-08-24
timezone: Asia/Manila
risk: medium
execution_plane: Astral Bridge deterministic local operations
classification: account-wide-tool-governance-amendment
supersedes:
  - TOKEN-OPT-001-A2 Headroom retirement decision
---

# TOKEN-OPT-001-A3
## Headroom LeanCTX Reintroduction, Codex Tool Parity, and Local Cognee Trial

## Acceptance record

Earl explicitly authorized this amendment on 2026-08-24 by directing that current Headroom be installed and configured with `HEADROOM_CONTEXT_TOOL=lean-ctx` for both Claude Code and Codex; that Serena and CodeGraph be added to Codex; that Hallmark and Impeccable remain enabled and complementary in both clients; and that Cognee be evaluated and, when the local preflight is green, configured without paid inference APIs.

This amendment supersedes only the Headroom-retirement decision in TOKEN-OPT-001-A2. The A2 removals, Figma decision, complementary routing, backup requirements, and Astral Bridge source-write stop condition remain active.

No commit, push, deployment, destructive Git operation, cloud Cognee configuration, paid model key, or write to the occupied Astral Bridge source worktree is authorized.

## Objectives

1. Use current supported Headroom as a proxy/compression layer downstream of LeanCTX without replacing LeanCTX.
2. Give Codex the same bounded semantic and impact-analysis tools already available to Claude.
3. Preserve one non-conflicting Hallmark-to-Impeccable frontend sequence in both clients.
4. Trial Cognee as secondary cross-session episodic memory using fully local inference and embeddings.
5. Preserve the Context Vault and authoritative project repositories as the only governance and project-state authorities.

## Headroom and LeanCTX

Install a current Headroom release only after its installed help or source confirms support for `HEADROOM_CONTEXT_TOOL=lean-ctx`.

Required persistent settings:

```text
HEADROOM_CONTEXT_TOOL=lean-ctx
HEADROOM_PORT=8791
```

Port `8791` is selected to avoid Astral Bridge on `127.0.0.1:8787`.

Configure Headroom for both Claude Code and Codex. Preserve each client's model selection, authentication, sandbox, approvals, existing MCP registrations, and provider routing. Headroom owns proxy-level compression and optional reversible retrieval only. It must not own project memory, code memory, or a second code graph while Cognee, Context Vault, Serena, CodeGraph, and LeanCTX already own those roles.

Do not enable Headroom shared memory, Headroom code-memory, Headroom code-graph, or output-effort shaping in this slice. Establish a clean compression baseline first.

## Codex tool parity

Add user-scoped Codex MCP registrations for:

- Serena, using the installed absolute executable and `start-mcp-server --context codex --project-from-cwd` when supported;
- CodeGraph, using the installed absolute executable and `serve --mcp`.

Preserve LeanCTX, Node REPL, and Figma. Do not remove Claude's existing Serena or CodeGraph registrations.

Routing remains:

```text
known symbol or semantic edit -> Serena
broad discovery or large output -> LeanCTX
cross-module impact or affected tests -> CodeGraph
current external API documentation -> Context7
```

Use one primary repository tool per question and stop when it establishes the required fact.

## Hallmark and Impeccable

Required availability:

- Claude: Hallmark shared skill plus Impeccable plugin.
- Codex: Hallmark shared skill plus Impeccable user skill.

Required sequence:

```text
greenfield or substantial redesign
-> Hallmark establishes and locks direction
-> implementation
-> one bounded Impeccable audit/refinement
-> at most one confirmation pass
-> UI quality gate
-> stop
```

Use Impeccable alone for narrow accessibility, responsiveness, typography, spacing, copy, motion, state, performance, and hardening work. Impeccable may not replace an accepted Hallmark direction unless Earl explicitly authorizes that change.

## Local Cognee trial

Cognee is authorized only as secondary episodic recall across Codex and Claude. It is never authoritative for specifications, current step, Git state, deployments, migrations, data, credentials, or owner decisions.

Use the already installed Ollama runtime and existing `qwen3:8b` model. Configure both text generation and embeddings locally so no provider silently falls back to OpenAI:

```dotenv
COGNEE_BACKEND="local"
LLM_PROVIDER="ollama"
LLM_MODEL="qwen3:8b"
LLM_ENDPOINT="http://localhost:11434/v1"
LLM_API_KEY="ollama"
EMBEDDING_PROVIDER="fastembed"
EMBEDDING_MODEL="sentence-transformers/all-MiniLM-L6-v2"
EMBEDDING_DIMENSIONS="384"
STRUCTURED_OUTPUT_FRAMEWORK="litellm_native"
COGNEE_PLUGIN_DATASET="agent_sessions"
COGNEE_PREFER_MEMORY="false"
```

Enable the existing Codex Cognee plugin and install the official Cognee Claude Code memory plugin only after:

- Codex hooks are enabled;
- Ollama responds locally;
- port `8011` is available or already owned by the same local Cognee installation;
- no cloud Cognee endpoint or paid LLM key is configured;
- configuration and plugin files are backed up.

The first trial must use a disposable test session and synthetic non-secret memory. Do not ingest the Context Vault, entire repositories, credentials, private logs, attachments, or historical session archives.

If local Cognee cannot complete a synthetic remember/sync/recall cycle reliably with bounded latency, leave the plugins disabled and preserve the local configuration for diagnosis rather than injecting failing recall into every prompt.

## Backups

Before personal changes, create:

```text
C:\Users\adria\.codex\backups\TOKEN-OPT-001-A3-<timestamp>
```

Back up every existing personal configuration or plugin-state file that will change, plus a redacted record of the relevant user environment-variable names and prior values. Record byte length and SHA-256 and verify source-to-backup identity before mutation. Never copy secrets into governance files or command output.

## Verification

Required checks:

- current Headroom version and help/source confirm LeanCTX selection;
- `HEADROOM_CONTEXT_TOOL=lean-ctx` and `HEADROOM_PORT=8791` persist at user scope;
- Headroom doctor/status verifies Claude and Codex routing without using port `8787`;
- `codex mcp list` shows Serena, LeanCTX, CodeGraph, Node REPL, and Figma enabled;
- Claude retains Serena, LeanCTX, CodeGraph, Context7, Node REPL, and Figma;
- Hallmark and Impeccable resolve in both clients;
- Cognee uses Ollama plus Fastembed and has no cloud base URL or paid API key;
- Codex Cognee hooks are enabled and trusted when required;
- a synthetic local Cognee test either passes remember/sync/recall or the plugins remain disabled;
- Context Vault diff is limited to A2/A3 and the token-efficiency protocol;
- no Astral Bridge source file is changed by this task.

## Rollback

Rollback uses the timestamped backup and supported uninstall/unwrap commands:

- `headroom unwrap claude`
- `headroom unwrap codex`
- remove the Headroom MCP registrations and user environment values added by this amendment;
- remove only the new Codex Serena and CodeGraph registrations;
- disable or uninstall the Cognee plugins and restore backed-up Cognee configuration;
- restore personal configuration files from verified backups.

Never use Git reset, history rewrite, or deletion of unknown work.
