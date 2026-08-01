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
| `unit/zone_progression_tests.gd` | Zones 3–8 geometry, deterministic motion, density gates, anchor classes, cues, and visual-audit contracts. |
| `unit/audio_presentation_tests.gd` | Generated-SFX provenance, PCM budget/headroom, event mappings, warning cues, variation/cooldowns, and optional feedback wiring. |
| `unit/mobile_hud_layout_tests.gd` | GUI ownership, shared hit geometry, gesture separation, and action-feedback wiring. |
| `integration/front_end_flow_tests.gd` | Home routes, Campaign, Settings, persistence, progression, and run-mounting contracts. |
| `fixtures/` | Deterministic inputs — fixed seeds, recorded input traces, save files. |

## What exists now

184 runtime contracts: eleven bootstrap/build checks plus sixty
deterministic physics, fifteen zone-progression, eleven spider-biology, ten
Campaign, nine difficulty, four upgrade-wiring, nine simulation-lab/replay, two
economy, six generated-SFX, twenty-five mobile HUD, and twenty-two front-end
checks. The bootstrap group pins the public stable debug signer and
rejects per-run key generation. The physics group proves continuous
solid targeting, larger aim forgiveness, bounded arc/rise-scored manual release
momentum with forced-detach exclusion and wrap-safe history,
speed-neutral Reel and automatic take-up, the two-second base resource plus the
owner-tested 400–450 px/s max Garden response band, non-compounding config
resolution, exact percentage Burst/Dive Pull travel,
recovery-web interruption, detached cooldown double-tap fallback, explicit
release/retarget behavior, a paced bounded organic course with lower rail routes,
independent rail lethality, swept pickups, authoritative polygon collisions, a
three-lane steering-envelope sweep through every rail-grown root passage, and
seeded 5000 m region identities with bounded recovery cadence, safe non-record
checkpoint starts, an arbitrary no-awards debug start, and exact seeded geometry
equivalence between late starts in every owned zone and traversal from zero,
including exact identity/anchor/motion descriptors, plus equivalent trajectories
through simulated 30/60/90/120 Hz render loops. The zone group proves the
append-only 5 km schedule, pattern-pool diversity, explicit tap eligibility,
pure periodic phase motion, swept moving collision, moving-pivot binding, each
documented density gate, highway/sticky/timed anchor semantics, Mist's audio
lead, explicit finished-art routing for every obstacle family seen in the
owner's 10 km/15 km recordings, and the current 25% silhouette/alpha audit. The
simulation-lab input group proves the measurement tool receives anchor classes,
timed-anchor life, and the actual Dive input path without asserting the bot's
conclusions. The audio group proves all 25
original WAVs reproduce exactly, remain within the mobile PCM/headroom budget,
cover their event/cue catalog, and keep high-frequency variation bounded. The HUD group proves the 228×228 thumb
targets, event consumption, shared geometry, gesture separation, success
feedback, independent off-by-default collision/web-guide diagnostics, a
sprite-only finished forest obstacle policy, mipmapped 384×181 transparent art
for all five profiles with one shared presentation renderer, and one
authoritative world intent for a touchscreen event plus Godot's emulated mouse
copy. The front-end group includes actual filesystem round-trips for settings
and progression, idempotent settlement application, checkpoint migration,
locked/unlocked non-competitive practice routes, and a selectable session-only
upgrade overlay that never serializes and restores exact owned levels.

## Writing tests

Determinism is the whole point. Fixed seeds and recorded input traces in
`fixtures/`; never wall-clock timing, never frame-count-dependent assertions.

The GDD § 22.2 list is the target set as systems arrive:

- manual release preserves the current velocity vector, adds only the bounded
  arc/rise-scored forward award, and forced detach adds no release award;
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
