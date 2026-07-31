# Character runtime art

The five playable profiles use finished right-facing 384×181 RGBA sprites:

- `classic-garden-spider.png` — dark fur, orange banding, balanced silhouette;
- `skitter-magnolia-jumper.png` — slender translucent-green jumper;
- `anchorite-burrowing-spider.png` — broad charcoal/bronze mygalomorph;
- `ballooner-spider.png` — pale, long-legged tiptoe launch stance;
- `springtail-trapdoor-spider.png` — compact glossy amber trapdoor build.

Every sprite follows the deliberate side-profile occlusion convention: four
complete near-side legs, two recessed far-side front legs, and both far-side
rear legs hidden behind the body. This keeps the biological eight-leg truth
without turning the 2D silhouette into an unreadable limb cluster. See
`REFERENCE-MANIFEST.md` for generation and visual-reference provenance.

Each sprite rotates with presentation velocity and scales around its profile's
authoritative collision radius. All are imported with mipmaps because the
384-pixel sources are normally drawn at roughly one quarter of that size.
Presentation interpolates fixed-step positions and applies only restrained
action-state pose scaling; DEBUG still shows the exact collision circle. Skitter,
Ballooner, and Springtail no longer take the procedural fallback during normal
play; that fallback remains fail-safe behavior for a missing texture.
