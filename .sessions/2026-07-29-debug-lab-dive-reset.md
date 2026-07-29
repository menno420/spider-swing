# Phase 0.11 debug lab and Dive reset

> **Status:** `in-progress`

## Goal

Turn Menno's first test of the merged gameplay-foundation build into two
contained improvements: make the DEBUG tuning surface understandable and
efficient on a phone, and replace Dive Pull's timer cooldown with a deterministic
one-use state that re-arms only after a successful normal web attachment to a
ceiling or obstacle.

## Scope

- Group the existing tuning controls by player intent instead of exposing one
  long parameter carousel.
- Use large touch targets, direct selection for common comparisons, plain names,
  units, live values, and short descriptions.
- Preserve every existing experimental setting and its single `SwingConfig`
  owner; presentation must consume metadata rather than invent a second config.
- Keep Anchor Burst's timed cooldown unchanged.
- Give Dive Pull no timed cooldown. One successful Dive consumes its charge; a
  qualifying upper/obstacle web attachment re-arms it.
- Add authoritative events/snapshot feedback and deterministic tests for the
  new Dive state.
- Keep the checksum-pinned GDD unchanged and avoid unrelated obstacle retuning;
  the first floating obstacle remains owner-test evidence for a later route
  tuning decision.

## Previous-session review

**previous-session review:** PR #16 merged the 1120-gravity/40%-Dive candidate,
speed-neutral take-up, paced course rails, fly/boost foundations, and a verified
Android build. Menno reports that the course rails and safe/lethal behavior work
well, but the current DEBUG carousel is difficult to navigate and the first
floating obstacle remains uncleared. This session changes control access and
Dive availability without silently changing the movement candidate or obstacle
geometry.

## Q-011 doc-hygiene review

The reported badge finding is the already documented, reason-carrying false
positive for the owner-authored GDD. Adding a badge would alter its pinned bytes;
the correct resolution remains the existing allowlist plus the status-bearing
`docs/game-design/README.md`. There is no new documentation drift to "fix" in the
frozen file.

## 💡 Idea

Define tuning controls once as typed descriptors—category, plain label, help
text, unit, step, and optional quick choices—then let both the phone panel and
tests consume that registry. Future upgrade previews can reuse the same
descriptors without duplicating simulation configuration or creating another
settings UI.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

Born red. Exact local/CI results, PR and Android artifact URLs, and the
documentation audit will be recorded before the final status flip.
