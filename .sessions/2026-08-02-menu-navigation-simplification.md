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

## Next step

Build the state-owned hubs and compact Home layout, then replace the obsolete
three-column-map contract with route-depth and mobile-layout guarantees.

- **📊 Model:** gpt-5 · high · feature build
