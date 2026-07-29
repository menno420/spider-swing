# Front-end flow

> **Status:** `reference`

Spider Swing opens into a player-facing front end before any simulation exists.
The composition root owns the transition between front end and run; presentation
cannot start or persist a run by itself.

## Screens

### Home

The first visible screen presents these real routes:

- **Play** — creates a new Swing Laboratory session with the saved options;
- **Garage** — compares spider profiles, palettes, and web treatments;
- **Shop** — spends laboratory flies on shared core and profile-identity tracks;
- **Tutorial** — opens the six-step animated mechanics guide;
- **Course Lab** — edits and playtests a six-piece local deterministic pattern;
- **Settings** — edits real, persisted player options.

The simulation, input router, and gameplay view are not mounted until Play is
requested. Returning through the in-game **Menu** control releases held Reel
input, destroys the current session, and recreates the front end.

### Tutorial

The tutorial is data-driven by `FrontEndState.TUTORIAL_STEPS` and illustrated by
`TutorialPreview`. Its six focused steps cover:

1. automatic forward movement and distance;
2. forgiving solid ceiling/obstacle targets, optional aim guides, and range;
3. manual release with momentum preservation;
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

The Shop gives every profile the same five core tracks plus two identity tracks.
Each track has 20 small levels. Levels 5, 10, 15, and 20 are visible
breakthroughs that grant one extra tuning step without adding another input or
charge. The seven selected-profile rows live in a focus-following vertical
`ScrollContainer` so they remain reachable at 1040×480.
Purchases spend `spendable_flies` through `ProgressionService` and persist
atomically through `SaveRepository`. Schema 4 maps each former five-level value
to the equivalent four-level interval exactly once. There are no real-money
products or entitlements in this build.

### Course Lab

Six saved slots cycle through EMPTY, LEAF, POD, VINE, and GATE. The selected
pattern replaces the post-opening procedural pattern during a creator
playtest. This is deliberately a local deterministic foundation: sharing,
discovery, moderation, validation tooling, and a full spatial editor remain
future work.

### Settings

The current options all affect runtime behavior:

| Option | Runtime effect |
| --- | --- |
| Swing feel | Applies Balanced, Weighty, or Agile before the run starts |
| Control hints | Shows or hides run guidance and feedback text |
| Reduced motion | Stops decorative front-end/tutorial motion and removes camera easing/parallax |
| Debug tools | Shows or removes the laboratory DEBUG control and panel hit regions |

DEBUG availability is a player setting; world overlays are not. Every new run
starts with collision outlines and web-target guides off. Their independent
OVERLAYS buttons affect only the current laboratory session and cannot mutate
course geometry, targeting, or collision.

`PlayerSettings` validates and versions these values. `PlayerProgress` separately
versions lifetime/spendable flies, distance milestones, selected spider,
profile upgrades, palettes, web variants, and the saved creator pattern.
`SaveRepository` is the exclusive persistent writer and performs a recoverable
temp → primary rotation for both records.
Settings survive app restarts; invalid or corrupt values fall back safely.
The Settings and Shop cards use vertical `ScrollContainer` surfaces with larger
text, mobile-sized controls, and focus-follow behavior. All actions remain
reachable on the 1040×480 Android viewport from the owner recording and on
taller aspect ratios.

## Ownership

- `FrontEndState` owns navigation, tutorial progress, settings validation,
  Garage/Shop/Course Lab intent, and the Play request.
- `FrontEndView` renders state and forwards button intent.
- `TutorialPreview` renders illustration only.
- `ProgressionService` applies each run settlement once and owns fly-funded
  upgrades, selections, creator edits, and milestone cosmetic unlocks.
- `SaveRepository` exclusively reads and writes settings and progression files.
- `main.gd` is the composition root: it mounts one surface at a time and wires
  the transition.
- `SwingLabSession` remains the sole owner of authoritative run state.

No global manager or autoload is introduced.

## Verification

`python3 tools/verify.py --require-godot` verifies:

- startup mounts Home without creating gameplay;
- Play, Garage, Shop, Tutorial, Course Lab, and Settings are real
  event-consuming Buttons;
- the tutorial has exactly six steps and covers the live mechanics;
- Settings owns a vertical scroll surface with readable type and mobile-sized
  picker/action controls;
- invalid settings are rejected and valid changes emit once;
- settings and progression encode/decode and actual atomic filesystem
  persistence round-trips;
- duplicate settlement rejection, the five-core/two-identity Shop structure,
  20-level caps and breakthroughs, proportional one-time migration,
  fly-funded upgrades, creator edits, selections, and fly/distance cosmetic
  milestones;
- the composition root enters gameplay only through the Play request;
- Menu emits one return request without leaking into a web action;
- disabling debug tools removes their touch surface.
