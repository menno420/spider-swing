# Spider Swing · status
updated: 2026-07-28T11:25:58Z
phase: Phase 0 mobile HUD correction complete on PR #7 — green candidate awaiting merge and owner device confirmation
health: green
kit: v1.20.2 · check: designed session-card hold only · engaged: yes
last-shipped: Phase 0 Swing Laboratory; PR #7 fixes Android Reel/DEBUG hit regions with 21 green runtime contracts
blockers: no technical blockers; Phase 1 remains product-gated on owner control verification and swing-baseline approval
orders: acked= done=
⚑ needs-owner: 2 asks — choose a main-protection option and verify the repaired Reel/DEBUG controls on the replacement APK

⚑ OWNER-ACTION
WHAT: Decide how `main` should be protected on this private repository — GitHub will not let any tool set branch protection here until you pick one of three options.
WHERE: https://github.com/menno420/spider-swing/settings — either "Billing and plans" (upgrade to GitHub Pro), or "General" -> "Danger Zone" -> "Change repository visibility" (make public), or do nothing to accept the current state.
HOW: click only. Option A: upgrade the account to GitHub Pro (~$4/month), then reply and an agent applies the ruleset via API in one step. Option B: make the repository public, which enables rulesets for free — but publishes the code and the GDD. Option C: accept an unprotected `main` for now; agents keep verifying both gates by hand before merging, which is what happens today.
RISK: ↩️ reversible — a Pro upgrade can be cancelled, visibility can be flipped back (note: making a repo public and then private again does not un-publish anything already fetched), and doing nothing changes nothing.
WHY-IT-MATTERS: without protection, a bad push could land on `main` without the two gates passing, and GitHub's auto-merge cannot be armed at all — so every agent PR needs a manual merge instead of landing itself on green.
UNBLOCKS: the `substrate-gate` + `game-quality` required-check ruleset, and the kit's auto-merge-enabler, which is currently inert by design and will stay red until required contexts exist.
VERIFIED-NEEDED: attempted 2026-07-28 via the direct-PAT path on BOTH endpoints. `POST /repos/menno420/spider-swing/rulesets` -> HTTP 403 "Upgrade to GitHub Pro or make this repository public to enable this feature." and `PUT /repos/menno420/spider-swing/branches/main/protection` -> HTTP 403, identical message. The same token successfully changed every other repository setting this session (squash-only merges, delete-branch-on-merge, labels, milestones), so this is a GitHub plan/visibility constraint on private repos, not a token, venue, or agent limitation. Recorded in docs/CAPABILITIES.md.

⚑ OWNER-ACTION
WHAT: Install the replacement Android build from PR #7, verify Reel and DEBUG now respond, then approve a Phase 0 tuning baseline or request concrete changes.
WHERE: https://github.com/menno420/spider-swing/actions/workflows/android-debug.yml — open the successful run created by the PR #7 merge, download artifact `spider-swing-android-debug`, unzip it, and install `spider-swing-debug.apk`.
HOW: first tap DEBUG and confirm the lab panel opens. Press Reel while detached and confirm the yellow attach-first message. Then attach to a cyan anchor, hold Reel, and confirm the button says PULL, brightens, drains energy, and visibly shortens the rope. Finally compare `balanced_candidate`, `weighty_candidate`, and `agile_candidate`, then report your preferred baseline and any attach delay, lost momentum, Reel teleport, or unfair boundary death.
RISK: ↩️ reversible — this changes only the development APK; no preset is declared the baseline, and no save, production signing, or published record is affected.
WHY-IT-MATTERS: the first 1040×480 phone recording exposed a physical-screen/logical-canvas mismatch. CI now proves the recorded coordinates, but only a real device can confirm touch ergonomics and whether Reel feels useful.
UNBLOCKS: Phase 1 — Fair Endless Slice, including reusable biome backgrounds, obstacle chunk families, flies, score, death/results, and sub-two-second restart.
VERIFIED-NEEDED: `game-quality` passes 21 runtime checks, including nine physics contracts and four mobile HUD coordinate regressions. The owner must confirm the repaired physical controls and choose or reject a tuning candidate.
notes: PR #7 converts the visible physical screen size through Godot's inverse stretch basis before evaluating shared HUD rectangles, adds detached-Reel feedback and a strong attached state, and changes no physics constants, presets, frozen GDD bytes, or Phase 1 content.
