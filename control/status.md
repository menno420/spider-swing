# Spider Swing · status
updated: 2026-07-28T15:24:00Z
phase: Phase 0.6 anchor-pull candidate on PR #11 — extended reach, immediate Reel response, and anchor-directed Burst proven in CI
health: green
kit: v1.20.2 · check: 41/41 game contracts green; completed-card strict gate pending · engaged: yes
last-shipped: PR #10 traversal test; PR #11 gameplay commit ce9e5f7 is Android-proven and awaiting session close
blockers: Phase 1 is product-gated on owner selection/rejection of a swing baseline after the Phase 0.6 device test
orders: acked= done=
⚑ needs-owner: 2 asks — choose a main-protection option and playtest the Phase 0.6 anchor-pull build

⚑ OWNER-ACTION
WHAT: Decide how `main` should be protected on this private repository — GitHub will not let any tool set branch protection here until you pick one of three options.
WHERE: https://github.com/menno420/spider-swing/settings — either "Billing and plans" (upgrade to GitHub Pro), or "General" -> "Danger Zone" -> "Change repository visibility" (make public), or do nothing to accept the current state.
HOW: click only. Option A: upgrade the account to GitHub Pro (~$4/month), then reply and an agent applies the ruleset via API in one step. Option B: make the repository public, which enables rulesets for free — but publishes the code and the GDD. Option C: accept an unprotected `main` for now; agents keep verifying both gates by hand before merging, which is what happens today.
RISK: ↩️ reversible — a Pro upgrade can be cancelled, visibility can be flipped back (note: making a repo public and then private again does not un-publish anything already fetched), and doing nothing changes nothing.
WHY-IT-MATTERS: without protection, a bad push could land on `main` without the two gates passing, and GitHub's auto-merge cannot be armed at all — so every agent PR needs a manual merge instead of landing itself on green.
UNBLOCKS: the `substrate-gate` + `game-quality` required-check ruleset, and the kit's auto-merge-enabler, which is currently inert by design and will stay red until required contexts exist.
VERIFIED-NEEDED: attempted 2026-07-28 via the direct-PAT path on BOTH endpoints. `POST /repos/menno420/spider-swing/rulesets` -> HTTP 403 "Upgrade to GitHub Pro or make this repository public to enable this feature." and `PUT /repos/menno420/spider-swing/branches/main/protection` -> HTTP 403, identical message. The same token successfully changed every other repository setting, so this is a GitHub plan/visibility constraint on private repos, not a token, venue, or agent limitation. Recorded in docs/CAPABILITIES.md.

⚑ OWNER-ACTION
WHAT: Playtest the PR #11 anchor-pull build and select or reject the Phase 0 movement baseline.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30372450524 — download artifact `spider-swing-android-debug`, unzip it, and install `spider-swing-debug.apk`.
HOW: uninstall the old development app first because each CI build uses a fresh ephemeral signing key. Launch `Spider Swing Anchor Pull (dev)` and confirm `BUILD 0.2.1-anchor-pull-test`. Aim roughly one guide interval beyond the former limit; press Reel while descending and hold it through the arc; Burst from webs aimed forward, upward, and slightly backward; try Burst detached; then compare Balanced, Weighty, and Agile.
RISK: ↩️ reversible — this replaces only the private development APK and writes only versioned local settings. Reset Defaults restores the original configuration.
WHY-IT-MATTERS: automated tests prove the exact vector math, first-tick response, range, resource limits, and build identity, but only a real phone can prove that the new pull timing and recovery strength feel natural under thumb pressure.
UNBLOCKS: approval of the Phase 0 movement baseline and the transition to a validated Phase 1 Fair Endless Slice.
VERIFIED-NEEDED: `game-quality` run 30372449569 passed 41/41 runtime contracts (15 physics, 9 HUD, 8 front-end, 9 bootstrap/build) on Godot 4.7.1. Android run 30372450524 passed from source `ce9e5f74bebad32bf5425b5b2368da9ae02f5ee1`; artifact `spider-swing-android-debug` ID `8693506101` is 56,715,449 bytes with digest `sha256:129b61404fd4e4a7f7c4f2559b45805f82032776efb5cc5fe5b97a0cb653f94f`. The downloaded APK is a real Android package with `classes.dex` and the compiled gameplay/tutorial scripts.
notes: Menno's recordings confirmed the concept is fun and encourages retries. Phase 0.6 changes only tunable reach and the authoritative radial rope actions; obstacles and course streaming remain the same graybox test instruments.
