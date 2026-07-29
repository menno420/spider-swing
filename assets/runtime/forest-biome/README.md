# Ancient Forest finished art

> **Status:** `candidate-production-runtime-art`

- `ancient-branch-rail-tile.png` is the active continuous ceiling/floor surface.
  World-anchored UVs keep its bark and moss aligned through chunk seams and
  shaped profiles; floor profiles use a vertical mirror.
- `mossy-growth-socket.png` covers the contact between a wall-grown obstacle and
  its rail with roots, moss, and a restrained contact shadow.
- `thorn-bramble.png` visualizes floor-grown and broad edge-grown hazards.
- `hanging-thorn-vine.png` visualizes tall top-anchored hazards.
- `fallen-root-stump.png` gives later stump patterns a distinct natural
  silhouette instead of another stretched bramble.
- `forest-backdrop-far.webp`, `forest-backdrop-mid.png`, and
  `forest-backdrop-near.png` form a low-contrast three-depth forest behind the
  playable silhouettes.

`ancient-branch-ceiling.png` is retained as a recoverable earlier candidate but
is no longer registered as active runtime art.

`SwingLabView` uses these assets only for Ancient Forest and exposes exact
collision outlines only in DEBUG. Every wall-grown sprite and growth socket
extends behind the rail, then the rail is redrawn over the join. Texture regions
are aspect-preserving crops, so differently sized hazards do not squash the
source art. Broad passages use the same upper/lower bramble grammar instead of
stretching two circular gate halves. `ArtAssetCatalog` is the single runtime
registry. The background is presentation-only and never hides or defines
collision.

Source specifications, processing, and hashes live in
`assets/source/forest-biome/README.md`.
