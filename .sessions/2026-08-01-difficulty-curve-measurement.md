# Slice 1 — difficulty curve measurement

> **Status:** `complete`

## Goal

Establish the difficulty baseline that three later slices are judged against:
deaths per kilometre and death causes per distance band, across skill tiers,
with fixed seeds. Commit the numbers.

## Scope guard

Measurement only. No physics values touched, no zone content touched, no
pattern pool or recovery cadence changed. The one code change is to the
diagnostic lab's arithmetic, which asserts nothing and gates nothing.

## Previous-session review

**previous-session review:** the overnight brief (PR #70) put measurement first
precisely because difficulty modes, the upgrade audit and the economy all lean
on it. It was right to: the numbers turned out to contradict the assumption a
reader would carry in, that an endless runner gets harder the further you go.

## What was measured

40 runs per skill tier per band, course seeds 1337–1344, bot seed base 1,
`balanced_baseline`, `classic`, 0 upgrades, 240 s cap. No run timed out, so
every run ended in a death. Bands 0/1k/2k/3k/4k/4.5k/5k/5.5k/6k/7k/8k/10k/15k/20k.

## Finding

*(Re-measured after `main` landed PR #69 mid-slice — see "Re-measurement"
below. The numbers here describe the merged tree.)*

**The course ramps hard to 8 km, then falls off a cliff at 10 km.**
Intermediate bot: 2.79 deaths/km at 1 km, climbing to 19.47 ±2.18 at 8 km — a
7× ramp — then dropping to 5.46 ±0.61 at 10 km, a 3.6× collapse across the
Bramble Canopy → Silk Hollow boundary, and flat through 20 km. The drop is
6.2σ. 10 km is still no harder than 4 km (5.46 ±0.61 vs 5.38 ±0.60) despite
everything between them being 2–4× deadlier.

**Inside Bramble Canopy, skill stops mattering.** The novice-to-expert
deaths/km ratio falls from 3.31× at 1 km to 1.31× at 5 km, 1.10× at 6 km, and
0.87× at 7 km — where the expert bot dies *more* than the novice. Silk Hollow
restores it to 1.7–1.8×. A band where playing well does not help is a content
signal rather than a difficulty one.

Three mechanisms, each confirmed by censusing the served stream rather than
only by reading the source:

1. `CourseStream._obstacle_growth_scale()` saturates at 1.16 from 3500 m and
   never moves again at any distance.
2. Both distance gates have fired by 2 km (middle hazards 1000 m, tight
   corridors 2000 m).
3. The served pattern stream reaches a steady state at 10 km that is
   statistically identical out to 30 km — same eleven patterns, same
   proportions, ~20% recovery, mean authored difficulty 3.16–3.20.

A fourth mechanism stopped working: **the authored `difficulty` field no longer
predicts lethality.** PR #69 moved Bramble's mean authored difficulty 3.15 →
3.25 (3%) and left its recovery share unchanged at 18.9%, while measured
deaths/km at 8 km went 7.01 → 19.47 (178%). Whatever the new vocabulary's
geometry does is invisible to the rating. Treat the field as a label, not a
measurement, until something reconciles them.

**The remedy is zone content, which is not this lane.** Recorded for the lane
that owns it; nothing in the pattern catalog was changed.

## Re-measurement — main moved under the slice

`main` landed PR #69 ("Give Bramble Canopy its own obstacle vocabulary") while
this PR was open. It replaced **every** pattern id in the Bramble pool — 11 ids
out, 8 new ones in — which is precisely the content the 5–10 km bands measure.
The first measurement's Bramble numbers no longer described the tree, so the
whole grid and the census were re-run against the merged result and the
document rewritten. Landing the original numbers would have shipped a doc that
contradicted the code it documented on the day it merged.

The change is confined as expected, which is the internal check: the 0 m and
10/15/20 km bands came back **byte-identical** to the pre-#69 run, because runs
at those starts never touch Bramble. Only the 5–8 km bands moved.

It also changed the headline. Before #69 the curve peaked at 6 km and declined
gently; now it climbs to 8 km and collapses. The skill-insensitivity finding
did not exist before #69 at all — old Bramble held a 1.5–2× novice/expert
ratio. Both are reported as measurements of the current tree, not as verdicts
on the zone lane's change.

## The lab fix this needed

Per-kilometre rates divided by absolute course position rather than ground
travelled, so a warped batch normalized against kilometres the bot never
covered. A run warped to 10 000 m and dying 380 m later reported 0.9 flies/km
where the true rate was 24.2 — a 27× error, and every `--start-m` number ever
read off this tool carried it.

Rows now carry `start_m` and `travelled_m`; rates divide by travelled distance;
summaries add `deaths_per_km` (counting the rescued death as well as the
terminal one) with its Poisson standard error, so a later slice can tell a real
shift from sample size. At `--start-m=0` travelled equals absolute, so unwarped
numbers are unchanged — verified: the 0 m batch reports travelled mean 1859.2 m
against distance mean 1859.2 m.

## Falsification

The normalization was falsified before being trusted: the same 8-run batch at
`--start-m=0` reports travelled ≡ distance and an unchanged 12.9 flies/km,
while at `--start-m=10000` it reports travelled 376.9 m (= 10376.9 − 10000) and
24.2 flies/km against the old code's 0.9. The census that confirms mechanism 3
was run as a throwaway script against `pattern_for_chunk`, not committed.

No new contract was added — `simulate.gd` asserts nothing by design and sits
outside the verify gate — so `EXPECTED_CHECK_COUNT` is untouched at 123.

## Friction — guard recipe for the next slice in this chain

**A local `bootstrap.py check --strict` exit 0 does not prove the session card
will pass CI.** This card first carried an off-taxonomy `📊 Model:` task-class
(`measurement — …`). Locally the kit reported it as a *model-line-class
advisory* and exited 0 — with the default invocation and with CI's
`--session-log <card>` form, and still exit 0 when the bad token was restored
to confirm. CI turned the same card red, because the added-card gate escalates
it: *"card … is newly ADDED by this PR (born-red heartbeat) — added-card gate:
in-progress HOLDs until the card flips complete; grammar misses red."*

The escalation is not locally reproducible, so the guard is procedural: the
task-class segment must **prefix-match** one of the nine PL-004 classes
(`docs-only | mechanical refactor | test writing | runtime bugfix |
kernel/architecture design | review/verify | research | idea/planning |
feature build`); trailing detail after the class is fine (`research — …`).
Every remaining slice in this chain adds a card, so every one of them can hit
this. Check the token by eye before pushing rather than trusting a green local
gate. Anchors: `session-card-grammar` / `model-line-class` guards in
`src/engine/guards.py`, taxonomy taught in `.sessions/README.md`.

## Verification

`python3 tools/verify.py --require-godot` → **exit 0**, **124** contracts on
pinned Godot 4.7.1, run against the tree with `main` merged in. `main` moved
three times during this slice — PR #72 touched the contract-count machinery and
PR #69 bumped `EXPECTED_CHECK_COUNT` 123 → 124 — so the suite was re-run after
each merge rather than trusting the diff. The count reads 124 executed against
124 declared, so the same-value merge hazard did not bite.

`python3 bootstrap.py check --strict` → **exit 0**.

## Shipped

- `docs/measurements/2026-08-01-difficulty-curve.md` — the committed baseline:
  deaths/km, survival, death causes and resource pressure, with an explicit
  section on which numbers are load-bearing and which are not.
- `tools/difficulty_curve.py` — drives the grid and renders the tables,
  including the skill-sensitivity ratio, so the baseline can be re-measured and
  diffed rather than trusted forever. Re-running it after #69 is what caught
  the stale numbers.
- `tools/simulate.gd` — travelled-distance normalization, `deaths_per_km` and
  its standard error.
- `docs/technical/simulation-lab.md`, `docs/README.md` — kept in step.

## Owner questions

None blocking. One thing worth the owner's morning: the flat plateau past 10 km
means a player who reaches 10 km sees no new pressure for the next 20 km. That
is a product question (should the endless run keep ramping, or is the plateau
the intended "you have arrived" state?) rather than a bug, and slice 7 will put
it in front of him with the evidence attached.

## 💡 Idea

Recovery share is the cleanest difficulty dial in the game and it is already
load-bearing: 2.4% / 18.9% / 20.8% of chunks by zone, with no physics
involvement at all. Slice 3's difficulty modes should reach for it first rather
than inventing a new lever.

- **📊 Model:** opus-5 · high · research — difficulty curve baseline

## Wake chain

One outstanding wake, armed after the slice's work was pushed. Recorded
verbatim per `docs/ROUTINES.md`:

- **id:** `trig_01SHptxVQLm6zjoz2rnqWoZb`
- **binding:** self-bound one-shot (`send_later`) into this session
- **fires:** `2026-07-31T22:57:00Z` (50 minutes out)
- **carries:** get PR #74 to merged first — including the Godot install recipe
  and the CI-stall context — then slice 2, written to work from cold.

Armed 50 minutes out rather than the brief's ~75 because it is a
CI-recovery check-in, not a post-merge slice hand-off: at 22:05Z GitHub
Actions was stalled repo-wide (zero workflow runs on any branch since
21:49Z, so this PR's head had no checks scheduled and auto-merge had
nothing to consume). Transient venue state, not a wall — the previous
commit fired all four workflows through the same path, and `game-quality`
passed on it. The wake re-fires the event if the queued ones were dropped.

## Next slice

**Slice 2 — campaign teaching tier.** The gap is named in the approved campaign
decision in `docs/decisions.md`: the tutorial explains Reel, Burst and Dive
across six static steps and then never asks the player to perform any of them.
Build short levels that each *require* one verb. Existing art, existing course
geometry; rewards are cosmetics and stars, never flies, routed through the
existing settlement path.
