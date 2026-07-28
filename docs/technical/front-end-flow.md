# Front-end flow

> **Status:** `reference`

Spider Swing opens into a player-facing front end before any simulation exists.
The composition root owns the transition between front end and run; presentation
cannot start or persist a run by itself.

## Screens

### Home

The first visible screen presents exactly three primary routes:

- **Play** — creates a new Swing Laboratory session with the saved options;
- **Tutorial** — opens the five-step animated mechanics guide;
- **Settings** — edits real, persisted player options.

The simulation, input router, and gameplay view are not mounted until Play is
requested. Returning through the in-game **Menu** control releases held Reel
input, destroys the current session, and recreates the front end.

### Tutorial

The tutorial is data-driven by `FrontEndState.TUTORIAL_STEPS` and illustrated by
`TutorialPreview`. Its five focused steps cover:

1. automatic forward movement and distance;
2. valid cyan web anchors and range;
3. manual release with momentum preservation;
4. attached-only Reel use and finite energy;
5. lethal boundaries, restart, Menu, and optional debug tooling.

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

`PlayerSettings` validates and versions these values. `SaveRepository` is the
exclusive persistent writer and performs a recoverable temp → primary rotation.
Settings survive app restarts; invalid or corrupt values fall back safely.

## Ownership

- `FrontEndState` owns navigation, tutorial progress, settings validation, and
  the Play request.
- `FrontEndView` renders state and forwards button intent.
- `TutorialPreview` renders illustration only.
- `SaveRepository` exclusively reads and writes the settings file.
- `main.gd` is the composition root: it mounts one surface at a time and wires
  the transition.
- `SwingLabSession` remains the sole owner of authoritative run state.

No global manager or autoload is introduced.

## Verification

`python3 tools/verify.py --require-godot` verifies:

- startup mounts Home without creating gameplay;
- Play, Tutorial, and Settings are real event-consuming Buttons;
- the tutorial has exactly five steps and covers the live mechanics;
- invalid settings are rejected and valid changes emit once;
- settings encode/decode and actual atomic filesystem persistence round-trip;
- the composition root enters gameplay only through the Play request;
- Menu emits one return request without leaking into a web action;
- disabling debug tools removes their touch surface.
