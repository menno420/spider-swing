# Wide gate and clean-start diagnostics session

> **Status:** `complete`

## Goal

Turn the split root gate into a broad, steerable passage that grows from the
ceiling and floor, then make collision outlines and web-target guides opt-in
diagnostics instead of startup visuals.

## Scope guard

This session changes the gate's authoritative geometry and matching presentation,
diagnostic-display state and controls, regression coverage, documentation, and
development build identity. It does not retune spider movement, progression,
rewards, speed pacing, gate frequency, or unrelated obstacle geometry.

## Previous-session review

**previous-session review:** PR #23 replaced the collision-closed root ring with
two disconnected upper/lower pieces and proved a Classic-sized circle could cross
their exact centre line. Menno's `0.8.1-split-gate-test` Android recording shows
that this proof was too narrow: a real swing cannot hold the exact horizontal
centre line, and the two small floating pieces still read as a precision obstacle
rather than one usable opening.

## Decisions flagged

- Validate a vertical steering envelope across the full gate, not only its exact
  centre line.
- Root the upper and lower gate pieces into the existing lethal rails so the art,
  collision, and environmental meaning all describe one passage.
- Keep the DEBUG panel available, but give collision outlines and web guides
  separate off-by-default controls inside it.

## 💡 Idea

Treat route readability as a volume contract: a collectible trail needs enough
clearance for the spider's body plus realistic steering error over the entire
advertised passage.

- **📊 Model:** gpt-5 · high · runtime bugfix

## Verification evidence

- `python3 tools/verify.py --require-godot` passes with Godot
  `4.7.1.stable.official.a13da4feb`: 14 architecture fixtures, the repository
  architecture scan, clean import, front-end boot, and 78/78 headless contracts
  (40 physics, 17 mobile HUD, 11 front-end, and 10 bootstrap).
- The physics suite sweeps a Classic-sized spider through the complete root-gate
  width in three vertical lanes at every supported opening scale. The mobile HUD
  suite proves both diagnostic flags start false, their controls exist under
  DEBUG → OVERLAYS, and each control toggles only its own state.
- PR [#24](https://github.com/menno420/spider-swing/pull/24) is ready.
  `game-quality` run
  [30468085710](https://github.com/menno420/spider-swing/actions/runs/30468085710)
  passes at source `5029e2c501b01e48c12e88a2ba266212014c0ef9`.
- `android-debug` run
  [30468087491](https://github.com/menno420/spider-swing/actions/runs/30468087491)
  passes and produced
  [`spider-swing-android-debug`](https://github.com/menno420/spider-swing/actions/runs/30468087491/artifacts/8730447877),
  artifact ID `8730447877`, 58,595,704 bytes, digest
  `sha256:3dbd6a975f512e3633fb03cc65d07320b3b30c686b367fe18130c96ae395d006`.
  The downloaded ZIP and its 58,983,802-byte APK both pass archive validation.
  The APK has SHA-256
  `cfc39b42a49a83bb5111113f9737e74ccc4c74f23f859100e800c30544b5756f`
  and contains `classes.dex`, `AndroidManifest.xml`, and
  `assets/project.binary`. `build-info.txt` proves version
  `0.8.2-wide-passage-test`, the exact source SHA, the dev package, and display
  name `Spider Swing Wide Passage (dev)`.
- The initial `substrate-gate` failure is the designed in-progress-card hold.
  It will be rerun after this close-out and the final status flip.

## Documentation audit

Updated the binding phase-lab, testing, front-end-flow, current-state, decision,
layer-boundary, test-index, and project-index records. The frozen GDD is
unchanged. No stale statement still describes the root passage as a detached
floating obstacle or either visual diagnostic as enabled at startup.

## Remaining owner review

Install the verified PR artifact and confirm that the root passage supports
normal swing correction rather than exact centre-line flight, that its branches
read as part of the ceiling and floor, and that a fresh launch shows neither
collision outlines nor unattached-web guides. Then enable each diagnostic
independently under DEBUG → OVERLAYS.
