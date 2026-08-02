# Bot model v4 — the model can pump, and that is how reel upgrades pay

> **Status:** `reference`
>
> The single most-cited blind spot in this repository — *the bot cannot pump a
> pendulum* — is now closed. Measured effect: **pumping reliably buys speed,
> and it buys far more at high upgrade levels than at level zero.** That
> mechanically explains why the lab kept reading reel upgrades as worthless.
>
> **The publication rule is UNCHANGED.** v4 still fails the upgrade-sign
> acceptance target in
> [`2026-08-01-owner-play-calibration.md`](2026-08-01-owner-play-calibration.md),
> so no conclusion about difficulty, upgrades or the economy may be drawn from
> simulation output. v4 is a better instrument, not a licence.

## Method

`tools/simulate.gd`, bot model v4, `balanced_baseline`, `classic`, Standard,
120 s cap, Godot `4.7.1.stable.official.a13da4feb`. Full suite green at
**204 contracts** both before and after the change.

Two **disjoint** seed sets, so a result that appears in one and not the other is
reported as not replicating:

- **Set A** — bot seed 4242, courses 9000–9007, n=24 (the sweep document's
  held-out set).
- **Set B** — bot seed 1234, courses 7000–7007, n=32 (unseen by anything).

Every comparison below holds one policy constant across the compared cells.
Resolution is one 60 Hz tick; the **statistical** resolution is the binding one,
and at n=24 the p10–p90 band is roughly 1 300–3 100 m, so differences under
about ±200 m are not resolvable. That limit is applied honestly below — several
differences that look interesting are inside it and are labelled as such.

## What changed in the model

One knob, `pump_window_deg`, plus the policy that reads it
(`RunDriver._in_pump_window`). The model now reels when the web is within that
many degrees of straight-down, in addition to the old "below the route" rule,
and a pump is no longer cut short by having reached route height.

**Why that is pumping, physically.** `WebConstraint.advance_resource` only
shortens the rope; the constraint then resolves position along the radius,
killing outward radial velocity and preserving tangential. So a reel adds no
speed directly — the design's "speed-neutral" — it **buys height for free**, and
shortening by `dr` at angle `θ` from straight down raises the spider by
`dr·cos θ`. Pumping at the bottom of the arc is therefore worth `1/cos θ` times
pumping off to the side, and the height comes back as speed on the next descent.

The old policy reeled purely on being below the route. Being low correlates with
the bottom of a swing but does not imply it: **low and far out to the side is
the worst place to spend the meter, and it was being spent there routinely.**

Tier values are `novice 25° · intermediate 15° · expert 12°` — monotone in
precision, because a less skilled player pumps with sloppier timing. Only the
*direction* is measured (see the window sweep); the exact values are modelling
judgement and are `assumed`.

## The window sweep — tighter is better, and it is not subtle

Set A, intermediate, L0, n=24:

| `pump_window_deg` | travelled | deaths/km | speed vs reference | reel empties/run |
| ---: | ---: | ---: | ---: | ---: |
| **off (v3)** | 1 682 m | 1.19 | −4.2 m/s | 0.29 |
| 6° | 1 787 m | 1.12 | — | 0.58 |
| 12° | 1 858 m | 1.08 | — | 0.92 |
| **15°** | **1 931 m** | **1.04** | **−1.0 m/s** | 1.17 |
| 25° | 1 779 m | 1.12 | −1.4 m/s | 2.71 |
| 35° | 1 713 m | 1.17 | −1.5 m/s | 3.17 |
| 50° | 1 504 m | 1.33 | −2.4 m/s | 3.83 |

Everything from 6° to 35° beats the old policy; 50° is worse than not pumping at
all. **The peak's exact location is inside the noise band and is not claimed** —
6°, 12°, 15° and 20° are not distinguishable from one another at n=24. What is
solid is the shape: efficient windows help, sloppy ones waste the meter
(`reel empties` rises 0.29 → 3.83) and the meter is then unavailable for a real
correction.

## What replicates, and what does not

Set A vs Set B, intermediate, L0, pump 15° against pump off:

| | Set A (n=24) | Set B (n=32) | replicates? |
| --- | ---: | ---: | --- |
| Distance | 1 682 → 1 931 m (**+14.8%**) | 1 807 → 1 831 m (**+1.3%**) | **No** |
| Speed vs reference | −4.2 → −1.0 m/s | −3.4 → −0.1 m/s | **Yes, ≈ +3.3 m/s** |
| Deaths/km | 1.19 → 1.04 | 1.11 → 1.09 | directionally, weakly |
| Reel empties/run | 0.29 → 1.17 | 0.53 → 1.22 | **Yes** |

**The distance gain did not replicate. The speed gain did.** Set A's +14.8% is
substantially seed luck and must not be quoted as the effect of pumping. The
honest headline is that pumping converts reliably into **speed**, and whether
that becomes distance depends on what else is binding.

The reel-empties result is a genuine fidelity gain against measured ground
truth: the owner **empties the meter in every recorded L0 run** while v3 emptied
it 0.29–0.53 times per run. v4 moves toward him rather than away.

## The finding that matters: pumping is how reel upgrades get spent

Set A, intermediate, standing start, n=24 — the full 2×2:

| | pump off (v3) | pump on (v4) | pumping buys |
| --- | ---: | ---: | ---: |
| **L0** | 1 682 m | 1 931 m | **+14.8%** |
| **L40** | 1 049 m | 1 531 m | **+46.0%** |
| *upgrades buy* | **−37.7%** | **−20.7%** | |

Pumping is worth **three times as much at L40 as at L0**, which is exactly what
the physics predicts: L40 reels at 454 px/s into a 2.67 s meter against L0's
320 px/s into 2.00 s, so every pump moves more rope and there are more of them.

> **This is the mechanism behind a finding this repository has been carrying as
> an unexplained contradiction.** The lab kept reporting reel upgrades as
> worthless-to-harmful while the owner reported max upgrades playing far better
> than none. The explanation is not that the bot "reels in fractions" alone — it
> is that **the bot had no way to spend a bigger reel.** A stronger meter is
> only worth something to a policy that can convert it, and conversion is
> pumping. Give the model the verb and the same upgrades are worth 46% instead
> of 15%.

**It is still the wrong sign.** v4 shrinks the L40 upgrade penalty from −37.7%
to −20.7% — a 17-point move toward the owner's reality — and does not reach it.
The acceptance target is that upgrades must *improve* the result; v4 fails it,
so the publication rule stands unchanged.

## Speed costs deaths, measured four independent ways

Every cell where the model got faster, it also died more per kilometre:

| Change | speed vs reference | deaths/km | travelled |
| --- | ---: | ---: | ---: |
| pump 15° → 25° (Set B) | −0.1 → **+1.0** | 1.09 → **1.29** | 1 831 → 1 548 m |
| pump 15° → 50° (Set A) | −1.0 → −2.4 | 1.04 → **1.33** | 1 931 → 1 504 m |
| L0 → L40, pump on (Set A) | −1.0 → **+4.6** | 1.04 → **1.31** | 1 931 → 1 531 m |
| L0 → L40, cadence 2/2 | +6.7 → **+7.6** | 0.84 → 0.91 | 2 387 → 2 193 m |

**This is a model-side corroboration of the mechanism named in
[`../product/upgrade-and-difficulty-research-2026-08-02.md`](../product/upgrade-and-difficulty-research-2026-08-02.md)
§ 2.4** — that warning time shrinks as speed rises, from both the fixed
700–820 px hazard cue and the fixed 853 px camera preview — arrived at from a
completely different instrument. The bot's analogue of preview is its decision
cadence and reaction delay, and it exhibits the same trade.

It is corroboration of the *mechanism*, not of any tuning number. Nothing here
licenses a change to cue distance, camera lead, or any physics value.

## A hypothesis that did NOT hold up

If the speed-for-deaths trade were purely reading-bound, giving the model more
reading time should flip the upgrade sign positive. Set A, intermediate,
standing, n=24:

| cadence (decide/react, ticks) | L0 | L40 | upgrade effect |
| --- | ---: | ---: | ---: |
| 7/6 (default) | 1 931 m | 1 531 m | −20.7% |
| 4/3 (expert rate) | 2 692 m | 2 047 m | **−24.0%** |
| 2/2 (human peak floor) | 2 387 m | 2 193 m | **−8.1%** |

**Not monotone, and therefore not supported.** The penalty does shrink at the
fastest cadence, but the middle point is worse than the slowest, and L0 itself
is not monotone in cadence (2 692 m at 4/3 beats 2 387 m at 2/2). At n=24 these
differences are at or inside the noise band. Recorded as a negative result so
the next session does not re-run it expecting a clean answer.

## A fix that measured worse and was deleted

A **release-arc gate** — postponing a discretionary release until the award in
`SimulationWorld._release_web` would actually be paid (forward, right of the
anchor, past a minimum covered arc) — was implemented and measured:

| Set B, intermediate, L0, n=32 | travelled | deaths/km |
| --- | ---: | ---: |
| baseline | 1 807 m | 1.11 |
| minimum arc 30° | 1 637 m (**−9.4%**) | 1.22 |
| minimum arc 50° | 1 640 m (**−9.2%**) | 1.22 |

Two settings, same size, same direction: **holding a swing for the release award
costs this model more than the award is worth.** Deleted rather than kept behind
a default-off knob, following this repository's practice with the three v3 fixes
that measured worse.

It is **bot evidence, not a tuning verdict** — but it is worth putting in front
of OQ-16, which asks whether earned release feels strong and legible. The award
is `assumed` at 100 px/s scaled by `arc_quality × rise_quality`, and a policy
that must trade holding-time to collect it is currently better off not
collecting it. Whether a human faces the same trade is a device question.

## Acceptance targets — v4 scored honestly

Against `2026-08-01-owner-play-calibration.md`, intermediate tier, Set A:

| Target | v4 result | Verdict |
| --- | --- | --- |
| Warp 5 km L20: median ≥1 500 m per life | **361 m** median net (mean 532 m) | **FAIL** |
| Warp 5 km L20: ≤0.8 deaths/km | **3.76** | **FAIL** |
| Warp 5 km L20: sustained 45–80 m/s | −26.1 m/s vs reference, above it 5% of run | **FAIL** |
| Warp 5 km L20: spread in kilometres | p10–p90 278–724 m | **FAIL** |
| Standing L0: inside 0.8–4.7 km | 1.37–2.55 km p10–p90 | **PASS** |
| Standing L0: median ~2.4 km | **1.78 km** | marginal |
| Any config: upgrades must improve | **−20.7%** at L40 | **FAIL** |
| Any config: run-average ≤18 taps/s | 3.6 taps/s | **PASS** |

Roughly **two and a half of eight**, against v3's three of eight on a
partly different target list. v4 is better on the mechanism it fixed and no
better on pace: the warp band is still where the model collapses, and its
sustained speed there is 26 m/s below the reference curve while the owner ran
that same warp at 78.6 m/s.

**So the rule in `docs/technical/simulation-lab.md` is unchanged, and this
document does not weaken it.** Do not use the simulator to evaluate upgrades,
difficulty, or the economy.

## Reproduce

```bash
# v4 default
godot --headless --path . --script res://tools/simulate.gd -- \
  --runs=24 --seed=4242 --course-seed=9000 --course-seeds=8 \
  --skill=intermediate --upgrades=0 --max-seconds=120

# every pre-v4 batch in docs/measurements/ reproduces with pumping disabled
godot --headless --path . --script res://tools/simulate.gd -- \
  --runs=24 --seed=4242 --course-seed=9000 --course-seeds=8 \
  --skill=intermediate --upgrades=0 --max-seconds=120 --bot=pump_window_deg:0
```

**Prior published bot numbers were produced by v3 and do not reproduce under the
v4 default.** `--bot=pump_window_deg:0` restores v3 behaviour exactly; that flag
is the migration path, and `BOT_MODEL_VERSION` is printed in every batch header
so a pasted result always says which model produced it.

### Claim provenance (PL-013)

- **`measured`** — every number above, instrumented simulation at 1-tick
  resolution, deterministic. Re-running does not re-sample, so a repeat run is
  never independent confirmation.
- **`measured`** — that pumping is worth more at L40 than L0 (+46.0% vs
  +14.8%). Same policy, same seeds, one variable.
- **`inferred`** — that this explains the lab's historical reel-upgrade
  reading. It follows from the mechanism and the 2×2, but no owner-side
  measurement confirms the link.
- **`assumed`** — the per-tier window values, and that any of this transfers to
  a human. The model still fails five of eight acceptance targets; a fixed
  blind spot is not a validated model.
