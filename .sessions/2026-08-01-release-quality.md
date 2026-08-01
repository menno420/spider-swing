# Earned release quality

> **Status:** `complete`

## Goal

Implement the first ordered slice of the earned-speed design: release timing
must become an authoritative, deterministic source of forward momentum.

## Scope guard

Release-quality simulation, deterministic contracts, replay compatibility,
living documentation, and a source-identified development build. This session
does not remove the horizontal drive, add bird state, tune the bird, or add
bird presentation.

## Previous-session review

**previous-session review:** PR #96 left a fully measured, ordered mechanics
spec and correctly made release quality the first independently shippable slice.
The important discipline carried forward was not to treat the whole earned-speed
package as one implementation: drive removal and the bird remain later PRs.

## Shipped

- `game/simulation/web_constraint.gd` and
  `game/simulation/simulation_world.gd` at remote implementation commit
  `33cf084b753508bac13d0aa0bf560196bb487b7d`: wrap-safe per-attachment arc
  history, rising/forward release scoring, a bounded x-only award, authoritative
  event data, and a manual-release-only seam.
- `game/domain/swing_config.gd` and `game/domain/difficulty_catalog.gd` at
  `33cf084b753508bac13d0aa0bf560196bb487b7d`: schema 11 config, zero-disable,
  validation, preset reset, and the difficulty-mode physics boundary.
- `tests/unit/phase0_physics_tests.gd`, `tests/test_runner.gd`, and
  `tools/simulate.gd` at `33cf084b753508bac13d0aa0bf560196bb487b7d`:
  sixty deterministic physics checks and one shared definition of covered arc
  for gameplay and lab instrumentation.
- `game/domain/trace_catalog.gd`,
  `tests/unit/simulation_lab_tests.gd`, and
  `assets/runtime/traces/release-quality-technical.json` at
  `33cf084b753508bac13d0aa0bf560196bb487b7d`: authoritative-physics trace
  format `@2`, retained `@1` incompatibility evidence, and a current technical
  cross-path fixture.
- Build `0.25.0-earned-release-playtest`, Android code 44, plus the living
  design/testing/owner ledgers at `33cf084b753508bac13d0aa0bf560196bb487b7d`.
  The checksum-pinned owner GDD remains byte-identical at
  `a63e804bfadfe6fd9db88686bf55ea2b57ce488157069190d8350968c39c7a53`.

## Mechanic and provenance

Covered arc quality is the wrap-safe attachment range divided by a full-arc
threshold; rise quality is `-velocity.y / velocity.length()`; their product
scales the horizontal award. The award requires forward motion and a position
right of the anchor. Burst/Dive and every other forced release stay on plain
`WebConstraint.release()` and earn nothing.

- **Assumed:** 100 px/s maximum award and a 90° full-arc threshold. Device feel,
  not the non-pumping bot, decides them. Zero disables the mechanic.
- **Inferred:** cap this one award at the retained named reference target plus
  the existing horizontal-overspeed allowance. It prevents repeated releases
  manufacturing unbounded speed without driving the player toward the curve.
- **Measured:** the pinned 60 Hz fixture covers 90° and releases at
  `(400, -300)` px/s, producing rise quality 0.600 and a 60.000 px/s award.
  Method: authoritative event payload under Godot 4.7.1; assertion resolution:
  0.001° and 0.001 px/s.

## Contract falsification

Each temporary break was isolated, run through the exact headless runner,
observed red, and restored. These are `measured` runner outcomes at one-contract
resolution:

| Temporary break | Required failure |
| --- | --- |
| Award hard-disabled | `wide rising release did not convert its measured quality into 60 px/s` |
| Up/down sign replaced with absolute vertical speed | `falling release manufactured forward momentum` |
| Arc multiplier bypassed | `sub-degree rising release received a wide-arc award` |
| Reference-speed cap replaced with a remote ceiling | `release award ignored its reference-speed cap or duplicated` |
| Angle delta left raw across the ±π discontinuity | `arc wrap read 358.000°, expected the small 46° unwrapped range` |
| Forced Burst detach deliberately granted release momentum | `forced Burst detach collected a manual-release award` |

After every mutant was restored, the full runner returned 184/184.

## Verification evidence

- `python3 tools/verify.py --require-godot` on exact
  `4.7.1.stable.official.a13da4feb` → `Phase 0 physics: 60 deterministic checks`,
  `[test_runner] PASS — 184 check(s) passed`, `[verify] all checks passed`.
- Godot `tools/simulate.gd --replay=assets/runtime/traces/release-quality-technical.json`
  → `travelled_m expected 2227.762 got 2227.762 ok`,
  `seconds expected 40.600 got 40.600 ok`, `trace REPRODUCES`. This is
  `measured` at one 60 Hz simulation tick; stdout resolution is 0.001 m and
  0.001 s. It is compatibility evidence, not play-quality or tuning evidence.
- Pre-flip `python3 bootstrap.py check --strict` found only this card's named
  `HOLD (by design)` after two invalid draft badge names were corrected. The
  completed-badge/claim-withdrawal pair is the deliberate final edit, followed
  by the same two required gates on the exact final tree.

## Capability delta

None. Local authenticated Git push remains unavailable, and the already
documented GitHub-app exact-tree publication path worked with byte-matched blob
SHAs. No capability ledger entry is added for a known venue state.

## Owner question and uncertainty

OQ-16 records the only new device judgement: whether the `assumed` 100 px/s /
90° response feels rewarding and legible without encouraging shallow-release
spam. No recording is requested; a playtest verdict is enough. OQ-13 through
OQ-15 remain unchanged.

## 💡 Idea

Physics semantics belong in replay identity even when the JSON shape is
unchanged. An input-only trace is a claim about both commands and the world that
interprets them; versioning only the record schema lets a plausible but false
run survive any mechanics change.

## Next slice

Drive → 0 as the existing `horizontal_drive_acceleration` config value, with
all five `target_speed_at` consumers decided explicitly. Do not delete
`target_speed_at`, and do not begin bird state or presentation in that PR.

- **📊 Model:** gpt-5.6-sol · high · feature build
