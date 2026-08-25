# TOKEN-OPT-001-A7 Cognee End-to-End Verification Receipt

**Date:** 2026-08-25
**Target:** local Cognee at `http://127.0.0.1:8011`
**Result:** PARTIAL / BLOCKED AT LOCAL LLM AND GRAPH IMPROVE

## Verified

- Cognee CLI/server version: `1.5.2`, from the dedicated `C:\Users\adria\.cognee-plugin\venv`.
- The detailed health route reached the local server. SQLite, LanceDB, Ladybug graph, local file storage, FastEmbed, and `sentence-transformers/all-MiniLM-L6-v2` were healthy.
- Current live server configuration uses Ollama `qwen3:8b`; the model is installed and Ollama's tags/process APIs are reachable.
- Codex Cognee plugin `1.4.3` is installed and its SessionStart, prompt, trace, Stop, PreCompact, and SessionEnd hooks are registered.
- Fresh synthetic agent session `codex-a7-e2e-c5852d6ae367` registered successfully.
- Synthetic marker `A7_COGNEE_20260825T084123Z_44B429CD` stored as a QA entry in dataset `token_opt_a7_e2e`; response was `session_stored` and an entry ID was returned.
- Same-session authenticated recall found the exact marker.
- The supported SessionEnd hook exited `0`, passed the API key through inherited environment only, and deferred heavy graph work to the existing shutdown worker.
- The detached worker started against the intended session and dataset and unregistered the synthetic agent connection.

## Blocking evidence

- `/health/detailed` returned `degraded` only because the local LLM connection test timed out after 30 seconds.
- Direct `qwen3:8b` generation did not complete within 300 seconds. A controlled restart of the exact local Ollama app/server process pair restored its API, but the same deployed-model generation probe remained nonresponsive.
- The SessionEnd worker's first `/api/v1/improve` attempt timed out, recorded `wrote=false`, and entered its bounded retry path.
- Fresh-session graph recall returned `NoDataError`; therefore graph/improve write and cross-session recall are not accepted.
- The synthetic marker is retained and explicitly labelled disposable because safe cleanup would remove evidence before graph state is settled.

## Safety and disposition

- No credential value was printed, placed in process arguments, written to this receipt, or committed.
- No model/provider configuration was changed. Switching away from the currently configured `qwen3:8b` would be a provider/configuration choice outside a routine repair.
- Governance, routing, AGENTS synchronization, hooks timeout, and usage-guard verification are independently green; this blocker is isolated to Cognee local LLM-backed improve.

## Next exact action

Start a fresh owner-authorized `@sol-advisor` task to diagnose the existing `qwen3:8b` generation stall without changing models, then rerun only Cognee Phase 10.
