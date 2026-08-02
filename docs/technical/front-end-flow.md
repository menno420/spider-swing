# Front-end flow

> **Status:** `reference`

Spider Swing opens into a player-facing front end before any simulation exists.
The composition root owns the transition between front end and run; presentation
cannot start or persist a run by itself.

## Screens

### Home

The first visible screen presents intentions rather than indexing every feature:

- **Play** — starts Endless immediately with the selected difficulty, spider,
  owned upgrades, and saved options;
- **Spider** — opens Garage and Upgrades together;
- **Play Modes** — opens Campaign, Region Practice, and Course Lab together;
- **Guide** — opens How to Swing and Field Guide together;
- **Settings** — edits real persisted options directly;
- **Test Lab** *(when Debug Tools is enabled)* — remains a subordinate direct
  utility for saved, noncompetitive run comparisons.

Home uses a full landscape dashboard rather than a feature grid. The selected
production spider, role, difficulty, and best distance form one identity card;
the other reserves its strongest weight for one Endless Play action. The four
normal secondary choices are a two-column semantic map. Every previous
destination remains reachable within two taps, and its back action names and
returns to the hub that opened it. This topology is state-owned by
`FrontEndState`; presentation does not maintain a second overlay history.

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
`TutorialPreview`. Its six focused steps cover:

1. automatic forward movement and distance;
2. forgiving solid ceiling/obstacle targets, optional aim guides, and range;
3. manual momentum carry plus the bounded wide/rising release award;
4. speed-neutral rope-shortening Reel use and finite energy;
5. percentage-based Anchor Burst, detached double-tap targeting, one-shot
   downward Dive Pull, and immediate recovery-web interruption;
6. shaped warning obstacles, ceiling/floor gaps, fly routes, temporary Burst
   Frenzy, configurable lethal rails, restart, Menu, and optional debug tooling.

The preview is an in-engine animation rather than a prerecorded video. This is a
deliberate reversible decision: the guide stays synchronized with live mechanics,
adapts to differing aspect ratios, honors reduced motion, and can be localized
without re-editing video. A polished cinematic can replace or precede it later
without changing the navigation contract.

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
breakthroughs that grant one extra tuning step without adding another input or
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
| Debug tools | Shows or removes the Home Test Lab route plus in-run diagnostic controls |

### Test Lab

The pre-run Test Lab exposes the eight configuration categories that can
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

- `FrontEndState` owns navigation, tutorial progress, settings validation,
  Garage/Shop/Course Lab/Region Practice intent, Field Guide selection, the
  Test Lab working set, and run requests.
- `FrontEndView` renders state and forwards button intent.
- `TutorialPreview` renders illustration only.
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
- Play, Spider, Play Modes, Guide, Settings, and Test Lab are real
  event-consuming Home buttons; each hub's destination buttons consume their
  own events and return through the same state-owned route;
- the tutorial has exactly six steps and covers the live mechanics;
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
  subordinate debug-only Test Lab action; the three hubs remain enclosed in
  short landscape layouts and preserve two-tap reachability;
- Field Guide retains its index plus four separate glance-readable sections;
- the Test Lab exposes all eight pre-run catalogue categories, auto-saves its
  working set, round-trips A/B/C, preserves unedited progression, reaches the
  real session before its first tick, and remains noncompetitive;
- disabling debug tools removes its Home and in-run touch surfaces.
