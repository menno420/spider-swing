# Owner play calibration — 2026-08-01

> **Status:** `reference`
>
> Ground truth for how the game is actually played, taken from owner device
> recordings. **This is the acceptance test any simulation model must pass
> before its output is published.** The overnight lab runs failed every target
> below and their conclusions were published anyway; that is the mistake this
> document exists to prevent.

## The recordings

Six screen recordings, 2026-07-31, build `0.19.1-depth-control-repair`. All
are **debug start 5 000 m with upgrades at L20**, which is the same warp
condition `tools/simulate.gd --start-m=5000` uses — so the comparison is
direct, not an analogy.

| Run | Duration | Start | Last observed | Net progress | Deaths | Mean speed |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `726dcc65` | 48.6 s | 5 019.8 m | 8 554.6 m | 3 535 m | 1 | 78.6 m/s |
| `07a46d98` | 41.6 s | 5 205.2 m | 7 965.1 m | 2 760 m | 1 | 66.3 m/s |
| `4185b2b4` | 40.7 s | 5 118.5 m | 7 789.9 m | 2 671 m | 1 | 74.2 m/s |
| `256bd884` | 36.7 s | 5 181.5 m | 7 399.6 m | 2 218 m | 1 | 73.9 m/s |
| `17dd734b` | 44.2 s | 5 100.9 m | 6 887.4 m | 1 787 m | 1 | 44.7 m/s |
| `6b272cfb` | 33.5 s | 5 198.9 m | 5 077.3 m | **−122 m** | 1 | — |
| **total** | **245.3 s** | — | — | **12 849 m** | **6** | **52.4 m/s** |

Every run was still alive when its recording ended, so these are lower bounds.
"Deaths" counts the rescue life being spent, which the HUD states directly
(`RESCUE READY` → `RESCUE SPENT` → "Rescue silk caught you · life spent").

**Aggregate: 0.47 deaths/km at ~52 m/s sustained.**

**The variance is the headline.** Net progress ranges from **−122 m to
3 535 m** across six runs of the same configuration — a run where the rescue
reset him *behind* his starting point, and a run of 3.5 km. That spread is
what the owner means by "each run is genuinely different": production draws a
fresh course seed every run. A model validated only on tight fixed-seed batches
will not reproduce it, and reporting a mean without that spread misleads.

## Against the bot

| | Owner | Bot, expert, same warp |
| --- | ---: | ---: |
| Median net progress per life | ~2 400 m | 196 m |
| Deaths per km | **0.47** | **10.23** |
| Range across runs | −122 m to 3 535 m | 141–274 m (p10–p90) |

The bot is not a weaker player in this regime. It dies in under three seconds
at pace, roughly **27× worse per kilometre**.

## Playstyle observations that a model must reproduce

**Dive is a primary verb.** The action button cycles ATTACH → BURST → PULL
continuously, with `Dive Pull 40%` in the feedback line throughout. The current
bot has never performed a single Dive in any batch ever run.

**He trades distance for safety, and sometimes loses.** Run `17dd734b` covers
only **320 m in its first 20 seconds** — hanging on a long web, stabilising — then 1 467 m in the next 20.
A model that always maximises forward progress cannot produce that shape, and
would score the recovery as failure. Run `6b272cfb` is the other tail: he ends
*behind* where he started, because the rescue returns the player to a safe
point upstream. Both belong in a faithful model — a bot that only ever produces
its median is not modelling this game.

**Input rate is several per second**, against a bot that decides once every 7
ticks with a 6-tick reaction delay.

**Upgrades are used deliberately.** `Anchor Burst 52%` appears in the feedback
line — the L20 burst fraction — and the owner reports upgrades taking him from
~2 km unupgraded to well above 5 km.

## The input stream, recovered

The recordings have Android **show-taps** enabled, so every touch is drawn as a
pale disc at its exact screen position. That makes the input stream directly
recoverable — position and frame-accurate timing, not inference.

Detected by scanning for bright near-neutral discs (`value > 0.55`,
`saturation < 0.16`, ≥140 px solid) at 30 fps and de-duplicating across the
~3-frame fade. Run `726dcc65`, 48.6 s:

| Measure | Value |
| --- | ---: |
| Taps detected | 229 |
| **Tap rate** | **4.71 / second** |
| Median gap between taps | 0.133 s |
| Left button — Reel | 52 (22.7%) |
| Right button — Attach/Burst | 70 (30.6%) |
| Play area — aiming | 107 (46.7%) |

**Of the aiming taps, 48% are in the lower half of the screen** — Dive targets,
since the HUD's own instruction is "tap solid above to web · tap solid below to
Dive Pull". Median aim-tap height is 203 px of 480.

That is the single most important number here: **roughly half of all aimed
input is a verb the current bot has never once performed.** Not a tuning gap —
half the game is missing from the model.

For comparison, the bot's decision cadence is 0.117 s at intermediate, close to
the owner's 0.133 s median gap. So the model's *rate* is roughly right and its
*repertoire* is not. That is a much more specific diagnosis than "the bot is
unrealistic", and it points at what to build.

## Acceptance targets

A simulation model may not be used to draw conclusions about difficulty,
upgrades or the economy until it meets these. They are deliberately loose —
matching the owner exactly is not the goal; not being wrong by an order of
magnitude is.

| Configuration | Target | Source |
| --- | --- | --- |
| Warp 5 000 m, upgrades L20 | median ≥1 500 m per life, ≤0.8 deaths/km | recordings above |
| Warp 5 000 m, upgrades L20 | sustained 45–80 m/s | recordings above |
| Warp 5 000 m, upgrades L20 | run-to-run spread of **kilometres**, not metres | recordings above |
| Standing start, no upgrades | ~2 000 m | owner statement |
| Standing start, max upgrades | >5 000 m | owner statement |
| Any configuration | upgrades must **improve** the result | owner statement |

That last row is the cheapest and most important: the current bot reports
upgrades as a 25% *loss*, so it fails on sign alone before any magnitude is
considered.

## Known structural blind spots

Three, all discoverable in source, all of which produced published errors:

1. **No Dive.** The bot cannot represent a third of the verb set.
2. **Fraction-based Reel policy.** It engages above
   `energy_fraction > reel_reserve` and stops at `energy_fraction <= 0.06`.
   Every term is a ratio, so scaling `reel_energy_capacity` scales both sides
   and the bot behaves identically — Silk Reserve's real 2.00 s → 2.48 s gain
   in continuous reel time is invisible to it. It also means the meter can
   never empty, which made "the Reel meter never empties" a circular premise.
3. **Anchor classes ignored.** `tools/simulate.gd` references none of
   `ANCHOR_MOVING_PIVOT`, `ANCHOR_HIGHWAY`, `ANCHOR_STICKY`, `ANCHOR_ROTTEN`
   or `ANCHOR_COLLAPSING`, so zones 4–8 are measured as if their defining
   mechanics were ordinary fixed anchors.

## Method

Frames decoded with ffmpeg at 1–10 fps and read directly; distance, fly count,
rescue state and the action-button label are all legible in the HUD. The
action button is separable by colour alone at 10 fps. Tap markers are separable
by saturation at 30 fps, giving exact position and timing for every input — so
aim distribution, tap cadence and verb mix can all be fitted from recordings
without OCR and without inference.

Recordings are the owner's and are not committed to the repository.
