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
| `test_runner.gd` | Headless entry point. Currently asserts the 15 bootstrap contracts. |
| `unit/` | Per-system tests. |
| `integration/` | Cross-system tests. |
| `fixtures/` | Deterministic inputs — fixed seeds, recorded input traces, save files. |

## What exists now

15 configuration and architecture contracts: engine version, main scene resolves
and instantiates, the five input actions, 60 Hz fixed tick (on disk *and* as the
engine reports it), 4 catch-up steps, Compatibility renderer, 1280×720 viewport,
landscape orientation, the `Android Debug` preset and its development-only package
identifier, inward dependency direction, and no autoload singletons.

**No gameplay tests, because there is no gameplay.** That is the bootstrap scope
boundary, not an omission.

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
