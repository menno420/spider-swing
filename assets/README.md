# `assets/`

Art, audio, and other media. Split by whether the engine loads it.

| Directory | Holds | Shipped? |
| --- | --- | --- |
| `source/` | Authoring files — vector originals, layered art, project files, raw audio | No |
| `runtime/` | Engine-ready exports the game actually loads | Yes |

The split exists so a large authoring file never has to be imported by Godot or
carried in the APK.

## Empty at bootstrap

There is no production art. The GDD is explicit that art direction is a later
phase: high-contrast 2D silhouettes in oversized natural or household
environments, one coherent biome for the first release (GDD § 17.1). Phase 0 uses a
graybox debug course.

Avoid visual similarity to Spider-Man or other superhero properties (GDD § 17.1).

## No Git LFS yet

Deliberate. There are no large binary assets, and enabling LFS before they exist
imposes a clone-time dependency for nothing. When real production art lands, decide
it then and record it as an ADR — enabling LFS retroactively rewrites history, so it
is worth a decision rather than a reflex.

## Readability constraints that apply to every asset

From the GDD's readability contract (§ 4.3):

- Player, web, collectible, safe attachment surface, and lethal hazard must be
  distinguishable **by shape as well as colour** — colour alone fails
  colour-blind players and fails at speed.
- Visual decoration must never conceal hazard bounds or anchor validity (§ 9.4).
- Everything must stay readable on a small screen at maximum speed (§ 2.3).
