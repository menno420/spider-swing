# Haunted background soundtrack

> **Status:** `complete`

## Goal

Create and integrate an original haunted background score through the
presentation-owned audio layer, with independent music control, deterministic
assets, mobile-safe mixing, and no gameplay authority.

## Scope guard

Audio generator/assets, presentation audio catalog/director, persistent Music
setting and Settings control, composition wiring, build identity, tests, and
living docs only. Preserve simulation, bird tuning, physics, progression,
course content, effects event mapping, haptics behavior, and settlement.

## Previous-session review

**previous-session review:** PR #106 correctly put all menus behind one passive
spider-web theme and explicitly handed this independent audio slice forward.
The existing `AudioDirector`, generated-SFX manifest, exact-regeneration gate,
and schema-2 Effects/Haptics settings were the right seams to extend; creating a
second audio service would have duplicated ownership.

## Implemented

- `tools/generate_audio_samples.py` and `assets/runtime/audio/` add an original
  32-second D-minor/Phrygian silk-and-forest bed plus a synchronized low chase
  pulse. Both are mono PCM WAV, exact-regenerated, compressed by Godot import,
  and recorded in manifest schema 2 beside the unchanged 25 SFX.
- `AudioAssetCatalog` and the persistent `AudioDirector` keep both stems phase-
  aligned across Home and gameplay. Pace and bird gap/closing snapshots resolve
  a bounded tension target; attack/release easing changes only presentation.
- Player settings schema 3 adds Music, default-on for older saves and independent
  from Effects and Haptics. Settings changes apply immediately and persist only
  through `SaveRepository`.
- Build identity is `0.29.0-haunted-soundtrack-playtest`, Android code 49.

## Shipped

- Remote implementation commit `1b483641f49408e2f020759913e96ff9aeaca8af`
  carries all 32 files on PR #107; GitHub and local tree SHA both resolve to
  `0510e1017021235e8bce87a6ee7174e2adc1eae6`.
- This closeout flip withdraws `agent/haunted-soundtrack`; required GitHub checks
  and Android export decide the PR's terminal merge/build state.

## Audio proof and boundary

- Bed: 32.000 s, -10.0 dBFS peak, -20.28 dBFS RMS, 0.248 seam ratio.
- Chase: 32.000 s, -11.0 dBFS peak, -25.64 dBFS RMS, 0.127 seam ratio.
- Maximum runtime stem mix: -10.3 dBFS peak/-22.7 dBFS mean, leaving about 7 dB
  below the loudest SFX. Combined committed PCM size is 5.4 MiB before Godot's
  runtime compression.
- This seat can prove synthesis, loop continuity, levels, wiring, persistence,
  and engine playback requests but cannot make a human listening judgement.
  Haunted feel, repetition fatigue, phone-speaker clarity, and final balance
  against SFX remain an owner-device ear gate.

## Adversarial verification

Five temporary production breaks each turned the intended contract red: missing
chase-stem catalog entry, pace-only pressure mix, Music/Effects coupling, schema-
2 Music default-off, and a second `AudioDirector` ownership site. Every mutation
was restored before the final gates.

## Capability delta

The requested `app_block` and all music-generation tools were absent from the
exact owner-live callable registry. The dated wall and deterministic repository-
generator workaround are appended to `docs/CAPABILITIES.md`.

## Verification evidence

- `python3 tools/generate_audio_samples.py --check`: 27 deterministic WAVs and
  manifest pass exact-byte regeneration.
- Exact Godot `4.7.1.stable.official.a13da4feb`: 200/200 contracts pass on the
  restored implementation tree.
- `python3 tools/verify.py --require-godot`: all seven stages pass. Strict's
  pre-close run reported only the deliberate hold after the seat digest refresh.

## Owner questions

None before device listening; every tuning value is reversible presentation
data and no gameplay behavior moved.

## 💡 Session idea

If the core score survives device review, give each distance region a data-
driven tonal accent stem that crossfades over the same persistent director,
rather than restarting separate tracks or embedding region logic in simulation.

## Next slice

Device-listen to Home, ordinary bird pressure, close-bird danger, and Effects-
off/Music-on. Tune only from that evidence before adding zone ambience.

- **📊 Model:** gpt-5 · high · feature build
