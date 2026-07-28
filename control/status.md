# Spider Swing · status
updated: 2026-07-28T16:24:14Z
phase: Phase 0.7 responsive rope-actions candidate shipped — owner device feel gate next
health: green
kit: v1.20.2 · check: green; 42/42 game contracts green · engaged: yes
last-shipped: PR #12 — responsive Reel/Burst controls and verified Android build 0.2.2
blockers: Phase 1 is product-gated on owner selection/rejection of a swing baseline after the Phase 0.7 device test
orders: acked= done=
⚑ needs-owner: 1 ask — playtest the Phase 0.7 responsive-pull build

⚑ OWNER-ACTION
WHAT: Playtest the PR #12 responsive-pull build and select or reject the Phase 0 movement baseline.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30377680073 — download artifact `spider-swing-android-debug`, unzip it, and install `spider-swing-debug.apk`.
HOW: uninstall the old development app first because each CI build uses a fresh ephemeral signing key. Launch `Spider Swing Responsive Pull (dev)` and confirm `BUILD 0.2.2-responsive-pull-test`. Deliberately tap the outer edges of REEL and BURST; press Reel while falling; Burst from forward, upward, and slightly backward webs; watch/feel the acceptance feedback; then compare Balanced, Weighty, and Agile.
RISK: ↩️ reversible — this replaces only the development APK and writes only versioned local settings. Reset Defaults restores the original configuration.
WHY-IT-MATTERS: automated tests prove the exact radial/tangential math, first-tick response, hit regions, feedback wiring, resource limits, and build identity, but only a real phone can prove that the controls feel immediate and forgiving under thumb pressure.
UNBLOCKS: approval of the Phase 0 movement baseline and the transition to a validated Phase 1 Fair Endless Slice.
VERIFIED-NEEDED: `game-quality` run 30377680346 passed 42/42 runtime contracts (15 physics, 10 HUD, 8 front-end, 9 bootstrap/build) on Godot 4.7.1. Android run 30377680073 passed from source `cc0bac54e74f49ed4147978bc7a6e702c4c50804`; artifact `spider-swing-android-debug` ID `8695654625` is 56,723,433 bytes with digest `sha256:9a6a22f0cc5a7d6165740101c29691f75aa02a10b38d626a2c81dd716271776a`. The downloaded APK is a real Android package with `classes.dex`, `AndroidManifest.xml`, and compiled project data.
notes: Menno's recordings confirmed the concept is fun and encourages retries. The repository is temporarily public by owner choice; public metadata shows auto-merge off and no public ruleset, and this gameplay PR changed no repository settings.
