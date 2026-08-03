# What it took to reach 10 km — the first play data in this repository

> **Status:** `reference`
>
> Thirty-five recorded attempts and one success, played consecutively in a single
> sitting on 2026-08-02, supplied by the owner as a gallery recording on
> 2026-08-03. **Every prior measurement in this repository is geometry.** This is
> the first thing that says anything about deaths.
>
> **It is 35 samples from one expert player in one sitting.** Read it as a
> direction, never as a rate.

## Method

The gallery lists each run as a video with a duration. The owner states recording
began about **2 s before** each run and ended **at most 5 s after** death, so run
time ≈ duration − 7 s. That lead-in is confirmed rather than assumed: the 10 km
run's HUD reads `053.2 m` (the previous run's residue) at t = 0 and resets to
`003.3 m` at t = 2.

Distance is converted at the successful run's own end-to-end pace — 10 605 m over
about 143 s of running, **≈ 74 m/s**. Short runs average slower than that from a
standing start, so their distances are **upper bounds**.

Some recordings were deleted before the gallery was captured, so 35 is a floor on
the attempt count, not a count.

## The survival curve

`measured`, with the conversion caveats above.

| band | entered | died in band | hazard |
| --- | ---: | ---: | ---: |
| 0 – 1 000 m | 35 | 9 | 26% |
| 1 000 – 1 500 | 26 | 5 | 19% |
| 1 500 – 2 000 | 21 | 4 | 19% |
| **2 000 – 2 500** | **17** | **7** | **41%** |
| 2 500 – 3 000 | 10 | 2 | 20% |
| 3 000 – 3 500 | 8 | 0 | 0% |
| 3 500 – 4 000 | 8 | 2 | 25% |
| 4 000 – 5 000 | 6 | 0 | 0% |

Hazard is deaths divided by runs that *actually reached* the band — never raw
counts — as
[`difficulty-research-2026-08-02.md`](../game-design/difficulty-research-2026-08-02.md)
§ 3 requires.

| | duration | ≈ distance |
| --- | ---: | ---: |
| median attempt | 0:32 | ~1 850 m |
| 75th percentile | 0:43 | ~2 660 m |
| longest failure | 1:40 | ~6 900 m |
| **the success** | **2:29** | **10 605 m** |

**The successful run is 4.7× longer than the median attempt, and only 17% of
attempts reached 5 km at all.**

## The finding

**Hazard peaks at 2 000 – 2 500 m, at 41% — double the surrounding bands.**

That is immediately past `MASTERY_START_DISTANCE`, where the authored label jumps
**1.30 → 3.27** and hard-pattern share goes **0% → 93% inside 250 m**. R3 was
written to forbid exactly that cliff, from geometry alone, before any play data
existed. **The play data now lands on the same place independently.**

That convergence is the point. Two instruments — a label-free geometric walk of
the generator, and 35 recorded deaths — with no shared inputs, both name 2 km.

## What the number is not

**It is not a content difficulty.** The owner's own account of the same sitting:

> *"Some of my early deaths can be attributed to the fact that I rushed through
> the first 2km at most of my runs, not really paying attention and reeling
> excessively to speed it up, which caused me to be unprepared for when the
> difficulty suddenly increased."*

So 41% measures **content × player state on arrival**, and the player state was
manufactured by the preceding two kilometres being dull. The causal chain the
design owns:

> opening too easy → player disengages and reels to skip it → arrives at 2 km **at
> the speed cap, inattentive** → the cliff lands at maximum speed → 41%

**Tuning obstacles at 2–2.5 km would be treating a symptom whose cause is a
kilometre upstream.** Two interventions attack this, and they are complementary
rather than redundant: the front-loaded pressure curve makes 0–2 km worth playing
attentively, and R3's bounded slope removes the cliff it delivers you to.

It also retro-justifies a measurement choice. The course audit reports spacing
*at the speed cap for that distance* — the worst case. This account says the worst
case **is** the realistic case at 2 km, because reeling puts him there. Ancient
Forest's 0.29–0.31 s is what he actually faces, not a pessimistic figure.

## It sharpens the doctrine rather than contradicting it

The doctrine records *"between 2500 and 5000 most of my deaths occur"*. That is a
**hazard** intuition — where you die *given* you got there — and it is
directionally right. The raw distribution peaks one band earlier, because most
runs never reach 2.5 km. Both statements are true and they measure different
things; this is the first evidence able to separate them, which is precisely the
separation § 3 of the research doc demanded.

## A behavioural signal with a predicted direction

**Reel usage per kilometre over the first 2 km is a boredom proxy.** The owner
reeled excessively there *because the section was not worth playing*. If the
front-loaded curve works, that number should fall — which makes it a check on
whether the fix landed rather than only a description of the problem. It is the
only behavioural signal identified so far that has a predicted direction, and it
costs nothing to log.

## Claim provenance (PL-013)

- **`measured`** — the durations, the attempt count, the 2 s lead-in calibration,
  and the 10 km run's pace.
- **`inferred`** — every distance, since it converts duration at one run's average
  pace; and the whole survival table, which inherits that conversion.
- **`assumed`** — that 35 attempts by one expert in one sitting says anything
  about any other player. It does not. Fatigue and learning are both inside this
  sample and cannot be separated from it.

**Every identified source of error pushes deaths earlier, not later** — deleted
recordings, recording overhead, and slower early pace all shorten the estimates.
The 2 000 – 2 500 m spike is therefore the conservative reading.
