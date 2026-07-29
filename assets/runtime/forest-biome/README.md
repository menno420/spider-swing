# Ancient Forest finished art

> **Status:** `candidate-production-runtime-art`

- `ancient-branch-ceiling.png` decorates the collision-facing edge of both
  ceiling and floor polygons; floor segments use a vertical mirror.
- `thorn-bramble.png` visualizes floor-grown and broad edge-grown hazards.
- `hanging-thorn-vine.png` visualizes tall top-anchored hazards.

`SwingLabView` uses these sprites only for Ancient Forest and exposes exact
collision outlines only in DEBUG. Every wall-grown sprite extends behind the
branch rail, then the continuous rail is redrawn over the join. Texture regions
are aspect-preserving crops, so differently sized hazards do not squash the
source art. Broad passages use the same upper/lower bramble grammar instead of
stretching two circular gate halves. `ArtAssetCatalog` is the single runtime
registry. Other course generation, route width, lethality, and spider physics
are unchanged.

Source specifications, processing, and hashes live in
`assets/source/forest-biome/README.md`.
