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

- Compact, short-legged, big-headed **jumping spider** proportions; body
  clearly smaller than Garden's.
- **Pale translucent olive-green** overall — glassy, lightly-furred legs
  (contrast with Garden's heavy dark fur).
- Two oversized dark anterior eyes with strong speculars; a **red-orange
  crest** between the eyes; **pale/white facial mask** below them.
- Reads as: small, quick, alert. Trade-off text: "changes pace quickly,
  fits tighter gaps."

## Ballooner — tiptoeing ballooning spider (money-spider/crab-spider build)

Real ballooning spiders launch from a "tiptoe" stance, spinnerets up,
riding silk. Make that the identity.

- **Slender, light** body; the **longest and finest legs** in the set, in a
  raised tiptoe posture (mid-launch feel even in the static pose).
- **Pale silver/cream** with a cool satin sheen; faint darker dorsal
  pattern; optionally one or two barely-visible silk strands rising from
  the spinnerets (must survive chroma keying cleanly, else omit).
- Reads as: light, floaty, delicate. Distinct axis: silver + slender +
  long-legged.

## Springtail — amber trapdoor spider (glossy armour)

"Springtail" is the game name, not a species (real springtails are not
spiders — do not draw one). The gameplay identity is the one-bounce
**Impact Carapace**, so pick the armoured spider: a trapdoor spider.

- **Stout, compact** body with a visibly **glossy, hard sclerotized
  carapace** — polished highlights where the others have matte fur.
- Thick spiny legs held in a slightly **compressed, coiled-spring stance**.
- **Warm amber/rust/bronze** palette (the owner's Grok notes: "warm amber
  springy").
- Reads as: guarded, springy, armoured. Distinct axis: gloss + amber +
  compact.

## Acceptance checklist (run before opening the PR)

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

## What already failed (do not repeat)

- External Grok renders (2026-07-31): unusable output despite a good
  reference brief; the owner explicitly gave up on that route.
- Procedural code-drawn painting (same day, this repo's review session):
  one honest attempt could not approach the painterly fur bar set by the
  finished pair — fine for placeholders, not for production identity art.
