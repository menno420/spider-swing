---
state: routed
origin: owner
shipped_pr: null
shipped_repo: null
merged_date: null
outcome: open
---

# Timed traversal envelopes for authored obstacle sequences

> **Status:** `ideas`

## Why this exists

Bramble's original passability proof swept a Garden-sized circle along an
ideal fly guide, yet owner-device play showed the first sequence was
effectively impossible. The proof checked where a player could fit, but not
whether a swinging player had enough time and recovery space to get there.

## Route

**Structured plan after PR #86's device verdict.** If Bramble's timed envelope
survives real play, extract the shared measurements—obstacle occupancy, time
between commitments, preparation space, recovery space, and route clearance—
into a reusable validator for static patterns. Moving, force-field, timed-anchor
and fog zones need mechanic-specific extensions rather than pretending one
static formula certifies them.

## Guardrails

- Device play remains the acceptance authority; this validator prevents known
  structural mistakes and cannot declare a zone fun or balanced.
- Derive time from the authoritative target speed and world-space geometry.
- Keep zone-specific limits beside the pattern catalog, not in presentation.
- Do not tune movement to make a bad content envelope pass.

## Next proof

Install the source-identified PR #86 APK, start at 5000 m with MAX upgrades,
and confirm that the opening hazards are passable while Bramble still demands
clear high↔low commitments. Promote the abstraction only if that verdict is
positive.
