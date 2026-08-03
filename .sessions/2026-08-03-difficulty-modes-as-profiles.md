# Difficulty modes become profiles, and every mode gets a board

> **Status:** `complete`

## Goal

Record two owner decisions taken in conversation after the pressure-curve slice
landed, before they are lost: difficulty modes become **axis profiles** rather
than a geometry scale, and **every mode gets its own leaderboard**. Records only
— no code moves.

## Scope guard

Docs and the decision ledger. **No code, no contract, no generator change, no
build bump.** The `leaderboards_eligible` flag and the contract pinning
"Standard alone" are deliberately left as they are: they change in the phase that
builds the boards, not in the phase that decides they exist.

## Previous-session review

**previous-session review:** the pressure-curve slice ended by asking one
question (OQ-17) with a stated default rather than blocking on it. That was the
right shape — the answer came back within the hour and it was "ship the default".
Same instinct applied here: both new decisions carry defaults on the parts that
are genuinely arguable (Harsh's width, the continuation counts) so nothing waits.

## What was decided

**[D-0055].** Two coupled changes.

1. **Modes become profiles.** Today a mode scales geometry and shifts when
   hazards start; the code that decides *which pattern goes in which chunk* never
   reads the mode, so Relaxed and Harsh generate the identical course structure.
   Modes gain Predictability, Density and spacing. Standard stays the reference
   with an empty override set.
2. **Every mode gets a board**, superseding D-0033's "only Standard is eligible"
   clause — and **Relaxed's rails become lethal**, which removes the one reason
   Relaxed was records-ineligible. All three modes end up uniform.

**The coupling is the argument.** Once a mode changes selection rather than
scale, a Harsh run and a Standard run are different *courses*, not one course
drawn differently. A single board would rank runs that never faced the same
content — a worse ambiguity than the one the board's design was written to avoid.

**This is not a reversal of D-0033.** The owner states the shipped mode system
was an agent's design produced from his one-line suggestion of difficulty modes,
not something he specified, and that he left it uncorrected because other work
mattered more. So the geometry-scale reading never carried owner intent. A later
session should not defend it as though it did — that is exactly the shape of
mistake this ledger exists to prevent.

## The check that did its job before anything was built

`tests/unit/difficulty_tests.gd` carries the invariant *a mode that cannot set a
record must not claim a leaderboard slot*. Relaxed is records-ineligible because
its rails are non-lethal, so "a board for every difficulty" would have violated
it — and the violation surfaced while reading, not after building. The owner's
answer (make the rails lethal) satisfies the invariant rather than bending it.

**Guard recipe:** when a decision grants a capability per-mode, grep
`tests/unit/difficulty_tests.gd` for the eligibility invariants first —
`_test_record_and_leaderboard_rules` encodes the ones that are easy to
contradict by implication.

## Verification — run, not claimed

- **`python3 tools/verify.py --require-godot` — PASS** against the pinned
  `4.7.1.stable.official.a13da4feb`; `bootstrap.py check --strict` exit 0.
- Records-only, so the suite is unchanged by construction — the point of running
  it is that a docs slice must not move it, and it did not.
- `D-0055` is cited from exactly one doc outside the ledger, per the stamp guard.

## Owner questions

**OQ-17 answered and moved** — ship the curve's 0.70 default and judge it on
device, because the change is reversible. No new questions: both decisions here
carry owner answers, and the two arguable defaults inside D-0055 (Harsh spends on
timing rather than width; 2/3/4 legal continuations) are recorded as vetoable
rather than raised as blockers.

## 💡 Idea

**A decision's provenance should say whether the owner specified it or an agent
inferred it.** D-0033's mode design read as settled for three days because the
ledger records *what* was decided but not *how much of it was the owner's*. The
grammar has a `provenance` line already; it just does not distinguish "owner's
words" from "agent's reading of owner's words". One token would — and the cost of
not having it is a later session defending an agent's guess as though it were an
instruction. Deduped: no existing field carries this. Worth proposing if a second
entry turns out to have the same ambiguity.

## Next slice

**Phase 3 — move selection onto the curve, Ancient Forest first**, unchanged.
Modes stay untouched until Standard is on the curve, because they are derived
from it. The board work and the lethal-rails change follow the profiles, since a
board for a mode whose content is still moving would rank a moving target.

- **📊 Model:** opus-5 · high · docs-only
