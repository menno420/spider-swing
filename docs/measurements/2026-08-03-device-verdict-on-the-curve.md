# The first device verdict on the curve — eight runs, two of them unupgraded

> **Status:** `reference`
>
> Owner play on `0.39.0-pressure-curve-region-swap`, recorded as eight screen
> captures and supplied as a Drive folder on 2026-08-03. Read frame-by-frame
> from the HUD; every distance below is a direct reading of the death frame, not
> a conversion from duration.
>
> **This is the second body of play data this repository has, and the first on a
> curve-driven course.** The one it is compared against —
> [`owner-run-attrition`](2026-08-03-owner-run-attrition.md) — is 35 attempts on
> the pre-swap build.
>
> **Eight runs is not a rate.** Read every percentage here as a direction.

## The runs

`measured` — HUD distance and region at the death frame. Upgrade state is read
from the run banner, not assumed: runs 7 and 8 display
`DEBUG START 0 m · UPGRADES L0 · AWARDS NOTHING`.

| run | died at | region | spider |
| ---: | ---: | --- | --- |
| 1 | 1 205.0 m | Bramble Canopy | fully upgraded |
| 2 | 1 714.5 m | Bramble Canopy | fully upgraded |
| 3 | 2 985.5 m | Bramble Canopy | fully upgraded |
| 4 | 3 597.0 m | Bramble Canopy | fully upgraded |
| 5 | 6 582.0 m | Ancient Forest | fully upgraded |
| 6 | 8 180.7 m | Ancient Forest | fully upgraded |
| **7** | **5 869.9 m** | **Ancient Forest** | **L0** |
| **8** | **4 379.2 m** | Bramble Canopy | **L0** |

Median 3 988 m. Three of eight passed 5 km. None reached Silk Hollow.

> **Each recording contains the start of the next attempt.** The owner restarts
> instantly on death, so the frames after the death fade belong to a *new* run
> and read 8–50 m. Two of those were briefly misread as finals during this
> analysis before the absent spider gave it away — worth stating, because the
> same trap is waiting in every future recording.

## The 2 km band

**The finding this build was aimed at.**

Hazard is deaths divided by the runs that actually *reached* the band, never raw
counts — the same rule the attrition doc uses.

| band | before, 35 runs | now, 8 runs | entered |
| --- | ---: | ---: | ---: |
| 1 000 – 1 500 | 19% | 13% | 8 |
| 1 500 – 2 000 | 19% | 14% | 7 |
| **2 000 – 2 500** | **41%** | **0%** | **6** |
| 2 500 – 3 000 | 20% | 17% | 6 |
| 3 000 – 3 500 | 0% | 0% | 5 |
| 3 500 – 4 000 | 25% | 20% | 5 |
| 4 000 – 5 000 | 0% | 25% | 4 |

**Six runs entered the 2 000–2 500 m band and none died there.** That band
carried the sharpest spike in the pre-swap data, at double its neighbours, and
it sat immediately past the 1 750 → 2 000 m cliff that R3 was written to forbid.

**What this supports is "no evidence of a spike", not "the spike is gone."** Six
runs through a band cannot distinguish 0% from 15%. The claim that is safe is
the weaker one: the band no longer stands out against its neighbours, where
before it stood out by 2×.

Two other things moved in the same direction and carry the same caveat: median
distance 1 850 m → 3 988 m, and the share of runs reaching 5 km 17% → 37%.

## What the L0 runs say, and it is not what they were run to test

They were run to answer one question — *is the new opening passable without
upgrades?* It is: run 7 cleared Bramble and died at 5 870 m in Ancient Forest,
run 8 reached 4 379 m.

The unasked result is the more interesting one. **Run 7 at L0 beat four of the
six fully-upgraded runs.** The L0 runs sit mid-pack rather than at the bottom,
which says upgrades are not what carries the first 5 km.

The owner's own reading of why, and it fits the numbers:

> *"what the upgrades mostly did was make it faster to play, not necessarily a
> lot easier, it just changes the playstyle a lot."*

**`inferred`, and confounded.** The L0 runs were played *after* the upgraded
ones in the same sitting, so within-session learning is inseparable from upgrade
state in this sample. A clean answer needs the two interleaved, or two players.

## A bound worth writing down before anyone raises Bramble's density again

The owner reported needing a double Burst several times in the upgraded runs.
Chased through source rather than left as an impression:

| term | value |
| --- | ---: |
| `burst_cooldown` | 1.65 s |
| `burst_charge_capacity`, base | **1** |
| `burst_charge_capacity`, upgraded | 2 |
| one chunk at the speed cap | 1.26 – 1.35 s |

**The cooldown is longer than a chunk.** So two consecutive chunks that each
demand a Burst are not clearable on one charge — they are on two.

Before this build, Bramble never placed two challenge chunks in a row — the
Bramble spacing decision isolated every commitment with an open chunk. The
pressure-curve slice raised its challenge share from 50% to 72% and allows runs
of up to four.

**The L0 clear says this is not binding today.** It is recorded as a *bound*
rather than a defect, because it is the term that breaks first if Bramble's
density rises again, and because nothing in the suite currently watches it —
the fairness contracts check corridor width, spacing and route traversability,
none of which can see a charge economy.

## Method, and its limits

Frames extracted with `ffmpeg` at the death moment and read directly; the HUD
renders distance zero-padded to five characters (`014.8 m`, `046.6 m`), which is
a formatting detail worth knowing before reading a low number as a bug.

**An automated digit classifier was built for this and then discarded.** Nearest
-neighbour template matching over segmented glyphs decoded roughly 15% of frames
and produced impossible values — 99 003 m — because the HUD is white text over a
moving, high-contrast canopy. The numbers in this document are all direct visual
reads of individual frames. *Recorded because the failed approach is the one a
later session would otherwise try first.*

## Claim provenance (PL-013)

- **`measured`** — the eight distances, the regions, the L0 banner, and the four
  source constants in the Burst table.
- **`inferred`** — every hazard percentage, which divides tiny counts; and the
  before/after comparison, which sets 8 runs against 35 on a different build.
- **`assumed`** — that any of this generalises past one player. It does not. The
  owner's own conclusion from this sitting is that it needs *"multiple opinions
  from other players"*, and that judgement is not something this data can make
  for him.
