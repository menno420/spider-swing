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
only and load hidden. DEBUG → OVERLAYS can reveal them without enabling
collision outlines. A tap may land up to 220 reference pixels from the nearest solid edge, but
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

Reel immediately shortens the authoritative rope length at 320 px/s in the
Balanced candidate while energy is available. A full level-zero meter lasts
2.0 seconds and can therefore remove about 640 px. Maxing Silk Winder raises
the Garden response to 416 px/s; maxing Silk Reserve as well extends that rate
to 2.48 seconds. The constraint removes outward motion and applies capped position
correction as the rope tightens; Reel does not add radial acceleration, a
minimum inward speed, or a forward boost. That keeps its job distinct: change
the swing radius without replacing manual swing timing.
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
middle-lane hazards. Independently, the first 2000 metres forbid inward rail
movement: a route may hold the normal corridor or move one or both rails
outward, but it cannot pinch the player. Sparse silhouettes may grow from an
existing rail, while the player learns the corridor, ceiling web, lower Dive
routes, flies, and recovery timing. Later chunks vary:

- continuous ceiling and floor contours that open high/low/centre bypasses or,
  after the protected distance, occasionally form a rail-only smaller gap;
- floor-grown leaf clusters and vine forks;
- ceiling-hanging seed pods and leaf clusters;
- broad root passages grown from both rails, with a steerable centre opening;
- post-2000 m high→low and low→high weave pairs, each with seven flies along a
  full Classic-sized safe curve between shorter alternating rail growth, 420 px
  of cue spacing, and a separately tested central transition band;
- compact post-2000 m seed burrs suspended in old silk, with the complete
  collision bounded to the small visible bramble rather than its safe thread;
- lower rail targets placed before the pattern's key hazard;
- five-fly trails placed from the same route plan that shapes the rails and
  selected obstacle;
- sparse Burst Frenzy pickups.

Obstacle polygons are lethal on contact and also valid anchors. Course rails are
attachable structural surfaces, lethal by default, and independently
configurable as visible or absent and safe or lethal. DEBUG → OVERLAYS can draw
the predicted endpoint of the nearest available Dive in green or red. Four
generated environment packs now texture the
same polygons for art-direction comparison. Ancient Forest additionally composes
finished candidate branch, bramble, hanging-vine, Classic spider, and fly
sprites around those exact authoritative bounds. Its transparent obstacle
art replaces the prototype filled polygon rather than revealing that old shape
underneath. Wall-grown art overlaps behind the branch rail and the continuous
rail is redrawn over the join; aspect-preserving source crops prevent non-uniform
sprite distortion. The broad passage is two natural rail-grown hazards around
the same authoritative opening, not a stretched circular sprite. If a required
art asset is missing, presentation falls back to the
textured geometry instead of creating an invisible hazard. Normal play removes
graphic collision outlines and web-target guides; the two independent OVERLAYS
switches restore only the requested diagnostics.
The other three material packs remain prototype comparisons. Moving hazards,
production balancing, and final art for the other spider profiles remain
deferred.

The default floating-hazard scale is 90%, edge-grown obstacles use 94%, and gate
openings use 112%. Small hazards receive a gradual 8–16% post-runway growth
factor; the wide root opening never shrinks. These are independent DEBUG values.
`CourseStream` scales the authoritative polygons before either simulation or
presentation receives them, so a smaller drawing can never retain an invisible
old collision shape.

Fly and Burst Frenzy pickups are collected with swept tests, so a fast spider
cannot tunnel through them. Burst Frenzy suppresses Anchor Burst cooldown for
four configurable seconds; it does not grant extra Dive Pull charges. Death
creates one idempotent settlement through `ProgressionService`;
`SaveRepository` atomically persists lifetime and spendable fly totals,
profile-specific upgrade levels, selections, the local creator pattern, and
cosmetic milestones. Schema 5 retains the proportional former-five-level
migration, records reached 5000 m region checkpoints, and infers existing
schema-4 checkpoint access from standard best distance exactly once. Practice
settlements grant no flies and cannot update records. The current fly costs are
comparison values only.

## Debug tuning

The touch-first debug panel is split into **Movement**, **Pacing**, **Rope**,
**Pulls**, **Course**, **Routes**, **Run**, **Special**, **Look**, **Overlays**,
and **Tools**. Every tuning section shows at most six large setting cards.
Each card uses a plain name, one-sentence description, direct comparison values,
and 52-pixel `−` / `+` targets. Presets are named instead of numbered. This
avoids searching through one long carousel during device playtests.

When Debug Tools are enabled, Home owns the primary **Debug Test Run** setup.
Before play begins, it stages a typed exact distance with large 100 m `−` / `+`
controls and 0/5000/10000/25000 m shortcuts. It also stages one temporary level
across all seven selected-spider tracks through large `−` / `+` controls plus
`OWNED`, L0, L10, and `MAX`. The overlay is not applied until the explicit
no-awards start action. That start routes through `RUN_PRACTICE`, so it awards
no flies, best distance, checkpoint, record, or future leaderboard eligibility.

**Run** retains the same two controls for adjustments during a mounted test.
`Start at exact distance` accepts a typed metre value through a visible
48-pixel `GO`, Enter/Done, or focus loss. `Temporary upgrade level` resolves
every track through the same session-only `ProgressionService` overlay. Neither
surface changes `PlayerProgress`; Shop purchases pause while the overlay is
active, and Garage, Shop, HUD, and restart feedback disclose that the level is
not owned and the run awards nothing. `OWNED` and every ordinary Play/Course
Lab/Region Practice start clear the overlay and restore the exact saved levels.
Both setup surfaces disappear when `show_debug_tools` is off.

**Special** holds Burst reserve/Frenzy and Buckler's bounded rail-recovery
controls. Moving those existing controls out of Run/Pulls keeps the complete
1280×720 panel within its measured six-card grid; no tuning value changed.

**Look** uses five larger preview cards rather than numeric tuning: Graybox,
Ancient Forest, Mossy Ravine, Overgrown Greenhouse, and Reclaimed Attic. The
selector changes only presentation-owned texture, object art, and palette data.
Graybox remains the exact silhouette check; selecting a look cannot resize,
move, add, or remove a collision surface. Ancient Forest uses natural art in
normal play. **Overlays** contains separate, off-by-default switches for exact
collision outlines and web-target guides.

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
| `Full Reel time` | continuous hold time from a full meter | 0.2 / 0.8–4.0 s |
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
| `Gate opening size` | widen or tighten rail-grown root passages | 4% / 80–140% |
| `Shaped ceiling and floor` | contour continuous rails around challenges | off / on |
| `Bypass room` | extra room on most high/low routes | 10% / 50–150% |
| `Small-gap opening` | height of later rail-only inward passages | 5% / 75–140% |
| `Inward rails begin` | first distance where a rail-only passage may narrow | 250 m / 1000–8000 m |
| `Opening training web` | start on the ordinary guided ceiling web | off / on |
| `One rescue per run` | recover the first lethal mistake | off / on |
| `Start at exact distance` | restart a no-awards debug run at typed metres on the active seed | typed 0–100,000 m with 48 px `GO`; 100 m `−` / `+` |
| `Temporary upgrade level` | resolve selected-spider tracks without changing ownership | `OWNED`, 0–20, or one-tap `MAX` |
| `Stored Bursts` | comparison capacity for serially refilled Anchor Burst charges | 1 / 1–3 |
| `Burst Frenzy time` | Anchor Burst cooldown suppression | 0.5 / 1–10 s |
| `One-charge rail bounce` | enable bounded moderate rail recovery | off / on |
| `Maximum safe impact` | fastest charged rail impact that survives | 40 / 300–1100 px/s |
| `Rail bounce strength` | inward speed returned away from the rail | 5% / 20–80% |

`DRIVE` can be subtle while the spider is already at or above its current target
speed: it accelerates forward only toward that target, while the target itself
increases with distance. It is not a free velocity multiplier.

Diagnostics include active pull kind, separate Burst cooldown and Dive-ready
state, retained stream chunks, debug start/overlay identity, record eligibility,
record/replay, and JSON export. Runtime changes reset when the app restarts.

These controls are also the measurement surface for possible future upgrades.
The Garage and seven-track Shop prove that validated profile and fly-funded
upgrade modifiers can resolve over one base `SwingConfig`; they do not create
parallel physics implementations. The five shared core tracks and two identity
tracks each have 20 small levels with deterministic 5/10/15/20 breakthrough
steps. Current costs and caps are test data. Record
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
- a 1000 m middle-hazard runway plus a 2000 m no-inward-rail period,
  deterministic organic geometry after it, one shared route plan for rails,
  fly guidance, and obstacles, rail-only late tight routes, lower-anchor
  coverage, independently scaled obstacle polygons, creator-pattern bounds, a
  three-lane Classic-sized steering-envelope sweep through root passages,
  high↔low weave envelopes, minimum cue spacing, a forgiving central transition
  band in the shared patterns, Bramble-specific pairs that block the neutral
  middle line while keeping their Classic-sized guide clear, small detached-burr
  bounds, and a bounded
  seven-chunk window;
- a one-second safe guided opening that remains interruptible from its first
  tick;
- one authoritative rescue followed by normal death on the next lethal contact;
- five catalogued spider profiles, five shared core plus two identity upgrade
  paths each, 20-level bounds, deterministic breakthroughs, level-zero
  preservation, a real bounded glide state, and Buckler's one-charge
  moderate rail bounce using the same central configuration;
- independently safe/lethal course rails, swept pickups that do not respawn,
  idempotent persistent progression, and milestone cosmetic unlocks;
- nonlethal upper and lethal lower/left/obstacle boundaries;
- symmetric event-consuming Reel and Burst touch targets;
- one gameplay intent for each Android touchscreen press even though the
  Control-based HUD keeps Godot touch-to-mouse emulation enabled;
- fixed-rate trajectory equivalence at simulated 30/60/90/120 Hz render rates.
- all twenty finished-art runtime textures—including the six-asset Bramble
  Canopy pack—load through one presentation-owned catalog without changing
  authoritative course geometry; foreground region selection is world-anchored
  and the backdrop transition honors Reduced Motion.
- custom spider/web presentation interpolates fixed snapshots, snaps teleports,
  honors reduced motion, and uses mipmaps for heavily minified moving art.
- an arbitrary debug start inherits practice settlement ownership and cannot
  grant flies, records, checkpoints, or leaderboard eligibility;
- geometry at an off-grid debug distance exactly equals the same seed streamed
  sequentially from zero;
- the selectable upgrade overlay never serializes, affects only the selected
  spider, makes its run noncompetitive, and restores the exact saved level
  dictionary when disabled;
- a real Swing Lab view and native input surface instantiated in a 1280×720
  headless `SubViewport` keep all category tabs, all six-card sections, the typed
  distance field, and its 48-pixel `GO` target inside the panel; a connected
  input-router/session contract applies typed distance, `MAX`, and `OWNED` to the
  live run; DEBUG-off hides every depth control.
- a real Front End instantiated in a 1280×720 headless `SubViewport` encloses
  the 1088×533 pre-run card, 64-pixel `−` / `+`, and 68-pixel start action; a
  joined contract stages an off-grid distance and upgrade level, starts the
  authoritative practice session, and proves ordinary Play clears the overlay.

## Owner device playtest

Install `0.20.0-bramble-canopy` over `0.19.0-depth-testing` or any later
stable-key build without uninstalling; both use the stable signer and the update
should preserve the save.
Only a device that never installed `0.19.0` or later needs the one final
uninstall from the old throwaway-signer era.

Before the traversal checklist, prove the new depth-access gate:

- change a visible setting, collect flies, buy at least one real upgrade, and
  retain the app for the next build; after installing that later build without
  uninstalling, verify the setting, balance, owned level, best distance, and
  checkpoints are unchanged;
- enable Debug Tools, return Home, open `DEBUG TEST RUN`, type an off-grid value
  such as `12345.7`, use the large upgrade `−` / `+`, and tap the single start
  action; confirm the HUD says
  `DEBUG START 12346 m … AWARDS NOTHING` (rounded only for HUD copy);
- play and die from that start; flies, best distance, checkpoint access, and
  owned upgrades must remain unchanged;
- return to the pre-run setup, set temporary upgrades to `MAX`, compare the
  upgraded feel, return to
  Garage and Shop, and verify both say the level is a debug overlay and
  `NOT OWNED`;
- switch the level back to `OWNED` and confirm the exact prior Shop levels and
  balance return. Turn Debug Tools off in Settings and confirm neither depth
  control is reachable.
- start at 4900 m and cross 5000 m normally: braided green rails and canopy
  hazards should approach from the right before the lime-lit backdrop replaces
  Ancient Forest, while Reduced Motion makes the backdrop switch immediate;
- start directly at 5000 m and confirm the complete Bramble pack appears at
  once. Its authored pair should demand a visible high↔low commitment rather
  than a neutral centre line. Compare `OWNED` and `MAX`: Reel should reward an
  early route read and arc setup, while Burst remains the faster late height
  correction. This is a role check, not a request to make both controls equal;
- at 10000 m, record Silk Hollow's gameplay separately. Its dedicated
  background/obstacle pack is not built yet, and the current stream remains
  Silk Hollow after 10000 m; do not count either limitation as a Bramble
  regression.

Then check the traversal baseline:

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
10. use level-zero Garden, hold Reel continuously, and confirm its full ring
    lasts about two seconds, responds at 320 px/s, and changes height/arc
    without a separate forward shove;
11. use Home → `DEBUG TEST RUN` to compare owned Garden against
    max, and confirm max Silk Winder resolves to 416 px/s and supplies enough
    deliberate high↔low correction near 5000 m;
12. compare several starting web lengths and confirm base Burst covers roughly
    40% while a close valid target still provides its visible minimum travel;
13. use a lower rail target twice without attaching above between attempts; the
    second must say that an upper web is required, not display a timer;
14. attach a ceiling or upper obstacle, then immediately Dive during an active
    Burst cooldown; confirm the downward pull works and spends its charge;
15. deliberately Burst toward a badly timed obstacle and confirm the control
    remains powerful but unsafe;
16. use each DEBUG section to change range, Burst cooldown, Burst %, Dive %, both
    durations, Reel speed, and Full Reel time; confirm no setting requires
    carousel searching;
17. compare `Keep shortened rope` off/on and several retained percentages; when the spider moves
    toward the anchor, the shorter web should mostly remain short without a speed
    spike;
18. compare rails off, rails safe, and rails lethal; verify continuous shaped
    rails open usable high/low bypasses and only occasionally close into a small
    gap;
19. confirm no large middle-lane challenge appears before roughly 1000 m, then
    judge whether later leaf, vine, seed-pod, and root patterns remain readable;
20. compare floating obstacle sizes around 85%, 90%, and 95%, then vary gate
    opening size; every root passage must remain steerable and its collision
    edges must remain aligned with the silhouettes;
21. open DEBUG → OVERLAYS and verify collision outlines and web-target guides
    begin off, can be enabled independently, and return off in a new run;
22. deliberately hit a lethal obstacle once and verify `RESCUE READY` becomes
    `RESCUE SPENT`; the next lethal hit must end the run;
23. compare all five Garage profiles, especially the Magnolia Green Jumper's smaller collision
    radius, Anchorite's weight, Ballooner's visible bounded glide, and
    Buckler's charged moderate rail bounce;
24. on maxed Balanced Flow, confirm the description says automatic take-up
    keeps less slack and shortens the web; then spend laboratory flies through
    levels 4→5 on one Shop track, confirm the button says `BREAKTHROUGH ×2`,
    the card says that level 5 grants two tuning steps, the resolved value
    changes twice, the silk knot fills, and the level survives restart;
25. create a six-piece Course Lab pattern, playtest it after the opening, return
    Home, and confirm the saved pattern remains;
26. follow fly arcs, collect Burst Frenzy, use multiple Bursts before it expires,
    and confirm it does not bypass the upper-web requirement for another Dive.
27. compare full-speed distances around 3000/5000/6500 m and confirm the default
    no longer feels near maximum during the opening kilometre;
28. spend Buckler's shell on a moderate rail hit, confirm a second hit kills,
    then attach an upper web and verify the shell becomes ready again;
29. verify Buckler still dies to obstacles, an excessive rail impact, or
    contact caused by a Burst/Dive pull.
30. compare the spider at steady speed, during Reel, and during Burst on the
    1040×480 device recording path; confirm it no longer vibrates or leaves the
    attached web behind, and that the restrained poses remain readable.
31. swipe Shop and Settings starting on the purchase button, description text,
    milestone row, panel edge, toggles, and empty card space; every drag should
    move one smooth inertial list, while a short tap should still activate only
    its original control. Then compare Classic, Dew, and Ember in the live Silk
    preview;
32. after 2000 m, follow both seven-fly weave curves and confirm the shorter,
    wider-spaced growth asks for a readable high→low or low→high change without
    clipping either obstacle or showing a rectangular art cut;
33. pass the small silk-suspended burr above and below; its visible bramble,
    collision outline, and safe support thread must agree.
34. use the pre-run upgrade `−` / `+` and toggle `OWNED` / `MAX` to compare the
    exact same saved Garden. Max Silk Winder + Silk Reserve should offer clearly
    stronger and longer arc correction, but neither version should feel
    mandatory for every ordinary route; `OWNED` must restore the saved levels.
35. switch repeatedly between Garden and Anchorite in the Garage and in play.
    Anchorite should read as a broad, low, heavy burrowing spider at gameplay
    size, retain clean alpha without a magenta fringe, rotate and pose smoothly,
    and remain aligned with the unchanged collision outline.

Phase 1 remains gated on an explicitly approved movement baseline.
