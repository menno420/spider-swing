# Phase 0.9 burst web independence session

> **Status:** `complete`

## Goal

Make one physical world tap produce exactly one authoritative gameplay intent on
Android, so a recovery web attached during Burst cannot be immediately released
by Godot's emulated mouse copy of the same touchscreen event.

## Previous-session review

**previous-session review:** PR #14 correctly separated ordinary web control from
the pull cooldown inside application and simulation state. The next real-device
recording shows that the adapter still delivers one touchscreen press twice,
which turns the accepted recovery attach into an immediate manual release.

## Shipped

- `InputRouter` now treats raw touchscreen presses as the authoritative world
  input and ignores only `DEVICE_ID_EMULATION` mouse copies. Physical mouse
  input remains supported, and Godot touch-to-mouse emulation remains enabled
  for the Control-owned HUD.
- `project.godot` makes the one-way emulation contract explicit:
  touch-to-mouse is on for mobile Controls, while mouse-to-touch is off.
- The born-red regression first reproduced two web intents from one Android tap.
  Its final form exercises single tap, double-tap, physical mouse, and the full
  post-Burst adapter→session→simulation handoff; the recovery web remains
  attached after the exact device event pair.
- Build `0.3.2-single-intent-test`, Android version code 9, and label
  `Spider Swing Single-Intent Web (dev)` uniquely identify the corrected APK.

## Decisions flagged

- Deduplication belongs at the adapter boundary [D-0005]. Simulation commands
  remain source-agnostic and deterministic; application and simulation do not
  acquire platform timing heuristics.
- The filter is deliberately limited to emulated mouse events that reach
  gameplay `_unhandled_input`. It does not disable the emulation that Godot
  Controls use for the mobile HUD.

## 💡 Idea

Add a developer-only input receipt to diagnostic exports: source kind, Godot
event ID, accepted intent, command sequence, and fixed tick. Future recordings
could then prove pointer arbitration without inferring it from feedback text.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

- The new test failed born-red with:
  `one touchscreen tap plus its emulated mouse copy emitted 2 web intents and 0
  Burst intents`.
- Local
  `GODOT_BIN=/tmp/spider-swing-godot-4.7.1/Godot_v4.7.1-stable_linux.x86_64 python3 tools/verify.py`
  passed all six stages: 14 architecture fixtures, live inward scan, Godot
  4.7.1 discovery, clean import, boot smoke, and **53/53** runtime contracts
  (23 physics, 12 mobile HUD, 8 front-end, 10 bootstrap/build).
- PR #15 `game-quality` run
  [30396476300](https://github.com/menno420/spider-swing/actions/runs/30396476300)
  passed the same 53 contracts at implementation source
  `4ecc2968c2404edca9c8c4125c48d44eff02a554`.
- PR #15 `android-debug` run
  [30396475709](https://github.com/menno420/spider-swing/actions/runs/30396475709)
  produced
  [`spider-swing-android-debug`](https://github.com/menno420/spider-swing/actions/runs/30396475709/artifacts/8703014230)
  artifact `8703014230`. The downloaded 56,750,675-byte ZIP matched
  `sha256:f8f0b92751aa1dc752fc9d72c59e821b6ac72ae69dc8592c8071612a8214ae71`;
  its 57,132,620-byte APK passed archive verification and had SHA-256
  `1a184b6b99ab8915090fbbfc812850296e1250e61ec207776307b3b1024caac1`.
  `build-info.txt` proves version `0.3.2-single-intent-test`, source
  `4ecc2968c2404edca9c8c4125c48d44eff02a554`, package
  `com.menno420.spiderswing.dev`, and display name
  `Spider Swing Single-Intent Web (dev)`.
- The pre-close strict gate reported only this card's intentional
  `in-progress` hold as exit-affecting; its guard-fire telemetry is retained.

## Documentation audit

README, tests guide, Phase 0 playtest guide, current-state, decision and
capability ledgers, project/export identity, workflow assertions, and session
evidence describe the same single-intent boundary as source. The checksum-pinned
GDD was not modified.

## Remaining owner review

Install the PR #15 APK. One tap from `RUN ENDED` must restart without also
attaching. Then Burst and tap one valid upper solid once: the recovery web must
remain visible and must not immediately report `Momentum preserved`. Repeat with
fast taps and double-taps before resuming broader feel tuning.

## Pull request

- PR [#15](https://github.com/menno420/spider-swing/pull/15) is ready; the
  implementation `game-quality` and Android workflows are green. The Substrate
  gate is intentionally held by this card until the final status flip.
