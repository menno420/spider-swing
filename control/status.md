# Spider Swing · status
updated: 2026-08-01T08:27:37Z
phase: shipped-state reconciliation and generated SFX — PR #83 in CI
health: local green · GitHub checks running
kit: v1.20.2 · check: green · engaged: yes
last-shipped: PR #82 records the owner's device difficulty verdict
blockers: no code blocker; audio mix and later-zone readability need owner-device evidence
orders: acked= done=
⚑ needs-owner: build 0.22 audio and integrated-zone device pass

⚑ OWNER-ACTION
WHAT: Install build `0.22.0-audio-playtest`, judge the generated core SFX on the phone speaker, and continue the frozen Silk Hollow/Zones 4–8 success-sentence pass.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30691794032
HOW: When the run finishes, download `spider-swing-android-debug`; install over any stable-key `0.19.0` or later build without uninstalling; confirm the build label; compare Effects on/off and Haptics on/off independently; listen for attach/release variants, the continuous Reel loop, Burst versus Dive, fly/invalid/rescue/death feedback, then start at 15000/20000/30000/35000 m for glass, storm, rot, and mist warning cues.
RISK: ↩️ reversible — install any later stable-key debug APK over this one; do not uninstall, so saved data remains.
WHY-IT-MATTERS: Contracts prove exact source, safe levels, event mapping, and deterministic warning lead, but only a phone-speaker run can prove readability, fatigue, and emotional fit at 76 m/s.
UNBLOCKS: Retain/revise decisions for the SFX set and owner acceptance of the later-zone warning budget.
VERIFIED-NEEDED: Local exact Godot 4.7.1 import/boot and 165/165 contracts pass; require green game-quality/Substrate, Android export, embedded build identity, package manifest, and pinned stable signer before merge.

notes: PR #83 changes presentation feedback, settings schema 2, documentation,
and visible build identity only. It does not change physics, zone geometry or
mechanics, Campaign, difficulty, upgrades, economy, input meaning, settlement,
or progression. The 25 WAVs are original procedural output with byte-exact
regeneration; ambience and music remain absent.
