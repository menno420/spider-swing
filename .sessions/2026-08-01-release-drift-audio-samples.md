# Reconcile shipped state and prototype core SFX

> **Status:** `complete`

## Goal

Remove repository drift that would make the owner's imminent Android playtest
misidentify the build or trust stale shipped-state claims. Then prove whether a
small, original generated-SFX set can meet the game's spider/web identity and
mobile readability bar without changing simulation, balance, progression, or
save behavior.

## Scope guard

Own documentation, visible build identity, presentation-owned audio plumbing,
original generated sample assets, and their contracts. Do not change physics,
zone geometry or mechanics, campaign, difficulty, upgrades, economy, input
meaning, settlement, or persistence.

## Previous-session review

**previous-session review:** PRs #73–#82 shipped Zones 4–8, Campaign,
difficulty modes, the upgrade-audit correction, and the owner's authoritative
difficulty verdict. Live source is green at 159 contracts, but the living docs
still call merged PRs candidates, report 134 contracts, say difficulty remains
unimplemented, and expose build `0.21.0-zones-4-8` for a materially newer game.

## Planned proof

- Derive every changed shipped-state statement from source, merged commits, or
  a fresh exact-engine run.
- Treat generated SFX as a contained presentation slice: reproducible source,
  headroom/peak/duration audit, event-driven playback, high-frequency
  variation/cooldown rules, and independent effects/haptics controls.
- Run `python3 tools/verify.py --require-godot` and
  `python3 bootstrap.py check --strict`; build the exact Android artifact if
  audio or visible identity changes ship.

## 💡 Session idea

The reproducible SFX generator and automated headroom/size audit are useful as a
permanent verification step: a regenerated sample cannot silently drift from
its manifest or exceed the Android budget. Subjective mix approval remains a
device-listening decision, not an automated score.

- **📊 Model:** gpt-5.6 · high · feature build

## Shipped change

- Reconciled the living README, current-state ledger, zone source of truth,
  playtest guide, test documentation, asset policy, and subsystem READMEs with
  the shipped eight-zone, Campaign, difficulty, and upgrade state.
- Advanced the visible Android identity to `0.22.0-audio-playtest` / code 40.
- Added 25 original deterministic mono PCM WAVs plus a hash/level/duration/loop
  manifest and byte-exact generator. No recording, sample library, reference
  audio, download, or third-party source was used.
- Added a presentation-owned six-voice `AudioDirector`, explicit event mapping,
  round-robin variants, cooldowns, a snapshot-driven Reel loop, and five
  later-zone warning treatments. The old temporary sine generator was removed.
- Added independently persisted Effects and Haptics switches. Audio and haptics
  consume authoritative events but cannot write simulation, rewards, or saves.

## Proof

- `python3 tools/verify.py --require-godot` passed with exact Godot
  `4.7.1.stable.official.a13da4feb`: deterministic regeneration, architecture,
  import, boot, and all 165 contracts green.
- `python3 tools/generate_audio_samples.py --check` reproduced 25 WAVs and the
  manifest byte-for-byte. The pack is 516,562 WAV bytes (536 KiB on disk), mono
  44.1 kHz 16-bit PCM, peaks from −12 to −3 dBFS; Reel's boundary-step ratio is
  0.718 under the 1.5 ceiling.
- PR #83 opened ready with exact local-tree equality. Initial GitHub runs:
  substrate 30691794043, game quality 30691794045, and Android 30691794032.
- The environment could not audition audio directly, so no subjective sound-
  quality claim is recorded. The owner-facing sampler and Android run are the
  listening gate.

## Decision flag

Treat this as a strong generated-SFX **playtest mix**, not locked production
audio. Keep generated core feedback reproducible; source any future ambience or
music only from individually verified CC0 files. Device evidence decides which
samples to retain, revise, replace, or rebalance.
