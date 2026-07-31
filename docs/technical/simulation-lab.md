# Simulation lab — headless batch runs

> **Status:** `reference`
>
> Diagnostic balance instrumentation. Not a merge gate, not a feel oracle.

## What it is

`tools/simulate.gd` drives the authoritative `SimulationWorld` +
`CourseStream` — the exact code the game ships — with a scripted, deliberately
imperfect player model, unpaced and headless. Hundreds of short runs complete
in seconds and report distance, death-cause, and resource metrics, so a tuning
change can be compared **before** spending an owner device playtest on it.

```bash
godot --headless --path . --script res://tools/simulate.gd -- \
  --runs=20 --skill=all --spider=classic --upgrades=0 --json=/tmp/sim.json
```

| Option | Default | Meaning |
| --- | --- | --- |
| `--runs=N` | 20 | Runs per configuration |
| `--skill=` | `intermediate` | `novice` · `intermediate` · `expert` · `all` |
| `--spider=` | `classic` | Any catalog id, or `all` |
| `--preset=` | `balanced_baseline` | Named `SwingConfig` preset (legacy `balanced_candidate` still resolves) |
| `--upgrades=N` | 0 | Level 0–20 applied to every track of the spider |
| `--seed=N` | 1 | Base seed for the bot-imperfection RNG |
| `--course-seed=N` | 1337 | First production course-order seed |
| `--course-seeds=N` | 1 | Consecutive course seeds rotated independently across runs |
| `--max-seconds=S` | 240 | Simulated-time cap; a capped run reports `timeout` (alive), never a death |
| `--start-m=N` | 0 | Warp the start N metres into the course at that distance's pace — tests late-game regimes without surviving to them |
| `--reel-style=` | `adaptive` | `adaptive` · `tap` · `hold` — how the bot spends Reel |
| `--save-bursts=` | `on` | `on` · `off` — emergency Burst when no web can save it |
| `--moving-anchor-proof` | off | Run the ADR 0004 moving-pivot energy probe against the production `WebConstraint`, then exit |
| `--sweep=SPEC` | — | Parameter grid, e.g. `reel_rate:260:440:4,pull_cooldown:1.2:2.4:3` (≤60 points, one skill + spider). Names resolve as TuningCatalog ids first, else raw `SwingConfig` properties (`reel_regeneration_rate`) |
| `--json=path` | — | Write per-run rows + summaries as JSON |

## The player model (bot v2)

The bot reads only what a player could: its own motion, the fly trail (the
game's authored route language), solid geometry through the same
`nearest_solid_point` forgiveness a real tap receives, and the pull-safety
preview the HUD already draws. It attaches up-forward webs when falling or
below the route, releases on the rising swing, reels when below the route
line, and Bursts opportunistically — plus an emergency Burst when it is
falling to its death and no attachable web exists. Skill tiers vary only
human-imperfection parameters:

| Tier | Decision cadence | Reaction delay | Aim error σ | Checks pull safety |
| --- | --- | --- | --- | --- |
| novice | 10 ticks | 9 ticks (+0–2) | 46 px | 40% of Bursts |
| intermediate | 7 ticks | 6 ticks (+0–2) | 26 px | 75% of Bursts |
| expert | 4 ticks | 3 ticks (+0–2) | 10 px | 95% of Bursts |

**v2 adapts to the configuration it is handed**, the way a player learns a
build, so upgrade comparisons measure the tuning rather than a bot's stale
habits:

- **Reel reserve follows sustainability.** The less the meter regenerates
  relative to its drain, the larger the fraction the bot keeps in reserve
  before spending (`hold` style spends to empty; `tap` style keeps the v1
  fixed reserve).
- **Reel engagement follows the retraction rate.** A faster reel corrects
  more per second, so the bot engages it later for the same correction.
- **Burst aim shortens as the pull fraction grows.** Expected travel stays a
  controllable hop, and a skill-scaled habit checks the game's own
  endpoint-safety preview before committing.

The course is deterministic for a given course seed. By default it is identical
every run, while `--course-seeds` can rotate a known seed range independently
from bot-imperfection seeds. This separates “different player reaction” from
“different curated pattern order” in the resulting rows. The same seeds and
options reproduce a batch bit-for-bit, and summaries carry the bot model
version because numbers are only comparable within one bot model.

Each row records its course seed, death region, and active pattern. Summaries
include death-region and death-pattern histograms. Late-game `--start-m` runs
now use the same safe start-distance reset and guided opening as production
checkpoint practice. The delayed command queue also permits only one pending
web or Burst intent at a time, preventing repeated pre-delivery decisions from
turning an accepted attachment into a stale release.

## What it can and cannot answer

**Good questions for the lab** — relative, mechanical, statistical:

- Did this Reel/Burst/course change make runs longer or shorter at equal bot
  skill and course seed — overall, or warped into the late game with
  `--start-m`?
- Where do runs die (cause histogram, distance bands, mid-pull deaths)
  before vs after a change? Where do rescues get spent, and how much
  distance does a life buy — the pricing input for the planned lives system?
- Do spider profiles and upgrade levels move any measurable number? How many
  flies per kilometre does play earn — the other half of economy pricing?
- How much Reel time and energy does a run actually consume, per usage style?
- Which region and curated pattern account for a death wall, and does it remain
  when the course-order seed changes?

**Questions it must never be allowed to answer:**

- Whether the swing **feels** right — weight, responsiveness, thumb comfort,
  readability on a small screen. Owner device playtests remain the exit gate
  for feel, exactly as the GDD requires.
- Whether a challenge is *fun* rather than merely survivable.
- Anything about touch handling, GUI, haptics, frame pacing, or rendering —
  the lab runs below the adapter layer by design.

Interpretation caveats, in honesty order: the bot is one player model, not a
population; its adaptations are simple rules, not learning; and a divergence
between bot preference and owner device findings (see below) means "different
regime or bot limitation", never "the device test was wrong".

## Moving-anchor architecture probe

ADR 0004's one-off architecture mode bypasses the player model and exercises the
production rope solver directly:

```bash
godot --headless --path . --script res://tools/simulate.gd -- \
  --moving-anchor-proof
```

It first translates a support at constant velocity and compares the result with
the static solution in support-relative coordinates. It then runs the intended
slow Ruined Arboretum pivot for twenty complete five-second cycles under the
approved Balanced gravity. The command exits non-zero if translation covariance
drifts beyond 0.001, the late-cycle relative-speed envelope grows, the moving
peak exceeds the static control by more than 35%, or rope overrun exceeds the
existing elasticity/correction budget.

Measured 2026-07-31 with Godot `4.7.1.stable.official.a13da4feb`:

- maximum translation-relative error: **0.000270 px** and **0.000284 px/s**;
- moving/static peak relative-speed ratio: **1.0627**;
- late/early five-cycle peak ratio: **0.1177** (energy decays; it does not
  accumulate);
- maximum rope overrun: **17.039 px**, inside the existing allowance and capped
  correction budget.

The moving-pivot mechanic is therefore viable at the proved 38 px radius,
42-degree amplitude, and 300-tick period. Faster or larger authoring values are
not covered by this result and require rerunning the probe with their actual
specification.

## Observations (2026-07-30, bot model v2 — not human truth)

- The v1 finding that maxed-everything Garden scored *below* level 0 halves
  under the adaptive bot (≈−13% → ≈−6% mean, medians 1 289 m vs 1 191 m,
  20 runs) — most of the v1 gap was the unadapting bot, the remainder is
  consistent with longer Bursts sweeping more geometry and is within noise
  at this sample size. Worth one targeted device comparison, not a verdict.
- Both level-0 and maxed intermediate batches share an identical p90 wall at
  ≈1 571 m — one specific course challenge kills intermediate-grade play
  there. The fixed course makes such walls findable; that one is worth a
  look in the Course Lab.
- The 2.0-second Reel meter never empties under *purposeful* reeling — even
  the greedy `hold` style, which reels whenever below the route line, holds
  ~4 s per run in short bouts and never drains it. Meter pressure of the
  kind the owner wants requires lower capacity, slower regeneration, or a
  regeneration delay (the last does not exist as a gameplay parameter yet).
- Early-game runs (start 0) mildly favour *slower* reels (260 px/s scored
  best at intermediate); warped late-game runs (`--start-m=4000`) flatten
  the rate differences to noise. This diverges from the owner's device
  finding that 260 px/s was too weak — different regime, and deliberate
  height changes at speed are exactly what the bot models least. Trust the
  device on this one; the lab's contribution is that rate barely moves
  survival, so Reel speed can be tuned for feel without survival cost.
- At 4 000 m+ pace, intermediate play survives ≈350 m and burns its rescue
  almost immediately (mean spend ≈4 150 m); a life is worth ≈150–250 m
  there. Lives pricing now has its first data.

## Maintenance

`RunDriver.run()` mirrors the small per-tick orchestration
`SwingLabSession._step_once()` performs (Burst-Frenzy effect, chunk
streaming, one-rescue-then-death). If that orchestration changes shape,
update the mirror — or extract a shared driver if the duplication grows past
this handful of lines. The lab deliberately adds no third gate:
`tools/verify.py` and `bootstrap.py check --strict` remain the only two.
