# Difficulty curve measurement — 2026-08-01

> **Status:** `reference`
>
> Baseline for slices that follow. Diagnostic instrumentation, not a gate and
> not a feel oracle: it reports what a scripted bot does, not what the owner
> feels. Re-measure and diff rather than trusting these numbers forever.
>
> Measured against `main` at PR #69 (Bramble Canopy's own obstacle vocabulary).
> That PR replaced every pattern id in the Bramble pool, so any earlier reading
> of the 5–10 km bands does not describe this tree.
>
> **Superseded above 15 km by PR #73.** Zones 4–8 landed after this was
> measured — Ruined Arboretum at 15 km, Storm Ridge at 20 km, then Web City,
> Ashen Hollow and Deep Mist — so the 15 km and 20 km bands below now sample
> zones that did not exist, and the "10 km to 30 km is statistically identical"
> finding no longer describes the tree. The 0–10 km bands and the mechanism
> section still hold. Re-measure before leaning on anything above 10 km.

## Headline

**The course ramps hard to 8 km, then falls off a cliff at 10 km.** For an
intermediate bot on `balanced_baseline` with no upgrades:

- 2.79 deaths/km at 1 km, climbing to **19.47 ±2.18 at 8 km** — a 7× ramp.
- At 10 km it drops to **5.46 ±0.61**, a **3.6× collapse** across the
  Bramble Canopy → Silk Hollow boundary, and stays flat through 20 km
  (5.46 / 5.72 / 6.46).
- **10 km is still no harder than 4 km** (5.46 ±0.61 vs 5.38 ±0.60), despite
  everything between them being 2–4× deadlier.

**Inside Bramble Canopy, skill stops mattering.** Novice-to-expert deaths/km
ratio falls from 3.31× at 1 km to 1.31× at 5 km, 1.10× at 6 km, and **0.87× at
7 km — where the expert bot dies more often than the novice**. Silk Hollow
restores it to 1.7–1.8×. A band where playing well does not help is a content
signal, not a difficulty one: it suggests deaths there are unreadable or
unavoidable rather than skill-tested.

Both effects are far larger than sampling error (the 8 km → 10 km drop is
6.2σ), so neither is noise.

## Why — three mechanisms, and one that stopped working

Confirmed by censusing the served stream, not only by reading source:

1. **Obstacle growth saturates at 3 500 m.**
   `CourseStream._obstacle_growth_scale()` steps 1.0 → 1.08 → 1.14 → 1.16 at
   `CoursePatternCatalog`'s `CONTROL_START_DISTANCE` (10 000 px = 1 000 m),
   `MASTERY_START_DISTANCE` (20 000 px = 2 000 m) and
   `DEEP_FOREST_START_DISTANCE` (35 000 px = 3 500 m). Past 3 500 m it returns
   1.16 forever, at every distance.
2. **Both distance gates have fired by 2 km** — `middle_hazard_start_distance`
   1 000 m, `tight_corridor_start_distance` 2 000 m.
3. **The served stream reaches a steady state at 10 km.** Enumerating
   `CoursePatternCatalog.pattern_for_chunk()` over course seeds 1337–1344:

| Zone span | Chunks | Recovery pockets | Mean authored difficulty |
| --- | ---: | ---: | ---: |
| Ancient Forest 0–5 km | 336 | 2.4% | 2.81 |
| Bramble Canopy 5–10 km | 424 | 18.9% | 3.25 |
| Silk Hollow 10–15 km | 424 | 20.8% | 3.17 |
| Silk Hollow 10–20 km | 840 | 21.0% | 3.16 |
| 20–30 km | 840 | 20.0% | 3.20 |

From 10 km to 30 km the stream is statistically identical — same eleven
patterns, same proportions, ~20% recovery. A player at 25 km sees the same
content mix as one at 11 km.

**The authored `difficulty` field has stopped predicting lethality.** Bramble's
recovery share is unchanged at 18.9% and its mean authored difficulty moved
only 3.15 → 3.25, while measured deaths/km at 8 km went 7.01 → 19.47. A 3%
change in the authored number accompanied a 178% change in the measured one.
Whatever makes the new vocabulary lethal — geometry the eight new ids produce,
34% of the pool being shutter weaves — is invisible to the rating. Treat the
`difficulty` field as a label, not a measurement, until something reconciles
them.

**These are findings, not fixes.** Bramble's tuning and Silk Hollow's pool are
zone content, which is the zone lane. Recorded here for the lane that owns it;
nothing in the pattern catalog was touched.

## Deaths per kilometre — the 1–8 km sweep

| Start | Novice | Intermediate | Expert |
| --- | ---: | ---: | ---: |
| 1,000 m | 4.81 ±0.54 | 2.79 ±0.31 | 1.45 ±0.16 |
| 2,000 m | 6.29 ±0.70 | 3.92 ±0.44 | 2.53 ±0.28 |
| 3,000 m | 6.02 ±0.67 | 3.82 ±0.43 | 3.56 ±0.40 |
| 4,000 m | 6.03 ±0.67 | 5.38 ±0.60 | 3.83 ±0.43 |
| 4,500 m | 7.46 ±0.83 | 5.24 ±0.59 | 3.88 ±0.43 |
| 5,000 m | 13.36 ±1.49 | 9.50 ±1.06 | 10.23 ±1.14 |
| 5,500 m | 9.29 ±1.04 | 8.71 ±0.97 | 8.07 ±0.90 |
| 6,000 m | 12.04 ±1.35 | 11.62 ±1.30 | 10.93 ±1.22 |
| 7,000 m | 13.30 ±1.49 | 13.15 ±1.47 | 15.34 ±1.71 |
| 8,000 m | 18.27 ±2.04 | 19.47 ±2.18 | 17.94 ±2.01 |

## Skill sensitivity

Novice deaths/km ÷ expert deaths/km. High means the band rewards
skill; ~1.0 means playing well does not help, which is a content
signal rather than a difficulty one.

| Start | Novice | Expert | Ratio |
| --- | ---: | ---: | ---: |
| 1,000 m | 4.81 | 1.45 | 3.31× |
| 2,000 m | 6.29 | 2.53 | 2.49× |
| 3,000 m | 6.02 | 3.56 | 1.69× |
| 4,000 m | 6.03 | 3.83 | 1.58× |
| 4,500 m | 7.46 | 3.88 | 1.92× |
| 5,000 m | 13.36 | 10.23 | 1.31× |
| 5,500 m | 9.29 | 8.07 | 1.15× |
| 6,000 m | 12.04 | 10.93 | 1.10× |
| 7,000 m | 13.30 | 15.34 | 0.87× |
| 8,000 m | 18.27 | 17.94 | 1.02× |

## Deaths per kilometre — the briefed bands

Rate normalizes on ground **travelled**, not course position, and
counts the rescued death as well as the terminal one. `±` is the
Poisson standard error — band-to-band wobble inside it is sample
size, not difficulty.

| Start | Novice | Intermediate | Expert |
| --- | ---: | ---: | ---: |
| 0 m | 2.16 ±0.24 | 1.23 ±0.14 | 0.91 ±0.10 |
| 5,000 m | 13.36 ±1.49 | 9.50 ±1.06 | 10.23 ±1.14 |
| 10,000 m | 6.29 ±0.70 | 5.46 ±0.61 | 3.62 ±0.40 |
| 15,000 m | 8.75 ±0.98 | 5.72 ±0.64 | 4.09 ±0.46 |
| 20,000 m | 7.58 ±0.85 | 6.46 ±0.72 | 4.16 ±0.47 |

## Distance survived from the start line

| Start | Skill | Mean | Median | p10 | p90 | Timeouts |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 0 m | novice | 925 m | 1,043 m | 341 m | 1,343 m | 0 |
| 0 m | intermediate | 1,623 m | 1,605 m | 1,092 m | 2,163 m | 0 |
| 0 m | expert | 2,193 m | 2,239 m | 1,768 m | 2,554 m | 0 |
| 5,000 m | novice | 150 m | 134 m | 112 m | 228 m | 0 |
| 5,000 m | intermediate | 211 m | 206 m | 121 m | 286 m | 0 |
| 5,000 m | expert | 196 m | 184 m | 141 m | 274 m | 0 |
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
| 5,000 m | novice | obstacle ×32 · boundary ×8 | 0 | canopy_shutter_low_high ×19 · canopy_hook_high ×12 · canopy_shutter_high_low ×9 |
| 5,000 m | intermediate | obstacle ×27 · boundary ×13 | 4 | canopy_shutter_high_low ×14 · canopy_hook_high ×12 · canopy_shutter_low_high ×9 · canopy_hook_low_high ×5 |
| 5,000 m | expert | obstacle ×38 · boundary ×2 | 3 | canopy_shutter_low_high ×25 · canopy_shutter_high_low ×11 · canopy_hook_high ×2 · canopy_hook_low ×1 · canopy_leaf_high ×1 |
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
| 5,000 m | novice | 30.7 | 1.3 | 0.1 | 0.33 s | 0.00 s |
| 5,000 m | intermediate | 29.4 | 2.7 | 0.7 | 0.64 s | 0.00 s |
| 5,000 m | expert | 23.4 | 3.9 | 1.9 | 0.51 s | 0.00 s |
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
ramp, the 8 km peak, the 10 km collapse and the skill-sensitivity curve all
rest on that comparison.

**Not load-bearing — the 0 m band is not comparable to a warped band.** A run
started at 0 m travels ~1.6 km through the entire opening ramp, so its rate
averages the easy runway with everything after it, while a warped band samples
a 100–600 m window at one difficulty. Reading "0 m = 1.23, 5 km = 9.50" as an
8× step is wrong; much of that gap is the averaging window. Compare warped to
warped.

**Not load-bearing — flies/km in a warped band.** Every warped run gets a fresh
guided opening, so per-run fly income is amortized over a short window and the
rate is inflated. The economy slice must measure income over full runs from
0 m.

**A real signal worth carrying forward: the Reel meter is never a constraint.**
Across all 15 configurations `reel empties` is 0.00 and `time at empty` is
0.00 s — the bot never exhausts the meter in any band at any skill. This
extends the 2026-07-30 lab observation from the early game to every band out to
20 km: depth does not create meter pressure either. Any upgrade track buying
Reel capacity or regeneration is improving a resource that never runs out. The
upgrade audit should test that first.

Two smaller notes. Deaths split roughly evenly between `boundary` and
`obstacle` in every band with no distance trend — the failure *mode* does not
change with depth, only its frequency. And the blank pattern id in the 0 m
novice row is chunk 0, served before a pattern is assigned.

## Method

- Bot model v2, `balanced_baseline`, `classic`, 0 upgrades, rescue life on.
- 40 runs per skill tier per band, rotating course seeds 1337–1344, bot seed
  base 1, 240 s cap. No run timed out, so every run ended in a death.
- Deaths per km normalizes on ground **travelled** (`distance_m - start_m`) and
  counts the rescued death as well as the terminal one — a rescued death is
  still a mistake the player made.
- `±` is the Poisson standard error on the rate (`rate / sqrt(deaths)`).
  Band-to-band wobble inside it is sample size, not difficulty.

Reproduce:

```bash
python3 tools/difficulty_curve.py --runs=40 --course-seeds=8 \
  --bands=0,5000,10000,15000,20000 --out=/tmp/canonical.md
python3 tools/difficulty_curve.py --runs=40 --course-seeds=8 \
  --bands=1000,2000,3000,4000,4500,5000,5500,6000,7000,8000 --out=/tmp/fine.md
```

Both are deterministic: the same flags reproduce these numbers exactly. The
0 m and 10 km+ bands are byte-identical to the pre-#69 measurement, which is
the internal check that #69's effect is confined to Bramble Canopy.

## What the later slices should take from this

- **Difficulty modes.** The sanctioned dials — which content the stream serves
  and how much recovery the player gets — are the two levers this measures.
  Recovery share (2.4% / 18.9% / 20.8% by zone) is the cleanest single knob and
  needs no physics change. Use the skill-sensitivity ratio as the acceptance
  test: a mode that lowers deaths/km but also flattens the ratio has made the
  game easier without making it fairer.
- **Upgrade audit.** Test the Reel-meter hypothesis first. Re-run this grid at
  `--upgrades=0` vs `10` vs `20`; a track that does not move deaths/km by more
  than its error bar is noise.
- **Currency and rewards.** Do not use the warped flies/km figures. Measure
  income over full runs from 0 m.
- **Ideas.** Two measured gaps worth a proposal: the 10 km cliff, where the
  game's hardest content is immediately followed by its most static, and the
  flat plateau past it, where a player sees no new pressure for 20 km.
