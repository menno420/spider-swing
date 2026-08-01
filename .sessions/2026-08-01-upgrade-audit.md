# Slice 4 — upgrade audit

> **Status:** `complete`

## Goal

Measure which upgrade tracks actually change outcomes and which are noise.
Refine what the evidence condemns; add nothing on intuition.

## Scope guard

Measurement and wiring contracts only. No upgrade value retuned, no physics
value touched, no zone content, no new track invented.

## Previous-session review

**previous-session review:** slice 3 landed difficulty modes (PR #76, main
`7244bf3`). Two lessons carried in. Its `PHYSICS_FIELDS` / `CONTENT_FIELDS`
split showed that a rule restated across documents wants to be an enforced
list — this slice does the same for "a track must actually reach the config".
And its late CI failure came from reading `check --strict` through `tail -3`
instead of the findings list; this slice read the findings.

## Findings

**Buying every upgrade makes the player 25% worse.** Intermediate bot, 60 runs
per configuration: level 0 → 1 646.9 m, level 10 → 1 484.4 m, level 20 →
1 233.7 m. Monotone.

**Per-track isolation, everything else at zero:**

| Track | Distance | Δ |
| --- | ---: | ---: |
| *(baseline)* | 1 646.9 m | — |
| Silk Winder — Reel speed | 1 475.4 m | **−10.4%** |
| Anchor Drive — Burst reach + 2nd charge | 1 544.8 m | **−6.2%** |
| Reliable Launch — Burst floor | 1 609.6 m | −2.3% |
| Silk Reserve — Reel capacity | 1 646.9 m | **0.0%** |
| Rapid Recovery — Reel regen + lockout | 1 646.9 m | **0.0%** |
| Balanced Flow — take-up | 1 674.2 m | +1.7% |
| Garden Rhythm — Burst cooldown | 1 670.4 m | +1.4% |

**Two tracks are provably inert.** Silk Reserve and Rapid Recovery produce
bit-identical output — mean, median, p10, p90, distance and death count
identical to the digit, at novice, intermediate and expert alike. Both
hypotheses handed to this slice are confirmed, and the Reel one is confirmed as
strongly as a measurement can be.

**The null was checked against the harness before being believed.** A
bit-identical result could equally mean the isolation flag never applied the
track. A direct probe showed the config genuinely changes — capacity 60.0 →
74.4, regeneration 18.0 → 22.32, lockout 0.75 → 0.66 — and play still does not.
The reason is structural: the Reel meter never empties in any band, mode or
reel style, so more headroom on a limit nobody reaches cannot matter. That part
does not depend on bot preference.

**The negative tracks are directionally consistent but not actionable.** Silk
Winder and Anchor Drive are negative at every tier and positive at none, but
the magnitudes swing with tier (Silk Winder −4.3 / −10.4 / −3.2%; Anchor Drive
−0.7 / −6.2 / −11.8%). These are bot-preference results, and the lab already
carries a recorded disagreement with an owner device finding on exactly the
Reel-rate axis. **Nothing was retuned.**

## What shipped

- `docs/measurements/2026-08-01-upgrade-audit.md` — the audit, with the
  reproduction commands and an explicit section on what the evidence does and
  does not license.
- `tools/simulate.gd` — `--track=<suffix|full_id>` isolates one upgrade track
  so a null result names the track instead of the bundle, and errors rather
  than silently measuring nothing when the name matches nothing.
- `tests/unit/upgrade_audit_tests.gd` — 4 wiring contracts.
- `docs/current-state.md`, `docs/README.md` — kept in step.

## The refinement, and the one I did not make

The evidence condemns two tracks, and the honest response is **not** to repoint
them at some other effect: what those tracks should become is a design decision
about the shop, and the brief is explicit that upgrades are not added on
intuition. Making the meter bind instead would mean lowering capacity or
raising drain — owner-approved physics, out of bounds.

So the refinement is the one the audit itself needed: **a contract that a track
which stops reaching the config fails the suite**, instead of quietly reading
as "measured, no effect". Distinguishing those two took a hand-written probe
this slice, and without it the whole finding would have been worthless. That
check is now permanent and runs on every track of every spider.

## Falsification

Four mutations, each reddening the intended contract, baseline green after:

- **Disconnected the `REEL_CAPACITY` branch** → "track classic_reel_capacity
  changes no config value at level 20 — it is disconnected, not weak". ✅ This
  is the exact ambiguity the slice had to resolve by hand.
- **Moved the Anchor Drive breakthrough off level 10** → "did not grant the
  second Burst charge at level 10 (1)". ✅
- **Removed the burst-fraction cap** → "burst_distance_fraction on classic
  reached 1.6000, cap is 0.6000". ✅
- **Duplicated a track suffix** → "duplicate upgrade id classic_burst". ✅

Three of the four also tripped pre-existing physics contracts, which is
reassuring rather than redundant: those assert tuning, these assert wiring, and
only the wiring ones name the offending track.

## Verification

`python3 tools/verify.py --require-godot` → **exit 0**, 157 contracts on pinned
Godot 4.7.1 (`EXPECTED_CHECK_COUNT` 153 → 157, re-derived from a real run).

`python3 bootstrap.py check --strict` → **exit 0**, findings list read in full
rather than tailed.

## Owner questions

Two, both genuinely yours, neither blocking:

1. **Silk Reserve and Rapid Recovery currently buy nothing.** Repointing them
   at an effect that binds, or removing them, is a shop design decision. They
   cannot stay priced as improvements without the shop making a false claim —
   which makes this input to the economy slice as well.
2. **Silk Winder and Anchor Drive measure negative.** Worth a device playtest
   before anyone touches the numbers, because the lab and the device have
   disagreed on the Reel-rate axis before. If they feel good to you, the bot is
   wrong and the tracks stay.

## 💡 Idea

The interesting question is not which upgrade is weak but **why more capability
makes this player worse** — that pattern is the same in the bundle and in the
two largest tracks. Two testable candidates, both cheap with `--track` and
`--ablate` now in place: whether a longer Burst simply reaches more lethal
geometry, and whether the second stored charge invites a second mistake before
the first is recovered. Anchor Drive bundles both changes, so separating them
is the first experiment.

- **📊 Model:** opus-5 · high · research — upgrade audit

## Next slice

**Slice 5 — currency and reward model.** Design the whole economy on paper
first, then implement: what each currency is for, what it buys, what cannot be
bought. Flies are the only currency today; the campaign added stars, and
rewards must never be flies. This is where the "final economy" scope boundary
moves, so update `docs/current-state.md` in the same PR.

Carry this slice's finding into it: **two upgrade tracks are currently priced
as improvements while measurably doing nothing.** Whatever the economy becomes,
it cannot charge for those without the shop making a false claim — so the
economy design has to say what happens to them. Slice 2's lesson also applies
directly here: idempotence assertions look exactly like the ones that passed
vacuously, so make every economy contract observe the mechanism, not just the
balance.
