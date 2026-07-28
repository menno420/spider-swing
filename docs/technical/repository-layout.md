# Repository layout

> **Status:** `reference`
>
> What lives where, and why. The binding rules behind this layout are ADR 0002
> (layering) and ADR 0003 (build strategy).

## Top level

```
.github/                 CI workflows, issue/PR templates, Dependabot
.sessions/               Substrate session cards (append-only session memory)
.substrate/              Substrate Kit state and staged packs (kit-owned)
assets/                  Art/audio: source files and runtime-ready exports
build/                   Build output. Contents ignored; build/.gitkeep committed
control/                 Substrate coordination bus (status heartbeat, inbox, claims)
docs/                    Durable documentation (see below)
game/                    All game code, layered (see below)
scripts/                 Substrate-planted helper scripts (kit-owned)
tests/                   Test runner, unit/integration tests, fixtures
tools/                   Host verification tooling (verify.py, check_architecture.py)

.editorconfig            Editor defaults; GDScript is tab-indented
.gitattributes           Text-native Godot resources marked as real source
.gitignore               Engine/editor/Android generated state, all signing material
.godot-version           4.7.1 — the single source of truth for the engine pin
CONSTITUTION.md          Substrate: the project's binding contract
README.md                Entry point
bootstrap.py             Vendored Substrate Kit v1.20.2 (kit-owned, do not edit)
bootstrap.py.sha256      The kit release's published checksum, for re-verification
export_presets.cfg       Export presets. One preset: "Android Debug"
project.godot            Godot project configuration
project.index.json       Substrate AgentContextPack index (areas → contracts)
substrate.config.json    Substrate Kit configuration
```

## `game/` — layered, dependencies point inward

Full rules and rationale in
[ADR 0002](adr/0002-simulation-and-event-boundaries.md). Summary:

| Directory | Rank | Contains | May depend on |
| --- | ---: | --- | --- |
| `game/domain/` | 0 | Engine-independent value objects, commands, events, identifiers, configuration contracts | nothing |
| `game/content/` | 0 | Versioned data definitions: spiders, effects, difficulty tiers, chunks, missions, upgrades, economy, cosmetics | nothing |
| `game/simulation/` | 1 | Fixed-step spider motor, web constraint, collision policy, deterministic run model | `domain` |
| `game/application/` | 2 | Run state machine, difficulty director, world stream orchestration, effects, score, settlement | `domain`, `simulation` |
| `game/adapters/` | 3 | Godot input, scenes, persistence, telemetry, platform integration | `domain`, `simulation`, `application` |
| `game/presentation/` | 3 | UI, camera, audio, VFX, rendering | `domain`, `simulation`, `application` |
| `game/bootstrap/` | 4 | The composition root; wires the graph and boots the game | anything |

`adapters` and `presentation` are equal-rank **peers** and may not depend on each
other.

`game/presentation/` splits into `scenes/` (`.tscn`) and `scripts/` (`.gd`) so a
scene and its script are findable from either side.

Enforced by `tools/check_architecture.py` (14 fixtures) and by
`tests/test_runner.gd`. Both run under `python3 tools/verify.py`.

## `assets/`

| Directory | Holds |
| --- | --- |
| `assets/source/` | Authoring files — vector originals, layered art, raw audio. Not shipped. |
| `assets/runtime/` | Engine-ready exports the game actually loads. |

The split exists so a large authoring file never has to be imported by the engine
or shipped in the APK.

**No Git LFS yet.** There are no large binary assets, and adding LFS before they
exist imposes a clone-time dependency for nothing. Revisit when real production art
lands — that is a decision worth an ADR at the time, because enabling LFS
retroactively rewrites history.

## `tests/`

| Path | Purpose |
| --- | --- |
| `tests/test_runner.gd` | Headless entry point. Asserts the bootstrap contracts. |
| `tests/unit/` | Per-system tests. Phase 0 adds fixed-rate and trajectory tests here. |
| `tests/integration/` | Cross-system tests (settlement idempotency, seeded runs). |
| `tests/fixtures/` | Deterministic inputs: recorded input traces, fixed seeds, save files. |

See [testing.md](testing.md).

## `docs/`

| Path | Holds |
| --- | --- |
| `docs/game-design/` | The GDD — the product and gameplay source of truth. Checksum-pinned. |
| `docs/product/` | Product-side status that is not gameplay design (e.g. name status). |
| `docs/technical/` | Technical reference. |
| `docs/technical/adr/` | Architecture decision records. Numbered, binding, superseded rather than deleted. |

Everything else directly under `docs/` is a Substrate-generated living ledger —
`current-state.md`, `CAPABILITIES.md`, `architecture.md`, `ownership.md`,
`runtime_contracts.md`, and so on. Those are **rendered from interview answers**:
change them via `bootstrap.py answer <slot> "..."` then `bootstrap.py render --live`,
not by hand-editing the output.

## What is committed vs generated

**Committed** — text-native Godot resources are real source:
`.gd`, `.tscn`, `.tres`, `project.godot`, `export_presets.cfg`, `.godot-version`.

**Ignored** — anything the engine, the Android toolchain, or a local editor
regenerates: `.godot/`, `.import/`, editor-local state, `android/` build state,
`build/*` output (except `.gitkeep`), Python caches.

**Never committed** — all signing and credential material: `*.keystore`, `*.jks`,
`*.p12`, `*.pepk`, provisioning profiles, `.env`. `.gitignore` refuses these so an
accidental `git add -A` cannot leak one. See ADR 0003.

## Conventions

- **No empty global `Manager` singletons.** The GDD forbids them (§ 19). An
  autoload is an architecture decision that needs its own ADR;
  `tests/test_runner.gd` fails on any autoload appearing without one.
- **No third-party Godot addons** were added during bootstrap. Adding one is a
  decision with a maintenance and review cost — it belongs in an ADR.
- **Stable IDs over names.** Runtime logic refers to content identifiers, never
  scene names or display text (GDD § 19.3).
- **GDScript is tab-indented**, matching the engine's own convention and the
  official style guide. `.editorconfig` encodes this.
