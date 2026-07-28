# Front-end flow

> **Status:** `reference`

Spider Swing opens into a player-facing front end before any simulation exists.
The composition root owns the transition between front end and run; presentation
cannot start or persist a run by itself.

## Screens

### Home

The first visible screen presents exactly three primary routes:

- **Play** — creates a new Swing Laboratory session with the saved options;
- **Tutorial** — opens the six-step animated mechanics guide;
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

### Settings

The current options all affect runtime behavior:

| Option | Runtime effect |
| --- | --- |
| Swing feel | Applies Balanced, Weighty, or Agile before the run starts |
| Control hints | Shows or hides run guidance and feedback text |
| Reduced motion | Stops decorative front-end/tutorial motion and removes camera easing/parallax |
| Debug tools | Shows or removes the laboratory DEBUG control and panel hit regions |

`PlayerSettings` validates and versions these values. `PlayerProgress` separately
versions fly totals, distance milestones, and unlocked spider palettes.
`SaveRepository` is the exclusive persistent writer and performs a recoverable
temp → primary rotation for both records.
Settings survive app restarts; invalid or corrupt values fall back safely.
The Settings card is a vertical `ScrollContainer` with larger text, 58–68-pixel
controls, and focus-follow behavior. All actions remain reachable on the
1040×480 Android viewport from the owner recording and on taller aspect ratios.

## Ownership

- `FrontEndState` owns navigation, tutorial progress, settings validation, and
  the Play request.
- `FrontEndView` renders state and forwards button intent.
- `TutorialPreview` renders illustration only.
- `ProgressionService` applies each run settlement once and owns milestone
  cosmetic unlocks.
- `SaveRepository` exclusively reads and writes settings and progression files.
- `main.gd` is the composition root: it mounts one surface at a time and wires
  the transition.
- `SwingLabSession` remains the sole owner of authoritative run state.

No global manager or autoload is introduced.

## Verification

`python3 tools/verify.py --require-godot` verifies:

- startup mounts Home without creating gameplay;
- Play, Tutorial, and Settings are real event-consuming Buttons;
- the tutorial has exactly six steps and covers the live mechanics;
- Settings owns a vertical scroll surface with readable type and mobile-sized
  picker/action controls;
- invalid settings are rejected and valid changes emit once;
- settings and progression encode/decode and actual atomic filesystem
  persistence round-trips;
- duplicate settlement rejection plus fly/distance cosmetic milestones;
- the composition root enters gameplay only through the Play request;
- Menu emits one return request without leaking into a web action;
- disabling debug tools removes their touch surface.
