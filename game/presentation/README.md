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

- `front_end.tscn` + `front_end.gd` — responsive Home, Garage, mobile-scrollable
  seven-track Shop, Tutorial, Course Lab, and Settings surfaces bound to
  application-owned state.
- `tutorial_preview.gd` — reduced-motion-aware in-engine mechanics animation.
- `swing_lab.tscn` + `swing_lab.gd` — Phase 0 camera, anchors, spider, web,
  HUD, Reel energy, opening/rescue/profile feedback,
  authoritative-event-driven action flashes, and opt-in collision/web-guide
  overlays. The DEBUG panel and world overlays are independent.
- `environment_theme_catalog.gd` — one visual-only registry for the Graybox,
  Ancient Forest, Mossy Ravine, Overgrown Greenhouse, and Reclaimed Attic
  looks. It may change texture and palette but never course geometry. Finished
  Ancient Forest obstacle art uses transparent sprite alpha as its normal-game
  silhouette; the exact polygons remain available through the opt-in collision
  overlay and as a missing-asset fallback. One world-anchored bark texture spans
  every ceiling/floor profile, including profile changes and chunk seams.
  Wall-grown art overlaps a mossy growth socket behind that rail, which is drawn
  over the join, and texture regions are cropped without changing aspect ratio.
  The broad passage uses the same rail-grown bramble/vine grammar instead of a
  stretched circular gate sprite. Three independently scrolling, mirrored
  forest-depth layers replace the abstract circle/tree backdrop at deliberately
  lower contrast than the spider, flies, web, and lethal silhouettes.

`SwingLabView` manually interpolates its custom-drawn spider and attached web
between consecutive fixed-step snapshots using Godot's physics interpolation
fraction. This changes only render coordinates. Teleports and run resets snap
both samples together, reduced-motion disables action-pose deformation, and
authoritative collision continues to use the untouched snapshot state.

The composition root mounts either the front end or the laboratory, never two
competing roots. See ADR 0002 and `docs/technical/front-end-flow.md`.
