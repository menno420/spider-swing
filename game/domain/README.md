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
- `CourseRegionCatalog`, the stable 5000 m region/checkpoint identities shared
  by generation, saves, diagnostics, and UI.
- `DomainEvent` values the simulation emits (GDD § 19.2).
- Stable content identifiers (GDD § 19.3): runtime logic refers to IDs, never to
  scene names or display text.
- Versioned gameplay configuration contracts — the tunable-parameter set in
  GDD § 6.6, including shared web range and the authoritative Reel/Burst pull
  strengths, Reel hold time, minimum response speeds, and Burst tangential
  retention.
- `RunSettlement` and its identity/eligibility flags, so idempotent standard and
  non-record practice settlement is expressible in one place (GDD § 15.1,
  § 20).
- `SpiderCatalog` profile and upgrade definitions. Profiles are modifiers over
  one `SwingConfig`; they do not fork the physics implementation. Every profile
  instantiates one canonical five-track core plus two identity tracks, with 20
  levels and deterministic breakthroughs at 5/10/15/20. `resolved_config()`
  always begins from a fresh named preset before applying one profile and its
  upgrades, preventing repeated mount paths from compounding modifiers.
- Versioned `PlayerProgress`, including spendable/lifetime flies, selections,
  capped upgrade levels, proportional migration from the former five-level
  schema, the local creator pattern, and reached practice checkpoints.

## What does not

Anything that touches the scene tree, physics bodies, files, or rendering.

`InputCommand`, `CourseGeometry`, `CourseRegionCatalog`, `SimulationEvent`,
`SimulationSnapshot`, `SwingConfig`, `SpiderCatalog`, `PlayerProgress`, and
shared layout contracts are live. The shared layout contract
owns both drawn and interactive rope-action geometry so tests and adapters cannot
silently disagree. `SimulationSnapshot` also carries independent, off-by-default
collision-outline and web-guide presentation flags; neither flag changes
authoritative geometry. See ADR 0002.
