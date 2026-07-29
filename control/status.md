# Spider Swing · status
updated: 2026-07-29T14:06:00Z
phase: Phase 0.16 finished Ancient Forest slice — owner device art/readability gate next
health: green
kit: v1.20.2 · check: green; 76/76 game contracts green · engaged: yes
last-shipped: PR #22 verified candidate — natural forest boundaries, hazards, Classic spider, and flies
blockers: Phase 1 and final production-art direction remain product-gated on owner device playtesting
orders: acked= done=
⚑ needs-owner: 1 ask — play the finished Ancient Forest candidate on device

⚑ OWNER-ACTION
WHAT: Play the PR #22 forest-art build and judge whether the first finished asset set is genuinely usable in motion.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30458979638/artifacts/8726773191 — download artifact `spider-swing-android-debug`, unzip it, and install `spider-swing-debug.apk`.
HOW: uninstall the old development app first because each CI build uses a fresh ephemeral signing key. Launch `Spider Swing Forest Art (dev)` and confirm `BUILD 0.8.0-forest-art-test`. Play Ancient Forest with the nearly upgraded Classic Garden Spider. Check branch joins along shaped floors and ceilings, whether brambles/vines visibly match their lethal regions, whether the hollow root-gate opening feels honest, and whether the Classic spider and golden flies stay readable at speed. Turn on DEBUG once to compare the exact collision overlays.
RISK: ↩️ reversible — this replaces only the development APK. Ancient Forest art is presentation-only; Graybox and the three comparison packs remain available, and no physics, collision, route width, difficulty, settings schema, or progression data changed.
WHY-IT-MATTERS: automated tests prove every asset imports and every theme selection preserves authoritative geometry, but only a real phone can establish seam quality, motion readability, and whether realistic detail competes with the web and route.
UNBLOCKS: approval or focused revision of this forest visual grammar before equally deliberate art is made for other biomes and spider profiles.
VERIFIED-NEEDED: `game-quality` run 30458975297 passed all 76 runtime contracts on Godot 4.7.1 at source `8aaa517823239a3d80db94d14c72eab12ad0219d`. Android run 30458979638 passed; artifact `spider-swing-android-debug` ID `8726773191` is 58,679,746 bytes with digest `sha256:c3e0c2c94cacec5f0315c87ba7320decf55a39a61fdb166a5eba2288aebf1870`. Its 59,065,710-byte APK passed archive verification with SHA-256 `f045f1ab5b3af460c77b256502c73338fcfbcf8d3d5b0b713acee98228e709e7`.
notes: The six alpha runtime assets total about 1.3 MiB and use lossless 2D texture import. Ancient Forest removes graphic outlines during normal play, keeps exact DEBUG overlays, groups the existing four gate polygons under one hollow root visual, and backs obstacle transparency with a dark collision shadow. Defaults remain gravity 1120, Dive Pull 40%, 85% automatic inward take-up, lethal shaped rails, no inward rail movement before 2000 m, and maximum pace at 5000 m. The repository is temporarily public by owner choice; PR #22 changes no repository settings.
