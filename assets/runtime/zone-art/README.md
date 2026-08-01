# Zones 3–8 runtime art

These transparent PNGs are presentation overlays for authoritative code-built
geometry. `ArtAssetCatalog` is the sole runtime registry. Backdrops render at
the 1280×720 reference size and alternate mirrored tiles; obstacle art is
aspect-preserving or aligned to the polygon's long axis. An explicitly mapped,
loaded texture replaces the prototype collision-colour fill and keeps only a
restrained target/lethal rim; an unmapped or missing texture falls back to the
honest collision fill. The cyan authoritative outline remains available in the
development collision-overlay mode.

The renderer selects these assets by `CourseGeometry` visual ids. It does not
infer a zone from polygon shape, and no raster controls collision, motion,
anchor eligibility, force, reward, or settlement.

Generation, dimensions, anchor state, hashes, alpha QA, and the 25% silhouette
result live in `assets/source/zone-art/README.md` and
`docs/visual/zones/zone-art-audit.json`.
