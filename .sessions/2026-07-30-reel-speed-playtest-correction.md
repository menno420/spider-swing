# Reel speed playtest correction session

> **Status:** `complete`

## Goal

Correct the over-nerfed Reel shortening rate from the isolated 0.12.0 device
playtest while preserving its finite two-second resource budget and every
unrelated movement contract.

## Scope guard

This session may change centralized Reel rates for the named presets,
Reel-focused regression expectations, development build identity, and living
balance documentation. It must not change Reel duration, drain, regeneration,
lockout, velocity, automatic take-up, Burst/Dive, aim reach or forgiveness,
maximum course speed, route geometry, progression levels, saves, the frozen
GDD, monetization, or the deferred reserve-Burst prototype.

## About to happen

Apply Menno's device evidence by raising the balanced level-zero Reel rate from
260 to 320 px/s, prove max Garden Silk Winder resolves to 416 px/s, publish and
inspect the exact Android artifact, then complete this card and remove the
claim only after every required check is green.

## Previous-session review

**previous-session review:** PR #38 successfully isolated Reel capacity from
future breakthrough mechanics and fixed non-idempotent upgrade application.
Menno's resulting device test provided the missing feel evidence: the
two-second resource limit is useful, but 260 px/s made level-zero play too weak
and rates below 400 px/s could not change height reliably near 5000 m.

## Shipped

- `game/domain/swing_config.gd` raises Balanced Reel from 260 to 320 px/s and
  preserves the named preset response ordering at 320/335/350 px/s without
  changing duration, drain, regeneration, lockout, or any velocity rule.
- `game/domain/tuning_catalog.gd` exposes 260/320/400/440 px/s quick
  comparisons while retaining the existing direct 20 px/s tuning step.
- `tests/unit/phase0_physics_tests.gd` proves the two-second/640 px level-zero
  candidate, 416 px/s max Garden Silk Winder result, 400–450 px/s owner-tested
  max band, 2.48-second max Silk Reserve duration, preset ordering, and
  non-compounding resolution. The complete suite remains 91 contracts.
- `project.godot`, `export_presets.cfg`, `tests/test_runner.gd`, and
  `.github/workflows/android-debug.yml` identify
  `0.12.1-reel-speed-correction-test`, Android version code 28, and
  `Spider Swing Reel Speed Correction (dev)`.
- `README.md`, `docs/current-state.md`, `docs/decisions.md`,
  `docs/product/deep-progression-direction.md`,
  `docs/technical/phase-0-swing-laboratory.md`, and `tests/README.md` record
  the device-led correction and its deliberately unchanged boundaries.
- Remote implementation head
  `dcd3cee27fad6bb59cca0b03a5b132a09fad9fea` has tree
  `5e9cd817dde401af1a972cf59994db360855bf47`, byte-identical to the locally
  verified implementation tree.

## Decisions flagged

- Keep the two-second base meter from PR #38; correct only Reel shortening
  response so the playtest has one cause.
- Use 320 px/s at level zero because max Garden Silk Winder then resolves
  exactly to 416 px/s, inside Menno's tested 400–450 px/s target.
- Preserve the existing +15/+30 px/s Weighty/Agile preset ordering at
  335/350 px/s rather than leaving alternate debug candidates below Balanced.
- Keep Anchor Drive's reserve Burst deferred until this corrected Reel build is
  judged independently.

## 💡 Idea

Add a development-only post-run Reel readout for total energy spent and total
rope length shortened. That would distinguish “too slow” from “insufficient
capacity” in future device feedback without changing play or adding analytics.

- **📊 Model:** gpt-5.6-sol · high · feature build

## Capability delta

None. The authenticated GitHub connector, local public fetch, exact Godot
4.7.1 verification, and Android artifact download/inspection paths all worked.
The generic GitHub publish helper's missing `gh` prerequisite remains an
existing environment limitation; connector-backed branch, commit, PR, check,
artifact, and merge operations provide the repository's established fallback.

## Verification evidence

- `git diff --check` passed.
- With task-local XDG directories, pinned Godot
  `4.7.1.stable.official.a13da4feb` completed clean import, front-end boot, and
  all 91/91 contracts locally: 45 physics, 21 mobile HUD, 15 front-end, and 10
  bootstrap.
- The first exact-engine run passed every physics contract but found one stale
  ignored `.godot/imported` texture cache. Removing only that generated cache
  entry caused Godot to regenerate it from the byte-valid committed PNG; the
  unchanged suite then passed 91/91.
- The pre-flip strict Substrate check reported only this card's designed
  in-progress hold plus known non-blocking capability advisories. CI run
  [30559186194](https://github.com/menno420/spider-swing/actions/runs/30559186194)
  independently confirms `HOLD (by design)` and no other exit-affecting
  governance defect.
- Ready PR [#40](https://github.com/menno420/spider-swing/pull/40) contains
  exact source `dcd3cee27fad6bb59cca0b03a5b132a09fad9fea`.
  `game-quality` run
  [30559186244](https://github.com/menno420/spider-swing/actions/runs/30559186244)
  passed all 91 contracts. Android run
  [30559186273](https://github.com/menno420/spider-swing/actions/runs/30559186273)
  produced
  [artifact 8766128692](https://github.com/menno420/spider-swing/actions/runs/30559186273/artifacts/8766128692),
  61,396,058 bytes with GitHub digest
  `sha256:10f2ea5e8e08d70299b69c592a933d19614192cd38540ac1328ff558601af83d`.
  The downloaded ZIP matched that digest and passed archive validation. Its
  61,799,558-byte APK passed archive validation with SHA-256
  `b03a98e59ef07fdb4db2b49bb3ceaac88a369274ff2c97ede92291d1afa3151b`;
  `build-info.txt` proves the expected build, exact source, dev package, and
  display name.
- The checksum-pinned GDD remains byte-identical at
  `a63e804bfadfe6fd9db88686bf55ea2b57ce488157069190d8350968c39c7a53`.
- Final `python3 bootstrap.py check --strict --require-session-log
  --session-log .sessions/2026-07-30-reel-speed-playtest-correction.md`:
  `check: session log .sessions/2026-07-30-reel-speed-playtest-correction.md
  complete.` and `check: all checks passed.`
- PR: #40 is ready and remains open only for the final closeout-head checks;
  merge is permitted after those checks and the rebuilt Android artifact are
  green.

## Documentation audit

The centralized named presets, direct debug comparisons, regression contract,
build identity, current-state ledger, decision log, progression direction, and
device checklist now agree. Historical PR #38 records remain unchanged. No
Reel duration/recovery, velocity, take-up, Burst/Dive, aim, route, save,
monetization, reserve-Burst, or frozen-GDD source changed.

## Remaining owner review

Compare level-zero and maxed Garden on-device. Confirm that 320 px/s is
playable but still worth upgrading, 416 px/s permits deliberate high↔low
changes near 5000 m, the two-second meter still depletes often enough to make
Silk Reserve useful, and Reel still reads as arc control rather than a direct
forward boost. Anchor Drive remains deferred until that judgment.
