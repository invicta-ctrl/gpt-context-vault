---
title: AGENTS Audit
status: prechange-inventory-frozen
spec_id: AGENTS-CONSOLIDATION-001
captured: 2026-08-19
---

# AGENTS Audit

## Scope and method

The authorized filename-only scan covered accessible `C:\` and `D:\` areas. It followed directories without traversing reparse points, matched `AGENTS.md` case-insensitively on Windows, hashed every match with SHA-256, and recorded Git identity where available.

The exhaustive machine-readable evidence is:

```text
governance/agents/inventory/AGENTS_INVENTORY_PRECHANGE_2026-08-19.json
governance/agents/inventory/AGENTS_INVENTORY_PRECHANGE_2026-08-19.csv
```

The JSON also records AGENTS-family variants and every inaccessible path. This Markdown report renders every discovered exact Windows-equivalent `AGENTS.md` file.

## Verified pre-change totals

```text
Windows-equivalent AGENTS.md: 106
Exact uppercase spelling:      98
Lowercase case variants:        8
Unique SHA-256 hashes:         41
Duplicate hash groups:         10
AGENTS-family variants:        14
Unclassified exact files:       0
Inaccessible protected paths: 206
```

The family-variant count includes the newly accepted `AGENTS-CONSOLIDATION-001.md` specification because its filename begins with `AGENTS`; it is governance authority, not a backup or replica.

## Verified candidate-state totals

The final filename-only verification scan was rerun after creating the two isolated governance worktrees. Its machine-readable evidence is:

```text
governance/agents/inventory/AGENTS_INVENTORY_CANDIDATE_2026-08-19.json
governance/agents/inventory/AGENTS_INVENTORY_CANDIDATE_2026-08-19.csv
```

```text
Windows-equivalent AGENTS.md: 108
Exact uppercase spelling:     100
Lowercase case variants:       8
Unique SHA-256 hashes:        42
Duplicate hash groups:        11
AGENTS-family variants:       18
Unclassified exact files:      0
Inaccessible protected paths: 206
```

The increase from 106 to 108 exact files is fully accounted for by the isolated Context Vault canonical candidate and the isolated Astral Bridge managed-replica candidate. No live Global Codex, HAU, Astral main, Odysseus, historical, worktree-derived, backup, fixture, package, plugin, marketplace, or vendor root policy was added or removed.

## Classification totals

| Classification | Count | Synchronization |
|---|---:|---|
| Owned active repository | 2 | Candidate only after repository gates |
| Owned HAU worktree | 32 | Forbidden |
| Global/local AI configuration | 2 | Conditional managed-replica targets |
| Stale owned | 2 | Preserve until replacement/reference gates pass |
| Historical/archive/evidence | 2 | Forbidden |
| Backup/example/test | 39 | Forbidden |
| Third-party/vendor/package/plugin | 27 | Forbidden |
| Unknown | 0 | N/A |

## Authority findings

- The live Context Vault had no root `AGENTS.md` before this task.
- Global Codex, HAU-USC Logistics, Astral Bridge, and Odysseus each contained independently editable general rules.
- `D:\Download\AGENTS.md` claimed Context Vault entrypoint status but was a loose copy outside the repository.
- `D:\AI_Workspace\AGENTS.md` claimed canonical Odysseus status.
- HAU contained 32 worktree-area copies, including dirty and actively locked lineages; they are historical or operationally derived, not sync targets.
- Third-party and fixture paths were classified with zero unknown exact files.

## Duplicate-hash findings

The largest duplicate group is the HAU policy hash `819364b3...`, present in the active checkout and 27 worktree copies. Three additional HAU copies use semantically equivalent text with different line-ending bytes under hash `eeb436f3...`.

The remaining large groups are temporary CodexPro fixtures, package/cache copies, and vendor duplicates. They are excluded from synchronization.

## Inaccessible areas

The scan encountered 206 protected or transient paths. Most are Windows, ProgramData, package, service, system, or sandbox areas on `C:\`; `D:\System Volume Information` was inaccessible on `D:\`.

No claim is made that protected directories were successfully scanned. The exhaustive path/error list is retained in the JSON evidence.

## Exhaustive exact-file inventory

| # | Absolute path | Classification | Bytes | SHA-256 | Git root | Branch | Tracked |
|---:|---|---|---:|---|---|---|:---:|
| 1 | `C:\Users\adria\.agents\backups\hallmark-install-20260802-184155\AGENTS.md` | BACKUP_EXAMPLE_TEST | 10729 | `fbed46f8549f8eaa3140dbffd8de350dbc5b8416045dd5395d0798071eb82926` | `N/A` | `N/A` | N/A |
| 2 | `C:\Users\adria\.cargo\registry\src\index.crates.io-1949cf8c6b5b557f\lean-ctx-3.9.12\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 246 | `50c56ef7a987a5d042902952549a0e24387fc16fd01759593789bf403d589e1c` | `N/A` | `N/A` | N/A |
| 3 | `C:\Users\adria\.cargo\registry\src\index.crates.io-1949cf8c6b5b557f\zerocopy-0.8.52\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 3112 | `24b16178226d2f96cafd03eed01113b4b0240c9e6a6cd938a155e991b4f11034` | `N/A` | `N/A` | N/A |
| 4 | `C:\Users\adria\.cargo\registry\src\index.crates.io-1949cf8c6b5b557f\zerocopy-0.8.55\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 3112 | `24b16178226d2f96cafd03eed01113b4b0240c9e6a6cd938a155e991b4f11034` | `N/A` | `N/A` | N/A |
| 5 | `C:\Users\adria\.claude\plugins\marketplaces\impeccable\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 14150 | `d2a2b1c4f5d0a49c467adfbe263efcc0eec785855b3c5a1e976e337a23076bd4` | `N/A` | `N/A` | N/A |
| 6 | `C:\Users\adria\.codex\.tmp\bundled-marketplaces\openai-bundled.staging-d8b227ca-4295-4790-949b-ff0fa80e8057\plugins\sites\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 932 | `1948b53b13790189e85281254c899005ca22c86f4eb7b664fffdc0b52d9b10ea` | `N/A` | `N/A` | N/A |
| 7 | `C:\Users\adria\.codex\.tmp\bundled-marketplaces\openai-bundled\plugins\sites\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 932 | `1948b53b13790189e85281254c899005ca22c86f4eb7b664fffdc0b52d9b10ea` | `N/A` | `N/A` | N/A |
| 8 | `C:\Users\adria\.codex\.tmp\plugins\plugins\build-web-apps\skills\react-best-practices\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 97869 | `924b5c33d0f671769467ac8b10ed98c9708d6db3e5465cc3dec368454ff059d0` | `N/A` | `N/A` | N/A |
| 9 | `C:\Users\adria\.codex\.tmp\plugins\plugins\build-web-apps\skills\supabase-best-practices\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 2227 | `f3336d9942583a30df20e4bad03adeb48d1f246583999979e5cceb215bda55e9` | `N/A` | `N/A` | N/A |
| 10 | `C:\Users\adria\.codex\.tmp\plugins\plugins\zoom\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 475 | `6632c3523fb0b61e98d689724ceaa19fd3f7d9dc50aff78c5e4c891a441ee3de` | `N/A` | `N/A` | N/A |
| 11 | `C:\Users\adria\.codex\AGENTS.md` | GLOBAL_LOCAL_AI_CONFIGURATION | 13098 | `076191b522646c02896c7b31901f918a0db1cd5e855dd5b6c20ee3e3901e7c42` | `N/A` | `N/A` | N/A |
| 12 | `C:\Users\adria\.codex\plugins\cache\openai-bundled\sites\0.1.37\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 932 | `1948b53b13790189e85281254c899005ca22c86f4eb7b664fffdc0b52d9b10ea` | `N/A` | `N/A` | N/A |
| 13 | `C:\Users\adria\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\Claude Extensions\ant.dir.gh.wonderwhy-er.desktopcommandermcp\node_modules\@supabase\auth-js\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 904 | `c93e2a7d549f427e44d598eead73bd901f93470977b27f43a6f2cbea28f1cbd5` | `N/A` | `N/A` | N/A |
| 14 | `C:\Users\adria\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\Claude Extensions\ant.dir.gh.wonderwhy-er.desktopcommandermcp\node_modules\@supabase\functions-js\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 849 | `84552dc956a63fd915607f97794918971a6719231214c15ab364cdf0de12d058` | `N/A` | `N/A` | N/A |
| 15 | `C:\Users\adria\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\Claude Extensions\ant.dir.gh.wonderwhy-er.desktopcommandermcp\node_modules\@supabase\postgrest-js\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 904 | `0e68eade1bbae48a8df26ab46363dac100e76f038fef136fada45165dc92021f` | `N/A` | `N/A` | N/A |
| 16 | `C:\Users\adria\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\Claude Extensions\ant.dir.gh.wonderwhy-er.desktopcommandermcp\node_modules\@supabase\realtime-js\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 930 | `ea65270fa49ec5b8bdfc3f35f70861bc90ea823e1365ee89e73d787c15853137` | `N/A` | `N/A` | N/A |
| 17 | `C:\Users\adria\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\Claude Extensions\ant.dir.gh.wonderwhy-er.desktopcommandermcp\node_modules\@supabase\storage-js\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 926 | `2d35b8f1877f3ebd3f9348e254323aa970060dcf406d05fe18de6904870e4635` | `N/A` | `N/A` | N/A |
| 18 | `C:\Users\adria\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\Claude Extensions\ant.dir.gh.wonderwhy-er.desktopcommandermcp\node_modules\@supabase\supabase-js\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 996 | `f21a864654bbb1c15ec72ddd724e5b568f85f3ec1054c3313819e32e40860814` | `N/A` | `N/A` | N/A |
| 19 | `C:\Users\adria\AppData\Local\Programs\Microsoft VS Code\a5b5009513\resources\app\extensions\copilot\assets\prompts\skills\agent-customization\references\agents.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 4726 | `9654233652f0c36d9ae3ed364c61c0fe072836892cbcb063dd376a09d3e99af1` | `N/A` | `N/A` | N/A |
| 20 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-7g2bar\workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST | 18 | `791b0533c7ba3f5e503ec5a71f10fc00264f8bef95da9d42c1e260c407d45d70` | `N/A` | `N/A` | N/A |
| 21 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-7NCQJ8\workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST | 18 | `791b0533c7ba3f5e503ec5a71f10fc00264f8bef95da9d42c1e260c407d45d70` | `N/A` | `N/A` | N/A |
| 22 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-7NCQJ8\write-workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST | 25 | `3550f046dbf05d3c24ddc45504f90c587f411dd95ba536f5200f7c1a2db06b65` | `N/A` | `N/A` | N/A |
| 23 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-AzwYlN\workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST | 18 | `791b0533c7ba3f5e503ec5a71f10fc00264f8bef95da9d42c1e260c407d45d70` | `N/A` | `N/A` | N/A |
| 24 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-AzwYlN\write-workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST | 25 | `3550f046dbf05d3c24ddc45504f90c587f411dd95ba536f5200f7c1a2db06b65` | `N/A` | `N/A` | N/A |
| 25 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-idzbnO\workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST | 18 | `791b0533c7ba3f5e503ec5a71f10fc00264f8bef95da9d42c1e260c407d45d70` | `N/A` | `N/A` | N/A |
| 26 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-idzbnO\write-workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST | 25 | `3550f046dbf05d3c24ddc45504f90c587f411dd95ba536f5200f7c1a2db06b65` | `N/A` | `N/A` | N/A |
| 27 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-mPz8FN\workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST | 18 | `791b0533c7ba3f5e503ec5a71f10fc00264f8bef95da9d42c1e260c407d45d70` | `N/A` | `N/A` | N/A |
| 28 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-mPz8FN\write-workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST | 25 | `3550f046dbf05d3c24ddc45504f90c587f411dd95ba536f5200f7c1a2db06b65` | `N/A` | `N/A` | N/A |
| 29 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-nYVyD4\workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST | 18 | `791b0533c7ba3f5e503ec5a71f10fc00264f8bef95da9d42c1e260c407d45d70` | `N/A` | `N/A` | N/A |
| 30 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-nYVyD4\write-workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST | 25 | `3550f046dbf05d3c24ddc45504f90c587f411dd95ba536f5200f7c1a2db06b65` | `N/A` | `N/A` | N/A |
| 31 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-O7gj3q\workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST | 18 | `791b0533c7ba3f5e503ec5a71f10fc00264f8bef95da9d42c1e260c407d45d70` | `N/A` | `N/A` | N/A |
| 32 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-O7gj3q\write-workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST | 25 | `3550f046dbf05d3c24ddc45504f90c587f411dd95ba536f5200f7c1a2db06b65` | `N/A` | `N/A` | N/A |
| 33 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-uIgOjY\workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST | 18 | `791b0533c7ba3f5e503ec5a71f10fc00264f8bef95da9d42c1e260c407d45d70` | `N/A` | `N/A` | N/A |
| 34 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-v6tgY6\workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST | 18 | `791b0533c7ba3f5e503ec5a71f10fc00264f8bef95da9d42c1e260c407d45d70` | `N/A` | `N/A` | N/A |
| 35 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-VQruys\workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST | 18 | `791b0533c7ba3f5e503ec5a71f10fc00264f8bef95da9d42c1e260c407d45d70` | `N/A` | `N/A` | N/A |
| 36 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-yZ6Wl0\workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST | 18 | `791b0533c7ba3f5e503ec5a71f10fc00264f8bef95da9d42c1e260c407d45d70` | `N/A` | `N/A` | N/A |
| 37 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-ZdDG7V\workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST | 18 | `791b0533c7ba3f5e503ec5a71f10fc00264f8bef95da9d42c1e260c407d45d70` | `N/A` | `N/A` | N/A |
| 38 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-ZdDG7V\write-workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST | 25 | `3550f046dbf05d3c24ddc45504f90c587f411dd95ba536f5200f7c1a2db06b65` | `N/A` | `N/A` | N/A |
| 39 | `C:\Users\adria\AppData\Local\Temp\codexpro-lower-agents-3vu2a3\agents.md` | BACKUP_EXAMPLE_TEST | 57 | `2489196edb43abe1c289c62a50b61bcfec1310daab1ef06378dec81d9d0119da` | `N/A` | `N/A` | N/A |
| 40 | `C:\Users\adria\AppData\Local\Temp\codexpro-lower-agents-A6FaqP\agents.md` | BACKUP_EXAMPLE_TEST | 57 | `2489196edb43abe1c289c62a50b61bcfec1310daab1ef06378dec81d9d0119da` | `N/A` | `N/A` | N/A |
| 41 | `C:\Users\adria\AppData\Local\Temp\codexpro-lower-agents-KMXqMN\agents.md` | BACKUP_EXAMPLE_TEST | 57 | `2489196edb43abe1c289c62a50b61bcfec1310daab1ef06378dec81d9d0119da` | `N/A` | `N/A` | N/A |
| 42 | `C:\Users\adria\AppData\Local\Temp\codexpro-lower-agents-kSkC9R\agents.md` | BACKUP_EXAMPLE_TEST | 57 | `2489196edb43abe1c289c62a50b61bcfec1310daab1ef06378dec81d9d0119da` | `N/A` | `N/A` | N/A |
| 43 | `C:\Users\adria\AppData\Local\Temp\codexpro-lower-agents-NdQ7vc\agents.md` | BACKUP_EXAMPLE_TEST | 57 | `2489196edb43abe1c289c62a50b61bcfec1310daab1ef06378dec81d9d0119da` | `N/A` | `N/A` | N/A |
| 44 | `C:\Users\adria\AppData\Local\Temp\codexpro-lower-agents-VJIOeB\agents.md` | BACKUP_EXAMPLE_TEST | 57 | `2489196edb43abe1c289c62a50b61bcfec1310daab1ef06378dec81d9d0119da` | `N/A` | `N/A` | N/A |
| 45 | `C:\Users\adria\AppData\Local\Temp\codexpro-lower-agents-xT8AKp\agents.md` | BACKUP_EXAMPLE_TEST | 57 | `2489196edb43abe1c289c62a50b61bcfec1310daab1ef06378dec81d9d0119da` | `N/A` | `N/A` | N/A |
| 46 | `C:\Users\adria\AppData\Local\Temp\codexpro-smoke-avPJks\AGENTS.md` | BACKUP_EXAMPLE_TEST | 37 | `17d81e09a3a42deebc6c65be665b3d42182d095f5920297756ee63f58c16d8cf` | `N/A` | `N/A` | N/A |
| 47 | `C:\Users\adria\AppData\Local\Temp\codexpro-smoke-DRkkuG\AGENTS.md` | BACKUP_EXAMPLE_TEST | 37 | `17d81e09a3a42deebc6c65be665b3d42182d095f5920297756ee63f58c16d8cf` | `N/A` | `N/A` | N/A |
| 48 | `C:\Users\adria\AppData\Local\Temp\codexpro-smoke-HuZ1FN\AGENTS.md` | BACKUP_EXAMPLE_TEST | 37 | `17d81e09a3a42deebc6c65be665b3d42182d095f5920297756ee63f58c16d8cf` | `N/A` | `N/A` | N/A |
| 49 | `C:\Users\adria\AppData\Local\Temp\codexpro-smoke-jAXgxv\AGENTS.md` | BACKUP_EXAMPLE_TEST | 37 | `17d81e09a3a42deebc6c65be665b3d42182d095f5920297756ee63f58c16d8cf` | `N/A` | `N/A` | N/A |
| 50 | `C:\Users\adria\AppData\Local\Temp\codexpro-smoke-KsUUc9\AGENTS.md` | BACKUP_EXAMPLE_TEST | 37 | `17d81e09a3a42deebc6c65be665b3d42182d095f5920297756ee63f58c16d8cf` | `N/A` | `N/A` | N/A |
| 51 | `C:\Users\adria\AppData\Local\Temp\codexpro-smoke-MeMBjV\AGENTS.md` | BACKUP_EXAMPLE_TEST | 37 | `17d81e09a3a42deebc6c65be665b3d42182d095f5920297756ee63f58c16d8cf` | `N/A` | `N/A` | N/A |
| 52 | `C:\Users\adria\AppData\Local\Temp\codexpro-smoke-se4vEt\AGENTS.md` | BACKUP_EXAMPLE_TEST | 37 | `17d81e09a3a42deebc6c65be665b3d42182d095f5920297756ee63f58c16d8cf` | `N/A` | `N/A` | N/A |
| 53 | `C:\Users\adria\AppData\Local\Temp\codexpro-smoke-tOd6U7\AGENTS.md` | BACKUP_EXAMPLE_TEST | 37 | `17d81e09a3a42deebc6c65be665b3d42182d095f5920297756ee63f58c16d8cf` | `N/A` | `N/A` | N/A |
| 54 | `C:\Users\adria\AppData\Local\Temp\codexpro-smoke-wGIWyb\AGENTS.md` | BACKUP_EXAMPLE_TEST | 37 | `17d81e09a3a42deebc6c65be665b3d42182d095f5920297756ee63f58c16d8cf` | `N/A` | `N/A` | N/A |
| 55 | `C:\Users\adria\AppData\Local\Temp\codexpro-stress-8j1DFd\AGENTS.md` | BACKUP_EXAMPLE_TEST | 36 | `eae4238f530f6cb7af8c57b0c626a12326648ea51a8f3f89980178fbbbdcd266` | `N/A` | `N/A` | N/A |
| 56 | `C:\Users\adria\AppData\Local\uv\cache\archive-v0\9rKRD7dGWdiDGS7a\litellm\proxy\_experimental\mcp_server\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 6369 | `9419ab0c5e43488449c30b768b158f0e70f80c38489b7ad132fb1a368ef9785e` | `N/A` | `N/A` | N/A |
| 57 | `C:\Users\adria\AppData\Local\uv\cache\archive-v0\-zOPV52F1mA58Kz0\litellm\proxy\_experimental\mcp_server\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 6470 | `12d316ccff1957d6e84dac9410c214754ecee82e1970fd0055aa7cb8c2767c02` | `N/A` | `N/A` | N/A |
| 58 | `C:\Users\adria\AppData\Local\uv\cache\sdists-v9\pypi\litellm\1.93.0\v6Enx0UGkUxpUaqn\src\litellm\proxy\_experimental\mcp_server\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 6369 | `9419ab0c5e43488449c30b768b158f0e70f80c38489b7ad132fb1a368ef9785e` | `N/A` | `N/A` | N/A |
| 59 | `C:\Users\adria\AppData\Local\uv\cache\sdists-v9\pypi\litellm\1.93.0\v6Enx0UGkUxpUaqn\src\litellm-rust\crates\ai-gateway\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 2744 | `6371dcf6cfc54731a83e2ebd5101224a600702aacba87c1d68c59b06fba6f1d8` | `N/A` | `N/A` | N/A |
| 60 | `C:\Users\adria\AppData\Local\uv\cache\sdists-v9\pypi\litellm\1.93.0\v6Enx0UGkUxpUaqn\src\litellm-rust\crates\ai-gateway\src\python\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 1284 | `bcb2ec317b27316c6acb1eeb69bb891dcadcfe27c2a74d93d7b40f9aef798724` | `N/A` | `N/A` | N/A |
| 61 | `C:\Users\adria\AppData\Local\uv\cache\sdists-v9\pypi\litellm\1.93.0\v6Enx0UGkUxpUaqn\src\litellm-rust\crates\ai-gateway\src\routes\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 1778 | `690128e29c35bf545e424c55192bcfa82af71131d1ccd8eff07fe43b146a0172` | `N/A` | `N/A` | N/A |
| 62 | `C:\Users\adria\AppData\Local\uv\cache\sdists-v9\pypi\litellm\1.93.0\v6Enx0UGkUxpUaqn\src\litellm-rust\crates\core\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 261 | `10444963c75c778e9ec8df2debe9e4edd506f0bf04ec30da48b53b12dc3da6a3` | `N/A` | `N/A` | N/A |
| 63 | `C:\Users\adria\AppData\Local\uv\cache\sdists-v9\pypi\litellm\1.93.0\v6Enx0UGkUxpUaqn\src\litellm-rust\crates\python-bridge\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 308 | `68beb2eff647a79481ac06e52707f9f608e011d8c5a9e383e3b4cc5cbabdd79f` | `N/A` | `N/A` | N/A |
| 64 | `C:\Users\adria\AppData\Roaming\uv\tools\headroom-ai\Lib\site-packages\litellm\proxy\_experimental\mcp_server\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 6470 | `12d316ccff1957d6e84dac9410c214754ecee82e1970fd0055aa7cb8c2767c02` | `N/A` | `N/A` | N/A |
| 65 | `C:\Users\adria\CodexTools\CodexBridgeStartup\backups\controller-20260817-211530-v2-amendment\AGENTS.md` | BACKUP_EXAMPLE_TEST | 14883 | `cf8d9b6971c149fcb760f13da6743d1a78815dfa39f817837ef26264f4282de9` | `N/A` | `N/A` | N/A |
| 66 | `C:\Users\adria\llama.cpp\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN | 8282 | `3a943ba3a8e459f9e720843f1abce6f371f6f70a44b9ea610494050ca4029f44` | `N/A` | `N/A` | N/A |
| 67 | `D:\AI_Workspace\AGENTS.md` | GLOBAL_LOCAL_AI_CONFIGURATION | 20355 | `03fb8ad36f134e063ad3be960c1b4a2b8468cbb08a975b71b64e1825caf47272` | `N/A` | `N/A` | N/A |
| 68 | `D:\AI_Workspace\odysseus\data\AGENTS.md` | STALE_OWNED | 12392 | `e9dfe77f1f6844b247afe40aaf7ca3c8118466ce82adece04d091eaaaf0151ec` | `N/A` | `N/A` | N/A |
| 69 | `D:\AI_Workspace\ornith-agent-test\AGENTS.md` | BACKUP_EXAMPLE_TEST | 138 | `e15cc129989d768ebec9d235d46a3886de1a791429d1d9de25d304bd92bd64c0` | `N/A` | `N/A` | N/A |
| 70 | `D:\Documents\Codex\Astral-Bridge\AGENTS.md` | OWNED_ACTIVE_REPOSITORY | 5391 | `df283d7010f10942fad2a2295b72195ea5a33316d2fcb3b59b5826ab19d41158` | `N/A` | `N/A` | N/A |
| 71 | `D:\Documents\Codex\HAU-USC Logistics\active\hau-usc-logistics-management-system\AGENTS.md` | OWNED_ACTIVE_REPOSITORY | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 72 | `D:\Documents\Codex\HAU-USC Logistics\archives\old-prototype\20260715\HAU_USC_Logistics_Apps_Script\AGENTS.md` | HISTORICAL_ARCHIVED_EVIDENCE | 2648 | `0ffe0fead1e111f7fe8cba4750fa687cf130806dc9cdba9e6f78b49b1aa0ecc2` | `N/A` | `N/A` | N/A |
| 73 | `D:\Documents\Codex\HAU-USC Logistics\private-config\evidence\slice-13-demo-20260716\gate-b-20260718-113245\history-a3fffb9-full\AGENTS.md` | HISTORICAL_ARCHIVED_EVIDENCE | 3622 | `b1b439b808adfaa5d54d6a1a20465f7acee9180def61675ff007fe115db7e910` | `N/A` | `N/A` | N/A |
| 74 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\design-dna-staging-2026-08-10\AGENTS.md` | OWNED_GIT_WORKTREE | 10335 | `0d64b83e92748440ff23199660e7a65400f4fac2fd18b1fa5766b2822cf8535d` | `N/A` | `N/A` | N/A |
| 75 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\playground-owner-feedback-2026-08-10\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 76 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\spec-v073-frontend-design-integration\AGENTS.md` | OWNED_GIT_WORKTREE | 8334 | `ca53d79b4d6a3fd07912f087eac26e9b8a9fb52cc88914f7224ae2caef10b150` | `N/A` | `N/A` | N/A |
| 77 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-production-execution-eb14cd81\AGENTS.md` | OWNED_GIT_WORKTREE | 16044 | `eeb436f36724e763e26def5b2dd1c8239a8177d3e58bb8ce71e7f27e77c51f3f` | `N/A` | `N/A` | N/A |
| 78 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s09-auth-reset-atomicity\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 79 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s09-lane-a\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 80 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s09-release-preflight\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 81 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s10-evidence-bb652506\AGENTS.md` | OWNED_GIT_WORKTREE | 16044 | `eeb436f36724e763e26def5b2dd1c8239a8177d3e58bb8ce71e7f27e77c51f3f` | `N/A` | `N/A` | N/A |
| 82 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s11-generator-eol\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 83 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s12-cloudflare-fresh-d1-startup-budget\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 84 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s12-internal-verification-aa083567\AGENTS.md` | OWNED_GIT_WORKTREE | 16044 | `eeb436f36724e763e26def5b2dd1c8239a8177d3e58bb8ce71e7f27e77c51f3f` | `N/A` | `N/A` | N/A |
| 85 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s12-lane-a2-access-directory\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 86 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s12-lane-a-closure\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 87 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s12-lane-a-current-ui\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 88 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s12-lane-a-mobile-topbar-gap\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 89 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s12-lane-d-denied-renderer\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 90 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s12-lane-g-generator-replacement\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 91 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s12-lane-p-revision-sync\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 92 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s12-lane-r2-request-search\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 93 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s12-lane-r-rv01-closure\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 94 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s12-lane-t-static-contract\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 95 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s12-lane-w-workspace-auth\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 96 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s12-recovery-4ded0bc2\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 97 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s12-rv01-post-review-truth\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 98 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-s12-v5-functional-closure\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 99 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v082-s06-controlled-a3477ae-20260813-2338\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 100 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v082-s06-controlled-replacement-a3477ae-20260813-2348\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 101 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v082-s06-serial-full-lf-a3477ae-20260814-0015\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 102 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v083-disabled-enablement-gate-codex\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 103 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v083-gate-a-fixture-codex\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 104 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v083-id-c-source-projection-probe-codex\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 105 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v83-idc-gate-a-audit-prep-2026-08-16\AGENTS.md` | OWNED_GIT_WORKTREE | 15741 | `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | `N/A` | `N/A` | N/A |
| 106 | `D:\Download\AGENTS.md` | STALE_OWNED | 4973 | `1744f504d6754308264d9aa7db75271e253af8a7ca39196ca8ea25e591662188` | `N/A` | `N/A` | N/A |

## Exact duplicate groups

| SHA-256 | Count | Representative path | Classification set |
|---|---:|---|---|
| `819364b3fe617b830ed28d6fd103d9b4e2745c5ba57a2c1777ad8bcbead93596` | 28 | `D:\Documents\Codex\HAU-USC Logistics\active\hau-usc-logistics-management-system\AGENTS.md` | OWNED_ACTIVE_REPOSITORY, OWNED_GIT_WORKTREE |
| `791b0533c7ba3f5e503ec5a71f10fc00264f8bef95da9d42c1e260c407d45d70` | 12 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-7g2bar\workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST |
| `17d81e09a3a42deebc6c65be665b3d42182d095f5920297756ee63f58c16d8cf` | 9 | `C:\Users\adria\AppData\Local\Temp\codexpro-smoke-avPJks\AGENTS.md` | BACKUP_EXAMPLE_TEST |
| `2489196edb43abe1c289c62a50b61bcfec1310daab1ef06378dec81d9d0119da` | 7 | `C:\Users\adria\AppData\Local\Temp\codexpro-lower-agents-3vu2a3\agents.md` | BACKUP_EXAMPLE_TEST |
| `3550f046dbf05d3c24ddc45504f90c587f411dd95ba536f5200f7c1a2db06b65` | 7 | `C:\Users\adria\AppData\Local\Temp\codexpro-controller-smoke-7NCQJ8\write-workspace\AGENTS.md` | BACKUP_EXAMPLE_TEST |
| `1948b53b13790189e85281254c899005ca22c86f4eb7b664fffdc0b52d9b10ea` | 3 | `C:\Users\adria\.codex\.tmp\bundled-marketplaces\openai-bundled.staging-d8b227ca-4295-4790-949b-ff0fa80e8057\plugins\sites\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN |
| `eeb436f36724e763e26def5b2dd1c8239a8177d3e58bb8ce71e7f27e77c51f3f` | 3 | `D:\Documents\Codex\HAU-USC Logistics\worktrees\v081-production-execution-eb14cd81\AGENTS.md` | OWNED_GIT_WORKTREE |
| `24b16178226d2f96cafd03eed01113b4b0240c9e6a6cd938a155e991b4f11034` | 2 | `C:\Users\adria\.cargo\registry\src\index.crates.io-1949cf8c6b5b557f\zerocopy-0.8.52\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN |
| `9419ab0c5e43488449c30b768b158f0e70f80c38489b7ad132fb1a368ef9785e` | 2 | `C:\Users\adria\AppData\Local\uv\cache\archive-v0\9rKRD7dGWdiDGS7a\litellm\proxy\_experimental\mcp_server\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN |
| `12d316ccff1957d6e84dac9410c214754ecee82e1970fd0055aa7cb8c2767c02` | 2 | `C:\Users\adria\AppData\Local\uv\cache\archive-v0\-zOPV52F1mA58Kz0\litellm\proxy\_experimental\mcp_server\AGENTS.md` | THIRD_PARTY_VENDOR_PACKAGE_PLUGIN |

## AGENTS-family variants

These are separate from the exact Windows-equivalent AGENTS.md count.

| # | Path | Bytes | SHA-256 |
|---:|---|---:|---|
| 1 | `C:\Users\adria\.codex\.tmp\plugins\plugins\base44\skills\base44-cli\references\agents-pull.md` | 2158 | `7377a6c2702ca3edfa408d51319cc0d0f5a1873b2f3e441a288a5a33b0ee3bc6` |
| 2 | `C:\Users\adria\.codex\.tmp\plugins\plugins\base44\skills\base44-cli\references\agents-push.md` | 5446 | `680413fb732a1236c538ec0b2fd499d8e9b40a9d307aa09ed2c16dd1a16986fa` |
| 3 | `C:\Users\adria\.codex\AGENTS.md.20260802T185953.bak` | 11282 | `2aaf2b2c4020f6243d9daea5f0f5ecbdfba2f2ef087cf4bd2e7ded8c5d9db0e1` |
| 4 | `C:\Users\adria\.codex\AGENTS.md.bak` | 11283 | `0c65ea686fa8c6bdda2815f3bce7d6c0b309bc93ffabea28d0b475b5e099fa2a` |
| 5 | `C:\Users\adria\.codex\backups\pre-multimodel-20260817-0230\AGENTS.md.pre-multimodel-20260817-0230.bak` | 12202 | `7b8eeafe50669cb794c8bc381b6ce10fe60f2df69ba00edf596df20f504ffc5b` |
| 6 | `C:\Users\adria\AppData\Roaming\npm\node_modules\codexpro\AGENTS.example.md` | 576 | `4e78de00856ee45ee8971076abf1e7e06d661387804781b0d8b42bbca07c090a` |
| 7 | `C:\Users\adria\CodexTools\CodexProSource\AGENTS.example.md` | 594 | `d18ca07cd45da683c99ec1dd2c3247a8741fa11bca87487f2ee9b3d8786203bf` |
| 8 | `C:\Users\adria\Documents\Codex\2026-08-17\codexpro-fix-chatgpt-mcp-tool-availability\work\provenance\npm-package\package\AGENTS.example.md` | 576 | `4e78de00856ee45ee8971076abf1e7e06d661387804781b0d8b42bbca07c090a` |
| 9 | `D:\Documents\Codex\GitHub\worktrees\gpt-context-vault-agents-consolidation-001\governance\agents\specs\AGENTS-CONSOLIDATION-001.md` | 11270 | `2bcbfb37b80e2ec76b40186ab393006cd3ca4f256663684a164747ac2528ab71` |
| 10 | `D:\Download\AGENTS (1).md` | 5500 | `4287f613e825debbfa7bd864a16c42ea5a20272f4bc6665061c9f21ed7c18a4f` |
| 11 | `D:\Download\AGENTS (2).md` | 6111 | `638533098e571b59a582e575a37d6f4d01e0286947f0a0048225fe0a2b06d757` |
| 12 | `D:\Download\AGENTS (3).md` | 5397 | `36927b699abce2602023e0c71a9bdc92b93b697ab8d3a16c10d9836a2d3b122d` |
| 13 | `D:\Download\AGENTS(5).md` | 9081 | `88dcfd84317c933293474e6a2c9eeb9630d37e73a2f2857bde06801cb05ef8f5` |
| 14 | `D:\Download\AGENTS_edited.md` | 20355 | `03fb8ad36f134e063ad3be960c1b4a2b8468cbb08a975b71b64e1825caf47272` |

## Stale-reference audit

A bounded deterministic reference scan was run across the Context Vault candidate, the isolated Astral Bridge candidate, the active HAU-USC Logistics repository, the live Global Codex policy, and the Odysseus governance/loader files. Generated governance evidence was treated as provenance rather than as live authority.

```text
FILES SCANNED: 718
RAW MATCHES: 15
PROVEN STALE REFERENCES AUTOMATICALLY FIXED: 0
```

| Pattern | Raw matches | Disposition |
|---|---:|---|
| `REQUIRED_MODEL: CODEX` | 8 | Two literal current-chain metadata entries are actionable but blocked; five HAU protective policy/test references intentionally document that the metadata is superseded; one Context Vault report reference is evidence. |
| `D:DownloadAGENTS.md` | 3 | Intentional inventory, audit, and disposition provenance only. |
| `D:AI_WorkspaceodysseusdataAGENTS.md` | 3 | Intentional inventory/disposition provenance only. |
| `canonical global governance policy` | 1 | Live Odysseus root claim; actionable but blocked until extension-loading/injection proof exists. |

### Actionable but blocked references

| Location | Finding | Blocker / safest next step |
|---|---|---|
| `D:DocumentsCodexHAU-USC Logisticsactivehau-usc-logistics-management-system.codexCURRENT.md` | Literal `REQUIRED_MODEL: CODEX` metadata remains. | Active HAU writer locks and unrelated dirty work block current-chain normalization. Preserve and amend only at a clean accepted HAU handoff. |
| `D:DocumentsCodexHAU-USC Logisticsactivehau-usc-logistics-management-system.codexCURRENT_TASK.md` | Literal `REQUIRED_MODEL: CODEX` metadata remains. | Same HAU blocker; do not race the active release lineage. |
| `D:AI_WorkspaceAGENTS.md` | Still claims to be the canonical global governance policy. | Current Odysseus loader injects this root only and cannot load the proposed project extension. Preserve unchanged until deterministic extension-loading proof exists. |

### Intentional references retained

- Seven Context Vault matches are inventory, rule-matrix, or consolidation-report provenance.
- Five HAU matches in `AGENTS.md`, `.codex/USAGE_POLICY.md`, and `tests/unit/codex-governance.test.js` deliberately state or test that the legacy model metadata is superseded. They are protective evidence, not stale authority.
- No `AGENTS(3).md` or `single operational entrypoint` live-authority reference was found in the final deterministic scan.
- No reference was rewritten solely because it matched a string.

## Disposition summary

- Managed synchronization is allowed only for registry targets whose gate is open.
- All 32 HAU worktree-area copies remain excluded from mass synchronization.
- All 27 third-party/vendor/package/plugin files remain excluded.
- All 39 backup/example/test files remain excluded.
- The two historical/evidence files remain immutable for this task.
- The two stale-owned files remain preserved until canonical activation, reference audit, extension-loading proof, and recovery verification pass.
- Unknown/unclassified exact files: 0.
