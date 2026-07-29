# Spider Swing · status
updated: 2026-07-29T15:04:00Z
phase: Phase 0.17 traversable split root gate — owner device route/readability gate next
health: green
kit: v1.20.2 · check: designed born-red hold pending close; 77/77 game contracts green · engaged: yes
last-shipped: PR #22; PR #23 candidate verified — fly-advertised root gates are open in the movement plane
blockers: Phase 1 and final production-art direction remain product-gated on owner device playtesting
orders: acked= done=
⚑ needs-owner: 1 ask — play the split-root route candidate on device

⚑ OWNER-ACTION
WHAT: Confirm that every fly trail through an Ancient Forest root gate now leads through a genuinely usable opening.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30463832706/artifacts/8728752470 — download artifact `spider-swing-android-debug`, unzip it, and install `spider-swing-debug.apk`.
HOW: uninstall the old development app first because each CI build uses a fresh ephemeral signing key. Launch `Spider Swing Split Gate (dev)` and confirm `BUILD 0.8.1-split-gate-test`. Follow the horizontal fly line through several split root gates. In Course Lab, set GATE in multiple slots and test the minimum, default, and maximum GATE OPENING values. Turn on DEBUG once to confirm each visible upper/lower root arc follows its exact lethal collision overlay and the central route has no invisible side wall.
RISK: ↩️ reversible — this replaces only the development APK. The former closed-ring texture and geometry remain recoverable from PR #22; no spider physics, pace, rewards, saved progression, gate frequency, or unrelated obstacle changed.
WHY-IT-MATTERS: a collectible line is a route promise. The previous closed ring had a visible centre but could not be entered from either side in the 2D movement plane, so following the flies caused an unavoidable death.
UNBLOCKS: approval of the split-root gate as an honest Ancient Forest obstacle and continued finished-art work on the next small asset set.
VERIFIED-NEEDED: `game-quality` run 30463832533 passed all 77 contracts on Godot 4.7.1 at source `5e11740ccd249b5754114443316fa64207490de5`. Android run 30463832706 passed; artifact `spider-swing-android-debug` ID `8728752470` is 58,590,815 bytes with digest `sha256:7702d3245b236bb19eccc1a9a3e10a79d613bf0e4b6915c54d3f2a8abd154fd4`. The preceding gameplay-identical Android run 30463570678 was downloaded: its 58,979,706-byte APK passed archive verification with SHA-256 `670e78776eb7596a5c81328722ea08be655ed592d637de6df18f236a51ac0527`, and `build-info.txt` proved the split-gate build identity and source.
notes: The gate is now two disconnected upper/lower authoritative polygons and two matching regions from one 385×512 lossless alpha asset. A Classic-sized clearance sweep crosses the complete fly route without meeting roots, floor, or ceiling at every supported GATE OPENING value (80%, 112%, and 140%). Normal play keeps outlines hidden; DEBUG restores exact overlays. The verifier now treats Godot parse/script diagnostics as fatal even if Godot exits 0 and enforces the exact 77-check count. The repository is temporarily public by owner choice; PR #23 changes no repository settings.
