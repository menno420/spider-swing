# The model's real gap is recovery, not route choice — 2026-08-01

> **Status:** `reference`
>
> **88–100% of the model's deaths happen with an unused escape in hand.**
> It is not choosing bad routes. It is failing to *recover* from routes that
> went wrong — the exact thing the owner describes doing with Dive and Burst.
>
> This supersedes the "route choice" diagnosis in
> `2026-08-01-bot-model-v3.md`, which named the right symptom and the wrong
> cause.

## What prompted it

The owner, on why Dive and Burst matter to him:

> *"An actual person would make mistakes and sometimes end up at a point that
> it didn't plan to get, like high up right before a hanging obstacle, or it
> would be low and then suddenly an obstacle appears it didn't count on…
> that made dive and burst very valuable. But I also try to use them as help
> for reaching my planned path."*

Two distinct jobs: **recovery from an unplanned state**, and **assistance
toward a planned one**. The model does the second and never the first. The
question was whether that costs it anything measurable.

## It costs it nearly everything

At the moment of death, per policy, held-out seeds:

| policy | held a Burst | held a Dive | **held either** | was on a web |
| --- | ---: | ---: | ---: | ---: |
| endorsed (owner-approved) | 75% | 50% | **88%** | 25% |
| flagged (hauling) | 88% | 96% | **100%** | 42% |
| default control | 100% | 96% | **100%** | 42% |

**Between 88% and 100% of deaths occur with an escape available and unspent.**
Most happen while *detached* — 58–75% were not even on a web, i.e. in flight
toward the thing that killed them, holding a tool that could have changed the
outcome.

And the model's explicit panic path — `_find_emergency_tap`, counted as
`save_bursts` — fires **0.00 times per run in every policy at every
configuration measured**. The bot never panics, because nothing in it ever
notices that it should.

## Why this reframes the whole diagnosis

`2026-08-01-bot-model-v3.md` concluded the remaining gap was **route choice**:
"which anchor to take so that the swing that follows clears what is coming."
That reading has been carried forward all day, and it is wrong — or at least
badly incomplete.

The evidence against it is that the tools were *there*. A route-choice failure
looks like arriving somewhere with no options. This looks like arriving
somewhere with options and not taking them. The model does not lack a plan;
**it lacks a response to the plan failing.**

That also explains a pairing that never quite fit:

- Its dives are *screened* — `_find_dive_tap` rejects every candidate whose
  swept path is blocked, which is genuine obstacle awareness.
- Yet 95% of its deaths are obstacle collisions.

Both are true because the screen only runs on pulls the model was **already
choosing to make**. Nothing ever asks "I am about to hit something, what do I
still have?" The awareness is attached to intention, not to danger.

## Why the owner's account is the key to it

An escape verb is only valuable in proportion to how often you end up
somewhere you did not intend. The model demonstrates the contrapositive
perfectly: it never *knowingly* gets into trouble, so its dives are traversal
moves that happen to be safe, and its escape statistics read as traversal
statistics.

The owner gets surprised — a hanging obstacle above him, one appearing while
he is low — and those moments are where the verbs earn their place. **The
model gets surprised just as often** (95% obstacle deaths prove it) **and has
no repertoire for the moment after.**

So "the bot plays differently" is not a matter of taste or tuning here. It is
missing one specific loop: *notice the trouble → check what is available →
spend it*.

## Bearing on the bird

This strengthens the case for a pursuer considerably, and changes what it is
for.

A chaser **manufactures unplanned states**. That is precisely the condition
under which escape verbs become valuable, and the game currently generates
those states only by accident of course geometry. A threat that is dynamic and
*behind* you cannot be screened for in advance the way a static obstacle ahead
can — which is exactly why it would exercise a capability that today goes
almost untested.

It also means the bird would be hardest on the very style the search keeps
finding. Hauling holds an escape at 100% of its deaths; it has the tools and
no habit of using them under pressure.

## What it does not license

No change to the player model is proposed here. Teaching the bot a recovery
loop would make it survive longer, but the acceptance targets in
`2026-08-01-owner-play-calibration.md` are about resembling a person, and a
recovery loop written from this document rather than from recordings would be
another invented habit. **The tap stream already contains the ground truth**:
the owner's own dives and bursts, timestamped, in the moments after things
went wrong. Fitting the recovery loop from those is the honest route, and it
is the one piece of the model that the recordings can supply directly.

## Method

`tools/simulate.gd` records `burst_charges`, `dive_ready` and web state at the
tick a run's terminal death is requested, and reports them as shares of runs.
24 runs per policy, held-out seeds (bot 4242, courses 9000–9007), never seen
by any search.
