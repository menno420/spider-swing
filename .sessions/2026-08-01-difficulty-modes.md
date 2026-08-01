# Slice 3 — difficulty modes

> **Status:** `complete`

## Goal

Implement the difficulty modes D-0033 settled: separate best distance per mode,
only Standard leaderboard-eligible, and difficulty changes which content the
stream serves and how much recovery the player gets — never the physics.

## Scope guard

Systems and progression only. No physics value touched, no zone content, no new
art. The mode surface is the content and recovery knobs that already reach
`CourseStream.reset()` and the collision policy.

## Previous-session review

**previous-session review:** slice 2 landed the campaign teaching tier (PR #75,
main `a8001bd`). Its lesson was about tests, not features: two of its contracts
passed while the code they guarded was mutated — one because two guards were
redundant, one because the assertion queried a helper that could not observe
the violation. That shaped this slice's falsification, which deliberately
mutated the guard *and* the guarded value separately.

## What shipped

Relaxed / Standard / Harsh, chosen on Home, persisted, with per-mode bests.

- `game/domain/difficulty_catalog.gd` — the modes, their content and recovery
  overrides, and the `PHYSICS_FIELDS` / `CONTENT_FIELDS` split that makes the
  no-physics promise enforceable rather than aspirational.
- `game/domain/player_progress.gd` — schema 7: `best_distance_by_mode`,
  `selected_difficulty`, and a migration that puts a schema-6 save's single
  best into Standard's slot and nowhere else.
- `game/application/progression_service.gd` — every mode records its own best;
  only a records-eligible mode moves the authoritative one.
- `game/application/swing_lab_session.gd` — the mode is applied at the single
  config-resolution choke point, so every path that rebuilds the config carries
  it; `leaderboards_eligible` is now set separately from `records_eligible`.
- `game/application/front_end_state.gd`, `front_end.gd`, `main.gd` — the Home
  selector showing each mode's own best.
- `tools/simulate.gd` — `--difficulty`, and `deaths_per_run` beside the rate.
- `tests/unit/difficulty_tests.gd` — 9 contracts.

## The design, and the one judgement call

The split is what makes this safe. `PHYSICS_FIELDS` names all 45 values a mode
may never move — gravity, drive, speed curve, web, reel, Burst, Dive, camera,
collision radius. `CONTENT_FIELDS` names the 13 it may: obstacle and gate
scales, when hazards and tight corridors begin, the rescue life, and whether
the rails are lethal. A contract applies each mode to a fresh config and
asserts every physics field comes out identical to Standard's. Standard's
override set is empty by construction, so "Standard == the approved preset"
cannot drift.

**The judgement call: Harsh sets records, Relaxed does not.** D-0033 says
separate bests and Standard-only leaderboards; it does not say who may move the
*authoritative* best that region checkpoints unlock from. Its stated worry is
specific — "without letting non-lethal rails set a record that reads as
equivalent to a Harsh one" — so Relaxed is excluded from records because a run
that cannot fall off the course would unlock every checkpoint on a first
attempt. Harsh is strictly harder than Standard, so a distance reached there
cheapens nothing and it keeps records while staying off the leaderboard. That
needed `records_eligible` and `leaderboards_eligible` to stop moving together,
which `RunSettlement` already modelled as separate fields.

## Measured acceptance

Distance survived (m), 30 runs per skill per mode:

| Mode | Novice | Intermediate | Expert | Expert ÷ novice |
| --- | ---: | ---: | ---: | ---: |
| Relaxed | 2 529 | 3 096 | 3 806 | 1.51× |
| Standard | 982 | 1 714 | 2 258 | 2.30× |
| Harsh | 609 | 1 133 | 1 448 | 2.38× |

Monotone at every tier. **Harsh passes the brief's acceptance test** — harder
while preserving skill sensitivity (2.38× vs 2.30×).

**Relaxed deliberately fails it, and that is the honest reading.** It flattens
the ratio to 1.51× because non-lethal rails remove the failure mode that
punishes novices most. By the brief's test that is "easier without being
fairer" — which is exactly why D-0033 keeps Relaxed off records, and why this
implementation also keeps it off region checkpoints. Reported rather than tuned
away: making Relaxed preserve skill sensitivity would mean keeping lethal
rails, which is the one thing D-0033 explicitly gave it.

**A trap worth not re-learning:** deaths/km is not comparable across modes.
Harsh reads *lower* deaths/km than Standard (1.64 vs 2.04) while killing twice
as fast, because it disables the rescue life so a run holds one death instead
of two. `deaths_per_run` now sits beside the rate; compare modes on distance.

## Falsification

Five mutations, each reddening the intended contract, baseline green after:

- **Physics override with the guard intact** → "mode harsh overrides
  non-content field gravity". ✅
- **Physics override with the guard removed** → "mode harsh changed physics
  field gravity (1120.0 → 900.0)". ✅ Both layers proven separately, because
  slice 2 showed a redundant guard can hide a weak test.
- **Relaxed made records-eligible** → two contracts fail, including "a Relaxed
  run moved the authoritative best to 400000". ✅
- **Per-mode best recording removed** → "mode relaxed best is 0, expected
  50000". ✅
- **Schema-6 migration removed** → "a schema-6 best did not migrate to
  Standard". ✅

## Verification

`python3 tools/verify.py --require-godot` → **exit 0**, 153 contracts on pinned
Godot 4.7.1 (`EXPECTED_CHECK_COUNT` 144 → 153, re-derived from a real run).

`python3 bootstrap.py check --strict` → **exit 0**.

## Re-measurement

The committed baseline was re-run against current `main` and is **fully**
superseded, not only above 15 km as the previous card assumed. PR #73 also
touched `simulation_world.gd` and `web_constraint.gd`, so bands whose content
never changed moved anyway: 10 km went 5.46 → 7.68 deaths/km with Silk
Hollow's pool untouched. When the simulation moves, the whole curve moves.

## Owner questions

None blocking. One is worth your morning, and it is a zone-lane finding:

**Web City at 25 km is far too easy for its position.** 2.55 deaths/km against
Storm Ridge's 8.94 immediately before it — 3.5× easier, easier than Bramble
Canopy at 5 km, and only twice the opening ramp. An expert survives 1 394 m
there against 296 m at 20 km. A player who fights through Storm Ridge is
rewarded with the easiest content since the tutorial. Recorded for the zone
lane; nothing in the pattern catalog was touched here.

## 💡 Idea

The `PHYSICS_FIELDS` / `CONTENT_FIELDS` split turned a rule that had been
repeated in prose across three documents into one enforced list. The
generalisable move: when a constraint keeps getting restated in briefs and
decision records, that is evidence it wants to be a data structure with a
contract behind it. The same treatment would suit "campaign rewards are never
flies" — currently guarded by one `rewards_eligible` flag and a test, but not
by an enumeration anything new must pass.

- **📊 Model:** opus-5 · high · feature build — difficulty modes

## Next slice

**Slice 4 — upgrade audit and refinement.** With the fresh baseline, measure
which existing upgrade tracks actually change outcomes and which are noise. Do
not add upgrades on intuition.

Two hypotheses are already measured and waiting. **The Reel meter never
empties** — `reel empties` 0.00 and `time at empty` 0.00 s in every band at
every skill, now including zones 4–8 — so any track buying Reel capacity or
regeneration is improving a resource that does not bind. **Burst barely moves
survival** — ablating it entirely cost 2 258 → 2 360 m at expert, within noise.
Re-run `tools/difficulty_curve.py` at `--upgrades=0` vs `10` vs `20` and treat
any track that does not move deaths/km by more than its error bar as noise.
