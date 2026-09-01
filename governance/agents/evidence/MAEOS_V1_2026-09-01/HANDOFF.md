# MAEOS v1 durable handoff

TASK: MAEOS v1 account-wide orchestration integration
MAEOS VERSION: v1
GOVERNANCE REVISION: MAEOS-v1
STARTING CONTEXT-VAULT SHA: 2285cf4926df0ca56e0b2966dd605f6b5a18f365
ENDING CONTEXT-VAULT SHA: 2a77f1cb156d5bb2a68456dd66fcceaafc6e8ea0 (implementation merge)
IMPLEMENTATION PUBLICATION: PR #19 https://github.com/invicta-ctrl/gpt-context-vault/pull/19 merged 2026-09-01 into governance/agents-consolidation-002
BRANCH / PR / MERGE: codex/maeos-v1; PR #19 merged 2026-09-01 into governance/agents-consolidation-002
WORKTREE STATE: durable final handoff after implementation publication
INDEPENDENT FRESH SOL REVIEW: ship

ARCANEDGE: inspected pinned `08d5d6c14b556026657ffdb4fc217b6ba6d020b1`, MIT; adopted curated task graph, worker packet, worktree, coordination, reference routing, and review assets; adapted for root-only graph, depth one, zero default children, and one-writer safety; rejected mandatory child, depth two, installer/global instruction block.

AUGIEFRA: inspected pinned `6ee3c15714b5f8d695b1a7aaa2178364d1c67346`, MIT; adopted config merge, runtime-truth, completion-guard, and packet mechanics; rejected recursive Terra leaves and automatic Spark fallback; Spark `REFERENCE_ONLY/SKIPPED`; no catalog patch.

ACTIVE MAEOS ROLE CONTRACT: MAEOS-v1 governs the owner-started integration layer; Sol High is root/reviewer; Luna Max is read-only leaf only; Terra High is every native non-Ox implementation/write/integration lane; Ox is the optional fail-closed writer overlay; locked manual execution gate; native ceiling 16; depth one; no recursion/fallback; writer caps 2 account-wide / 1 target. SOL-ADVISOR-GLOBAL-001 is historical compatibility/provenance only.

CODEX_HOME: C:/Users/adria/.codex
BACKUPS CREATED: C:/Users/adria/.codex/backups/MAEOS-v1-20260901T000000Z (only changed/managed local files and LeanCTX config backup)
FILES INSTALLED/CHANGED: six MAEOS skills under C:/Users/adria/.agents/skills; three curated references under C:/Users/adria/.codex/references/maeos; sol-advisor profile; stale config usage hint; preserved original two-command `hooks.json` SessionStart state; canonical managed LeanCTX guidance block; managed global AGENTS and extension only through scoped sync; C:/Users/adria/.codex/maeos/INSTALL_MANIFEST.json (schema 3, 15 managed entries)
MANAGED MANIFEST: vendor/maeos/UPSTREAM_MANIFEST.json and C:/Users/adria/.codex/maeos/INSTALL_MANIFEST.json
RUNTIME FEATURES: observed `multi_agent` and `multi_agent_v2` stable true via exact read-only installed-client script
RUNTIME MODEL PROOF: UNRUN; features output does not prove fresh-session model/effort
LEANCTX ALLOWANCES: exact paths only for `inspect-codex-features.ps1`, `test-maeos-routing.ps1`, `test-maeos-install.ps1`, `verify-maeos.ps1`, and `verify-token-optimization.ps1`; no executable or shell broadening. The original LeanCTX backup remains the rollback source.

NORMAL MAEOS TOPOLOGY: 0 default children; 0–4 normal readers; normally <=5 total with <=1 writer
BURST POLICY: read-only only, finite root-authored graph, <=16
WRITER POLICY: one per repository/worktree; second account writer only under existing proven isolation
TASK-GRAPH POLICY: optional for simple/linear work; required for larger burst
REVIEW POLICY: risk-triggered; mandatory fresh independent Sol review for MAEOS
REASONING POLICY: TOKEN-OPT remains authoritative; targeted packets/no full history by default

TESTS / EXACT RESULTS: inspect-codex-features `OBSERVED` (`multi_agent`/`multi_agent_v2` stable true; no model proof); isolated installer first-install Plan/APPLIED/NOOP plus all 15 managed-class drift refusals `SUMMARY PASS maeos_install_plan_apply_noop=1 references=3 skills=6 real_codex_calls=0`; account installer derives its first Apply expectation from Plan (`APPLIED` when changes/manifest update are planned, otherwise verified `NOOP`) and always requires a second `NOOP`; strengthened verify-maeos `PASS managed_files=15 references=3 skills=6`; functional compiler fixture rejects a mixed 5-Luna/1-Terra burst and all prior negative cases; comprehensive verify-token-optimization preserves 58 historical behavior fixtures and passes A4/A6/A7/A8, isolated historical SOL, and MAEOS suites with personal/catalog `PASS`; active-authority cluster regressions reject Terra integration-sensitive-only wording, active SOL supersession/current-route wording, and an owner-started line that does not name MAEOS-v1; scoped global-codex sync dry run had the sole target then Apply `UPDATED/MATCH/MATCH`; scoped verify-agents `MATCH/MATCH/MATCH`; canonical/global AGENTS SHA-256 `203CF9EC80652801E8EA435CBDA854CD72A7F3C59D0B7FAEFC0EF43EFA2A869E`.
UNRUN CHECKS: fresh-session leaf/parallel/writer runtime smoke and actual model/effort proof; no approved fresh manual runtime execution was performed. The existing SessionStart hook remains installed, but its exact emitted LeanCTX guidance is canonical so cached or future emission is idempotent. Exact TOML parse is also UNRUN: the installed LeanCTX shell allowlist denied the bundled `python.exe` TOML parser, and no broad executable or shell allowance was added.
ROLLBACK: the manifest records exact pre-change hashes and verified backups for the Sol profile, config, global AGENTS, global extension, Lean exact allowances, and hooks; restore only those exact baselines. The verified Lean rollback is `C:\Users\adria\.codex\backups\MAEOS-v1-20260901T000000Z\lean-ctx-config.toml` (SHA-256 `F0E31F6F99DF94C930034C76C2189B4DFB6EA8F60A5F780B6989AAA365382E55`). Hooks are preserved desired state; do not disable or remove them. The six skills and three references are `PREEXISTENCE_UNPROVEN_PRESERVE_ON_ROLLBACK` with null pre-hashes/backups, so rollback must preserve rather than delete them. Restore LeanCTX config from its verified backup; normal Git revert after review.
UNRESOLVED RISKS: compiler test is deterministic/static; fresh-session actual model/effort/native-dispatch proof and exact TOML parsing remain UNRUN as recorded above. Independent fresh Sol review returned `ship`; PR #19 merged 2026-09-01.
PROJECT ADOPTION TEMPLATE: templates/MAEOS_PROJECT_ADOPTION_TEMPLATE.md
NEXT RECOMMENDED PROJECT: separate owner-authorized project adoption only; none is automatic, and no application repository was mutated
DO NOT REPEAT: do not reapply installation or sync absent changed source/target
HANDOFF_STATUS: MAEOS-v1 PUBLISHED / MERGED / ACCEPTED / SHIP REVIEW COMPLETE
