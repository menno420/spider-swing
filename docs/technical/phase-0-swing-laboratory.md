# Phase 0 — Swing Laboratory

> **Status:** implemented candidate; owner device playtest and baseline approval
> remain open.

The Swing Laboratory is the first playable Spider Swing milestone. It exists to
answer one question before content production begins: does attaching, swinging,
releasing, and reeling feel good on a real phone?

It deliberately contains no procedural chunks, obstacles, flies, currency,
progression, alternate spiders, monetization, or production art. Those systems
must not be built around unapproved movement.

## Play controls

| Action | Android touch | Desktop |
| --- | --- | --- |
| Attach web | Tap a visible cyan anchor | Left-click an anchor |
| Release web | Tap anywhere while attached | Left-click while attached |
| Reel-In | Hold the lower-right Reel control | Hold the configured `reel_in` action |
| Restart | Tap after death | `R` / configured `restart_run` |
| Debug panel | Tap `LAB` in the upper-right | `F1` / configured `toggle_debug` |

Touching the Reel control or any debug control never also fires a web. Multiple
touches are tracked independently, so the player may hold Reel with one finger
and attach or release with another.

## Candidate presets

The lab ships three deliberately named candidates:

- `balanced_candidate` — the neutral first tuning pass;
- `weighty_candidate` — more gravity, momentum, and deliberate Reel;
- `agile_candidate` — faster response, lower gravity, and stronger Reel.

None is called a baseline. The owner must play on a real Android device and
choose one, request changes, or reject all three before the Phase 0 exit gate is
complete.

## Debug and reproduction tools

Open the `LAB` panel for:

- pause and single fixed-step;
- quarter-speed simulation;
- gravity, forward drive, Reel rate, and rope-damping adjustment;
- input recording and deterministic replay;
- a diagnostic JSON export containing the seed, preset, position, velocity,
  rope length, Reel energy, and recorded commands.

The export is written to `user://swing_lab_diagnostic.json`. The visible event
message reports the absolute platform path.

Desktop shortcuts:

| Key | Action |
| --- | --- |
| `1`, `2`, `3` | Select candidate preset |
| `,`, `.` | Select previous/next tuning value |
| `-`, `=` | Decrease/increase the selected value |
| `F2` | Pause |
| `F3` | Advance one 60 Hz tick |
| `F4` | Toggle quarter-speed |
| `F6` | Start/stop recording |
| `F7` | Replay |
| `F8` | Export diagnostic JSON |

## Verification contract

`python3 tools/verify.py --require-godot` covers the bootstrap contracts and the
Phase 0 deterministic suite. The suite guards:

- named preset validation;
- release-time velocity preservation;
- Reel shortening without a position teleport;
- inert invalid targets with explicit feedback;
- repeated attach/release without hidden energy injection;
- a nonlethal upper world boundary and lethal lower boundary;
- identical trajectory results when the same timestamped trace is fed from
  simulated 30, 60, 90, and 120 Hz render loops.

The simulation advances only at 60 Hz. Presentation consumes snapshots and
events; it cannot modify authoritative movement.

## Owner device playtest

Download the latest `spider-swing-android-debug` artifact, install it on an
Android phone, and try all three candidates for several minutes.

Please report:

1. the candidate you preferred;
2. whether attaching ever felt delayed or unclear;
3. whether release preserved the momentum you expected;
4. whether Reel felt useful without becoming a teleport;
5. any unfair top, bottom, or left-edge death;
6. the exported diagnostic file after a run that felt wrong.

Phase 1 may begin only after the feel baseline is explicitly approved.
