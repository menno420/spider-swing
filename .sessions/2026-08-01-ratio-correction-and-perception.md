# A ratio read without its denominator, and what the model can actually see

> **Status:** `complete`

## Goal

Answer two owner questions about the simulations — what they tell us and how
far to trust them — and correct what the answers exposed.

## Scope guard

Documentation only. No code, no measurement re-run, no tuning.

## Previous-session review

**previous-session review:** #92 landed the upgrade sweep, the first fair-play
verdict, and the external-review audit. The owner then asked how trustworthy
the simulations are, and mentioned two impressions of the runs he watched.
Both impressions turned out to be worth checking; one was my error and one was
his, and his was caused by my wording.

## The correction

I wrote that the flagged 10 773 m run **"abandoned Dive"**, from
`dives_per_attach` falling 0.96 → 0.28. The owner read that and asked how it
could possibly handle the course without diving. It cannot, and it did not:

| | endorsed | flagged |
| --- | ---: | ---: |
| Dives per run | 13.1 | **36.2** |
| Dives per second | 0.60 | 0.37 |
| Webs per second | 0.63 | **1.34** |

It dives nearly **three times as often per run**. The ratio collapsed because
its *denominator* doubled — web attaches went to 1.34 per second — not because
diving stopped. **I read a ratio without reading its denominator and described
a verb as abandoned when its absolute count had tripled.**

The genuinely unusual thing about that run is the web rate, and only that.
Corrected in the sweep measurement and in current-state.

## What the model can actually see

The owner watched the endorsed traces and read them as *"the simulation
recognized the obstacles and did its best to avoid them."* They do look like
that. Its entire perception is: own position and velocity, the fly trail, the
nearest-solid query at an aimed tap, and the HUD's own pull-safety preview.
A general path lookahead was built and deleted the same day for measuring
worse.

So the apparent *route* avoidance is **emergent from following the authored
fly trail** — a finding about the level design, not the model: the fly route
is good enough that following it competently keeps a player clear.

I first wrote this as "the bot never reads `world.obstacles`". That is true of
the bot file and **misleading about the system** — see the next section, where
the owner's follow-up question exposed it. The pull-safety preview reaches
obstacle data through another layer.

Recorded in `docs/technical/simulation-lab.md` § "What the model can actually
see", with the standing warning: **do not read planning into a replay.**

## Two more owner observations, both right, both correcting me

**"I did see the bot use reel — just less than I do, probably because I also
use it to gain a little speed."**

Both halves check out, and both correct something I had written.

*Usage.* My "the model effectively does not use the reel" came from 9 reel
presses in the 97-second flagged trace. That is true of that run (1.5% of its
duration) and false in general — the endorsed warp-L20 runs he actually
watched hold reel **21.5% of the time**. I generalised a per-configuration
number, and counted *presses* on a held control rather than time held.

*Speed.* Tested by ablating reel on the endorsed policy, held-out seeds:
**79.2 m/s with reel against 74.5 m/s without, and 1 908 m against 1 252 m.**
Reel is worth **+6.2% speed and +52% distance**. He is right, and the
repository's own phrase "speed-neutral Reel" is narrower than it reads: the
retraction step adds no velocity, but the pendulum converts it and the effect
is large. Nobody should read that phrase as "reeling does not make you
faster".

**"I spotted dives that narrowly avoided obstacles — how, if it cannot see
them?"**

Because "it cannot see obstacles" was too absolute, and this is the third
overstatement he has caught today. `preview_pull` calls
`_first_obstacle_contact`, which **sweeps the whole pull path** in half-radius
steps. So the model has real obstacle awareness with an exact shape:

- along a **candidate pull only** — never anywhere else;
- **skill-gated** by `care` (0.40 novice → 0.95 expert);
- `_find_dive_tap` **rejects every candidate whose swept path is blocked** and
  takes the best of what survives.

So a Dive threading a gap is a genuine selection among candidate paths by
clearance — not planning, but not luck either. What is missing sits between
the two things it does have: it checks the *pulls* it might commit and follows
the *trail* for where to go, and nothing checks the **swing** it is about to
take. That is where 95% of its deaths come from.

## The trust answer, as given

- **Trust** comparisons holding one policy constant across configurations —
  confounds cancel, and that is where the upgrade findings come from.
- **Do not trust** absolute difficulty numbers, or anything about the reel.
  That gap is now vivid rather than abstract: the bundled 97-second,
  640-command trace contains **9 reel presses**, against an owner who taps
  reel about once a second and empties the meter repeatedly at L0.
- **Undecided** until watched: anything from the flagged web-spam policy.

## Verification

`python3 tools/verify.py --require-godot` → exit 0, 181 contracts.
`python3 bootstrap.py check --strict` → exit 0. Documentation only.

## Owner questions

None new.

## 💡 Idea

Every error today was the same error at different scales. Comparing
best-per-configuration searches let *search luck* masquerade as an upgrade
effect; quoting `dives_per_attach` let a *denominator change* masquerade as a
verb being abandoned. In both cases a normalised number was reported as if it
were an observation. **A ratio is a claim about two things; state both, or
state the absolute count.** The near-miss reporting added earlier has the same
shape and the same fix.

The perception overstatements are a variant: "it never reads
`world.obstacles`" was *literally true of the bot file* and false about the
system, because the obstacle knowledge arrives through a query into another
layer. **A negative claim about a component is not a negative claim about what
it can learn.** Three of my summary sentences today were technically
defensible and practically misleading, and in all three cases the owner caught
it by comparing them against what he had watched. Watching beats reading, and
he is the only one doing it.

## Next slice

Unchanged: the owner's judgement on
`lab-flagged-webspam-standing-l20.json`. His observation that the endorsed
runs read as genuine play — and the correction that the flagged run dives
*more*, not less — makes "legitimate high-frequency style" a live possibility
rather than the exploit I framed it as.
- **📊 Model:** opus-5 · high · docs-only — ratio correction and perception note
