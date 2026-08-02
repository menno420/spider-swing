# Mobile Test Run scrolling

> **Status:** `in-progress`

## Goal

Make every Test Run setup control and the primary start action fully reachable on phone viewports through one native vertical scroller, while preserving the existing session-only tuning and noncompetitive-run contracts.

## Scope guard

Presentation layout and its mobile/integration contracts only. Do not change bird tuning, upgrade values, progression, persistence, simulation, or ordinary Play.

## Planned verification

- Falsify the new scroll/layout contract before trusting it.
- `python3 tools/verify.py --require-godot`
- `python3 bootstrap.py check --strict`

## Next slice

Expand all upgrade tracks from 20 to 40 levels with proportional save migration, a longer fly-cost curve, smaller per-level gains, and a larger level-40 total reward.

- **📊 Model:** gpt-5 · high · focused mobile UX fix
