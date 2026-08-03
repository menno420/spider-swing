# The curve drives the course — before and after, measured

> **Status:** `reference`
>
> Phases 3 and 4 of [the doctrine](../game-design/difficulty-and-obstacle-doctrine.md),
> landed together because **S4** says they cannot land apart. Selection now reads
> `CoursePressure` and nothing else for *amount*; Bramble Canopy opens the game
> and Ancient Forest follows.
>
> Measured with `tools/course_audit.gd` at 40 vertical probes per chunk, three
> seeds (1000–1002), chunks 0–156, on the pinned
> `4.7.1.stable.official.a13da4feb`. Course generation is a pure function of
> `(chunk_index, distance, course_seed)`, so **a repeat run is not independent
> confirmation.**
>
> Reproduce either column with:
>
> ```bash
> godot --headless --path . --script res://tools/course_audit.gd -- \
>   --to-metres=15000 --seeds=3
> ```

## The course moved, and here is the proof rather than the claim

| | commit | digest, 3 seeds, chunks 0–156 |
| --- | --- | --- |
| before | `e2c1167` | `abd839ea…f281d3e7` |
| after | this branch | `db540077…c485d439` |

The two-seed window the suite pins moved from `4d7bbdf2…b1d249f076f` to
`087252417…dcf75704b`. **That contract failing was the deliverable** — it was
written to fail the moment a phase wired selection onto the curve, so that no
generator change can land looking like a no-op.

## Per kilometre

`measured`. `press` is `CoursePressure` at the kilometre mark and it now drives
selection; `size` is the obstacle scale the curve asks for; `dens%` counts
challenge chunks against *scheduled* chunks, excluding the warm-up, which draws
no pattern at all.

| km | region | press | size | label | dens% | minGap (d) | pinch (sw) | minOpp (s) |
| ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 0 | bramble_canopy | 0.000 | 0.63 | 1.09 | 80% | 12.09 | 26.7 | — |
| 1 | bramble_canopy | 0.025 | 0.94 | 2.00 | 60% | 8.49 | 11.3 | 0.94 |
| 2 | bramble_canopy | 0.108 | 1.02 | 2.36 | 73% | 8.49 | 11.3 | 0.92 |
| 3 | bramble_canopy | 0.206 | 1.04 | 2.20 | 70% | 8.49 | 11.3 | 0.89 |
| 4 | bramble_canopy | 0.309 | 1.06 | 2.27 | 73% | 8.49 | 11.3 | 0.87 |
| 5 | ancient_forest | 0.412 | 1.07 | 2.67 | 80% | 7.39 | 11.3 | 0.28 |
| 6 | ancient_forest | 0.511 | 1.09 | 2.47 | 70% | 7.39 | 11.3 | 0.48 |
| 7 | ancient_forest | 0.605 | 1.10 | 2.79 | 73% | 7.39 | 11.3 | 0.27 |
| 8 | ancient_forest | 0.691 | 1.12 | 3.60 | 90% | 7.39 | 11.3 | 0.26 |
| 9 | ancient_forest | 0.769 | 1.13 | 2.91 | 73% | 7.39 | 11.3 | 0.28 |
| 10 | silk_hollow | 0.837 | 1.14 | 3.20 | 80% | 7.75 | 3.3 | 0.20 |
| 11 | silk_hollow | 0.894 | 1.15 | 3.20 | 80% | 7.75 | 3.3 | 0.20 |
| 12 | silk_hollow | 0.939 | 1.15 | 3.27 | 82% | 7.75 | 3.3 | 0.20 |
| 13 | silk_hollow | 0.973 | 1.16 | 3.20 | 80% | 7.75 | 3.3 | 0.20 |
| 14 | silk_hollow | 0.993 | 1.16 | 2.91 | 73% | 7.75 | 7.3 | 0.20 |

## The four targets, answered

### 1 · The 2 km cliff is gone

The defect: the authored label ran **1.30 → 3.27 inside 250 m** at 1750–2000 m,
hard-pattern share **0% → 93%**, and the play data put a **41% hazard spike** in
the band immediately after it.

There is no longer a step there at all. Nothing reads a distance threshold to
decide how hard a chunk is, so there is no threshold left to step at: the
steepest kilometre of pressure anywhere in scope is **0.1032 against the 0.15
bound**, and every difficulty term is a continuous function of it.

The mechanism the attrition doc blamed is also addressed upstream rather than at
the symptom. Its causal chain was *opening too easy → player reels to skip it →
arrives at 2 km at the speed cap, inattentive*. The warm-up now ends at 500 m
instead of 1 000 m — the owner's own number, which the code had never matched —
and obstacles ramp from 0.63× to full size over the next kilometre, so 0.5–2 km
is content rather than a corridor to reel through.

### 2 · The saw-tooth is gone

Region means of the authored label, in play order:

| | 1st region | 2nd | 3rd |
| --- | ---: | ---: | ---: |
| before | ancient_forest **2.81** | bramble_canopy **2.00** | silk_hollow **3.15** |
| after | bramble_canopy **2.28** | ancient_forest **2.88** | silk_hollow **3.15** |

Before, the middle term falls; after, the sequence rises throughout. The
**worst three-kilometre rolling dip falls from 17.4% to 4.1%**, against a
contracted bound of 15%.

> **Why a rolling window and not the raw kilometre.** A kilometre is 10.4
> chunks, so the recovery cadence aliases against the bucket boundary: one extra
> open chunk in ten moves the mean 10% by itself. R2 is explicit that
> monotonicity is a property of the **envelope**, not of the instantaneous
> signal — *"the naive reading … forbids both the section-entry ramp the owner
> asked for and the recovery chunks he asked for."* Three kilometres is the
> smallest window that removes the aliasing and still rejects the pre-swap
> course, which it does at 17.4%.

### 3 · Recovery share is inside (2%, 50%) for every region

O2's bound, owner-stated: strictly above Ancient Forest's shipped 2%, strictly
below Bramble's shipped 50%.

| region | before | after | cadence |
| --- | ---: | ---: | --- |
| bramble_canopy | **50.0%** | **28.3%** | every 2nd chunk → every 3rd → every 4th |
| ancient_forest | **2.4%** | **23.1%** | every 4th chunk → every 5th |
| silk_hollow | 21.2% | 21.2% | every 5th chunk |

One curve replaces three per-region constants. Ancient Forest's 23.1% is the
number its own catalogue entry has always claimed — F3 measured *"wide recovery
rhythm"* against a delivered 2% — and it is close to the 20% O2 calls the
natural first value. Silk Hollow lands on its shipped figure without being
told to.

**The cadence is an integer interval, not a fractional share.** A fractional
share has to place its openings by accumulator, and the phase then drifts
against the chunks-per-kilometre boundary in a way nobody chose. An integer is
also what R14 asks for and a drifting accumulator is not: *"a demonstration is
only a demonstration if the player can see the pattern as a pattern."* The
interval widening from 2 to 5 is legible from inside the run.

### 4 · The width envelope holds, and the two violators are fixed

| region | min | median | median ÷ min | near own min | longest run near min |
| --- | ---: | ---: | ---: | ---: | ---: |
| ancient_forest | **7.39** | 12.22 | 1.65 | 4% | 1 chunk / 96 m |
| bramble_canopy | 8.49 | 10.50 | 1.24 | 9% | 2 chunks / 192 m |
| silk_hollow | **7.75** | 10.39 | 1.34 | 24% | 2 chunks / 192 m |

In player diameters (36 px). **Swing-class minimum across the whole scoped
range: 7.75 diameters**, up from 6.69. `hollow_lattice_high` and
`hollow_lattice_low` were the only two patterns in the first 15 km below the
7.39 floor their class may never cross; their lattice height went 292 → 258 px.
The absolute minimum anywhere is 7.39 — Ancient Forest's endorsed `rooted_gate`
— against R8's 3.0-diameter backstop, which is therefore approached at 2.5×
margin and remains a backstop rather than a target.

> **One caveat, and it points the wrong way for a naive reading.** *Share near
> own minimum* is relative to each region's own floor, so **raising a floor
> mechanically raises the share**. Silk Hollow's went 18% → 24% *because* its
> minimum improved 6.79 → 7.75 and the distribution compressed toward it. The
> honest reading is the pair: its worst case improved 14% and its shape got
> flatter. `median ÷ min` is reported beside it for exactly that reason —
> Ancient Forest's 1.65 is the shape the width envelope endorses, and it is the region the
> owner named as the right kind of difficult.

## The two measurements the instrument lacked

Both are width × **duration** terms. Before this slice an obstacle could have
been reshaped into a 400 px tube at an unchanged minimum with every contract
green, and the 192 m-versus-96 m difference that actually separates Silk Hollow
from Ancient Forest was invisible to the suite.

**Constriction length within a chunk** — the longest run of samples within 10%
of that chunk's own minimum, in spider widths (36 px):

| what | pinch |
| --- | ---: |
| an empty chunk (corridor set by the rail contour alone) | 26.7 sw (960 px, the whole chunk) |
| Bramble / Ancient Forest commitment chunks | 11.3 sw (408 px) |
| Silk Hollow commitment chunks | **3.3 sw (120 px)** |

That inverts the intuition the width table gives on its own: Silk Hollow's
corridor is the tightest **and** its pinches are the shortest by 3.4×, which is
the same finding C1 recorded for `hollow_spindle_gate` generalised to the whole
region. Its difficulty is spacing, exactly as the width envelope says it should be.

**Consecutive chunks near a region's minimum** — 1 / 2 / 2 chunks for Ancient
Forest / Bramble / Silk Hollow. Contracted at 3, i.e. as a measurement with
regression headroom rather than as a difficulty target.

Resolution caveat, unchanged and still pointing the wrong way for a fairness
floor: at the audit's default 24 px step the minimum is **overestimated**
slightly. The length term inherits that coarseness and is quantised to the step.

## What got worse, stated plainly

**1 · Ancient Forest's tightest sequential pair went 0.288 s → 0.261 s, a 9%
tightening, on unchanged geometry.** Spacing is reported *at the speed cap for
that distance*, and moving Ancient Forest from 2–5 km to 5–10 km moves it into a
faster band of the shipped pace curve. The owner clears 0.29–0.31 s today on this
exact content. The counterweight is that he now meets it at 5 km rather than
2 km, with a kilometre of size-ramped Bramble behind him. **This is a device
question and it is the sharpest one in the slice.**

**2 · The thinnest pool in the game is now the opening region.** Bramble has
eight patterns against Ancient Forest's ladder of 38 — F6 and §9 both name it as
the thinnest, and §9 measures its repetition at 13× over a 5 km slot. Putting it
first is a known and accepted cost of the swap; the doctrine's Phase 4 is
explicit that this lands with *"no new patterns authored"*.

What partly offsets it is that **sequence variety went up while vocabulary
variety went down.** F7 measured Bramble as a memorisable four-beat loop —
`lowolowolowo`, 0% same-lane repeats, only 2 of 5 seeds differing. The loop is
gone: the cadence widens 2 → 3 → 4 across the region, pairs are admitted only
from ~1 km and only after an open chunk, and the freed slots draw from the whole
pool. The contract that used to demand ten distinct ids in that window now
demands all nine Bramble can produce, which is a higher bar against a smaller
pool.

**3 · One Harsh override became a no-op.** Standard's warm-up moved to 500 m,
which is the value Harsh already overrode to. It is kept rather than deleted —
it still records intent, and the difficulty-mode decision gives Harsh its real separation on the
predictability, density and spacing axes in the mode-profile phase.

## Every new contract was falsified with its real failure

Each mutation was applied and reverted **in isolation**, from a byte-for-byte
backup rather than `git checkout --` — which is a no-op on an untracked file and
silently accumulates mutations, a trap this repository has already been caught
by. A green baseline was proven before and after the whole run.

| falsification | caught by |
| --- | --- |
| constriction length reports the whole chunk instead of the run near the minimum | the empty-versus-pinched comparison |
| the near-minimum run is counted over sorted widths, destroying course order | the literal-input distribution contract (reads 6, authored 3) |
| the two lattice patterns are put back at 292 px | the swing-class floor (6.81 d against 7.39) |
| a region is held at its own minimum without ever going below it | the consecutive-chunks term (4 chunks against 3) |
| the cadence is clamped to its tightest, restoring 50% recovery | the (2%, 50%) bound |
| the cadence is widened past its ceiling | R7's consecutive-challenge run (7 against 5) |
| the last region delivers less than the one before it | the rolling envelope (a 24% drop against the 15% bound) |
| selection reads distance again instead of the curve | the course digest |

## What this does not say

1. **It is not difficulty and it is not calibrated.** Every figure is a
   geometric or structural proxy. Nothing here establishes that pressure 0.412
   at 5 km *feels* like anything in particular.
2. **No play data is involved.** The only play data in this repository is 35
   recorded attempts by one expert in one sitting, and it describes the course
   this slice replaced.
3. **`ONSET_SHAPE` is unchanged and still `assumed`.** It stays a source
   constant rather than a Test Lab dial because pattern selection must remain a
   pure function of `(chunk, distance, seed)` for traces to reproduce. The
   **obstacle size floor** is exposed instead, as
   `opening_obstacle_scale_floor`, because it is a geometry scale and the lab
   already tunes those.
4. **The size floor is a guess.** 0.60 as a multiplier on the mode's own scale,
   i.e. 0.54 effective at Standard — a 300 px Bramble hook drawn at 162 px, 28%
   of the corridor. Today's entire shipped range across all three modes is
   0.76–1.06 and the doctrine's worked example was 0.45.

## Claim provenance (PL-013)

- **`measured`** — every table above, three seeds, deterministic, on the pinned
  engine; both digests; the falsification results.
- **`inferred`** — that Ancient Forest's 9% spacing tightening is caused by the
  pace curve rather than by geometry. The geometry is unchanged and the speed
  cap is higher; the attribution is arithmetic, not an experiment.
- **`assumed`** — the size floor, the recovery-share interpolation between its
  two shipped endpoints, and that any of this predicts felt difficulty for
  anyone at all.
