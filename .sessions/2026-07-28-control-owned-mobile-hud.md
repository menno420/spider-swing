# Control-owned mobile HUD correction session

> **Status:** `complete`

## Goal

Use Menno's second real-device failure to eliminate manual touch-coordinate
assumptions, make Reel and DEBUG true Godot GUI controls that consume input before
world taps, and produce an unmistakably versioned replacement APK.

## Scope guard

This session changed the mobile input adapter, presentation build marker, debug
package version, tests, Android artifact provenance, and truthful ledgers. It did
not retune swing physics, select a baseline, add Phase 1 content, or modify the
frozen GDD.

## Previous-session review

**previous-session review:** merged PR #7, its 21 runtime checks, the owner's
second phone result, and the unchanged on-device behavior were reviewed.
Automated coordinate proofs did not establish actual Android event routing or
artifact identity. PR #7's device handoff is therefore recorded as superseded,
not counted as a successful control correction.

## Result

- Reel, DEBUG, and every debug-panel hit region are native Godot `Button`
  controls with `MOUSE_FILTER_STOP`.
- World attach/release input moved from `_input` to `_unhandled_input`, after
  GUI event consumption.
- Reel button press/release emits held state without creating a web-tap command.
- The HUD displays `BUILD 0.0.2-control-ui`; Android version code is 2 and the
  app label is `Spider Swing UI2 (dev)`.
- Gameplay PRs produce source-identified Android artifacts containing
  `build-info.txt`.
- The current ephemeral signing limitation is explicit: the old dev app must be
  uninstalled before installing a replacement CI APK.

## Verification

- `game-quality` run
  [30356316095](https://github.com/menno420/spider-swing/actions/runs/30356316095)
  passed with 22/22 runtime contracts.
- `android-debug` run
  [30356316047](https://github.com/menno420/spider-swing/actions/runs/30356316047)
  passed from source
  `3322e8ca9fbac1771a761d39dcc798b3584f70f7`.
- Artifact `spider-swing-android-debug` ID `8686961396` was downloaded:
  56,653,674 bytes; SHA-256
  `06f3d5b4b8069e0f4e391d541fa3e7509cf8922bf6de203860116fa455159fd5`.
- Its `build-info.txt` proves version `0.0.2-control-ui`, package
  `com.menno420.spiderswing.dev`, display name
  `Spider Swing UI2 (dev)`, and the exact source SHA above.
- Final `substrate-gate` and `game-quality` results are required on this
  completed card before PR #8 may merge.

## Docs audit

**docs audit:** updated the Phase 0 laboratory guide, current-state ledger,
heartbeat, PR body, and Phase 0 issue with the second device failure, native GUI
input contract, exact artifact evidence, and uninstall-first instruction. The
frozen GDD was not edited.

## Owner verification

Uninstall the currently installed Spider Swing development app, download the
artifact from Android run 30356316047, install `spider-swing-debug.apk`, and
launch **Spider Swing UI2 (dev)**. Confirm the lower-left HUD reads
`BUILD 0.0.2-control-ui` before testing DEBUG and Reel. Physical success remains
an owner-controlled Phase 0 gate and is not claimed by this session.

## 💡 Idea

Let Godot's GUI pipeline own HUD geometry and event consumption, while world taps
use `_unhandled_input`. Pair every phone-test APK with an always-visible build
identifier and source manifest so a future device report is tied to an exact
binary rather than an ambiguous artifact name.

- **📊 Model:** gpt-5 · high · runtime bugfix
