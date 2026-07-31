# Verification log — second deep-research report, 31 July 2026

> **Status:** `audit`
>
> The owner supplied a second, longer version of the spider deep-research
> report (2,119 lines vs 1,157; atlas 105 rows vs 66). **It ships 84 bracketed
> citation keys — `[B01]`–`[B90]`, `[M01]`–`[M10]` — and no register defining
> them.** The document ends at §17; the first report's §19 source register with
> 31 working URLs is gone.
>
> Nothing from an unresolvable citation may enter shipped data. This log records
> what was independently re-verified, against what, and what was adopted. Claims
> not listed here were not checked and must not be treated as sourced.
>
> Verified 2026-07-31. Two uploads were byte-identical (md5 `b40daf36…`) — one
> document, not two.

## 1. Does the second report change the five approved mappings?

**No.** Its §15.7 independently reaches the same five mappings already recorded
in `docs/product/spider-biology-folio.md` and
`game/domain/spider_biology_catalog.gd`: Ballooner behaviour-level, Skitter
*Lyssomanes viridis* with the slender-body correction, Garden an Araneidae
composite, Anchorite a composite mygalomorph, and the guarded-recovery profile
fictional with *Ummidia* art. That is independent corroboration, not new scope.

It adds two refinements, both adopted below: a stronger armour reference for
Buckler, and a named example species for Ballooner.

## 2. Claims re-verified independently

| Claim in report 2 | Verified against | Verdict |
|---|---|---|
| *Cyclocosmia* has a truncated abdomen ending in a hardened, ribbed disc used to plug its burrow (phragmosis) | Godwin & Bond 2018 (Halonoproctidae description); AMNH *Novitates* 2580 revision of the genus; Halonoproctidae *Cyclocosmia* species papers in PMC | **Confirmed.** The disc functions as a "false bottom" when the spider retreats head-first; it seals the burrow, it is not body armour |
| *Cyclocosmia* Ausserer, 1871; family Halonoproctidae | WSC species records; Godwin & Bond 2018 moved the group out of Ctenizidae in 2018 | **Confirmed**, including the 2018 family move that also carries *Ummidia* |
| *Erigone atra* is a documented, heavily studied ballooning linyphiid | Weyman 1994, *Entomologia Experimentalis et Applicata*; Thorbek & Topping dispersal modelling | **Confirmed.** One of the most-recorded aeronauts in western Europe |
| Six-eyed sand spiders: *Sicarius* → *Hexophthalma* for the southern African species | Genus revalidated 2017; *H. hahni* and *H. damarensis* moved out of *Sicarius* | **Confirmed.** Report 1's *Sicarius* entry is superseded for southern Africa |
| Net-casters: *Deinopis* → *Asianopis* for Asian/Australasian species | Lin, Shao, Hänggi, Caleb, Koh, Jäger & Li 2020, *ZooKeys* 890 | **Confirmed.** *Deinopis subrufa* → *Asianopis subrufa*; *Deinopis* is retained for other species |
| *Toxeus magnus* provisions young with a milk-like secretion | Chen et al. 2018, *Science*; follow-up review in PMC | **Confirmed.** Nutritive secretion, extended maternal care past sub-adulthood |
| *Theridiosoma gemmosum* tensions its web into a cone and releases it at flying prey | *J. Exp. Biol.* directional-web-strike study; slingshot-web mechanics preprint | **Confirmed**, and distinct from *Hyptiotes*: the ray spider's web snaps from cone to flat disc |
| *Thwaitesia argentiopunctata* carries reflective guanine patches that change size | Species and genus references describing guanine platelet arrays | **Confirmed** for the reflective guanine structures. The size-change mechanism is less well sourced — treat as reported, not established |
| *Adelocosa anops* is an eyeless, endangered Hawaiian cave wolf spider | US Fish & Wildlife Service species page; NatureServe | **Confirmed.** Eyeless, restricted to Kōloa-basin caves on Kauaʻi, listed endangered since 2000 |

## 3. Not verified — deliberately not adopted

- **Every authority string report 2 attaches to a species it does not itself
  cite.** Only the authorities checked above are recorded in repository data.
  `Cyclocosmia` Ausserer, 1871 and the *Asianopis* 2020 author list were
  confirmed; everything else keeps genus/family only.
- **Anchorite palette refinement** (*Aphonopelma hentzi* body, *Grammostola
  pulchra* palette). Plausible and harmless, but the finished Anchorite sprite
  is already approved and the folio's composite mapping does not depend on
  which theraphosid is named. Not adopted; no benefit.
- **Report 2's process advice** — hold all roster/art/education work until
  issue #2 closes, and produce a mapping folio as the next artifact. Overtaken
  by events: the folio shipped in PR #50 and the owner has since answered
  several of its §16.4 questions directly.
- **~15 further atlas taxa** that were not re-verified because nothing in the
  repository would cite them yet. They stay in report 2 only.

## 4. Adopted into repository data

1. **Buckler gains *Cyclocosmia* as its armour reference.** This is a
   materially better story than *Ummidia* alone: a real spider whose abdomen
   really is a hardened plate, used as a door. It also sharpens the disclosure,
   because the real function — sealing a burrow entrance — is precisely *not*
   the impact armour the mechanic invents.
2. **Ballooner names *Erigone atra* as a documented example**, without
   promoting it to the profile's species. The record stays `behaviour`.
3. **Two taxonomy corrections in the folio's parked-candidate list**
   (*Hexophthalma*, *Asianopis*), so a future session does not reuse superseded
   names from report 1.
4. **Four verified candidates added to the parked backlog** — *Toxeus magnus*,
   *Theridiosoma gemmosum*, *Thwaitesia argentiopunctata*, *Adelocosa anops* —
   each with the source that was actually checked.

## 5. Standing rule this produced

A research document is an input, not a source. When a report's own citations do
not resolve, its claims are re-verified against the World Spider Catalog, a
peer-reviewed paper, or a museum or health authority before any of it reaches
`SpiderBiologyCatalog` — and the check is logged here with its verdict. The
`sources_for()` contract in `tests/unit/spider_biology_tests.gd` already refuses
a record citing a source id with no resolvable entry; this log is the
human-readable half of the same rule.
