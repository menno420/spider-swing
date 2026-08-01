# Correct the upgrade audit and revert its shop change

> **Status:** `complete`

## Goal

The owner reports from device play that **max upgrades play far better than
none**, and that a previous session had already established the simulator does
not adjust correctly for upgrades. He is right. Revert the shop change my audit
motivated, and record why the lab was wrong so it cannot happen again.

## Scope guard

Correction only. Reverts a change I shipped; adds no feature, retunes no value,
touches no physics and no zone content.

## Previous-session review

**previous-session review:** slice 4 (PR #77) audited upgrade tracks with the
simulation lab and concluded the bundle made the player 25% worse and two Reel
tracks were inert. Slice 5 (PR #78) acted on that by withdrawing those two
tracks from sale. Both conclusions were wrong, and the second one shipped a
user-visible defect.

## What was actually wrong

**The bot cannot perceive Reel upgrades.** Its policy is written entirely in
*fractions* of the meter — engage above `energy_fraction > reel_reserve`,
disengage at `energy_fraction <= 0.06`. Scaling `reel_energy_capacity` scales
numerator and denominator together, so the bot behaves identically. Measured
directly:

```
(none)         cap=60.0  seconds_of_reel=2.00  bot_reserve=0.240
reel_capacity  cap=74.4  seconds_of_reel=2.48  bot_reserve=0.240
reel_recovery  regen=22.3 sustain=0.744        bot_reserve=0.154
```

Silk Reserve is a real **+24% increase in continuous reel time**. The
bit-identical simulation output was the bot being structurally blind to the
axis, not the upgrade being inert.

**And the supporting premise was circular.** The audit rested on "the Reel
meter never empties — `reel empties` 0.00 in every band". The bot stops reeling
at 6% remaining, so it *cannot* empty the meter. That was a measurement of the
bot's own stopping rule reported as a fact about the game.

The negative findings (Silk Winder −10.4%, Anchor Drive −6.2%, bundle −25%) are
artifacts of the same class, and device play contradicts them.

## What I got right, and what that is worth

The audit did flag these as bot-preference results and explicitly refused to
retune anything, routing it to a device playtest as OQ-11. That refusal is the
only reason this correction is a document change plus one revert rather than a
balance rollback. But the caution was not evenly applied: I labelled the inert
finding "structural, not bot preference" and acted on it. That sentence was the
error — I asserted the one conclusion I had not tested the harness against.

## Shipped

- **Reverted the shop suspension.** `SUSPENDED_TRACK_SUFFIXES`, the
  `purchasable` flag, `is_purchasable`, the purchase refusal and the shop's
  "WITHDRAWN" state are all gone. All seven tracks sell normally. No save was
  ever modified, so nothing needs migrating back.
- Removed the four contracts that asserted the suspension; kept the two economy
  rules that remain true (campaign never pays flies, only records-eligible
  modes bank). 163 → 159 contracts, a deliberate removal.
- `docs/measurements/2026-08-01-upgrade-audit.md` — superseded banner naming
  the mechanism. Kept rather than deleted: the method and its failure are worth
  reading.
- `docs/technical/simulation-lab.md` — a new section stating the lab must not
  be used to evaluate upgrades, with the two generalisable traps.
- `docs/current-state.md`, `docs/owner-questions.md` — OQ-8 and OQ-11 closed by
  owner evidence and moved to Answered.

## The lesson worth keeping

**A bit-identical result is not evidence of no effect — it can mean the model
is blind to the axis you varied.** I checked that the *config* changed before
believing the null, which felt like rigour and was not enough: the missing
check was whether the bot's decision rule could represent the change at all.
For any parameter, ask first whether the policy under test is scale-invariant
in it. If it is, the experiment cannot answer the question.

The same defect has a second instance already visible: `tools/simulate.gd`
references none of the special anchor classes zones 4–8 introduced — moving
pivots, silk highways, sticky silk, rotten anchors, collapsing spans — and has
never performed a Dive in any batch. So the difficulty readings for zones 4–8,
including "Web City at 25 km is far too easy", are suspect for exactly the same
structural reason and should not be acted on either.

## Verification

`python3 tools/verify.py --require-godot` → **exit 0**, 159 contracts on pinned
Godot 4.7.1 (163 → 159; four suspension contracts deliberately removed, count
re-derived from a real run).

`python3 bootstrap.py check --strict` → **exit 0**, findings read in full.

No mutation log: this change removes contracts and reverts code rather than
adding guarantees. The surviving suite is what proves the revert is complete.

## Owner questions

None new. OQ-8 and OQ-11 are closed by the owner's device evidence. OQ-9 (Harsh
fly premium) and OQ-10 (economy length) stay open and are unaffected — neither
rests on the upgrade audit.

## 💡 Idea

The lab's credibility problem is narrower than "the bot is unrealistic": it is
that **the bot's blind spots are undocumented**, so a result cannot be read
without knowing them. Three are now known — fraction-based Reel policy, never
Dives, ignores special anchor classes. A cheap improvement for a later session
would be a `--capabilities` flag that prints what the current bot model can and
cannot represent, so every measurement can be read against it rather than
against an assumption of competence.

- **📊 Model:** opus-5 · high · runtime bugfix — upgrade audit correction

## Next slice

**Slice 6 — missions, design only** remains the next backlog item, unchanged by
this correction. Design first: what a mission is, how it is offered without a
wall clock, how it completes from existing simulation events, how it settles,
and how it avoids becoming a second progression system competing with upgrades.

One thing this correction adds to it: mission objectives should be chosen from
behaviour the *game* can observe, not from what the lab can measure. The two
are not the same thing, and this slice is why.
