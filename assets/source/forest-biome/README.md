# Forest biome finished-art source record

> **Status:** `candidate-production-source-record`

Six original assets were generated with OpenAI image generation on 2026-07-29
and reviewed individually at source and gameplay scale. The previously generated
Spider Swing environment concept was supplied only as an internal style,
lighting, material, and scale reference. No third-party image was copied into an
asset.

Every source used a perfectly flat `#ff00ff` chroma background. The background
was removed with the image-generation skill's `remove_chroma_key.py` using
border auto-key, soft matte, thresholds 12/220, and despill. Runtime images were
alpha-trimmed, padded by 8 pixels, and downscaled with ImageMagick. Full
generation canvases are represented here by their SHA-256 rather than committed:
Godot would otherwise import roughly 9 MiB of regeneration input that the game
never loads.

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
- runtime: `assets/runtime/forest-biome/split-thorn-root-gate.png`
- runtime SHA-256:
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
