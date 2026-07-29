# Spider Swing · status
updated: 2026-07-29T12:22:00Z
phase: Phase 0.15 environment-theme comparison — owner device art/readability gate next
health: green
kit: v1.20.2 · check: green; 76/76 game contracts green · engaged: yes
last-shipped: PR #21 candidate — four generated environment packs over one collision silhouette
blockers: Phase 1 and production-art direction remain product-gated on owner device playtesting
orders: acked= done=
⚑ needs-owner: 1 ask — compare the four Phase 0.15 environment looks on device

⚑ OWNER-ACTION
WHAT: Play the PR #21 environment-theme build and compare readability, atmosphere, and collision clarity across all five looks.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30451065009/artifacts/8723522456 — download artifact `spider-swing-android-debug`, unzip it, and install `spider-swing-debug.apk`.
HOW: uninstall the old development app first because each CI build uses a fresh ephemeral signing key. Launch `Spider Swing Environment Themes (dev)` and confirm `BUILD 0.7.0-environment-themes-test`. Start Play, open DEBUG → LOOK, and compare Ancient Forest, Mossy Ravine, Greenhouse, Reclaimed Attic, and Graybox on the same routes. Check whether lethal rail edges remain obvious at speed, whether material detail competes with the spider/web, and which look best supports the realistic direction.
RISK: ↩️ reversible — this replaces only the development APK. Theme choice is presentation-only and per run; Graybox remains one tap away, and no physics, collision, difficulty, settings schema, or progression data changed.
WHY-IT-MATTERS: automated tests prove all four assets load and every selector preserves authoritative geometry, but only a real phone can establish whether the textures remain legible and convincing in motion.
UNBLOCKS: selection of a visual baseline for deeper environment art, plus the existing owner choice of a Phase 0 movement/course baseline before a contained Phase 1 Fair Endless Slice.
VERIFIED-NEEDED: `game-quality` run 30451065223 passed all 76 runtime contracts on Godot 4.7.1 at source `402997b6362e46c9002aa6001c7b3f9f28cbb16a`. Android run 30451065009 passed; artifact `spider-swing-android-debug` ID `8723522456` is 57,651,810 bytes with digest `sha256:d74b40e6a2ff92cbb7457bbf982c6212e087506e78c13ba8b19ac13990744926`. Its downloaded 58,035,981-byte APK passed archive verification with SHA-256 `0e8689f112068f2ae4b0d763472d40c0bc284613b424f6113e43421f652131bf`.
notes: Ancient Forest is the default per-run comparison look. Four generated prototype tiles total about 136 KiB on disk; world-space UVs cover the exact course polygons. Defaults remain gravity 1120, Dive Pull 40%, 85% automatic inward take-up, lethal shaped rails, no inward rail movement before 2000 m, and maximum pace at 5000 m. DEBUG keeps every unsettled gameplay value editable. The repository is temporarily public by owner choice; PR #21 changes no repository settings.
