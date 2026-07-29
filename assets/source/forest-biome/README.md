# Forest biome finished-art source record

> **Status:** `candidate-production-source-record`

Twelve original assets were generated with OpenAI image generation on
2026-07-29; ten are active runtime assets. The earlier single-branch rail and
dedicated split-gate raster are retained only as recoverable history. Every
active asset was reviewed individually, in repeated-tile or layered-composition
previews where relevant, and at mobile gameplay scale. The previously generated
Spider Swing environment concept was supplied only as an internal style,
lighting, material, and scale reference. No third-party image was copied into an
asset.

Isolated sources used a perfectly flat `#ff00ff` chroma background. It was
removed with the image-generation skill's `remove_chroma_key.py`, using an
explicit key for compositions whose foliage touched the border, then soft matte
and despill. The opaque far background was exported directly. Runtime images
were cropped and downscaled with ImageMagick as appropriate. Full generation
canvases are represented here by SHA-256 rather than committed: Godot only
imports the exact runtime files.

## Art direction shared by all six assets

- realistic painterly 2.5D miniature forest;
- warm dappled light, deep natural shadows, and no graphic outline;
- strong silhouette and material readability at 1280×720 mobile scale;
- isolated asset on chroma, with no UI, text, frame, cast shadow, or unrelated
  scene elements;
- visible art may decorate authoritative collision, but never define it.

## Ancient ceiling branch

Generation specification: one long, side-on old tree branch with cracked bark,
moss, warm highlights, enough wood mass to blend into a bark ceiling, and a
continuous collision-facing underside with only short rootlets. It spans nearly
the full canvas and has no perspective taper.

- source SHA-256:
  `8143367f6b02af3507929820e6955b33ce308ae7e00b85a2837f0c571ef569f3`
- runtime: `assets/runtime/forest-biome/ancient-branch-ceiling.png`
- runtime SHA-256:
  `a6eb7bdd47ebbda4aceceed126ca773ebb6d9e8412970053f09df27a6c928f00`

## Continuous ancient branch rail tile

Generation specification: one long side-on old branch band with cracked bark,
moss, root fibres, warm dappled highlights, and enough visual mass to read as
both ceiling and floor. Its left and right edges carry matching bark and moss
structure for repetition, while the collision-facing edge stays continuous and
free of long hanging pieces.

- source SHA-256:
  `eccf9eca581b462b8fc5f28fe368ed39a484a57f4fa03ef9329b75cb1c617675`
- runtime: `assets/runtime/forest-biome/ancient-branch-rail-tile.png`
- runtime SHA-256:
  `24198c4fe47c5d97e2a9ad3bd98b2fb24c856011afbbcaf01d33076252aa36dd`

## Mossy growth socket

Generation specification: one low horizontal root collar made from intertwined
roots, moss, tiny leaves, bark debris, and a restrained contact shadow. It has a
broad transparent base and no independent obstacle silhouette, so it only reads
as the transition between a hazard and its supporting branch.

- source SHA-256:
  `a1619b1708c0e8048346382a688b5222cb44ebd6726907ac41dfa6577bc4a7d9`
- runtime: `assets/runtime/forest-biome/mossy-growth-socket.png`
- runtime SHA-256:
  `a82002aa72724dbdec8bd82d236a13e4cbdc3b9e19c0ba33930db9707b80cc86`

## Fallen root stump

Generation specification: one side-on broken root stump with a wide embedded
base, a short asymmetric upward mass, cracked reddish bark, moss, small fungal
details, and restrained thorns. It contains no central opening or detached
debris and remains readable at roughly 180–245 world pixels.

- source SHA-256:
  `d0bab7d250581e79f25da60ebc5183521bca1e10c15192186ba72a33bc702b19`
- runtime: `assets/runtime/forest-biome/fallen-root-stump.png`
- runtime SHA-256:
  `efdf2267860c7c25aee5e725cc768941316c76921d375d7bf447494e6e257d6e`

## Layered forest depth

The far source is one complete misty old-growth forest with warm shafts of
light and no gameplay silhouettes. The mid source contains only isolated trunks,
branches, and hanging moss on chroma. The near source contains only restrained
edge foliage and roots on chroma; a second edit removed bright pollen and glow
that competed with flies.

| Layer | Source SHA-256 | Runtime | Runtime SHA-256 |
| --- | --- | --- | --- |
| far | `b0d96b72a399ab6295b8508b55adf9158e73a082a8a82dcc27ec18b56868e2fe` | `assets/runtime/forest-biome/forest-backdrop-far.webp` | `7f38e49940d12f6ca7dfa807880208da05f1a79b4217148bc9fab58848accf65` |
| mid | `69f5e46a8f107653a8c5db48a7b2e83529351877a532e6b1e655c828f09a581e` | `assets/runtime/forest-biome/forest-backdrop-mid.png` | `d31afea8fdc986f43683244f9fb6187ea64f9c720459966fb63feb39da612d4b` |
| near | `699f0436e6bb41b44338874096a9b8d5f03f820a97821a85f4640ef7e9985237` | `assets/runtime/forest-biome/forest-backdrop-near.png` | `1cfeb45eeb8e1c607d5ea4779a1cfd5ed817ecac827fea01ad38e0cabfe1055d` |

## Floor thorn bramble

Generation specification: one compact upward-growing bramble with a broad
rooted base, dense intertwined woody stems, a narrower forked crown, restrained
leaves and moss, and thick readable pale thorns. Its triangular mass contains no
opening that appears safely passable.

- source SHA-256:
  `61c8194ac0afa339d8d3d11f38db81753827fad7d771097fbfffd9a580399857`
- runtime: `assets/runtime/forest-biome/thorn-bramble.png`
- runtime SHA-256:
  `c06d290f2030bc2c87b26a647cbf166461687ecbbff6f9d488a47ac473a777c6`

## Hanging thorn vine

Generation specification: one top-anchored mass with a broad horizontal root
knot, dense tapering thorn vines, close-set leaves and moss, and a pointed
seed-pod tip. It has no detached pieces or false central route.

- source SHA-256:
  `c27e5e63d6a175ee4b34b95843dbce2285ac5b78a36f24c42ee0a0d5be8bf8ed`
- runtime: `assets/runtime/forest-biome/hanging-thorn-vine.png`
- runtime SHA-256:
  `7bcbff4e2f8501d1f364f681252d8673bc4ac032f3afc3906e75acddce979d14`

## Split thorn-root gate

> **Runtime status:** retired after `0.8.3-clean-forest-test`. Stretching the two
> circular halves across variable upper/lower obstacle rectangles visibly
> distorted them and made them read as floating pieces. The broad passage now
> uses the same rail-grown bramble/vine grammar as the rest of the biome.

Generation specification: preserve the Ancient Forest gate's bark, moss,
outward thorns, palette, and lighting, but replace its closed ring topology with
exactly two disconnected upper/lower arcs. Both sides remain completely open,
and the empty horizontal passage occupies roughly 45% of the full sprite
height. No branch, vine, thorn, shadow, or debris bridges the route.

The built-in image editor produced the source on a flat `#ff00ff` key. The
standard soft-matte/despill helper removed that key, then the result was
alpha-trimmed, padded by eight pixels, and reduced to the runtime size. The
superseded closed-ring runtime asset remains recoverable from PR #22.

- source SHA-256:
  `61838a6ae54fe7f7fa8083f66bff6e9a6f1272296dd760413028aa6d5a664a4b`
- retired runtime SHA-256:
  `dda9625bd3f8a61ab5bc9f69fabe26b8a1c05ce58d78224fd8281f4bbe6cc800`

## Classic Garden Spider

Generation specification: one real miniature jumping spider facing right, with
a compact fuzzy charcoal body, burnt-orange markings, sturdy separated legs,
large readable forward eyes, natural anatomy, and a momentum-ready pose. It
contains no superhero styling or human attributes.

- source SHA-256:
  `c169c4f28fc53197b1f1efb2a5cdbc0d7d17ab6c0a9183da204c381b81690f9b`
- runtime: `assets/runtime/characters/classic-garden-spider.png`
- runtime SHA-256:
  `bfe1e6cf8de49fbef448cd9b24bce75e640ba1906c25ea4792df069cd2fc2b71`

## Golden forest fly

Generation specification: one believable side-profile fly with a dark warm
thorax, glowing segmented amber abdomen, reddish compound eye, six close-set
legs, broad translucent veined wings, and a crisp silhouette at 24–30 pixels.

- source SHA-256:
  `e48f6e79651cb3a206e82ebd7b53e786011acc35c6daf9769e69ef0233426a47`
- runtime: `assets/runtime/collectibles/golden-forest-fly.png`
- runtime SHA-256:
  `ed03b99dd26c62d87ee5dc3ec485fb3be32e46148551635216768d1c0d5c1d41`
