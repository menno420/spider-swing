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
Natural inward movement now creates slack take-up as a separate, speed-neutral
rule: Balanced retains 85% of each new inward movement, leaving 15% elastic give.
Static slack is not repeatedly consumed. DEBUG can disable the behavior or tune
the retained share from 0–100%.

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

A target below the spider becomes Dive Pull instead of a rope. It crosses 40%
of the starting distance over 0.16 seconds, retains 50% of tangential velocity,
ends with a 280 px/s radial exit, and never remains attached. Dive Pull has no
timer. Using it spends one Dive charge; the next successful normal web
attachment above the spider, including an obstacle attachment, immediately
rearms it. Time passing and Burst Frenzy do not. Anchor Burst alone uses the
1.65-second cooldown. Both paths are sampled against lethal polygon geometry so
a strong pull used at the wrong time can still cause a collision.

Accepted Reel, Burst, and Dive Pull actions emit domain events. Presentation
turns those into short rope/button flashes and the input adapter supplies
distinct lightweight Android haptics. Rejected actions use unavailable feedback
instead of faking acceptance.

## Streamed prototype course

`CourseStream` derives polygon geometry from deterministic 960-pixel chunk
indices. It retains two chunks behind the spider and four ahead, so distance is
not capped and retained state does not grow with a run.

The first 1000 displayed metres are a learning runway with no detached
middle-lane hazards. Sparse silhouettes may grow from an existing rail, but the
player first learns the corridor, ceiling web, lower Dive routes, flies, and
recovery timing. Later chunks vary:

- ceiling and floor height plus deliberate gaps on either side;
- floor-grown leaf clusters and vine forks;
- ceiling-hanging seed pods and leaf clusters;
- broken-pot gates with a traversable opening;
- lower rail targets placed before the pattern's key hazard;
- five-fly arcs that communicate a suggested route;
- sparse Burst Frenzy pickups.

Obstacle polygons are lethal on contact and also valid anchors. Course rails are
attachable structural surfaces and are independently configurable as visible or
absent, and safe or lethal. DEBUG draws the predicted endpoint of the nearest
available Dive in green or red. The palette is still diagnostic; moving hazards,
production balancing, and final object art remain deferred.

Fly and Burst Frenzy pickups are collected with swept tests, so a fast spider
cannot tunnel through them. Burst Frenzy suppresses Anchor Burst cooldown for
four configurable seconds; it does not grant extra Dive Pull charges. Death
creates one idempotent settlement through `ProgressionService`;
`SaveRepository` atomically persists fly totals and the 25-fly/1000-m cosmetic
milestones. This proves ownership and save flow without inventing the final
economy or upgrade prices.

## Debug tuning

The touch-first debug panel is split into **Movement**, **Rope**, **Pulls**,
**Course**, and **Tools**. Every section shows at most six large setting cards.
Each card uses a plain name, one-sentence description, direct comparison values,
and 52-pixel `−` / `+` targets. Presets are named instead of numbered. This
avoids searching through a 19-item carousel during device playtests.

| Debug value | Meaning | Step / range |
| --- | --- | --- |
| `Gravity` | downward acceleration | 40 / 400–1800 |
| `Forward drive` | acceleration toward the distance-based forward target speed | 25 / 100–1000 |
| `Maximum web reach` | maximum resolved web distance | 50 / 500–1400 px |
| `Tap retargets web` | attached upper-solid tap behavior | off / on |
| `Aim forgiveness` | accepted distance from a tap to the nearest solid edge | 10 / 80–320 px |
| `Attach catch-up` | rope-length reduction on normal attach | 1% / 0–20% |
| `Reel-In speed` | rope shortening speed | 20 / 80–720 px/s |
| `Keep shortened rope` | retain natural inward slack | off / on |
| `Shortening retained` | share of natural slack retained | 5% / 0–100% |
| `Anchor Burst distance` | Burst share of starting anchor distance | 5% / 10–80% |
| `Anchor Burst time` | time taken to cross the Burst share | 0.02 / 0.08–0.40 s |
| `Burst cooldown` | time limit for Anchor Burst only | 0.10 / 0.30–2.50 s |
| `Downward pull distance` | Dive share of starting anchor distance | 5% / 5–60% |
| `Downward pull time` | time taken to cross the Dive share | 0.02 / 0.08–0.32 s |
| `Rope damping` | rope constraint damping | 0.01 / 0–0.30 |
| `Ceiling and floor` | render/target continuous course rails | off / on |
| `Lethal ceiling and floor` | rail contact policy | off / on |
| `Floating hazards begin` | first detached middle-hazard distance | 100 m / 250–2000 m |
| `Burst Frenzy time` | Anchor Burst cooldown suppression | 0.5 / 1–10 s |

`DRIVE` can be subtle while the spider is already at or above its current target
speed: it accelerates forward only toward that target, while the target itself
increases with distance. It is not a free velocity multiplier.

Diagnostics include active pull kind, separate Burst cooldown and Dive-ready
state, retained stream chunks, record/replay, and JSON export. Runtime changes
reset when the app restarts.

These controls are also the measurement surface for possible future upgrades.
Reel rate, Burst share, cooldown, and later glide response can become validated
modifiers over one base `SwingConfig`; they must not create parallel physics
implementations. Costs, caps, record eligibility, and the final economy remain a
separate product decision and are intentionally not inferred from DEBUG values.

## Verification contract

`python3 tools/verify.py --require-godot` guards:

- all presets and every requested debug-control mapping;
- release-time momentum preservation and speed-neutral Reel shortening;
- speed-neutral configurable automatic slack take-up;
- arbitrary solid-edge attachment, larger aim forgiveness, and extended range;
- detached targeted Burst, exact 50% traversal, deterministic exit, and cooldown;
- active-pull interruption plus detached cooldown double-tap recovery;
- Dive use during Burst cooldown, contact-only Dive rearm, and clear unavailable
  feedback before rearm;
- default manual release and optional atomic RETARGET behavior;
- one-shot downward Dive Pull with exact 40% traversal and no persistent rope;
- obstacle anchoring, polygon collision, and swept pull collision checks;
- a 1000 m middle-hazard runway, deterministic organic geometry after it,
  lower-anchor coverage, and a bounded seven-chunk window;
- independently safe/lethal course rails, swept pickups that do not respawn,
  idempotent persistent progression, and milestone cosmetic unlocks;
- nonlethal upper and lethal lower/left/obstacle boundaries;
- symmetric event-consuming Reel and Burst touch targets;
- one gameplay intent for each Android touchscreen press even though the
  Control-based HUD keeps Godot touch-to-mouse emulation enabled;
- fixed-rate trajectory equivalence at simulated 30/60/90/120 Hz render rates.

## Owner device playtest

Install `0.4.1-debug-lab-dive-reset-test` after uninstalling the previous ephemerally
signed dev app, then check:

1. from `RUN ENDED`, tap once to restart and confirm that the same physical tap
   does not also attach a web;
2. Burst, then tap one valid upper solid once; the recovery web must remain
   visibly attached and must not immediately report `Momentum preserved`;
3. repeat the same recovery with fast single taps and double-taps during the
   pull and cooldown; each physical press must produce one resulting action;
4. tap naturally on the forward/right side and confirm the 1000-pixel baseline
   reaches useful ceiling and obstacle edges;
5. Burst, then immediately tap an upper solid several times at different points
   in the pull; every valid tap should create a visible recovery web;
6. repeat with fast double-taps during the pull and cooldown; none should report
   `Pull already active` while the spider remains detached;
7. use DEBUG `TAP RELEASE`, then `TAP RETARGET`, and decide whether deliberate
   two-tap release/attach or atomic one-tap replacement feels more natural;
8. hold Reel during a downward arc and judge whether height becomes manageable
   without the previous runaway speed gain;
9. compare several starting web lengths and confirm Burst always covers roughly
   half the visible rope distance;
10. use a lower rail target twice without attaching above between attempts; the
    second must say that an upper web is required, not display a timer;
11. attach a ceiling or upper obstacle, then immediately Dive during an active
    Burst cooldown; confirm the downward pull works and spends its charge;
12. deliberately Burst toward a badly timed obstacle and confirm the control
    remains powerful but unsafe;
13. use each DEBUG section to change range, Burst cooldown, Burst %, Dive %, both
    durations, and Reel speed; confirm no setting requires carousel searching;
14. compare `Keep shortened rope` off/on and several retained percentages; when the spider moves
    toward the anchor, the shorter web should mostly remain short without a speed
    spike;
15. compare rails off, rails safe, and rails lethal; verify the deliberate gaps
    still permit occasional travel above/below the ordinary corridor;
16. confirm no detached middle hazard appears before roughly 1000 m, then judge
    whether later leaf, vine, seed-pod, and pot patterns remain readable;
17. follow fly arcs, collect Burst Frenzy, use multiple Bursts before it expires,
    and confirm it does not bypass the upper-web requirement for another Dive.

Phase 1 remains gated on an explicitly approved movement baseline.
