# Slice 2 — campaign teaching tier

> **Status:** `complete`

## Goal

Close the gap D-0033 names: the tutorial explains Reel, Burst and Dive across
six static text steps and then never asks the player to perform any of them.
Build short levels that each *require* one verb.

## Scope guard

Systems and progression only. No physics values touched, no zone content, no
new art. Levels are authored teaching fixtures built from the existing geometry
vocabulary, not new obstacle types.

## Previous-session review

**previous-session review:** slice 1 landed the difficulty baseline (PR #74,
main `066804a`). Its lesson for this slice is procedural: `main` moved three
times under that PR, once replacing an entire pattern pool the committed
measurement described, which forced a full re-measure before merge. Expect the
same here and re-check before letting anything land.

## What shipped

Three teaching levels — Reel, Burst, Dive — reachable from Home → CAMPAIGN.
A level clears only on **goal reached AND taught verb performed**, so it cannot
be swung past. Fixed course seeds on existing Ancient Forest geometry; no new
obstacle kinds, no art. Settlement is non-competitive through the existing
path: one star, never a fly, no record, no leaderboard. Progression is schema 6
with an empty-ledger migration from 5.

- `game/domain/campaign_catalog.gd` — the levels and the completion rule.
- `game/domain/run_settlement.gd` — `RunSettlement.campaign()`.
- `game/domain/player_progress.gd` — schema 6, `campaign_stars`, migration.
- `game/application/progression_service.gd` — awards the star, never flies.
- `game/application/swing_lab_session.gd` — `RUN_CAMPAIGN`, verb observation,
  completion, campaign settlement.
- `game/application/front_end_state.gd`, `game/presentation/scripts/front_end.gd`,
  `game/bootstrap/main.gd` — the screen and its wiring.
- `tests/unit/campaign_tests.gd` — 10 contracts.

## The design fork, and why it went this way

The plan was to prove verb-requirement from geometry: drive a level with the
verb ablated and assert it fails. `--ablate` was built for exactly that, and
measuring it killed the idea:

- **Burst** ablates cleanly — and shows Burst barely matters: 2 360 m without
  it against 2 258 m with it, within noise.
- **Reel** cannot be ablated meaningfully. Without it the bot does not play
  worse, it stops playing: 0 attaches, 58 m, every run timing out on its
  opening web, because `_decide_attached` only releases when rising fast or
  high enough and never gets there. That measures the bot, not the course.
- **Dive** is inert — the bot has never Dived in any batch.

So a geometry-derived guarantee would have been a claim nobody could check.
The verb requirement became an **explicit objective** instead, which the suite
can hold and the player can read. The ablation tool and its three findings are
kept, documented with their limits, because Burst-is-irrelevant is direct input
to the upgrade audit.

## Falsification

Every new contract was mutated. Two were weaker than they read, and only
mutation exposed that:

- **Verb requirement** — dropping it from `is_complete` failed 2 contracts. ✅
- **Repeat-clear guard** — *initially did not falsify.* Removing the
  settlement-id dedupe left the suite green, because the dedupe and the star
  cap are redundant and the test only asserted the star total. Strengthened to
  count applications and star reports; now removing the dedupe fails it. ✅
- **Unknown-level-id guard** — *initially did not falsify.* The assertion used
  `total_campaign_stars()`, which only sums ids the catalog knows and so could
  never observe a forged key: it passed vacuously. Re-pointed at the stored
  ledger; now it fails. ✅
- **Star clamp** — a save claiming 99 stars loads as 1; removing `mini()` fails
  it. ✅

## Verification

`python3 tools/verify.py --require-godot` → **exit 0**, 144 contracts on pinned
Godot 4.7.1 (`EXPECTED_CHECK_COUNT` 134 → 144; main moved 123 → 124 → 134 under
the two slices tonight, so the count was re-derived from a real run, never
assumed).

`python3 bootstrap.py check --strict` → **exit 0**.

One pre-existing contract needed updating rather than working around: the
composition-root check asserts the literal `configure_run(...)` call text, and
adding the campaign argument changed it. Updated to the new form and
strengthened to also require the campaign signal be connected.

## Owner questions

None blocking. Two worth your morning:

1. **Campaign levels currently share one goal distance (300 m) and differ only
   in seed and taught verb.** They teach the verb but do not yet *force* the
   situation that makes the verb the obvious answer — that needs authored
   teaching geometry, which touches the zone lane's surface. Flagged, not built.
2. **Burst appears near-irrelevant to survival** (within noise of not having
   it). That is a balance question, not a bug, and it lands in the upgrade
   audit.

## 💡 Idea

"Requires the verb" should be a **contract, not a claim** — that survived, but
not the way it was planned. The intended proof was simulated ablation, and
measuring it showed the bot cannot play without Reel and never Dives, so two
thirds of the proof were unavailable. Making the requirement an explicit
objective got the same guarantee for less, and made it legible to the player
too.

The generalisable part is the failure mode: **a redundant guard hides a weak
test**. Both the repeat-clear and unknown-id contracts passed while the code
they claimed to guard was broken — one because two mechanisms each enforced the
outcome, one because the assertion queried a helper that could not observe the
violation. Asserting the *outcome* is not enough when several paths produce it;
the test has to observe the mechanism. Worth carrying into the economy slice,
where idempotence assertions will look exactly like these.

- **📊 Model:** opus-5 · high · feature build — campaign teaching tier

## Next slice

**Slice 3 — difficulty modes.** Settled in D-0033, so this is implementation:
separate best distance per mode, only Standard leaderboard-eligible, and
difficulty changes which content the stream may serve and how much recovery the
player gets — never the physics.

Take the fresh measurement first. `docs/measurements/2026-08-01-difficulty-curve.md`
is now marked superseded above 15 km: PR #73 landed zones 4–8, so its 15 km and
20 km bands sample zones that did not exist when it ran, and its "10–30 km is
identical" finding no longer holds. Re-run `tools/difficulty_curve.py` against
the current tree before tuning any mode against it — the recovery-share dial
(2.4% / 18.9% / 20.8% by zone) is the cleanest lever and needs no physics
change, and the skill-sensitivity ratio is the acceptance test: a mode that
lowers deaths/km while flattening that ratio has made the game easier without
making it fairer.
