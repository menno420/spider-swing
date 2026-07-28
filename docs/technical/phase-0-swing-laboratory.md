# Phase 0 — Swing Laboratory

> **Status:** `reference`
>
> Playable traversal-test candidate; owner device playtest and baseline approval
> remain open.

The Swing Laboratory answers whether attaching, swinging, releasing, reeling,
bursting, and avoiding readable hazards feels good on a real phone. The current
obstacles and course loop are test instrumentation, not approved Phase 1 content.

## Play controls

| Action | Android touch | Desktop |
| --- | --- | --- |
| Attach web | Tap anywhere on the cyan ceiling underside | Left-click the ceiling |
| Release web | Tap the world while attached | Left-click while attached |
| Reel-In | Hold the large lower-left `REEL` control | Hold `reel_in` |
| Forward Burst | Tap the large lower-right `BURST`, or double-tap the attached web target | `B` / `burst_action`, or double-click the web target |
| Restart | Tap after death | `R` / `restart_run` |
| Return Home | Tap `MENU` | `Esc` / `ui_cancel` |
| Debug panel | Tap `DEBUG` when enabled | `F1` / `toggle_debug` |

The small ceiling rings are aim guides only. Every point on the cyan underside is
a valid target if it is within web range and the attachment cone.

Reel and Burst are separate native Godot `Button` nodes. Reel occupies a 190×190
left-thumb region; Burst occupies a 178×178 right-thumb region. Both stop pointer
events before world input, so neither control releases a web. Reel is a held,
energy-limited correction. Burst is a discrete forward impulse with a 1.65-second
cooldown; it releases the current web and adds a small upward stabilisation.

## Endless test course

`CourseStream` derives geometry from deterministic 960-pixel chunk indices. It
retains two chunks behind the spider and four ahead, so distance is not capped by
a prebuilt anchor list and retained state does not grow with a run.

Each chunk owns:

- one continuous web-compatible ceiling segment;
- optional visual aim guides;
- zero or more static obstacle rectangles.

The first two chunks are intentionally safe. Later chunks loop a small graybox
vocabulary: low posts, tall posts, ceiling-hanging blocks, and paired gates. The
orange/yellow diagonal treatment means “lethal obstacle.” Moving hazards,
collectibles, production balancing, and content theming remain deferred.

## Candidate presets and diagnostics

The three candidates remain `balanced_candidate`, `weighty_candidate`, and
`agile_candidate`; none is approved as the baseline. The optional debug panel
still provides fixed-step controls, runtime tuning, deterministic recording and
replay, and JSON export. Diagnostics now include Burst cooldown and retained
stream-chunk indices.

## Verification contract

`python3 tools/verify.py --require-godot` guards:

- named preset validation and fixed-rate trajectory equivalence;
- release-time momentum preservation and Reel resource behavior;
- arbitrary-point ceiling attachment rather than guide-only attachment;
- Burst release, impulse, cooldown, and separate GUI/gesture routing;
- deterministic geometry after 10,000 m with a bounded seven-chunk window;
- authoritative obstacle collision outcomes;
- nonlethal upper and lethal lower/left/obstacle boundaries;
- large, separated, event-consuming Reel and Burst controls.

## Owner device playtest

Install the `0.2.0-traversal-test` Android artifact after uninstalling the previous
ephemerally signed dev app. Please report:

1. whether Settings is comfortably readable and scrolls at 1040×480;
2. whether left-thumb Reel is reachable without looking away from the course;
3. whether Burst feels useful, excessive, or unclear;
4. whether tapping between guide rings attaches where expected;
5. which static obstacle pattern feels unfair or unreadable;
6. whether the course continues well beyond the former 2,000 m region;
7. which physics candidate you prefer, or what each gets wrong.

Phase 1 remains gated on an explicitly approved movement baseline.
