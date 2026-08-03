# Course audit baseline — the generator, measured, 0–15 km

> **Status:** `reference`
>
> The first output of the Phase 0 instrument (`tools/course_audit.gd`). It walks
> the deterministic generator and reports geometric proxies per chunk. **No play
> data is involved** — this is what the generator builds, not what happens to
> anyone in it.
>
> **The headline: the instrument reproduces all four of the owner's felt
> difficulty boundaries from geometry alone.** He described them from device
> play on 2026-08-02; this measurement had no access to that account beyond the
> doctrine already written from it, and it recovers each one on independent axes.

## Method

```bash
godot --headless --path . --script res://tools/course_audit.gd -- \
  --to-metres=15000 --seeds=3 --json=/tmp/course-audit.json
```

`measured` — three course seeds (1000–1002), chunks 0–156, 40 vertical probes
per chunk (one every 24 px), on the pinned `4.7.1.stable.official.a13da4feb`
with `balanced_baseline`. Course generation is a pure function of
`(chunk_index, distance_at_chunk, course_seed)`, so re-running does not
re-sample — **a repeat run is never independent confirmation.**

**Resolution and units.** Corridor is the largest *interior* free vertical span,
in player diameters (36 px). Spacing is between **sequential opposite-side**
obstacle commitments, reported in seconds **at the speed cap for that distance**
— which is what R13 specifies and is the worst case. Speed-independent pixel
figures are in the JSON; divide by whatever speed you want to reason at.

## The measured curve

| km | region | authored label | challenge chunks | tightest corridor | tightest sequential pair |
| ---: | --- | ---: | ---: | ---: | ---: |
| 0 | ancient_forest | 0.00 | 100% | 14.27 | — |
| 1 | ancient_forest | 1.47 | 100% | 7.39 | — (4 gates) |
| 2 | ancient_forest | 2.94 | 100% | 7.39 | **0.31 s** |
| 3 | ancient_forest | 3.27 | 100% | 7.39 | 0.30 s |
| 4 | ancient_forest | 3.48 | 91% | 7.39 | 0.29 s |
| 5 | bramble_canopy | 2.00 | 50% | 8.49 | 0.84 s |
| 6 | bramble_canopy | 2.00 | 50% | 8.49 | 0.81 s |
| 7 | bramble_canopy | 2.18 | 55% | 8.49 | 0.79 s |
| 8 | bramble_canopy | 2.00 | 50% | 8.49 | 0.78 s |
| 9 | bramble_canopy | 1.82 | 45% | 8.49 | 0.77 s |
| 10 | silk_hollow | 3.20 | 80% | **6.79** | **0.20 s** |
| 11 | silk_hollow | 3.20 | 80% | 6.79 | 0.20 s |
| 12 | silk_hollow | 3.27 | 82% | 6.79 | 0.20 s |
| 13 | silk_hollow | 3.20 | 80% | 6.79 | 0.20 s |
| 14 | silk_hollow | 2.91 | 73% | 6.79 | 0.20 s |

## The owner's four boundaries, checked

His account, 2026-08-02, and what the generator says.

1. > *"the start is too easy, the whole time I'm speeding through it with reel
   > just to get it over with"*

   **Confirmed.** km 0 carries authored label **0.00**, the widest corridor in
   the game (14.27 diameters), and **no sequential opposite pair at all**.

2. > *"at about 2500m the difficulty suddenly increases drastically"*

   **Confirmed, and now with a mechanism.** The *first* sequential opposite pair
   in the whole run appears in **km 2**, at 0.31 s. Before it there are none —
   km 1's opposite-side obstacles are all **simultaneous gates**, which are
   threaded rather than reacted to in sequence. The label and density curves are
   already high by km 1; **the thing that actually changes at ~2.5 km is the
   arrival of sequential opposite commitments.**

3. > *"between 2500 and 5000 most of my death occur"*

   **Confirmed.** km 2–4 combine the tightest Ancient Forest spacing
   (0.29–0.31 s) with 91–100% challenge density and a corridor at its regional
   minimum of 7.39 diameters. All three axes are at their regional worst
   simultaneously.

4. > *"after 5000 it gets a lot easier and more open"*

   **Confirmed on three independent axes at once.** Crossing into Bramble,
   challenge density halves (100% → 50%), spacing nearly triples (0.29 s →
   0.84 s), and the tightest corridor *widens* (7.39 → 8.49 diameters). The
   authored label drops 3.48 → 2.00, the **41% saw-tooth** the doctrine measured,
   independently reproduced.

5. > *"untill it hits 10K then suddenly it's at least 2x more difficult with no
   > gradual increase"*

   **Confirmed.** At the Silk Hollow boundary density returns to 73–82%, the
   corridor becomes the tightest in the game (6.79 diameters), and spacing
   **collapses to 0.20 s — 3.9× tighter than Bramble** — at the boundary, with no
   ramp. *"At least 2×"* is his estimate and this measurement cannot price it;
   what it can say is that every axis steps at once and none of them ramps.

## Six findings the doctrine did not have

### N1 · The tightest content in the game is not the weave

> **⚠ This is a SPACING finding, not a width one — clarified 2026-08-03.** Every
> figure below is centre-to-centre or edge-to-edge distance *between* obstacles.
> It has repeatedly been read as a corridor-width claim, and it is not:
> `hollow_spindle_gate`, named here as tightest, has a **7.85-diameter corridor**
> and an **8 ms constriction** — the most generous tight pattern in Silk Hollow.
> Corridor width is measured in
> [`2026-08-03-corridor-and-constriction.md`](2026-08-03-corridor-and-constriction.md)
> and governed by the corridor-width envelope in the decision ledger.

**The whole of O3 was framed around `high_low_weave` at 420 px / 0.60 s.** It is
not the floor. Measured, tightest first:

| pattern | lane | region | centre-to-centre | edge-to-edge |
| --- | --- | --- | ---: | ---: |
| `hollow_spindle_gate` | centre | silk_hollow | **180 px** | **104 px** |
| `staggered_s` | centre | ancient_forest | 233 px | **59 px** |
| `stump_and_vine` | centre | ancient_forest | 252 px | 93 px |
| `high_low_weave` | weave | ancient_forest | 416 px | 267 px |
| `low_high_weave` | weave | ancient_forest | 424 px | 279 px |
| `canopy_hook_high_low` | weave | bramble_canopy | 692 px | 405 px |
| `canopy_shutter_high_low` | weave | bramble_canopy | 693 px | 388 px |

**The real floor is 2.3× tighter than the number the open question was built
on.** Any T chosen against 0.60 s would leave three patterns below it untouched.

### N2 · Edge-to-edge is much tighter than centre-to-centre, and it is the honest number

Centre-to-centre counts the obstacles' own widths as available time. Edge-to-edge
is the clear horizontal space between *finishing* one and *meeting* the next.
`staggered_s` measures **59 px edge-to-edge — 1.6 player diameters**, against
233 px centre-to-centre. The doctrine's 420 px figure is a centre measurement, so
comparisons against it must stay centre measurements or they are not comparable.

### N3 · `lane` does not predict timing demand

**Both of the two tightest patterns are `lane = centre`, not `lane = weave`.**
Every `weave`-lane pattern is *looser* than all three tightest `centre`-lane
ones. So R14 (route-family scheduling) and R13 (spacing floor) are measuring
genuinely different things, and **the lane label cannot be used as a proxy for
reaction pressure** — which is what an axis-vector approach exists to prevent.

### N4 · Simultaneous gates are a width challenge, not a timing one

`rooted_gate` places its ceiling and floor obstacles at an **identical x-range**
(measured: x = [12116, 12304] for both). Timed naively as a sequential pair it
reads **0.00 s**, and R13's floor would look violated wherever a gate appears.
The instrument separates the two by x-overlap and counts gates rather than
timing them; a contract pins that behaviour.

### N5 · The warm-up already carries obstacles — R6 is a proposal, not a description

R6 says *"0–500 m carries no lethal obstacle."* Measured: chunks **1 and 4**
(96 m and 384 m) each carry one obstacle contact polygon, and the pattern
`[0, 1, 0, 0, 1, 0]` is **identical across all three seeds** — the opening is
authored, not seeded. That matches R12's description of the first gate (*"loose
single obstacles alternating top and bottom"*) and contradicts R6's stricter
wording. **One of the two rules needs rewording before either is implemented.**

### N6 · Recovery share per region, exactly

| region | chunks that are `open_recovery` |
| --- | ---: |
| ancient_forest | **2%** |
| bramble_canopy | **50%** |
| silk_hollow | 21% |

This is F3 stated as a number. Ancient Forest's catalogue claims a "wide recovery
rhythm" and delivers 2%. It also bounds O2 precisely: the owner said recovery
should rise above Ancient Forest's level but *"should not become 50/50 as in
Brambles"* — so the target sits inside **(2%, 50%)**, and Silk Hollow's 21% is a
shipped example of a value in that range.

## Corridor, per region

| region | tightest | median | widest |
| --- | ---: | ---: | ---: |
| ancient_forest | 7.39 | 12.29 | 15.89 |
| bramble_canopy | 8.49 | 9.83 | 15.89 |
| silk_hollow | **6.79** | 10.39 | 14.26 |

In player diameters. **Bramble has the lowest median corridor but the widest
minimum** — it is consistently narrower without ever being as narrow as Silk
Hollow's worst. That nuances F8: "narrowness" is two different quantities
(typical and worst-case) and the regions do not rank the same way on them.

## What this does not say

1. **It is not difficulty.** Every figure is a geometric proxy. Whether 0.20 s is
   unfair depends on predictability, telegraphing and the player — all device
   questions.
2. **It is not passability.** The instrument does not sweep a route. The existing
   fairness contracts do that, and they still pass.
3. **It says nothing about deaths.** There is no play data *here* — though as
   of 2026-08-03 there is some, in
   [`2026-08-03-owner-run-attrition.md`](2026-08-03-owner-run-attrition.md):
   35 recorded attempts whose hazard peaks at **2 000–2 500 m**, independently
   landing on the same cliff this document found from geometry. The instrumented
   hazard telemetry that § 3 of
   [`../game-design/difficulty-research-2026-08-02.md`](../game-design/difficulty-research-2026-08-02.md)
   specifies — deaths over runs that *reached* a point, first exposure separated
   from later — needs instrumented runs and does not exist yet.
4. **Seconds depend on the speed you assume.** These are at the speed cap. At the
   owner's measured sustained pace the same geometry buys more time.

## Claim provenance (PL-013)

- **`measured`** — every number above, from the deterministic generator at 24 px
  horizontal resolution and 1 px vertical, three seeds. Deterministic; a repeat
  run is not independent confirmation.
- **`measured`** — that the opening is seed-independent (three seeds, identical).
- **`inferred`** — that the arrival of *sequential* pairs is what the owner felt
  at ~2.5 km. The correlation is exact in this data; the causal claim is not
  tested.
- **`assumed`** — that any of these proxies predicts felt difficulty for anyone.
