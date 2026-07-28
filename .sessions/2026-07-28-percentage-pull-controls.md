# Phase 0.8 percentage pull controls session

> **Status:** `complete`

## Goal

Turn the latest Android playtest findings into predictable traversal controls:
percentage-based anchor Burst and downward Dive Pull, Reel that primarily
shortens the rope without accumulating excessive speed, atomic double-tap
targeting, solid-object anchors, shaped prototype geometry, and live debug
controls for every new feel variable.

## Previous-session review

**previous-session review:** PR #12 correctly made both rope actions immediately
legible and anchor-directed, but the next extended playtest exposed two deeper
contract problems: Reel's inward acceleration accumulated too much speed, and an
impulse-based Burst could not guarantee a consistent amount of travel. The
larger 228-pixel controls and event-driven feedback remain valid and were kept.

## Shipped

- `game/domain/`, `game/simulation/`, and `game/application/` now resolve all
  retained polygon edges as targets, keep Reel speed-neutral, perform atomic
  targeted Burst, and run collision-checked 50% Burst / 25% Dive traversals —
  implementation commit `357b885290e8ad692b8ef04c1dcfaf7892cfb03e`.
- `game/application/course_stream.gd` and
  `game/presentation/scripts/{swing_lab.gd,tutorial_preview.gd}` replace the
  rectangle-only test vocabulary with ceiling gaps, changing heights, branch
  silhouettes, and broken-pot gates while keeping the geometry deterministic.
- `SwingConfig`, the DEBUG panel, diagnostics, tutorial, and playtest guide expose
  Burst/Dive percentages and durations, Reel shortening speed, aim forgiveness,
  gentle attach catch, and the existing movement values.
- `tests/` and build configuration identify
  `0.3.0-percentage-pull-test` and verify 46 runtime contracts, including exact
  pull shares, detached double-tap targeting, polygon anchors/collisions, and
  all new debug controls.

## Decisions flagged

- Burst and Dive Pull temporarily own position integration for their short
  configured duration, retain only the configured tangential share, and hand
  normal simulation back a fixed radial exit speed. This makes percentage travel
  deterministic without making a badly aimed pull safe.
- Dive Pull shares Burst's cooldown. It is a directional variant of the same
  traversal resource, not a second spammable recovery action.
- Ceiling polygons are attachable structural surfaces; warning-colored obstacle
  polygons are both attachable and lethal. The shared edge resolver keeps target
  behavior consistent while collision policy remains explicit.
- Balanced gravity rises from 1080 to 1320 and Reel shortening from 340 to
  480 px/s, reflecting the owner's high-setting preference. Both remain live
  debug values and no preset is declared approved.

## 💡 Idea

Add a debug-only route probe that draws the nearest resolved solid point and the
projected Burst/Dive endpoint before activation. It would make future recordings
show whether a surprising pull came from aim resolution or movement tuning
without adding aim assistance to normal play.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

- Local
  `GODOT_BIN=/tmp/spider-swing-godot-4.7.1/Godot_v4.7.1-stable_linux.x86_64 python3 tools/verify.py --require-godot`
  passed all six stages: 14 architecture fixtures, live inward scan, Godot
  4.7.1 discovery, clean import, boot smoke, and **46/46** runtime contracts
  (19 physics, 10 mobile HUD, 8 front-end, 9 bootstrap/build).
- PR #13 `game-quality` run
  [30389822532](https://github.com/menno420/spider-swing/actions/runs/30389822532)
  passed the same 46 contracts from
  `357b885290e8ad692b8ef04c1dcfaf7892cfb03e`.
- PR #13 `android-debug` run
  [30389823194](https://github.com/menno420/spider-swing/actions/runs/30389823194)
  passed and produced
  [`spider-swing-android-debug`](https://github.com/menno420/spider-swing/actions/runs/30389823194/artifacts/8700462786)
  artifact `8700462786`. The downloaded 56,739,942-byte ZIP matched GitHub's
  `sha256:a40ee04c2417fd3890b83830206a02965f55dfcf4d41c1c239181959bad33acb`;
  its 57,120,332-byte APK opened without ZIP errors and had SHA-256
  `305f25025e4cb7b55590011dcf39a67882ead60f6529e12ac15fd4a58897de04`.
  Bundled `build-info.txt` proves version `0.3.0-percentage-pull-test`, source
  `357b885290e8ad692b8ef04c1dcfaf7892cfb03e`, package
  `com.menno420.spiderswing.dev`, and display name
  `Spider Swing Percentage Pull (dev)`.
- `python3 bootstrap.py check --strict` reported only this card's intentional
  `in-progress` hold as exit-affecting; its guard-fire telemetry is retained.

## Documentation audit

README, tutorial copy and preview, Phase 0 playtest guide, front-end guide,
testing guide, current-state ledger, decision ledger, build manifest, and
runtime diagnostics describe the same percentage-pull, solid-target, Reel, and
prototype-geometry contracts as source. The checksum-pinned GDD was not modified.
No unrendered template slot or speculative Phase 1 system was added.

## Remaining owner review

Install the Phase 0.8 Android artifact and judge solid-edge aim forgiveness,
height control without Reel overspeed, the 50% Burst / 25% Dive shares, detached
double-tap response, and the readability of the shaped course silhouettes. The
debug panel is intentionally available for reporting preferred percentages,
durations, and Reel shortening speed.
