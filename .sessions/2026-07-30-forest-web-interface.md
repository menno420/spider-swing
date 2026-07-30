# Forest-web interface and course rhythm session

> **Status:** `complete`

## Goal

Turn Home, Garage, Shop, and Settings into one cohesive natural forest-web
interface, replace the native-looking Silk selector, make touch scrolling
predictable on the owner's 1040×480 device, and add a small set of authored
post-opening course patterns that require readable high-to-low movement without
changing swing controls, aim forgiveness, or the safe learning runway.

## Scope guard

This session may change presentation-owned menus and theme helpers, touch-scroll
configuration, deterministic pattern selection and route cues, modest
authoritative obstacle polygons, regression contracts, living documentation,
and development build identity. It must not change baseline spider physics,
input reach or forgiveness, currency settlement, upgrade effects, save
ownership, the GDD, or place individual lethal obstacles randomly.

## Previous-session review

**previous-session review:** PR #28 correctly established five shared and two
identity upgrade tracks for every spider, preserved old save completion, and
removed the Classic spider's fixed-tick shimmer without changing simulation.
Menno's device recording confirmed that gameplay and the Ancient Forest were now
strong enough for the unfinished native-looking menus, Silk picker, touch
scrolling, and uneven late-course rhythm to be the highest-value next layer.
The current source confirmed that Shop and Settings still relied on
focus-following scroll surfaces and Garage still used native `OptionButton`
selectors.

## Shipped

- `game/presentation/scripts/spider_ui_theme.gd`,
  `game/presentation/scripts/silk_preview.gd`, and
  `game/presentation/scripts/front_end.gd` now provide one reusable
  bark/moss/sap/silk theme across Home, Garage, Shop, Tutorial, Course Lab, and
  Settings. Garage uses three-card body and Silk rails with a live thread
  preview; Shop uses themed CORE/IDENTITY cards, a fly-balance badge, and
  milestone knots.
- Shop and Settings retain Godot's native touch dragging but use a 12-pixel
  deadzone, 64-pixel step, and `follow_focus = false`, preventing an upgrade tap
  from snapping the list on the owner's 1040×480 viewport.
- `game/application/course_pattern_catalog.gd` and
  `game/application/course_stream.gd` add deterministic post-2000 m high→low
  and low→high weaves plus two compact silk-burr routes. The seven-fly weave
  curve and every obstacle come from one route plan. The opening runway and
  pre-2000 m rail policy remain unchanged.
- `game/presentation/scripts/swing_lab.gd` renders the small detached burr with
  the forest bramble grammar and presentation-only silk supports; it does not
  inherit a wall-growth socket or invisible collision.
- `tests/integration/front_end_flow_tests.gd`,
  `tests/integration/phase_0_physics_tests.gd`, and `tests/test_runner.gd`
  raise the suite to 88 contracts: 43 deterministic physics, 21 mobile GUI, 14
  front-end, and 10 bootstrap/build checks.
- `project.godot`, `export_presets.cfg`, and the Android workflow identify the
  comparison APK as `0.11.0-forest-web-polish-test`, version code 23, display
  name `Spider Swing Forest Web Polish (dev)`.
- README, current-state/capability ledgers, technical contracts, folios, and
  `project.index.json` now describe the verified implementation.

## Decisions flagged

- Keep all new difficulty after 2000 m. The 0–1000 m learning runway, baseline
  spider physics, full-screen aim reach, and aim forgiveness remain untouched.
- Require altitude changes through authored pairs and a fly-advertised curve,
  not through randomly stacked hazards. A Classic-sized route is sampled across
  the full transition in tests.
- Keep the middle burr roughly 95×80 pixels after scaling and make its thin Silk
  supports non-colliding. It creates a decision rather than a floating wall.
- Increase only small post-runway hazards through modest 8%, 14%, and 16%
  distance bands. The broad root passage opening never shrinks.
- Use a single inherited Godot `Theme` and the engine's existing touch-scroll
  behavior. UI decoration and Silk preview remain presentation-only.

## 💡 Idea

Treat fly trails as the readable grammar for future difficulty: show the
intended altitude change just before the geometry, then let the player decide
how to execute it. This can make later sections harder without hidden collision,
extra aim forgiveness, or more on-screen instruction.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

- `git diff --check`, the 14-fixture architecture self-test, and the full inward
  dependency scan pass on the exact local tree.
- `python3 tools/verify.py --skip-godot` passes both engine-independent gates;
  the clean CI run below supplies the non-skippable Godot proof.
- The pre-flip `python3 bootstrap.py check --strict` reported only this card's
  designed in-progress hold. Its completed-card rerun passes.
- PR
  [#30](https://github.com/menno420/spider-swing/pull/30) was opened ready while
  this born-red card kept the designed hold active.
- PR `game-quality` run
  [30520782041](https://github.com/menno420/spider-swing/actions/runs/30520782041)
  installed Godot `4.7.1.stable.official.a13da4feb`, completed clean import and
  front-end boot, and passed all 88 contracts at source
  `e8faca0762bd7184115a913cf9dc5e9cbb90b29e`.
- PR `android-debug` run
  [30520782029](https://github.com/menno420/spider-swing/actions/runs/30520782029)
  passed and produced
  [`spider-swing-android-debug` artifact 8750656978](https://github.com/menno420/spider-swing/actions/runs/30520782029/artifacts/8750656978),
  61,387,799 bytes, expiring 2026-08-13, with GitHub digest
  `sha256:f0845b3e6fa8391adc068aeff37719076518fb17180ef2279cc92d933de90c6c`.
  The downloaded ZIP matched that digest and passed archive validation. Its
  61,791,366-byte APK passed archive validation with SHA-256
  `2f9b820a7773a49ffbee1a74c1176ae660e0d2d3750ded9734667d55a37202a0`;
  `build-info.txt` proves version `0.11.0-forest-web-polish-test`, exact source,
  development package, and display name.
- The checksum-pinned GDD remains byte-identical at
  `a63e804bfadfe6fd9db88686bf55ea2b57ce488157069190d8350968c39c7a53`.

## Documentation audit

README, current-state and capability ledgers, front-end and Swing Laboratory
contracts, testing reference, project index, and application/presentation
folios match the verified source. No ADR or frozen game-design file changed,
and no live document retains an unrendered template slot or drafting marker.

## Remaining owner review

Install artifact `spider-swing-android-debug` 8750656978 after uninstalling the
previous ephemerally signed development app. Confirm Shop and Settings drag
smoothly from both buttons and empty space without tap-snapping; compare all
three Silk treatments; then pass both high↔low weave directions and the small
middle burr after 2000 m. The reversible values to judge are the 8–16% late
hazard growth and the burr's roughly 95×80-pixel size.
