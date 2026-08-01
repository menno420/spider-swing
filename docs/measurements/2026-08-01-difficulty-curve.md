# Difficulty curve measurement — 2026-08-01

> **Status:** `reference`
>
> Baseline for slices that follow. Diagnostic instrumentation, not a gate and
> not a feel oracle: it reports what a scripted bot does, not what the owner
> feels. Re-measure and diff rather than trusting these numbers forever.
>
> **Re-measured against `main` at PR #73** (zones 4–8). The earlier reading of
> this file, taken at PR #69, is fully superseded — not only above 15 km. PR
> #73 also touched `simulation_world.gd` and `web_constraint.gd`, so bands
> whose content never changed moved anyway: 10 km went 5.46 → 7.68 deaths/km
> with Silk Hollow's pattern pool untouched. When the simulation moves, the
> whole curve moves.

> **SUPERSEDED for every warped band (5 km and up) by owner device evidence,
> 2026-08-01.** A 48-second recording of the owner playing a debug start at
> 5 000 m with maxed upgrades — the *same warp condition* these bands use —
> measures him at **3 113 m to his first death (0.32 deaths/km)**, still alive
> at 8 554 m, averaging 78.6 m/s.
>
> The bot on that band travels **196 m** and dies at **10.23 deaths/km**. The
> owner goes **18× further** and dies **32× less often per kilometre**.
>
> So the warped-band numbers below measure the bot failing at pace, not how
> hard the course is. Two visible causes: the bot has **never performed a Dive**
> in any batch, while the recording shows the owner using Dive Pull constantly
> as a primary verb; and its fixed decision cadence is not viable at ~78 m/s,
> where it dies in under three seconds.
>
> **Do not read zone difficulty off this document.** The 0 m band, which runs
> the opening ramp rather than a warp, is the only reading here not contradicted
> by device evidence — and it is still one scripted model, not a person.
>
> Kept rather than deleted so the failure is legible. What would replace it: a
> device reading per zone, or a bot that Dives and engages the anchor classes
> zones 4–8 introduced.

## Headline

**The curve now has two cliffs, and the second one is new.** Intermediate bot,
`balanced_baseline`, no upgrades, Standard difficulty:

| Band | Zone | Deaths/km |
| --- | --- | ---: |
| 0 m | Ancient Forest (whole opening ramp) | 1.23 ±0.14 |
| 5 km | Bramble Canopy | 9.50 ±1.06 |
| 10 km | Silk Hollow | 7.68 ±0.86 |
| 15 km | Ruined Arboretum | 6.50 ±0.73 |
| 20 km | Storm Ridge | 8.94 ±1.00 |
| **25 km** | **Web City** | **2.55 ±0.29** |

Zones 4 and 5 sit sensibly in the established range. **Web City at 25 km does
not**: at 2.55 deaths/km it is 3.5× easier than Storm Ridge immediately before
it, easier than Bramble Canopy at 5 km, and only twice the difficulty of the
opening ramp. An expert survives 1 394 m there against 296 m at 20 km. A player
who fights through Storm Ridge is rewarded with the easiest content since the
tutorial.

That is a zone-content finding, not a systems one — recorded here for the lane
that owns it. Nothing in the pattern catalog was touched by this slice.

**Skill sensitivity is healthy again at depth.** The 5 km band remains the
flattest in the game at 1.31× (novice deaths/km ÷ expert), which is the
Bramble-Canopy signal from the previous measurement. Zones 4–8 restore it:
1.62× at 15 km, 2.23× at 20 km, 2.05× at 25 km, against 2.37× on the opening.

## Deaths per kilometre

Rate normalizes on ground **travelled**, not course position, and
counts the rescued death as well as the terminal one. `±` is the
Poisson standard error — band-to-band wobble inside it is sample
size, not difficulty.

| Start | Novice | Intermediate | Expert |
| --- | ---: | ---: | ---: |
| 0 m | 2.16 ±0.24 | 1.23 ±0.14 | 0.91 ±0.10 |
| 5,000 m | 13.36 ±1.49 | 9.50 ±1.06 | 10.23 ±1.14 |
| 10,000 m | 8.60 ±0.96 | 7.68 ±0.86 | 5.13 ±0.57 |
| 15,000 m | 8.29 ±0.93 | 6.50 ±0.73 | 5.12 ±0.57 |
| 20,000 m | 15.06 ±1.68 | 8.94 ±1.00 | 6.76 ±0.76 |
| 25,000 m | 2.94 ±0.33 | 2.55 ±0.29 | 1.43 ±0.16 |

## Skill sensitivity

Novice deaths/km ÷ expert deaths/km. High means the band rewards
skill; ~1.0 means playing well does not help, which is a content
signal rather than a difficulty one.

| Start | Novice | Expert | Ratio |
| --- | ---: | ---: | ---: |
| 0 m | 2.16 | 0.91 | 2.37× |
| 5,000 m | 13.36 | 10.23 | 1.31× |
| 10,000 m | 8.60 | 5.13 | 1.68× |
| 15,000 m | 8.29 | 5.12 | 1.62× |
| 20,000 m | 15.06 | 6.76 | 2.23× |
| 25,000 m | 2.94 | 1.43 | 2.05× |

## Distance survived from the start line

| Start | Skill | Mean | Median | p10 | p90 | Timeouts |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 0 m | novice | 925 m | 1,043 m | 341 m | 1,343 m | 0 |
| 0 m | intermediate | 1,623 m | 1,605 m | 1,092 m | 2,163 m | 0 |
| 0 m | expert | 2,193 m | 2,239 m | 1,768 m | 2,554 m | 0 |
| 5,000 m | novice | 150 m | 134 m | 112 m | 228 m | 0 |
| 5,000 m | intermediate | 211 m | 206 m | 121 m | 286 m | 0 |
| 5,000 m | expert | 196 m | 184 m | 141 m | 274 m | 0 |
| 10,000 m | novice | 233 m | 241 m | 102 m | 322 m | 0 |
| 10,000 m | intermediate | 260 m | 276 m | 107 m | 405 m | 0 |
| 10,000 m | expert | 390 m | 476 m | 120 m | 578 m | 0 |
| 15,000 m | novice | 241 m | 204 m | 103 m | 336 m | 0 |
| 15,000 m | intermediate | 308 m | 235 m | 146 m | 507 m | 0 |
| 15,000 m | expert | 390 m | 317 m | 196 m | 580 m | 0 |
| 20,000 m | novice | 133 m | 69 m | 66 m | 293 m | 0 |
| 20,000 m | intermediate | 224 m | 203 m | 78 m | 295 m | 0 |
| 20,000 m | expert | 296 m | 294 m | 199 m | 395 m | 0 |
| 25,000 m | novice | 680 m | 581 m | 190 m | 1,237 m | 0 |
| 25,000 m | intermediate | 784 m | 671 m | 143 m | 1,189 m | 0 |
| 25,000 m | expert | 1,394 m | 1,134 m | 346 m | 2,433 m | 0 |

## Death causes

| Start | Skill | Causes | Mid-pull | Patterns at death |
| --- | --- | --- | ---: | --- |
| 0 m | novice | boundary ×29 · obstacle ×11 | 1 |  ×19 · hanging_vine ×5 · rooted_gate ×5 · fallen_stump ×4 · bramble_curve ×2 · floor_vine ×2 · thorn_ridge ×2 · ceiling_stump ×1 |
| 0 m | intermediate | obstacle ×22 · boundary ×18 | 4 | rooted_gate ×9 · bramble_curve ×6 · floor_vine ×5 · thorn_ridge ×5 ·  ×3 · ceiling_stump ×3 · fallen_stump ×3 · canopy_pod ×2 · staggered_s ×2 · hanging_vine ×1 · low_high_weave ×1 |
| 0 m | expert | boundary ×20 · obstacle ×20 | 9 | tight_rail ×8 · fallen_stump ×4 · low_high_weave ×4 · rooted_gate ×4 · high_low_weave ×3 · thorn_ridge ×3 · bramble_curve ×2 · canopy_pod ×2 · ceiling_stump ×2 · silk_burr_high ×2 · vine_curtain ×2 · bramble_steps ×1 · floor_vine ×1 · silk_burr_low ×1 · staggered_s ×1 |
| 5,000 m | novice | obstacle ×32 · boundary ×8 | 0 | canopy_shutter_low_high ×19 · canopy_hook_high ×12 · canopy_shutter_high_low ×9 |
| 5,000 m | intermediate | obstacle ×27 · boundary ×13 | 4 | canopy_shutter_high_low ×14 · canopy_hook_high ×12 · canopy_shutter_low_high ×9 · canopy_hook_low_high ×5 |
| 5,000 m | expert | obstacle ×38 · boundary ×2 | 3 | canopy_shutter_low_high ×25 · canopy_shutter_high_low ×11 · canopy_hook_high ×2 · canopy_hook_low ×1 · canopy_leaf_high ×1 |
| 10,000 m | novice | boundary ×31 · obstacle ×9 | 0 | hollow_lattice_high ×10 · hollow_thread_eye ×6 · hollow_droplet_needles ×5 · hollow_orb_cluster ×4 · hollow_spindle_gate ×4 · hollow_twin_sacs ×4 · hollow_suspended_bridge ×3 · hollow_lattice_low ×2 · hollow_cocoon_chute ×1 · open_recovery ×1 |
| 10,000 m | intermediate | boundary ×29 · obstacle ×11 | 3 | hollow_lattice_high ×9 · open_recovery ×9 · hollow_suspended_bridge ×7 · hollow_droplet_needles ×5 · hollow_orb_cluster ×4 · hollow_spindle_gate ×3 · hollow_thread_eye ×2 · hollow_lattice_low ×1 |
| 10,000 m | expert | boundary ×25 · obstacle ×15 | 7 | hollow_droplet_needles ×16 · hollow_lattice_high ×11 · hollow_spindle_gate ×6 · hollow_suspended_bridge ×5 · hollow_lattice_low ×1 · hollow_twin_sacs ×1 |
| 15,000 m | novice | obstacle ×24 · boundary ×16 | 1 | arboretum_beam_high ×9 · arboretum_drip_arch_high ×8 · arboretum_drip_arch_low ×8 · arboretum_frame_rest_high ×7 · arboretum_beam_corridor ×4 · arboretum_beam_low ×3 · open_recovery ×1 |
| 15,000 m | intermediate | obstacle ×28 · boundary ×12 | 3 | arboretum_beam_high ×12 · arboretum_drip_arch_high ×12 · arboretum_beam_corridor ×6 · arboretum_frame_rest_high ×5 · arboretum_drip_arch_low ×4 · arboretum_frame_rest_low ×1 |
| 15,000 m | expert | obstacle ×39 · boundary ×1 | 1 | arboretum_drip_arch_high ×17 · arboretum_beam_corridor ×7 · arboretum_beam_high ×6 · arboretum_frame_rest_high ×6 · arboretum_drip_arch_low ×3 · arboretum_frame_rest_low ×1 |
| 20,000 m | novice | boundary ×34 · obstacle ×6 | 0 | open_recovery ×25 · ridge_lightning_high ×5 · ridge_wind_tree_low ×4 · ridge_lightning_low ×3 · ridge_open_gust ×1 · ridge_scree_high ×1 · ridge_split_spires ×1 |
| 20,000 m | intermediate | boundary ×24 · obstacle ×16 | 1 | open_recovery ×10 · ridge_lightning_high ×9 · ridge_spire_low ×5 · ridge_open_gust ×4 · ridge_wind_tree_high ×4 · ridge_scree_chute ×3 · ridge_wind_tree_low ×2 · ridge_lightning_low ×1 · ridge_scree_high ×1 · ridge_spire_high ×1 |
| 20,000 m | expert | obstacle ×36 · boundary ×4 | 5 | ridge_lightning_high ×17 · ridge_spire_low ×7 · ridge_open_gust ×5 · ridge_spire_high ×5 · ridge_wind_tree_high ×4 · open_recovery ×1 · ridge_scree_chute ×1 |
| 25,000 m | novice | boundary ×36 · obstacle ×4 | 0 | city_resident_high ×7 · city_sticky_high ×7 · city_egg_arch ×6 · open_recovery ×5 · city_highway_high ×4 · city_sticky_low ×3 · city_torn_high ×3 · city_highway_diagonal ×2 · city_resident_low ×2 · city_highway_low ×1 |
| 25,000 m | intermediate | boundary ×34 · obstacle ×6 | 9 | city_resident_high ×8 · city_torn_high ×8 · city_egg_arch ×6 · city_highway_high ×6 · city_sticky_high ×6 · open_recovery ×4 · city_resident_low ×1 · city_sticky_low ×1 |
| 25,000 m | expert | boundary ×26 · obstacle ×14 | 12 | city_egg_arch ×13 · city_resident_high ×7 · city_torn_high ×7 · city_highway_high ×6 · open_recovery ×4 · city_sticky_high ×3 |

## Resource pressure

| Start | Skill | Flies/km | Webs/run | Bursts/run | Reel held | At empty |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 0 m | novice | 11.2 | 13.7 | 1.5 | 4.32 s | 0.00 s |
| 0 m | intermediate | 13.4 | 23.6 | 8.4 | 5.90 s | 0.00 s |
| 0 m | expert | 14.6 | 41.0 | 19.2 | 7.19 s | 0.00 s |
| 5,000 m | novice | 30.7 | 1.3 | 0.1 | 0.33 s | 0.00 s |
| 5,000 m | intermediate | 29.4 | 2.7 | 0.7 | 0.64 s | 0.00 s |
| 5,000 m | expert | 23.4 | 3.9 | 1.9 | 0.51 s | 0.00 s |
| 10,000 m | novice | 22.0 | 2.1 | 0.2 | 0.58 s | 0.00 s |
| 10,000 m | intermediate | 22.8 | 3.2 | 0.9 | 0.74 s | 0.00 s |
| 10,000 m | expert | 20.5 | 6.2 | 2.6 | 1.24 s | 0.00 s |
| 15,000 m | novice | 21.4 | 2.3 | 0.2 | 0.48 s | 0.00 s |
| 15,000 m | intermediate | 21.9 | 3.3 | 1.2 | 0.66 s | 0.00 s |
| 15,000 m | expert | 22.1 | 6.0 | 3.0 | 0.83 s | 0.00 s |
| 20,000 m | novice | 12.0 | 1.4 | 0.1 | 0.12 s | 0.00 s |
| 20,000 m | intermediate | 11.6 | 2.3 | 1.2 | 0.43 s | 0.00 s |
| 20,000 m | expert | 12.2 | 3.5 | 4.1 | 0.55 s | 0.00 s |
| 25,000 m | novice | 8.8 | 6.7 | 0.9 | 1.28 s | 0.00 s |
| 25,000 m | intermediate | 10.0 | 9.3 | 3.1 | 1.46 s | 0.00 s |
| 25,000 m | expert | 13.8 | 22.9 | 11.4 | 2.50 s | 0.00 s |

## Difficulty modes — acceptance evidence

Measured 2026-08-01 with `--difficulty`, 30 runs per skill per mode, course
seeds 1337–1342, 180 s cap, from 0 m. Modes change content and recovery only;
`DifficultyTests` asserts no mode moves any physics field.

**Distance survived (m), the honest cross-mode comparator:**

| Mode | Novice | Intermediate | Expert | Expert ÷ novice |
| --- | ---: | ---: | ---: | ---: |
| Relaxed | 2 529 | 3 096 | 3 806 | 1.51× |
| Standard | 982 | 1 714 | 2 258 | 2.30× |
| Harsh | 609 | 1 133 | 1 448 | 2.38× |

The ordering is monotone at every skill tier, which is the first thing a mode
set has to get right.

**Harsh passes the acceptance test.** It raises difficulty while *preserving*
skill sensitivity (2.38× against Standard's 2.30×) — harder, and still fair.

**Relaxed deliberately flattens it** (1.51×), and that is worth stating plainly
rather than hiding. Non-lethal rails remove the failure mode that punishes
novices most, so the gap between a novice and an expert narrows. By the brief's
acceptance test that reads as "easier without being fairer" — and it is exactly
why Relaxed is excluded from records and from region checkpoints. (The decision
ledger is the home for that rule; see `docs/current-state.md`.) Relaxed is a
way to enjoy the course, not
a way to prove anything, and its per-mode best is kept precisely so it has
somewhere to show a good run that is not the record.

**A measurement trap worth not re-learning: deaths/km is not comparable across
modes.** Harsh reports 1.64 deaths/km at novice against Standard's 2.04 — while
killing the player twice as fast — because Harsh disables the rescue life, so a
Harsh run holds one death and a Standard run holds two. `tools/simulate.gd` now
reports `deaths/run` alongside the rate so the cause is visible. Compare modes
on distance survived.

## What these numbers do and do not support

**Load-bearing.** The warped bands (5 km and up) are directly comparable with
each other: each samples a narrow window under identical warp conditions. The
Web City cliff, the skill-sensitivity figures and the mode ordering all rest on
that comparison.

**Not load-bearing — the 0 m band is not comparable to a warped band.** A run
from 0 m travels ~1.6 km through the whole opening ramp, so its rate averages
the easy runway with everything after it, while a warped band samples a
100–600 m window at one difficulty. Compare warped to warped.

**Not load-bearing — flies/km in a warped band.** Every warped run gets a fresh
guided opening, so per-run income is amortized over a short window and inflated.
The economy slice must measure income over full runs from 0 m.

**The Reel meter is still never a constraint.** `reel empties` is 0.00 and
`time at empty` is 0.00 s in every band at every skill, now across zones 4–8 as
well. Any upgrade track buying Reel capacity or regeneration is improving a
resource that does not bind — the upgrade audit's first hypothesis.

## Method

- Bot model v2, `balanced_baseline`, `classic`, 0 upgrades, rescue life on
  (except Harsh, which disables it by design).
- 40 runs per skill tier per band for the curve; 30 per mode for the mode
  table. Course seeds 1337–1344, bot seed base 1, 240 s cap. No run timed out.
- Deaths per km normalizes on ground **travelled** and counts the rescued death
  as well as the terminal one. `±` is the Poisson standard error.

Reproduce:

```bash
python3 tools/difficulty_curve.py --runs=40 --course-seeds=8 \
  --bands=0,5000,10000,15000,20000,25000 --out=/tmp/curve.md

godot --headless --path . --script res://tools/simulate.gd -- \
  --runs=30 --skill=all --course-seeds=6 --max-seconds=180 --difficulty=harsh
```

Both are deterministic: the same flags reproduce these numbers exactly.
