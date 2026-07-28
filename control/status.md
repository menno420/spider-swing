# Spider Swing · status
updated: 2026-07-28T08:40:58Z
phase: bootstrap complete — Godot 4.7.1 shell + CI verified; Phase 0 implementation not started
health: green
kit: v1.20.2 · check: green · engaged: yes
last-shipped: founding bootstrap PR #1 (Substrate v1.20.2, Godot 4.7.1 shell, verify tooling, CI, ADRs)
blockers: none
orders: acked= done=
⚑ needs-owner: 1 ask — main is unprotected (see the OWNER-ACTION block below)

⚑ OWNER-ACTION
WHAT: Decide how `main` should be protected on this private repository — GitHub will not let any tool set branch protection here until you pick one of three options.
WHERE: https://github.com/menno420/spider-swing/settings — either "Billing and plans" (upgrade to GitHub Pro), or "General" -> "Danger Zone" -> "Change repository visibility" (make public), or do nothing to accept the current state.
HOW: click only. Option A: upgrade the account to GitHub Pro (~$4/month), then reply and an agent applies the ruleset via API in one step. Option B: make the repository public, which enables rulesets for free — but publishes the code and the GDD. Option C: accept an unprotected `main` for now; agents keep verifying both gates by hand before merging, which is what happens today.
RISK: ↩️ reversible — a Pro upgrade can be cancelled, visibility can be flipped back (note: making a repo public and then private again does not un-publish anything already fetched), and doing nothing changes nothing.
WHY-IT-MATTERS: without protection, a bad push could land on `main` without the two gates passing, and GitHub's auto-merge cannot be armed at all — so every agent PR needs a manual merge instead of landing itself on green.
UNBLOCKS: the `substrate-gate` + `game-quality` required-check ruleset, and the kit's auto-merge-enabler, which is currently inert by design and will stay red until required contexts exist.
VERIFIED-NEEDED: attempted 2026-07-28 via the direct-PAT path on BOTH endpoints. `POST /repos/menno420/spider-swing/rulesets` -> HTTP 403 "Upgrade to GitHub Pro or make this repository public to enable this feature." and `PUT /repos/menno420/spider-swing/branches/main/protection` -> HTTP 403, identical message. The same token successfully changed every other repository setting this session (squash-only merges, delete-branch-on-merge, labels, milestones), so this is a GitHub plan/visibility constraint on private repos, not a token, venue, or agent limitation. Recorded in docs/CAPABILITIES.md.
notes: Phase 0 issue #2 open and scoped. No swing physics implemented on purpose. No production signing, Play publishing, iOS runner, analytics, ads, cloud save, or store SDK. android-debug first runs on the merge commit; APK proof appended to the founding session card after merge.
