# Upgrade audit — 2026-08-01

> **Status:** `reference`
>
> **SUPERSEDED 2026-08-01 by owner device evidence. Do not act on the
> conclusions below.** The owner reports that max upgrades play *far better*
> than none, and that a previous session had already established the simulator
> does not adjust correctly for upgrades. He is right, and the mechanism is now
> identified:
>
> **The bot cannot perceive Reel upgrades at all.** Its reel policy is written
> entirely in *fractions* of the meter — it starts reeling above
> `energy_fraction > reel_reserve` and stops at `energy_fraction <= 0.06`.
> Scaling capacity scales both sides, so the bot behaves identically. Silk
> Reserve at level 20 is a real **2.00 s → 2.48 s** increase in continuous reel
> time (+24%), and the bot returned bit-identical output because it is
> structurally blind to it, not because the upgrade is inert.
>
> Worse, the "the Reel meter never empties" premise this document leans on is
> **circular**: the bot stops reeling at 6% remaining, so it can never empty the
> meter. That was a measurement of the bot's own stopping rule reported as a
> fact about the game.
>
> **Correction, same day.** That last paragraph is right about the method and
> wrong to imply the conclusion was false. The owner's recordings carry a
> readable reel meter: across a whole 48-second run at L20 it never falls below
> **73%**, median 100%. And bot v3, whose reel thresholds are absolute seconds
> rather than ratios and which therefore *could* show a binding reservoir,
> still reports both reel tracks bit-identical to level 0. So the premise
> holds — it simply was not established by the evidence originally offered for
> it. See `2026-08-01-bot-model-v3.md`.
>
> The negative findings (Silk Winder −10.4%, Anchor Drive −6.2%, the bundle
> −25%) are bot-preference artifacts of the same kind and are contradicted by
> device play. The shop suspension this document motivated has been reverted.
>
> Kept, not deleted, because the method and its failure are worth reading. The
> lab's blind spot is now recorded in `docs/technical/simulation-lab.md`.

## Headline

**Buying every upgrade makes the player 25% worse, and no track measurably
helps.** Classic, `balanced_baseline`, Standard difficulty, intermediate bot,
60 runs per configuration, course seeds 1337–1344:

| Every track at level | Distance survived | vs level 0 |
| --- | ---: | ---: |
| 0 | 1 646.9 m | — |
| 10 | 1 484.4 m | −9.9% |
| 20 | 1 233.7 m | **−25.1%** |

Monotone. A fully upgraded spider survives three quarters as far as a fresh
one.

## Per-track isolation

`--upgrades` moves all seven tracks at once, so a bundle result names no
culprit. Each track was levelled alone with `--track`, everything else at 0:

| Track | Buys | Distance | Δ |
| --- | --- | ---: | ---: |
| *(baseline)* | — | 1 646.9 m | — |
| **Silk Winder** | Reel speed +30% | 1 475.4 m | **−10.4%** |
| **Anchor Drive** | Burst reach 0.40→0.52, 2nd charge | 1 544.8 m | **−6.2%** |
| Reliable Launch | Burst floor +100 px | 1 609.6 m | −2.3% |
| **Silk Reserve** | Reel capacity 60.0→74.4 | 1 646.9 m | **0.0%** |
| **Rapid Recovery** | Reel regen 18.0→22.3, lockout 0.75→0.66 | 1 646.9 m | **0.0%** |
| Balanced Flow | Take-up retention +5% | 1 674.2 m | +1.7% |
| Garden Rhythm | Burst cooldown −8% | 1 670.4 m | +1.4% |

Only two tracks are positive, both by under 2% — inside the run-to-run spread.
The two largest effects are both **negative**.

## Two tracks are provably inert

**Silk Reserve and Rapid Recovery produce bit-identical output.** Not "within
noise" — identical to the digit in mean, median, p10, p90, total distance and
death count, at novice (948.7 m), intermediate (1 646.9 m) and expert
(2 210.4 m) alike.

That could mean the tracks do nothing, or that the isolation flag never applied
them. It was checked directly, because a null result you cannot distinguish
from a broken harness is worthless:

```
track=(none)         cap=60.000 regen=18.000 lockout=0.7500
track=reel_capacity  cap=74.400 regen=18.000 lockout=0.7500
track=reel_recovery  cap=60.000 regen=22.320 lockout=0.6600
```

The config genuinely changes. Play does not. The reason is the standing
measurement that the **Reel meter never empties** — `reel empties` 0.00 and
`time at empty` 0.00 s in every band, at every skill, in every difficulty mode,
including the greedy `hold` reel style. A larger reservoir, faster refill and
shorter empty-lockout are all improvements to a limit the player never reaches.
Two of seven tracks sell headroom on a resource that does not bind.

This finding does **not** depend on bot preference. It is structural: a
resource that is never exhausted cannot be improved by having more of it.

## The negative tracks, and how far to trust them

Silk Winder and Anchor Drive are negative at every skill tier — never positive
anywhere — but the magnitude moves with tier:

| Track | Novice | Intermediate | Expert |
| --- | ---: | ---: | ---: |
| Silk Winder | −4.3% | −10.4% | −3.2% |
| Anchor Drive | −0.7% | −6.2% | −11.8% |

**Trust the direction, not the size, and do not retune on this alone.** These
are bot-preference results and the bot is one player model with rule-based
Reel and Burst policies. The lab already carries a recorded disagreement on
exactly this axis: its earlier finding that slower reels scored better diverged
from the owner's device finding that 260 px/s felt too weak. A faster reel that
overshoots a rule-based correction may serve a human who reels deliberately.

Anchor Drive is the more suspicious of the two, because it compounds two
changes at once — a longer pull *and* a second stored charge from level 10 — so
a bot that Bursts opportunistically gets more chances to throw itself at
geometry. Worth separating before anyone concludes the reach is the problem.

## What this does and does not license

**Licensed by the evidence:** stating that Silk Reserve and Rapid Recovery
currently buy nothing, and that the upgrade bundle is a net negative for this
bot. Both are directly measured and reproducible.

**Not licensed:** retuning Silk Winder or Anchor Drive downward, or repointing
the two inert tracks at some other effect. The first needs a device playtest
because the lab and the device have disagreed on this exact axis before. The
second is a design decision about what those tracks should *become*, and the
brief is explicit that upgrades are not added on intuition. Both are owner
calls, recorded here rather than acted on.

**Also not licensed:** making the Reel meter bind by lowering capacity or
raising drain. Those are `balanced_baseline` physics values and owner-approved.

## Method

- Bot model v2, `balanced_baseline`, `classic`, Standard difficulty, rescue
  life on. 60 runs per configuration at intermediate, 50 at novice and expert.
- Course seeds 1337–1344 rotated independently of the bot-imperfection seed.
  180 s cap; no run timed out, so every run ended in a death.
- Level 20 is the maximum; `effective_steps` maps level to tuning steps.

Reproduce:

```bash
# the bundle
godot --headless --path . --script res://tools/simulate.gd -- \
  --runs=60 --skill=intermediate --course-seeds=8 --max-seconds=180 --upgrades=20

# one track alone
godot --headless --path . --script res://tools/simulate.gd -- \
  --runs=60 --skill=intermediate --course-seeds=8 --max-seconds=180 \
  --upgrades=20 --track=reel_capacity
```

`--track` accepts the bare suffix or the full `<spider>_<suffix>` id, and
errors rather than silently measuring nothing when the name matches no track.

## What the later slices should take from this

- **Currency and rewards.** Upgrade prices are currently charged for tracks
  that measurably do nothing. Whatever the economy becomes, Silk Reserve and
  Rapid Recovery cannot stay priced as if they were improvements without the
  shop making a false claim.
- **Ideas.** The most interesting question this raises is not "which upgrade is
  weak" but "why does more capability make this player worse". Two candidates
  worth measuring: whether a longer Burst simply reaches more lethal geometry,
  and whether the second Burst charge invites a second mistake.
