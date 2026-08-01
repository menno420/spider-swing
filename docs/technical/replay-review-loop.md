# The replay review loop

> **Status:** `reference`
>
> How a run found by the simulation lab gets in front of a human to be judged,
> and why the loop is shaped this way. Read
> [`simulation-lab.md`](simulation-lab.md) first for what the lab is; this
> document is about the part where a person decides whether to believe it.

## The problem it solves

A search rewarded for distance will use whatever the physics allows. That is
the point — an exploit found in the lab is a balance bug found before a player
finds it — but it means **no statistic separates "played well" from "found a
loophole."** Anomaly flags help; they cannot decide. Every automatic check is
a rule someone wrote in advance, and an exploit is by definition the thing
nobody wrote a rule for.

So the last step is a person watching the run. Everything here exists to make
that step possible and to make sure that what is watched is *the run that was
reported* — not something that merely resembles it.

## The chain

```
tools/fit_bot.py            search over policy knobs
        │                   (see simulation-lab.md)
        ▼
tools/simulate.gd           runs the batch; --trace-top writes the N best runs
        │  --trace-dir
        ▼
assets/runtime/traces/*.json    the trace: a world header + a list of taps
        │
        ├──▶ tools/simulate.gd --replay=<path>     re-runs it headlessly and
        │                                          fails unless it lands on its
        │                                          own recorded outcome
        │
        └──▶ TraceCatalog ──▶ Test Run screen ──▶ SwingLabSession
                                                  .load_input_trace()
                                                          │
                                                          ▼
                                                  you watch it, at speed,
                                                  with the real HUD
```

## Why a trace is just taps

A trace holds no positions, no velocities, no path. It holds **the input**:
which button, where on screen, on which tick. Everything else is recomputed by
the same deterministic simulation the game runs.

That is what makes the review meaningful. If a trace stored the trajectory,
watching it would prove nothing — you would be watching a recording. Because it
stores only input, the run you watch is *re-derived* from first principles
every time, and any divergence between what the lab reported and what you see
is a real disagreement rather than a playback artifact.

It is also why the format is the game's own. `SwingLabSession` has recorded and
replayed human input since long before the lab could produce any, using
`InputCommand.to_record()` plus a `playback_tick`. The bot writes exactly that
shape, so **a bot's run and a recording of a human are the same kind of
object** and the same replay path consumes both. No second implementation to
drift.

## What a trace contains

```jsonc
{
  "format": "spider-swing-input-trace@1",
  "setup": {            // everything needed to rebuild the identical world
    "preset": "balanced_baseline", "spider": "classic", "skill": "expert",
    "upgrades": 20, "difficulty": "standard", "start_m": 5000,
    "course_seed": 1342, "bot_seed": 12, "bot": "<policy knobs>"
  },
  "expected": {         // what the run did, so the trace can be checked
    "travelled_m": 3335.33, "distance_m": 8335.33,
    "seconds": 41.32, "cause": "obstacle", "deaths": 2, "flies": 57
  },
  "commands": [ { "kind": 0, "target_x": …, "playback_tick": 41 }, … ]
}
```

`expected` is the load-bearing part. **A trace that cannot be checked against
its own outcome is a story, not evidence.** Both replay paths compare against
it and refuse to claim success without a match.

## Two independent replays, on purpose

| | `--replay=<path>` | The game |
| --- | --- | --- |
| Runs | `tools/simulate.gd`'s minimal driver | `SwingLabSession` |
| Has | course streaming, rescue, effects — the lab's own mirror of them | the real run state machine, dying window, settlement path, presentation |
| Proves | the trace reproduces where it was produced | the trace reproduces where it is *watched* |

They are separate implementations of the same fixed-step loop, and the second
one is what the owner actually sees. A contract replays the committed trace
through `SwingLabSession` and requires it to land **within one metre** of the
recorded distance — deliberately tight, because a loose tolerance would hide
exactly the drift the contract exists to catch.

That contract has been falsified four ways. Each of these makes it fail:

| Break | Result |
| --- | --- |
| loader ignores the trace's course seed | 5 343 m against 8 335 m recorded |
| loader ignores the trace's start distance | 66 m against 8 335 m |
| loader ignores the trace's upgrade level | 5 264 m against 8 335 m |
| loader accepts an unknown format | accepted a trace it cannot replay |

The failure mode being guarded is specific and quiet: a replay fed into a
slightly different world **still plays**. It looks like a run. It is simply not
the run in the report, and without the contract nobody would ever know.

## Watching one

Enable Debug Tools → **HOME → DEBUG TEST RUN** → the row beneath the two setup
cards, *OR WATCH A RECORDED LAB RUN*. `‹` and `›` step through what is bundled,
longest run first. `WATCH THIS RUN` replays it.

The staged distance and upgrade controls on that screen are deliberately **not**
applied — the trace names the world it was recorded in, and letting the screen
override that would replay a different run under the reported run's name. Runs
loaded this way go through `RUN_PRACTICE` and inherit the whole
no-awards/no-records policy, like any other debug run.

## What to look for while watching

The question is not "was it good" — the search already established that. It is
**"would a person do that, and could they?"** Specifically:

- **Input that no hand produces.** The reported `taps_per_second` is compared
  against the owner's measured envelope (6.60/s across a run, 18/s sustained at
  peak — see the calibration document), but a rate inside the envelope can
  still be distributed impossibly. Watching shows the distribution.
- **Anchors chosen at the edge of legality** — repeatedly attaching at exactly
  the maximum web length, or to geometry a player would not read as a surface.
- **One verb carrying the run.** Verb spam is the commonest shape of an
  exploit, and the fingerprint flags it, but the flag has a threshold and the
  eye does not.
- **Geometry doing something unintended** — passing through an opening that
  looks closed, riding a hazard, surviving a contact that should end the run.

A run that survives that reading is evidence about the game. One that does not
is a bug report, which is just as valuable and arrives before a player finds it.

## Adding traces

```bash
# capture the 3 best runs of a batch
godot --headless --path . --script res://tools/simulate.gd -- \
  --runs=24 --skill=expert --start-m=5000 --upgrades=20 \
  --trace-top=3 --trace-dir=/tmp/traces

# check each one reproduces before trusting it
godot --headless --path . --script res://tools/simulate.gd -- \
  --replay=/tmp/traces/run-01-3335m.json
```

Copy a verified trace into `assets/runtime/traces/` to bundle it. Two things
are easy to get wrong:

- Traces are **plain JSON, not Godot resources**, so `export_filter=all_resources`
  does not carry them into an APK. `export_presets.cfg` needs an
  `include_filter` covering them, and a contract asserts it does — otherwise
  the feature works on a desktop checkout and silently offers nothing on the
  device where runs are actually watched.
- A trace from a superseded format must be **skipped by the catalog**, not
  listed and then refused. `zz-superseded-format-fixture.json` is committed
  precisely so that rule has something real to be tested against; after a
  format bump, every old trace looks like it.

## Bumping the format

`TraceCatalog.INPUT_TRACE_FORMAT` is the single definition, in `domain`;
the producer (`tools/simulate.gd`) and the consumer (`SwingLabSession`) both
reference it and neither carries its own copy. Change the record shape → bump
that one constant → old traces are refused rather than replayed into a world
they were never recorded in.
