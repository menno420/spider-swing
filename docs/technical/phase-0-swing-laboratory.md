# Phase 0 — Swing Laboratory

> **Status:** `reference`
>
> Playable anchor-pull feel candidate; owner device playtest and baseline approval
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
| Anchor Burst | Tap the large lower-right `BURST`, or double-tap the attached web target | `B` / `burst_action`, or double-click the web target |
| Restart | Tap after death | `R` / `restart_run` |
| Return Home | Tap `MENU` | `Esc` / `ui_cancel` |
| Debug panel | Tap `DEBUG` when enabled | `F1` / `toggle_debug` |

The small ceiling rings are aim guides only. Every point on the cyan underside is
a valid target if it is within the shared 820-pixel web range and attachment cone.
That adds roughly one guide interval beyond the previous 620-pixel limit.

Reel and Burst are separate native Godot `Button` nodes. Reel occupies a 190×190
left-thumb region; Burst occupies a 178×178 right-thumb region. Both stop pointer
events before world input, so neither control releases a web. Reel now applies one
bounded inward response on its first authoritative tick, then sustained radial pull
and rope shortening while energy lasts. Burst requires an attached web: it captures
the current anchor direction, releases, and applies one stronger 440 px/s pull along
that line. Detached Burst is inert and does not start its 1.65-second cooldown.

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
replay, and JSON export. Web range, Reel retraction/engagement, and Burst pull are
runtime-tunable. Diagnostics include Burst cooldown/attachment and retained
stream-chunk indices.

## Verification contract

`python3 tools/verify.py --require-godot` guards:

- named preset validation and fixed-rate trajectory equivalence;
- release-time momentum preservation, first-tick Reel fall arrest, sustained pull,
  and Reel resource behavior;
- arbitrary-point ceiling attachment beyond the old 620-pixel limit rather than
  guide-only attachment;
- anchor-aligned Burst release/impulse, detached rejection, cooldown, and separate
  GUI/gesture routing;
- deterministic geometry after 10,000 m with a bounded seven-chunk window;
- authoritative obstacle collision outcomes;
- nonlethal upper and lethal lower/left/obstacle boundaries;
- large, separated, event-consuming Reel and Burst controls.

## Owner device playtest

Menno's four 1040×480 recordings confirmed that the traversal concept is fun and
encourages immediate retries. Install `0.2.1-anchor-pull-test` after uninstalling
the previous ephemerally signed dev app, then verify the corrections:

1. aim naturally one guide interval beyond the old limit and confirm the web lands;
2. press Reel while descending and judge whether the pull is immediate enough;
3. hold Reel through a downward arc and check whether it arrests the fall without
   feeling like a teleport;
4. Burst from webs aimed forward, upward, and slightly backward; confirm each launch
   follows the web rather than screen-right;
5. try Burst while detached and confirm it asks for an attachment instead of moving;
6. judge whether the slightly stronger pull is enough for a tricky recovery;
7. compare Balanced, Weighty, and Agile and name the closest baseline.
Phase 1 remains gated on an explicitly approved movement baseline.
