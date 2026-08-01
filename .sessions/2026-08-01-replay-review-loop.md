# Replay review loop — watching what the search found

> **Status:** `complete`

## Goal

Make a run the simulation lab found watchable in the real game, so a person can
judge whether it was played fairly. No statistic can do that job; this slice
builds the path that lets the owner do it instead.

## Scope guard

Trace capture and a replay verifier in `tools/simulate.gd`; a trace catalog in
domain; a loader on `SwingLabSession`; a debug-only route to it. **No physics
values, no zone content, no tuning.** Traces award nothing and replay through
`RUN_PRACTICE`.

This is the first slice in this series to touch game code, which the previous
one deliberately did not. It is confined to a loader and a debug route.

## Previous-session review

**previous-session review:** the policy search landed and found a run reaching
4 295 m — past the owner's best recorded 3 535 m. He asked for the Trackmania-
style loop: surface the best runs so he can review them himself and rule on
whether the bot played fair or used a method a person never would. That is a
better validity check than any statistic, because an exploit is by definition
the thing nobody wrote a rule for in advance.

## What was built

**Trace capture.** `--trace-top=N --trace-dir=…` writes a batch's N furthest
runs as input traces. A trace holds no positions and no path — only *which
button, where, on which tick* — so the run is re-derived from first principles
on every replay rather than played back. If it stored the trajectory, watching
it would prove nothing.

The record shape is the game's own. `SwingLabSession` has recorded and replayed
human input since long before the lab could produce any, using
`InputCommand.to_record()` plus a `playback_tick`; the bot writes exactly that,
so **a bot's run and a recording of a human are the same kind of object** and
one replay path consumes both.

**A verifier.** `--replay=<path>` rebuilds the world from the trace's own
header, feeds the commands, and fails unless it lands on the recorded outcome.
The `expected` block exists for this: a trace that cannot be checked against its
own outcome is a story, not evidence.

**The game side.** `TraceCatalog` (domain) lists what is bundled;
`SwingLabSession.load_input_trace` reconstructs the world from the trace —
seed, start distance, upgrades, difficulty, preset — and replays it. A row on
the debug Test Run screen steps through the bundled runs, longest first, and
watches one. The screen's own distance and upgrade controls are deliberately
**not** applied: the trace names the world it was recorded in.

## It reproduces

Three traces captured from the search optimum, all verified:

```
travelled_m  expected   3335.330  got   3335.330  ok
distance_m   expected   8335.330  got   8335.330  ok
seconds      expected     41.317  got     41.317  ok
[simulate] trace REPRODUCES
```

The committed trace is a **3 335 m run in 41 s from 150 commands, 27 KB** —
close to the owner's own best of 3 535 m in 48.6 s.

## Two independent replays, on purpose

`--replay` proves a trace reproduces in the lab's minimal driver. A contract
proves it also reproduces through `SwingLabSession` — the real run state
machine, dying window and settlement path — **within one metre**. Two separate
implementations of the same fixed-step loop, and the second is the one the
owner actually watches.

The failure mode this guards is quiet: a replay fed into a slightly different
world **still plays**. It looks like a run. It is simply not the run in the
report.

## Verification

`python3 tools/verify.py --require-godot` → **exit 0**, **176 contracts**
(169 + 7 new). `python3 bootstrap.py check --strict` → **exit 0**.

Eight mutations, each run and read. All redden the specific contract; all
restore green:

| Mutation | Result |
| --- | --- |
| loader ignores the trace's course seed | 5 343 m vs 8 335 m recorded |
| loader ignores the trace's start distance | 66 m vs 8 335 m |
| loader ignores the trace's upgrade level | 5 264 m vs 8 335 m |
| loader accepts an unknown format | accepted a trace it cannot replay |
| catalog looks in the wrong directory | nothing to watch |
| catalog accepts any well-formed JSON | listed a superseded-format trace |
| export `include_filter` dropped | traces would not reach a device |
| watch route ignores the debug-tools gate | fired with Debug Tools off |

**Two mutations initially failed to redden, and both were my test's fault, not
the code's.** Rotating the course seed changed nothing because
`_next_course_seed()` returns the override anyway — a no-op dressed as a
mutation. And probing the format check with `project.godot` never reached it,
since the parse failed first; probing with the audio manifest never reached it
either, since the empty-`commands` check caught that. Only a *complete,
plausible trace from a superseded format* exercises it, so
`zz-superseded-format-fixture.json` is committed to be that.

## Owner questions

None new. OQ-9 and OQ-10 remain open.

## 💡 Idea

A mutation that does not redden is ambiguous, and the ambiguity is the useful
part: either the contract is weak or the mutation was a no-op. Both happened
here, and telling them apart took reading the code path rather than the diff. A
mutation is only evidence once you can say *which line it was supposed to
break* — otherwise "the suite stayed green" gets recorded as either "weak test"
or "sturdy code" depending on which you were hoping for.

## Next slice

**Per-upgrade fingerprints.** The search machinery now runs per configuration
and the fingerprint already reports how a run was played. Running it at L0, L10
and L20 and diffing the *behaviour* of each optimum answers the owner's
standing question — how much does each upgrade change the way the game is
played — with something better than a distance number. Each config's best run
gets bundled as a trace, so the difference can be watched rather than read.
- **📊 Model:** opus-5 · high · feature build — replay review loop
