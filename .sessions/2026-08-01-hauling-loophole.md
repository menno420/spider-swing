# The first confirmed exploit, and a design fix that would not have worked

> **Status:** `complete`

## Goal

Review the owner's recordings of the flagged 10 773 m run, verify his call
that it is a loophole, and evaluate his proposed fix — a chasing predator
enforcing a minimum speed.

## Scope guard

Swing-shape instrumentation in `tools/simulate.gd` and a measurement
document. **No physics values changed** — every candidate fix is an owner call
on an approved baseline and none is implemented.

## Previous-session review

**previous-session review:** the replay loop shipped, the owner endorsed two
warp-L20 runs as fair, and the flagged standing-L20 run was bundled awaiting
judgement. He judged it.

## The verdict, confirmed and measured

> *"Instead of swinging it basically keeps the web exactly above itself the
> whole time… the game really isn't meant to be played like this."*

Correct. The lab now records swing shape, and the exploit has a clean
signature:

| policy | arc per web | near-vertical | attaches/s |
| --- | ---: | ---: | ---: |
| endorsed | **58.9°** | 69% | 0.63 |
| flagged | **21.4°** | 80% | **1.34** |

**Arc per web is the whole discriminator.** Web angle (12.5° vs 15.2°) and
length (376 px vs 381 px) barely differ, because each attach is so brief the
web never travels far from vertical. Hunting "is the web vertical" would miss
it entirely; the giveaway is that the web never *goes* anywhere. It is
hauling, not swinging.

**This is the replay loop's whole purpose discharged.** No statistic proposed
this; a person watched a replay and named it, and the measurement followed.

## Why his proposed fix would have misfired

The bird is a good genre mechanic and his "it felt really slow" read is
directionally right. The magnitude is not: **59.0 m/s against the endorsed
79.1 — 25% slower, not 3×.** It *looks* far slower because the motion is
low-amplitude and repetitive, which is a real perceptual effect and not a
tunable one.

The decisive number: his own `17dd734b` averages **44.7 m/s**, slower than the
exploit, and spends its first 20 seconds at **16 m/s** stabilising — a passage
the calibration document already records as correct play.

| bird speed | catches exploit | catches his slowest run |
| ---: | --- | --- |
| 50–59 m/s | no | yes |
| 65–70 m/s | yes | yes |

**No setting separates them.** Had this shipped tuned to kill hauling, it
would have killed his stabilise-then-run pattern first.

## What was proposed instead

Act on the axis that actually separates the styles — a 2.8× difference in arc
against a 1.25× difference in speed. Preferred: **momentum on release scales
with arc swept**, which extends the project's existing "momentum preservation
is the core skill" principle rather than adding a punisher. Alternative:
scale `attachment_catch_fraction` by how vertical the new web is. Both are
owner calls needing device playtest; neither is implemented.

The bird keeps its place for pacing and tension — in position-based form, so
banked distance is a buffer and brief slow passages survive.

## Verification

`python3 tools/verify.py --require-godot` → exit 0, 181 contracts.
`python3 bootstrap.py check --strict` → exit 0.
Swing-shape metrics measured across three policies on held-out seeds.

## Owner questions

**New — OQ-12:** which anti-hauling mechanic to adopt, if any. Recorded with
the two candidates and the evidence; work proceeds under "none, pending the
owner's pick", since the exploit is a lab finding and not yet player-facing.

## 💡 Idea

The exploit and the proposed cure differed on *different axes*, and only
measuring both showed it. "It felt slow" was a true observation about
amplitude that would have been implemented as a rule about velocity — and the
velocities overlap. **When a fix is proposed for an observed problem, measure
the axis the fix acts on before building it**, because a correct perception
can still name the wrong variable. The bird would have shipped, felt
reasonable, and quietly punished the owner's own best habit.

## Next slice

The lab is now an exploit regression test: apply a candidate fix, re-run the
search, and check whether hauling still wins. A fix that merely makes it
awkward will be re-discovered within a few generations; a fix that makes it
unprofitable shows up as the optimum's arc climbing back toward 58.9°. That
loop is worth running before any anti-hauling mechanic reaches a device.
- **📊 Model:** opus-5 · high · research — hauling loophole and chaser analysis
