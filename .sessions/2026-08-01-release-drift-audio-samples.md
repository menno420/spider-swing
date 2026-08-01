# Reconcile shipped state and prototype core SFX

> **Status:** `in-progress`

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
  variation/cooldown rules, and an effects-volume control.
- Run `python3 tools/verify.py --require-godot` and
  `python3 bootstrap.py check --strict`; build the exact Android artifact if
  audio or visible identity changes ship.

## 💡 Session idea

Pending the implementation checkpoint: decide whether the reproducible SFX
generator and automated loudness/headroom audit deserve a permanent repository
workflow rather than a one-off script.

- **📊 Model:** gpt-5.6 · high · repository reconciliation and audio prototype

