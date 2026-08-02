# Simplify Home navigation into focused hubs

> **Status:** `in-progress`

## Goal

Replace Home's nine equal-weight destinations with a glance-readable hierarchy:
keep the selected spider, difficulty, and Endless Play primary; group the remaining
player routes into focused Spider, Play Modes, and Guide hubs; retain Settings and
a subordinate debug-only Test Lab shortcut.

## Scope guard

Front-end navigation state and presentation, Home and hub layout, route/back-path
contracts, mobile geometry checks, build identity, and living documentation.
Preserve every existing destination, normal-run configuration, progression,
persistence, gameplay simulation, audio, Test Lab contents, and reward eligibility.

## Planned verification

- Prove normal Home exposes one Play action plus four semantic destinations rather
  than the former nine-button feature index.
- Prove Garage/Upgrades, Campaign/Practice/Course Lab, and Tutorial/Field Guide stay
  reachable within two taps, with Test Lab directly reachable when debug is enabled.
- Measure Home and each new hub at 1280×720, 1280×600, and the owner's 1040×480
  recording viewport.
- Falsify route grouping, direct Play ownership, debug visibility, and viewport
  enclosure against production code.
- `python3 tools/verify.py --require-godot`
- `python3 bootstrap.py check --strict`

## Previous-session review

**previous-session review:** PR #109 correctly replaced the narrow unfinished menu,
completed Field Guide, and made Test Lab persistent, but its Home dashboard exposed
all nine destinations simultaneously. The owner's 36.8-second build-0.30 recording
shows that the route grid is now the dominant visual object and makes the first
screen feel like a control panel despite its improved material treatment. PR #111
only adds Music volume and does not change this information architecture.

## Implemented

- Home keeps selected-spider identity and difficulty, then presents one direct
  Endless Play action plus four intention-level choices: Spider, Play Modes,
  Guide, and Settings. Test Lab stays direct when enabled but is a subordinate
  48 px utility rather than a ninth equal-weight route.
- `FrontEndState` owns three new hub screens and every return path. Spider groups
  Garage and Upgrades; Play Modes groups Campaign, Region Practice, and Course
  Lab; Guide groups How to Swing and Field Guide. Every prior destination remains
  within two taps.
- Destination back actions name and return to the hub that opened them. Field
  Guide still remembers Garage separately when entered from a spider profile.
- Build identity is `0.32.0-menu-navigation-playtest`, Android version code 52.
  D-0047 supersedes only the former three-column Home topology.

## Layout evidence

- Real `SubViewport` layout after two frames encloses Home and all three hubs at
  1280×720, 1280×600, and the stricter unscaled 1040×480 recording size.
- At 1040×480, Home's slate dashboard is `(395.2, 24)–(998.4, 456)`, Play ends at
  214 px, the four-choice grid at 369 px, and Test Lab at 421 px. The Spider hub
  panels end at 441.6 px; both 112 px actions end at 369 px.
- The first measurement caught Home extending to 548 px and Spider actions to
  529 px. Redundant copy and excess minimum height were removed rather than
  adding scrolling to the first screen.
- Exact Godot's dummy headless renderer cannot produce a framebuffer in this
  seat, so no raster screenshot is claimed. Android remains the visual gate.

## Adversarial verification

Four temporary production breaks turned the intended focused contracts red:
restoring a three-column Home grid, sending Garage back to Home, enlarging Test
Lab to 80 px primary weight, and making Guide's Field Guide return to Home. Each
mutation was restored before the complete gate.

## Capability delta

The exact headless raster wall is appended to `docs/CAPABILITIES.md` with its
dummy-renderer error and Android-artifact workaround. The already-recorded
`app_block` absence was rechecked and remains true; no duplicate entry was added.

## Verification evidence

- Exact Godot `4.7.1.stable.official.a13da4feb`: 205/205 contracts pass.
- `python3 tools/verify.py --require-godot`: all seven stages pass, including
  deterministic audio regeneration, import, boot, architecture, and engine run.
- `python3 bootstrap.py check --strict`: pre-close red is the designed
  `in-progress` hold; final evidence awaits the remote implementation tree.

## Owner questions

No implementation blocker. The Android playtest should decide whether the four
Home intentions feel immediately understandable and whether one extra tap into
the three hubs feels calmer rather than slower.

## 💡 Session idea

If future features make one hub dense, add a persistent five-destination bottom
rail only after device evidence; do not put feature buttons back on Home.

## Next slice

Install the Android artifact over the stable-key build and traverse Home → each
hub → every destination once, focusing on recognition speed and back-path feel.

- **📊 Model:** gpt-5 · high · feature build
