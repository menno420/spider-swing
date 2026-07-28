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

The single host verification entry point. Runs five steps in order and reports a
summary; any failure exits nonzero.

| Step | What it proves |
| --- | --- |
| 1. Godot discovery | A Godot binary is locatable via `GODOT_BIN`, `GODOT`, `GODOT4`, or PATH. |
| 2. Version check | The binary reports the version pinned in `.godot-version` (4.7.1) and is **not** a Mono/.NET build. |
| 3. Architecture check | `tools/check_architecture.py --self-test` (14 fixtures), then the repository scan. |
| 4. Headless import | `godot --headless --import` — the project imports with no script parse errors. |
| 5. Headless run | The boot smoke test, then `tests/test_runner.gd`. |

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

31 checks, grouped so one subsystem failure never hides the rest:

- engine, main-scene, input-action, 60 Hz, renderer/viewport, Android preset,
  inward-dependency, and no-autoload bootstrap contracts;
- nine deterministic Phase 0 physics contracts, including momentum preservation,
  Reel behavior, boundaries, and identical trajectories from simulated
  30/60/90/120 Hz render loops;
- six mobile HUD contracts proving Reel, DEBUG, and Menu are event-consuming
  Buttons, UI actions do not leak into web input, debug tools can be removed, and
  world input waits for Godot GUI handling;
- seven front-end contracts proving Home starts before gameplay, Play/Tutorial/
  Settings route correctly, the five tutorial steps cover live mechanics, settings
  validate and emit once, serialization is stable, atomic filesystem persistence
  round-trips, and only Play mounts the run.

The physics group lives in `tests/unit/phase0_physics_tests.gd`, mobile input in
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
`tests/test_runner.gd`. The remaining GDD §22.2 targets arrive with their owning
phases: collision policy and seeded chunk selection in Phase 1, settlement
idempotence in Phase 2.
