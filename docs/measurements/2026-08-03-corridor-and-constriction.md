# Corridor width and constriction length — and three claims that did not survive

> **Status:** `reference`
>
> Measured 2026-08-03 with `tools/course_audit_probe.gd` on the pinned
> `4.7.1.stable.official.a13da4feb`, prompted by owner rulings on what a passable
> gap actually is. It supplies the numbers behind the corridor-width
> envelope recorded in the decision ledger — and it retires three width claims this repository had been reasoning from.
>
> **The headline: width is not the problem anywhere in the first 15 km, and the
> pattern the doctrine called "the tightest content in the game" is the
> best-behaved thing in Silk Hollow.**

## Per-region distribution

Largest interior free vertical span, in player diameters (36 px), three seeds,
0–15 km.

| region | tightest | median | share near its own min | longest run near min |
| --- | ---: | ---: | ---: | ---: |
| Ancient Forest | **7.39** | **12.29** | **6%** | **96 m** (1 chunk) |
| Bramble Canopy | 8.49 | 9.83 | 26% | 192 m |
| Silk Hollow | **6.79** | 10.39 | **18%** | **192 m** |

**Ancient Forest is the shape the owner endorses**: brief, isolated, rare pinches
inside a mostly-open corridor — a median nearly 1.7× the minimum, tight only 6% of
the time, never twice in a row.

**Silk Hollow diverges far more on frequency and duration than on width.** Its
minimum is only 8% tighter, but it sits near that minimum three times as often and
sustains it twice as long. That is why the envelope is written as a distribution: a
floor cannot see the difference.

Nothing anywhere in 0–15 km drops below **6 diameters** — double the owner's
stated 3-diameter backstop.

## Constriction length — the term nothing was watching

A narrow gap costs **width × length**. A pinch crossed in 50 ms demands far less
positional accuracy than a tube of the same width that must be threaded.
Measured at 2 px horizontal resolution, taking the run of samples within 10% of
each pattern's own minimum:

| pattern | lane | width | constriction | time at 710 px/s |
| --- | --- | ---: | ---: | ---: |
| `hollow_spindle_gate` | centre | 7.85 d | **0.17** spider widths | **8 ms** |
| `hollow_twin_sacs` | centre | 7.91 d | 1.17 | 59 ms |
| `rooted_gate` | centre | 7.39 d | 2.83 | 144 ms |
| **`hollow_lattice_high`** | **high** | **6.69 d** | **1.94** | **99 ms** |
| **`hollow_lattice_low`** | **low** | **6.69 d** | **1.94** | **99 ms** |

**Only `hollow_lattice_high` and `hollow_lattice_low` violate the width
envelope.** They are
`swing` class, below the 7.39-diameter floor that class may never cross, and they
hold it for ~2 spider widths. **They need widening.**

## Three claims that did not survive measurement

### C1 · `hollow_spindle_gate` is not "the tightest content in the game"

The course-audit baseline's **N1** names it the tightest thing shipped, at 180 px.
That figure is **centre-to-centre spacing between two obstacles** — a *timing*
quantity. Its **corridor** is 7.85 diameters with an 8 ms constriction, making it
the most generous tight pattern measured and the exemplar of the threading class.

N1 is not wrong about what it measured. It is wrong to read it as a width claim,
and R13 was framed against it as though it were one.

### C2 · The doctrine's § 2.2 corridor table is not reproducible

§ 2.2 reports Silk Hollow's tightest gate at **93 px** and its median at ~320 px,
seed 4242. Re-run on **that same seed** with the contracted instrument:

| | § 2.2 | measured 2026-08-03 |
| --- | ---: | ---: |
| tightest, 10–15 km | 93 px | **244.5 px** |
| median, 10–15 km | ~320 px | **374.1 px** |

It also claims the median chunk does not narrow the corridor at all below 10 km;
measured, Ancient Forest's median is 442 px and Bramble's 370 px against a 572 px
full corridor.

**Likely cause, and it is not carelessness:** the forgiving-lethal-contact
decision landed the same day and shrank every lethal contact polygon — a 4 px global inset plus alpha-traced
Bramble silhouettes removing up to ~77 px of invisible reach. § 2.2 almost
certainly measured the geometry as it stood before that inset landed. It is
superseded by a fix that landed beside it.

**Consequence: the 10 km "wall" is a timing wall, not a width wall.** Spacing
collapses 0.84 s → 0.20 s (4.2×) across that boundary while the corridor barely
moves. Any width work aimed at Silk Hollow would have been aimed at the wrong axis.

### C3 · D-0040's open recovery chunks are not what made Bramble passable

The Bramble decision of 2026-08-01 shipped two fixes together and its prose credits the wrong one. Its own
verdict names both: *"a pair owns one readable high↔low commitment instead of
placing two almost-touching walls"* (geometry) and *"every hard chunk is isolated
by an open recovery chunk"* (spacing).

The owner's `0.22.0` recording — the evidence D-0040 was written from — shows a
*single pattern* whose two obstacles nearly meet, with a body-width or two between
them. The disease was the almost-touching walls.

The geometry fix succeeded on its own: **Bramble now has the widest minimum
corridor in the game at 305.5 px / 8.49 diameters**, and its spacing sits at
0.77–0.84 s, clear of every floor in R13. The 50% open-chunk cadence is now
guarding against a failure two other things already prevent — which is why it can
be spent on variety, governed by the measured spacing and corridor floors rather
than by a blanket every-other-chunk rule.

**This is not a reversal of that decision.** Both its fixes were correct and both
shipped. What is corrected is the implied claim that the isolation is load-bearing.

## Two measurements the instrument still does not make

Both are width × duration terms, and **nothing currently watches either**:

1. **Constriction length within a chunk.** An obstacle could be reshaped into a
   400 px tube at an unchanged minimum and every contract would stay green.
2. **Consecutive chunks near the minimum.** The 192 m-versus-96 m difference
   between Silk Hollow and Ancient Forest — the thing that actually separates them
   — is invisible to the suite.

Both were computed ad hoc for this document. They belong in the probe.

## A sampling caveat worth knowing

The audit's default is 40 vertical probes per chunk, i.e. every 24 px. At 2 px
resolution `hollow_lattice_*` measures **240.8 px** against the default sweep's
**244.5 px**. The default therefore **slightly overestimates** the minimum. The
error is small (1.5%) and always in the optimistic direction, which is the wrong
direction for a fairness floor.

## Claim provenance (PL-013)

- **`measured`** — every table above, deterministic, on the pinned engine. A
  repeat run is not independent confirmation.
- **`inferred`** — that the contact-inset change explains the § 2.2
  discrepancy. The mechanism
  fits and the dates align; it has not been proven by rebuilding the old geometry.
- **`assumed`** — that any of these figures is passable for a player other than
  the owner. See the ledger entry's provenance limit.
