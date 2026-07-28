# ADR 0002 — Simulation, layering, and deterministic event flow

> **Status:** `binding`
>
> Decided 2026-07-28, founding bootstrap session.
> Implements the GDD's technical architecture (§ 19) and resolution order (§ 8).

## Context

The GDD opens § 19 with an explicit prohibition: *avoid a collection of global
`Manager` singletons*. It then specifies a deterministic simulation core, explicit
orchestration, data-defined content, and presentation adapters, plus a one-way
event flow (§ 19.2) and a strict per-tick resolution order (§ 8).

Those are architectural constraints, not style preferences. Three GDD guarantees
depend on them structurally:

- **One outcome per contact** (§ 13.2): repeated collision callbacks in the same
  tick must not consume multiple shields or settle the run twice.
- **Idempotent settlement** (§ 15.1, § 20): applying the same settlement twice has
  no effect, and app suspension during death cannot duplicate rewards.
- **Presentation cannot alter truth** (§ 19.2): persistence cannot grant currency
  from a raw collision callback.

A layered dependency rule is what makes those guarantees checkable rather than
merely intended.

## Decision

### Inward dependency direction

Six layers under `game/`, with dependencies pointing strictly inward:

| Rank | Layer | Contains | May depend on |
| ---: | --- | --- | --- |
| 0 | `domain/` | Engine-independent value objects, commands, events, identifiers, configuration contracts | nothing |
| 0 | `content/` | Versioned data definitions (spiders, effects, chunks, missions, economy) | nothing |
| 1 | `simulation/` | Fixed-step spider motor, web constraint, collision policy, deterministic run model | `domain` |
| 2 | `application/` | Run state machine, difficulty director, world stream orchestration, effects, score, settlement | `domain`, `simulation` |
| 3 | `adapters/` | Godot input, scenes, persistence, telemetry, platform integration | `domain`, `simulation`, `application` |
| 3 | `presentation/` | UI, camera, audio, VFX, rendering | `domain`, `simulation`, `application` |
| 4 | `bootstrap/` | The composition root; wires the graph together | anything |

`adapters` and `presentation` are **equal-rank peers**: neither may depend on the
other. Cross-cutting needs go inward into `domain`, or invert through an event.

`domain` imports no Godot-facing layer. It may use Godot's own base types
(`RefCounted`, `Vector2`) — "engine-independent" here means independent of *this
game's* Godot-facing layers, not a ban on the engine's value types, which would
be impractical in GDScript.

### Deterministic event flow

```
input → buffered command → fixed-step simulation → domain events
      → presentation/telemetry → run settlement → persistence
```

Enforced rules, each traceable to a GDD guarantee:

1. **Input never mutates simulation.** Touch and UI input becomes buffered
   `InputCommand` values, sampled during rendering and consumed on the next
   physics tick. A valid tap is never lost between ticks (GDD § 5.3).
2. **The tick order is fixed** and follows GDD § 8 exactly: consume commands →
   update pace and forward drive → gravity and movement forces → web constraint
   and Reel-In → advance physics → collectible contacts → hazard contacts through
   the central collision policy → emit domain events → update presentation.
3. **`CollisionPolicy` is the sole authority on contact outcomes.** Phasing,
   shield absorption, and breakable destruction all resolve there, and exactly one
   outcome is committed per contact (GDD § 13.2).
4. **Settlement is single and idempotent.** After death `RunStateMachine`
   requests exactly one `RunSettlement`; `ProgressionService` validates and
   applies it; `SaveRepository` performs one atomic versioned write.
   `SaveRepository` is the exclusive owner of persistent writes.
5. **Presentation is read-only with respect to truth.** It consumes events and
   cannot grant rewards, alter simulation state, or write saves.
6. **No global gameplay `Manager` singletons.** Autoloads are an architecture
   decision requiring their own ADR; `tests/test_runner.gd` fails on any autoload
   appearing without one.

### Enforcement

- `tools/check_architecture.py` scans `preload`, `load`, `extends` (including
  `class_name` resolution), bare `res://game/<layer>/` references, and
  `[ext_resource]` paths in scenes. It carries 14 fixtures asserting both
  directions of the rule, so it cannot silently degrade into a no-op.
- `tests/test_runner.gd` keeps an in-engine copy of the inward check and asserts
  the no-autoload rule.
- Both run under `python3 tools/verify.py`, which the `game-quality` CI check runs.

## Consequences

- Adding a system means choosing its layer first. A system that seems to need an
  outward dependency is a design smell: move the shared contract into `domain`, or
  invert it with an event.
- Missions, telemetry, and presentation all consume domain events rather than
  reading gameplay objects directly, so each can be added without touching the
  simulation (GDD § 16, § 19.4).
- The checker is a *static text* scan. A dynamic `load(some_variable)` can evade
  it; that is a deliberate limit, covered by review rather than by pretending the
  scan is total.
- Phase 0 will populate `simulation/` and `domain/` first. The layer directories
  exist now with README files so the boundary is visible before any code lands.

## Alternatives considered

- **Autoload singletons per system** (`GameManager`, `SaveManager`, …) — rejected:
  the GDD forbids it explicitly (§ 19), and it makes the one-outcome-per-contact
  and idempotent-settlement guarantees untestable because any callback can reach
  any system.
- **Nodes-as-architecture** (scene tree order as the ownership model) — rejected:
  tick order becomes an emergent property of tree order, which is exactly the
  nondeterminism GDD § 8 exists to prevent.
- **A single flat `src/`** with review-only discipline — rejected: unenforceable,
  and the owner relies on agents keeping the boundary without human code review.
