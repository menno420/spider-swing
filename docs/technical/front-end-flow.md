# Front-end flow

> **Status:** `reference`

Spider Swing opens into a player-facing front end before any simulation exists.
The composition root owns the transition between front end and run; presentation
cannot start or persist a run by itself.

## Screens

### Home

**Home is the run you are about to start, not an index of places to go.** It
fills the landscape with two columns:

- an **identity card** — the selected production spider, its role, and its art;
- a **run column** (`HomeRunColumn`) — the difficulty choice, the personal best
  with the region it was set in, three loadout chips grouped by the catalogue's
  own scopes, and `▶ START RUN`, which is **the only filled control in the whole
  front end**. A contract asserts that by comparing style-box luminance;
- a **route rail** (`HomeRouteGrid`) — the four intentions, each carrying a live
  badge drawn from `PlayerProgress`: **Spider** (choose · style · improve),
  **Play Modes** (campaign · practice · creator), **Guide** (learn controls ·
  meet spiders), and **Settings** (sound · motion · access);
- **Debug Test Run** *(when Debug Tools is enabled)* — subordinate beneath the
  rail, a direct utility for quick noncompetitive launches; Advanced Test Lab is
  one more tap from there.

The loadout chips report the catalogue's own totals against their ceilings —
never an invented weighted score, so they cannot drift from the tracks that
produce them. The selected difficulty is the strongest state on Home and is
never expressed with Godot's `disabled` styling, which would make the current
choice the dimmest control on the screen.

Every previous destination remains reachable within two taps, and its back
action names and returns to the hub that opened it. This topology is state-owned
by `FrontEndState`; presentation does not maintain a second overlay history.

The simulation, input router, and gameplay view are not mounted until Play is
requested. Returning through the in-game **Menu** control releases held Reel
input, destroys the current session, and recreates the front end.

Every front-end card uses the same presentation-only `SpiderWebPanel`. Its
neutral slate surface carries deterministic low-alpha grain and pits, fibres,
two tensioned corner webs, six silk knots, and two cocoon forms behind controls;
it never processes navigation or gameplay input. Buttons share an asymmetric
cocoon silhouette. Garage and Shop
derive their restrained border/title accent from the selected spider; Home,
Settings, Tutorial, Campaign, Course Lab, Region Practice, Field Guide, and Test
Run reuse the same material layer without changing their layout ownership.

### Field Guide

The guide is a master/detail browser, not one continuous text page. A persistent
five-spider species index selects one production sprite and identity header.
The detail scroller then presents four separately bordered sections: **Real
Animal**, **In Spider Swing**, **Field Note**, and **Sources**. Real scientific
claims, invented abilities, myth corrections, and provenance therefore cannot
blend into one green text wall. Back names and follows the route that opened the
guide (Guide hub or Garage).

### Tutorial

The tutorial is data-driven by `FrontEndState.TUTORIAL_STEPS` and illustrated by
`TutorialPreview`. Lessons have stable ids, one declared teaching goal, explicit
mechanic coverage, and one focused page for each of these subjects:

1. Bramble Canopy's guided opening, earned speed, and pursuing-bird pressure;
2. legal in-range attachment surfaces versus optional aim guidance;
3. wide rising swings, release quality, and momentum preservation;
4. speed-neutral rope-shortening Reel, finite energy, recharge, and automatic
   slack take-up;
5. aimed double-tap Anchor Burst, the unaimed button fallback, minimum travel,
   charges, and cooldown;
6. one-shot downward Dive Pull, upper-web rearm, and recovery interruption;
7. route changes, production obstacle silhouettes, flies, lethal rails, Burst
   Frenzy, and region changes;
8. Rescue, Buckler's separate rail bounce, death attribution, restart, and Menu.

The preview is a deterministic in-engine presentation rather than a prerecorded
video or second simulator. Every lesson owns exactly three concise teaching
points. Their numbered labels drive both the copy card and the matching large,
high-contrast scene callouts, so the explanation and picture cannot become two
different lessons. This replaces the paragraph-plus-small-tip hierarchy that
the owner's 1040×480 recording proved technically enclosed but hard to read.

The scene resolves the selected production spider, body tint, and Silk treatment
plus Bramble backdrop/rails, current obstacles, the pursuing bird, flies, the
real Burst Frenzy lightning pickup, route/target cues, and gameplay-shaped HUD
controls through the live asset catalog. `CanopyObstacleArt` is the one
presentation rule for directional hook/shutter art in both `SwingLab` and
`TutorialPreview`: source art grows upward from the floor, ceiling mounts flip
vertically, and the authored left/right kind alone controls horizontal mirroring.
Missing imports have an explicit labeled/silhouette fallback and cannot silently
restore the old cyan grid, rectangle, circle, and line-spider diagram. Reduced
Motion freezes each lesson at a useful staged pose.

Copy, preview, and 80-reference-pixel tutorial actions are enclosed at 1280×720,
1280×600, and strict unscaled 1040×480 without adding a nested scroll or gesture
owner. Overview pages retain a truthful `START RUN`; Attach, momentum Release,
Reel, Anchor Burst, and Dive Recovery instead expose `PRACTISE LESSON`.

`TutorialPracticeCatalog` is the one application-owned metadata and objective
model. Each lesson declares whether direct practice exists; applicable entries
carry a stable objective id, fixed seed/start, coaching, and completion rule.
Reel, Burst, and Dive reuse the same authoritative verb mapping as Campaign,
while Attach consumes `ATTACHED`, momentum Release requires a `RELEASED` event
with a positive simulation-awarded `forward_bonus`, and Dive Recovery requires
`DIVE_STARTED` followed by an upper attachment whose event says `dive_rearmed`.
Distance is not an objective input.

Practice mounts `SwingLabSession.RUN_TUTORIAL_PRACTICE` on Standard course
structure with the selected production spider, cosmetics, upgrades, real input,
physics, HUD, and deterministic course stream. The HUD presents objective,
authoritative progress, and concise coaching. Completion is session-local;
completion, confirmed death, and Menu remount the same tutorial lesson. This run
purpose never creates a `RunSettlement`, so it has no settlement id and cannot
reach Campaign stars, flies, bests, checkpoints, leaderboard eligibility,
`ProgressionService`, or `SaveRepository`.

### Garage and Shop

Garage profiles are centralized in `SpiderCatalog`. Balanced, small/agile,
heavy, gliding, and one-charge rail-recovery spiders are all unlocked in Phase
0 so the owner can compare their explicit strengths and costs without
progression obscuring the feel test.
The selected profile resolves into the same `SwingConfig` consumed by
simulation. Presentation only shows those resolved values.

Body palettes and Silk treatments use three-card button rails rather than
platform-native dropdowns. `SilkPreview` draws the selected Classic, Dew, or
Ember thread treatment in place, so the visual choice is readable before Play
without owning web physics or attachment rules.

The Shop gives every profile the same five core tracks plus two identity tracks.
Each track has 40 small levels. Every fifth level through 40 is a visible
breakthrough that grants one extra tuning step without adding another input or
charge. The seven selected-profile rows use one fly-balance badge, CORE/IDENTITY
accent cards, and eight visible silk knots for those milestones. The Shop states
the rule once above the list, marks an upcoming milestone `BREAKTHROUGH ×2`,
and says on its card that the purchase grants two tuning steps. A maxed card
derives its eight-breakthrough/48-step summary from `SpiderCatalog`, so
presentation does not duplicate the progression calculation.
Purchases spend `spendable_flies` through `ProgressionService` and persist
atomically through `SaveRepository`. Schema 4 maps each former five-level value
to the equivalent four-level interval exactly once; schema 8 then doubles
twenty-level ownership once, preserving the same proportional position. There are no real-money
products or entitlements in this build.

### Course Lab

Six saved slots cycle through EMPTY, LEAF, POD, VINE, and GATE. The selected
pattern replaces the post-opening procedural pattern during a creator
playtest. This is deliberately a local deterministic foundation: sharing,
discovery, moderation, validation tooling, and a full spatial editor remain
future work.

### Region Practice

Standard runs unlock Bramble Canopy at 5000 m and Silk Hollow at 10000 m as
soon as the player reaches those distances. Region Practice starts on the
ordinary guided web inside an authored open checkpoint chunk at the correct
late-game pace. It uses a newly seeded curated course order, but the same
physics, collision, upgrades, route geometry, and input path as a standard run.

Practice is deliberately non-competitive. Its persistent screen and in-run HUD
state that it grants no flies, cannot update best distance, cannot unlock later
checkpoints, and is ineligible for any eventual leaderboard. `RunSettlement`
carries those eligibility flags as authoritative data rather than relying on
presentation copy. Reaching a checkpoint in a standard run persists it through
`ProgressionService`; schema-4 saves infer already-reached checkpoints once from
their standard best distance.

### Settings

The current options all affect runtime behavior:

| Option | Runtime effect |
| --- | --- |
| Swing feel | Applies Balanced, Weighty, or Agile before the run starts |
| Control hints | Shows or hides run guidance and feedback text |
| Reduced motion | Stops decorative front-end/tutorial motion and removes camera easing/parallax |
| Haunted background music | Saved 0–100% slider for both persistent stems; 0% is silent, 50% preserves the original mix, and 100% adds 6.02 dB |
| Gameplay sound effects | Enables or mutes the presentation-owned SFX layer |
| Handheld haptics | Enables or suppresses Android vibration feedback independently |
| Debug tools | Shows or removes the Home Debug Test Run route plus in-run diagnostic controls |

### Debug Test Run and Advanced Test Lab

The Home route opens a compact launcher first. It exposes only start distance,
one temporary all-track upgrade level, and the three pursuing-bird values, with
0/5k/10k/25k, OWNED/L0/L20/MAX, and OFF/SLOW/BASE/FAST shortcuts. Its conditions
scroll independently while the start action stays pinned. A quick launch applies
only those visible fields; a hidden saved advanced override cannot affect a run
whose launcher did not disclose it.

Advanced Test Lab is one explicit tap from that launcher and exposes the eight
configuration categories that can
meaningfully exist before a run: Movement, Pacing, Rope, Pulls, Course, Routes,
Run, and Abilities. All entries come from `TuningCatalog`; presentation does not
duplicate bounds, steps, descriptions, or quick values. Pacing includes the
OFF/SLOW/BASE/FAST bird comparisons. Recorded traces live compactly inside Run,
while live-only pause, frame-step, recording, overlays, and diagnostics remain
in gameplay.

The current working set is written automatically to
`user://debug_test_profile.json`. A/B/C each save and restore a whole comparison
with a visible difference count. The editor displays the fully resolved values
for the selected spider, difficulty, preset, and owned/debug upgrade level, but
persists a separate sparse set of manually overridden axes. Only that sparse set
is applied after normal config resolution, so merely viewing or saving L40 can
never flatten its progression bonuses. Starting or replaying one of these runs
uses the practice/no-awards ownership path and cannot update flies, records,
checkpoints, leaderboards, or `PlayerProgress`.

DEBUG availability is a player setting; world overlays are not. Every new run
starts with collision outlines and web-target guides off. Their independent
OVERLAYS buttons affect only the current laboratory session and cannot mutate
course geometry, targeting, or collision.

`PlayerSettings` validates and versions these values. `PlayerProgress` separately
versions lifetime/spendable flies, distance milestones, selected spider,
profile upgrades, palettes, web variants, the saved creator pattern, and reached
region checkpoints.
`SaveRepository` is the exclusive persistent writer and performs a recoverable
temp → primary rotation for settings, progression, and the separate Test Lab
profile.
Settings survive app restarts; invalid or corrupt values fall back safely.
`SpiderUiTheme` supplies one Ancient-Forest-aligned bark, moss, sap, and silk
skin to every screen, including panels, buttons, disabled/focus states, and
scrollbars. Settings and Shop use Godot's built-in touch dragging with a
12-pixel deadzone and 64-pixel wheel/controller step. `follow_focus` is off on
these touch-first surfaces so tapping an upgrade cannot snap the viewport while
that same gesture becomes a drag. Every descendant control inside those two
scroll surfaces uses `MOUSE_FILTER_PASS`: buttons retain tap ownership, while a
gesture that crosses the deadzone bubbles to the one native inertial scroll
owner even when it begins on a button, label, panel, or empty card region. All
actions remain reachable on the 1040×480 Android viewport from the owner
recording and on taller aspect ratios.

## Ownership

- `FrontEndState` owns navigation, tutorial page and session-local completion
  state, settings validation,
  Garage/Shop/Course Lab/Region Practice intent, Field Guide selection, compact
  versus advanced debug launch intent, the Test Lab working set, and run requests.
- `FrontEndView` renders state and forwards button intent.
- `TutorialPreview` renders deterministic production-asset snapshots only; it
  owns no simulation, settlement, progression, or persistence state.
- `TutorialPracticeCatalog` owns stable lesson objective and launch metadata;
  `SwingLabSession` observes authoritative events and publishes progress.
- `ProgressionService` applies each run settlement once and owns fly-funded
  upgrades, selections, creator edits, and milestone cosmetic unlocks.
- `SaveRepository` exclusively reads and writes settings, progression, and the
  debug-only Test Lab profile.
- `main.gd` is the composition root: it mounts one surface at a time and wires
  the transition.
- `SwingLabSession` remains the sole owner of authoritative run state.

No global manager or autoload is introduced.

## Verification

`python3 tools/verify.py --require-godot` verifies:

- startup mounts Home without creating gameplay;
- Play, Spider, Play Modes, Guide, Settings, and Debug Test Run are real
  event-consuming Home buttons; each hub's destination buttons consume their
  own events and return through the same state-owned route;
- every tutorial lesson has a unique stable id and teaching goal, exactly three
  concise teaching points, no paragraph-plus-tip fallback, and the live
  mechanics each have one declared lesson owner; Burst/Dive remain separate;
- every preview resolves the selected spider plus real game presentation assets,
  uses the same three labels as its copy, applies the shared ceiling/floor
  obstacle orientation, freezes deterministically under Reduced Motion, and
  cannot silently return to primitive-only presentation;
- tutorial copy, preview, navigation, and 80 px actions remain enclosed at
  1280×720, 1280×600, and strict unscaled 1040×480 with no nested scroller;
- every practice-enabled lesson resolves a fixed launch and authoritative
  objective; distance and wrong verbs cannot complete it, Dive requires its
  ordered upper-web rearm, and identical launches resolve the same seed;
- tutorial practice emits no settlement or checkpoint, remains record- and
  leaderboard-ineligible, returns to its originating lesson on completion,
  death, or Menu, and leaves ordinary Play and Campaign run purposes unchanged;
- Settings owns a vertical scroll surface with readable type and mobile-sized
  three-card preset/action controls, a touch deadzone, no focus snapping, and
  complete descendant drag bubbling;
- invalid settings are rejected and valid changes emit once;
- settings, progression, and Test Lab profiles encode/decode and actual atomic
  filesystem persistence round-trip;
- duplicate settlement rejection, the five-core/two-identity Shop structure,
  40-level caps and breakthroughs, proportional one-time migration,
  fly-funded upgrades, creator edits, custom body/Silk rails and preview,
  themed progress knots, selections, and fly/distance cosmetic milestones;
- schema-4 checkpoint migration, locked/unlocked practice cards, and practice
  settlements that cannot alter flies or best distance;
- the composition root enters gameplay only through the Play request;
- Menu emits one return request without leaking into a web action;
- effects and haptics migrate on for older settings, persist independently, and
  cannot alter gameplay events;
- Home keeps one dominant Play action, a four-choice semantic map, and a
  subordinate debug-only quick-run action; the three hubs remain enclosed in
  short landscape layouts and preserve two-tap reachability;
- Field Guide retains its index plus four separate glance-readable sections;
- the compact launcher exposes all and only its visible start conditions, stays
  enclosed at the reference, short, and strict 1040×480 layouts, and cannot leak
  hidden tuning; Advanced Test Lab exposes all eight pre-run catalogue categories,
  auto-saves its working set, round-trips A/B/C, preserves unedited progression,
  reaches the real session before its first tick, and remains noncompetitive;
- disabling debug tools removes its Home and in-run touch surfaces.
