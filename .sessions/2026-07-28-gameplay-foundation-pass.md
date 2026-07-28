# Phase 0.10 gameplay foundation pass

> **Status:** `complete`

## Goal

Turn Menno's latest Android playtests and design direction into one coherent
next build: more predictable vertical control, an optionally self-shortening
rope, safer and more varied course patterns, explicit ceiling/floor experiments,
and a small progression-ready gameplay slice that does not duplicate simulation
or persistence ownership.

## Scope

- Keep gravity, Dive Pull, Burst, Reel, aim, range, and all new feel controls
  editable in the DEBUG panel.
- Promote the 1120-gravity / 40%-Dive candidate for the next controlled test.
- Add configurable natural rope take-up that retains a chosen percentage of
  inward movement without becoming another speed impulse.
- Keep continuous authored ceiling/floor rails with deliberate gaps, and allow
  their presence and lethality to be compared through DEBUG.
- Keep the opening 1000 m free from mid-lane hazards, then introduce validated
  lower anchors, readable route choices, and a larger organic graybox shape
  vocabulary.
- Add a predicted Dive path diagnostic so unsafe target routes are visible.
- If the existing boundaries support it cleanly, add deterministic fly
  collection, one temporary Burst-cooldown boost, persistent settlement, and
  initial cosmetic unlock progression through named owners rather than UI-owned
  writes.

The checksum-pinned GDD remains unchanged. Production art, monetization, store
publishing, analytics, cloud save, and a finalized upgrade economy are outside
this session.

## Previous-session review

**previous-session review:** PR #15 solved duplicate Android world intents and
Menno's subsequent recordings show that gravity 1120 produces longer,
more-readable runs. Dive Pull at 35% now creates useful lane changes, but 40% is
the next candidate. Some remaining deaths come from unsafe lower-anchor paths
through central obstacles, so pull strength and course validation must be
improved together.

## Decisions flagged

- Keep the movement lab as the one authoritative configuration surface.
- Treat permanent upgrade values as modifiers over a base `SwingConfig`, never
  as independent physics implementations.
- Start progression with one end-to-end, testable slice before adding a broad
  catalogue of currencies, boosts, spiders, or upgrade types.

## 💡 Idea

Generate collectible trails and lower-anchor windows from the same deterministic
route descriptor used by obstacle geometry. A course can then prove that its
visual hint, safe traversal line, collectible line, and recovery anchor describe
one route instead of four independently drifting systems.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

- `python3 tools/verify.py`: PASS locally on Godot
  `4.7.1.stable.official.a13da4feb`. The architecture checker passed all 14
  fixtures, the project imported and booted headlessly, and all 59 runtime
  contracts passed (28 deterministic physics, 12 mobile HUD, nine front-end,
  plus bootstrap/build contracts).
- `game-quality`: PASS at source
  `9050ea46d9894f6bb8198a6ee5a454e04e39f62a`.
  https://github.com/menno420/spider-swing/actions/runs/30402293219
- `android-debug`: PASS at the same source.
  https://github.com/menno420/spider-swing/actions/runs/30402293330
- Downloaded artifact
  [`spider-swing-android-debug`](https://github.com/menno420/spider-swing/actions/runs/30402293330/artifacts/8705188365)
  is a 56,779,277-byte ZIP with GitHub/SHA-256
  `bc87ecdf2814b7a7cf887d0b727416d748f18c9a02a890cd218df37c9b3be61b`.
  Its 57,162,004-byte APK passed archive verification, has SHA-256
  `5199c5c43562123f345da3833fcdc247a216965e21529abb2d4ffa4801982cfa`,
  and contains `classes.dex`, `AndroidManifest.xml`, `assets/project.binary`,
  and the compiled effect/progression scripts. Bundled `build-info.txt` proves
  version `0.4.0-gameplay-foundation-test`, source `9050ea46...`, development
  package `com.menno420.spiderswing.dev`, and display name
  `Spider Swing Gameplay Foundation (dev)`.
- The born-red `substrate-gate` run
  [30402293249](https://github.com/menno420/spider-swing/actions/runs/30402293249)
  failed only because this card was intentionally still `in-progress`. The
  completed-card strict run is the final merge gate.
- Ready PR: https://github.com/menno420/spider-swing/pull/16

## Docs audit

**docs audit result:** `README.md`, `docs/current-state.md`,
`docs/technical/phase-0-swing-laboratory.md`,
`docs/technical/front-end-flow.md`, `docs/technical/testing.md`,
`docs/DECISIONS.md`, `docs/CAPABILITIES.md`, `tests/README.md`, and
`control/status.md` now describe the configurable take-up/rail/course
experiments, the bounded collectibles/effects/progression slice, the 59-check
suite, and the exact Android artifact. The architecture index still points at
the same owners, no new autoload or duplicate authority was introduced, and the
checksum-pinned GDD was not edited.

## Owner follow-up

Install artifact `spider-swing-android-debug` from run `30402293330` after
uninstalling the previous dev build. Compare Dive Pull around 35/40/45%, natural
take-up off versus partial retention, safe versus lethal rails, and the first
1000 m before middle hazards. The next product decision is feel selection, not
more unreviewed feature breadth.
