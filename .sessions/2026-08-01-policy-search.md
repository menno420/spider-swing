# Policy search — a ceiling-finder, and a tap measurement corrected

> **Status:** `complete`

## Goal

Give the lab a search that looks for the best play its model can find, so three
questions become answerable: is a run genuinely possible, how does each upgrade
change the *way* the game is played, and does the model find loopholes worth a
human's attention.

## Scope guard

`tools/simulate.gd` gains a `--bot` policy override and a fittable/frozen knob
split; `tools/fit_bot.py` is new. **No physics values, no zone content, no
tuning, no game code.** The search reads the lab and writes JSON.

## Previous-session review

**previous-session review:** v3 closed the model's structural blind spots and
still failed five of eight acceptance targets, with route choice named as the
remaining gap. The owner then redirected: rather than a bot that imitates him,
he wants a maximiser whose best runs he reviews himself to judge whether they
were played fairly. That is a better validity check than any statistic here
could be, and it is what this slice builds toward.

## What was built

**`--bot=key:value,…`** overrides the selected tier's policy knobs, and the
hard-coded search fans became knobs (`attach_fan_top_deg`,
`attach_reach_frac`, `dive_fan_*`, …) so a search can widen, narrow or rotate
them. Parameterising the attach fan made it evenly spaced, which moves the
default very slightly — 244.8 m → 230.4 m at the warp on the pre-#86 geometry,
inside one standard error, and re-baselined rather than described as
unchanged.

**`tools/fit_bot.py`** — cross-entropy search over those knobs, stdlib only,
parallel across cores. It reports:

- **reach** — mean, median, p90, and the furthest single run. The last one is
  the "is this possible at all" number and is deliberately an observation, not
  a target; the search follows the mean, because one lucky run is noise.
- **a behavioural fingerprint** — dives per web, reel time, burst use, anchor
  classes, input rate. Two configurations reaching the same distance by
  different play is a finding that distance alone hides, and this is how the
  per-upgrade comparison will be read.
- **anomaly flags** — verb spam, abandoned verbs, input outside the owner's
  measured envelope, sudden use of anchor classes ordinary play avoids.

A new `travelled_max_m` in the lab summary backs the reach report;
`distance_max_m` is absolute course position and is meaningless for a warped
run, which the first draft of the reporter got wrong.

## First result

12 generations, population 16, at the owner's warp condition, on `main` after
PR #86. `tools/search/warp5000-l20.json` is the committed artifact.

| | default | optimum |
| --- | ---: | ---: |
| Mean travelled | 719.6 m | **1 714.6 m** (+138%) |
| Median | 651.8 m | **1 497.9 m** |
| **Furthest single run** | 1 497.4 m | **4 295.6 m** |
| Deaths per km | 2.78 | **1.17** |
| Taps per second | 5.00 | **3.49** |
| Dives per web | 0.66 | **0.96** |
| Bursts per run | 5.46 | **13.38** |
| Reel held per run | 1.97 s | **4.66 s** |

**No anomaly flags.** Two things make that credible rather than merely
unflagged: the input rate went *down* while distance more than doubled, and
the search chose a **slower** decision cadence (4 → 5.83 ticks) when it was
free to go as fast as 2. Given the option to act more often, it declined.
Speed was not the binding constraint; deliberation was.

**The furthest single run is 4 295 m — past the owner's best recorded 3 535 m.**
That is the first evidence from this lab that runs of that length at this pace
are reachable rather than exceptional, and it is the number the owner's replay
review now needs to adjudicate.

Deaths/km closed from 20× the owner's rate to **2.5×** (1.17 against 0.47).

The playstyle is legible: **far more Bursts, near one Dive per web, much longer
reel holds, a wider route-following band** (36 → 83 px) and **much longer
dives** (reach 0.55 → 0.86 of maximum web length). It tolerates a faster fall
before panicking (330 → 497) — it commits to descents instead of catching them.

### The geometry change dominates the policy change

This slice's first search ran before PR #86 and reported 245.4 m → 324.2 m.
Re-measured after that merge, the **baseline alone** moved 245.4 m → 719.6 m.
Making Bramble Canopy's openings physically playable was worth roughly three
times what the policy search was worth, and the stale numbers were replaced
rather than kept.

Two things follow. The policy gain **transfers** across a substantial geometry
change (+32% before, +138% after), so it is not overfitted to one course.
And the new geometry *rewards* good play far more than the old, which is what a
fixed traversal bug should look like.

## The correction that mattered

I froze decision cadence, reaction delay and aim error, arguing that a search
rewarded for distance would otherwise drive them to zero and hand back a reflex
machine whose ceiling proves nothing. The owner pushed back: he plays at very
high input rates, with sustained periods of near-zero gaps.

He is right, and the error was mine at the instrument. **The recordings are
native 60 fps and I sampled at 30**, de-duplicating by position so fast repeats
at one spot merged. Re-measured at full rate, counting a fresh contact whenever
a marker's area re-peaks:

| | 30 fps (published) | 60 fps (correct) |
| --- | ---: | ---: |
| Taps in run `726dcc65` | 229 | **321** |
| Run-average rate | 4.71 /s | **6.60 /s** |
| Median gap | 0.133 s | **0.067 s** |
| Gaps ≤ 50 ms | not resolvable | **27.5%** |
| Fastest 1 s / 2 s / 3 s | — | **18 / 14 / 11.7 per s** |

Some gaps are 0 ms — two markers in one frame, both thumbs.

**Average rate is not capability.** I had frozen the expert tier at 4 ticks per
decision, 15/s, which is *below* the 18/s he demonstrably sustains. The model
was capped under the player and I was citing that cap as what made its results
trustworthy.

Corrected: cadence and reaction delay are searchable down to a 2-tick (30/s)
floor — headroom over him, bounded. Aim error stays frozen, because it is
precision rather than speed and nothing in the tap stream speaks to it. The
figure is corrected in every document that carried it.

Measured immediately after: raising cadence alone makes the bot **worse**
(207 m against the 245 m default). And when the full search was later free to
choose any cadence down to the 2-tick floor, it settled on a *slower* one than
the default. Speed is not the lever; policy is. That does not contradict the
owner — he needs burst input for recoveries — but the model's route to distance
is to need fewer recoveries rather than to execute them faster.

## Verification

`python3 tools/verify.py --require-godot` → **exit 0**, 169 contracts.

`python3 bootstrap.py check --strict` → **exit 0**, findings read in full.

Behavioural checks on the new guard, each run and read:

| Attempt | Result |
| --- | --- |
| `--bot=aim_error_px:0` | refused — frozen, with the reason |
| `--bot=decision_period_ticks:1` | refused — below the 2-tick human floor |
| `--bot=decision_period_ticks:2,reaction_delay_ticks:2` | accepted, ran |
| `--bot=nonsense:1` | refused, fittable list printed |

## Owner questions

None new. OQ-9 and OQ-10 remain open.

## 💡 Idea

I published a number from an instrument I never checked the sampling rate of,
then built a design constraint on top of it, then used that constraint as the
reason the design was trustworthy. The owner caught it from *feel* — he knew
how fast he taps. Twice now on this data the correction has come from him, not
from the pipeline. **An instrument's resolution belongs in the measurement
record next to the value**, so that "4.71 taps/s" reads as "4.71, resolved to
33 ms" and its own limits are visible without anyone having to suspect them.

## Next slice

**Trace dump and replay.** `SwingLabSession` already owns recording and replay
with a stable format (`to_record` / `from_record`, seed restored first), and
the headless bot builds the same `InputCommand` objects. So the top runs can be
exported and watched **in the real game** — which is the review loop the owner
asked for and the only thing that can certify a run as fairly played. Needs
`--trace=` in the lab plus a loader on the session; the loader is game code,
which this slice deliberately did not touch.
- **📊 Model:** opus-5 · high · feature build — policy search and tap correction
