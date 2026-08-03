# The pressure curve, computed — and the course proved unchanged

> **Status:** `reference`
>
> Phase 2 of [the doctrine](../game-design/difficulty-and-obstacle-doctrine.md),
> now approved and binding. `CoursePressure` exists, contracts pin its shape, the
> audit instrument reports it per kilometre — and **nothing reads it**. The
> generated course is byte-for-byte the one that shipped before, proven below
> rather than asserted.
>
> **This is the step that makes everything after it comparable.** Every later
> phase moves behaviour; this one fixes the before-picture so those moves can be
> measured against something that cannot quietly drift.

## The curve

```
pressure(d) = smoothstep(progress ^ 0.70),  progress = (d - 500 m) / (15 km - 500 m)
```

| constant | value | provenance |
| --- | ---: | --- |
| `WARM_UP_END_PIXELS` | 500 m | owner requirement 1 — *"the first 500m should remain as it is"* |
| `SCOPE_TOP_PIXELS` | 15 km | owner scope decision, 2026-08-02. **The top of scope, not a plateau** |
| `ONSET_SHAPE` | 0.70 | `assumed` — the one number meant to be judged on device |
| `MAX_RISE_PER_KILOMETRE` | 0.15 | derived ceiling, 13× below the measured cliff |

**Why smoothstep over a front-loaded input.** The smoothstep supplies zero slope
at both ends, so the warm-up ends without a kink and the top is approached
without one. The exponent decides how much of the rise happens early.

**`ONSET_SHAPE` moves *where* pressure sits, not how steep the curve ever gets.**
Measured across 0.70–1.00, the peak one-kilometre rise stays ≈ 0.10 either way;
only the distribution changes. Steepness is bounded separately, so the owner can
move this dial on feel without being able to reintroduce a cliff by accident.

0.70 was chosen because it front-loads the stretch he calls too easy — *"the
start is too easy, the whole time I'm speeding through it with reel just to get
it over with"* — while leaving the curve **decelerating into the clamp**. That
tail is the part that survives O1 being deferred: if the plateau turns out to sit
at 40 km, a decelerating tail stretches, where a curve still climbing hard at its
top would have to be redesigned.

## Why the top is a clamp and not a plateau

O1 — where the plateau belongs — is **deferred, not answered**. The longest
verified run is 10 605 m; five of the eight regions have never been reached in a
recorded run. Any pressure target beyond 15 km would be fitted to nothing.

**Clamping and plateauing produce identical numbers today and mean opposite
things.** One says *this is where our authority ends*; the other says *this is
where the game stops getting harder*. The constant is named `SCOPE_TOP_PIXELS`
so that when the scope extends, the curve extends with it — and so a real
plateau decision cannot hide inside that edit.

## The profile

`measured` — from `CoursePressure` directly, and reproduced by the audit
instrument at the pinned `4.7.1.stable.official.a13da4feb`.

| km | pressure | rise over that km |
| ---: | ---: | ---: |
| 0 | 0.000 | — |
| 1 | 0.025 | +0.025 |
| 2 | 0.108 | +0.083 |
| 3 | 0.206 | +0.098 |
| 4 | 0.309 | +0.103 |
| 5 | 0.412 | +0.103 |
| 6 | 0.511 | +0.099 |
| 7 | 0.605 | +0.094 |
| 8 | 0.691 | +0.086 |
| 9 | 0.769 | +0.078 |
| 10 | 0.837 | +0.068 |
| 11 | 0.894 | +0.057 |
| 12 | 0.939 | +0.046 |
| 13 | 0.973 | +0.033 |
| 14 | 0.993 | +0.020 |
| 15 | **1.000** | +0.007 |

**Steepest kilometre anywhere in scope: 0.1032, spanning 3435–4435 m** — against
a bound of 0.1500, so a retune has roughly 45% headroom before it has to argue
with R3.

For scale, the defect R3 exists to forbid: the authored label ran 1.30 → 3.27
inside 250 m at 1750–2000 m, with hard-pattern share going 0% → 93%. Normalised
onto this curve's scale that is **≈ 1.97 per kilometre** — the bound sits 13×
below it, and the shipped curve 19× below.

## What the curve says about the course that exists today

The audit now prints pressure beside the axes it will eventually schedule. Read
that way, one number states the whole problem.

| region | pressure band it occupies | band width | label delivered | challenge share |
| --- | ---: | ---: | ---: | ---: |
| Ancient Forest | 0.000 → 0.412 | 0.412 | 0.00 → **3.48** | 91–100% |
| Bramble Canopy | 0.412 → 0.837 | **0.425** | **2.00, flat** | 45–55% |
| Silk Hollow | 0.837 → 1.000 | 0.163 | 3.20, flat | 73–82% |

**Bramble Canopy is handed the widest pressure band in the scoped range and
delivers a flat line across all of it.** That is S4 restated as a number: its
pool is region-keyed and distance-invariant, so it has nothing to spend a rising
band on. It is also the direct argument for the ordering the doctrine already
chose — the swap cannot land before the curve, because a swapped opening with no
curve would be flat across the whole first 5 km, contradicting requirement 2.

The mirror image is Ancient Forest: it occupies the **bottom** 0.41 of the curve
and delivers the game's hardest content there, 91–100% challenge density with the
region's tightest corridor.

And the saw-tooth, stated against the curve: across the Ancient Forest → Bramble
boundary **pressure rises 0.309 → 0.412 (+33%) while the authored label falls
3.48 → 2.00 (−41%)**. The curve and the content point in opposite directions at
exactly the place the owner reports the game getting easier.

## The course did not move — proof, not assurance

`CourseAuditProbe.course_digest` hashes what the generator actually builds:
pattern id, lane and label per chunk, plus every boundary, obstacle, contact and
surface polygon at four decimals. Run at two commits on this branch:

| | commit | `course_pressure.gd` in tree | digest, 3 seeds, chunks 0–156 |
| --- | --- | --- | --- |
| before | `49367d1` | absent | `abd839ea…f281d3e7` |
| after | working tree | present | `abd839ea…f281d3e7` |

Identical. The two-seed contract window is pinned in the suite as
`UNCHANGED_COURSE_DIGEST` = `4d7bbdf2…b1d249f076f`, so this cannot regress
silently.

Reproduce either side with:

```bash
godot --headless --path . --script res://tools/course_audit.gd -- \
  --to-metres=15000 --seeds=3 --quiet
```

**When a later phase moves selection onto the curve, that contract is *supposed*
to fail.** Re-pinning it is the visible record that behaviour moved — no
generator change can land looking like a no-op.

## Every contract was falsified with the real failure

Each was broken in the way it exists to catch, and each failed. Recorded because
one of them **passed** its first falsification and had to be rewritten.

| falsification | caught by |
| --- | --- |
| the warm-up is deleted, so pressure starts at 0 m | warm-up contract *(only after it was fixed — see below)* |
| a region lowers the curve for a breather | monotonicity, and the slope bound |
| the upper clamp is dropped, so the curve extrapolates past scope | the clamp contract, and monotonicity |
| the 1750–2000 m cliff is reintroduced onto the curve | the slope bound |
| the slope bound is raised to fit a steeper retune | the bound-derivation contract |
| the generator starts reading the pressure curve | the course digest |

**The one that was worthless first time.** The warm-up contract derived its
sample distances *from* `WARM_UP_END_PIXELS` — the constant it was checking — so
setting that constant to zero shrank every sample to 0 m, where pressure is
legitimately zero, and a deleted warm-up passed. It now restates 500 m as a
literal and asserts the constant against it, the same discipline
`AUTHORED_WEAVE_SPACING_PX` already uses in the audit contracts. *"The first
500 m" is a fact about the game the owner asked for, not a fact about whatever
the constant currently says.*

## What this does not say

1. **It is not difficulty, and it is not calibrated.** `pressure` is a
   normalised scalar with no validated mapping onto felt difficulty. Nothing here
   establishes that 0.412 at 5 km *feels* like anything in particular.
2. **The pressure → axis mapping does not exist yet**, deliberately. The
   decision left the per-axis caps to the phase that gives each axis a consumer; a cap
   with no consumer is exactly the shape of the `difficulty` label F1 calls dead
   metadata.
3. **Requirement 3 is not yet satisfied or contradicted.** *"The 5–10 km band as
   it is today is roughly the right difficulty for the first 5 km"* is an anchor
   on the axis targets, not on the scalar, so it is a Phase 3 measurement.
4. **`ONSET_SHAPE` is `assumed`.** It is a defensible default, not a finding, and
   it is the one number the Test Lab should expose for a device verdict.
5. **No play data is involved.** Same standing caveat as the course-audit
   baseline: these are geometric and structural proxies, and the hazard telemetry
   that would price them does not exist yet.

## Claim provenance (PL-013)

- **`measured`** — the profile table, the steepest kilometre, both digests, and
  every per-region figure in the comparison table; three seeds, deterministic, on
  the pinned engine. A repeat run is not independent confirmation.
- **`inferred`** — that Bramble's flat delivery across the widest band is the
  reason a swap without the curve would contradict requirement 2. The arithmetic
  is exact; the design consequence is reasoning.
- **`assumed`** — `ONSET_SHAPE = 0.70`, and that any of this predicts felt
  difficulty for anyone.
