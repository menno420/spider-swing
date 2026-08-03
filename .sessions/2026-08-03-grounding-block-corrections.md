# The grounding block asserted its own provenance and was wrong seven times

> **Status:** `complete`

## Goal

Correct `docs/technical/gameplay-video-review.md`. Its grounding block claims
every fact in it was read from three named source files. Four of those facts
contradict the files named, and three more are missing in ways that would make a
correct reading look wrong.

## Scope guard

**One document.** No game code, no contract, no build bump, no change to the
loop the document describes. Held.

## ⟲ Previous-session review

`2026-08-03-verify-before-assert.md` promoted one rule into the working
agreement: *"If a statement is checkable with one command, run the command
before writing the sentence."* It was written from three instances of that fault
found the same day, and it was correctly pitched — a rule that fires at the
assertion rather than at the artifact.

**It landed nine minutes too late, and nobody looked backwards.** The commit
times settle it:

| time | commit | what |
| --- | --- | --- |
| 21:54 | `58833cd` (#152) | the grounding block lands, with all seven faults in it |
| 22:04 | `7553d2c` (#153) | verify-before-assert promoted into `.claude/CLAUDE.md` |

The rule was authored *in response to* three checkable claims asserted wrong that
day, while four more of exactly the same class sat uncaught in the commit ten
minutes earlier — in a block whose own provenance line named the file that
contradicts it. The rule was right and the count was wrong.

## 💡 Session idea

**A new rule needs a backfill pass over the same day's work, or it only protects
the future — and the past is where its own evidence came from.** Every rule in
this repo is written the moment a fault is noticed, which means it is written
when instances of that fault are at their densest and least reviewed. #153 was
derived from three instances and shipped without asking the obvious next
question: *what else did I assert today?* Seven more were sitting in a document
committed ten minutes prior.

Concretely: when a session promotes a rule into `.claude/CLAUDE.md`, it should
re-audit its own day against that rule before flipping its card — the diff is
already in hand, the rule is already phrased as a test, and the fault density is
never higher than at the moment of noticing. Cost is minutes. The alternative is
what happened here: the rule's own author shipped fresh violations of it in the
same hour, and the owner caught them a day later by asking a question.

This also explains *which* facts were wrong, which looked arbitrary until the
dates were checked. The region order was **correct** — it had changed on 08-02,
one day earlier, so it was salient and got verified. The hazard vocabulary was
**wrong** — `canopy_pod` has sat in the Ancient Forest pools since 07-29 (#27)
and the Bramble singles/pairs split since 08-01 (#86), so both were stable
background and got written from memory. **The stable facts are the dangerous
ones**, because recency is doing the verification work that a check is supposed
to do.

## What was found

Seven faults, all introduced at the document's creation in #152. The code was
not moving underneath it — `canopy_pod` has been Ancient Forest content for five
days, the Bramble pool split for two — so this is not drift.

**Four contradictions of the files the block names:**

1. **Hazard vocabulary in the wrong region.** The block gave Bramble Canopy
   "canopy pods, canopy shutters, bramble curves, bramble steps" and called
   alternating thorns, ceiling stumps and rooted gates "shared".
   `course_pattern_catalog.gd:105-117` — Bramble Canopy's pool is eight entries:
   hooks, leaves, shutters. The rest are Ancient Forest (`:43-89`), and
   `_region_pool_for` (`:419`) returns one pool per region with no overlap, so
   nothing is shared. The worst of the seven: it teaches a reviewer to name an
   object something that cannot appear where it is looking.
2. **Debug banner truncated.** `swing_lab.gd:2240-2254` — all four strings end
   `· AWARDS NOTHING`, there are four rather than one, the fourth
   (`PRACTICE · NO FLIES OR RECORDS`) does not mean a debug start, and the banner
   draws only in practice mode (`:1739`).
3. **"No spider on screen" is false.** `_draw_spider()` is unconditional
   (`swing_lab.gd:279`, `:1452`) — the spider stays drawn at its death position
   under the overlay.
4. **"Restart frames read 8–50 m" holds only for runs starting at zero.**
   `swing_lab_session.gd:705-709` — `_reset_run` returns to
   `_start_distance_pixels`, so a `DEBUG START 10000 m` run restarts at ~10 000 m
   in Silk Hollow. That is what the dev recordings under review actually do, so
   the block pointed the reviewer the wrong way on its own headline failure mode.

**Three omissions, each able to make a correct reading look wrong:**

5. **Two of four death strings missing** — `Hit the solid ceiling or floor`
   (`simulation_world.gd:1493-1497`) and `Caught by the pursuing bird` (`:509`).
   Not theoretical: the review being corrected reported a run ending "after
   hitting the floor/ceiling barrier", a correct read of the third string that
   the two-string block gives grounds to doubt — the same shape as the retracted
   "invented vocabulary" entry the document already keeps visible.
6. **The death line's dependence on a player setting** — it lands on the general
   event line at `(142, 119)`, gated on "Show control hints"
   (`swing_lab.gd:1735-1738`). With hints off there is no death text at all and
   the honest answer is "not readable from this recording".
7. **The rescue life** — `swing_lab_session.gd:645-651`. A fatal contact with a
   rescue available does not end the run. Without this, a survived lethal-looking
   hit reads as a physics bug worth reporting.

The provenance section is corrected too. It labelled all of the above
`measured`, and a provenance label is the one claim that stops anyone downstream
from checking the rest.

## Guard recipe

The block goes stale silently — nothing fails, the reviewer just becomes
confidently wrong, and the failure surfaces as *reviewer* error. Anchors, one
per section: `CourseRegionCatalog.REGIONS`
(`game/domain/course_region_catalog.gd`), `_draw_hud` and `_run_access_status`
(`game/presentation/scripts/swing_lab.gd`), the four `DEATH_REQUESTED` sites
(`game/simulation/simulation_world.gd`), `_reset_run` and the rescue branch
(`game/application/swing_lab_session.gd`), the per-region pools and
`_region_pool_for` (`game/application/course_pattern_catalog.gd`). Five files,
about fifteen minutes. The document now names all five and says *re-derive*,
because this correction was itself found by re-derivation after a re-read had
already passed the same block as sound.

## Verify

```
$ python3 tools/verify.py
[verify] all checks passed
  [PASS] generated audio reproducibility (20.7s)
  [PASS] architecture checker self-test (0.1s)
  [PASS] architecture scan (0.1s)
  [PASS] Godot discovery and version (6.3s)
  [PASS] headless project import (14.5s)
  [PASS] headless boot smoke test (1.5s)
  [PASS] headless test runner (24.8s)   # 232 checks

$ python3 bootstrap.py check --strict
```

- **📊 Model:** opus-5 · high · docs-only — one document, seven corrections
