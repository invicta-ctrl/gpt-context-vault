# TOKEN-OPT-001-A7 Cognee Status Receipt

**Date:** 2026-08-25
**Target:** local Cognee at `http://127.0.0.1:8011`
**Result:** PARTIALLY_GREEN_WITH_ISOLATED_LLM_DEGRADATION

## Classification

- **COGNEE_CORE_API:** DEGRADED AT FINAL PROBE — the final `/health` request timed out while the local LLM-backed improve path was stalled; earlier authenticated API and detailed component probes responded.
- **COGNEE_STORAGE:** GREEN — SQLite, LanceDB, Ladybug graph, local file storage, FastEmbed, and `sentence-transformers/all-MiniLM-L6-v2` were verified healthy.
- **COGNEE_SESSION_MEMORY:** GREEN — a fresh synthetic session registered, stored a QA entry, returned an entry ID, and recalled the exact marker.
- **COGNEE_CROSS_SESSION_RECALL:** GREEN FROM EXISTING VERIFIED EVIDENCE — the same-day managed local R1 receipt proves marker-positive recall after a controlled restart; that still-valid evidence is reused per owner steering.
- **COGNEE_LLM_IMPROVE:** DEGRADED — current Ollama `qwen3:8b` inference timed out; the A7 synthetic SessionEnd improve attempt recorded `wrote=false`.
- **COGNEE_OVERALL:** PARTIALLY_GREEN_WITH_ISOLATED_LLM_DEGRADATION.

## Current A7 synthetic evidence

- Cognee CLI/server version is `1.5.2` in the dedicated `C:\Users\adria\.cognee-plugin\venv`.
- Codex Cognee plugin `1.4.3` is installed and its SessionStart, prompt, trace, Stop, PreCompact, and SessionEnd hooks are registered.
- Synthetic session `codex-a7-e2e-c5852d6ae367` registered successfully.
- Synthetic marker `A7_COGNEE_20260825T084123Z_44B429CD` stored as `session_stored`; same-session recall found it.
- The supported SessionEnd hook exited `0`, kept the API key out of process arguments, and deferred heavy graph work to its shutdown worker.
- The synthetic marker remains explicitly labelled disposable. No cleanup is attempted during governance closure.

## Disposition

- Cognee LLM improve is not an A7 governance closure gate.
- No credential value was printed, placed in process arguments, written to this receipt, or committed.
- No model/provider configuration was changed.
- Follow-up: `COGNEE-LOCAL-LLM-01`.

## Next exact action

Start one fresh owner-started Sol Advisor session after this task closes to verify that A7 is loaded and native bounded delegation is available.
