# Spider-web menu presentation

> **Status:** `complete`

## Goal

Give the front-end menus a recognizably spider-built look through reusable web filaments, cocooned corners, fibrous panel texture, and selected-spider accent cues, while preserving the already proven navigation and touch geometry.

## Scope guard

Presentation theme code, deterministic procedural texture/ornament assets if needed, visual/layout contracts, build identity, and living docs only. Preserve gameplay, physics, bird tuning, upgrade balance, persistence, navigation routes, scroll ownership, control names, minimum touch sizes, audio, and settlement.

## Planned verification

- Measure the real Home, Garage, Shop, and Test Run surfaces at phone/reference viewports.
- Falsify ornament ownership and touch/layout preservation contracts.
- `python3 tools/verify.py --require-godot`
- `python3 bootstrap.py check --strict`

## Previous-session review

**previous-session review:** PR #105 safely expanded all 35 progression tracks
and explicitly handed the next slice to a reusable menu presentation layer. The
existing front end already had an Ancient-Forest palette and two background
corner webs, but individual cards remained flat rounded rectangles.

## Implemented

- `SpiderWebPanel` replaces the panel factory's native flat cards across Home,
  Tutorial, Settings, Garage, Shop, Course Lab, Campaign, Region Practice,
  Field Guide, and Test Run. It draws deterministic 22 px-spaced fibres, twelve
  spokes, six web rings, six silk knots, and two cocoon forms behind children.
- Buttons use an asymmetric tensioned-cocoon silhouette with blended borders.
  Garage and Shop use the selected spider's restrained accent for their card
  edge and title; no gameplay or persistent profile data changes.
- The renderer is static, passes GUI input, and owns no navigation or layout.
  All existing button, scroll, and short-phone contracts remain unchanged.
- Build identity is `0.28.0-spider-menu-theme-playtest`, Android code 48.

## Visual verification boundary

The headless environment could not produce a framebuffer; a capture attempt
hung before any pixels were returned and was terminated. Visual confidence
therefore comes from bounded real-control geometry and deliberately low alpha
(5.5% fibres, 13–16% silk) rather than a claimed screenshot. Final material
density and appeal remain a device-eye gate.

## Adversarial verification

- Removing one cocoon failed the complete ornament contract.
- Making cards consume GUI input failed the passive-shell contract.
- Recoloring Anchorite moss-green exposed a self-referential test blind spot;
  the test now independently pins sap-orange, and the production mutation fails.
- Making all four button corners equal failed the cocoon-silhouette contract.

## Verification evidence

- Exact Godot `4.7.1.stable.official.a13da4feb`: 198/198 contracts pass after
  restoring every mutation.
- `git diff --check` and strict pass after the final lifecycle flip.

## 💡 Session idea

Use the same event/snapshot separation for haunted music: one original looping
bed should react only through presentation-owned mix layers, never simulation.

## Next slice

Create and integrate the haunted background soundtrack as its own PR.

- **📊 Model:** gpt-5 · high · feature build
