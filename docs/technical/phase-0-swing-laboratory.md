# Phase 0 — Swing Laboratory

> **Status:** `reference`
>
> Playable percentage-pull traversal candidate; owner device playtest and
> baseline approval remain open.

The Swing Laboratory answers whether attaching, swinging, releasing, reeling,
bursting, diving, and avoiding readable hazards feels good on a real phone. The
current silhouettes and course loop are test instrumentation, not approved
Phase 1 content.

## Play controls

| Action | Android touch | Desktop |
| --- | --- | --- |
| Attach web | Tap a solid ceiling or obstacle edge above the spider | Left-click a solid above |
| Release web | Tap the world while attached | Left-click while attached |
| Dive Pull | Tap a solid edge at least 28 px below the spider | Left-click a solid below |
| Reel-In | Hold the large lower-left `REEL` control | Hold `reel_in` |
| Anchor Burst | Tap the large lower-right `BURST` while attached, or double-tap any solid target | `B` / `burst_action`, or double-click a solid |
| Restart | Tap after death | `R` / `restart_run` |
| Return Home | Tap `MENU` | `Esc` / `ui_cancel` |
| Debug panel | Tap `DEBUG` when enabled | `F1` / `toggle_debug` |

Every edge in the retained polygon geometry is a valid target: ceiling pieces,
floor branches, hanging shapes, and gate pieces. Aim guides are visual hints
only. A tap may land up to 220 reference pixels from the nearest solid edge, but
the resolved anchor must still be within the shared 1000-pixel candidate web
range. The debug upper limit is 1400 pixels for right-hand reach experiments.

Reel and Burst are separate native Godot `Button` nodes. Both occupy symmetric
228×228 reference-pixel touch regions, inset 36 pixels from the side and 32 from
the bottom. The drawn circles remain smaller than the forgiving hit boxes. Both
stop pointer events before world input, so neither control releases a web.

## Traversal response contract

Normal attachment creates a persistent maximum-length rope with an 8% gentle
catch. It does not add velocity. Tapping again releases and preserves the current
velocity. That `RELEASE` behavior remains the default. DEBUG can switch to
`RETARGET`, where tapping another valid upper solid atomically replaces the web;
an empty-world tap still releases.

Reel immediately shortens the authoritative rope length at 480 px/s in the
Balanced candidate while energy is available. The constraint removes outward
motion and applies capped position correction as the rope tightens; Reel does not
also add a radial acceleration or minimum inward speed. That keeps its job
distinct: change the swing radius without becoming a hidden speed boost.

Anchor Burst is a short deterministic traversal:

- `BURST` uses the attached anchor;
- double-tap resolves the tapped solid atomically, even while detached;
- the spider crosses 50% of the starting anchor distance over 0.20 seconds;
- 62% of tangential velocity is retained and the pull ends with a fixed
  420 px/s radial exit;
- the rope releases when the pull starts.

Neither pull owns input. Tapping a valid upper solid during Burst or Dive Pull
immediately ends the pull at its configured exit velocity and attaches a normal
recovery web. If Android classifies that rapid tap as a double-tap, the
application routes it to the same recovery intent. After a pull ends, a
double-tap made while detached and still cooling down also becomes a normal web
instead of an unavailable Burst. Cooldown still limits repeated power use; it
never locks ordinary web control.

A target below the spider becomes Dive Pull instead of a rope. It crosses 25%
of the starting distance over 0.16 seconds, retains 50% of tangential velocity,
ends with a 280 px/s radial exit, and never remains attached. Burst and Dive Pull
share the 1.65-second cooldown. Both paths are sampled against lethal polygon
geometry so a strong pull used at the wrong time can still cause a collision.

Accepted Reel, Burst, and Dive Pull actions emit domain events. Presentation
turns those into short rope/button flashes and the input adapter supplies
distinct lightweight Android haptics. Rejected actions use unavailable feedback
instead of faking acceptance.

## Streamed prototype course

`CourseStream` derives polygon geometry from deterministic 960-pixel chunk
indices. It retains two chunks behind the spider and four ahead, so distance is
not capped and retained state does not grow with a run.

The first two chunks remain safe and the second introduces one lower practice
anchor. Later chunks vary:

- ceiling height and the presence of ceiling gaps;
- floor-grown and ceiling-hanging branch silhouettes;
- broken-pot gates with a traversable opening;
- short cyan lower-root windows placed before the pattern's key hazard;
- sections between authored windows where no lower target is available.

Obstacle polygons are lethal on contact and also valid anchors. Ceiling polygons
are attachable structural surfaces. The palette is still diagnostic; moving
hazards, collectibles, production balancing, and final object art remain
deferred.

## Debug tuning

The debug panel cycles through all live feel values with `<` and `>` and changes
the selected value with `-` and `+`.

| Debug value | Meaning | Step / range |
| --- | --- | --- |
| `GRAV` | downward acceleration | 40 / 400–1800 |
| `DRIVE` | acceleration toward the distance-based forward target speed | 25 / 100–1000 |
| `RANGE` | maximum resolved web distance | 50 / 500–1400 |
| `TAP` | attached upper-solid tap behavior | `RELEASE` / `RETARGET` |
| `AIM` | accepted distance from a tap to the nearest solid edge | 10 / 80–320 px |
| `CATCH` | rope-length reduction on normal attach | 1% / 0–20% |
| `REEL` | rope shortening speed | 20 / 80–720 px/s |
| `BURST` | Burst share of starting anchor distance | 5% / 10–80% |
| `B TIME` | time taken to cross the Burst share | 0.02 / 0.08–0.40 s |
| `P CD` | shared Burst/Dive cooldown | 0.10 / 0.30–2.50 s |
| `DIVE` | Dive Pull share of starting anchor distance | 5% / 5–50% |
| `D TIME` | time taken to cross the Dive share | 0.02 / 0.08–0.32 s |
| `DAMP` | rope constraint damping | 0.01 / 0–0.30 |

`DRIVE` can be subtle while the spider is already at or above its current target
speed: it accelerates forward only toward that target, while the target itself
increases with distance. It is not a free velocity multiplier.

Diagnostics include active pull kind, pull cooldown, retained stream chunks,
record/replay, and JSON export. Runtime changes reset when the app restarts.

## Verification contract

`python3 tools/verify.py --require-godot` guards:

- all presets and every requested debug-control mapping;
- release-time momentum preservation and speed-neutral Reel shortening;
- arbitrary solid-edge attachment, larger aim forgiveness, and extended range;
- detached targeted Burst, exact 50% traversal, deterministic exit, and cooldown;
- active-pull interruption plus detached cooldown double-tap recovery;
- default manual release and optional atomic RETARGET behavior;
- one-shot downward Dive Pull with exact 25% traversal and no persistent rope;
- obstacle anchoring, polygon collision, and swept pull collision checks;
- deterministic shaped geometry after 10,000 m, authored lower anchor coverage,
  and a bounded seven-chunk window;
- nonlethal upper and lethal lower/left/obstacle boundaries;
- symmetric event-consuming Reel and Burst touch targets;
- fixed-rate trajectory equivalence at simulated 30/60/90/120 Hz render rates.

## Owner device playtest

Install `0.3.1-recovery-web-test` after uninstalling the previous ephemerally
signed dev app, then check:

1. tap naturally on the forward/right side and confirm the 1000-pixel baseline
   reaches useful ceiling and obstacle edges;
2. Burst, then immediately tap an upper solid several times at different points
   in the pull; every valid tap should create a visible recovery web;
3. repeat with fast double-taps during the pull and cooldown; none should report
   `Pull already active` while the spider remains detached;
4. use DEBUG `TAP RELEASE`, then `TAP RETARGET`, and decide whether deliberate
   two-tap release/attach or atomic one-tap replacement feels more natural;
5. hold Reel during a downward arc and judge whether height becomes manageable
   without the previous runaway speed gain;
6. compare several starting web lengths and confirm Burst always covers roughly
   half the visible rope distance;
7. use the cyan lower-root windows before hazards and confirm a 25% Dive Pull
   redirects the spider without leaving a rope attached;
8. deliberately Burst toward a badly timed obstacle and confirm the control
   remains powerful but unsafe;
9. use DEBUG to change range, cooldown, Burst %, Dive %, both durations, and Reel
   speed, then name the closest values;
10. judge whether the lower anchor windows appear when useful without making the
   entire floor a permanent safety net.

Phase 1 remains gated on an explicitly approved movement baseline.
