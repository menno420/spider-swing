# Slice 5 — currency and reward model

> **Status:** `complete`

## Goal

Design the whole economy on paper first — what each currency is for, what it
buys, what cannot be bought — then implement. Answer what happens to the two
upgrade tracks the audit proved inert.

## Scope guard

Systems and progression only. No physics value touched, no upgrade *effect*
retuned, no zone content, no new currency invented. Pricing and availability
are in scope; effect sizes are not.

## Previous-session review

**previous-session review:** slice 4 landed the upgrade audit (PR #77, main
`4279096`). It proved Silk Reserve and Rapid Recovery change the config and
produce bit-identical play, and deliberately left the design answer to this
slice. Its methodological lesson carried straight in: a null must be
distinguishable from a broken harness, and a contract asserting an outcome
proves nothing when several mechanisms produce it.

## What the measurement says

Fly income over **full runs from 0 m** — never a warped band, whose income is
inflated by a fresh guided opening amortized over a short window:

| Mode | Novice | Intermediate | Expert |
| --- | ---: | ---: | ---: |
| Standard | 10.2/run · 11.1/km | 22.1/run · 13.4/km | 31.8/run · 14.5/km |
| Harsh | 7.0/run · 12.0/km | 14.7/run · 13.3/km | 21.6/run · 14.1/km |

Income is **near-invariant**: ~13 flies/km at every skill in both banking
modes, and ~46 flies/min at intermediate in both. Three consequences, all
problems:

1. **The whole upgrade economy is ~21.5 minutes long.** 987 flies to max
   Classic's seven tracks = 45 intermediate runs. The game's only long-term
   sink is exhausted before the player has learned the game.
2. **29% of that spend buys nothing** — 282 of 987 flies go to the two inert
   tracks.
3. **Harsh carries no risk premium.** Same flies per minute as Standard while
   killing roughly twice as fast. No economic reason to ever choose it.

And stars, minted once per campaign level, have **no sink at all**.

## The model

`docs/product/economy-model.md`, in one rule: **flies buy power, stars buy
appearance, and nothing buys mastery.**

- **Flies** — earned only in records-eligible modes, sink only into upgrade
  tracks.
- **Stars** — one per campaign level, never repeatable, designed to sink into
  cosmetics.
- **Never purchasable at any price:** difficulty modes, region checkpoints, the
  rescue life, leaderboard standing, anything touching physics.

Keeping the two economies disjoint is what stops either grind subsuming the
other — if flies bought cosmetics the campaign would become optional decoration.

## The design answer on the inert tracks

**Suspended from sale.** Not removed, not repriced, not repointed.

Levels already bought stay bought and still apply. Ids stay valid. The shop
stops offering them and says why — "WITHDRAWN — NO MEASURED EFFECT" — instead
of quietly charging 282 flies for nothing.

The alternatives were each worse for a specific reason. Removing them damages
existing saves. Repointing them at some effect that binds is inventing an
upgrade, which the brief forbids without evidence asking for it. Making the
Reel meter bind — lowering capacity or raising drain so the reservoir matters —
moves owner-approved physics. Suspension is the only option that is honest,
reversible, and inside the lane; unsuspending is one line if the meter is ever
made to bind.

## Implemented, and deliberately not

**Landed:** the model document, the suspension, and its contracts. A shop
making a false claim is a defect regardless of what the rest of the economy
becomes, so it stands alone correctly.

**Not landed, on purpose:** the star sink, the Harsh fly premium, and cosmetic
pricing. Each depends on an owner decision recorded in the model, and the brief
is explicit — *do not half-implement*. Building a star shop whose prices I
invented would be exactly the intuition the audit slice refused.

## Falsification

Five mutations, each reddening the intended contract, baseline green after:

- **Emptied the suspension list** → "no track is suspended — the audit found
  two that measure zero". ✅
- **Changed the refusal reason to `flies`** → "suspended track refused for
  reason 'flies', not 'suspended'". ✅ **This is the mechanism check.** A
  player with no flies is also refused, so asserting "not purchased" alone
  would pass with suspension doing nothing; the contract buys with a full
  wallet and reads the reason.
- **Made suspension universal** → "only 0 unsuspended track(s) could be bought
  — suspension is too broad". ✅ Catches a fix that disables the shop wholesale.
- **Removed the rewards-eligibility gate** → "a campaign clear banked 500
  flies" *and* "mode relaxed banked 120 flies but sets no record". ✅ The
  campaign contract forces `flies_collected = 500` onto the settlement, so the
  guarantee has to come from eligibility rather than from the constructor
  happening to zero the field.

## Verification

`python3 tools/verify.py --require-godot` → **exit 0**, 163 contracts on pinned
Godot 4.7.1 (`EXPECTED_CHECK_COUNT` 157 → 163, re-derived from a real run).

`python3 bootstrap.py check --strict` → **exit 0**, findings list read in full
rather than tailed.

## Owner questions

Four, all recorded in the model, none blocking:

1. **What should the inert tracks become?** Suspension is a holding position,
   not an answer — repoint, retire, or make the meter bind.
2. **Should Harsh pay a fly premium, and how much?** It currently pays nothing
   extra for roughly double the death rate.
3. **Is a ~21-minute upgrade economy the intended length?** If not, the fix is
   more sinks rather than higher prices — raising costs just makes the same
   twenty minutes feel slower.
4. **What do cosmetics cost in stars?** Three campaign levels exist, so three
   stars exist; that prices very little until the campaign grows.

## 💡 Idea

The measurement that reframed this slice was not a balance number but an
**invariance**: income is ~13 flies/km no matter who plays or how hard the mode
is. That means the economy has exactly one input — distance — and every
economic lever the game thinks it has is really the same lever. It also means
the difficulty modes are economically invisible, which is why Harsh needs a
premium to exist as a choice rather than a preference.

Worth carrying forward: when a currency's rate is invariant across every axis
you can vary, the currency is measuring one thing, and any design that assumes
it measures more is going to disappoint.

- **📊 Model:** opus-5 · high · kernel/architecture design — economy model

## Next slice

**Slice 6 — missions.** Design first, in its own slice, exactly as the brief
requires: missions were deliberately outside Phase 0 and there is no existing
shape to extend. What a mission *is*, how it is offered, how it completes, how
it settles, and — the hard part — how it avoids becoming a second progression
system competing with upgrades. Implement only after the design lands.

Two constraints from this slice carry directly into it. **Mission rewards must
never be flies**, same rule as the campaign, so the design has to say what they
*do* pay — and the star sink is still unbuilt, which makes stars the obvious
candidate and the reason to settle cosmetic pricing first. And the economy
already has only one real input, distance; a mission system that just re-prices
distance adds nothing a multiplier could not.
