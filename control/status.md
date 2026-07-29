# Spider Swing · status
updated: 2026-07-29T19:39:02Z
phase: Phase 0.21 living Ancient Forest depth — owner device art/feel gate next
health: green
kit: v1.20.2 · check: final completed-status flip pending; 82/82 game contracts green · engaged: yes
last-shipped: PR #26; PR #27 candidate verified — continuous rails, growth sockets, forest depth, and curated pattern variety
blockers: Phase 1 and final production-art direction remain product-gated on owner device playtesting
orders: acked= done=
⚑ needs-owner: 1 ask — inspect the living forest candidate on device

⚑ OWNER-ACTION
WHAT: Confirm that Ancient Forest now reads as one living, navigable environment and that its restrained difficulty increase still feels fair.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30485133800/artifacts/8737309320 — download artifact `spider-swing-android-debug`, unzip it, and install `spider-swing-debug.apk`.
HOW: uninstall the previous development app first because each CI build uses a fresh ephemeral signing key. Launch `Spider Swing Living Forest (dev)` and confirm `BUILD 0.9.0-living-forest-test`. Watch ceiling/floor profile changes for missing bark; inspect upper/lower hazards for visible gaps; and play past 2000 m to compare stumps, paired patterns, and predictable tight rails. Confirm that the layered realistic background never hides the spider, flies, web, or lethal silhouettes. Turn on DEBUG → OVERLAYS once to confirm the hidden collision outlines still match the visible growth.
RISK: ↩️ reversible — this replaces only the development APK. All earlier art and course selection remain recoverable from git history. Swing physics, the broad passage opening, rewards, saves, the 1000 m runway, and the 2000 m inward-rail protection did not change.
WHY-IT-MATTERS: continuous material, believable attachment, environmental depth, and varied natural silhouettes are the largest remaining differences between the cohesive prototype and the intended finished forest.
UNBLOCKS: approval of this Ancient Forest art direction and the modest distance-banded challenge progression.
VERIFIED-NEEDED: `game-quality` run 30485134026 passed all 82 contracts on Godot 4.7.1 at source `06a4c65aeb87b4d47a54423f9cd56ce87dcaaba5`. Android run 30485133800 passed; artifact `spider-swing-android-debug` ID `8737309320` is 61,305,243 bytes with digest `sha256:298f4733a665863f348af041c67b4c2ba6d4258e9705864fc0ebecba4d4cf33f`. The downloaded ZIP matched that digest and passed archive verification; its 61,704,954-byte APK passed archive verification with SHA-256 `90294c3b51a1aebe7b2227ea720573d2b2888443d6bdcf4686b60ab495e45eb8`, and `build-info.txt` proves the living-forest build identity and source.
notes: One world-anchored bark texture now spans each rail through contour and chunk seams. Root-and-moss sockets cover every wall-grown join, and a broken-stump asset adds a distinct natural silhouette. Three subdued parallax depths replace the abstract circles. Deterministic distance bands prevent immediate repeats, grow small hazards by only 6–12% after the runway, delay paired patterns until 2000 m, and keep tight rails predictable. Normal play still hides outlines and web guides until DEBUG → OVERLAYS enables them.
