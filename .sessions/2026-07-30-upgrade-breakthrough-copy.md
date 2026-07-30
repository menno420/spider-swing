# Upgrade breakthrough clarity session

> **Status:** `complete`

## Goal

Explain the real level 5/10/15/20 bonus in the Shop: each breakthrough purchase applies its track's listed per-step increase twice, without changing upgrade values, progression, saves, or swing behavior.

## Scope guard

This session may change centralized Shop copy, its front-end regression contract, development build identity, and living verification documentation. It must not change `SpiderCatalog.effective_steps()`, any per-step tuning value, upgrade costs, save schema, the frozen GDD, or unrelated gameplay and interface systems.

## Previous-session review

**previous-session review:** PR #34 corrected Balanced Flow's reversed wording. Menno's follow-up exposed the broader clarity gap: every card names a “breakthrough” and a future level, but never explains that the milestone adds one bonus tuning step and therefore applies the listed increase twice.

## About to happen

Open one ready implementation PR, add compact globally consistent breakthrough wording at both Shop-header and card level, prove levels 4/5/20 render the correct rule, build the Android artifact, then complete this card and remove the claim only after all evidence is green.

## Shipped

- `game/presentation/scripts/front_end.gd` explains once that levels 5, 10, 15,
  and 20 apply the listed increase twice; marks an upcoming purchase
  `BREAKTHROUGH ×2`; says the milestone grants two tuning steps; and derives a
  maxed card's four breakthroughs/24 total steps from `SpiderCatalog`.
- `tests/integration/front_end_flow_tests.gd` exercises the real Shop at level 4
  and max level. `tests/test_runner.gd` raises the declared suite to 90
  contracts.
- `project.godot`, `export_presets.cfg`, and
  `.github/workflows/android-debug.yml` identify build
  `0.11.3-upgrade-breakthrough-copy-test`, Android version code 26, and display
  name `Spider Swing Breakthrough Copy (dev)`.
- `README.md`, `docs/current-state.md`,
  `docs/technical/front-end-flow.md`, `docs/technical/testing.md`, and
  `docs/technical/phase-0-swing-laboratory.md` record the exact rule and device
  check.
- Remote implementation commit
  `3cef05470cfa10bf4a4e339c226ac099554aea58` has tree
  `23a54c7139af95e39e994a46194d01c9a082043e`, byte-identical to the locally
  verified implementation tree.

## Decisions flagged

- Keep one authoritative milestone mechanic: every fifth-level purchase adds
  one bonus copy of that track's normal increase. Do not invent unique powers
  for levels 5, 10, 15, or 20.
- Pair a single list-level rule with compact per-card state instead of
  duplicating 35 hand-authored milestone descriptions.
- Use `BREAKTHROUGH ×2` only beside the explicit “grants 2 tuning steps” text,
  so it cannot reasonably read as doubling the player's entire accumulated
  stat.

## Capability delta

None. The existing authenticated repository-write, exact-engine, and Android
artifact-inspection paths worked as already recorded; no new platform wall or
owner action was discovered.

## 💡 Idea

Label the four existing silk knots `5`, `10`, `15`, and `20` in a later
presentation-only pass so each filled knot maps visibly to its earned level
without adding a tooltip or another touch target.

- **📊 Model:** gpt-5 · high · runtime bugfix

## Verification evidence

- `git diff --check` passed.
- With task-local XDG directories, pinned Godot
  `4.7.1.stable.official.a13da4feb` completed clean import, front-end boot, and
  all 90/90 contracts locally: 44 physics, 21 mobile HUD, and 15 front-end.
- The pre-flip
  `python3 bootstrap.py check --strict --require-session-log --session-log
  .sessions/2026-07-30-upgrade-breakthrough-copy.md` reported only this card's
  designed in-progress hold. CI run
  [30535470360](https://github.com/menno420/spider-swing/actions/runs/30535470360)
  confirms `HOLD (by design)` and no other governance defect.
- Ready PR
  [#36](https://github.com/menno420/spider-swing/pull/36) contains exact
  implementation source `3cef05470cfa10bf4a4e339c226ac099554aea58`.
  `game-quality` run
  [30535470384](https://github.com/menno420/spider-swing/actions/runs/30535470384)
  passed. Android run
  [30535470355](https://github.com/menno420/spider-swing/actions/runs/30535470355)
  produced
  [artifact 8756471132](https://github.com/menno420/spider-swing/actions/runs/30535470355/artifacts/8756471132),
  61,394,012 bytes with GitHub digest
  `sha256:0c873700c4077ddeec8bad9944979a16be81e8abee242f6b2e245b725e34935b`.
  The downloaded ZIP matched that digest and passed archive validation. Its
  61,795,462-byte APK passed archive validation with SHA-256
  `939ea7b494b0cfbfb4166817e30540281805f1675a7bb68f64c49f83f90fd5dd`;
  `build-info.txt` proves the version, exact source, dev package, and display
  name.
- The checksum-pinned GDD remains byte-identical at
  `a63e804bfadfe6fd9db88686bf55ea2b57ce488157069190d8350968c39c7a53`.
- Final `python3 bootstrap.py check --strict --require-session-log
  --session-log .sessions/2026-07-30-upgrade-breakthrough-copy.md`:
  `check: session log .sessions/2026-07-30-upgrade-breakthrough-copy.md
  complete.` and `check: all checks passed.`

## Documentation audit

The Shop source, catalog progression model, test inventory, current-state
ledger, front-end contract, device checklist, and Android build assertions now
agree. Historical sessions and artifacts remain unchanged. No ADR, save
migration, upgrade value, progression calculation, or frozen game-design file
changed.

## Remaining owner review

Open one level-4 track and confirm the header rule, `BREAKTHROUGH ×2` button,
and “grants 2 tuning steps” description are immediately understandable at phone
size. A maxed track should read “4 breakthroughs earned · 24 tuning steps
total.” No swing-feel or save-migration retest is required because both
authoritative systems are unchanged.
