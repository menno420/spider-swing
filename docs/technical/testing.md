# Testing and verification

> **Status:** `reference`
>
> How to verify Spider Swing locally and what CI enforces.

## The two gates

There are exactly two commands. Both must pass before work lands.

```bash
python3 tools/verify.py            # host + game code
python3 bootstrap.py check --strict # Substrate doc/session hygiene
```

They are deliberately separate and **never call each other**. `tools/verify.py`
must not invoke the Substrate checker: the Substrate workflow runs
`bootstrap.py check` itself and also runs `tools/verify.py`, so calling one from
the other would recurse.

## `python3 tools/verify.py`

The single host verification entry point. Runs seven reported steps in order and reports a
summary; any failure exits nonzero.

| Step | What it proves |
| --- | --- |
| 1. Audio reproducibility | `tools/generate_audio_samples.py --check` regenerates every original WAV in a temporary directory and compares exact bytes plus the manifest. |
| 2. Architecture self-test | `tools/check_architecture.py --self-test` proves all 14 legal/illegal fixtures. |
| 3. Architecture scan | The live repository still obeys inward dependencies. |
| 4. Godot discovery/version | A Standard binary is locatable and reports the pinned 4.7.1 version. |
| 5. Headless import | `godot --headless --import` finds no script parse or resource-import errors. |
| 6. Boot smoke test | The real main scene mounts the front end before gameplay. |
| 7. Contract runner | `tests/test_runner.gd` executes the exact declared suite. |

Godot can occasionally return exit code `0` while printing a GDScript parse or
compile failure. `tools/verify.py` therefore treats the engine's fatal script
diagnostics as failures independently of its process code. The test runner also
asserts its exact declared total, so a runtime error cannot silently turn two
unexecuted checks into a smaller green suite.

It **never downloads anything**. A missing Godot is reported with instructions,
not silently fetched — a verification tool that installs its own dependencies can
pass on a machine that could not actually build.

### Engine present, absent, or wrong

Two CI jobs run this script and they have different toolchains, so it has three
outcomes rather than two:

| Situation | Result |
| --- | --- |
| Godot installed, correct version | Everything runs. |
| Godot **absent**, no flag | Engine-independent checks run strictly; engine steps report **`SKIP`** behind a loud banner saying nothing about the Godot project was verified. Exit 0 if the strict checks passed. |
| Godot **absent**, `--require-godot` | **Hard failure.** |
| Godot present but **wrong version**, or a **Mono/.NET** build | **Hard failure, always** — in every mode. An engine that is present but wrong is a real defect, never a skip. |

`game-quality` installs Godot and runs `python3 tools/verify.py --require-godot`,
so **the gate that proves the engine can never silently skip it** — a skip there
could only mean the install failed.

The kit-owned `substrate-gate` also runs this script, because it is the
repository's confirmed `verify_command` interview slot, but that job is Python-only
by design. There it does real work — the architecture self-test and scan — and
honestly reports the engine steps as skipped instead of manufacturing a pass or
turning a red gate into a complaint about a tool that job was never meant to have.

### Local setup

Install Godot 4.7.1 **Standard** (not .NET) from the
[Godot download archive](https://godotengine.org/download/archive/), then either
put it on PATH as `godot` or point `GODOT_BIN` at it:

```bash
export GODOT_BIN=/path/to/Godot_v4.7.1-stable_linux.x86_64
python3 tools/verify.py
```

Requires Python 3.10+. Nothing to `pip install` — the tooling is stdlib-only.

For a fast pass that skips the engine steps even when Godot *is* installed, use
`python3 tools/verify.py --skip-godot`. CI never uses that flag.

## What `tests/test_runner.gd` asserts

Run directly:

```bash
godot --headless --path . --script res://tests/test_runner.gd
```

175 checks, grouped so one subsystem failure never hides the rest:

- engine, main-scene, input-action, 60 Hz, renderer/viewport, Android preset,
  inward-dependency, and no-autoload bootstrap contracts;
- fifty-seven deterministic physics contracts, including extended arbitrary-point
  solid attachment, larger aim forgiveness, momentum preservation, speed-neutral
  Reel and automatic take-up, a bounded 2.0-second/520-pixel base Reel budget,
  deterministic non-compounding Reel upgrade resolution, runtime full-meter
  hold-time tuning, maxed Balanced Flow producing a shorter web,
  exact Burst/Dive distance shares and minimum
  Burst travel, unchanged level-zero Burst cadence plus the level-10 stored
  reserve Burst on one serial refill timer, recovery-web interruption,
  detached cooldown double-tap fallback, explicit release/retarget behavior,
  polygon anchoring/collision, a 1000 m runway, smooth 5000 m speed ramp, and
  bounded organic streaming with continuous contoured rails, lower rail
  coverage, independent rail lethality, authoritative obstacle scaling, a
  deterministic distance-banded pattern catalog with repetition protection and
  both single/paired natural compositions, authored high↔low weave envelopes,
  seeded 5000 m region identities, bounded recovery cadence, route-clear
  seed variation, and safe non-record checkpoint starts,
  minimum weave cue spacing and a forgiving central transition band,
  compact silk-burr bounds, a
  three-lane Classic-sized steering-envelope sweep through every root-passage
  fly route, the guided opening
  trajectory, one-run rescue, five spider profiles, the shared
  five-core/two-identity upgrade structure, 20-level cost bounds,
  5/10/15/20 breakthroughs, level-zero preservation,
  bounded glide and impact-shell recovery, creator-pattern bounds, swept
  pickups, runtime pull tuning, and
  exact off-grid polygons plus identity/anchor/motion descriptors through every
  owned late zone, and identical trajectories from
  simulated 30/60/90/120 Hz render loops;
- fifteen zone-progression contracts proving the append-only 5 km schedule, explicit
  hazard eligibility, pure seeded phase sampling, swept moving collision,
  energy-safe moving-pivot binding, all documented density thresholds, typed
  highway/sticky/rotten anchors, audio-first Mist cues, explicit finished-art
  routing for all recorded 10–30 km obstacle/surface families, two-plane depth,
  diagnostic-only outlines, ceiling-support continuity, and a current 33-asset
  source/runtime/25% alpha plus silhouette audit;
- eleven spider-biology contracts keep profile identity and disclosures separate
  from balance data;
- ten Campaign contracts prove verb-gated clears, fixed seeds, one-time stars,
  and noncompetitive settlement;
- nine difficulty contracts prove per-mode bests and content/recovery variation
  without any physics change;
- four upgrade-wiring contracts retain all seven saleable tracks and guard the
  simulator's known blind spots;
- four simulation-lab input contracts prove the measurement tool receives
  typed anchor classes, timed-anchor life, and the real Dive input path without
  freezing any bot conclusion;
- two economy contracts keep flies and Campaign stars in their declared lanes;
- six generated-SFX contracts prove original/reproducible provenance, exact
  catalog parity, Android-sized PCM/headroom, core-event coverage, variant and
  cooldown policy, five distinct later-zone warnings, and optional effects/
  haptics wiring;
- twenty-five mobile HUD contracts proving large separated Reel and Burst controls,
  DEBUG, and Menu are event-consuming
  Buttons, GUI geometry shares one layout source, accepted actions drive visual
  and haptic feedback, UI actions do not leak into web input, debug tools can be
  removed, collision outlines and web-target guides are independent opt-in
  controls, finished Ancient Forest obstacles never paint the legacy polygon
  backing, wall-grown art overlaps behind continuous rails without stretched
  gate halves, active Ancient Forest art includes a world-anchored rail tile,
  growth socket, stump, and three depth layers, custom fixed-snapshot spider
  interpolation, mipmapped moving art, restrained/reduced-motion-safe action
  poses, region ambience and persistent practice status remain presentation-only,
  and world input waits for Godot GUI handling;
- twenty-one front-end contracts proving Home starts before gameplay,
  Play/Garage/Shop/Tutorial/Campaign/Course Lab/Region Practice/Field Guide/
  Settings route correctly,
  the six tutorial
  steps cover live mechanics, Settings
  is touch-scrollable from every descendant control/card region without focus
  snapping and remains mobile-readable, options (including independent effects
  and haptics) validate and emit once, serialization is stable, atomic filesystem persistence
  round-trips, progression settlements remain idempotent, the seven-track Shop
  remains mobile-scrollable, one central forest-web theme skins every screen,
  custom body/Silk rails and the Silk preview replace native dropdowns, former
  five-level saves migrate once and
  proportionally, profile upgrades and creator edits persist, milestone unlocks
  persist, every fifth-level Shop purchase is explicitly described as two
  tuning steps with a derived max summary, and only a play request mounts the
  run. Checkpoint migration and practice settlement tests prove reached regions
  round-trip while practice grants no flies and cannot update best distance.

The physics group lives in `tests/unit/phase0_physics_tests.gd`, zone content in
`tests/unit/zone_progression_tests.gd`, mobile input in
`tests/unit/mobile_hud_layout_tests.gd`, and the front-end flow in
`tests/integration/front_end_flow_tests.gd`. The trajectory fixture is
`tests/fixtures/phase0_trace.json`.

## `tools/check_architecture.py`

Enforces the inward dependency direction from
[ADR 0002](adr/0002-simulation-and-event-boundaries.md) across GDScript `preload`,
`load`, `extends` (including `class_name` resolution through a class index), bare
`res://game/<layer>/` references, and `[ext_resource]` paths in `.tscn`/`.tres`.

```bash
python3 tools/check_architecture.py             # scan the repository
python3 tools/check_architecture.py --self-test  # check the checker
```

The self-test carries 14 fixtures asserting **both** directions — that legal
inward references pass and that each illegal outward reference is caught — so the
checker cannot silently degrade into a no-op that approves everything. Comment
lines are stripped before scanning, so prose mentioning another layer is not a
dependency.

It is a deterministic static text scan with a known limit: a dynamic
`load(some_variable)` is not resolvable statically. That gap is covered by review,
not by pretending the scan is total.

## Simulation lab (not a gate)

`tools/simulate.gd` batch-runs the authoritative simulation headlessly with an
imperfect scripted player and reports distance/death/resource statistics for
balance work. It asserts nothing and is never run by CI — the two gates above
remain the only gates. See [simulation-lab.md](simulation-lab.md).

## CI

| Workflow | Trigger | Required? | Proves |
| --- | --- | --- | --- |
| `game-quality` | PRs, pushes to `main`, dispatch | **Yes** | `python3 tools/verify.py` passes on a clean runner with Godot 4.7.1. Uses no secrets. |
| `substrate-gate` | PRs, pushes to `main` | **Yes** | Substrate doc/session hygiene, and runs `tools/verify.py` as its test step. Kit-owned. |
| `android-debug` | pushes to `main`, dispatch | No | The project exports an installable debug APK. Uses no secrets. |
| `auto-merge-enabler` | PR events | No | Arms native auto-merge on agent PRs. Kit-owned. |
| `branch-sweep` | schedule | No | Tidies merged agent branches. Kit-owned. |

`android-debug` is deliberately **not** a required check: it depends on external
SDK downloads, so making it required would convert a third-party outage into a
merge block. See ADR 0003.

### Kit-owned workflows

`substrate-gate.yml`, `auto-merge-enabler.yml`, and `branch-sweep.yml` are
generated by `python3 bootstrap.py adopt --include-claude --wire-enforcement`.
**Do not hand-edit them** — adopt/upgrade overwrites them in place. Change
`substrate.config.json` and regenerate. Host-specific CI belongs in
`game-quality.yml` or `android-debug.yml`.

The two host-owned workflows pin every `uses:` reference to a full commit SHA with
the release tag in a trailing comment. The kit-owned workflows use upstream's own
tag references; that is the kit's template, and hand-pinning them would be
overwritten on the next upgrade.

## Adding gameplay tests

Keep simulation checks deterministic: fixed seeds and recorded input traces in
`tests/fixtures/`, never wall-clock timing. Register suites in
`tests/test_runner.gd`. New moving content must extend ADR 0004's pure phase,
swept-contact, off-grid descriptor, and moving-anchor contracts rather than add
a second animation or physics authority.
