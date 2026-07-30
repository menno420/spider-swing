# Balanced Flow copy correction session

> **Status:** `complete`

## Goal

Clarify that the Garden Spider's Balanced Flow upgrade makes automatic take-up shorten the active web more during inward movement, without changing its already-correct physics, balance values, progression, or save data.

## Scope guard

This session may change the Garden Spider upgrade description, a deterministic
outcome contract, build identity, and living verification documentation. It
must not change the automatic take-up formula, its tuning values, web controls,
progression levels, save schema, the frozen GDD, or any unrelated gameplay
system.

## Previous-session review

**previous-session review:** PR #32 merged card-wide Shop/Settings scrolling and
the repaired post-2000 m weaves. Menno's next Shop screenshot exposed a separate
semantic defect: maxed Balanced Flow said it retained “more slack,” which reads
as a longer web even though the solver already shortens the web more.

## Shipped

- `game/domain/spider_catalog.gd` now says automatic take-up keeps less slack
  and shortens the web. The level effect remains exactly 0.25 percentage points
  per tuning step.
- `tests/unit/phase0_physics_tests.gd` exercises the real `WebConstraint` at
  level zero and max level. It proves take-up rises from 85% to 91%, so the same
  20 px inward movement leaves a 481.8 px web instead of 483 px.
- `tests/test_runner.gd`, `project.godot`, `export_presets.cfg`, and
  `.github/workflows/android-debug.yml` identify build
  `0.11.2-balanced-flow-copy-test`, Android version code 25, and display name
  `Spider Swing Balanced Flow Copy (dev)`.
- `docs/current-state.md`, `docs/technical/testing.md`, and
  `docs/technical/phase-0-swing-laboratory.md` record the precise direction,
  89-contract suite, and current device build.
- Remote implementation commit
  `748aa12a54430cedf38ca2a3dee555610328f69a` has tree
  `5c6b1397938562ea46410c9ddc5f928f8d41c05b`, byte-identical to the locally
  verified implementation tree.

## Decisions flagged

- Preserve the formula because its direction already matches the intended
  easier, tighter swing; correct the misleading copy rather than reversing
  working behavior.
- State the player-visible outcome—less slack and a shorter web—rather than
  exposing the ambiguous internal term “retention.”
- Protect both copy direction and solver outcome in one deterministic contract.

## 💡 Idea

Give every upgrade card a centralized current → max effect line, such as
`AUTO TAKE-UP 85% → 91%`, so descriptions explain fantasy while exact numbers
come from one reusable stat-preview model.

- **📊 Model:** gpt-5 · high · runtime bugfix

## Verification evidence

- `git diff --check` passed.
- `python3 tools/verify.py --skip-godot` passed the 14-fixture architecture
  self-test and inward dependency scan.
- With task-local XDG directories, pinned Godot
  `4.7.1.stable.official.a13da4feb` completed clean import, front-end boot, and
  all 89/89 contracts locally: 44 physics, 21 mobile HUD, and 14 front-end.
- The pre-flip
  `python3 bootstrap.py check --strict --require-session-log --session-log
  .sessions/2026-07-30-balanced-flow-copy.md` reported this card's designed
  in-progress hold; CI run
  [30533495249](https://github.com/menno420/spider-swing/actions/runs/30533495249)
  confirms the same hold and no other governance defect.
- Ready PR
  [#34](https://github.com/menno420/spider-swing/pull/34) contains exact
  implementation source `748aa12a54430cedf38ca2a3dee555610328f69a`.
  `game-quality` run
  [30533495192](https://github.com/menno420/spider-swing/actions/runs/30533495192)
  passed. Android run
  [30533495206](https://github.com/menno420/spider-swing/actions/runs/30533495206)
  produced
  [artifact 8755663459](https://github.com/menno420/spider-swing/actions/runs/30533495206/artifacts/8755663459),
  61,392,008 bytes with GitHub digest
  `sha256:a58a96b1d40f2079a5fc8ea7cf44c106c89e3e4b7842d4f0c0e35471df6c223f`.
  The downloaded ZIP matched that digest and passed archive validation. Its
  61,795,462-byte APK passed archive validation with SHA-256
  `353c469f360ec34afd69d297c3c1cfb9bba744dfa18c3bb4d6a3f6a0c865d473`;
  `build-info.txt` proves the version, exact source, dev package, and display
  name.
- The checksum-pinned GDD remains byte-identical at
  `a63e804bfadfe6fd9db88686bf55ea2b57ce488157069190d8350968c39c7a53`.

## Documentation audit

The upgrade catalog, physics test inventory, current-state ledger, device
checklist, build metadata, and Android assertions agree. Historical session and
artifact records remain unchanged. No ADR, save migration, or frozen
game-design file changed.

## Remaining owner review

Open the maxed Balanced Flow card and confirm the new sentence reads naturally
at phone size: “Automatic take-up keeps 0.25% less slack per tuning step,
shortening the web.” No swing-feel retest is required for this copy-only
correction; PR #32's scrolling and weave device checks remain the active
gameplay review.
