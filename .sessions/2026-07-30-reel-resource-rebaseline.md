# Reel resource rebaseline session

> **Status:** `complete`

## Goal

Make the level-zero Reel a limited arc-shaping resource again: correct
non-idempotent upgrade application, lower its base hold time and shortening
rate, preserve speed-neutral rope physics, and produce one isolated Android
comparison before prototyping Anchor Drive's reserve Burst.

## Scope guard

This session may change centralized Reel configuration, deterministic
progression application, Reel-focused debug tuning, regression contracts,
development build identity, and living balance documentation. It must not add
Burst charges, change Burst/Dive behavior, alter aim reach or forgiveness,
change automatic take-up, increase maximum course speed, modify course
geometry, migrate saves, edit the frozen GDD, or start monetization and larger
progression features.

## Previous-session review

**previous-session review:** PR #36 made the existing every-fifth-level double
tuning step explicit. Menno's follow-up and the current source show the next
progression problem is deeper: base Reel can shorten more rope than the full
usable span, while some Reel upgrade modifiers can be applied twice during the
normal mount path.

## About to happen

Rebaseline only the Reel resource, prove that preset/profile application is
idempotent and Reel remains velocity-neutral, publish and inspect the exact
Android artifact, then complete this card and remove the claim only after all
required checks are green.

## Shipped

- `game/domain/swing_config.gd`, `game/domain/spider_catalog.gd`, and
  `game/application/swing_lab_session.gd` make level-zero Balanced Reel a
  2.0-second, 260 px/s resource and resolve every active configuration from a
  fresh preset before applying progress exactly once.
- `game/domain/tuning_catalog.gd` adds authoritative full-meter Reel-time
  tuning; `game/presentation/scripts/front_end.gd` reports Reel rate and hold
  time from the same resolved configuration.
- `tests/unit/phase0_physics_tests.gd` proves the 520 px base shortening
  budget, bounded max shared-upgrade budget, idempotent modifier resolution,
  speed-neutral Reel constraint, and direct debug-time tuning.
  `tests/test_runner.gd` raises the declared suite to 91 contracts.
- `project.godot`, `export_presets.cfg`, and
  `.github/workflows/android-debug.yml` identify build
  `0.12.0-reel-resource-test`, Android version code 27, and display name
  `Spider Swing Reel Resource (dev)`.
- `README.md`, `docs/current-state.md`, `docs/decisions.md`,
  `docs/product/deep-progression-direction.md`, and the relevant technical and
  layer READMEs record the isolated comparison and proposed later Anchor Drive
  reserve-Burst contract.
- Remote implementation commit
  `d3c14c95f84aa8a749a5a4694ba4fabd3bdbe389` has tree
  `d59838e42d9f93bd349814d86c49719de7d14bba`, byte-identical to the locally
  verified implementation tree.

## Decisions flagged

- Use a 2.0-second, 260 px/s level-zero Balanced Reel comparison. Its 520 px
  shortening budget remains useful but cannot consume the full maximum web.
- Keep drain, regeneration, empty lockout, take-up, aim, reach, Burst/Dive,
  course speed, and route geometry unchanged so the device comparison has one
  balance cause.
- Resolve each active configuration from a fresh preset before applying one
  profile and its upgrades. Do not make mutating modifier application itself a
  reusable configuration lifecycle.
- Specify Anchor Drive's reserve Burst in the progression direction, but keep
  it out of this build until Reel feel is judged independently.

## 💡 Idea

Use the eventual two-pip Anchor Drive display as a reusable serial-charge
presentation component, but keep the authoritative charge owner inside fixed
simulation so future visuals and accessibility variants cannot alter recharge
truth.

- **📊 Model:** gpt-5.6-sol · high · feature build

## Capability delta

None. The existing authenticated repository-write, pinned Godot, and Android
artifact-inspection paths worked as recorded. No new platform wall or owner
action was discovered.

## Verification evidence

- `git diff --check` passed.
- With task-local XDG directories, pinned Godot
  `4.7.1.stable.official.a13da4feb` completed clean import, front-end boot, and
  all 91/91 contracts locally: 45 physics, 21 mobile HUD, 15 front-end, and 10
  bootstrap.
- The pre-flip
  `python3 bootstrap.py check --strict --require-session-log --session-log
  .sessions/2026-07-30-reel-resource-rebaseline.md` reported only this card's
  designed in-progress hold. CI run
  [30552164921](https://github.com/menno420/spider-swing/actions/runs/30552164921)
  confirms `HOLD (by design)` and no other exit-affecting governance defect.
- Ready PR
  [#38](https://github.com/menno420/spider-swing/pull/38) contains exact
  implementation source `d3c14c95f84aa8a749a5a4694ba4fabd3bdbe389`.
  `game-quality` run
  [30552161868](https://github.com/menno420/spider-swing/actions/runs/30552161868)
  passed. Android run
  [30552165170](https://github.com/menno420/spider-swing/actions/runs/30552165170)
  produced
  [artifact 8763246890](https://github.com/menno420/spider-swing/actions/runs/30552165170/artifacts/8763246890),
  61,395,621 bytes with GitHub digest
  `sha256:4ad4140070521bdc03145915f64413b7bb4a315a87bf6e9f10568d36106d1d82`.
  The downloaded ZIP matched that digest and passed archive validation. Its
  61,795,462-byte APK passed archive validation with SHA-256
  `f3cf97305a8207def7ea116113d57612f03779ff425662599365baf9c713bdd5`;
  `build-info.txt` proves build `0.12.0-reel-resource-test`, exact source, dev
  package, and display name.
- The checksum-pinned GDD remains byte-identical at
  `a63e804bfadfe6fd9db88686bf55ea2b57ce488157069190d8350968c39c7a53`.
- Final `python3 bootstrap.py check --strict --require-session-log
  --session-log .sessions/2026-07-30-reel-resource-rebaseline.md`:
  `check: session log .sessions/2026-07-30-reel-resource-rebaseline.md
  complete.` and `check: all checks passed.`

## Documentation audit

The centralized configuration, progression resolver, debug controls, Garage
stats, regression inventory, current-state ledger, decision log, and
progression direction now agree. Historical sessions and artifacts remain
unchanged. No Burst/Dive, aim, route, save, progression-level, monetization, or
frozen game-design source changed.

## Remaining owner review

Compare the level-zero Garden Reel with the previous build on a phone. Confirm
that a full meter now feels meaningfully finite, 260 px/s still gives enough
deliberate height/arc control, releasing Reel no longer reads as a dominant
forward boost, and every required route remains clearable. Only after that
isolated judgment should Anchor Drive's two-pip, serial-recharge reserve Burst
be implemented.
