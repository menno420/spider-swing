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

Reel and Burst are separate native Godot `Button` nodes. Both occupy symmetric
228×228 reference-pixel touch regions, inset 36 pixels from the side and 32 from
the bottom. The drawn circles remain smaller than the forgiving hit boxes. Both
stop pointer events before world input, so neither control releases a web.

Reel guarantees at least the configured inward speed on the first authoritative
tick without removing already-earned inward momentum. It then applies sustained
radial pull and rope shortening while energy lasts, preserving tangential swing.
Burst requires an attached web: it decomposes the current velocity into rope-axis
and tangential components, removes opposing rope-axis motion, guarantees a strong
anchor-directed launch, retains a tunable share of the tangential arc, then
releases the web. Already-earned inward speed is never capped away. Detached Burst
is inert and does not start its 1.65-second cooldown.

Accepted Reel and Burst actions emit domain events. Presentation turns those into
short rope/button flashes, and the input adapter supplies distinct lightweight
Android haptics. These cues report authoritative acceptance; a rejected action
uses the existing unavailable feedback instead of faking a successful pull.

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
- anchor-dominant Burst launch with explicit radial/tangential decomposition,
  preservation of earned inward speed, detached rejection, cooldown, and separate
  GUI/gesture routing;
- deterministic geometry after 10,000 m with a bounded seven-chunk window;
- authoritative obstacle collision outcomes;
- nonlethal upper and lethal lower/left/obstacle boundaries;
- symmetric 228×228 event-consuming Reel and Burst touch targets;
- event-driven visual and haptic success feedback.

## Owner device playtest

Menno's recordings confirmed that the traversal concept is fun and encourages
immediate retries, while the first anchor-pull candidate still felt delayed at the
moments requiring recovery. Install `0.2.2-responsive-pull-test` after uninstalling
the previous ephemerally signed dev app, then verify the corrections:

1. aim naturally one guide interval beyond the old limit and confirm the web lands;
2. press Reel while descending and confirm the fall is arrested immediately;
3. hold Reel through a downward arc and check whether it arrests the fall without
   feeling like a teleport;
4. Burst from webs aimed forward, upward, and slightly backward; confirm each launch
   is unmistakably dominated by the web direction while still carrying some arc;
5. try Burst while detached and confirm it asks for an attachment instead of moving;
6. deliberately tap the outer edge of each thumb control and confirm it still fires;
7. judge whether the action flash and haptic make acceptance immediately legible;
8. compare Balanced, Weighty, and Agile and name the closest baseline.
Phase 1 remains gated on an explicitly approved movement baseline.
