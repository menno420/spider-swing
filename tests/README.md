# `tests/`

## Running

```bash
python3 tools/verify.py    # the entry point — runs everything
```

Or the runner alone:

```bash
godot --headless --path . --script res://tests/test_runner.gd
```

Exits 0 on pass, 1 on failure. Every check runs even after one fails, so a single
failure never hides the rest.

## Layout

| Path | Purpose |
| --- | --- |
| `test_runner.gd` | Headless entry point and bootstrap/build contracts. |
| `unit/phase0_physics_tests.gd` | Fixed-step movement, web, rope actions, course, collision, and trajectory contracts. |
| `unit/mobile_hud_layout_tests.gd` | GUI ownership, shared hit geometry, gesture separation, and action-feedback wiring. |
| `integration/front_end_flow_tests.gd` | Home, Tutorial, Settings, persistence, and run-mounting contracts. |
| `fixtures/` | Deterministic inputs — fixed seeds, recorded input traces, save files. |

## What exists now

50 runtime contracts: bootstrap/build truth plus twenty-three deterministic physics,
ten mobile HUD, and eight front-end checks. The physics group proves continuous
solid targeting, larger aim forgiveness, momentum-preserving release,
speed-neutral Reel shortening, exact percentage Burst/Dive Pull travel,
recovery-web interruption, detached cooldown double-tap fallback, explicit
release/retarget behavior, shaped bounded geometry with lower anchor windows,
authoritative polygon obstacles/boundaries, and equivalent trajectories through
simulated 30/60/90/120 Hz render loops. The HUD group proves the 228×228 thumb
targets, event consumption, shared geometry, gesture separation, and success
feedback.

## Writing tests

Determinism is the whole point. Fixed seeds and recorded input traces in
`fixtures/`; never wall-clock timing, never frame-count-dependent assertions.

The GDD § 22.2 list is the target set as systems arrive:

- release preserves velocity within tolerance;
- Reel-In shortens rope length at the configured rate and never teleports;
- invalid targets do not create a constraint;
- settlement is idempotent;
- a collision produces only one outcome;
- power-up refresh and expiry rules are stable;
- a seed produces the same chunk sequence for the same content version;
- save migrations preserve balances and unlocks;
- pooled objects reset all gameplay state;
- standard mode ignores permanent upgrades;
- every released chunk passes metadata and route validation.

See `docs/technical/testing.md`.
