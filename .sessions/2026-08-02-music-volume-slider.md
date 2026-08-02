# Persistent Music volume control

> **Status:** `complete`

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

## Implemented

- `PlayerSettings` schema 4 owns one validated 0–1 Music volume. Former Music-on
  saves migrate to 0.5 and Music-off saves to 0.0; serialized output retains only
  a derived boolean for deliberate downgrade compatibility.
- Settings replaces `MusicToggle` with a themed 0–100% `HSlider`, a live
  OFF/percentage label, 5% touch steps, and copy explaining that 50% is the
  original mix.
- `AudioDirector` applies one gain after adaptive pressure mixing to both bed
  and chase stems. 50% is 0 dB relative, 0% stops playback, and 100% doubles
  amplitude (+6.02 dB) without changing SFX or Haptics.
- Build identity is `0.31.0-music-volume-playtest`, Android code 51. D-0045 and
  the current settings/audio/testing contracts record the new boundary.

## Layout and interaction evidence

- At 1280×720, the Settings scroller is 866.4×651.2 px and brings the complete
  858×64 px slider to `(206.8, 128)` inside its viewport.
- At 1280×600, the scroller is 866.4×542 px and brings the same complete slider
  to `(206.8, 122)` inside its viewport.
- Driving the real slider signal through 0/50/100 resolves OFF/50%/100%, stores
  0.0/0.5/1.0, and yields -60/0/+6.02 dB while Effects and Haptics stay on.

## Adversarial verification

Three temporary production mutations each turned the intended contract red:
legacy Music-on mapped to 100% instead of 50%; the gain reference moved from
50% to 100%; and 0% Music incorrectly disabled Effects. Every mutation was
restored before the final gates.

## Capability delta

No new capability or wall. The requested `app_block` name is still absent from
the callable registry, matching the dated repository finding recorded by the
soundtrack session; the direct GitHub connector remains the working publication
path in this venue.

## Shipped

- Remote implementation commit `cad5f0cca4a4966bb2fdaa617ee1ab8cb0806c13`
  carries the complete feature batch on PR #111. Its GitHub tree and local
  verified tree both resolve to `4231d65beadea119df8ded1ada46c7ee07842f5e`.
- This closeout removes only `agent/music-volume-slider`'s claim. Required
  GitHub checks and Android export decide the terminal merge/build state.
- Connector closeout commit `8555bb7f5c00c23c482eadae26a7fa1415fa3d23`
  carries the complete card/claim flip on exact tree `895cf97a…`.

## Verification evidence

- Exact Godot `4.7.1.stable.official.a13da4feb`: 204/204 contracts passed on
  the restored implementation after every mutation.
- `python3 tools/verify.py --require-godot`: all seven stages passed, including
  exact regeneration of 27 audio assets, import, boot, architecture, and the
  engine runner.
- Pre-flip `python3 bootstrap.py check --strict` reported only this card's
  deliberate born-red hold; the boot ledger retains 313 words of headroom.
- Closeout `python3 bootstrap.py check --strict` exited 0 with every content
  check passed after the status flip and claim withdrawal.

## Owner questions

No implementation blocker. Device listening should choose a preferred everyday
level and confirm that 100% remains comfortably below traversal and warning
cues on the phone speaker.

## Next slice

Install the Android artifact over the existing stable-key build, move Music
through 0/50/100 in Settings, restart once to confirm restoration, and compare
Home plus a bird-pressure run at the preferred level.

## 💡 Session idea

If one music slider proves insufficient after device testing, expose adaptive-tension intensity separately only after preserving a single master Music volume as the stable default control.

- **📊 Model:** gpt-5 · high · feature build
