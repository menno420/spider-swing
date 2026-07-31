# ADR 0004 — Deterministic moving parts and moving web anchors

> **Status:** `binding`
>
> Decided 2026-07-31 for Ruined Arboretum and every later zone.
> Extends ADR 0002 and the GDD's moving-hazard/anchor contracts (§§ 6.2, 9.3,
> 9.4, 19.2, and 21).

## Context

The shipped course is static. `CourseStream` derives a bounded set of polygons
from chunk index plus course seed, and `SimulationWorld` consumes that geometry
at a fixed 60 Hz. Contracts already require identical player trajectories at
30/60/90/120 Hz render rates and byte-equivalent authored geometry when an
off-grid debug start reaches the same chunks as sequential streaming.

Ruined Arboretum is deliberately the first place where the world moves. Its
signature attachment is the pivot of a swinging glass pane. Later regions add
rotors, lightning phases, patrolling residents, falling embers, and deterministic
wind. Implementing any of those as a Godot physics body, an animation callback,
or a runtime random draw would add a second simulation authority and make the
existing replay/debug guarantees false.

A moving web anchor is the highest-risk case. Solving an ordinary static-anchor
rope against a teleported anchor removes velocity in the wrong frame and can add
energy every tick. The GDD therefore requires a web-compatible moving object to
expose its velocity to the constraint.

## Decision

### 1. Authored descriptors stay immutable

`CourseStream` remains the sole author of chunk content. It emits static base
polygons and typed motion/anchor descriptors into `CourseGeometry`. Every
descriptor contains a stable content id, its owning `chunk_index`, the
`course_seed`, and integer-tick phase parameters. Generation may hash those
inputs once to choose a phase offset; active play never draws randomness.

The descriptor is the geometry-equality contract. A direct debug start and a
sequential stream over the same chunks must produce identical descriptors. An
evaluated frame is equal whenever `(chunk_index, course_seed, tick)` is equal.

### 2. One pure phase evaluator owns environmental motion

The simulation layer evaluates every moving part as a pure function:

```text
sample = f(base geometry, chunk_index, course_seed, tick)
```

The result contains the current polygon or anchor point, the next-tick sample,
and velocity derived from their difference over the fixed delta. Supported
motions are bounded authored functions such as rotation about a pivot, pendulum
rotation, looped translation, and phase visibility. There is no accumulated
transform, `RigidBody2D`, `AnimationPlayer` authority, wall-clock time, floating
elapsed-time phase, or runtime RNG call. Rebuilding the same tick is idempotent.

Continuous zone forces follow the same rule. Wind is a bounded vector field over
world position whose phase is derived from `(chunk_index, course_seed, tick)`.
It is evaluated in the ordinary movement-forces stage and never changes the
approved base `SwingConfig` preset.

### 3. Phase resolves at the fixed-step boundary

At the beginning of a fixed tick, `SimulationWorld` evaluates current and next
environment samples. Commands target that current sample. Movement forces use
the same phase; the rope then solves against the next anchor sample; collision
checks sweep the player and moving polygon from current to next. The world
increments `tick` only after the complete authoritative result is committed.

Presentation receives evaluated snapshot geometry plus stable visual/anchor
metadata. It may draw rest-position ghosts, motion trails, rain, ash, or fog,
but cannot evaluate a different gameplay phase. Reduced Motion may reduce
decorative trails and particles; it never freezes or retimes authoritative
hazards.

### 4. Moving anchors are stable bindings, not copied points

An attachment result carries an anchor class and stable source id. Ordinary
surfaces bind to a fixed point. A moving pivot binds to the descriptor's pivot
sample. Ridable and sticky silk are separate anchor classes on safe anchor
surfaces; they are not encoded as lethal-obstacle flags. A destroyed or expired
source releases the web once through the normal authoritative event path.

For a moving pivot, the web solver works in the anchor's reference frame:

- predict the spider and anchor at the next tick;
- measure rope extension against the predicted anchor;
- remove only outward **relative** radial speed
  `(spider_velocity - anchor_velocity) · radial_direction`;
- apply the existing capped positional correction;
- transform the corrected relative velocity back to world space.

The anchor may perform bounded physical work — a moving support should carry the
spider — but the solver may not create energy relative to that support. Anchor
speed and positional correction remain bounded by authored data and the existing
correction cap. A simulator regression compares moving- and static-anchor energy
over complete cycles before the mechanic may ship.

### 5. Player-triggered anchor expiry is deterministic state, not world motion

Ashen Hollow's rotten branch and collapsing span remain static collision
geometry. Attaching records an integer `expires_at_tick`; reaching that deadline
invalidates the anchor and emits one release/failure event. This state is fully
reproducible from the fixed input trace and tick sequence but is not used to
animate a physics body. Falling ember scenery/hazards around it still use the
pure environmental phase evaluator.

### 6. Collision and target affordances remain explicit

Every lethal polygon is appended through
`CourseGeometry.append_obstacle(polygon, anchorable)`. Ceiling-grown furniture
may answer web taps; floor-grown hazards do not. If only a pivot is safe to grab,
the lethal blade/pane is `NOT ANCHORABLE` and a separate typed anchor surface or
point represents the visible pivot. Presentation must not draw hooks, sockets,
or ledges on an untappable hazard.

## Required verification

Before any moving region is complete, executable contracts must prove:

- identical phase samples and trajectories at simulated 30/60/90/120 Hz;
- exact descriptor equality for sequential and off-grid chunk construction;
- no runtime RNG or mutable accumulated transform in the phase path;
- swept contact against moving polygons, including a fast crossing case;
- moving-pivot attachment follows the exact sampled anchor and releases once if
  the source becomes invalid;
- relative rope energy stays bounded over repeated complete anchor cycles and a
  zero-amplitude moving profile matches the static control;
- wind/phase fields reproduce for the same seed/tick and differ only through
  authored seed phase where intended;
- snapshot geometry, anchor eligibility, rest telegraphs, and presentation ids
  come from the same authoritative sample.

`tools/simulate.gd` is diagnostic evidence, not a feel oracle. If the production
constraint cannot satisfy the moving-anchor energy contract, the signature pivot
attachment stays disabled and the limitation is reported plainly rather than
hidden behind looser tolerances.

## Consequences

- Moving content adds one reusable deterministic phase seam instead of a new
  Node/animation implementation per zone.
- Static regions pay only bounded descriptor-copy overhead; phase evaluation is
  limited to the retained seven-chunk window.
- Motion can be reconstructed from a seed, chunk, and tick in diagnostics and
  recordings without serializing every transform.
- Collision, targeting, web binding, and rendering share one evaluated sample,
  so visible motion cannot drift away from lethal geometry.
- New motion kinds require a test and an extension to the pure evaluator; they
  do not patch the application loop or presentation clock.

## Alternatives considered

- **Godot physics bodies or joints** — rejected: a second integration authority,
  frame/order sensitivity, and no exact off-grid reconstruction.
- **`AnimationPlayer` or presentation-time transforms** — rejected: the art
  would move while collision and anchors remained elsewhere.
- **Runtime seeded RNG per tick** — rejected: draw order would become state and
  streaming/rebuilds could advance it differently.
- **Teleport the existing point anchor each tick** — rejected: it solves radial
  velocity in world space and injects energy as the support moves.
- **Make moving hazards visual-only** — rejected: it would fail Ruined
  Arboretum's timing axis and teach the player that visible lethal edges lie.
