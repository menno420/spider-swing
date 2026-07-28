# Spider Swing · status
updated: 2026-07-28T13:02:56Z
phase: Front-end menu, tutorial, and settings complete on PR #9 — exact Android artifact proven and ready to land
health: green
kit: v1.20.2 · check: final completed-card gates pending · engaged: yes
last-shipped: PR #9 opens on Home, teaches the complete control loop, persists real settings, and returns cleanly from gameplay to Menu
blockers: Phase 1 is product-gated only on owner playtesting and selection or rejection of a swing-physics baseline
orders: acked= done=
⚑ needs-owner: 2 asks — choose a main-protection option and verify the front-end build while comparing the three swing candidates

⚑ OWNER-ACTION
WHAT: Decide how `main` should be protected on this private repository — GitHub will not let any tool set branch protection here until you pick one of three options.
WHERE: https://github.com/menno420/spider-swing/settings — either "Billing and plans" (upgrade to GitHub Pro), or "General" -> "Danger Zone" -> "Change repository visibility" (make public), or do nothing to accept the current state.
HOW: click only. Option A: upgrade the account to GitHub Pro (~$4/month), then reply and an agent applies the ruleset via API in one step. Option B: make the repository public, which enables rulesets for free — but publishes the code and the GDD. Option C: accept an unprotected `main` for now; agents keep verifying both gates by hand before merging, which is what happens today.
RISK: ↩️ reversible — a Pro upgrade can be cancelled, visibility can be flipped back (note: making a repo public and then private again does not un-publish anything already fetched), and doing nothing changes nothing.
WHY-IT-MATTERS: without protection, a bad push could land on `main` without the two gates passing, and GitHub's auto-merge cannot be armed at all — so every agent PR needs a manual merge instead of landing itself on green.
UNBLOCKS: the `substrate-gate` + `game-quality` required-check ruleset, and the kit's auto-merge-enabler, which is currently inert by design and will stay red until required contexts exist.
VERIFIED-NEEDED: attempted 2026-07-28 via the direct-PAT path on BOTH endpoints. `POST /repos/menno420/spider-swing/rulesets` -> HTTP 403 "Upgrade to GitHub Pro or make this repository public to enable this feature." and `PUT /repos/menno420/spider-swing/branches/main/protection` -> HTTP 403, identical message. The same token successfully changed every other repository setting, so this is a GitHub plan/visibility constraint on private repos, not a token, venue, or agent limitation. Recorded in docs/CAPABILITIES.md.

⚑ OWNER-ACTION
WHAT: Playtest the PR #9 front-end build and select or reject a Phase 0 swing candidate.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30361449955 — download artifact `spider-swing-android-debug`, unzip it, and install `spider-swing-debug.apk`.
HOW: uninstall the old development app first because each current CI build uses a fresh ephemeral signing key. Launch `Spider Swing Menu (dev)`. Confirm Home appears before gameplay; walk through all five animated Tutorial pages; change Settings, start a run, return through MENU, relaunch the app, and confirm the settings persisted. Compare Balanced, Weighty, and Agile and report which feels best, or what each gets wrong.
RISK: ↩️ reversible — this replaces only the private development APK and writes only versioned local settings. Reset Defaults restores the original configuration.
WHY-IT-MATTERS: automated tests prove navigation, persistence, scene lifecycle, and build identity, but only a real device can prove touch comfort, tutorial clarity, and which swing candidate feels right.
UNBLOCKS: approval of the Phase 0 physics baseline and Phase 1 — Fair Endless Slice.
VERIFIED-NEEDED: `game-quality` run 30361453579 passed 31/31 runtime contracts, including a real settings filesystem round-trip. Android run 30361449955 passed from source `debc6a3f77caea5f0ee5cd014732e461dd4555f7`; artifact `spider-swing-android-debug` ID `8688986336` is 56,692,335 bytes with digest `sha256:2e085948033f73684d5c3b9d77624f540892c5dd2ee0d420cbc5b06d729e155b`.
notes: Menno confirmed the PR #8 Reel and DEBUG controls work on Android. The obsolete control-verification ask is closed. The tutorial uses an in-engine animation rather than a prerecorded video so it stays synchronized with gameplay and avoids a large stale binary asset.
