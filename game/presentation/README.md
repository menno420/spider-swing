# `game/presentation/` — what the player sees and hears

**Rank 3. Depends on `domain`, `simulation`, `application`. Peer of `adapters` —
must not depend on it.**

UI, camera, audio, VFX, rendering. Consumes application APIs and domain events.

## The hard rule

**Presentation never mutates authoritative simulation state, and cannot grant
rewards.** It reads and reacts. The visual web follows the authoritative physics
endpoints; it does not drive physics (GDD § 17.2).

## Layout

| Path | Holds |
| --- | --- |
| `scenes/` | `.tscn` scene files |
| `scripts/` | `.gd` scripts attached to those scenes |

## Current contents

- `front_end.tscn` + `front_end.gd` — responsive Home, Garage, Shop, Tutorial,
  Course Lab, and Settings surfaces bound to application-owned state.
- `tutorial_preview.gd` — reduced-motion-aware in-engine mechanics animation.
- `swing_lab.tscn` + `swing_lab.gd` — Phase 0 camera, anchors, spider, web,
  HUD, Reel energy, opening/rescue/profile feedback,
  authoritative-event-driven action flashes, and diagnostic overlays.

The composition root mounts either the front end or the laboratory, never two
competing roots. See ADR 0002 and `docs/technical/front-end-flow.md`.
