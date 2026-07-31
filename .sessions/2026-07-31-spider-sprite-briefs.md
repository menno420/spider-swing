# Spider sprite briefs session

> **Status:** `complete`

## Goal

Turn the owner's failed external sprite attempts into an executable
in-house plan: verified capability findings for this seat, plus complete
species design briefs and an acceptance checklist for the three missing
production sprites (Skitter, Ballooner, Springtail), routed to the
image-generation-capable seat that produced Anchorite.

## Scope guard

Documentation only: the brief doc, this card, and ledger touches. No
gameplay value, asset, contract, or build identity changes.

## Previous-session review

**previous-session review:** PR #47 landed the reserve Burst breakthrough
green (93 contracts) after the owner's device approval of the corrected
Reel; a sibling session added seeded course regions and checkpoint practice
to the lab (PR #48). The owner then tried generating spider sprites with
Grok (2026-07-31 recording), judged the results unusable, and asked whether
this session can produce realistic species-true sprites instead.

## Shipped

- `docs/ideas/spider-sprite-briefs.md` — ready-to-execute briefs: set
  cohesion rules (right-facing 384×181 chroma-key pipeline per the
  Anchorite recipe, painterly bar, 96×46 silhouette/palette
  distinguishability), species designs — Skitter as the Magnolia Green
  Jumper the owner's own research selected, Ballooner as a tiptoeing
  silver ballooning spider, Springtail as an amber glossy trapdoor spider
  (armour matching the Impact Carapace identity; real springtails are not
  spiders and must not be drawn) — an acceptance checklist ending at the
  owner device gate, and a record of the two already-failed routes.
- `docs/CAPABILITIES.md` — dated wall: this Claude Code seat has no
  image-generation tool (registry search verified; one procedural attempt
  honestly judged below the bar), with the workaround: generation routes to
  an image-capable seat; this seat runs the full downstream pipeline.

## Decisions flagged

- The Anchorite art capability is recorded as seat-scoped, not fleet-wide —
  exactly the venue-scoping the ledger's posture rule warns about.
- Springtail's brief deliberately breaks from its literal name (springtails
  are Collembola, not spiders); the armoured trapdoor spider expresses the
  gameplay identity instead. Owner can veto in the brief before execution.

## 💡 Idea

When the art seat executes the briefs, generate each spider's later
"cartoonish skin" variant in the same session from the approved realistic
source (style-transfer prompt on the same silhouette) so the paid-cosmetic
pipeline is proven cheap while the reference is fresh.

- **📊 Model:** fable-5 · high · docs-only

## Capability delta

One new wall with workaround appended to `docs/CAPABILITIES.md` (no image
generator in this seat; generation is seat-routed, integration stays here).
Pillow installs and runs in-container — used for the honest procedural
attempt and available for future keying/QA work.

## Verification evidence

- `python3 tools/verify.py --require-godot` on pinned Godot
  4.7.1.stable.official.a13da4feb: all steps PASS, 93/93 contracts
  (docs-only change; suite untouched).
- Strict Substrate check with CI's exact added-card invocation: all checks
  passed with this card complete; guard-fire telemetry delta committed.
- The failed procedural Skitter render was shared with the owner as
  evidence rather than asserted.

## Documentation audit

The brief doc, the CAPABILITIES wall entry, and this card agree: generation
is routed, integration stays here, and the acceptance gate ends at the
owner's device review like every other art slice.

## Remaining owner review

Read `docs/ideas/spider-sprite-briefs.md` and veto or adjust any species
choice (especially Springtail's trapdoor-spider direction) before an
art-capable session executes it.
