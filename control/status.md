# Spider Swing · status
updated: 2026-07-28T21:53:37Z
phase: Phase 0.10 configurable gameplay-foundation candidate — owner device feel gate next
health: green
kit: v1.20.2 · check: green; 59/59 game contracts green · engaged: yes
last-shipped: PR #16 candidate — configurable take-up, paced course, flies, Burst Frenzy, cosmetic milestones, and Android build 0.4.0
blockers: Phase 1 is product-gated on owner selection/rejection of a swing baseline after the Phase 0.10 device test
orders: acked= done=
⚑ needs-owner: 1 ask — playtest the Phase 0.10 gameplay-foundation build

⚑ OWNER-ACTION
WHAT: Playtest the PR #16 gameplay-foundation build and select or reject the next Phase 0 movement/course baseline.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30402293330/artifacts/8705188365 — download artifact `spider-swing-android-debug`, unzip it, and install `spider-swing-debug.apk`.
HOW: uninstall the old development app first because each CI build uses a fresh ephemeral signing key. Launch `Spider Swing Gameplay Foundation (dev)` and confirm `BUILD 0.4.0-gameplay-foundation-test`. Compare Dive Pull around 35/40/45%; automatic take-up off versus partial retention; safe, lethal, and hidden rails; the first 1000 m learning runway; later organic obstacles; fly trails; and Burst Frenzy.
RISK: ↩️ reversible — this replaces only the development APK and writes versioned local settings/progression. Reset Defaults restores the movement configuration; uninstalling clears local prototype progress.
WHY-IT-MATTERS: automated tests prove the exact pull/take-up math, recovery input, paced deterministic stream, pickups, idempotent persistence, debug controls, and build identity, but only a real phone can establish whether the new vertical control and route pacing feel natural.
UNBLOCKS: selection of a Phase 0 movement baseline and a contained Phase 1 Fair Endless Slice instead of further parallel tuning branches.
VERIFIED-NEEDED: `game-quality` run 30402293219 passed 59 runtime contracts on Godot 4.7.1. Android run 30402293330 passed from source `9050ea46d9894f6bb8198a6ee5a454e04e39f62a`; artifact `spider-swing-android-debug` ID `8705188365` is 56,779,277 bytes with digest `sha256:bc87ecdf2814b7a7cf887d0b727416d748f18c9a02a890cd218df37c9b3be61b`. Its downloaded APK is a valid 57,162,004-byte Android package with SHA-256 `5199c5c43562123f345da3833fcdc247a216965e21529abb2d4ffa4801982cfa`.
notes: The default candidate uses gravity 1120, Dive Pull 40%, and 85% automatic inward take-up. Debug keeps the approved comparisons adjustable. Flies, Burst Frenzy, and two palette milestones are intentionally small foundations, not a finalized economy. The repository is temporarily public by owner choice; this PR changes no repository settings.
