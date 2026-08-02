# Persistent Music volume control

> **Status:** `in-progress`

## Goal

Replace the binary background-Music setting with a touch-friendly saved volume slider so the soundtrack can be raised above its current quiet mix without changing Effects or Haptics.

## Scope guard

Player settings value and backward-compatible migration; Settings presentation; AudioDirector music-stem gain application; focused persistence, independence, and mobile-layout contracts; build identity and living docs. Preserve soundtrack assets, adaptive tension law, SFX/haptic levels, simulation, physics, progression, and gameplay balance.

## Planned verification

- Prove existing enabled settings migrate to the current soundtrack level and disabled settings migrate to silence.
- Prove the saved slider restores across restart and changes both soundtrack stems without changing Effects or Haptics.
- Measure the Settings control at 1280×720 and 1280×600.
- Falsify migration, persistence, and mix-independence contracts against production code.
- `python3 tools/verify.py --require-godot`
- `python3 bootstrap.py check --strict`

## Previous-session review

**previous-session review:** PR #109 completed the menu information architecture and retained independent binary Music, Effects, and Haptics settings. The owner’s immediate device verdict identifies the remaining audio-control gap: the shipped background mix is too quiet and Music needs intensity control rather than another soundtrack or SFX retune.

## 💡 Session idea

If one music slider proves insufficient after device testing, expose adaptive-tension intensity separately only after preserving a single master Music volume as the stable default control.

- **📊 Model:** gpt-5 · high · feature build
