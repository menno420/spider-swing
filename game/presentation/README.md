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

`scenes/swing_lab.tscn` + `scripts/swing_lab.gd` — the bootstrap placeholder. It
renders the "Spider Swing — Phase 0 Swing Laboratory" title and one line of runtime
facts. There is no spider, no web, no camera follow, and no physics. Phase 0
replaces it with the real Swing Laboratory.

## Coming in Phase 0

Camera with speed-dependent look-ahead holding the spider in the left third
(GDD § 4.2), and the diagnostic overlays from GDD § 22.1 — velocity, speed target,
rope length, tension, Reel energy, player state, and collision/attachment hitbox
overlays.

See ADR 0002.
