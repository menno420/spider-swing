# Restore the compact Debug Test Run launcher

> **Status:** `in-progress`

## Goal

Restore the former quick Debug Test Run setup as a distinct Home route for
distance, one temporary all-track upgrade level, bird configuration, and an
immediate noncompetitive start. Preserve the complete persistent Test Lab as an
Advanced Test Lab route and leave the concurrent menu-style work untouched.

## Scope guard

Front-end state, routing, quick-launch presentation, staging semantics,
regression contracts, build identity, and living documentation only. Do not
change ordinary Play, upgrade ownership, saved progression, simulation tuning,
the Test Lab parameter catalogue, A/B/C profiles, or menu visual direction.

## Planned verification

- Prove Home opens the compact launcher first and Advanced Test Lab remains
  reachable from it.
- Prove quick runs apply only visible distance, temporary upgrade, and bird
  choices; saved advanced overrides must not leak into them.
- Measure the restored screen at 1280×720, 1280×600, and 1040×480.
- Falsify routing, upgrade overlay, baseline isolation, and reward eligibility.
- `python3 tools/verify.py --require-godot`
- `python3 bootstrap.py check --strict`

## About to happen

Recover the former purpose-built launch form from repository history, reconnect
it to the current state-owned navigation, and keep the detailed Test Lab behind
an explicitly secondary action.
