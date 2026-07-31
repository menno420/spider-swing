# Spider biology layer and Field Guide session

> **Status:** `complete`

## Goal

Review the owner's deep-research report on real spider diversity against the
live repository, decide which findings are actually worth acting on now, and
land those — without expanding the roster or touching the physics that Phase 0's
owner-judged feel gate is still holding.

## Scope guard

Content and presentation only. No simulation, collision, economy, upgrade, or
tuning value changed. No new profile. No new mechanic. The research's own
strongest recommendation — keep swinging authoritative and let biology be a
content identity layer — is the constraint this session worked inside.

## Previous-session review

**previous-session review:** PR #49 landed the executable sprite briefs for
Skitter, Ballooner, and Springtail; PR #48 landed seeded regions and checkpoint
practice. The owner then supplied a deep-research report (31 July 2026) on
spider biology and educational game design, and asked which of it is valuable
and to continue improving the game on that basis.

## What the report was right about, and what was acted on

The report's central finding is that the five profiles already teach biology
whether the game intends to or not — they carry real-spider names and
real-spider art — and that two claims are wrong as shipped. Both were fixed:

- **Springtail names an animal that is not a spider.** Real springtails are
  Collembola, six-legged hexapods. The name stays (that is the owner's call);
  the game now says so.
- **Ballooner's steerable glide reads as spider flight.** Ballooning is one-way
  dispersal, mostly by small spiders and spiderlings. The game now discloses the
  glide as invented.

The third acted-on finding was cheaper still and would have cost real work if
missed: **the Skitter sprite brief said "compact, short-legged" while naming
*Lyssomanes viridis*, which is slender and long-legged.** That art had not been
produced yet. Correcting the brief before production was the highest
value-per-line item in the whole review.

## Shipped

- `game/domain/spider_biology_catalog.gd` — one record per profile: inspiration,
  claim strength (`species` / `composite` / `behaviour` / `fictional`), observed
  real-world trait, explicit game-adaptation disclosure, myth correction, cited
  sources, accepted-name authority, review date. Shares no key with
  `SpiderCatalog`; only a species-level claim may state a binomial.
- Garage detail card now names the selected spider's inspiration and its claim
  strength, and routes to a new scrollable **FIELD GUIDE** screen that keeps
  game identity, inspiration, real biology, and game adaptation on separate
  labelled lines.
- `tests/unit/spider_biology_tests.gd` — nine contracts: profile/record parity,
  classification validity, a real disclosure on every record, no binomial
  without a species claim, the Collembola correction, the ballooning/flight
  separation, resolvable sources, the two tables staying disjoint in both
  directions, and the Garage summary carrying its classification.
- `tests/integration/front_end_flow_tests.gd` — the Field Guide route contract:
  Garage names an inspiration, routes to the guide, every profile has an entry
  carrying all three lines, the guide is a vertical touch scroller, and back
  returns to the Garage.
- `docs/product/spider-biology-folio.md` — the approved mappings with reasoning
  and sources, editorial voice, art and reference-licensing rules, and the
  parked candidate backlog (*Selenops*, *Dolomedes*, *Argyroneta*, temporary
  modes, biome inhabitants) explicitly marked ideas-not-scope.
- `docs/ideas/spider-sprite-briefs.md` — Skitter anatomy corrected to slender
  and long-legged with the superseded direction recorded; Ballooner reframed as
  behaviour-level; Springtail's armour constrained to sclerotized cuticle; a
  reference-manifest and claim-still-matches-art step added to the acceptance
  checklist.
- `docs/decisions.md` — D-0026. `docs/current-state.md` — baseline, in-flight,
  and recently-shipped updated.
- Build identity `0.16.0-field-guide-test`, Android version code 32.

## Deliberately not done

- **No roster expansion.** *Selenops* and *Dolomedes* are the report's strongest
  new-profile candidates and both are parked in the folio. The feel gate is
  open; a new profile now would be scope the owner has not bought.
- **No new mechanics.** Net-cast, bolas, spitting, and triangle-web tension are
  recorded as temporary-mode ideas, not planned.
- **No rename.** Springtail keeps its name plus a disclosure — the cheapest
  honest option and reversible in one line. Renaming is a branding call.
- **No medical or safety content.** The current five carry no medical claims,
  which is the correct amount. Regional health authorities own that material.

## Verification

`python3 tools/verify.py --require-godot` green against Godot 4.7.1 stable:
architecture self-test and scan, headless import, boot smoke test, and
**107 contracts passing** (49 physics, 9 biology, 22 HUD layout, 17 front-end
flow, 10 project/engine). Garage layout headroom measured in a 1280×720
subviewport for all five profiles: 54–70 px spare, nothing overflows.

## Open owner questions (parked, not blocking)

1. Springtail — keep the fictional name plus its disclosure, or rename it?
2. Release roster — fictional names throughout, species names, or the current
   mix?
3. Field Guide reach — Garage-only (as shipped), or also linked from Home?

## 💡 Idea

The Field Guide already renders from data, so the cheapest next educational
step is not a new screen: give `SpiderBiologyCatalog` an optional `fact` list
and let the results screen surface one unseen entry every few runs, weighted to
the profile just played. Same table, same disclosures, no new content pipeline
— and it stays skippable, which is the difference between a field guide and a
loading-screen trivia box.

- **📊 Model:** opus-5 · high · feature build
