# Spider Swing · status
updated: 2026-07-29T03:40:00Z
phase: Phase 0.11 touch-first tuning lab and contact-rearmed Dive candidate — owner device feel gate next
health: green
kit: v1.20.2 · check: green; 63/63 game contracts green · engaged: yes
last-shipped: PR #17 candidate — grouped responsive DEBUG, independent Dive charge, and Android build 0.4.1
blockers: Phase 1 is product-gated on owner selection/rejection of a swing baseline after the Phase 0.11 device test
orders: acked= done=
⚑ needs-owner: 1 ask — playtest the Phase 0.11 Dive-reset build

⚑ OWNER-ACTION
WHAT: Playtest the PR #17 Dive-reset build and select or reject the next Phase 0 movement/course baseline.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30420061815/artifacts/8711576758 — download artifact `spider-swing-android-debug`, unzip it, and install `spider-swing-debug.apk`.
HOW: uninstall the old development app first because each CI build uses a fresh ephemeral signing key. Launch `Spider Swing Dive Reset (dev)` and confirm `BUILD 0.4.1-debug-lab-dive-reset-test`. Open DEBUG and compare the Movement, Rope, Pulls, Course, and Tools sections. Use Dive twice without an intervening upper web, then attach to a ceiling or upper obstacle and Dive again during Burst cooldown. Re-test the first floating obstacle without changing its shape.
RISK: ↩️ reversible — this replaces only the development APK and writes versioned local settings/progression. Reset Defaults restores the movement configuration; uninstalling clears local prototype progress.
WHY-IT-MATTERS: automated tests prove the separate Burst/Dive state, responsive native hit targets, deterministic movement, and exact build identity, but only a real phone can establish whether the new vertical rhythm and tuning workflow feel natural.
UNBLOCKS: selection of a Phase 0 movement baseline and a contained Phase 1 Fair Endless Slice instead of further parallel tuning branches.
VERIFIED-NEEDED: `game-quality` run 30420061825 passed 63 runtime contracts on Godot 4.7.1. Android run 30420061815 passed from source `b00007514aaad431dcfaa5b41c8ec9413a1eadba`; artifact `spider-swing-android-debug` ID `8711576758` is 56,800,048 bytes with digest `sha256:57f77723586babbe408bb6b86f987bb3e8caa622b01f9130fd943b91c58b4dcd`. Its downloaded APK is a valid 57,182,655-byte Android package with SHA-256 `2b9438829f631d3486a668b28915aa8ff9d618639d287a8f87166b9771f20db6`.
notes: The default candidate remains gravity 1120, Dive Pull 40%, and 85% automatic inward take-up. DEBUG keeps all comparisons editable. The first floating obstacle is intentionally unchanged so the device test isolates the new Dive rearm rule. The repository is temporarily public by owner choice; this PR changes no repository settings.
