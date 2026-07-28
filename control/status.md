# Spider Swing · status
updated: 2026-07-28T11:54:00Z
phase: Phase 0 control-owned mobile HUD correction on PR #8 — exact APK proven, final repository close-out in progress
health: yellow
kit: v1.20.2 · check: designed session-card hold only · engaged: yes
last-shipped: Phase 0 Swing Laboratory; PR #8 replaces manual HUD hit testing with native GUI controls and visible build provenance
blockers: owner device confirmation remains required; Phase 1 is product-gated on physical control verification and swing-baseline approval
orders: acked= done=
⚑ needs-owner: 2 asks — choose a main-protection option and verify the unmistakably versioned UI2 build

⚑ OWNER-ACTION
WHAT: Decide how `main` should be protected on this private repository — GitHub will not let any tool set branch protection here until you pick one of three options.
WHERE: https://github.com/menno420/spider-swing/settings — either "Billing and plans" (upgrade to GitHub Pro), or "General" -> "Danger Zone" -> "Change repository visibility" (make public), or do nothing to accept the current state.
HOW: click only. Option A: upgrade the account to GitHub Pro (~$4/month), then reply and an agent applies the ruleset via API in one step. Option B: make the repository public, which enables rulesets for free — but publishes the code and the GDD. Option C: accept an unprotected `main` for now; agents keep verifying both gates by hand before merging, which is what happens today.
RISK: ↩️ reversible — a Pro upgrade can be cancelled, visibility can be flipped back (note: making a repo public and then private again does not un-publish anything already fetched), and doing nothing changes nothing.
WHY-IT-MATTERS: without protection, a bad push could land on `main` without the two gates passing, and GitHub's auto-merge cannot be armed at all — so every agent PR needs a manual merge instead of landing itself on green.
UNBLOCKS: the `substrate-gate` + `game-quality` required-check ruleset, and the kit's auto-merge-enabler, which is currently inert by design and will stay red until required contexts exist.
VERIFIED-NEEDED: attempted 2026-07-28 via the direct-PAT path on BOTH endpoints. `POST /repos/menno420/spider-swing/rulesets` -> HTTP 403 "Upgrade to GitHub Pro or make this repository public to enable this feature." and `PUT /repos/menno420/spider-swing/branches/main/protection` -> HTTP 403, identical message. The same token successfully changed every other repository setting this session, so this is a GitHub plan/visibility constraint on private repos, not a token, venue, or agent limitation. Recorded in docs/CAPABILITIES.md.

⚑ OWNER-ACTION
WHAT: Verify the PR #8 build, not a previous same-named APK: uninstall the current Spider Swing development app, install the new artifact, and confirm Reel and DEBUG physically respond.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30356316047 — download artifact `spider-swing-android-debug`, unzip it, and install `spider-swing-debug.apk`.
HOW: uninstall the old dev app first because every current CI run uses a fresh ephemeral signing key and Android cannot update a differently signed package. Launch the app named `Spider Swing UI2 (dev)`; confirm the lower-left HUD reads `BUILD 0.0.2-control-ui`. Tap DEBUG and confirm the panel opens. Press Reel while detached for attach-first feedback, then attach to a cyan anchor and hold Reel; it must say PULL, brighten, drain energy, and visibly shorten the rope.
RISK: ↩️ reversible — this replaces only the private development APK; it changes no save, preset, production signing, or publication state.
WHY-IT-MATTERS: the owner's second report showed PR #7 produced no observable device change. PR #8 removes manual coordinate conversion entirely, but physical Android input remains the authoritative proof.
UNBLOCKS: tuning-candidate comparison and Phase 0 baseline approval; then Phase 1 — Fair Endless Slice.
VERIFIED-NEEDED: `game-quality` run 30356316095 passed 22 runtime contracts. Android run 30356316047 passed and artifact 8686961396 was downloaded; its archive SHA-256 is `06f3d5b4b8069e0f4e391d541fa3e7509cf8922bf6de203860116fa455159fd5`. `build-info.txt` proves version `0.0.2-control-ui` from source `3322e8ca9fbac1771a761d39dcc798b3584f70f7`.
notes: Real Godot Buttons now own HUD hit regions with `MOUSE_FILTER_STOP`; web attach/release is processed in `_unhandled_input` only after GUI input. The app name and visible version make accidental old-build testing observable.
