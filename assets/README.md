# `assets/`

Art, audio, and other media. Split by whether the engine loads it.

| Directory | Holds | Shipped? |
| --- | --- | --- |
| `source/` | Authoring files — vector originals, layered art, project files, raw audio | No |
| `runtime/` | Engine-ready exports the game actually loads | Yes |

The split exists so a large authoring file never has to be imported by Godot or
carried in the APK.

## Current asset policy

Runtime art now covers the player roster and eight authored zone identities;
the generated SFX playtest pack covers core actions and later-zone warnings.
Every generated or externally sourced asset needs a source/provenance record,
and externally sourced audio still requires per-file CC0 verification. Graybox
fallbacks remain available for diagnostics.

Avoid visual similarity to Spider-Man or other superhero properties (GDD § 17.1).

## No Git LFS yet

Deliberate. Current optimized runtime binaries remain practical in ordinary Git;
enabling LFS would add a clone-time dependency. Revisit the decision if future
source art, music, or ambience materially changes repository size.

## Readability constraints that apply to every asset

From the GDD's readability contract (§ 4.3):

- Player, web, collectible, safe attachment surface, and lethal hazard must be
  distinguishable **by shape as well as colour** — colour alone fails
  colour-blind players and fails at speed.
- Visual decoration must never conceal hazard bounds or anchor validity (§ 9.4).
- Everything must stay readable on a small screen at maximum speed (§ 2.3).
