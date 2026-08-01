# Recorded Zones 3–6 environment finish

> **Status:** `complete`

## Goal

Bring Silk Hollow, Ruined Arboretum, Storm Ridge, and Web City to the complete
environment standard established by Ancient Forest and Bramble Canopy. Add
real parallax depth, finished zone-specific corridor and safe-surface
materials, remove non-debug polygon ghosts from finished obstacles, and make
every declared ceiling-grown hazard meet the actual local ceiling profile.
Attachment supports may extend only through the measured gap to that profile;
primary hazard silhouettes, corridor profiles, route guides, physics values,
floor clearances, and anchor rules remain unchanged.

## Scope guard

Own only recorded Zones 3–6 environment presentation assets, semantic renderer
routing, presentation contracts, reproducible recording/device-scale evidence,
build identity, and the living handoff record. Exclude PR #89 replay tooling,
Ancient Forest and Bramble art, authoritative obstacle/boundary/surface
geometry except narrow ceiling attachment supports, route guides and corridor
profiles, zone mechanics, simulation, physics values, difficulty, progression,
economy, settlement, saves, and input. Every support change requires a seeded
passability proof and an exact before/after geometry assertion limiting the
delta to the intended support.

## Previous-session review

**previous-session review:** PR #87 correctly replaced the most visible flat
obstacle polygons with finished Silk and Arboretum objects, but its seeded
preview exposes the remaining generic wall path: thin cyan double outlines at
the ceiling and floor still frame otherwise finished zone art.

## Owner evidence

The owner's six 2026-08-01 recordings establish Ancient Forest (0–5 km) and
Bramble Canopy (5–10 km) as the finished benchmark. Silk Hollow, Ruined
Arboretum, Storm Ridge, and Web City retain attractive single-layer backplates
but expose pale corridor polygons, always-on moving-rest outlines, unresolved
surface/egg/scree fallbacks, and visible joins where wall-grown art stops short
of the rendered boundary. The correction must address those shared
presentation paths without using painted thickness to misrepresent collision
or reduce the opening.

## 💡 Idea

Give each zone reusable backdrop-layer, boundary-material, surface-material,
and obstacle-art specifications so environment finish is selected from semantic
zone data rather than accumulating renderer branches.

- **📊 Model:** gpt-5.6-sol · high · feature build

## Recording analysis

The six owner recordings were compared at matching 1280×720 gameplay scale.
Ancient Forest establishes three low-contrast raster depths, continuous textured
rails, and growth sockets; Bramble Canopy establishes two depths plus ambience,
braided rails, and hazards whose roots visibly agree with their tap data. The
10–30 km recordings instead exposed one 0.065-scroll backplate under a tint,
flat corridor polygons, and two separate outline paths: moving-rest ghosts at
0.24 alpha and 1.8/2.2-pixel semantic rims drawn over otherwise finished art.

Three ceiling-grown families also stopped before the real local boundary:
Ruined Arboretum beam supports by 25.6–44.3 px, Storm Ridge spires by 28.6 px,
and Web City egg tethers by 69.1 px. Silk Hollow's objects were already
boundary-grown; its unfinished join came from the generic wall renderer.

## Shipped

- Added a second, independently scrolling raster depth to each recorded 10–30
  km zone while retaining its approved backplate: Hollow fibres, Arboretum
  iron/ivy/glass, Ridge slate/roots, and City civic-silk buttresses.
- Replaced generic corridor fills with continuous, zone-specific ceiling and
  floor materials. Silk's braided ceiling and blunt floor preserve the tap
  promise; Arboretum uses overhead iron/glass and a masonry/debris base; Ridge
  uses wet slate; City uses civic silk.
- Finished the remaining recorded fallbacks: Storm scree, Web City highways,
  sticky highway treatment and egg. Skinny resident collision legs no longer
  become pale outlined bars in normal play.
- Removed moving-rest ghosts and semantic obstacle rims from normal rendering;
  both remain available through collision/debug presentation where they belong.
- Extended only the three measured ceiling supports through their pre-existing
  gaps to the interpolated local ceiling profile. Primary hazard silhouettes,
  corridor profiles, route guides, floor clearances, motion, anchorability and
  physics are unchanged.
- Added 13 original transparent runtime assets. The generated-asset catalog now
  contains 33 Zone 3–8 assets and records source/runtime dimensions, rationale,
  anchorability, generation prompts and source hashes in
  `assets/source/zone-art/README.md`.
- Bumped the playtest build to `0.24.0-environment-finish-playtest`, Android code
  43, with display name `Spider Swing Environment Finish Playtest (dev)`.

## Verification evidence

- `python3 tools/verify.py --require-godot`: PASS on exact Godot 4.7.1 import,
  boot, architecture and all **175/175** contracts.
- The contracts prove ordered two-plane depth, finished boundary/surface routes,
  debug-only ghosts/rims, attachment to the exact local ceiling, support-only
  geometry deltas, preserved openings and unchanged primary silhouettes.
- `tools/zone_art_audit.py`: 33/33 assets pass source, runtime and bilinear 25%
  gameplay-scale alpha/fringe checks. The maximum whole-zone silhouette IoU is
  0.504 between the two benchmark forest zones; every recorded later zone is
  at or below 0.488 against every other zone.
- Seeded full-colour 1280×720 captures and 320×180 silhouettes are committed in
  `docs/visual/zones`; their geometry and art routing come from the same export
  consumed by the tests.
- PR #90 `game-quality` run
  [30700135588](https://github.com/menno420/spider-swing/actions/runs/30700135588)
  passed all 175 contracts at source
  `ce8e71e1b0f9a54dcd7c79877a99b6e474c8f013`.
- PR #90 `android-debug` run
  [30700135589](https://github.com/menno420/spider-swing/actions/runs/30700135589)
  passed and produced artifact
  [`8818553194`](https://github.com/menno420/spider-swing/actions/runs/30700135589/artifacts/8818553194).
  Its 76,561,832-byte ZIP matches
  `sha256:e14f875f9e922ec158fabf5a3c0b5f1bd2d0fde449ffbb6501e03339e7d0ee8d`;
  the contained 77,007,766-byte APK passes archive validation and has SHA-256
  `d5846835eef4727cd3ab6856e0108374f9620ee52538dca667ef0d2a9f2dad64`.
  `build-info.txt` proves the version, source SHA, dev package, display name and
  stable debug-key identity above.
- The published GitHub tree `1cb95089f12aedf5e3100bda71e03a28458a1fb6`
  exactly matches the locally verified implementation tree. The pre-close
  strict repository gate failed only on this card's intentional `in-progress`
  hold; that guard-fire telemetry is retained.

## Documentation audit

README, current state, zone progression, presentation/application ownership,
testing, visual evidence, generated-source policy, Android workflow and build
identity all describe the same recorded-zone finish. Historical evidence and
the checksum-pinned design source remain untouched.

## Remaining owner review

Install the verified APK and compare 10–30 km against the first two recordings.
At speed, judge whether each new depth plane recedes, every ceiling/floor reads
as one continuous physical structure, finished hazards no longer show faint
polygon rims, and the three repaired ceiling-grown families now look honestly
attached without narrowing the intended route. Automated evidence cannot
approve composition, readability or feel on the target phone.
