# Silk Hollow and Ruined Arboretum obstacle art correction

> **Status:** `complete`

## Goal

Replace the visibly unfinished collision-polygon obstacle presentation in Silk
Hollow and Ruined Arboretum with painterly foreground objects that belong to
their approved backgrounds, while preserving the authoritative gameplay.

## Scope guard

Own only Zones 3–4 foreground obstacle assets, their presentation routing,
asset provenance/QA, visual contracts, build identity, and living handoff
records. Preserve every collision polygon, route, motion phase, moving-anchor
rule, anchor eligibility flag, physics value, difficulty value, background,
progression, save, economy, settlement, and input behavior. Bramble Canopy and
PR #86 are explicitly excluded.

## Previous-session review

**previous-session review:** PR #73 successfully established distinct
backgrounds, deterministic later-zone mechanics, and zone-level silhouette
identity, but the owner recordings expose a weaker foreground-art claim: most
Silk lattice/spindle and Arboretum beam/rotor hazards still fall back to flat
filled polygons with bright outlines. The backgrounds look finished while the
hazards read as debug geometry.

## Owner evidence

Two 1040×480 Android recordings from build `0.22.0-audio-playtest` cover
10,000–11,700 m and 15,000–16,200 m. Silk Hollow shows repeated pink angular
bars over a convincing web chamber; Ruined Arboretum shows pale rectangular
crosses over a convincing reclaimed glasshouse. The correction target is the
foreground vocabulary, not course difficulty or the backgrounds.

## Root cause

`SwingLabView._draw_zone_obstacle` still used a generic solid polygon and bright
outline whenever the art catalog did not resolve an obstacle. Silk's lattice,
spindle and floor-needle content ids and Arboretum's beam, rotor and collapsed-
frame ids had no routes, so finished backgrounds were carrying prototype
collision visualisation. The defect was presentation data and routing, not the
authoritative polygons or zone designs.

## Implemented

- Seven original, isolated transparent objects replace those generic fills:
  Silk cocoon (384×768, **ANCHORABLE**), spindle (256×768, mixed by authored
  ceiling/floor state), lattice strut (768×128, mixed), Arboretum beam (768×96,
  **ANCHORABLE**), rotor arm (768×96, **NOT**), rotor hub (256×256, **NOT**),
  and solid collapsed frame (640×512, mixed). Exact source dimensions, sizing
  rationale, anchor state, generation prompt/mode, hashes, and each 25%
  silhouette verdict live in `assets/source/zone-art/README.md`.
- `ArtAssetCatalog.zone_obstacle_art_spec()` now owns explicit stable
  `visual_id`/`content_id` routes, long-axis orientation, floor/ceiling flips,
  contain rules and minimum render sizes. The renderer uses those specs while
  retaining an honest generic fallback for unmapped or missing art.
- Long struts, beams and rotor arms align to their authoritative oriented
  polygons. The collapsed-frame painting is opaque across its solid collision
  area rather than promising a false passable arch. A restrained semantic rim
  and the existing cyan collision-debug overlay remain available without
  becoming the obstacle's primary appearance.
- The seeded zone exporter now includes content ids and useful 10 km/15.1 km
  review starts. The audit composites actual catalog art onto actual exported
  geometry instead of painting generic polygons into the evidence captures.
- Build identity is `0.23.0-obstacle-art-playtest`, Android version code 42,
  display name `Spider Swing Obstacle Art Playtest (dev)`.

## Preserved gameplay

Collision polygons, course routes, pattern pools, distances, motion phases,
moving-anchor behaviour, anchor eligibility, physics, difficulty, backgrounds,
input, progression, economy and saves are unchanged by this correction. New
contracts pin route completeness, runtime dimensions, orientation/flips and the
geometry-invariance boundary. The later merge of Bramble PR #86 is retained in
full; only shared screenshots/audit evidence were regenerated around it.

## Visual and asset verification

- All 20 zone-art assets report zero targeted green or magenta chroma fringe at
  keyed-source, runtime and 25% gameplay size. The seven new runtime PNGs total
  about 1.4 MiB and import under the Compatibility renderer.
- Seeded 1280×720 captures at Silk 10 km and Arboretum 15.1 km now show woven
  trusses/cocoons/needles and corroded greenhouse beams/rotors instead of flat
  pink bars and pale outlined crosses.
- The 320×180 pure-black sort audit passes all zones. Highest whole-set overlap
  is 0.504 between the two pre-existing forest zones; Silk's nearest overlap is
  Ancient Forest at 0.488 and Arboretum's is Ancient Forest at 0.464.
- Generation used only the repository's approved Silk and Arboretum art as
  image references; no third-party source or reference material was used.

## Local verification

- Exact `4.7.1.stable.official.a13da4feb` import, boot, architecture scan and
  `GODOT_BIN=/tmp/godot-4.7.1/Godot_v4.7.1-stable_linux.x86_64 python3
  tools/verify.py --require-godot` pass all **171/171** contracts after merging
  current `main`.
- `python3 tools/zone_art_audit.py` passes all 20 source/runtime/gameplay matte
  checks and regenerates the seeded screenshots, silhouettes, contact sheets and
  JSON report. `git diff --check` is clean.
- `python3 bootstrap.py check --strict` reports only this card's deliberate
  pre-close `in-progress` hold. Advisory stale-wall/capability notices are
  non-exit-affecting and pre-existing.

## Remote implementation proof

- PR #87 implementation commit `c2ca71e53471c6347249663e18c0ef5f3a81cd4f`
  and reconciliation merge `299790c01abe9166540caca9e38a6da4802865c6`
  point to the exact locally verified integrated tree
  `02c5a92e51cbbaf7f1b01340e286e1a97878cc6b`.
- `game-quality` run
  [30696896648](https://github.com/menno420/spider-swing/actions/runs/30696896648)
  passed on that head. Substrate's red result is the designed open-session hold.
- Android run
  [30696896649](https://github.com/menno420/spider-swing/actions/runs/30696896649)
  passed and uploaded artifact
  [8817550870](https://github.com/menno420/spider-swing/actions/runs/30696896649/artifacts/8817550870).
  Its 70,272,400-byte ZIP matches GitHub's SHA-256
  `d55c124d47127696a4e26c616ebe47e6ce5c566e0a6342ee43dd2dff6113e6b8`
  and passes archive validation. The 70,704,975-byte APK passes archive
  validation with SHA-256
  `d339d94852c2c7cb3e854d9530003f4af6880dd2ab129f39185cf94cac2e9cd6`;
  embedded `build-info.txt` proves the version, exact source, dev package and
  display name above.

## Moving-main reconciliation

While this slice was active, `main` advanced through Bramble clearance PR #86
and policy-search PR #88. True remote merge commit `299790c0` preserves both
parents and regenerated shared visual evidence. The combined state—not the
pre-merge branch—passed 171 local contracts, remote game quality and Android
export before this lifecycle flip.

## Final verification gate

This `complete` badge and deletion of only
`control/claims/claude-codex-zones-3-4-obstacle-art.md` are the deliberate final
content change. The exact engine suite and strict repository gate must pass
again on the final PR head, which may merge only after fresh final-head checks
are green.

## Capability delta

`docs/CAPABILITIES.md` appends the newly demonstrated owner-recording-to-
finished-zone-art path: decode supplied Android recordings, generate from
approved repository references, key/despill, audit source/runtime/25% mattes,
and verify through exact Godot. Publication reused the documented authenticated
GitHub-app exact-tree route; the local Git authentication wall is unchanged.

## Owner questions

None before merge. Device acceptance remains the owner's visual judgement:
whether the 10–12 km lattice/spindle hazards and 15–17 km beam/rotor hazards
read as finished world objects with about one second of warning, and whether
the restrained semantic rim should be reduced further after phone testing.

## 💡 Idea

Carry forward the existing development-only art/fallback comparison-toggle
idea, and export one presentation manifest for both GDScript and the Python
audit so content-id routing cannot drift between the game and its evidence tool.

- **📊 Model:** gpt-5.6-sol · high · feature build
