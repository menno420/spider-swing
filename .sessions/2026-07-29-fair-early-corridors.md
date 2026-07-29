# Phase 0.14 fair early corridors

> **Status:** `in-progress`

## Goal

Correct the deterministic corridor pattern exposed by Menno's
`0.6.0-gradual-progression-test` recordings: keep the first 2000 m spacious,
prevent floating gates from being paired with inward-moving lethal rails that
erase their bypass, and make the suggested fly route describe a genuinely
usable lane.

## Scope

- Preserve the continuous lethal ceiling and floor, gradual 5000 m speed ramp,
  existing obstacle scale, and all current spider mechanics.
- Keep inward-moving tight corridors out of the first 2000 m by default, with
  the threshold editable in the touch-first DEBUG course controls.
- Give each generated challenge one explicit route intent shared by boundary
  shaping, fly guidance, and deterministic validation.
- Never combine the broken-pot gate with the old inward pattern; retain
  deliberate later tight corridors only where their challenge geometry leaves
  a validated route.
- Add regression coverage for the exact repeated gate failure seen around
  21–24 s and 32–34 s in the owner recordings.

## Previous-session review

**previous-session review:** PR #19 successfully slowed the pace curve, made
the continuous rails meaningful, and improved overall play feel. Its
pattern-seven combination independently pinched both rails around a centered
pot gate, however, leaving effectively no upper bypass and an impractical lower
route. The deterministic repeat made an authored geometry mistake look like a
player failure.

## 💡 Idea

Make route intent a first-class chunk contract: the same value should shape
the rails, place route flies, and drive a clearance assertion. This prevents
three independently reasonable systems from composing into an impossible
course.

- **📊 Model:** gpt-5 · high · feature build

