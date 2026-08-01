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

### What else fails to discriminate — measured, not assumed

Before proposing a fix it is worth knowing which axes are dead ends. Each of
these was measured across the two styles:

| axis | swinging | hauling | discriminates? |
| --- | ---: | ---: | --- |
| Ground speed | 79.1 m/s | 59.0 m/s | **no** — both sit on their own pace-curve target |
| Mean height | 385 px | 405 px | **no** — same band |
| Vertical span | 432 px | 423 px | **no** — same band |
| Web angle | 15.3° | 12.5° | no |
| Web length | 382 px | 377 px | no |
| **Arc per web** | **59.9°** | **21.3°** | **yes — 2.8×** |
| **Attach rate** | **0.63/s** | **1.34/s** | **yes — 2.1×** |

The height result specifically refutes an attractive idea: *"hauling hugs the
ceiling, so threaten the ceiling."* It does not. Both styles use the same
vertical band, so a predator patrolling the top cannot tell them apart either.

### The structural reason, and what it rules out

Hauling works because **the pace curve makes forward motion free.**
`SpiderMotor` drives horizontal velocity toward target whether you swing or
not, so the web is never needed for *propulsion* — only as fall-arrest. Once
that is true, swinging is optional, and a style that uses the web purely to
avoid falling is strictly less work.

The corollary matters more than the diagnosis: **any penalty denominated in
speed washes out**, because the drive restores it within about a second. That
disqualifies, together:

- a speed-based chaser;
- momentum-on-release scaled by arc (my own earlier first choice — it
  penalises exit speed, which the drive refunds);
- an angle-dependent attach catch (same objection).

A fix has to act on something the drive does not refund.

## What the axis actually is

The two styles differ by **a factor of 2.8 in arc per web** and a factor of
2.1 in attach rate, while differing by 1.25× in speed. Any fix should act on
the axis that separates them.

Three candidates, in the order worth trying. All are physics changes to an
owner-approved baseline, so all are his call and all need a device playtest —
none are implemented.

**1. Silk as a per-web cost (preferred).** Each attach spends from a finite
silk pool that refills over time. At 0.63 attaches/s it sustains; at 1.34/s it
does not. This caps **attach rate** — one of the only two discriminating axes —
in a currency the horizontal drive cannot refund.

It is also the most thematically honest option in the game: a spider's silk is
finite, the game is named for it, and the two upgrade tracks that currently
buy relief on a meter the owner only strains at L0 (Silk Reserve, Rapid
Recovery) would gain a second and much more legible job. It makes the resource
the *web* budget, not only the *reel* budget.

**2. Spent anchors, generalised (good companion).** The simulation already
marks rotten and collapsing anchors spent via `_spent_anchor_sources`. Extend
it: any anchor becomes unusable for a short window after release. Ratcheting
in place stops working, and reaching a *fresh* anchor requires carrying
momentum forward — which is a swing. Reuses machinery that already exists and
is already tested.

**3. Momentum-on-release scaled by arc.** Attractive and probably too weak on
its own — see the structural note above: the drive refunds exit speed. Worth
keeping as *flavour* on top of 1 or 2, where it rewards the intended style
without being the thing that enforces it.

**4. Re-attach refractory window.** Blunt, and it directly conflicts with the
fast recoveries the owner values — he sustains 18 taps/s when recovering.
Listed for completeness; I would not start here. Note that option 2 achieves
the same end without punishing a recovery aimed at a *different* anchor.

## The owner's proposal, tested — it works, and it is a package

On seeing the above the owner proposed two changes together: **remove the free
forward drive so only swinging propels you**, and **add the bird at a rate
slightly below the pace the game currently forces**, accelerating slowly, so
reel becomes a speed tool and Burst/Dive become escapes. Then: *"I am mostly
going faster than the forced speed, so the forced speed is basically useless."*

Both halves check out, and the second explains the first.

### The drive is the exploit's engine, and nothing to a swinger

Measured at one matched configuration (standing, L20, intermediate). "Own
speed" is mean `velocity.x − target_speed_at(distance)` — how far the run
travels above the speed the drive hands it for free.

| policy | distance | own speed | above the floor | arc per web |
| --- | ---: | ---: | ---: | ---: |
| endorsed — swinging | 3 157 m | **+3.6 m/s** | **53%** | 59.8° |
| default — swinging | 1 786 m | **+7.6 m/s** | **60%** | 42.8° |
| **flagged — hauling** | 5 051 m | **−5.0 m/s** | **21%** | 21.3° |

**Swinging generates its own speed; hauling is carried.** The owner's read of
his own play is correct and is a property of the *style*, not of him.

Ablating the drive confirms it end to end:

| policy | full drive | **no drive** | change |
| --- | ---: | ---: | ---: |
| hauling (the exploit) | 4 179 m | **78 m** | **−98%** |
| default (swings) | 1 720 m | 1 147 m | −33% |

**A near-perfect targeted fix.** It costs the intended style a third and
destroys the unintended one outright — because the drive was not helping
hauling, it *was* hauling's engine.

### Why this makes the other proposals work

Three mechanics that are individually weak become sound once the drive is
gone, and this document previously dismissed two of them for a reason that
stops applying:

- **A speed-based chaser** cannot discriminate today because the pace curve
  pins everyone. Remove the curve and speed becomes a real signal of skill,
  so the bird can pace the game honestly.
- **Arc-scaled release momentum** was dismissed above as something the drive
  refunds within a second. With no drive there is nothing to refund it, so a
  bonus for a well-swung release becomes the game's actual propulsion reward
  rather than decoration. **That earlier dismissal was correct in isolation
  and wrong about the package.**
- **Reel as a speed tool** is already real and already measured: ablating reel
  costs 6.2% speed and 52% distance. Making it the deliberate accelerator
  formalises something the physics already does.

Burst and Dive gain a defensive job — escaping a closing bird — which they
currently lack entirely; they are used opportunistically for traversal only.

The proposals are **mutually enabling**, which is why evaluating them one at a
time produced two wrong verdicts here.

### The open risk, stated plainly

Without the drive the bot manages roughly **13 m/s** against the current
55–76 m/s pace. That is a floor, not a ceiling, for two reasons: the policy
was optimised for a world with a drive, and more importantly **the model
cannot pump.** Its reel policy is height-based, not swing-phase-based, so it
cannot add energy at the bottom of an arc — the single skill the proposal
makes central.

The physics do allow the pace: a 380 px web swung from horizontal reaches
`sqrt(2gL)` = **92 m/s** at the bottom. Sustaining that requires putting
energy back in every arc, which is exactly what pumping is.

**So the bird cannot be tuned from bot numbers.** Its speed has to come from a
device playtest of the no-drive build, because the only evidence that matters
is what a pumping human can sustain, and no measurement here can produce it.

## How the bird earns its place

Not as the anti-hauling mechanic — measurement rules that out on both speed
and height. It earns its place on experience, and one of those reasons is
better than the rest.

**It makes an invisible system visible.** The pace curve already pins the
player's speed and already escalates with distance, and *nothing on screen
says so*. A closing predator does not create pressure; it **reveals pressure
that already exists**, and turns a silent tuning curve into something felt.
That alone justifies it.

**Failure gets a face.** Every run currently ends against geometry. A second,
legible failure mode with an antagonist gives runs different endings and a
villain, which a distance counter cannot.

**It gives the rescue a cost.** The rescue life is currently close to free —
it returns the player upstream and the run continues. If losing ground means
the bird closes, the rescue becomes a *comeback arc* instead of a rewind, and
the owner's recorded stabilise-then-run pattern becomes a deliberate, visible
gamble rather than an invisible one.

**It fits the identity work.** Birds are the spider's actual predator, and the
project already maintains `docs/product/spider-biology-folio.md`. This is
identity, not only mechanics.

### The form it should take

**Position-based, not speed-based.** A chaser advancing at a steady world rate
means banked distance is a buffer, so the brief stabilising passages the
recordings show as correct play survive. A speed floor kills them.

**It needs a reason to vary.** If it advances at a constant rate against a
speed the pace curve already pins, the outcome is deterministic and therefore
dull — always escapable, or never. The cleanest source of variance is the one
above: **the bird closes when ground is lost**, and ground is lost mainly by
dying into the rescue. That couples it to the one existing mechanic that
currently has no downside.

## The lab is now an exploit regression test

`arc per web`, `near-vertical share`, `mean web angle` and `mean web length`
are reported for every batch. That means any candidate fix can be tested the
hard way: **apply it, re-run the search, and see whether the hauling policy
still wins.** A fix that merely makes hauling awkward will be re-discovered by
the search within a few generations; a fix that makes it unprofitable will
show up as the optimum's arc per web climbing back toward the endorsed 58.9°.

That is a much stronger test than "it looks better now", and it exists because
the owner watched a replay and named what he saw.
