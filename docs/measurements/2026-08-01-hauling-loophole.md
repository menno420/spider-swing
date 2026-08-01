# The hauling loophole, and why a speed chaser will not fix it — 2026-08-01

> **Status:** `reference`
>
> The owner watched the lab's best run (10 773 m) in game and called it a
> loophole: *"instead of swinging it basically keeps the web exactly above
> itself the whole time… the game really isn't meant to be played like this."*
>
> **He is right, and the exploit is now measured.** But the fix he proposed —
> a chasing predator enforcing a minimum speed — **cannot separate hauling from
> swinging in principle**, because `SpiderMotor` drives horizontal velocity
> toward the pace curve and has already equalised ground speed across styles.
> This document exists so that design decision is made on numbers.

## The exploit, measured

The lab now records swing shape per run. `arc per web` is the angular sweep
between attach and release; `near-vertical` is the share of hanging time
within 20° of straight down.

| policy | web angle | web length | **arc per web** | near-vertical | attaches/s |
| --- | ---: | ---: | ---: | ---: | ---: |
| **endorsed** (owner: *"matches my playstyle"*) | 15.2° | 381 px | **58.9°** | 69% | 0.63 |
| **flagged** (owner: *"one of the loopholes"*) | 12.5° | 376 px | **21.4°** | 80% | **1.34** |
| default control | 17.5° | 418 px | 41.6° | 63% | — |

**The discriminator is arc per web, and only that.** The exploit sweeps a
third of the endorsed arc while attaching twice as often. Web *angle* and web
*length* barely differ — 12.5° against 15.2°, 376 px against 381 px — because
each attach is so brief it never travels far from vertical. Anyone hunting
this signature on "is the web vertical" would miss it; the giveaway is that
the web never *goes* anywhere.

Plainly: it is not swinging, it is **hauling** — attach nearly overhead, get
dragged a short way, release, repeat, better than once a second.

## Why the bird will not catch it

The proposal is sound as a genre mechanic and the owner's read that it "felt
really slow" is correct in direction. The magnitude is not:

| | speed |
| --- | ---: |
| Endorsed policy | 79.1 m/s |
| **Flagged policy** | **59.0 m/s** — 25% slower, not 3× |

(Both figures come from the simulation, not from video, so playback speed does
not touch them.)

It *looks* far slower than 25% because the motion is low-amplitude and
repetitive: small ratcheting arcs under the ceiling read as slow even when the
camera is moving at a decent clip. **And the owner watched those clips at 2×
playback** — so the real thing is twice as slow to watch as the impression he
formed, which makes his read an understatement rather than an exaggeration.

That perceptual gap is real and worth designing for. But a chaser is tuned in
metres per second, and the next section is why that will not work.

### The real reason, which is stronger: the game pins ground speed

An earlier draft argued this from the owner's `17dd734b` averaging 44.7 m/s —
slower than the exploit. **That figure was wrong.** It is net progress divided
by duration on a run that spent its rescue, and the rescue returns the player
*upstream*; it was never a speed. It is also below the pace curve's own floor
for that distance range (76.0 m/s), which is impossible to sustain — a number
that cannot happen is a clue the statistic is wrong, not the player.

The correct argument does not need his recordings at all. `SpiderMotor`
**drives** horizontal velocity toward `target_speed_at(distance)` whenever the
player is below it. Ground speed is therefore pinned near the pace curve for
*everybody*, whatever their style:

| | distance range | mean target | observed |
| --- | --- | ---: | ---: |
| **exploit** | 0 – 5 310 m | 57.2 m/s | **59.0 m/s** |
| owner `726dcc65` | 5 020 – 8 555 m | 76.0 m/s | 78.6 m/s |

**The exploit is not dawdling — it is travelling at the speed the game sets
for where it is.** It reads as 25% slower than the endorsed policy only
because that policy runs at 5 000 m+, where the curve is already at its 76 m/s
ceiling, while the exploit spends most of its run in the low-target early
course.

So a speed-based chaser cannot separate playstyles **in principle**: the pace
curve has already equalised the thing it would measure. The only speed
variance between styles is the swing gain on top of the drive, and that is
small compared to the curve itself.

A position-based chaser (constant world rate, so distance banked is a buffer)
remains the right *form* if a chaser ships — it forgives the brief stabilising
passages the recordings show are correct play. It simply cannot be the
anti-hauling mechanic, because at any given distance hauling and swinging move
at the same speed.

## What the axis actually is

The two styles differ by **a factor of 2.8 in arc per web** and a factor of
2.1 in attach rate, while differing by 1.25× in speed. Any fix should act on
the axis that separates them.

Three candidates, in the order worth trying. All are physics changes to an
owner-approved baseline, so all are his call and all need a device playtest —
none are implemented.

**1. Reward the arc (positive, preferred).** Momentum preserved on release
scales with the arc swept since attach. A wide swing exits faster than a short
haul. This *extends* the project's existing principle — "momentum preservation
on release is the core skill" — rather than bolting on a punisher, and it
makes swinging the profitable choice instead of the mandatory one.

**2. Angle-dependent attach catch.** `attachment_catch_fraction` is a flat
0.08 today. Scale it with how vertical the new web is: catching a rope
directly overhead while moving horizontally should cost more than swinging
into one placed ahead. Physically motivated, and it taxes the exploit's
signature move specifically.

**3. Re-attach refractory window.** A brief lockout after release. Blunt, and
it directly conflicts with the fast recoveries the owner values — he sustains
18 taps/s when recovering. Listed for completeness; I would not start here.

## The bird still earns its place

Nothing above argues against the predator. It solves a *different* and real
problem — pacing pressure, tension, and a reason not to dawdle — and it fits
the fiction. It simply is not this exploit's fix, and tuning it to be one is
what this document exists to prevent.

If it ships, the position-based form (a chaser that advances at a steady world
rate, so distance banked is a buffer) preserves the stabilise-then-run pattern
the recordings show is correct play. A pure speed floor does not.

## The lab is now an exploit regression test

`arc per web`, `near-vertical share`, `mean web angle` and `mean web length`
are reported for every batch. That means any candidate fix can be tested the
hard way: **apply it, re-run the search, and see whether the hauling policy
still wins.** A fix that merely makes hauling awkward will be re-discovered by
the search within a few generations; a fix that makes it unprofitable will
show up as the optimum's arc per web climbing back toward the endorsed 58.9°.

That is a much stronger test than "it looks better now", and it exists because
the owner watched a replay and named what he saw.
