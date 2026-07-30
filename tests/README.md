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

91 runtime contracts: ten bootstrap/build checks plus forty-five deterministic
physics, twenty-one mobile HUD, and fifteen front-end checks. The physics group proves continuous
solid targeting, larger aim forgiveness, momentum-preserving release,
speed-neutral Reel and automatic take-up, the bounded base/max Reel resource
budgets, non-compounding config resolution, exact percentage Burst/Dive Pull travel,
recovery-web interruption, detached cooldown double-tap fallback, explicit
release/retarget behavior, a paced bounded organic course with lower rail routes,
independent rail lethality, swept pickups, authoritative polygon collisions, a
three-lane steering-envelope sweep through every rail-grown root passage, and
equivalent trajectories through
simulated 30/60/90/120 Hz render loops. The HUD group proves the 228×228 thumb
targets, event consumption, shared geometry, gesture separation, success
feedback, independent off-by-default collision/web-guide diagnostics, a
sprite-only finished forest obstacle policy, and one
authoritative world intent for a touchscreen event plus Godot's emulated mouse
copy. The front-end group includes actual filesystem
round-trips for settings and progression plus idempotent settlement application.

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
