# Bramble Canopy finished-art source record

> **Status:** `candidate-production-source-record`

Eight original assets were generated with OpenAI image generation on 2026-07-31
after inspecting the existing Ancient Forest runtime pack and Menno's four
5000 m Android recordings. The recordings supplied gameplay evidence only;
they were not copied into any asset. The Ancient Forest images were supplied as
internal style, material, lighting, and mobile-scale references. No third-party
image was copied.

Isolated sources requested a perfectly flat `#ff00ff` chroma background. The
first six used that exact key. The two follow-up obstacle sources rendered
slightly shifted flat keys (`#f802f0` and `#fb02fa`), which the image-generation
skill's border sampler measured rather than pretending they were exact.
`remove_chroma_key.py` used a soft matte and despill; ImageMagick then performed
only alpha trim, transparent padding, and aspect-preserving resize. The opaque
far backdrop was downscaled directly. Source canvases are represented by
SHA-256 rather than committed because Godot imports only the inspected runtime
files.

## Shared direction

- realistic painterly 2.5D miniature forest matching Ancient Forest's finish;
- a younger, brighter high canopy with lime-gold leaves, braided vines, and
  conspicuous pale thorns;
- clear silhouettes at a 1280×720 phone viewport with an uncluttered central
  sightline;
- no text, UI, characters, pickups, frames, or apparent extra collision;
- foreground alpha sources contain one isolated asset on chroma.

## Runtime provenance

| Asset | Generation specification | Source SHA-256 | Runtime SHA-256 |
| --- | --- | --- | --- |
| `bramble-backdrop-far.webp` | Sunlit high-canopy clearing, open misty centre, interlaced thorn branches and lime-gold foliage around the outer frame, no foreground hazards. | `064ab3bd0a839b0b11e399e8bf38ce5f7f430745fe3bc3eec1dd4993859d7e3a` | `d2333f8ed5ff3f6f14e92bebdd8d2051a281ff8543ae746840ace8b66548329c` |
| `bramble-backdrop-mid.png` | Transparent edge layer of twisted young trunks and long thorn limbs, dense only near the outer edges, completely open central route. | `1bcabc5d0f165bbf366d90d66cbe492cf991590c2664d8e2394a0305bfc848d4` | `e9576455bf276491ac44a3d79caa35758cf8baa1c8092e70a73778c0fd680ae0` |
| `canopy-vine-rail-tile.png` | Long side-on band of braided younger vines, broad leaves, moss, and pale thorns, with continuous collision-facing edge and repeatable end structure. | `fe8ca7acebc2b8eacdbfad51e061d6f3f3ce5008372dffdce83014d00c5bf37c` | `f9d419d4235cbbec6a4ac16e392942576c04d747307c59feab1d82989e93c8ef` |
| `canopy-growth-socket.png` | Low wide leafy vine collar that visually joins one hazard to its supporting rail without an independent obstacle silhouette. | `956057d7e4ad6821d91f84f75033e7b6b88b083216c6122fa9375e66a30d81e5` | `cc80bf99eb6c947ae9d60d4c24a2677f65ac737481f9e57a67e8635fb3431a67` |
| `canopy-thorn-bramble.png` | Compact leafy thorn mound with broad rooted base, intertwined vines, two asymmetric crowns, and no false opening. | `6ebab0238b202891f3d14b2f24602c26e8381551c089c26bcd2474d8eac1350a` | `ced57e5134477cafee77023ed5d0d007e29991e38555e5d29fb5730a6e2767aa` |
| `canopy-seed-pod-vine.png` | Broad top knot, tapering leafy thorn vines, one large ribbed seed pod, and a pointed readable lower silhouette. | `cabec97ecc9bad7449bbee98b84e8ddfe7125db22cc56607320b3d2f389aea22` | `bb32f95f315d3966d066b3596a4dd874bc309bababcf5c42dbc0f02bc77ce774` |
| `canopy-hook-vine.png` | One floor-rooted braided vine bending sideways into a large shepherd's-hook/question-mark silhouette with an open concave pocket; explicitly not a mound, stump, pod, fork, or straight column. | `48bc14c9d889af380dc7fb16537b57d8003085af0644e1d2a689ea1e0a834bc1` | `42ac6e8019726cfb78916b792d478776387bd6894ec0fa1b80ce437680c8f5ca` |
| `canopy-leaf-shutter.png` | Five-to-seven enormous overlapping pointed leaves on thorn-vine ribs, forming one solid diagonal folding-fan barricade from a compact rail-rooted base; explicitly not a round cluster, mound, pod, stump, pillar, or hook. | `c0f9f0f17dfeba0d3360a4b95ab5f4b24c229b551fd511f66c8152e7198e9e35` | `4b4db7afe644a55dea00b60518743b5dfbc0b8cd6ed829aa89a8d9632ba2745f` |

Phone-scale composition review kept the centre brighter and more open than
Ancient Forest but applies a green-dark runtime modulation so the white web,
dark spider, golden flies, and thorn edges retain contrast. Collision outlines
and route envelopes—not the raster silhouettes—remain the geometry proof.

The follow-up hook and shutter were also compared together in a 1280×720
phone-scale composition over the exact runtime backdrop and rail textures. The
hook retained its concavity and the shutter retained its diagonal leaf-fan read
after minification and mirroring; neither collapsed into the old mound/pod
silhouette family.
