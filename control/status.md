# Spider Swing · status
updated: 2026-07-29T17:51:15Z
phase: Phase 0.20 cohesive Ancient Forest composition — owner device continuity gate next
health: green
kit: v1.20.2 · check: designed born-red hold pending close; 80/80 game contracts green · engaged: yes
last-shipped: PR #25; PR #26 candidate verified — wall-grown hazards and broad passages use one continuous forest grammar
blockers: Phase 1 and final production-art direction remain product-gated on owner device playtesting
orders: acked= done=
⚑ needs-owner: 1 ask — inspect the cohesive forest candidate on device

⚑ OWNER-ACTION
WHAT: Confirm that Ancient Forest hazards now read as growth from one continuous ceiling/floor environment.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30476965336/artifacts/8734021620 — download artifact `spider-swing-android-debug`, unzip it, and install `spider-swing-debug.apk`.
HOW: uninstall the previous development app first because each CI build uses a fresh ephemeral signing key. Launch `Spider Swing Cohesive Forest (dev)` and confirm `BUILD 0.8.4-cohesive-forest-test`. Play until several upper/lower brambles and broad passages appear. Check that each hazard enters behind the textured branch rail without a transparent gap and that broad passages look like natural upper/lower growth rather than two distorted semicircles. Turn on DEBUG → OVERLAYS once to confirm the hidden collision outlines still match the visible lethal growth.
RISK: ↩️ reversible — this replaces only the development APK. The retired split-root texture and all prior composition remain recoverable from git history; no course geometry, clearance, physics, pace, rewards, or saved progression changed.
WHY-IT-MATTERS: independent transparent sprites only feel like a finished biome when their attachment points disappear into the environment; distorted floating gate halves break both realism and obstacle readability.
UNBLOCKS: approval of this Ancient Forest composition seam and focused work on the next finished environmental asset.
VERIFIED-NEEDED: `game-quality` run 30476965313 passed all 80 contracts on Godot 4.7.1 at source `32cb11459d4be05b180c736316b8ef5cd27bda9d`. Android run 30476965336 passed; artifact `spider-swing-android-debug` ID `8734021620` is 58,421,464 bytes with digest `sha256:c46b101fc33200108d82fd10510a75f29ed431ede15c383783f5d2dc19ebbc68`. The downloaded ZIP matched that digest and passed archive verification; its 58,807,429-byte APK passed archive verification with SHA-256 `91c99a6cd151db64ac99d504e240f7ae5f3c877417448f5b324fbf254841d19c`, and `build-info.txt` proves the cohesive-forest build identity and source.
notes: Every Ancient Forest obstacle now overlaps behind its branch rail, and the rail is redrawn above the join so transparent source padding cannot expose a seam. Texture placement uses aspect-preserving source cropping rather than non-uniform stretching. The special split-circle draw path and obsolete root-gate runtime texture were removed; broad passages reuse the same natural upper/lower bramble grammar as the environment. Missing textures retain the honest geometry fallback, while normal play still hides outlines and web guides until DEBUG → OVERLAYS enables them.
