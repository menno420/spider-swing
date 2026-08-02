# Complete front-end and persistent Test Lab

> **Status:** `complete`

## Goal

Turn the passive web-themed shell into a complete, glance-readable menu system:
give Home a clear action hierarchy, make Field Guide a species browser rather
than a text wall, and expose the full meaningful tuning catalogue before a run
through persistent comparison configurations.

## Scope guard

Front-end information architecture and shared material rendering; Field Guide
selection/detail presentation; a versioned debug-test configuration value object
written only through SaveRepository; pre-run application of catalogue tuning;
mobile layout and persistence contracts; build identity and living docs.
Preserve normal-run physics/defaults, progression ownership, reward/record
eligibility, course generation, full-screen aiming, audio, and in-run tuning.

## Planned verification

- Inspect and render Home, Field Guide, Garage, Shop, Settings, Tutorial, and
  Test Lab at 1280×720 plus a shorter landscape viewport.
- Prove Test Lab edits round-trip, A/B/C snapshots remain debug-only, and the
  exact selected profile reaches the session before its first simulation tick.
- Falsify Field Guide hierarchy, passive textured surfaces, persistence,
  noncompetitive run ownership, and profile application.
- `python3 tools/verify.py --require-godot`
- `python3 bootstrap.py check --strict`

## Previous-session review

**previous-session review:** PR #106 established one passive spider-web panel
renderer but intentionally left the existing information architecture intact.
The owner's 18.585-second 1040×480 recording then showed the remaining gap:
Home was a narrow equal-weight button column, Field Guide was a small green text
wall, and Test Run was difficult to scan or compare. The centralized theme,
`FrontEndState`, `TuningCatalog`, `SaveRepository`, and debug-practice ownership
were the correct seams to extend rather than replacing the front end.

## Implemented

- Home now fills the landscape with a selected-spider identity card and a
  dominant Play/difficulty/three-column route dashboard. Every route explains
  its destination on a second line.
- The shared slate/graphite palette reserves moss, sap, dew, and amber for
  meaning. Every `SpiderWebPanel` draws deterministic neutral grain and pits
  beneath the existing low-alpha fibres, webs, knots, and cocoons.
- Field Guide is a five-spider master/detail browser with production sprite,
  identity, and separate Real Animal, In Spider Swing, Field Note, and Sources
  cards.
- Home's Test Lab exposes all eight meaningful pre-run `TuningCatalog`
  categories. Its working set auto-saves separately, A/B/C store complete
  comparisons, and the Start action remains pinned outside category scrolling.
- Resolved display values are separated from sparse explicit overrides, so
  untouched spider/difficulty/owned-or-L40 tuning remains authoritative. The
  selected override batch reaches a noncompetitive session before its first
  simulation tick and live changes re-enter the saved working set on Menu.
- Build identity is `0.30.0-menu-system-playtest`, Android code 50.

## Shipped

- Remote implementation commit `7f7136d76b239d2d9999148de27db7c1b84c7e0a`
  carries all 21 changed files on PR #109. GitHub and the locally verified Git
  commit both resolve to tree `7b5b4a6bb7420f50a6e5c812451b2f348ec0ae33`.
- This closeout flip withdraws `claude/menu-system-overhaul`; required GitHub
  checks and Android export decide the PR's terminal merge/build state.

## Layout and visual boundary

- Headless Godot layout audits at 1280×720 and 1280×600 found no visible
  non-scroll control outside any of the ten front-end screens.
- At 1280×600 the Test Lab card is 1190.4×471 px, its movement scroller remains
  1186×242 px, and the full 400×62 px Start action stays pinned and enclosed.
- Home, Field Guide, and Test Lab geometry was measured directly after two
  layout frames. This seat has no framebuffer, so it does not claim raster
  screenshot evidence; the Android artifact remains the owner visual gate.

## Adversarial verification

Six temporary production breaks each turned the intended front-end contract
red: 71 rather than 72 slate grain marks, renamed game-fiction Field Guide
section, all resolved values emitted as overrides, ignored profile primary
file, skipped pre-tick profile application, and a demoted 60 px Home Play
action. Every mutation was restored before the final gates.

## Verification evidence

- Exact Godot `4.7.1.stable.official.a13da4feb`: 203/203 contracts pass.
- `python3 tools/verify.py`: all seven stages pass, including exact regeneration
  of 27 audio assets, import, boot, architecture, and the engine runner.
- `python3 bootstrap.py check --strict`: the completed card and withdrawn claim
  pass every content check. Only nonblocking repository advisories remain, and
  the boot ledger retains 199 words of enforced headroom.

## Owner questions

No implementation blocker. Device review should decide whether the neutral
texture is strong enough, the Field Guide section density is comfortable, and
the A/B/C strip remains readable at the physical phone size.

## 💡 Session idea

Give saved Test Lab slots optional short user labels only if A/B/C proves too
abstract in device use; keep labels inside `DebugTestProfile`, never progress.

## Next slice

Install the Android artifact and review Home hierarchy, all five Field Guide
entries, Test Lab category scrolling, saved A/B/C restoration after an app
restart, and ordinary Play after an L40 comparison.

- **📊 Model:** gpt-5 · high · feature build
