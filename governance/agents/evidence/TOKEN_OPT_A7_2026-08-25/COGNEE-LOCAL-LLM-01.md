# COGNEE-LOCAL-LLM-01 — Ollama qwen3:8b inference timeout

**Status:** OPEN / DEFERRED
**Created:** 2026-08-25
**Owner:** Earl
**Parent closure:** TOKEN-OPT-001-A7
**Execution in parent task:** PROHIBITED BY OWNER STEERING

## Problem

The local Ollama API and configured `qwen3:8b` model are discoverable, but inference did not complete within 300 seconds. Cognee `/health/detailed` therefore reported the LLM provider degraded, and the synthetic SessionEnd improve attempt timed out with `wrote=false`.

## Preserved green evidence

- Cognee storage components and embedding service were healthy.
- Fresh session registration, QA storage, and same-session marker recall succeeded.
- Existing same-day R1 evidence proves cross-session recall after restart.
- No credential or model configuration was changed.

## Scope for a future task

Diagnose the existing `qwen3:8b` inference stall without automatic model substitution. Re-run only Cognee LLM health, improve, and a synthetic cross-session recall after the inference fault is resolved.

## Start condition

A separate explicit owner instruction after TOKEN-OPT-001-A7 closure.
