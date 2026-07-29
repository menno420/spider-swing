# Phase 0.11 debug lab and Dive reset

> **Status:** `complete`

## Goal

Turn Menno's first test of the merged gameplay-foundation build into two
contained improvements: make the DEBUG tuning surface understandable and
efficient on a phone, and replace Dive Pull's timer cooldown with a deterministic
one-use state that re-arms only after a successful normal web attachment to a
ceiling or obstacle.

## Scope

- Group the existing tuning controls by player intent instead of exposing one
  long parameter carousel.
- Use large touch targets, direct selection for common comparisons, plain names,
  units, live values, and short descriptions.
- Preserve every existing experimental setting and its single `SwingConfig`
  owner; presentation must consume metadata rather than invent a second config.
- Keep Anchor Burst's timed cooldown unchanged.
- Give Dive Pull no timed cooldown. One successful Dive consumes its charge; a
  qualifying upper/obstacle web attachment re-arms it.
- Add authoritative events/snapshot feedback and deterministic tests for the
  new Dive state.
- Keep the checksum-pinned GDD unchanged and avoid unrelated obstacle retuning;
  the first floating obstacle remains owner-test evidence for a later route
  tuning decision.

## Previous-session review

**previous-session review:** PR #16 merged the 1120-gravity/40%-Dive candidate,
speed-neutral take-up, paced course rails, fly/boost foundations, and a verified
Android build. Menno reports that the course rails and safe/lethal behavior work
well, but the current DEBUG carousel is difficult to navigate and the first
floating obstacle remains uncleared. This session changes control access and
Dive availability without silently changing the movement candidate or obstacle
geometry.

## Q-011 doc-hygiene review

The reported badge finding is the already documented, reason-carrying false
positive for the owner-authored GDD. Adding a badge would alter its pinned bytes;
the correct resolution remains the existing allowlist plus the status-bearing
`docs/game-design/README.md`. There is no new documentation drift to "fix" in the
frozen file.

## 💡 Idea

Define tuning controls once as typed descriptors—category, plain label, help
text, unit, step, and optional quick choices—then let both the phone panel and
tests consume that registry. Future upgrade previews can reuse the same
descriptors without duplicating simulation configuration or creating another
settings UI.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

- **Implementation:** `TuningCatalog` is now the sole metadata registry for all
  19 runtime feel values. DEBUG uses five direct sections, named presets,
  explanatory cards, one-tap comparison values, and shared responsive geometry
  for both drawing and native Godot `Button` hit targets. The layout was
  specifically regression-tested at the 1280×720 reference size and a
  1560×720 wide-phone canvas.
- **Dive ownership:** `SimulationWorld` owns one independent `dive_ready`
  charge. Dive ignores and never writes Anchor Burst cooldown, spends the
  charge on successful start, and rearms only through a successful normal
  upper/obstacle attachment. Snapshot, feedback, diagnostic export, preview,
  and Burst Frenzy all consume that same state.
- **Local game gate:** `python3 tools/verify.py` passed on Godot
  `4.7.1.stable.official.a13da4feb`: architecture fixtures `14/14`, headless
  import/boot, 29 deterministic physics checks, 15 mobile GUI contracts, nine
  front-end contracts, and **63/63 total runtime checks**.
- **Strict gate ritual:** the first `python3 bootstrap.py check --strict`
  produced only its designed born-red hold for this in-progress card plus
  advisory stale-ledger notes. Its eight guard-fire records were committed;
  the checksum-pinned GDD finding remained the documented false positive.
  After the deliberate completion flip, the exact final strict command passed;
  its two legitimate telemetry records are included in the closing commit.
- **CI:** ready PR
  [#17](https://github.com/menno420/spider-swing/pull/17);
  [`game-quality` run 30420061825](https://github.com/menno420/spider-swing/actions/runs/30420061825)
  passed from source `b00007514aaad431dcfaa5b41c8ec9413a1eadba`.
- **Android proof:**
  [`android-debug` run 30420061815](https://github.com/menno420/spider-swing/actions/runs/30420061815)
  produced artifact
  [`spider-swing-android-debug` / 8711576758](https://github.com/menno420/spider-swing/actions/runs/30420061815/artifacts/8711576758).
  The downloaded 56,800,048-byte ZIP matched GitHub digest
  `sha256:57f77723586babbe408bb6b86f987bb3e8caa622b01f9130fd943b91c58b4dcd`;
  its 57,182,655-byte APK passed archive verification with SHA-256
  `2b9438829f631d3486a668b28915aa8ff9d618639d287a8f87166b9771f20db6`.
  `build-info.txt` proved version `0.4.1-debug-lab-dive-reset-test`, source,
  dev package, and display name `Spider Swing Dive Reset (dev)`.
- **Docs audit:** README, current state, capability ledger, decision ledger,
  and the Phase 0 playtest guide now distinguish Burst cooldown from Dive
  contact rearm and describe the grouped DEBUG surface. The frozen GDD was not
  edited. No unrendered placeholders remain.
- **Flagged reversible decision:** the first floating obstacle was deliberately
  not retuned. The next device run should isolate whether the new Dive rhythm
  makes it passable; its geometry can then be widened independently if needed.
