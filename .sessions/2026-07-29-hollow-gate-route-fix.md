# Hollow gate route fix session

> **Status:** `in-progress`

## Goal

Turn the Ancient Forest's closed round root obstacle into a physically traversable
split gate so its fly trail communicates a route the Classic spider can actually
follow.

## Scope guard

This session changes the gate's authoritative obstacle geometry, matching forest
presentation, deterministic route validation, documentation, and development build
identity. It does not retune spider physics, speed progression, rewards, course
frequency, or unrelated obstacles.

## Previous-session review

**previous-session review:** PR #22 added the first finished Ancient Forest art
slice while deliberately preserving existing course geometry. Menno's Android
recording of that build exposes a pre-existing topology error that the realistic
art made easier to see: a horizontal fly trail enters the centre of a closed ring,
but a 2D spider approaching from either side must collide with the ring wall before
it can reach the nominal hole.

## Decisions flagged

- The gate will become two separated upper/lower root arcs with an uninterrupted
  horizontal opening; visual and collision geometry must agree.
- Validation will sweep a Classic-sized circle along the advertised route rather
  than checking only isolated fly centres.

## 💡 Idea

Treat collectible trails as executable route contracts: every authored trail
segment should be clearance-tested against the same authoritative geometry used by
the simulation.

- **📊 Model:** gpt-5 · high · bug fix

## Verification evidence

In progress.

## Documentation audit

In progress.

## Remaining owner review

In progress.
