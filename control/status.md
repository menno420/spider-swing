# Spider Swing · status
updated: 2026-07-29T10:42:00Z
phase: Phase 0.13 gradual progression and bounded impact recovery — owner device feel gate next
health: green
kit: v1.20.2 · check: green; 74/74 game contracts green · engaged: yes
last-shipped: PR #19 — 5000 m pace ramp, shaped lethal rails, deep upgrades, and Springtail recovery
blockers: Phase 1 is product-gated on owner selection/rejection of a swing baseline after the Phase 0.13 device test
orders: acked= done=
⚑ needs-owner: 1 ask — playtest the Phase 0.13 gradual-progression build

⚑ OWNER-ACTION
WHAT: Playtest the PR #19 gradual-progression build and select or reject the next Phase 0 movement/course baseline.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30444418230/artifacts/8720817780 — download artifact `spider-swing-android-debug`, unzip it, and install `spider-swing-debug.apk`.
HOW: uninstall the old development app first because each CI build uses a fresh ephemeral signing key. Launch `Spider Swing Gradual Progression (dev)` and confirm `BUILD 0.6.0-gradual-progression-test`. Compare full-speed distances around 3000/5000/6500 m, test the weaker Classic Reel and Burst plus minimum-travel upgrades, follow the shaped high/low rail routes, and spend/rearm Springtail's one moderate-impact shell.
RISK: ↩️ reversible — this replaces only the development APK and writes versioned local settings/progression. Reset Defaults restores the movement configuration; uninstalling clears local prototype progress.
WHY-IT-MATTERS: automated tests prove the slow exact pace curve, rail geometry, upgrade resolution, bounded impact state, and build identity, but only a real phone can establish whether the learning curve and recoveries feel fair.
UNBLOCKS: selection of a Phase 0 movement baseline and a contained Phase 1 Fair Endless Slice instead of further parallel tuning branches.
VERIFIED-NEEDED: `game-quality` run 30444418170 passed all 74 runtime contracts on Godot 4.7.1 at gameplay source `bc582e25a2a2fd7d6da18ed2cf127cc568b834ca`. Android run 30444418230 passed; artifact `spider-swing-android-debug` ID `8720817780` is 56,859,911 bytes with digest `sha256:ba83d0a7c1f6cd64706da933f3d6e08af10459fcf6d1f28c231228a3842863ef`, and its download endpoint was exercised successfully.
notes: Defaults are gravity 1120, Dive Pull 40%, 85% automatic inward take-up, lethal shaped rails, and maximum pace at 5000 m. DEBUG keeps every unsettled value editable. Springtail survives only one moderate free-flight rail impact before an upper web is required; obstacles, hard hits, pull collisions, and a second un-rearmed hit remain lethal. The repository is temporarily public by owner choice; PR #19 changes no repository settings.
