# Production sprite briefs — Skitter, Ballooner, Springtail

> **Status:** `plan`
>
> Owner-requested (2026-07-31): the three remaining spiders need production
> sprites that look **quite real** and each resemble a real species, with
> room for cartoonish purchasable skins later. External tools (Grok) failed
> to deliver usable renders; the in-house pipeline that produced the
> approved Garden Spider and Anchorite sprites is the route. Execute in an
> image-generation-capable session; integration/QA can be done by any
> session.
>
> **Corrected 2026-07-31** against the owner's deep-research report. Identity
> claims — which species, how strong the claim, what may be said about it —
> belong to `docs/product/spider-biology-folio.md`, which wins over this file.
> The Skitter anatomy below was wrong and has been fixed; do not produce art
> from an older revision of this brief.
>
> **Executed 2026-07-31:** the owner approved all three generated candidates.
> Their transparent runtime files, shared renderer routing, and reference
> manifest ship with the Garden anatomy correction in PR #52.

## The set rules (non-negotiable for cohesion)

- Right-facing side profile on a flat disposable chroma background,
  delivered as a transparent **384×181** PNG (Anchorite recipe, D-0021 /
  CAPABILITIES 2026-07-30 entry: generate on chroma key → key to alpha
  locally → inspect source AND 96×46 gameplay scale before integration).
- Match the two finished sprites: painterly-realistic, visible fur/texture
  detail, soft top-left rim light, grounded leg spread, no cast shadow.
- Every spider must be identifiable at the 96×46 gameplay footprint by
  **silhouette and palette alone**. The set's differentiation axes are
  already spent as: Garden = dark fur + orange-banded legs; Anchorite =
  broad low matte-dark tarantula. Do not reuse those combinations.

## Skitter — Magnolia Green Jumper (*Lyssomanes viridis*)

The owner's own reference research (Grok session, 2026-07-31) landed here
and it is the right call: a real, common, leaf-coloured jumping spider.
This is the one profile carrying a **species-level** claim, so the anatomy
has to survive a reference check.

- **Slender and long-legged** for a jumping spider — *Lyssomanes* is not the
  stocky salticid build. Delicate, lightly-furred limbs held in a wide alert
  stance; body clearly smaller than Garden's, legs proportionally longer.
- **Pale translucent olive-green** overall — glassy, almost backlit (contrast
  with Garden's heavy dark fur).
- Big-headed salticid face with two oversized dark anterior eyes and strong
  speculars; **verify the red-orange crest and pale facial mask against
  reference for the sex being drawn** before committing — the facial markings
  are sex-variable.
- Reads as: small, quick, alert. Trade-off text: "changes pace quickly,
  fits tighter gaps."

> **Superseded direction:** an earlier revision of this brief said "compact,
> short-legged". That is a different genus and would have made a
> species-labelled sprite anatomically wrong. Slender wins.

## Ballooner — tiptoeing ballooning spider (money-spider/crab-spider build)

Real ballooning spiders launch from a "tiptoe" stance, spinnerets up,
riding silk. Make that the identity — **the behaviour, not a species**.
Ballooning happens across many families and mostly in small spiders and
spiderlings, so this sprite is a readable symbol for a behaviour. It must
never be captioned as "the ballooning spider", and no binomial goes near it.

- **Slender, light** body; the **longest and finest legs** in the set, in a
  raised tiptoe posture (mid-launch feel even in the static pose).
- **Pale silver/cream** with a cool satin sheen; faint darker dorsal
  pattern; optionally one or two barely-visible silk strands rising from
  the spinnerets (must survive chroma keying cleanly, else omit).
- Reads as: light, floaty, delicate. Distinct axis: silver + slender +
  long-legged.

## Springtail — amber trapdoor spider (glossy armour)

"Springtail" is the game name, not a species (real springtails are
Collembola — six-legged hexapods, not arachnids; do not draw one). The
gameplay identity is the one-bounce **Impact Carapace**, so pick the
armoured spider: a cork-lid trapdoor spider (*Ummidia*). Draw armour that
reads as **sclerotized cuticle**, not as beetle plates or a visible spring —
the bounce is fiction and the art must not argue for it.

- **Stout, compact** body with a visibly **glossy, hard sclerotized
  carapace** — polished highlights where the others have matte fur.
- Thick spiny legs held in a slightly **compressed, coiled-spring stance**.
- **Warm amber/rust/bronze** palette (the owner's Grok notes: "warm amber
  springy").
- Reads as: guarded, springy, armoured. Distinct axis: gloss + amber +
  compact.

## Acceptance checklist (run before session close and merge)

1. Source PNG is 384×181 with clean alpha (no chroma fringe; inspect edge
   pixels).
2. Side-by-side at 96×46 with `classic-garden-spider.png` and
   `anchorite-burrowing-spider.png`: all five distinguishable by
   silhouette/palette at a glance; none reads as a recolour.
3. Wire through `ArtAssetCatalog` like Anchorite (profile-radius scaling
   preserved; presentation only — no collision change), add the asset
   registration to the existing mobile-HUD asset contract, and prove the
   Android artifact embeds the textures.
4. Owner device review judges species readability, contrast, and edge
   quality — the same gate Anchorite is currently under.
5. Each finished sprite has a reference manifest: for every image consulted,
   record URL, creator, licence, access date, permitted transformations, and
   the attribution string. Wikimedia licences are per-file; museum imagery is
   not automatically reusable; figures in open-access papers can still be
   separately copyrighted.
6. The species claim in `game/domain/spider_biology_catalog.gd` still matches
   the delivered art. If the sprite drifted to a composite, downgrade the
   record's `inspiration` rather than shipping false precision.

## What already failed (do not repeat)

- External Grok renders (2026-07-31): unusable output despite a good
  reference brief; the owner explicitly gave up on that route.
- Procedural code-drawn painting (same day, this repo's review session):
  one honest attempt could not approach the painterly fur bar set by the
  finished pair — fine for placeholders, not for production identity art.
