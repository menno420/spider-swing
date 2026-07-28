# Phase 0.8 recovery web controls session

> **Status:** `in-progress`

## Goal

Turn the latest Android recordings into a safer, more deliberate control
contract: a Burst or Dive Pull can always be interrupted by a normal recovery
web, rapid double-taps cannot swallow that recovery input, forward right-hand
taps have practical reach, and lower anchor windows exist before the hazards
that need downward redirection.

## Previous-session review

**previous-session review:** PR #13 made pull distance predictable and Reel
speed-neutral, but the next device recordings show that the short pull state
still monopolizes rapid double-taps. The percentage controls and solid-edge
resolver remain valid; input handoff and course-authored lower opportunities need
this follow-up.

## Planned evidence

- deterministic pull-interruption, double-tap arbitration, long-reach, and lower
  anchor coverage tests;
- local `python3 tools/verify.py` and `python3 bootstrap.py check --strict`;
- ready PR, green GitHub checks, merged main commit, and downloadable Android
  debug artifact.

## 💡 Idea

Treat Burst and Dive Pull as interruptible movement transitions rather than
temporary input modes: their cooldown limits repeated power use, but never owns
or disables the spider's ordinary web.

- **📊 Model:** gpt-5 · high · feature build
