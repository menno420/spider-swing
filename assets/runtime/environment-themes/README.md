# Environment theme textures

> **Status:** `prototype-runtime-art`

Four 384×384 WebP material tiles are shipped for the Phase 0.15 visual
comparison:

- `ancient-forest.webp`
- `mossy-ravine.webp`
- `overgrown-greenhouse.webp`
- `reclaimed-attic.webp`

`EnvironmentThemeCatalog` is the one runtime registry. `SwingLabView` maps these
textures over the authoritative world polygons with world-space UVs, so camera
movement does not make the material slide and theme changes cannot alter
collision.

These are generated prototype assets, not approved production art. Their exact
generation prompts, processing notes, and hashes live in
`assets/source/environment-themes/README.md`.
