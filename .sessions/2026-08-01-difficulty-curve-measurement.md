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

**The endless course stops getting harder at about 6000 m, and everything past
10 000 m is easier than 4000 m.** Intermediate bot: 2.79 deaths/km at 1 km,
climbing to a peak of 10.36 ±1.16 at 6 km, then falling to 5.46 ±0.61 at 10 km
and staying flat through 20 km. The peak-to-plateau drop is 3.7σ. 10 km is
exactly as hard as 4 km (5.46 ±0.61 vs 5.38 ±0.60); for a novice it matches
2 km, for an expert 3 km.

Three mechanisms, each confirmed by censusing the served stream rather than
only by reading the source:

1. `CourseStream._obstacle_growth_scale()` saturates at 1.16 from 3500 m and
   never moves again at any distance.
2. Both distance gates have fired by 2 km (middle hazards 1000 m, tight
   corridors 2000 m).
3. The served pattern stream reaches a steady state at 10 km that is
   statistically identical out to 30 km — same eleven patterns, same
   proportions, ~20% recovery, mean authored difficulty 3.16–3.20.

Silk Hollow is structurally gentler than Bramble Canopy: recovery every 5
chunks against Bramble's 6 (20.8% vs 18.9% of the stream), while Bramble also
forces a vertical weave every 4 chunks — 33% of its entire stream. With
obstacle growth already saturated, nothing compensates, so the curve inverts at
the zone-2 → zone-3 boundary.

**The remedy is zone content, which is not this lane.** Recorded for the lane
that owns it; nothing in the pattern catalog was changed.

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

## Verification

`python3 tools/verify.py --require-godot` → **exit 0**, 123 contracts on pinned
Godot 4.7.1. Re-run after rebasing onto `main` (which moved twice during the
slice, once through the contract-count machinery in PR #72) — the count still
reads 123 executed and 123 declared.

`python3 bootstrap.py check --strict` → **exit 0**.

## Shipped

- `docs/measurements/2026-08-01-difficulty-curve.md` — the committed baseline:
  deaths/km, survival, death causes and resource pressure, with an explicit
  section on which numbers are load-bearing and which are not.
- `tools/difficulty_curve.py` — drives the grid and renders the tables, so the
  baseline can be re-measured and diffed rather than trusted forever.
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

- **📊 Model:** opus-5 · high · measurement — difficulty curve baseline

## Next slice

**Slice 2 — campaign teaching tier.** The gap is named in the approved campaign
decision in `docs/decisions.md`: the tutorial explains Reel, Burst and Dive
across six static steps and then never asks the player to perform any of them.
Build short levels that each *require* one verb. Existing art, existing course
geometry; rewards are cosmetics and stars, never flies, routed through the
existing settlement path.
