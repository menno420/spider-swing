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
| `--start-m=N` | 0 | Warp the start N metres into the course at that distance's pace — tests late-game regimes without surviving to them. Every per-km rate normalizes on distance *travelled*, so a warped band stays comparable with an unwarped one |
| `--reel-style=` | `adaptive` | `adaptive` · `tap` · `hold` — how the bot spends Reel |
| `--save-bursts=` | `on` | `on` · `off` — emergency Burst when no web can save it |
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
checkpoint practice.

**Rates normalize on ground travelled.** Every row carries `start_m` and
`travelled_m` (`distance_m - start_m`), and every per-kilometre summary rate
divides by travelled kilometres rather than absolute course position. Warping
to 10 000 m and dying 380 m later is 380 m of exposure, not 10 380 m of it;
before this, a warped batch's `flies_per_km` was understated by the warp ratio
(0.9/km reported where the true rate was 24.2/km). Summaries also report
`deaths_per_km` — counting the rescued death as well as the terminal one —
with its Poisson standard error `deaths_per_km_se`, so a later comparison can
tell a real shift from sample size. At `--start-m=0` travelled distance equals
absolute distance, so unwarped numbers are unchanged.

## Measuring the difficulty curve

`tools/difficulty_curve.py` drives the lab once per distance band across every
skill tier and renders the deaths-per-km, survival, death-cause and
resource-pressure tables:

```bash
python3 tools/difficulty_curve.py --runs=40 --course-seeds=8 \
  --bands=0,5000,10000,15000,20000 --out=docs/measurements/<date>-curve.md
```

It finds Godot the same way `tools/verify.py` does and asserts nothing. The
committed baseline is
[`docs/measurements/2026-08-01-difficulty-curve.md`](../measurements/2026-08-01-difficulty-curve.md);
re-measure and diff against it rather than treating those numbers as permanent. The delayed command queue also permits only one pending
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
