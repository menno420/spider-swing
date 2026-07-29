# Phase 0.15 environment theme packs

> **Status:** `in-progress`

## Goal

Replace the temporary flat rail rendering with four coherent, touch-selectable
environment texture packs while preserving the existing authoritative collision
geometry and a one-tap graybox comparison mode.

## Scope

- Add four original texture packs for the ceiling, floor, and rail-grown
  obstacles.
- Centralize visual theme data in one presentation-owned catalog.
- Add an obvious DEBUG selector and keep graybox available as a baseline.
- Preserve gameplay geometry, lethality, pacing, and deterministic simulation.
- Add runtime contracts and ship a uniquely identified Android comparison APK.

## Previous-session review

**previous-session review:** PR #20 fixed the early impossible corridors without
changing the gradual pace curve. This session deliberately builds only on the
presentation surface so the newly playable geometry remains the comparison
baseline.

## 💡 Idea

Treat the environment as a swappable visual skin over one collision silhouette:
the same world can compare art direction without silently changing route width
or difficulty.

- **📊 Model:** gpt-5 · high · feature build

