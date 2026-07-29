# Wide gate and clean-start diagnostics session

> **Status:** `in-progress`

## Goal

Turn the split root gate into a broad, steerable passage that grows from the
ceiling and floor, then make collision outlines and web-target guides opt-in
diagnostics instead of startup visuals.

## Scope guard

This session changes the gate's authoritative geometry and matching presentation,
diagnostic-display state and controls, regression coverage, documentation, and
development build identity. It does not retune spider movement, progression,
rewards, speed pacing, gate frequency, or unrelated obstacle geometry.

## Previous-session review

**previous-session review:** PR #23 replaced the collision-closed root ring with
two disconnected upper/lower pieces and proved a Classic-sized circle could cross
their exact centre line. Menno's `0.8.1-split-gate-test` Android recording shows
that this proof was too narrow: a real swing cannot hold the exact horizontal
centre line, and the two small floating pieces still read as a precision obstacle
rather than one usable opening.

## Decisions flagged

- Validate a vertical steering envelope across the full gate, not only its exact
  centre line.
- Root the upper and lower gate pieces into the existing lethal rails so the art,
  collision, and environmental meaning all describe one passage.
- Keep the DEBUG panel available, but give collision outlines and web guides
  separate off-by-default controls inside it.

## 💡 Idea

Treat route readability as a volume contract: a collectible trail needs enough
clearance for the spider's body plus realistic steering error over the entire
advertised passage.

- **📊 Model:** gpt-5 · high · runtime bugfix

## Verification evidence

Pending implementation and gate runs.

## Documentation audit

Pending.

## Remaining owner review

Pending a verified Android candidate.
