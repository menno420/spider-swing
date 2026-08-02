# Complete front-end and persistent Test Lab

> **Status:** `in-progress`

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

Pending implementation review.

## What is about to happen

Build one coherent menu-system vertical slice from the owner recording and the
existing centralized front-end, tuning, persistence, and simulation seams.

## 💡 Session idea

Pending.

## Next slice

Pending.

- **📊 Model:** gpt-5 · high · feature build
