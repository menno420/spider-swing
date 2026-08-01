# Spider Swing · status
updated: 2026-08-01T14:15:24Z
phase: recording-led fine-tuning — one zone or system per PR/APK
health: gameplay tree dfd797d · build 0.24.0 · exact Godot 4.7.1 and 181/181 contracts green · strict repository gate green
kit: v1.20.2 · check: green · engaged: yes
last-shipped: PR #90 finishes recorded 10–30 km presentation; PR #89 adds replay review and final guards
blockers: no technical blocker; merged visual/audio/replay work still needs bounded owner-device verdicts
orders: acked= done=
⚑ needs-owner: one focused recording of the single most noticeable unfinished area

⚑ OWNER-ACTION
WHAT: Record the one Spider Swing area that currently feels most unfinished, with its distance band and test setup visible or stated.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30700926892/artifacts/8818796707
HOW: ↩️ Install over any stable-key `0.19.0` or later build without uninstalling; use `DEBUG TEST RUN` for the exact distance and `OWNED` or `MAX`; capture roughly 30–60 seconds before, through, and after the problem; state the spider, upgrade preset, and difficulty if they are not visible.
RISK: ↩️ reversible — a later stable-key APK installs over this build and preserves the same local save.
WHY-IT-MATTERS: Source and CI prove implementation integrity, but only the phone recording can identify the highest-value remaining visual, touch, sound, spacing, or feel defect.
UNBLOCKS: one diagnosis-only pass followed by one bounded correction PR and Android APK, then a device verdict before any second slice.
VERIFIED-NEEDED: Exact Godot 4.7.1 passes 181/181 contracts; the downloaded Android ZIP matches GitHub's digest, its PR-head tree equals merged gameplay `main`, and its stable signer is verified. None of those checks can approve phone-scale feel.

notes: Read docs/planning/fresh-session-handoff-2026-08-01.md. Do not combine
several recordings or zones into one implementation task. PR #91 is documentation
and coordination only; gameplay remains at dfd797d / build 0.24.0.
