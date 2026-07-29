# Ancient Forest finished art

> **Status:** `candidate-production-runtime-art`

- `ancient-branch-ceiling.png` decorates the collision-facing edge of both
  ceiling and floor polygons; floor segments use a vertical mirror.
- `thorn-bramble.png` visualizes floor-grown and broad edge-grown hazards.
- `hanging-thorn-vine.png` visualizes tall top-anchored hazards.
- `thorn-root-gate.png` visualizes the existing four-piece safe-opening gate as
  one continuous natural object.

`SwingLabView` draws a dark collision shadow behind obstacle alpha, uses these
sprites only for Ancient Forest, and exposes exact collision outlines only in
DEBUG. `ArtAssetCatalog` is the single runtime registry. Course generation,
route width, collision polygons, and lethality are unchanged.

Source specifications, processing, and hashes live in
`assets/source/forest-biome/README.md`.
