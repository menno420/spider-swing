# Second research report — verification and adoption

> **Status:** `complete`

## Goal

The owner supplied a second, longer version of the spider deep-research report
and asked whether it contains new information, then to verify its claims as far
as possible and document what is valuable in the repository.

## Scope guard

Research verification, data, and documentation. No physics, collision, economy,
upgrade, or tuning value changed. No new profile, no new mechanic. Also resolved
a real merge against main, which moved twice during the session.

## Previous-session review

**previous-session review:** PR #50 merged, landing `SpiderBiologyCatalog`, the
Garage inspiration strip, the Field Guide and the folio. PR #53 (Buckler rename
plus first-class fictional spiders) was open and green on this same branch. Main
then advanced twice — #51 claimed the art work and #52 shipped the five-spider
production roster — which is what produced the merge resolved below.

## What the report actually is

Two uploads, **byte-identical** (md5 `b40daf36…`) — one document, not two. It is
the same research restructured and about 80% longer (2,119 lines vs 1,157;
atlas 105 rows vs 66).

**It reproduces all five approved mappings independently.** Its §15.7 reaches
exactly what the folio already records. That is corroboration, not new scope.

**But its citations do not resolve.** It carries 84 bracketed keys —
`[B01]`–`[B90]`, `[M01]`–`[M10]` — across 93 lines, and ends at §17 with no
register defining any of them. The first report's §19 source list with 31
working URLs did not survive the rewrite. So nothing in it could be taken on
trust.

## Verification

Nine claims re-verified independently against the World Spider Catalog,
peer-reviewed papers (ZooKeys, J. Exp. Biol., Science), the AMNH digital
library, and US Fish & Wildlife. **All nine confirmed**, with one qualification
recorded (*Thwaitesia*'s patch-size change is reported, not established).

Full log with verdicts, and an explicit list of what was *not* checked:
`docs/product/spider-biology-verification-2026-07-31.md`.

## Shipped

- **Buckler's armour reference is now *Cyclocosmia*.** Its abdomen ends in a
  hardened ribbed disc used to plug its own burrow (phragmosis). This is a
  better story than *Ummidia* alone and it sharpens the disclosure, because the
  real function is a **door, not a shield** — which is precisely not the impact
  armour the mechanic invents. Cited to Godwin & Bond 2018 and AMNH *Novitates*
  2580.
- ***Erigone atra*** named as Ballooner's documented example, cited to Weyman
  1994. The record stays `behaviour` and claims no species.
- **Two taxonomy corrections** carried into the folio's parked list so a future
  session cannot reuse superseded names: *Sicarius* → ***Hexophthalma*** for the
  southern African six-eyed sand spiders (genus revalidated 2017), and
  *Deinopis* → ***Asianopis*** for Asian/Australasian net-casters (ZooKeys 890,
  2020).
- **Four verified backlog candidates** with the source actually checked:
  *Toxeus magnus*, *Theridiosoma gemmosum*, *Thwaitesia argentiopunctata*,
  *Adelocosa anops*.
- **A tenth biology contract** — a registered source that nothing cites now
  fails the build. The suite already refused a cited id with no entry; this
  closes the other direction, which is the failure mode the second report
  demonstrates.
- `docs/decisions.md` — **D-0029** (re-verify research claims before they reach
  shipped data). `docs/current-state.md` updated.
- Build identity `0.18.0-buckler-test`, Android version code 34.

## Merge against a moving main

Main advanced twice mid-session: #51 claimed the art work, then **#52 shipped
the five-spider production roster**. That produced a real merge, including a
semantic break the text merge could not see: #52 added
`SpiderCatalog.SPRINGTAIL: SPRINGTAIL_SPIDER` to `ArtAssetCatalog`, a constant
this branch removes. Resolved:

- `art_asset_catalog.gd` rewired to `SpiderCatalog.BUCKLER: BUCKLER_SPIDER`.
- **My decision entry renumbered D-0027 → D-0028.** #52's "occlude two far-side
  rear legs" landed first and owns D-0027; the ledger is append-only.
- Build identity bumped past main's `0.17.0-five-spider-art-test` / code 33.
- Verified that none of #52's contracts were lost in the merge by diffing the
  test-function lists against `origin/main` — identical.
- Asset **filenames** keep the `springtail-` spelling, matching the reasoning
  used for the persisted profile id: they are internal keys, the reference
  manifest binds filename to SHA-256, and no player sees either.

## Deliberately not done

- **No renaming of the shipped PNG files.** Same reasoning as the profile id;
  renaming would churn a checksum-tracked artifact a sibling session just
  landed, for nothing a player can see.
- **Anchorite palette refinement** (*Aphonopelma hentzi* / *Grammostola
  pulchra*). Plausible, but the sprite is approved and the composite mapping
  does not depend on which theraphosid is named.
- **~15 further atlas taxa** left unverified and unadopted, and recorded as
  such — an unchecked claim that looks checked is the failure D-0029 prevents.

## Verification run

`python3 tools/verify.py --require-godot` green against Godot 4.7.1 stable —
**108 contracts passing** (49 physics, 10 biology, 22 HUD layout, 17 front-end
flow, 10 project/engine). `python3 bootstrap.py check --strict` green. Field
Guide copy rendered headlessly and read back to confirm the new Buckler and
Ballooner entries.

## Open owner questions (parked, not blocking)

1. Release roster — fictional names throughout, species names, or the current
   mix?
2. Field Guide reach — Garage-only (as shipped), or also linked from Home?
3. New, from the report's §16.4: who approves scientific claims, medical
   wording, and image licences before anything is published? Not urgent while
   nothing ships externally.

## 💡 Idea

*Cyclocosmia* is the proof of the on-ramp pattern the folio describes: an
invented profile (Buckler) now points at a real animal that is stranger than the
invention. Worth making that the template — when a fictional profile lands, give
its Field Guide entry a "the real thing" line that names the animal the fiction
borrowed from, and let the correction do the teaching.

- **📊 Model:** opus-5 · high · research verification
