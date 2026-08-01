# Consolidate the overnight run's owner forks

> **Status:** `complete`

## Goal

Correct a ledger my own work made false. `docs/owner-questions.md` read
"Open — _None. Every recorded fork has an answer below._" while five slices had
accumulated genuine owner decisions that lived only in session cards.

## Scope guard

One document. No code, no design change, no new question invented — every entry
is a fork an already-merged slice raised, with its measured evidence and the
default the work is proceeding under.

## Previous-session review

**previous-session review:** slices 1–5 landed overnight (PRs #74–#78). Each
recorded its owner questions in its own session card and none of them updated
`docs/owner-questions.md`, whose stated purpose is exactly "consolidated so
they are not scattered across session cards". Five PRs in a row missed it.

## What this is, and why it is not new scope

This is a defect I created, not a new slice. The repository's own drift rule —
and the PR template's "docs that disagree with this change are corrected in
this PR" — should have caught it five times. The file was left asserting there
were no open forks while four were live.

## Filed

- **OQ-8** — what the two inert upgrade tracks should become. Default:
  withdrawn from sale, which is a holding position rather than an answer.
- **OQ-9** — whether Harsh should pay a fly premium. Default: no premium, so
  difficulty is currently economically invisible.
- **OQ-10** — whether a ~21-minute upgrade economy is the intended length.
  Default: prices unchanged; the note that the fix would be more sinks rather
  than higher prices.
- **OQ-11** — whether Silk Winder and Anchor Drive feel good on a device.
  Default: nothing retuned.

Each carries its measurement and points at the committed evidence.

## Deliberately not filed

**Web City at 25 km measuring 2.55 deaths/km against Storm Ridge's 8.94.** It
is real and recorded in `docs/measurements/2026-08-01-difficulty-curve.md`, but
it is a zone-content finding and the zone lane owns it. Filing another lane's
work as an owner fork would route it wrongly.

**Campaign levels not yet staging the situation that makes each verb the
obvious answer.** Recorded in the slice-2 card as a lane-boundary note; it
needs authored teaching geometry, which is the zone lane's surface. It becomes
an owner fork only if that lane declines it.

## Verification

`python3 tools/verify.py --require-godot` → **exit 0**, 163 contracts on pinned
Godot 4.7.1 — unchanged, as expected for a documentation-only change.

`python3 bootstrap.py check --strict` → **exit 0**, findings read in full.

## Owner questions

None new. This slice files the existing four; it does not raise any.

## 💡 Idea

The failure is a shape worth naming: **a "no open questions" ledger is only
trustworthy if writing to it is part of the same ritual that raises them.**
Five consecutive sessions wrote thorough owner questions into their session
cards — the handoff artefact they were told to write — and none propagated them
to the consolidated file, because nothing in the close-out ritual asked. The
session card and the owner ledger serve different readers; the card is for the
next agent, the ledger is for the owner, and only one of them was in the
checklist.

Cheap guard for a later session: the kit already parses session cards for
badges and the model line, so an advisory that fires when a card contains an
"Owner questions" section with content while `docs/owner-questions.md` gained
no entry in the same diff would have caught all five.

- **📊 Model:** opus-5 · high · docs-only — owner fork consolidation

## Next slice

**Slice 6 — missions, design first.** Unchanged by this correction: missions
were deliberately outside Phase 0, so the design slice comes before any
implementation. What a mission is, how it is offered, how it completes, how it
settles, and how it avoids becoming a second progression system competing with
upgrades.

Carry forward: mission rewards must never be flies, the star sink is still
unbuilt (which makes stars the obvious candidate and OQ-10 the reason to settle
pricing first), and the economy has only one real input — distance — so a
mission system that merely re-prices distance adds nothing a multiplier could
not.
