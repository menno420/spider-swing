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
  seven-track Shop, Tutorial, Campaign, Course Lab, Region Practice, Field Guide,
  and Settings surfaces bound to application-owned state. The forest-web
  background and all selectors use presentation state only.
- `spider_ui_theme.gd` — one Ancient-Forest-aligned theme for panels, buttons,
  focus/disabled states, touch scroll configuration, descendant gesture
  bubbling, and silk-like scrollbars.
- `silk_preview.gd` — compact visual-only Classic/Dew/Ember thread preview for
  the Garage's custom Silk card rail.
- `tutorial_preview.gd` — reduced-motion-aware in-engine mechanics animation.
- `audio_asset_catalog.gd` + `audio_director.gd` — event-to-sample mapping,
  bounded voice playback, high-frequency variants/cooldowns, and a continuous
  Reel loop. They consume authoritative events/snapshots and never emit gameplay
  intent.
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
  over the join. Broad shapes use aspect-preserving cover crops; tall narrow
  growth uses the complete vertical vine texture at its natural aspect with
  conservative horizontal overscan, so art never ends on a sliced source edge.
  Compact middle burrs use the bramble grammar but skip wall-growth sockets and
  hang from thin presentation-only silk; their small polygon remains the whole
  collision.
  The broad passage uses the same rail-grown bramble/vine grammar instead of a
  stretched circular gate sprite. Three independently scrolling, mirrored
  forest-depth layers replace the abstract circle/tree backdrop at deliberately
  lower contrast than the spider, flies, web, and lethal silhouettes.
  Bramble Canopy's normal stream does not reuse those obstacle roles. Each deep
  hook vine or diagonal giant-leaf shutter carries a domain semantic kind beside
  its authoritative polygon and anchor flag; presentation maps that kind to an
  inspected alpha asset and mirrors it to match the authored direction. Bounds-
  based selection remains only the conservative fallback for untyped creator or
  legacy laboratory geometry.

`SwingLabView` manually interpolates its custom-drawn spider and attached web
between consecutive fixed-step snapshots using Godot's physics interpolation
fraction. This changes only render coordinates. Teleports and run resets snap
both samples together, reduced-motion disables action-pose deformation, and
authoritative collision continues to use the untouched snapshot state.
All five finished spider sprites use that same path and scale from each
profile's authoritative radius; a missing texture retains the procedural
renderer as a presentation-only fallback.

The composition root mounts either the front end or the laboratory, never two
competing roots. See ADR 0002 and `docs/technical/front-end-flow.md`.
