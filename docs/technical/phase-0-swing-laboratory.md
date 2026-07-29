# Phase 0 — Swing Laboratory

> **Status:** `reference`
>
> Playable percentage-pull traversal candidate; owner device playtest and
> baseline approval remain open.

The Swing Laboratory answers whether attaching, swinging, releasing, reeling,
bursting, diving, and avoiding readable hazards feels good on a real phone. The
current silhouettes and course loop are test instrumentation, not approved
Phase 1 content.

Each run now begins on a normal ceiling web with a deterministic safe
trajectory. The player may override it immediately, but no input is required for
roughly the first second. One optional rescue charge can recover the first lethal
mistake; the HUD always says whether it is ready or spent.

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

Reel immediately shortens the authoritative rope length at 400 px/s in the
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
- the spider crosses 40% of the starting anchor distance, with 80 px minimum
  useful travel, over 0.20 seconds;
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

- continuous ceiling and floor contours that open high/low bypasses or
  occasionally close into a smaller late gap;
- floor-grown leaf clusters and vine forks;
- ceiling-hanging seed pods and leaf clusters;
- broken-pot gates with a traversable opening;
- lower rail targets placed before the pattern's key hazard;
- five-fly arcs that communicate a suggested route;
- sparse Burst Frenzy pickups.

Obstacle polygons are lethal on contact and also valid anchors. Course rails are
attachable structural surfaces, lethal by default, and independently
configurable as visible or absent and safe or lethal. DEBUG draws the predicted endpoint of the nearest
available Dive in green or red. The palette is still diagnostic; moving hazards,
production balancing, and final object art remain deferred.

The default floating-hazard scale is 90%, edge-grown obstacles use 94%, and gate
openings use 112%. These are independent DEBUG values. `CourseStream` scales the
authoritative polygons before either simulation or presentation receives them,
so a smaller drawing can never retain an invisible old collision shape.

Fly and Burst Frenzy pickups are collected with swept tests, so a fast spider
cannot tunnel through them. Burst Frenzy suppresses Anchor Burst cooldown for
four configurable seconds; it does not grant extra Dive Pull charges. Death
creates one idempotent settlement through `ProgressionService`;
`SaveRepository` atomically persists lifetime and spendable fly totals,
profile-specific upgrade levels, selections, the local creator pattern, and
cosmetic milestones. The current fly costs are comparison values only.

## Debug tuning

The touch-first debug panel is split into **Movement**, **Pacing**, **Rope**,
**Pulls**, **Course**, **Routes**, **Run**, and **Tools**. Every section shows
at most six large setting cards.
Each card uses a plain name, one-sentence description, direct comparison values,
and 52-pixel `−` / `+` targets. Presets are named instead of numbered. This
avoids searching through one long carousel during device playtests.

| Debug value | Meaning | Step / range |
| --- | --- | --- |
| `Gravity` | downward acceleration | 40 / 400–1800 |
| `Forward drive` | acceleration toward the distance-based forward target speed | 25 / 100–1000 |
| `Starting speed` | forward target at run start | 20 / 240–520 px/s |
| `Maximum speed` | final forward target | 20 / 500–1000 px/s |
| `Full speed reached` | exact end of the smooth pace ramp | 500 m / 2000–8000 m |
| `Maximum web reach` | maximum resolved web distance | 50 / 500–1400 px |
| `Tap retargets web` | attached upper-solid tap behavior | off / on |
| `Aim forgiveness` | accepted distance from a tap to the nearest solid edge | 10 / 80–320 px |
| `Attach catch-up` | rope-length reduction on normal attach | 1% / 0–20% |
| `Reel-In speed` | rope shortening speed | 20 / 80–720 px/s |
| `Keep shortened rope` | retain natural inward slack | off / on |
| `Shortening retained` | share of natural slack retained | 5% / 0–100% |
| `Anchor Burst distance` | Burst share of starting anchor distance | 5% / 10–80% |
| `Minimum Burst travel` | useful travel floor for a valid close Burst | 10 / 20–260 px |
| `Anchor Burst time` | time taken to cross the Burst share | 0.02 / 0.08–0.40 s |
| `Burst cooldown` | time limit for Anchor Burst only | 0.10 / 0.30–2.50 s |
| `Downward pull distance` | Dive share of starting anchor distance | 5% / 5–60% |
| `Downward pull time` | time taken to cross the Dive share | 0.02 / 0.08–0.32 s |
| `Rope damping` | rope constraint damping | 0.01 / 0–0.30 |
| `Ceiling and floor` | render/target continuous course rails | off / on |
| `Lethal ceiling and floor` | rail contact policy | off / on |
| `Floating hazards begin` | first detached middle-hazard distance | 100 m / 250–2000 m |
| `Edge obstacle size` | scale rail-grown leaves, vines, and pods | 2% / 70–115% |
| `Floating obstacle size` | scale detached middle hazards | 2% / 70–115% |
| `Gate opening size` | widen or tighten broken-pot passages | 4% / 80–140% |
| `Shaped ceiling and floor` | contour continuous rails around challenges | off / on |
| `Bypass room` | extra room on most high/low routes | 10% / 50–150% |
| `Small-gap opening` | occasional late tight-route size | 5% / 75–140% |
| `Opening training web` | start on the ordinary guided ceiling web | off / on |
| `One rescue per run` | recover the first lethal mistake | off / on |
| `Burst Frenzy time` | Anchor Burst cooldown suppression | 0.5 / 1–10 s |
| `One-charge rail bounce` | enable bounded moderate rail recovery | off / on |
| `Maximum safe impact` | fastest charged rail impact that survives | 40 / 300–1100 px/s |
| `Rail bounce strength` | inward speed returned away from the rail | 5% / 20–80% |

`DRIVE` can be subtle while the spider is already at or above its current target
speed: it accelerates forward only toward that target, while the target itself
increases with distance. It is not a free velocity multiplier.

Diagnostics include active pull kind, separate Burst cooldown and Dive-ready
state, retained stream chunks, record/replay, and JSON export. Runtime changes
reset when the app restarts.

These controls are also the measurement surface for possible future upgrades.
The Garage already proves that validated profile and fly-funded upgrade
modifiers can resolve over one base `SwingConfig`; it does not create parallel
physics implementations. Current costs and caps are test data. Record
eligibility, the final economy, and any real-money entitlement remain separate
product decisions.

## Verification contract

`python3 tools/verify.py --require-godot` guards:

- all presets and every requested debug-control mapping;
- release-time momentum preservation and speed-neutral Reel shortening;
- speed-neutral configurable automatic slack take-up;
- arbitrary solid-edge attachment, larger aim forgiveness, and extended range;
- detached targeted Burst, exact configured traversal with an upgradeable
  minimum useful distance, deterministic exit, and cooldown;
- active-pull interruption plus detached cooldown double-tap recovery;
- Dive use during Burst cooldown, contact-only Dive rearm, and clear unavailable
  feedback before rearm;
- default manual release and optional atomic RETARGET behavior;
- one-shot downward Dive Pull with exact 40% traversal and no persistent rope;
- obstacle anchoring, polygon collision, and swept pull collision checks;
- a 1000 m middle-hazard runway, deterministic organic geometry after it,
  continuous shaped lethal-by-default rails with open and tight routes,
  lower-anchor coverage, independently scaled obstacle polygons, creator-pattern
  bounds, and a bounded seven-chunk window;
- a one-second safe guided opening that remains interruptible from its first
  tick;
- one authoritative rescue followed by normal death on the next lethal contact;
- five catalogued spider profiles, three five-level upgrade paths each, a real
  bounded glide state, and Springtail's one-charge moderate rail bounce using
  the same central configuration;
- independently safe/lethal course rails, swept pickups that do not respawn,
  idempotent persistent progression, and milestone cosmetic unlocks;
- nonlethal upper and lethal lower/left/obstacle boundaries;
- symmetric event-consuming Reel and Burst touch targets;
- one gameplay intent for each Android touchscreen press even though the
  Control-based HUD keeps Godot touch-to-mouse emulation enabled;
- fixed-rate trajectory equivalence at simulated 30/60/90/120 Hz render rates.

## Owner device playtest

Install `0.6.0-gradual-progression-test` after uninstalling the previous ephemerally
signed dev app, then check:

1. start a run without touching the screen for one second; the ordinary opening
   web should produce a safe useful first swing instead of a free fall;
2. interrupt the opening immediately with a valid tap and confirm there is no
   input lock or discarded intent;
3. from `RUN ENDED`, tap once to restart and confirm that the same physical tap
   does not also attach a web;
4. Burst, then tap one valid upper solid once; the recovery web must remain
   visibly attached and must not immediately report `Momentum preserved`;
5. repeat the same recovery with fast single taps and double-taps during the
   pull and cooldown; each physical press must produce one resulting action;
6. tap naturally on the forward/right side and confirm the 1000-pixel baseline
   reaches useful ceiling and obstacle edges;
7. Burst, then immediately tap an upper solid several times at different points
   in the pull; every valid tap should create a visible recovery web;
8. repeat with fast double-taps during the pull and cooldown; none should report
   `Pull already active` while the spider remains detached;
9. use DEBUG `TAP RELEASE`, then `TAP RETARGET`, and decide whether deliberate
   two-tap release/attach or atomic one-tap replacement feels more natural;
10. hold Reel during a downward arc and judge whether height becomes manageable
   without the previous runaway speed gain;
11. compare several starting web lengths and confirm base Burst covers roughly
    40% while a close valid target still provides its visible minimum travel;
12. use a lower rail target twice without attaching above between attempts; the
    second must say that an upper web is required, not display a timer;
13. attach a ceiling or upper obstacle, then immediately Dive during an active
    Burst cooldown; confirm the downward pull works and spends its charge;
14. deliberately Burst toward a badly timed obstacle and confirm the control
    remains powerful but unsafe;
15. use each DEBUG section to change range, Burst cooldown, Burst %, Dive %, both
    durations, and Reel speed; confirm no setting requires carousel searching;
16. compare `Keep shortened rope` off/on and several retained percentages; when the spider moves
    toward the anchor, the shorter web should mostly remain short without a speed
    spike;
17. compare rails off, rails safe, and rails lethal; verify continuous shaped
    rails open usable high/low bypasses and only occasionally close into a small
    gap;
18. confirm no detached middle hazard appears before roughly 1000 m, then judge
    whether later leaf, vine, seed-pod, and pot patterns remain readable;
19. compare floating obstacle sizes around 85%, 90%, and 95%, then vary gate
    opening size; collision edges must remain aligned with the silhouettes;
20. deliberately hit a lethal obstacle once and verify `RESCUE READY` becomes
    `RESCUE SPENT`; the next lethal hit must end the run;
21. compare all five Garage profiles, especially Skitter's smaller collision
    radius, Anchorite's weight, Ballooner's visible bounded glide, and
    Springtail's charged moderate rail bounce;
22. spend laboratory flies on one Shop track and confirm the shown resolved
    value changes and survives restart;
23. create a six-piece Course Lab pattern, playtest it after the opening, return
    Home, and confirm the saved pattern remains;
24. follow fly arcs, collect Burst Frenzy, use multiple Bursts before it expires,
    and confirm it does not bypass the upper-web requirement for another Dive.
25. compare full-speed distances around 3000/5000/6500 m and confirm the default
    no longer feels near maximum during the opening kilometre;
26. spend Springtail's shell on a moderate rail hit, confirm a second hit kills,
    then attach an upper web and verify the shell becomes ready again;
27. verify Springtail still dies to obstacles, an excessive rail impact, or
    contact caused by a Burst/Dive pull.

Phase 1 remains gated on an explicitly approved movement baseline.
