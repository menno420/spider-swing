# Build the local run-evidence system

> **Status:** `complete`

## Goal

Build a schema-versioned, bounded, local-only record of authoritative completed
runs, expose it through a mobile-readable Run History destination, and provide a
manual JSON export without adding analytics, identity, upload, or leaderboard
logic.

## Scope guard

This session may change run finalization, pure metric accumulation, local
persistence, Play Modes navigation, the history/export presentation, focused
contracts, Android build identity, and the canonical documentation for those
areas. It does not change gameplay tuning, physics, difficulty, upgrades,
rewards, Campaign content, remote collection, leaderboards, tester rewards, or
Issue #2.

## Previous-session review

**previous-session review:** main is still the reviewed
`2e8ab8e7282107a71fda8d55453fb4bae018926d` implementation plus this session's
landed work claim. The latest runtime work established tutorial clarity at build
0.43/code 63, while the Play internal track already contains code 64. No merged
or open implementation work has added run records; open PR #139 is an unrelated
Dependabot `actions/setup-java` update.

## Context delta

### Needed but not pointed

- `docs/CAPABILITIES.md` defined the connector-backed GitHub write path and the
  honest limits of headless UI evidence.
- `.substrate/skills/session-close/SKILL.md` supplied the repository's current
  claim, born-red card, verification, and close-out protocol because the older
  `.claude/skills/session-close/` route is absent.

### Pointed but not needed

- `HANDOFF.md` is not present on main.
- No new project-index area is expected: the work remains inside the existing
  domain, application, adapter, presentation, and bootstrap ownership seams.

### Discovered by hand

- `SwingLabSession.export_diagnostic()` currently writes directly to
  `user://`, so the run-evidence work must also move that adjacent write behind
  `SaveRepository` to preserve exclusive persistence ownership.
- `tools/simulate.gd` samples reference-speed share and Reel-held time before
  each fixed step, but has no shared mean/max-speed definition; the runtime and
  simulator need one pure accumulator rather than parallel semantics.
- Campaign deliberately reuses one settlement ID per level to make stars
  idempotent. A record therefore needs its own per-attempt ID plus an explicit
  settlement link; equating the two would silently discard repeat Campaign
  completions from evidence.

## Shipped

- Added schema-1 `RunRecord` and `RunRecordLedger` domain values. The ledger
  retains the newest 100 full records and fixed-size lifetime runs, active play
  duration, travelled distance, and comparable per-difficulty bests.
- Added the pure `RunMetricsAccumulator`, shared by live play and
  `tools/simulate.gd`. It samples once before each active 60 Hz step and counts
  only accepted `ATTACHED`, `REEL_STARTED`, `REEL_EMPTY`, `BURST_STARTED`,
  `DIVE_STARTED`, and `RESCUE_USED` events.
- Paired one record with the existing terminal settlement seam. Progression is
  applied and saved first; optional evidence append/write follows, logs failure,
  and cannot alter settlement idempotency or rewards.
- Moved the adjacent diagnostic write behind `SaveRepository`, which remains the
  only filesystem writer and now owns the separate recoverable evidence file.
- Added Home → Play Modes → Run History with latest/recent context, lifetime
  summary, one native scroll owner, selectable JSON, and explicit clipboard
  copy through a platform adapter. The payload states local-only/no transmission.
- Classified standard, Region Practice, debug, Course Lab, Campaign, and trace
  replay records. Tutorial practice remains excluded because it has no
  settlement; Menu/abandonment/suspension add no new write path.
- Bumped the source/debug build to `0.44.0-run-evidence`, Android version code
  65 and `Spider Swing Run Evidence (dev)`. Play internal-testing code 64 is
  historical and was neither reused nor published over.
- Added the binding contract at `docs/technical/run-evidence.md` and updated the
  ownership, runtime, front-end, testing, privacy, current-state, ideas, layer,
  and routing documents without promoting the wider tester programme.

## Exact shared metrics

- duration: sampled active fixed ticks ÷ 60;
- travelled distance: final absolute distance minus actual start, clamped at 0;
- mean/max speed: arithmetic mean/max of nonnegative horizontal velocity sampled
  immediately before every active fixed step;
- above-reference share: those samples strictly above
  `target_speed_at(distance)` divided by sampled ticks;
- Reel-held time: pre-step authoritative Reel-active ticks ÷ 60;
- flies/km: collected flies divided by travelled kilometres, never absolute
  course position after a checkpoint/debug start.

## Verification

- `git diff --check` → **exit 0**.
- `python3 tools/verify.py --require-godot` on pinned Godot 4.7.1 → **exit 0**;
  import, boot, architecture, reproducible audio, and all 266 declared contracts
  passed, including 10 focused evidence contracts.
- `godot --headless --path . --script res://tools/run_history_layout_probe.gd`
  → **exit 0** after four settled frames with 100 records and JSON export at
  strict 1040×480.
- `tools/simulate.gd` one-run smoke → **exit 0**, reporting the shared mean/max,
  reference-share, action, Reel, and rescue fields.
- `python3 bootstrap.py check --strict` → **exit 0** after this required final
  status flip; existing advisory walls were read and no session gate remained.

PR #172 is the coherent implementation PR. `game-quality`, `substrate-gate`,
and the Android debug artifact are post-push observations; their exact results
belong in the PR and owner-facing handoff rather than being predicted here.

## Scope and data posture

No gameplay value, difficulty profile, physics, upgrade, economy, reward,
Campaign content, leaderboard schema, account/device/advertising identity,
network client, endpoint, analytics SDK, upload queue, consent flow, Play
publication, or Issue #2 state changed. Copying JSON is explicit and local; the
game itself transmits nothing.

## Device questions

1. Does Run History remain readable and scrollable on the owner's 1040×480
   device after an ordinary death and after a checkpoint/debug run?
2. Do final versus travelled distance, action counts, raw cause/region, rescue,
   build/seed/loadout, and eligibility match the run just played?
3. Does **COPY JSON** paste the complete `spider-swing-local-run-evidence@1`
   payload on Android, and do all history/export controls stay isolated from
   world input?
4. Does the code-65 debug APK update the existing dev package in place and
   preserve progression plus older settings?

## Known limitations

- The Android clipboard API has no acknowledgement; the in-game copy call still
  needs the device paste check above. Selectable JSON remains the fallback.
- Only settlement-backed completions are retained. Tutorial practice and
  abandonment are intentionally outside this ledger.
- No trustworthy persisted clock contract exists, so there are no first/recent
  timestamps or day-return inference.
- The evidence schema is not a leaderboard entry and implements no ranking,
  remote trust, identity, or automatic collection.

## Next slice

The most valuable next implementation is a small, local first-session tester
prompt tied to a completed record ID and included in the same manual export.
It should ask one closed comprehension/fairness question at a time, without
automatic upload; recruitment, consent for transmission, and rewards remain
separate owner decisions.

## 💡 Session idea

Pair the rich local record with the existing settlement identity at one terminal
seam, while keeping persistence failures unable to affect progression. The
Campaign identity edge made the final shape better: linked, not conflated.

- **📊 Model:** gpt-5 · high · feature build
