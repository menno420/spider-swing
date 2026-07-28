# Phase 0.5 mobile traversal and obstacle test session

> **Status:** `complete`

## Goal

Turn Menno's second Android playtest into the next coherent laboratory slice: readable scrolling Settings, thumb-safe action controls, continuous ceiling attachment, a deterministic forward Burst, a course that streams beyond the original anchor field, and a small fair obstacle vocabulary.

## Scope guard

This session may change Phase 0 domain, simulation, application, input, presentation, tests, documentation, and debug build identity. It will not add currency, collectibles, unlocks, permanent progression, monetization, production art, or treat graybox obstacle tuning as approved Phase 1 content.

## Previous-session review

**previous-session review:** PR #9 and Menno's 1040×480 recording were reviewed. Home, Tutorial, Settings, Play, Menu, Reel, and DEBUG work on-device. The recording proves the Settings card is too small and clipped; the owner's run also reveals the finite anchor field, Reel reach cost, dot-only targeting limitation, and need for an avoidance test.

## Decisions flagged

- Add one authoritative `BURST` command reached by both a large button and an optional double-tap shortcut; the simulation owns cooldown and impulse.
- Model the upper attachment area as repeating ceiling surface segments while retaining small visual markers only as aim guidance.
- Stream deterministic chunks around the player instead of prebuilding a finite course.
- Start with static posts, gates, and low barriers; defer moving obstacles until the readable collision contract is proven.

## 💡 Idea

Use a deterministic chunk descriptor as the single source for ceiling surfaces, visual hints, and collision geometry. The same small set can loop with mirrored height/pattern variation, later gaining flies and moving obstacles without creating a second world-generation system.

- **📊 Model:** gpt-5 · high · feature build

## Completed

- Replaced the fixed anchor list with continuous web-compatible ceiling surfaces and a deterministic seven-chunk stream that remains populated beyond 10,000 m.
- Added one authoritative cooldown-limited Forward Burst command, reached through a large right-thumb Button or a double-tap of the attached web target.
- Moved Reel to a 190×190 lower-left hold target, added a 178×178 lower-right Burst target, and kept both inside Godot's GUI event-consumption path.
- Added safe opening chunks and a small static striped obstacle vocabulary with authoritative collision deaths.
- Rebuilt Settings as a vertically scrolling, focus-following surface with larger type and 58–68-pixel controls; expanded the in-engine Tutorial to six current-mechanic steps.
- Updated build identity to `0.2.0-traversal-test`, Android version code 4, and display name `Spider Swing Traversal (dev)`.

## Verification evidence

- `game-quality` run [30365948791](https://github.com/menno420/spider-swing/actions/runs/30365948791): success on Godot 4.7.1 Standard. `tools/verify.py --require-godot` passed 39 runtime contracts (13 physics, 9 mobile HUD, 8 front-end, 9 bootstrap) plus all 14 architecture fixtures.
- `android-debug` run [30365945501](https://github.com/menno420/spider-swing/actions/runs/30365945501): success from source `0b3827aaad7769f64f3e2a75e5525b565879a2d2`. Artifact `spider-swing-android-debug` ID `8690806549`, 56,710,502 bytes, digest `sha256:b091f4231df7d9c78053f54c91ba20b02c62578be0914fa8aed800aa4e9a3a8e`.
- Downloaded artifact inspection: archive integrity passed; APK reports `Android package (APK), with classes.dex`; it contains compiled CourseStream, front-end, Swing Laboratory, and both scenes for `arm64-v8a` and `x86_64`.
- `bootstrap.py check --strict`: pre-close remains held only by this card's intentional `in-progress` badge; the completed-card commit must make the final `substrate-gate` green before merge.
- GDD SHA-256 remains frozen by contract; no GDD content was changed.

## Documentation audit

**docs audit:** README, the Swing Laboratory reference, front-end flow, testing guide, architecture folios, project index, current-state ledger, status heartbeat, tutorial copy, and Android identity all describe the same implemented surface. The obstacle set is consistently labelled graybox test instrumentation rather than Phase 1 authored content.

## PR and handoff

- PR: [#10](https://github.com/menno420/spider-swing/pull/10)
- Remaining owner actions: the existing private-repository protection decision, plus Android playtesting of Settings readability, thumb reach, Burst feel, continuous targeting, obstacle fairness, and the three physics candidates.
- Guard recipe: preserve surface/Burst input isolation in `InputRouter._unhandled_input` (`game/adapters/input_router.gd`) and `SimulationWorld._consume` (`game/simulation/simulation_world.gd`); extend `MobileHudLayoutTests` and `Phase0PhysicsTests` for any new activation path.
