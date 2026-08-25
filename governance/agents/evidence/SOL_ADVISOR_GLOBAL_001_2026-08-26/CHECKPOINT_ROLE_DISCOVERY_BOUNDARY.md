# SOL-ADVISOR-GLOBAL-001 Role-Discovery Boundary Checkpoint

Date: 2026-08-26
Owner: Earl
Repository: `D:\Documents\Codex\GitHub\gpt-context-vault`
Branch: `governance/agents-consolidation-002`
Pre-checkpoint HEAD and upstream: `04991e6f2e687922be47dbc7a30bed36959eb4e7`
Pre-checkpoint divergence: `0 ahead / 0 behind`
Pre-checkpoint worktree: clean

## Accepted authority

- Prompt: `D:\Download\SOL_ADVISOR_GLOBAL_OX_ALPHA_AMENDMENT_PROMPT_2026-08-26.md`
- SHA-256: `8A435990236A8129433E6E12FC2D6FB36200AD26BBDA82BFA71F4E32F9ADCE63`
- Declared route: `full`
- Preferred implementation overlay: Ox Alpha only after deterministic eligibility proof
- Native fallback: Terra / High for this account-wide, high-risk migration
- Required final reviewer: fresh Sol / High after parent verification

## Completed external state

1. Resolved `https://github.com/DannyMac180/sol-advisor.git` `refs/heads/main` to `37b75cad535abdd46531f0227483a8842d045ab8`.
2. Installed marketplace `sol-advisor` from upstream `main`.
3. Installed plugin `sol-advisor@sol-advisor` version `0.6.0` at `C:\Users\adria\.codex\plugins\cache\sol-advisor\sol-advisor\0.6.0`.
4. Verified the marketplace checkout HEAD equals the resolved upstream SHA and has no reported worktree changes.
5. Installed the exact upstream companion files:
   - `C:\Users\adria\.codex\agents\sol-advisor-luna-implementer.toml`
   - `C:\Users\adria\.codex\agents\sol-advisor-terra-implementer.toml`
   - `C:\Users\adria\.codex\agents\sol-advisor-sol-reviewer.toml`
6. Ran the exact all-role `--check`: passed.
7. Ran the `full` Terra-plus-Sol selective check: passed.
8. Preserved the existing `C:\Users\adria\.codex\agents\sol-advisor.toml`; it was not deleted or overwritten.
9. Created preflight backups outside Git at `C:\Users\adria\.codex\backups\SOL_ADVISOR_GLOBAL_001_20260826_preflight`.

## Exact role hashes

- Luna implementer: `000FF8BED7F94F77A460FB81424D51233EB6146DB5B21A346068ACEB6A9ABE27`
- Terra implementer: `7C9497C46207007565F72AC9BAC6CE4954A1491914E4D64B44E27E4C27E8CD43`
- Sol reviewer: `6AC63677BCC8677A9A743522CF06696C8EDB1B005A61430E0FC8FA62E18DC355`
- Preserved legacy/personal `sol-advisor.toml`: `60EE3F66D199379E2F67E2A6A0845191B1E4696F7FAAA654E1DE021852177C93`

## Preflight backup hashes

- Canonical `AGENTS.md`: `EA1B32A7A1BAA28A4845C970A7178603B7FC9E98D80667A1C4BAA747F31A4D87`
- Personal managed `AGENTS.md`: `9134072DB442FC8E838B07434849701F4885A9C831D0B50A747103BC24F437B6`
- Pre-plugin `config.toml`: `556C04E483D3532DE56D86B09E6E8546CB2D80074B8F4CC1B4708D1C3F31AB1E`
- Preserved `sol-advisor.toml`: `60EE3F66D199379E2F67E2A6A0845191B1E4696F7FAAA654E1DE021852177C93`

The current post-install Codex configuration is expected to differ from the pre-plugin backup because marketplace/plugin registration is an accepted external write. Reconcile it in the fresh task; do not restore the backup blindly.

## Required stop and resume

Upstream Sol Advisor states that native companion roles are discovered only by a fresh Codex task after installation. This task therefore stops before governance implementation and before any implementation/review auxiliary spawn.

In the fresh owner-started GPT-5.6 Sol / High task:

1. Read `AGENTS.md`, `.codex/CURRENT.md`, and this checkpoint.
2. Re-run the repository handshake and verify no concurrent work appeared.
3. Verify the installed plugin and companion files with non-mutating checks; do not reinstall unless verified state differs.
4. Confirm exact native discovery/runtime metadata for `sol_advisor_terra_implementer` and `sol_advisor_sol_reviewer` before using the declared `full` route.
5. Inspect the Codex Model Router/OpenRouter configuration and fail closed on Ox unless exact runtime identity, callable availability, zero pricing, health, and required capabilities are all proven.
6. Continue from the accepted prompt's governance implementation phase; do not repeat completed installation work.

## Remaining accepted work

- Evaluate and reconcile the temporary Ox Alpha extension and fail-closed eligibility gate.
- Create accepted amendment `SOL-ADVISOR-GLOBAL-001` and reconcile TOKEN-OPT into one routing contract.
- Update canonical `AGENTS.md`, eligible project extensions, templates, router/validator logic, and managed replicas without modifying product/application code.
- Run deterministic synchronization, validators, routing smoke tests, complete-diff review, and the required fresh Sol / High final review.
