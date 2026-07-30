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
| `--preset=` | `balanced_candidate` | Named `SwingConfig` preset |
| `--upgrades=N` | 0 | Level 0–20 applied to every track of the spider |
| `--seed=N` | 1 | Base seed for the bot-imperfection RNG |
| `--max-seconds=S` | 240 | Simulated-time cap; a capped run reports `timeout` (alive), never a death |
| `--json=path` | — | Write per-run rows + summaries as JSON |

## The player model

The bot reads only what a player could: its own motion, the fly trail (the
game's authored route language), and solid geometry through the same
`nearest_solid_point` forgiveness a real tap receives. It attaches up-forward
webs when falling or below the route, releases on the rising swing, reels in
short corrective holds when below the route line, and occasionally Bursts.
Skill tiers vary only human-imperfection parameters:

| Tier | Decision cadence | Reaction delay | Aim error σ |
| --- | --- | --- | --- |
| novice | 10 ticks | 9 ticks (+0–2 jitter) | 46 px |
| intermediate | 7 ticks | 6 ticks (+0–2 jitter) | 26 px |
| expert | 4 ticks | 3 ticks (+0–2 jitter) | 10 px |

The course is deterministic and identical every run; **all** run-to-run
variation comes from the seeded imperfection model. Identical world, a
distribution of player behaviour: a tuning change shifts the metrics, not the
luck. The same seed and options always reproduce the same batch bit-for-bit.

## What it can and cannot answer

**Good questions for the lab** — relative, mechanical, statistical:

- Did this Reel/Burst/course change make runs longer or shorter at equal
  bot skill?
- Where do runs die (cause histogram, distance bands) before vs after a
  change? Does a new pattern band spike deaths?
- Do spider profiles actually differentiate outcomes? Does an upgrade level
  move any measurable number?
- How often does the Reel meter empty under a given usage style?

**Questions it must never be allowed to answer:**

- Whether the swing **feels** right — weight, responsiveness, thumb comfort,
  readability on a small screen. Owner device playtests remain the exit gate
  for feel, exactly as the GDD requires.
- Whether a challenge is *fun* rather than merely survivable.
- Anything about touch handling, GUI, haptics, frame pacing, or rendering —
  the lab runs below the adapter layer by design.

A known interpretation caveat: the bot never adapts its style to the
configuration it is given. A human with a faster Reel changes how they play;
the bot just reels the same corrective way, faster. Treat "maxed upgrades
scored lower" as "this tuning punishes an unadapted style", not "upgrades are
bad".

## First observations (2026-07-30, bot model v1 — not human truth)

- Distance scales cleanly with bot skill (Garden, level 0: ≈560 m novice /
  ≈1 260 m intermediate / ≈1 830 m expert mean over 20 runs), and even the
  expert bot's deaths concentrate in the post-1 000 m pattern bands.
- Springtail's impact shell eliminated rail deaths outright in its batch
  (15/15 deaths were obstacles; every other spider mixes in boundary deaths).
  The identity mechanic is visible in pure statistics.
- The 2.0-second Reel meter never emptied under corrective-style reeling at
  any tier. Silk Reserve's value is invisible to that style; only sustained
  held reeling drains it. Worth one targeted device look.
- Maxed-everything Garden scored slightly *below* level 0 for the unadapting
  intermediate bot (longer Bursts reach further and its pull path sweeps into
  geometry more often) — see the caveat above before reading this as a
  balance verdict.

## Maintenance

`RunDriver.run()` mirrors the small per-tick orchestration
`SwingLabSession._step_once()` performs (Burst-Frenzy effect, chunk
streaming, one-rescue-then-death). If that orchestration changes shape,
update the mirror — or extract a shared driver if the duplication grows past
this handful of lines. The lab deliberately adds no third gate:
`tools/verify.py` and `bootstrap.py check --strict` remain the only two.
