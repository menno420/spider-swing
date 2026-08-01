# Economy model — currencies, sources, sinks

> **Status:** `plan`
>
> The whole economy on paper before it is built, as the overnight brief
> requires. Measured facts come from the simulation lab and are dated; the
> model is a design proposal and the owner decisions at the end are genuinely
> open. Balance numbers live in code, never here.

## What the economy is for

The game already has three things worth wanting — capability, mastery and
identity — and only one of them costs anything today. The model exists to give
each its own currency, so that no single grind buys everything and no reward
undermines the mode that earned it.

- **Capability** — how well the spider swings. Bought with **flies**.
- **Mastery** — proof you can do a specific thing. Earned as **stars**, never
  bought.
- **Identity** — how the spider looks. Bought with **stars**, never flies.

The rule that keeps them separate: **flies buy power, stars buy appearance,
and nothing buys mastery.**

## What is measured, and what it says

Measured 2026-08-01 against `main` at PR #77, full runs from 0 m — never a
warped band, whose income is inflated by a fresh guided opening amortized over
a short window.

**Income is almost invariant.** Flies per kilometre sits at 11.1–14.5 across
every skill tier and both banking difficulty modes:

| Mode | Novice | Intermediate | Expert |
| --- | ---: | ---: | ---: |
| Standard | 10.2/run · 11.1/km | 22.1/run · 13.4/km | 31.8/run · 14.5/km |
| Harsh | 7.0/run · 12.0/km | 14.7/run · 13.3/km | 21.6/run · 14.1/km |

Per minute of play the two modes are indistinguishable — about 46 flies/min at
intermediate in both. Three consequences follow, and all three are problems:

**1. The whole upgrade economy is about twenty minutes long.** Maxing Classic's
seven tracks costs 987 flies. At measured income that is 45 runs — **21.5
minutes** at intermediate, 17.7 at expert. The single long-term sink in the
game is exhausted before a player has properly learned it.

**2. Twenty-nine percent of that spend buys nothing.** Silk Reserve and Rapid
Recovery cost 282 flies between them and produce bit-identical play at every
skill tier (`docs/measurements/2026-08-01-upgrade-audit.md`). The shop is
charging for improvements that are measurably not improvements.

**3. Harsh carries no risk premium.** It pays the same flies per minute as
Standard while killing the player roughly twice as fast. There is no economic
reason to ever choose it — only a personal one.

And separately: **stars have no sink at all.** The campaign mints them and
nothing spends them.

## The model

### Flies — the run currency

- **Source:** collected during a run, banked only when the run's difficulty
  mode is records-eligible. Practice, campaign and Relaxed bank nothing. This
  already holds and does not change.
- **Sink:** upgrade tracks. Nothing else, ever. If flies could buy appearance
  the campaign would become optional decoration.
- **Rate:** ~13/km, effectively flat. Distance *is* the income, which is the
  right shape for an endless runner: the reward for going further is going
  further.
- **The risk premium Harsh is missing** is the one number in this model worth
  adding: a mode multiplier on banked flies, so choosing a harder course pays
  for the shorter runs it causes. Relaxed keeps its zero. This is a pricing
  change, not a physics one.

### Stars — the mastery currency

- **Source:** one per campaign level, once, never repeatable. Fixed-seed levels
  cannot be farmed — the settlement-id dedupe already guarantees that.
- **Sink:** cosmetics. Styles and web variants priced in stars.
- **Never:** stars cannot buy upgrade levels, and flies cannot buy cosmetics.
  Keeping the two economies disjoint is what stops either grind subsuming the
  other.

Cosmetics currently unlock on thresholds (25 lifetime flies; 1 000 m best).
Those thresholds stay as *free* unlocks — they are the game teaching that
appearance exists — and the star shop is what carries the rest.

### What cannot be bought, at any price

- **Difficulty modes.** All three are free and always available. Selling access
  to an easier game is selling the game's own difficulty back to the player.
- **Region checkpoints.** Earned by reaching the distance in a records-eligible
  mode, never purchased.
- **The rescue life.** It is a difficulty-mode property, not an item.
- **Leaderboard standing**, and anything that would change physics.

## What happens to the two inert tracks

They are **suspended from sale** — not removed, not repriced, not repointed.

- Levels a player already bought stay bought. No save loses value.
- The tracks stay in the catalog with their ids intact, so nothing that keys on
  them breaks.
- The shop stops offering them and says why, rather than quietly charging for
  nothing.

Removing them would damage existing saves. Repointing them at some effect that
does bind would be inventing an upgrade, which the brief forbids without
evidence asking for it. Making the Reel meter bind — by lowering capacity or
raising drain so the reservoir matters — would move owner-approved physics.
Suspension is the only option that is honest, reversible, and inside the lane:
it states the measured truth and leaves every real decision to the owner.

If a later change makes the Reel meter bind, unsuspending them is a one-line
change and they resume being real upgrades.

## Owner decisions

These are genuinely open and the model is written so any answer drops in:

1. **What should the inert tracks become?** Suspension is a holding position,
   not an answer. Repoint them at something that binds, retire them, or make
   the meter bind — all three need your call.
2. **Should Harsh pay a fly premium, and how much?** The measurement says it
   currently pays nothing extra for roughly double the death rate. A multiplier
   is the obvious fix; the size is a feel decision.
3. **Is a twenty-minute upgrade economy the intended length?** If the answer is
   no, the fix is more sinks rather than higher prices — raising costs just
   makes the same twenty minutes feel slower.
4. **What do cosmetics cost in stars?** Three campaign levels exist, so three
   stars exist. That prices at most a small number of items until the campaign
   grows.

## Implementation status

Landed with this document: the inert-track suspension, because a shop making a
false claim is a defect regardless of what the rest of the economy becomes.

Designed but **not** implemented, deliberately: the star sink, the Harsh fly
premium, and cosmetic pricing. Each depends on an owner decision above, and
half-building an economy is worse than describing one. They are the next
implementation slice, not this one.
