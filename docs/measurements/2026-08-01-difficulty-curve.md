# Difficulty curve measurement — 2026-08-01

> **Status:** `reference`
>
> Baseline for slices that follow. Diagnostic instrumentation, not a gate and
> not a feel oracle: it reports what a scripted bot does, not what the owner
> feels. Re-measure and diff rather than trusting these numbers forever.

## Headline

**The endless course stops getting harder at about 6 000 m, and everything past
10 000 m is easier than 4 000 m.**

For an intermediate bot on `balanced_baseline` with no upgrades:

- Difficulty climbs steadily from 1 km (2.79 deaths/km) to a peak at
  **6 km (10.36 ±1.16)** — a 3.7× ramp.
- It then *falls*: 7 km 8.05, 8 km 7.01, and 10 km **5.46 ±0.61**.
- 10 km, 15 km and 20 km are flat within error (5.46 / 5.72 / 6.46).
- **10 km is exactly as hard as 4 km** (5.46 ±0.61 vs 5.38 ±0.60). For a
  novice, 10 km is exactly as hard as 2 km (6.29 ±0.70 both). For an expert,
  10 km matches 3 km (3.62 ±0.40 vs 3.56 ±0.40).

The peak-to-plateau drop is 3.7σ, so it is not sampling noise.

## Why — the generator has nothing left to escalate

Three mechanisms, all readable in the source and confirmed by censusing the
served stream:

1. **Obstacle growth saturates at 3 500 m.**
   `CourseStream._obstacle_growth_scale()` steps 1.0 → 1.08 → 1.14 → 1.16 at
   `CoursePatternCatalog`'s `CONTROL_START_DISTANCE` (10 000 px = 1 000 m),
   `MASTERY_START_DISTANCE` (20 000 px = 2 000 m) and
   `DEEP_FOREST_START_DISTANCE` (35 000 px = 3 500 m). Past 3 500 m it returns
   1.16 forever. There is no further geometric escalation at any distance.
2. **Both distance gates have already fired by 2 km.** `balanced_baseline` sets
   `middle_hazard_start_distance` 10 000 px (1 000 m) and
   `tight_corridor_start_distance` 20 000 px (2 000 m).
3. **The served pattern stream reaches a steady state at 10 km.** Enumerating
   `CoursePatternCatalog.pattern_for_chunk()` over course seeds 1337–1344:

| Zone span | Chunks | Recovery pockets | Mean authored difficulty |
| --- | ---: | ---: | ---: |
| Ancient Forest 0–5 km | 336 | 2.4% | 2.81 |
| Bramble Canopy 5–10 km | 424 | 18.9% | 3.15 |
| Silk Hollow 10–15 km | 424 | 20.8% | 3.17 |
| Silk Hollow 10–20 km | 840 | 21.0% | 3.16 |
| 20–30 km | 840 | 20.0% | 3.20 |

From 10 km to 30 km the stream is statistically identical — same eleven
patterns, same proportions, ~20% recovery, mean difficulty 3.16–3.20. A player
at 25 km is playing the same content mix as one at 11 km.

**Silk Hollow is structurally gentler than Bramble Canopy**: it grants a
recovery pocket every 5 chunks against Bramble's 6 (20.8% vs 18.9% of the
stream), while Bramble additionally forces a `canopy_high_low`/`canopy_low_high`
vertical weave every 4 chunks — 33% of its entire stream. With obstacle growth
already saturated, nothing compensates for the softer pool, so the curve
inverts at the zone-2 → zone-3 boundary.

**This is a finding, not a fix.** The remedy lives in zone content — pattern
pools and recovery cadence — which is the zone lane, not this one. Recorded
here so the lane that owns it can act on it.

## Deaths per kilometre — the 1–8 km sweep that located the peak

| Start | Novice | Intermediate | Expert |
| --- | ---: | ---: | ---: |
| 1,000 m | 4.81 ±0.54 | 2.79 ±0.31 | 1.45 ±0.16 |
| 2,000 m | 6.29 ±0.70 | 3.92 ±0.44 | 2.53 ±0.28 |
| 3,000 m | 6.02 ±0.67 | 3.82 ±0.43 | 3.56 ±0.40 |
| 4,000 m | 6.03 ±0.67 | 5.38 ±0.60 | 3.81 ±0.43 |
| 4,500 m | 7.45 ±0.83 | 5.19 ±0.58 | 3.78 ±0.42 |
| 5,000 m | 10.24 ±1.15 | 7.79 ±0.87 | 4.94 ±0.55 |
| 5,500 m | 7.11 ±0.80 | 6.41 ±0.72 | 4.84 ±0.54 |
| 6,000 m | 9.62 ±1.08 | 10.36 ±1.16 | 8.17 ±0.91 |
| 7,000 m | 8.35 ±0.93 | 8.05 ±0.90 | 7.01 ±0.78 |
| 8,000 m | 8.47 ±0.95 | 7.01 ±0.78 | 6.10 ±0.68 |

The 1 km reading is the first band that is a fair narrow-window sample; see the
caveat on the 0 m band below.

## Deaths per kilometre — the briefed bands

Rate normalizes on ground **travelled**, not course position, and
counts the rescued death as well as the terminal one. `±` is the
Poisson standard error — band-to-band wobble inside it is sample
size, not difficulty.

| Start | Novice | Intermediate | Expert |
| --- | ---: | ---: | ---: |
| 0 m | 2.16 ±0.24 | 1.23 ±0.14 | 0.91 ±0.10 |
| 5,000 m | 10.24 ±1.15 | 7.79 ±0.87 | 4.94 ±0.55 |
| 10,000 m | 6.29 ±0.70 | 5.46 ±0.61 | 3.62 ±0.40 |
| 15,000 m | 8.75 ±0.98 | 5.72 ±0.64 | 4.09 ±0.46 |
| 20,000 m | 7.58 ±0.85 | 6.46 ±0.72 | 4.16 ±0.47 |

## Distance survived from the start line

| Start | Skill | Mean | Median | p10 | p90 | Timeouts |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 0 m | novice | 925 m | 1,043 m | 341 m | 1,343 m | 0 |
| 0 m | intermediate | 1,623 m | 1,605 m | 1,092 m | 2,163 m | 0 |
| 0 m | expert | 2,193 m | 2,239 m | 1,768 m | 2,554 m | 0 |
| 5,000 m | novice | 195 m | 182 m | 119 m | 283 m | 0 |
| 5,000 m | intermediate | 257 m | 249 m | 140 m | 390 m | 0 |
| 5,000 m | expert | 405 m | 388 m | 144 m | 627 m | 0 |
| 10,000 m | novice | 318 m | 290 m | 117 m | 525 m | 0 |
| 10,000 m | intermediate | 366 m | 325 m | 139 m | 605 m | 0 |
| 10,000 m | expert | 552 m | 505 m | 233 m | 807 m | 0 |
| 15,000 m | novice | 228 m | 237 m | 90 m | 372 m | 0 |
| 15,000 m | intermediate | 349 m | 322 m | 91 m | 571 m | 0 |
| 15,000 m | expert | 489 m | 411 m | 90 m | 903 m | 0 |
| 20,000 m | novice | 264 m | 267 m | 110 m | 398 m | 0 |
| 20,000 m | intermediate | 309 m | 287 m | 197 m | 409 m | 0 |
| 20,000 m | expert | 480 m | 406 m | 269 m | 769 m | 0 |

## Death causes

| Start | Skill | Causes | Mid-pull | Patterns at death |
| --- | --- | --- | ---: | --- |
| 0 m | novice | boundary ×29 · obstacle ×11 | 1 |  ×19 · hanging_vine ×5 · rooted_gate ×5 · fallen_stump ×4 · bramble_curve ×2 · floor_vine ×2 · thorn_ridge ×2 · ceiling_stump ×1 |
| 0 m | intermediate | obstacle ×22 · boundary ×18 | 4 | rooted_gate ×9 · bramble_curve ×6 · floor_vine ×5 · thorn_ridge ×5 ·  ×3 · ceiling_stump ×3 · fallen_stump ×3 · canopy_pod ×2 · staggered_s ×2 · hanging_vine ×1 · low_high_weave ×1 |
| 0 m | expert | boundary ×20 · obstacle ×20 | 9 | tight_rail ×8 · fallen_stump ×4 · low_high_weave ×4 · rooted_gate ×4 · high_low_weave ×3 · thorn_ridge ×3 · bramble_curve ×2 · canopy_pod ×2 · ceiling_stump ×2 · silk_burr_high ×2 · vine_curtain ×2 · bramble_steps ×1 · floor_vine ×1 · silk_burr_low ×1 · staggered_s ×1 |
| 5,000 m | novice | obstacle ×24 · boundary ×16 | 1 | canopy_high_low ×11 · canopy_low_high ×11 · tall_vine ×8 · bramble_steps ×4 · canopy_thorn_high ×3 · fallen_stump ×3 |
| 5,000 m | intermediate | boundary ×20 · obstacle ×20 | 0 | canopy_high_low ×19 · canopy_low_high ×6 · tall_vine ×6 · fallen_stump ×5 · canopy_thorn_high ×3 · open_recovery ×1 |
| 5,000 m | expert | obstacle ×29 · boundary ×11 | 2 | canopy_low_high ×20 · canopy_high_low ×11 · tall_vine ×4 · canopy_thorn_high ×2 · bramble_steps ×1 · fallen_stump ×1 · long_pod ×1 |
| 10,000 m | novice | obstacle ×21 · boundary ×19 | 0 | silk_burr_high ×9 · high_low_weave ×6 · recovery_pair ×6 · rooted_gate ×5 · stump_and_vine ×5 · silk_burr_low ×4 · open_recovery ×3 · low_high_weave ×1 · staggered_s ×1 |
| 10,000 m | intermediate | boundary ×20 · obstacle ×20 | 3 | recovery_pair ×10 · high_low_weave ×7 · silk_burr_high ×5 · open_recovery ×4 · low_high_weave ×3 · rooted_gate ×3 · stump_and_vine ×3 · silk_burr_low ×2 · staggered_s ×2 · alternating_thorns ×1 |
| 10,000 m | expert | obstacle ×22 · boundary ×18 | 6 | low_high_weave ×7 · recovery_pair ×7 · high_low_weave ×6 · rooted_gate ×6 · silk_burr_low ×5 · open_recovery ×3 · silk_burr_high ×3 · staggered_s ×2 · stump_and_vine ×1 |
| 15,000 m | novice | boundary ×22 · obstacle ×18 | 0 | tight_rail ×16 · low_high_weave ×6 · open_recovery ×4 · silk_burr_high ×4 · high_low_weave ×3 · rooted_gate ×3 · stump_and_vine ×2 · alternating_thorns ×1 · staggered_s ×1 |
| 15,000 m | intermediate | obstacle ×24 · boundary ×16 | 3 | silk_burr_high ×8 · tight_rail ×8 · low_high_weave ×6 · high_low_weave ×5 · rooted_gate ×4 · open_recovery ×3 · stump_and_vine ×3 · alternating_thorns ×2 · staggered_s ×1 |
| 15,000 m | expert | boundary ×25 · obstacle ×15 | 5 | tight_rail ×11 · high_low_weave ×8 · low_high_weave ×6 · silk_burr_high ×5 · recovery_pair ×4 · staggered_s ×3 · rooted_gate ×2 · stump_and_vine ×1 |
| 20,000 m | novice | boundary ×22 · obstacle ×18 | 0 | alternating_thorns ×7 · rooted_gate ×7 · low_high_weave ×6 · recovery_pair ×6 · high_low_weave ×4 · silk_burr_high ×4 · stump_and_vine ×3 · open_recovery ×2 · silk_burr_low ×1 |
| 20,000 m | intermediate | obstacle ×27 · boundary ×13 | 4 | low_high_weave ×11 · high_low_weave ×6 · rooted_gate ×5 · stump_and_vine ×5 · silk_burr_high ×4 · alternating_thorns ×3 · recovery_pair ×3 · staggered_s ×3 |
| 20,000 m | expert | obstacle ×31 · boundary ×9 | 2 | low_high_weave ×10 · high_low_weave ×7 · rooted_gate ×6 · silk_burr_low ×5 · silk_burr_high ×3 · stump_and_vine ×3 · alternating_thorns ×2 · open_recovery ×2 · recovery_pair ×2 |

## Resource pressure

| Start | Skill | Flies/km | Webs/run | Bursts/run | Reel held | At empty |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 0 m | novice | 11.2 | 13.7 | 1.5 | 4.32 s | 0.00 s |
| 0 m | intermediate | 13.4 | 23.6 | 8.4 | 5.90 s | 0.00 s |
| 0 m | expert | 14.6 | 41.0 | 19.2 | 7.19 s | 0.00 s |
| 5,000 m | novice | 26.5 | 1.8 | 0.2 | 0.49 s | 0.00 s |
| 5,000 m | intermediate | 25.3 | 2.9 | 0.9 | 0.73 s | 0.00 s |
| 5,000 m | expert | 19.2 | 6.7 | 3.1 | 1.10 s | 0.00 s |
| 10,000 m | novice | 19.9 | 3.0 | 0.4 | 0.70 s | 0.00 s |
| 10,000 m | intermediate | 21.7 | 4.4 | 1.4 | 0.82 s | 0.00 s |
| 10,000 m | expert | 19.2 | 8.8 | 4.2 | 1.36 s | 0.00 s |
| 15,000 m | novice | 15.1 | 2.5 | 0.2 | 0.54 s | 0.00 s |
| 15,000 m | intermediate | 13.9 | 4.2 | 1.5 | 0.76 s | 0.00 s |
| 15,000 m | expert | 12.5 | 8.0 | 3.5 | 1.34 s | 0.00 s |
| 20,000 m | novice | 17.0 | 2.5 | 0.4 | 0.68 s | 0.00 s |
| 20,000 m | intermediate | 15.3 | 3.3 | 1.6 | 0.76 s | 0.00 s |
| 20,000 m | expert | 14.1 | 6.7 | 6.2 | 1.08 s | 0.00 s |
## What these numbers do and do not support

**Load-bearing.** The warped bands (5 km and up) are directly comparable with
each other: each samples a narrow window under identical warp conditions. The
ramp, the 6 km peak and the 10 km+ plateau all rest on that comparison.

**Not load-bearing — the 0 m band is not comparable to a warped band.** A run
started at 0 m travels ~1.6 km through the entire opening ramp, so its rate
averages the easy runway together with everything after it. A warped band
samples only a 200–600 m window at one difficulty. Reading "0 m = 1.23,
5 km = 7.79" as a 6× difficulty step is wrong; most of that gap is the
averaging window. Compare warped bands to warped bands.

**Not load-bearing — flies/km in a warped band.** Every warped run gets a fresh
guided opening, so per-run fly income is amortized over a short window and the
rate is inflated (25/km at 5 km vs 13/km at 0 m). The economy slice must
re-measure income over full runs, not warped windows.

**A real signal worth carrying forward: the Reel meter is never a constraint.**
Across all 15 configurations, `reel empties` is 0.00 and `time at empty` is
0.00 s — the bot never exhausts the Reel meter in any band at any skill. This
extends the 2026-07-30 lab observation (the meter never empties under
purposeful reeling, even in the greedy `hold` style) from the early game to
every band out to 20 km: depth does not create meter pressure either. Any
upgrade track that buys Reel capacity or regeneration is currently improving a
resource that never runs out. The upgrade audit should treat that as its first
hypothesis to test.

Two smaller notes. Deaths split roughly evenly between `boundary` and
`obstacle` in every band, with no distance trend — the failure *mode* does not
change with depth, only its frequency. And the blank pattern id in the 0 m
novice row is chunk 0, which is served before a pattern is assigned.

## Method

- Bot model v2, `balanced_baseline`, `classic`, 0 upgrades, rescue life on.
- 40 runs per skill tier per band, rotating course seeds 1337–1344, bot seed
  base 1, 240 s cap. No run timed out, so every run ended in a death.
- Deaths per km normalizes on ground **travelled** (`distance_m - start_m`) and
  counts the rescued death as well as the terminal one — a rescued death is
  still a mistake the player made.
- `±` is the Poisson standard error on the rate (`rate / sqrt(deaths)`).
  Band-to-band wobble inside it is sample size, not difficulty. Treat a change
  smaller than ~1 death/km at these run counts as noise.

Reproduce:

```bash
python3 tools/difficulty_curve.py --runs=40 --course-seeds=8 \
  --bands=0,5000,10000,15000,20000 --out=/tmp/canonical.md
python3 tools/difficulty_curve.py --runs=40 --course-seeds=8 \
  --bands=1000,2000,3000,4000,4500,5000,5500,6000,7000,8000 --out=/tmp/fine.md
```

Both are deterministic: the same flags reproduce these numbers exactly.

## What the later slices should take from this

- **Difficulty modes.** The sanctioned dials — which content the stream serves
  and how much recovery the player gets — are exactly the two levers this
  measurement shows are load-bearing. Recovery share (2.4% / 18.9% / 20.8% by
  zone) is the cleanest single knob, and it needs no physics change.
- **Upgrade audit.** Test the Reel-meter hypothesis above first. Re-run this
  grid at `--upgrades=0` vs `--upgrades=10` vs `--upgrades=20`; a track that
  does not move deaths/km by more than ~1 at these run counts is noise.
- **Currency and rewards.** Do not use the warped flies/km figures. Measure
  income over full runs from 0 m.
- **Ideas.** The flat 10 km+ plateau is the strongest measured gap in the game:
  a player who reaches 10 km sees no new pressure for the next 20 km.
