# Spider Swing · status
updated: 2026-07-29T11:20:00Z
phase: Phase 0.14 obstacle-aware fair corridors — owner device feel gate next
health: green
kit: v1.20.2 · check: green; 75/75 game contracts green · engaged: yes
last-shipped: PR #20 candidate — protected early rails and obstacle-aware route plans
blockers: Phase 1 is product-gated on owner selection/rejection of a swing baseline after the Phase 0.14 device test
orders: acked= done=
⚑ needs-owner: 1 ask — playtest the Phase 0.14 fair-corridor build

⚑ OWNER-ACTION
WHAT: Playtest the PR #20 fair-corridor build and select or reject the next Phase 0 movement/course baseline.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30447006513/artifacts/8721864851 — download artifact `spider-swing-android-debug`, unzip it, and install `spider-swing-debug.apk`.
HOW: uninstall the old development app first because each CI build uses a fresh ephemeral signing key. Launch `Spider Swing Fair Corridors (dev)` and confirm `BUILD 0.6.1-fair-corridor-test`. Check that rails never pinch toward obstacles before 2000 m, follow the fly-guided high/low/centre routes, and compare later rail-only narrow passages. DEBUG → Routes → `Inward rails begin` changes the protected distance.
RISK: ↩️ reversible — this replaces only the development APK and writes versioned local settings/progression. Reset Defaults restores the movement configuration; uninstalling clears local prototype progress.
WHY-IT-MATTERS: automated tests prove the protected-distance rule, obstacle clearance, route guidance, slow exact pace curve, and build identity, but only a real phone can establish whether the resulting passages feel fair.
UNBLOCKS: selection of a Phase 0 movement baseline and a contained Phase 1 Fair Endless Slice instead of further parallel tuning branches.
VERIFIED-NEEDED: `game-quality` run 30447006504 passed all 75 runtime contracts on Godot 4.7.1 at gameplay source `b700c61eaa1c427005b1e957cb708dc58e56390f`. Android run 30447006513 passed; artifact `spider-swing-android-debug` ID `8721864851` is 56,858,997 bytes with digest `sha256:53f7da38c36856e6f559731eb9a8c099d90247f5141c51c8cec7d44edd237c85`. Its downloaded 57,240,170-byte APK passed archive verification with SHA-256 `ab4727e70deee2bd041e1c6038968e67d998587ee76002a9c4d7e061b4774098`.
notes: Defaults are gravity 1120, Dive Pull 40%, 85% automatic inward take-up, lethal shaped rails, no inward rail movement before 2000 m, and maximum pace at 5000 m. DEBUG keeps every unsettled value editable. Later tight routes are rail-only. The repository is temporarily public by owner choice; PR #20 changes no repository settings.
