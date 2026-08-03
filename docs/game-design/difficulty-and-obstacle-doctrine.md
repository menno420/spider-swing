# Difficulty and obstacle placement — measured baseline and the doctrine

> **Status:** `binding` for 0–15 km · [D-0054]
>
> **Approved 2026-08-03 by [D-0054].** Written across 2026-08-02 (PRs #124–#129)
> and refined the following morning (#130–#132, the last of which landed the
> instrument that contradicted two of its rules), it is now the governing plan for
> the first 15 km; generator work may proceed against it. Three questions that
> blocked implementation were settled by that entry and are folded in below —
> **R6** is reworded rather than the generator, the axis **budget** is an axis
> **envelope**, and **R13's T** is a function of local predictability rather than
> a constant. Each was recorded as an agent default open to owner veto.
>
> **Still not decided: where the plateau goes.** O1 remains deferred, so
> `pressure(d)` clamps at the top of the owner-scoped range instead of placing
> one. Sections beyond 15 km are outside this document's authority.
>
> **Scope — the first 15 km only.** Owner decision, 2026-08-02: *"let's focus on
> the first 15K because that's actually something that's proven to be reachable;
> once we have determined that the next sections are truly reachable we can start
> thinking about those more."* Rules stated generally still apply generally, but
> **no target, bound or schedule beyond 15 km is settled here**, and R5's plateau
> is deferred rather than placed. Three regions are in scope: Ancient Forest,
> Bramble Canopy, Silk Hollow.
>
> **Provenance (PL-013):** `measured` = read off source or off a headless
> generator run · `inferred` = arithmetic on measured values · `assumed` =
> design hypothesis awaiting a device verdict.
>
> **External evidence, added 2026-08-02.** An owner-commissioned deep research
> report is written up in
> [`difficulty-research-2026-08-02.md`](difficulty-research-2026-08-02.md). It
> corroborates F8 and the O3 coupling from independent instruments, and proposes
> three changes — marked inline as quoted blocks in §4, R12 and R13. **All of it
> is `inferred` external practice, none of it is measurement**, so where it and a
> measured finding here disagree, **the measurement wins**.
>
> **Measurement method.** Course generation is a pure function of
> `(chunk_index, distance_at_chunk, course_seed)`, so it can be walked exactly.
> Two independent instruments were used on the pinned
> `4.7.1.stable.official.a13da4feb`: one reads each chunk's authored
> `difficulty` label across five seeds; the other builds the real
> `CourseGeometry` and measures, at 24 px steps, the widest free vertical span
> between the ceiling, the floor and every lethal contact polygon. The second
> instrument is **label-free** — it reports what the generator actually built.

---

## 1 · What the owner asked for

Verbatim requirements from the 2026-08-02 device session, after a recorded
10 605 m run:

1. The first **500 m** stays as it is — a warm-up.
2. Then difficulty rises **gradually**, "not too slow and not too fast".
3. The **5–10 km band as it is today is roughly the right difficulty for the
   first 5 km**.
4. After that, keep introducing **higher-skill plays that need more Dives and
   Bursts**.
5. Past roughly **15 km it should stop getting harder** and instead demand
   *different playstyles*, "somewhat equally difficult or slightly more
   difficult in different ways".
6. **Ancient Forest's density is fun and must not be diluted** — "even though
   it's a very hard section it is very fun to play through".
7. The owner is separately considering **swapping the first two regions**, so
   Bramble Canopy opens the game and Ancient Forest follows.
8. Stage transitions read as unclean. **Explicitly parked**, not in scope.

---

## 2 · Measured baseline

### 2.1 Authored difficulty per kilometre

Mean of the `difficulty` label over five seeds (`1, 4242, 90210, 7777, 31337`).

| band | mean | recovery chunks | hard (≥3) | region |
| --- | ---: | ---: | ---: | --- |
| 0–1 km | **0.00** | 0% | 0% | Ancient Forest |
| 1–2 km | 1.46 | 0% | 0% | Ancient Forest |
| 2–3 km | 2.89 | 0% | 71% | Ancient Forest |
| 3–4 km | 3.36 | 0% | 94% | Ancient Forest |
| 4–5 km | 3.44 | 9% | 91% | Ancient Forest |
| 5–10 km | **2.00** | **50%** | 48% | Bramble Canopy |
| 10–15 km | **3.20** | 20% | 80% | Silk Hollow |

At 250 m resolution the sharpest edge in the game is exact: **1750 m sits at
1.30 mean with 0% hard patterns; 2000 m jumps to 3.27 with 93%.** That is
`MASTERY_START_DISTANCE`. The control pool tops out at difficulty 2 and the
mastery pool starts at 3 — the vocabulary has no rung between them.

### 2.2 Real corridor width per kilometre

Widest free vertical span, label-free, seed 4242. Player collision radius is
**18 px** at base upgrades.

| band | tightest gate | median gate | region |
| --- | ---: | ---: | --- |
| 0–9 km | 498 px | **572 px** (full corridor) | Ancient Forest · Bramble |
| 9–10 km | 389 px | 572 px | Bramble Canopy |
| **10–15 km** | **93 px** | **~320 px** | **Silk Hollow** |
| 15–16 km | 294 px | 350 px | Ruined Arboretum |

> ### ⚠ SUPERSEDED 2026-08-03 — this table is not reproducible
>
> Re-measured on **the same seed** with the contracted instrument, Silk Hollow's
> tightest corridor over 10–15 km is **244.5 px**, not 93, and its median is
> **374.1 px**, not ~320. Ancient Forest's median is 442 px and Bramble's 370 px
> against a 572 px full corridor — so the claim that the median chunk does not
> narrow the corridor below 10 km is also wrong.
>
> **Likely cause, and it is not carelessness:** the forgiving-lethal-contact
> decision landed the same day and shrank every lethal contact polygon. This table almost certainly measured the
> geometry as it stood before that inset landed.
>
> **What it changes: crossing into Silk Hollow narrows the tightest corridor by
> 1.25×, not 5.4×, and barely moves the median. The 10 km wall is a TIMING wall**
> — spacing collapses 0.84 s → 0.20 s, 4.2× — **not a width wall.** Numbers and
> method: [`../measurements/2026-08-03-corridor-and-constriction.md`](../measurements/2026-08-03-corridor-and-constriction.md).

The original reading, kept because the error is instructive:

`measured`. For the first ten kilometres the **median** chunk does not narrow
the corridor at all. At 10 km the median halves and the tightest gate tightens
**5.4×**, to about 2.6 body widths, crossed in roughly 0.28 s at the owner's
measured 70 m/s.

### 2.3 The eight regions already declare eight different axes

Straight from `CourseRegionCatalog.REGIONS` — this is authored, not invented
here:

| region | declared focus | declared quirk |
| --- | --- | --- |
| Ancient Forest | Mixed fundamentals | Wide recovery rhythm |
| Bramble Canopy | Height control | Alternating weave cues |
| Silk Hollow | Precision, narrow lines | Silk-marked recovery pockets |
| Ruined Arboretum | Timing, read the phase | Moving gaps and pivots |
| Storm Ridge | External force | Deterministic lateral wind |
| Web City | Route choice | Ridable and sticky strands |
| Ashen Hollow | Trust, weak anchors | Timed rotten anchors |
| Deep Mist | Information, sightline | Short sightline |

**The design the owner is asking for in requirement 5 — equally difficult in
different ways — is already authored as prose.** What is missing is any
discipline about *amount*.

---

## 3 · Eight structural findings

*Two of these were later corroborated from outside this repository — F7 by the
prescription "give every recognisable beat two to four legal continuations", and
F8 by "treat corridor width as a protected error margin, spend extra pressure on
decision density and timing". Both in
[`difficulty-research-2026-08-02.md`](difficulty-research-2026-08-02.md)
§ 1.1 and § 2.6. Neither finding depends on that agreement — they are `measured`
and it is not.*

### F1 · The `difficulty` label is dead metadata — ⚠ RESOLVED 2026-08-03

> **It has a consumer now.** [D-0057] makes the label the admission key for
> R13's bounded spread: `CourseAxisEnvelope.admission_floor(pressure)` decides
> which authored rungs a chunk may draw, so a label that drifts changes what the
> generator builds and the course digest moves. R10 asked for exactly this —
> *"`difficulty` becomes derived from measured geometry, or it is deleted"* — and
> the middle path it did not name turned out to be available: the label stays
> authored, but it is now load-bearing and therefore falsifiable.
>
> The first thing that fell out was a correction it had been hiding. Bramble's
> four singles were labelled 4, identical to its four pairs, which is F5's
> "binary" finding stated as data; they are 3 now, because §6.1's third lever
> already said the pair is the commitment and the single is not.

`difficulty` appears in `course_pattern_catalog.gd` and **nowhere else in the
codebase**. Nothing reads it. §2.1 measures what the authors *intended*, which
happens to track the owner's felt experience closely — a good sign the labels
are honest — but nothing enforces that a difficulty-4 pattern is harder than a
difficulty-1 one. `measured`.

### F2 · The distance ladder is scoped to one region

`_patterns_for_distance` returns a region-specific pool for **seven of eight
regions**. Only Ancient Forest falls through to the distance-tiered pools
(opening → control at 1 km → mastery at 2 km → deep forest at 3.5 km).
`_obstacle_growth_scale` likewise caps at 3.5 km. `measured`.

> **The game's entire distance-driven progression belongs to Ancient Forest,
> and Ancient Forest happens to sit at 0–5 km.** Everywhere else, distance is
> irrelevant and only region identity matters.

This is the root cause of the saw-tooth. Nobody chose 3.4 → 2.0 → 3.2; it fell
out of eight regions authored independently for character.

### F3 · Ancient Forest is the only region with no recovery cadence — and its own catalogue says it should have the widest

```gdscript
if region_id != CourseRegionCatalog.ANCIENT_FOREST and \
        posmod(local_chunk, recovery_interval) == recovery_interval - 1:
    return RECOVERY_PATTERN
```

Every region except Ancient Forest gets an open chunk every fifth. Ancient
Forest gets **none** — while its catalogue entry declares its quirk to be
*"Wide recovery rhythm"*. `measured`.

> This is a documented-versus-actual contradiction sitting exactly where the
> owner reports most of his deaths, and it is the cheapest lead in this
> document.
>
> **⚠ FIXED 2026-08-03 by [D-0057].** The per-region cadence constants are gone;
> one pressure-driven interval governs every region, Ancient Forest included.
> Measured recovery share is now **23.1%** against the 2% above — close to the
> 20% its own catalogue entry has always claimed, and to the value O2 calls the
> natural first try.

### F4 · Difficulty has two axes today and they are uncoordinated

Density (Ancient Forest, 2.5–5 km) and corridor width (Silk Hollow, 10 km+).
Silk Hollow stacks a narrow corridor *on top of* a high hard-pattern share, and
it is the only region that uses the width axis at all. `inferred` from §2.1 +
§2.2.

> **⚠ CORRECTED 2026-08-03. The original sentence continued "that is why 10 km
> reads as a wall rather than a step", and the measurement does not support it.**
> Silk Hollow's corridor is only 8% tighter than Ancient Forest's at minimum, and
> its median is *wider* than Bramble's. What collapses at 10 km is **spacing —
> 0.84 s → 0.20 s, 4.2×**. The wall is timing.
>
> The finding survives in a better form: the two axes are still uncoordinated,
> and Silk Hollow still spends width and timing at once — which is exactly the
> combination [D-0054]'s envelope forbids. But the width contribution is small,
> and a fix aimed at it would have missed.

### F5 · Three pools have no internal difficulty gradient at all

Distinct `difficulty` values present in each pool:

| pool | values | gradient? |
| --- | --- | --- |
| Ancient Forest · control | 1, 2 | yes |
| Ancient Forest · mastery | 2, 3 | yes |
| Ancient Forest · deep | 3, 4 | yes |
| **Bramble Canopy** (single + pair) | **4** | **none** |
| **Silk Hollow** | **4** | **none** |
| Ruined Arboretum | 4, 5 | yes |
| Storm Ridge · Web City | 4, 5, 6 | yes |
| Ashen Hollow | 5, 6 | yes |
| **Deep Mist** | **6** | **none** |

`measured`. This restates F2 from the other side. Ancient Forest is the only
early region that can ramp **because it is the only early region whose pools
contain more than one difficulty**.

> **Bramble Canopy is binary: 50% empty chunks and 50% difficulty-4 chunks.**
> Its measured mean of 2.0 in §2.1 is the average of two extremes, not a
> moderate setting. It reads as gentle because of the spacing, not because the
> obstacles are small — its smallest is a 300 px hook in a 572 px corridor,
> **52% of the corridor height**.

The practical consequence is in §6.1.

### F6 · No pattern is ever reused between sections

| section | pool | new to the run | reused |
| --- | ---: | ---: | ---: |
| Ancient Forest | 20 | 20 | 0 |
| Bramble Canopy | 8 | 8 | 0 |
| Silk Hollow | 9 | 9 | 0 |
| Ruined Arboretum | 18 | 18 | 0 |
| Storm Ridge · Web City · Ashen Hollow | 11 each | 11 each | 0 |
| Deep Mist | 9 | 9 | 0 |

**97 distinct patterns, and every one belongs to exactly one section.**
`measured`.

This decides the shape of R12. "Vocabulary the player has already met is free to
reuse" sounds like a useful economy and currently saves **nothing** — every
section is 100% new. So a rule that demonstrates each new *pattern* once, spaced
to be legible, would spend 20 demonstrations on Ancient Forest: at two chunks
each that is **40 of its 52 chunks**, an entire section spent teaching.

Per-pattern introduction is therefore too expensive at the top end, and the unit
of introduction has to be coarser. See R12.

### F7 · Route predictability varies enormously, and it inversely tracks where the owner dies

Every pattern already declares a **`lane`** — `high`, `low`, `centre`, `weave`,
`tight` — and the generator builds the corridor around it
(`_boundary_edge_y_at(..., route_lane, ...)`). **The lane is the route.** Each
section uses only three or four of them.

Walking the real lane sequence, five seeds, `o` = open recovery:

| section | seeds that differ | same-lane repeats | first 24 chunks, seed 4242 |
| --- | ---: | ---: | --- |
| **Bramble Canopy** | **2 of 5** | **0%** | `lowolowolowolowolowolowo` |
| Silk Hollow | 3 of 5 | 14% | `hhcocllhohcclollhcohclco` |
| Ancient Forest 2–5 km | **5 of 5** | 27% | `lhthwhchcltlwlclwcthllll` |

`measured`.

> **Bramble Canopy is a memorisable four-beat loop** — low, open, weave, open —
> and it is nearly seed-independent. Ancient Forest's 2–5 km stretch is fully
> seeded across five lanes with no cadence at all.

**The ranking is the exact inverse of where the owner dies.** He finds Bramble
easy, dies most in Ancient Forest 2.5–5 km, and hits a wall at Silk Hollow.
Predictability, obstacle density and corridor width all point the same way here,
but they are **independent levers** and only two of them were previously named.

This is the mechanism behind the owner's own account of his 10 605 m run:

> *"once a player knows that they have to take a certain route for the first few
> obstacles they see, they will naturally focus more on predicting how to take
> that kind of route again the next time, and that has helped me a lot"*

Predictability converts **reading into execution**, and execution is far faster
— which is how a sustained 70 m/s is reachable at all. It also explains
Bramble's felt gentleness better than its 50% recovery cadence does: the player
is not solving 26 puzzles, he is running one loop 13 times.

The corollary is a warning. Bramble's loop runs unchanged for all 52 of its
chunks, so **predictability has an optimum, not a maximum** — past some point
the same loop stops being reassuring and becomes repetitive.

### F8 · Density with room is fun; narrowness is a wall

The owner's two verdicts, side by side with what each section measures:

| | Ancient Forest 2.5–5 km | Silk Hollow 10–15 km |
| --- | --- | --- |
| encounter density | **highest in the game** (100% hard, 0% recovery) | high (80% hard, 20% recovery) |
| corridor (as originally measured) | **full 572 px, tightest 498** | **median ~320 px, tightest 93** |
| corridor (re-measured 2026-08-03) | median 442 px, tightest 266 | median **374 px**, tightest **244** |
| owner's verdict | *"very hard … but very fun to play through"* | *"at least 2× more difficult with no gradual increase"* |

His stated reason for the first is explicitly about room:

> *"the fact that there is always still enough room to move through it with some
> error margin makes it the right kind of difficult"*

**The denser section is the one he enjoys, and the difference is that it never
takes the room away.** `inferred` from `measured` §2.1 + §2.2 plus the owner's
2026-08-02 verdicts.

This is a direct steer on how the axes of §4 should be spent: **density is a
cheap and well-liked way to add difficulty; width is expensive and should be
used sparingly.** Narrowing removes the error margin that makes a mistake
survivable, and a mistake you cannot survive reads as unfair rather than hard.
Silk Hollow currently spends both at once.

---

## 4 · The proposed model

**Separate *how much* from *what kind*.**

### Pressure — how much

One monotone curve, `pressure(d) ∈ [0, 1]`:

- `0` below 500 m
- rises to `1.0` at the top of the scoped range
- constant above it

Every difficulty term derives from pressure. No region, pool or pattern reads
distance directly.

**Implemented 2026-08-03 as `CoursePressure` (`game/domain/course_pressure.gd`),
with no consumer yet.** The top of the curve is **15 km because that is where
the owner's scope ends, not because a plateau was placed there** — O1 is
deferred, and a curve that clamps is honest about having no authority past its
evidence, where one that kept rising would be extrapolating onto ground nobody
has stood on. When the scope extends, the curve extends with it; the constant is
named for what it is. Numbers:
[`../measurements/2026-08-03-pressure-curve-profile.md`](../measurements/2026-08-03-pressure-curve-profile.md).

### Axes — what kind

Pressure is *spent* across named axes. Each is separately measurable:

| axis | metric | who uses it today |
| --- | --- | --- |
| **Density** | share of chunks carrying a challenge | Ancient Forest |
| **Width** | tightest free span ÷ player radius | Silk Hollow |
| **Displacement** | required vertical travel between commitments | Bramble Canopy |
| **Phase** | share of hazards that move on a timer | Ruined Arboretum |
| **Force** | external acceleration applied off-silk | Storm Ridge |
| **Anchor quality** | share of anchors that are sticky, rotten or once-only | Web City · Ashen Hollow |
| **Information** | preview distance before a hazard is legible | Deep Mist |
| **Verb** | share of chunks whose best line needs a Dive or Burst | — |
| **Predictability** | how well the next route can be inferred from the current one | Bramble (very high) → Ancient Forest (none) |

A region declares an **axis envelope** — which profiles it may legally present
at the pressure it is given. At the plateau every region carries the *same
envelope* and fills it with a *different profile*. That is requirement 5,
expressed as a constraint rather than a hope.

> ### Budget became *envelope* — ruled by [D-0054], 2026-08-03
>
> **This section originally said "axis budget", and that every region spends the
> *same total* on different axes.** That framing is retired. The correction came
> from [`difficulty-research-2026-08-02.md`](difficulty-research-2026-08-02.md)
> § 2.2 and was the most substantive external challenge to the model.
> **Pressure is very unlikely to be additive:**
>
> `pressure ≠ density + narrowness + timing + unpredictability`
>
> A point of narrowing is not equivalent to a point of density. Narrowing is mild
> at low speed on a known pattern and severe when it coincides with a new required
> verb, a vertical reversal and short telegraphing. Multidimensional level metrics
> are well-established prior art; **a validated conserved difficulty budget is
> not** — the report searched and found none.
>
> **What replaced it.** The monotone scalar stays, but as an **admission
> envelope**: it decides which *profiles* are legal at a distance. Each axis then
> carries its **own cap, slope limit and cooldown**, and a small set of
> **explicitly forbidden combinations** — maximum narrowness must not coincide
> with maximum novelty and minimum reaction time. The scalar stays an
> orchestration instrument without pretending the axes are interchangeable
> currency.
>
> This costs nothing we are not already building: every chunk still gets a vector,
> every region a target profile, every kilometre an allowed range. It changes what
> the comparison looks at — **maxima, consecutive exposure, and interaction terms
> like `density × narrowness` and `novelty × required_verbs`**, not means alone.
>
> Nothing else in this section changes; requirement 5 is still expressible, as
> "equal envelopes, different profiles" rather than "equal totals".
>
> **Where the per-axis numbers come from, and when.** [D-0054] deliberately did
> **not** fix the caps, slope limits or cooldowns. A cap with no consumer is
> exactly the shape of the `difficulty` label F1 calls dead metadata —
> unfalsifiable and free to drift — so each axis gets its numbers in the phase
> that gives it a consumer, region by region. The scalar and its own slope limit
> are the only parts that exist before then, because they are the only parts the
> whole game shares.

It also answers requirement 4 directly: "more Dives and Bursts" is the **Verb**
axis rising with pressure, and it is the one axis currently at zero everywhere.

---

## 5 · The rules

Numbered so they can be argued with individually. Each is written to be
machine-checkable or explicitly marked device-only.

**R1 · One curve.** `pressure(d)` is the single source of difficulty amount.
Nothing else may read `distance_at_chunk` to decide how hard a chunk is.

**R2 · Monotone envelope — of ceilings, not of the instantaneous signal.**
Section ceilings never decrease: `ceiling(n) ≥ ceiling(n-1)`. The instantaneous
difficulty *may* dip, but only at a section entry and only within the bounds of
R12. This distinction is load-bearing: the naive reading — that difficulty never
decreases anywhere — forbids both the section-entry ramp the owner asked for and
the recovery chunks he asked for. **Monotonicity is a property of the envelope,
not of the signal.**

**R3 · Bounded slope.** No kilometre may raise pressure by more than a set
maximum. This is the rule that kills the 1750 → 2000 m cliff.

**R4 · Regions choose character, never amount.** A region declares an axis
budget. It may modulate total pressure by at most **±15%** — enough for the
owner's "slightly more difficult in different ways", not enough to halve the
game. The ceiling on that bound is derived in S7: the saw-tooth this doctrine
exists to prevent is a 41% drop, so any bound at or above ~20% re-permits it.

**R5 · The plateau is real.** Above the plateau distance, pressure is exactly
constant. Variation comes from rotating axis budgets, bounded so no rotation is
more than ~10% harder than another on the measured terms.

**R6 · Warm-up is sacred.** 0–500 m carries **no multi-obstacle pattern and no
opposite-side pair**. Loose single obstacles alternating top and bottom are the
warm-up, not a violation of it. A contract, so it cannot erode.

> **Reworded by [D-0054], 2026-08-03. The previous wording was "no lethal
> obstacle", and it described a game that has never shipped.** Measured
> 2026-08-02: chunks 1 and 4 (96 m and 384 m) each carry one obstacle contact
> polygon, identically across every seed — the opening is authored, not seeded.
> That is exactly what R12's first-gate row describes (*"loose single obstacles
> alternating top and bottom with short open gaps"*), so the old R6 was stricter
> than both the shipped generator and this document's own other rule. The
> owner's requirement was *"the first 500m should remain as it is"*, which
> settles which of the two had to move: **the rule, not the content.** See **N5**
> in [`../measurements/2026-08-02-course-audit-baseline.md`](../measurements/2026-08-02-course-audit-baseline.md).
>
> What the new wording still forbids is real: the warm-up may not acquire a
> second simultaneous hazard, and it may not acquire the sequential opposite
> commitment whose *first* appearance the audit locates at km 2 — which is the
> mechanism behind the owner's "at about 2500m the difficulty suddenly
> increases".

**R7 · Recovery cadence is a curve, not a per-region constant.** Maximum
consecutive challenge chunks rises with pressure. Every region obeys it,
including Ancient Forest.

**R8 · The fairness floor is independent of pressure.** Every generated chunk,
at every distance, must satisfy:

- tightest gate ≥ K × player collision radius at **base** upgrades, where
  **K = 6 radii = 3.0 player diameters = 108 px** — owner-stated 2026-08-03 as
  the absolute limit of possible passing, and therefore a backstop nothing should
  approach rather than a target. The *governing* width rule is the distribution
  in [D-0056], not this floor;
- preview time ≥ T seconds, computed as free horizontal distance before the
  next constriction ÷ the **speed cap at that distance** (D-0050's curve);
- a passable line exists using only verbs the player has been taught by then.

This is what lets difficulty rise without becoming unfair, and all three terms
are computable headlessly.

**R9 · The curve is a schedule, not a filter.** Content that works is
*relocated*, never deleted, to satisfy the curve. Written in response to
requirement 6 — Ancient Forest's density is an asset to place correctly, not a
problem to dilute.

**R10 · No label without a consumer.** `difficulty` becomes derived from
measured geometry, or it is deleted. A number nothing reads is a lie waiting to
happen (F1).

**R12 · Every section shows its new patterns once, gently, before it uses them
for real.** Owner-specified 2026-08-02, revised the same day. This is a
**promise to the player**, not a difficulty concession — once players learn the
promise holds, the introduction reads as legibility rather than charity. The
owner's phrasing: *"players will know that each section will show them the
patterns once in a more forgiving way, and the next one will be the real deal."*

Two ramps stack, and they are driven by different things.

**The gate — driven by distance.** A stretch of no lethal obstacle at each
section entry, whose job is the visual and audio transition, not teaching:

| section | gate | why |
| --- | --- | --- |
| 1st | ~500 m | also the game's onboarding; loose single obstacles alternating top and bottom with short open gaps between, *before* any multi-obstacle pattern |
| 2nd | ~100 m or less | patterns may start immediately, merely spread wider for the first few |
| ≥ 15 km | shorter still | "keep the pace high" — bounded below by the spacing floor, never by zero |

**The introduction — driven by novelty, not by distance.** Each *family* of
patterns new to the run gets one forgiving showing — open chunks either side,
reduced obstacle scale — before that family joins the section's normal pool.
Ramp length therefore **emerges** from how much is genuinely new rather than
being a number per section.

Why family and not pattern: F6 measures 97 patterns with **zero reuse between
sections**, so a per-pattern schedule would spend 20 demonstrations on Ancient
Forest — 40 of its 52 chunks. Grouping into roughly five families per section
gives ~5 demonstrations at ~3 chunks each ≈ 15 chunks ≈ **1440 m**, which
recovers the owner's own "over the first 1 km … full vocabulary around 1500 m"
almost exactly. That convergence is the argument for the family unit.

**This needs one thing that does not exist:** patterns carry no `family` tag.
Adding one to 97 entries is cheap, mechanical, and is the prerequisite for R12.

**Novelty, not ordinal, must set the length.** A rule that shrinks the ramp
purely with section index would give the *most alien* mechanics the *shortest*
teaching — Deep Mist at 35 km changes what the player can see, and Ashen Hollow
makes anchors fail. Those deserve a full introduction however deep they sit. The
gate shrinks with distance; the introduction does not.

> **Two amendments proposed by
> [`difficulty-research-2026-08-02.md`](difficulty-research-2026-08-02.md)
> § 2.3–2.5**, both `inferred` from external practice:
>
> 1. **Make the ramp an axis-local reset, not a global drop.** Valve's shipped
>    rule for deliberate oscillation is *"amplitude (difficulty) is not changed,
>    frequency (pacing) is"* — local waves should not lower the underlying floor.
>    That is in tension with a 100–150 m gate only if the gate drops *everything*.
>    Both hold together if the entry lowers **novelty and width pressure for the
>    mechanic being introduced** while the monotone base pressure keeps rising
>    underneath. This is the sharpest single change the report suggests.
> 2. **A safe introduction that still kills teaches distrust, not the mechanic.**
>    The first encounter must use the same perceptual language, the same collision
>    rules and the same required movement as later variants, with exactly **one**
>    generous margin — and it must survive **bird pressure**, which is an
>    independent source that does not know a teaching chunk is in progress.
>
> A third caution, against over-applying R12: the largest relevant tutorial study
> (> 45 000 players) found tutorial value depends heavily on game complexity, with
> **no significant gain** in the simpler games. Spend the teach treatment where a
> mechanic needs new interpretation or new input — not on every new silhouette.

**R13 · Bounded spread, and a spacing floor that does not bend.** Within the
ramp and at plateau, the drawable pool is centred on the current level with a
bounded spread — a chunk may be easier than the current level, never much
harder. The constraint is on the *distribution*, not the chunk-to-chunk
sequence, because scheduled recovery chunks are deliberate dips and a sequence
rule would forbid them. Owner's phrasing: *"not so random that it suddenly goes
from 0 to 100 difficulty"*.

Separately and unconditionally: **consecutive opposite-lane commitments are
separated by at least T seconds at the speed cap for that distance** — where T
is a *function of local predictability*, not a constant. A route the player can
predict needs less time than one they must read; O3 derives the coupling, and
it makes R13 and R14 two views of one knob. The
owner's constraint — *"not so small that someone sees an obstacle at the top and
then immediately has one at the bottom before having the time to figure out what
happened"* — is the same quantity as R8's preview time, and it binds at every
pressure including the plateau. For scale: one chunk is 1.37 s at 70 m/s, and
the weave patterns place their two commitments 420 px apart, which is **0.60 s**
at that speed.

> **T's shape is ruled by [D-0054]; its constants are still device-only.**
> T is a **function of local predictability**, not a constant, and it ships with
> these three values as `assumed` defaults pending the owner's verdict on his own
> device and hands:
>
> | situation | floor |
> | --- | --- |
> | pre-learned **and** well-telegraphed expert beat — i.e. where R14 has already made that beat predictable | **0.60 s** |
> | unlearned opposite-side choice | **0.8–1.0 s** |
> | unlearned, **and** significant swing correction needed | **1.2–1.4 s** |
>
> The bounds come from
> [`difficulty-research-2026-08-02.md`](difficulty-research-2026-08-02.md) § 2.1,
> `inferred` and **not** measurement. Published choice-reaction time is ≈ 369 ms
> for a four-way choice against ≈ 253 ms for a simple one, a second choice costs
> ~+50% and three choices roughly double it. Subtracting ≈ 0.37 s from a 0.60 s
> window leaves ≈ 0.23 s for screen and touch latency, pattern interpretation,
> pendulum dynamics and actual displacement. Our 1.37 s chunk is explicitly
> called *substantial room*. The 0.8–1.0 s figure is the report's own
> conservative extrapolation, not a published mobile standard, so it **bounds** T
> rather than setting it.
>
> **⚠ The tightest content is not the weave, and `lane` is not a proxy for T.**
> This rule was originally framed around `high_low_weave` at 420 px / 0.60 s.
> Measured 2026-08-02, tightest first: `hollow_spindle_gate` **180 px (0.20 s at
> the cap)**, `staggered_s` 233 px, `stump_and_vine` 252 px — **all
> `lane = centre`**, and **every `weave`-lane pattern is looser than all three**.
> The real floor is 2.3× tighter than the figure the question was built on, so a
> T chosen against 0.60 s would leave the three tightest patterns beneath it
> untouched.
>
> **⚠ Read that as a SPACING claim only — 2026-08-03.** Those figures are
> centre-to-centre distances between obstacles, i.e. timing. They say nothing
> about corridor width, and `hollow_spindle_gate` — named there as the tightest
> content in the game — has a **7.85-diameter corridor with an 8 ms
> constriction**, making it the most generous tight pattern measured. Width is
> governed by [D-0056], not by these numbers.
>
> **And the owner plays at 0.29–0.31 s.** Ancient Forest 2–5 km runs sequential
> opposite pairs at that spacing and he clears it. The report's conservative
> 0.8–1.0 s floor for an *unlearned* choice is roughly **3× looser than measured
> expert reality**. Both can hold — that is the predictability coupling — but the
> constants must be re-derived from the run, not from the extrapolation. The
> measurement wins. Whatever schedules T must read measured geometry; **the lane label
> does not predict timing pressure and may not stand in for it.** See **N1** and
> **N3** in
> [`../measurements/2026-08-02-course-audit-baseline.md`](../measurements/2026-08-02-course-audit-baseline.md).

**R14 · Predictability is scheduled, not accidental.** F7 shows it currently
ranges from a near-deterministic four-beat loop to a fully seeded five-lane
draw, and nothing chose that spread. It becomes a first-class axis:

- **Maximum during introduction.** A demonstration is only a demonstration if
  the player can see the pattern *as* a pattern. The introduction phase runs a
  legible cadence, not a random draw — which is what makes the owner's promise
  ("shown once forgiving, then real") learnable rather than merely survivable.
- **Reduced as pressure rises**, within the section and across the run.
- **Floored.** Fully random is not difficulty, it is noise; below some floor the
  player is reacting rather than predicting and R13's spacing rule is doing all
  the work.

This gives the plateau (R5) something to spend that costs no new content:
**a late section can drop predictability instead of raising density.** Same
obstacle count, less pattern — genuinely harder, in a different way, which is
exactly requirement 5. It is the cheapest lever in the doctrine and the only one
that adds difficulty without adding either hazards or narrowing.

**R11 · Declared identity must match generated behaviour.** A region's `focus`
and `quirk` are assertions about its output, and a contract checks them. F3 is
what happens without this rule.

---

## 6 · The region swap, and what it needs alongside

### 6.1 · Bramble has no rungs to climb — and three ways to build them

R12 asks Bramble to ramp from near-empty to its current state over 1.5 km.
**F5 says it cannot: all eight of its patterns are difficulty 4, and its
smallest obstacle covers 52% of the corridor.** There is nothing between empty
and full-on to put in the middle of the ramp.

Three levers manufacture the missing rungs from the eight patterns that already
exist, with **no new content**:

1. **Cadence** — obstacle spacing ramps 1-in-4 → 1-in-3 → 1-in-2 (its current
   value). Free; the cadence rule already exists per region.
2. **Size** — the owner's own instinct — *"possibly with a very small reduction
   on obstacle size"* — is the ramp if it is a *curve* rather than a constant. A
   300 px hook at 0.45 scale is 135 px, 24% of the corridor: plausibly "an
   occasional obstacle at the top". Plumbing exists
   (`_floating_obstacle_scale`, `_obstacle_growth_scale`), though today's whole
   range is 0.76–1.06 across difficulty modes, so 0.45 is a larger stretch than
   the art has been asked for.
3. **Singles before pairs** — the pool is already split 4 singles / 4 pairs, and
   the pairs are the commitment. Introducing pairs at ~1 km is free and uses the
   existing structure.

Together these give a genuine three-lever ramp. **Only lever 2 risks looking
wrong**, because the art is authored at a size; levers 1 and 3 are pure
scheduling.

The same gap applies to Silk Hollow (all 4) and Deep Mist (all 6). Every other
region has at least two rungs of its own.



The owner's idea — Bramble Canopy first, Ancient Forest second — is **better
than the retune this document originally proposed**, because it achieves
requirement 3 without touching requirement 6. Bramble already *is* the
difficulty wanted for the first 5 km.

Measured consequence on the label curve:

| | 0–5 km | 5–10 km | 10–15 km |
| --- | ---: | ---: | ---: |
| today | 0.0 → 3.4 | 2.0 | 3.2 |
| swapped | **2.0** | **3.4** | 3.2 |

Up, up, then flat-with-a-width-spike — instead of up, down, up. **The swap
alone removes most of the saw-tooth at near-zero content cost.**

Three consequences it must be paired with, all from F2:

1. **The swap moves the only ramp the game has from the first 5 km to the
   second.** Bramble's pool is region-keyed and distance-invariant, so a
   swapped opening would be *flat* across its whole 5 km — which contradicts
   requirement 2. The pressure curve (R1) is what puts the ramp back, and it
   must land before or with the swap.
2. **Ancient Forest at 5–10 km would draw only the deep-forest pool** (≥3.5 km
   in the current law), making it harder than today's 2.5–5 km, which mixes
   mastery and deep. Under R1 this stops being automatic and becomes a choice.
3. **Region checkpoint ids are persisted** in `unlocked_region_checkpoints`.
   Swapping start distances changes which distance a saved checkpoint unlocks,
   so it needs a save migration, and Region Practice entries change meaning.

---

## 7 · How reliable is this? An honest split

**Near-certain — the shape.** Generation is a pure function of distance. The
curve can be made any shape and pinned by contracts that fail on regression.
Both instruments used for §2 were written in minutes.

**Near-certain — fairness.** Every term in R8 is computable headlessly, as is
R2, R3, R6 and R7. These become CI, not judgement.

**Low — the feel.** The bot pumps and Dives now, and it still fails most of its
acceptance targets — it collapses in the warp band and gets the upgrade sign
wrong — so `docs/technical/simulation-lab.md` still forbids using it to evaluate
difficulty. Whether 2 km is the right place for the second rung is
device-only, permanently.

**The consequence for the plan:** put every knob on one curve, exposed in the
Test Lab, so device time is spent judging **one slope** rather than
re-authoring content chunk by chunk. If the plan ever requires the owner to
evaluate individual patterns on device, it has failed.

---

## 8 · Staged plan

**Phase 0 — instrumentation only. ✅ LANDED 2026-08-02.**
`tools/course_audit.gd` walks the generator and reports the axis vector per
chunk; `tools/course_audit_probe.gd` holds the measurement, so the CLI and the
contracts can never measure differently. The contracts in
`tests/unit/course_audit_tests.gd` pin the *instrument* — not the difficulty —
and each was falsified before being trusted. **No gameplay value changed.**
First output and its six new findings:
[`../measurements/2026-08-02-course-audit-baseline.md`](../measurements/2026-08-02-course-audit-baseline.md).

> **It confirmed all four of the owner's felt boundaries from geometry alone**,
> and it moved two things in this document: **N1** (the tightest content is not
> the weave — the real floor is 180 px, not 420) and **N5** (the warm-up already
> carries obstacles, so R6 contradicts R12). Both are folded in below.

**Phase 1 — doctrine. ✅ LANDED 2026-08-03.** These rules, argued and cut down,
became [D-0054], which approved the doctrine for 0–15 km and settled the three
questions that blocked implementation (R6's wording, budget → envelope, T's
shape). The plateau's position was **not** settled and stays deferred.

**Phase 2 — compute the curve without using it. ✅ LANDED 2026-08-03.**
`CoursePressure` exists in `game/domain/`, contracts pin its shape, the audit
instrument reports the profile per kilometre, and **nothing consumes it** — the
generated course is unchanged, proven by a pinned digest over patterns and
polygons across the scoped range. Proves the numbers before they are
load-bearing. Profile and the before-picture:
[`../measurements/2026-08-03-pressure-curve-profile.md`](../measurements/2026-08-03-pressure-curve-profile.md).

**Phase 3 — switch selection onto the curve. ✅ LANDED 2026-08-03**, as
[D-0057], and **not** one region at a time in the end: the axis terms are
region-independent by construction, so staging them per region would have meant
three partial implementations of one rule. `CourseAxisEnvelope`
(`game/domain/`) maps pressure to the recovery cadence, obstacle size, the
admissible authored rungs, and multi-obstacle admission. Three distance laws
were deleted with it, and the `difficulty` label finally has a consumer (R10).
**The digest contract failed and was re-pinned, which is the visible record that
behaviour moved.**

The slope is **not** exposed in the Test Lab, and that reverses this line
deliberately: pattern selection has to stay a pure function of
`(chunk, distance, seed)` or no input trace reproduces. `ONSET_SHAPE` therefore
stays a source constant and the **obstacle size floor** is the dial instead —
it is a geometry scale, which the lab already tunes, and §8's own "one open
risk" says it is the number that can look wrong rather than play wrong.

**Phase 4 — the swap and the retune. ✅ LANDED 2026-08-03**, in the same change
as Phase 3, because S4 already derived that they cannot land apart. Bramble
opens the game, and the owner chose its opening ramp on 2026-08-03:

| stretch | what carries it |
| --- | --- |
| 0 – 500 m | the warm-up, untouched — **it moves with the front slot, not with Ancient Forest** |
| 500 m – ~1500 m | **obstacle size** ramping up to full — *"decrease the obstacle size of it for the first 1000m or something like that"* |
| ~1500 m – 5 km | **loose obstacles filling a rising share of the open chunks** — *"add some loose obstacles in between certain wide spaces instead of just repeating the same pattern"* |

Two levers, no new patterns authored, and a continuous rise instead of a flat
3.5 km. The fill is governed by the **measured spacing and corridor floors**, not
by a blanket every-other-chunk rule — which is available precisely because
Bramble's open chunks turned out not to be what made it passable (see C3 in
[`../measurements/2026-08-03-corridor-and-constriction.md`](../measurements/2026-08-03-corridor-and-constriction.md)).
The ~1500 m endpoint is not arbitrary: R12's family-introduction arithmetic
independently landed on ~1440 m for Bramble's vocabulary to be fully shown.

**The one open risk is art, and only the owner can judge it.** Today's entire
obstacle-scale range across all difficulty modes is 0.76–1.06; a meaningful
opening ramp wants to go well below that, and how small an obstacle can be drawn
before it looks wrong is a device call, not a measurable one.

> **Shipped as 0.60 — a multiplier on the mode's own scale, not an absolute.**
> At Standard that is 0.54 effective: a 300 px Bramble hook drawn at 162 px, 28%
> of the corridor, against 270 px and 47% at full size. A multiplier keeps each
> mode's own size intent instead of overriding it. It is `assumed`, it is the
> Test Lab dial `opening_obstacle_scale_floor`, and it is the single thing in
> this phase most likely to come back changed from a device session.
>
> **Two things got worse and are recorded rather than argued away.** Ancient
> Forest's tightest sequential pair reads **0.288 s → 0.261 s** on unchanged
> geometry, because spacing is measured at the speed cap and 5–10 km is a faster
> band than 2–5 km; the owner clears 0.29–0.31 s on this content today and now
> meets it a full 3 km later. And the swap puts the **thinnest pool in the game**
> — Bramble's eight patterns, F6 — in the front slot, though F7's memorisable
> four-beat loop goes with it. Numbers:
> [`../measurements/2026-08-03-curve-driven-course.md`](../measurements/2026-08-03-curve-driven-course.md).

**Phase 5 — per-region endless (§9)**, deepest pool first, as a non-records
mode. Deliberately last: it is nearly free once Phase 2 lands and impossible
before it, and it is the instrument that validates the plateau claim in R5.

---

## 9 · Per-region endless modes

An owner idea from the same session: **make each region playable as an endless
version of itself** — endless Forest, endless Brambles — so a region can scale
past the 5 km slot it gets in the main run.

### Why it fits the doctrine unusually well

It separates the two things that are fused today. In the main run a region gets
one 5 km slot and therefore exactly **one** pressure level. In a region-endless
mode it gets the whole curve, expressed entirely on its own axes.

Three consequences worth having:

1. **It is the missing calibration instrument.** Every target in §2 comes from
   the owner's play of one mixed course, and each region is only ever observed
   at its single slot pressure. Region-endless yields a *per-axis* skill curve
   — "I reach 20 km on height control and 8 km on precision" — which is
   evidence no mixed run can produce, and which directly settles questions 1
   and 4 below.
2. **It validates R5's plateau before the main run depends on it.** The claim
   that eight axis budgets can be made roughly equal in difficulty is testable
   in isolation, one region at a time.
3. **It is a content multiplier with no new content** — eight ways to play the
   patterns that already ship.

### Why it must come after the curve, not before

A region today has exactly one difficulty setting: its authored pool plus its
cadence, invariant across its span. There is nothing to scale. **Region-endless
is impossible to do well before `pressure(d)` exists and nearly free
afterwards** — once a region takes pressure as an input, running it from 0 to
plateau is the same code path as running it in its slot.

It also needs one capability the game does not have: **holding a region while
distance keeps rising.** Region Practice starts you at a checkpoint but the
course continues normally and crosses into the next region ~5 km later. Under
R1 that decoupling is natural, because region and pressure stop being the same
variable.

### The binding constraint is pool depth, and it is very uneven

Distinct patterns per pool, with how often a pattern must repeat to fill a
5 km slot (≈52 chunks):

| pool | patterns | repeats per 5 km | per 20 km |
| --- | ---: | ---: | ---: |
| **Bramble Canopy** (single + pair) | **8** | **13×** | **52×** |
| Silk Hollow | 9 | 5.8× | 23× |
| Deep Mist | 9 | 5.8× | 23× |
| Ruined Arboretum · Storm Ridge · Web City · Ashen Hollow | 11 | 4.7× | 19× |
| Ancient Forest (control + mastery + deep) | 40 across three tiers | 3.1× | 12× |

`measured`.

> **Bramble Canopy is the thinnest pool in the game at eight patterns**, and it
> is both the region the owner wants to move to the front and an obvious
> candidate for endless. It currently reads as pleasant partly *because* half
> its chunks are empty, which hides how little vocabulary it has.

So region-endless is gated on authoring depth, region by region, and the order
in which regions get an endless mode should follow pool depth rather than
theme. Ancient Forest could sustain one today; Bramble could not.

### Unresolved conflicts

- **The leaderboard is one board per difficulty mode** — [D-0055], superseding
  the "Standard alone" eligibility clause it replaced. That is three boards, and
  it is bounded: a mode gets a board because it presents a *genuinely different
  course*, which is what makes ranking within it meaningful. **Eight region-endless
  modes do not clear that bar** — they are the same difficulty profile applied to
  one region, so eight more boards would be the population-splitting the board's
  own design rejected, without the justification the difficulty split has.
  *Recommendation unchanged: region-endless is non-records, like Region Practice,
  unless and until the main boards are healthy.*
- **Economy.** If region-endless pays flies, players farm the cheapest region;
  if it pays nothing, it competes with the main run for attention and loses.
  Region Practice's existing answer is "awards nothing", and it is the safest
  precedent.
- **It multiplies the balance surface by eight** — the risk §11 warns about.
  The mitigation is that it multiplies it along a dimension the doctrine wants
  measured anyway, and each mode is independently shippable.

---

## 10 · Questions — settled, and genuinely open

Split by whether an answer follows from evidence already in this document. The
**settled** ones carry their reasoning so they can be overruled; the **open**
ones are open because no amount of measurement decides them.

### 10.1 Settled by reasoning

**S1 · The fairness floor fails CI; it never substitutes silently.**
A silent substitution produces a course different from the one authored, with
no signal that it happened — and it would shift the seeded selection stream, so
the damage would not even be local to the offending chunk. The repository
already refuses to do this elsewhere: the trace format rejects cross-generation
input rather than reinterpreting it, and the check-count guard names its own
fix instead of adjusting itself. A CI failure costs one human edit. A silent
substitution costs an unknown number of quietly degraded chunks that nobody
ever looks at.

**S2 · The Verb requirement is derived from geometry, never flagged.**
A flag saying "this chunk needs a Dive" is exactly the shape of `difficulty` in
F1 — a label with no consumer, unfalsifiable and free to drift. R8 already
requires the generator to determine whether a passable line exists using only
the verbs taught so far, which means the geometry must be interrogable for verb
requirements *anyway*. Once it is, "more Dives and Bursts" becomes a selection
criterion over patterns that already exist, and the only open part is
measurable: how many current patterns actually have a Dive- or Burst-only line.
That is a measurement, not an opinion.

**S3 · `weave` is its own route family.**
Being taught `high` and `low` separately does not teach the weave, because the
weave's difficulty is the *transition between them under time pressure*, which
neither component contains. The generated data agrees: Bramble's loop is
`low · open · weave · open`, treating weave as a distinct beat rather than a
compound. So each section demonstrates 3–4 families and `weave` counts as one.

**S4 · The swap lands with the curve or after it, never before.**
Already derived in §6: Bramble's pool is distance-invariant, so a swapped
opening with no pressure curve is *flat* across its whole 5 km — which
contradicts the owner's requirement 2 directly. This is logic, not preference.

**S5 · Ancient Forest gets the first endless mode.**
Pool depth decides (§9), and it is arithmetic: 20 patterns, 12× repetition over
20 km, against Bramble's 8 patterns and 52×. Nothing else competes.

**S6 · Region-endless awards nothing, like Region Practice.**
The binding economy model is *flies buy power, stars buy appearance, nothing
buys mastery*. A per-region endless mode is a mastery mode by construction, so
paying it would contradict the model's own sentence — and paying flies would
make the cheapest region the farm. *Residual risk worth stating: a mode that
awards nothing may simply not be played. If that happens, the fix is to make it
the calibration instrument §9 describes rather than to attach currency to it.*

**S7 · The region deviation bound is at most ±20%, and ±15% sits safely inside.**
Derivable as a ceiling rather than a value: the saw-tooth the owner complained
about is a **41% drop** (3.44 → 2.00 between Ancient Forest and Bramble). A
deviation bound at or above that permits precisely the thing the doctrine
exists to prevent, so it must be well under it — half is a defensible line. It
must also be non-zero or regions lose their character entirely. **±15%** is a
value inside a derived bound rather than a guess, but the exact figure inside
`(0, 20%]` remains `assumed`.

**S8 · The obstacle-size ramp is optional, not required. — RETIRED 2026-08-03.**
The owner has since chosen it as Bramble's **primary** opening lever: *"we should
just decrease the obstacle size of it for the first 1000m or something like that,
and keep the rest mainly the same."* So the 0.45-size-floor question this
settlement retired is **re-opened**, and it is a device judgement — how small an
obstacle can be drawn before it looks wrong. The reasoning below is kept because
the alternative levers it names are still the ones that carry 1.5–5 km.

§6.1 listed it as one of three levers for Bramble's missing rungs, and F7 has
since supplied a fourth: the lane loop itself. Cadence, singles-before-pairs and
a legible lane cadence give three rungs without touching obstacle scale, so the
size ramp is now an *extra* rather than a dependency. **This retires the
question of whether a 0.45 size floor is acceptable to the art** — nothing needs
it unless the other three prove insufficient on device.

### 10.2 Genuinely open — and why measurement cannot settle them

**O1 · Where does the plateau start? — DEFERRED by the owner, 2026-08-02.**

> *"This is still something we would need to test more. For now let's focus on
> the first 15K because that's actually something that's proven to be reachable;
> once we have determined that the next sections are truly reachable we can
> start thinking about those more."*

Correct call, and it removes the question rather than answering it: **you cannot
place a plateau on ground nobody has stood on.** The longest verified run is
10 605 m. Sections beyond Silk Hollow have never been reached in a recorded run,
so any pressure target for them would be fitted to nothing.

The analysis below is kept for whenever 15–40 km becomes reachable, and is
`assumed` until then.

> **A plateau at 15 km means pressure stops rising while five of the eight
> sections have not yet been seen.** Regions are 5 km each: 15 km is inside
> Silk Hollow, with Ruined Arboretum, Storm Ridge, Web City, Ashen Hollow and
> Deep Mist still ahead — and those five carry the most alien mechanics in the
> game (moving pivots, wind, sticky strands, rotten anchors, short sightlines).

So the real question is not "where does the number go" but: **is arriving
novelty enough variation on its own, or does pressure need to keep rising until
the vocabulary stops growing?** R5 asserts the former. If that is right, 15 km
is fine and the last five sections are pure axis rotation. If it is wrong, the
plateau belongs nearer 40 km and R5 needs rewriting. *Evidence: one long run
through a section at constant pressure whose mechanics are new — Storm Ridge is
the cleanest test, since wind is unlike anything before it.*

**O2 · Ancient Forest's density — ANSWERED by the owner, 2026-08-02: both, and
bounded.**

> *"I think it's a bit of both. The encounters are fun and the fact that some of
> them are genuinely uninterrupted make it very challenging, and the fact that
> there is always still enough room to move through it with some error margin
> makes it the right kind of difficult. Some more open space in between them
> wouldn't hurt, but it should not become 50/50 as in Brambles right now."*

Three things fall out, and the third is the most useful.

1. **The unbroken run is part of the fun**, so recovery must be added
   sparingly rather than to a schedule borrowed from elsewhere.
2. **The bound is explicit**: recovery share strictly above 0% and well below
   Bramble's 50%. The every-fifth-chunk cadence Ancient Forest's own catalogue
   already claims (F3) is **20%** — inside the bound, and it is the natural
   first value to try precisely because the region already declares it.
3. **The reason he tolerates the density is room**, not spacing — which is F8,
   and it says far more about how to use the *width* axis than about recovery.

*Remaining unknown, and it is now narrow: whether 20% is already too much.*
One build answers it and it is one line of code.

**O3 · What is T, the spacing floor in R13? — STRUCTURE RULED by [D-0054],
constants still device-only.**

> **Update, 2026-08-02.** The deep research report reaches this same coupling
> from reaction-time literature, without having seen the derivation below: a
> known beat lets anticipation start *before* the window opens, so 0.60 s can
> work as an expert **execution** window, while an unlearned choice cannot use
> anticipation at all. **Two instruments, one conclusion.** It also bounds the
> constants — 0.8–1.0 s for an unknown opposite-side choice, 1.2–1.4 s where
> swing correction is also needed — as its own conservative extrapolation. See
> R13 and
> [`difficulty-research-2026-08-02.md`](difficulty-research-2026-08-02.md) § 2.1.
>
> **What remains open is now narrower:** not *whether* T varies with
> predictability, but what the constants are on the owner's device and hands.
>
> **⚠ And the question was framed against the wrong number.** Measured
> 2026-08-02: `high_low_weave`'s 420 px is **not** the tightest content. Three
> `centre`-lane patterns are tighter — `hollow_spindle_gate` at **180 px
> (0.20 s)**, `staggered_s` at 233 px, `stump_and_vine` at 252 px. So **the real
> floor is 2.3× tighter than the figure this question was built on**, and any T
> chosen against 0.60 s would leave three patterns beneath it untouched.
> Worse for R14's framing: **every `weave`-lane pattern is looser than all three
> tightest `centre`-lane ones**, so the lane label does not predict timing
> pressure at all. See **N1** and **N3** in
> [`../measurements/2026-08-02-course-audit-baseline.md`](../measurements/2026-08-02-course-audit-baseline.md).

The original derivation, kept because the convergence is the evidence:

A *read* commitment needs choice-reaction time plus execution: roughly 400–600
ms to decide which way to go, then the time to fire a web or commit a Dive. The
weave's measured 0.60 s between its two commitments sits at the bottom of that
range with no margin at all. That argues for T ≥ 0.8 s.

But a *predicted* commitment needs far less, which is exactly the owner's own
account of his 10 605 m run — once the route is known he is executing, not
reading. **So T is not one number: it is a function of local predictability,
and R13 and R14 are the same knob seen from two sides.** High predictability
buys tighter spacing honestly; low predictability must pay for it in time.

That coupling is derivable. The constants in it are not, because they are the
owner's reaction time on his own device.

---

## 11 · Risks

- **Calibrated on one player.** Every target in §2 is the owner's play. A
  second competent player would sharpen this a lot.
- **Eight regions × new rules is a large authored surface.** Phase 3's
  region-at-a-time staging exists to stop that landing as one unreviewable
  change. Per-region endless modes (§9) multiply it again.
- **Pattern vocabulary is thin and uneven** — 8 patterns in Bramble against 40
  across Ancient Forest's tiers. Any plan that gives a region more distance
  than its slot is really a request for more authored patterns.
- **Save migration** for region checkpoints if the swap lands (§6.3).
- **Course seeds change.** Any change to pool selection changes every generated
  course, so old traces and any recorded run become non-reproducible. The trace
  format already refuses cross-generation input, so this fails loudly rather
  than silently — but the leaderboard's reproducibility promise is scoped to one
  physics generation, and this is a generation change.

---

## Appendix · Reproducing the measurements

**Superseded 2026-08-02 — both instruments are now permanent.** Run:

```bash
godot --headless --path . --script res://tools/course_audit.gd -- \
  --to-metres=15000 --seeds=3 --json=/tmp/course-audit.json
```

Measurement lives in `tools/course_audit_probe.gd` and is pinned by five
contracts. The original sketch is kept below because the *error* it records is
the reason those contracts exist:

- **Label curve** — call `CoursePatternCatalog.pattern_for_chunk(chunk, chunk *
  960.0, seed)` for chunks 0…160 across several seeds; bucket
  `pattern["difficulty"]` by kilometre.
- **Gate curve** — `CourseStream.reset(...)` then `update_for_position(x)` per
  chunk; from `geometry()`, take `boundary_surfaces` and
  `obstacle_contact_polygons`, compute each polygon's y-span at a sampled `x`,
  merge overlapping spans, and take the largest **interior** gap. Measuring
  from `y = 0` instead of from the ceiling's underside reports the space above
  the ceiling as passable and yields nonsense — that error was made and caught
  during this session.
