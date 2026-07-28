# `game/domain/` — engine-independent contracts

**Rank 0. Depends on nothing.**

Value objects, commands, events, identifiers, and configuration contracts. This is
the innermost layer: it imports no Godot-facing layer of this game.

"Engine-independent" means independent of this game's Godot-facing layers — not a
ban on Godot value types. Using `RefCounted` and `Vector2` here is fine and
expected; importing `game/simulation/`, `game/application/`, `game/adapters/`, or
`game/presentation/` is not.

## What belongs here

- `InputCommand` values produced by the input router and consumed by simulation, including the authoritative `BURST` command.
- `CourseGeometry`, the compact ceiling/guide/obstacle value crossing from the application stream into simulation.
- `DomainEvent` values the simulation emits (GDD § 19.2).
- Stable content identifiers (GDD § 19.3): runtime logic refers to IDs, never to
  scene names or display text.
- Versioned gameplay configuration contracts — the tunable-parameter set in
  GDD § 6.6.
- `RunSettlement` and its identity, so idempotent settlement is expressible in one
  place (GDD § 15.1, § 20).

## What does not

Anything that touches the scene tree, physics bodies, files, or rendering.

`InputCommand`, `CourseGeometry`, `SimulationEvent`, `SimulationSnapshot`, `SwingConfig`, and shared layout contracts are live. See ADR 0002.
