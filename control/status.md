# Spider Swing · status
updated: 2026-08-05T00:40:23Z
phase: earned speed — release-quality slice at PR #97 closeout; drive → 0 is next
health: implementation 33cf084 · build 0.25.0 · exact Godot 4.7.1 and 184/184 contracts green · strict gate on designed born-red hold until final flip
kit: v1.20.2 · check: designed hold · engaged: yes
last-shipped: PR #96 specifies earned speed and the bird; PR #97 is the verified release-quality candidate
blockers: none; drive and bird are deliberately unchanged in this slice
orders: acked=release-quality done=release-quality
⚑ needs-owner: nonblocking OQ-16 verdict on earned-release feel; no recording

⚑ OWNER-ACTION
WHAT: Play build `0.25.0-earned-release-playtest` and say whether a wide rising release feels rewarding and legible without making shallow release taps feel exploitable.
WHERE: PR #97 Android artifact after its `android-debug` workflow completes: https://github.com/menno420/spider-swing/pull/97/checks
HOW: ↩️ Install over any stable-key `0.19.0` or later build without uninstalling; swing normally, compare late rising releases with falling or immediate releases, and reply with a verdict. No recording is needed.
RISK: ↩️ reversible — the award is one config value and zero disables it; a later stable-key APK updates in place and preserves the save.
WHY-IT-MATTERS: Headless checks prove scoring and bounds, but only device play can settle the `assumed` 100 px/s maximum and 90° full-arc threshold.
UNBLOCKS: OQ-16 tuning evidence. The ordered drive → 0 implementation can proceed separately under its own stated assumptions.
VERIFIED-NEEDED: Exact Godot 4.7.1 passes 184/184 contracts; six deliberate mutants each turned the intended release contract red; the current `@2` technical trace reproduces exactly. None of those proves phone-scale feel.

notes: Read docs/planning/next-session-brief-2026-08-01-mechanics.md and its
earned-speed spec. No new recording is expected. One ordered slice per green PR;
next change is drive → 0 as config, not bird state or presentation.
