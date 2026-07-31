# Spider sprite reference manifest

> **Status:** `reference`
>
> Last reviewed: 2026-07-31. Runtime pixels are generated production assets;
> no third-party photograph or illustration was copied into these files.

## Shared generation contract

All five assets use the project-owned finished Garden/Anchorite images and
owner-approved generated candidates as internal visual references. The built-in
OpenAI image workflow generated or edited the candidates under Menno's art
direction. No external image URL was supplied to the image model. The final
chroma sources were converted locally to transparent RGBA with a soft matte and
despill, then checked at 384×181 and at the 96×46 runtime footprint.

Internal generated references are project assets rather than third-party works:

| Reference | Creator / rights basis | Permitted use | Attribution |
|---|---|---|---|
| `classic-garden-spider.png` before the anatomy edit (SHA-256 `bfe1e6cf…`) | OpenAI built-in image workflow under Menno's direction; generated output governed by the applicable OpenAI service terms | Project use, editing, chroma extraction, downscaling | None embedded |
| `anchorite-burrowing-spider.png` (SHA-256 `9f1de779…`) | OpenAI built-in image workflow under Menno's direction; generated output governed by the applicable OpenAI service terms | Project use, editing, style reference, downscaling | None embedded |
| Owner-approved Skitter, Ballooner, and Springtail candidates | OpenAI built-in image workflow under Menno's direction; generated output governed by the applicable OpenAI service terms | Project use, anatomy correction, chroma extraction, downscaling | None embedded |

Real-world identity and taxonomy were checked against the cited factual sources
in `docs/product/spider-biology-folio.md`. Those sources informed
non-copyrightable species and behaviour facts; none of their image pixels was
ingested, traced, or reproduced. Therefore there is no external image creator,
image licence, permitted-transformation grant, or in-game image attribution to
carry for this set. If a future pass supplies an external image to the
generator, add its exact URL, creator, per-file licence, access date,
transformation grant, and required attribution here before committing the
result.

## Delivered assets

| Runtime file | Production prompt summary | Final SHA-256 |
|---|---|---|
| `classic-garden-spider.png` | Preserve the dark-furred orange-banded Garden identity; correct only the 2D leg staging to four near-side legs plus two recessed far-side front legs; hide the other far-side pair | `411e7d24acd2e0f88d12d737bfd9a7634af39d16c575debf9b46005b4ecada51` |
| `skitter-magnolia-jumper.png` | Slender pale translucent olive *Lyssomanes viridis*, alert salticid face, red-orange crest and pale mask, six-visible-leg side-profile convention | `b742ba4e7b804f84fe3919583dd2d3884a424fdec0a82268cad8a3c2c1900545` |
| `anchorite-burrowing-spider.png` | Broad low charcoal-and-bronze burrowing mygalomorph with heavy matte mass | `9f1de7799ca0a3e78aebe5317418106aba61c4d9c02a2e6cd88c832166763175` |
| `ballooner-spider.png` | Pale silver/cream lightweight spider in raised tiptoe ballooning-launch stance, longest and finest legs in the roster | `3161722a932c73a22d97939539a355e787df88e8a6447443b968b922b07ceae9` |
| `springtail-trapdoor-spider.png` | Compact glossy amber trapdoor-spider cuticle, thick spiny legs in a compressed guarded stance | `bfd78bbe637c5c6e42fb1827d5078a1dd4fa0a9c75425e5b306c8b777e4b7b9c` |

The six-visible-leg convention is a presentation choice, not a biological
claim: every character remains an eight-legged spider, with the two far-side
rear legs occluded by its body in the right-facing 2D view.
