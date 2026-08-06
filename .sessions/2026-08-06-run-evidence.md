# Build the local run-evidence system

> **Status:** `in-progress`

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

## Working close-out

Implementation, verification, PR, artifact evidence, owner checks, and final
limitations will be recorded here before the status is flipped.

## 💡 Session idea

Pair the rich local record with the existing settlement identity at one terminal
seam, while keeping persistence failures unable to affect progression.

- **📊 Model:** gpt-5 · high · feature build
