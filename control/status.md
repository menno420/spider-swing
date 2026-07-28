# Spider Swing · status
updated: 2026-07-28T14:00:00Z
phase: Phase 0.5 traversal test complete on PR #10 — continuous ceiling, bounded stream, Burst, and static obstacle artifact proven
health: green
kit: v1.20.2 · check: pre-close game-quality green; completed-card strict gate pending · engaged: yes
last-shipped: PR #10 turns the finite anchor laboratory into an endless surface-target traversal and obstacle test with mobile-readable settings
blockers: Phase 1 is product-gated on owner selection/rejection of a swing baseline and review of graybox obstacle readability
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
WHAT: Playtest the PR #10 traversal build and select or reject the movement and obstacle test.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30365945501 — download artifact `spider-swing-android-debug`, unzip it, and install `spider-swing-debug.apk`.
HOW: uninstall the old development app first because each CI build uses a fresh ephemeral signing key. Launch `Spider Swing Traversal (dev)` and confirm `BUILD 0.2.0-traversal-test`. Verify Settings is readable and scrolls; aim between the small ceiling rings; hold the large lower-left Reel while aiming; try the lower-right Burst and double-tap shortcut; continue beyond the old finite course; and report any striped obstacle that feels unreadable or unavoidable. Compare Balanced, Weighty, and Agile and report which feels best, or what each gets wrong.
RISK: ↩️ reversible — this replaces only the private development APK and writes only versioned local settings. Reset Defaults restores the original configuration.
WHY-IT-MATTERS: automated tests prove deterministic mechanics, stream bounds, collision outcomes, navigation, and build identity, but only a real phone can prove thumb comfort, targeting clarity, and whether an avoidance route reads in time.
UNBLOCKS: approval of the Phase 0 movement baseline and the transition to a validated Phase 1 Fair Endless Slice.
VERIFIED-NEEDED: `game-quality` run 30365948791 passed 39/39 runtime contracts. Android run 30365945501 passed from source `0b3827aaad7769f64f3e2a75e5525b565879a2d2`; artifact `spider-swing-android-debug` ID `8690806549` is 56,710,502 bytes with digest `sha256:b091f4231df7d9c78053f54c91ba20b02c62578be0914fa8aed800aa4e9a3a8e`. The downloaded archive and APK both passed integrity checks and include the compiled CourseStream and gameplay/front-end scenes.
notes: Menno confirmed the prior front end works. The tutorial remains an in-engine animation so it stays synchronized with mechanics. Current obstacles are explicit graybox test instruments, not approved production content.
