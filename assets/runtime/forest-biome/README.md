# Ancient Forest finished art

> **Status:** `candidate-production-runtime-art`

- `ancient-branch-ceiling.png` decorates the collision-facing edge of both
  ceiling and floor polygons; floor segments use a vertical mirror.
- `thorn-bramble.png` visualizes floor-grown and broad edge-grown hazards.
- `hanging-thorn-vine.png` visualizes tall top-anchored hazards.
- `split-thorn-root-gate.png` contains matching upper and lower root arcs for a
  horizontally open, physically traversable gate.

`SwingLabView` draws a dark collision shadow behind obstacle alpha, uses these
sprites only for Ancient Forest, and exposes exact collision outlines only in
DEBUG. It maps each gate arc to its own authoritative polygon, so the visible
opening follows the editable gate-clearance value. `ArtAssetCatalog` is the
single runtime registry. Other course generation, route width, lethality, and
spider physics are unchanged.

Source specifications, processing, and hashes live in
`assets/source/forest-biome/README.md`.
