# Pair first-session comprehension feedback with local run evidence

> **Status:** `in-progress`

## Goal

Ask one small closed comprehension question after each of the first few eligible
completed runs, pair the answer with the exact local run record, and include it
in the existing manual JSON export so external first-session tests can explain
not only what happened, but whether the player understood the death.

## Scope guard

This session may change the local run-evidence schema, a pure prompt policy,
death-state input and presentation, evidence persistence/export, focused tests,
Android debug identity, and the canonical documentation for those areas. It
does not change gameplay tuning, physics, difficulty, progression, rewards,
Campaign content, recruitment, consent for transmission, automatic upload,
analytics, identity, leaderboards, tester rewards, Play publication, or Issue
#2.

## Previous-session review

**previous-session review:** main is the reviewed run-evidence implementation
from PR #172 plus the merged work claim from PR #175. The latest completed
session explicitly named a local first-session prompt paired with a record ID as
the next slice. Open PR #139 remains an unrelated Dependabot workflow update.

## Context delta

### Needed but not pointed

- `docs/ideas/run-records-and-tester-programme-2026-08-03.md` limits the first
  feedback wave to comprehension and keeps distribution, consent, and server
  work separate.
- `docs/product/player-preference-research-2026-07-18.md` identifies attributable
  deaths as a testable learning signal: the player should know what killed them
  and what to do differently.
- `.substrate/skills/session-close/SKILL.md` supplies the live claim, born-red
  card, verification, review, and close-out protocol because the advertised
  `.claude/skills/session-close/` body is absent from this checkout.

### Pointed but not needed

- No new project-index area is expected; this remains inside the existing
  domain, application, adapter, presentation, and bootstrap ownership seams.

### Discovered by hand

- Run finalization is emitted at the start of `DYING`, so the prompt must wait
  for the authoritative `DEAD` snapshot before becoming interactive.
- The real GUI controls belong to `InputRouter`, while `SwingLabView` draws the
  matching visuals; both seams must agree so a response never leaks into the
  world tap that restarts a run.
- Progression already saves before optional evidence. Feedback persistence must
  retain that ordering and remain incapable of changing settlement or rewards.

## Planned implementation

- Add a schema-versioned, bounded feedback value keyed by record ID and question
  ID, with clean migration from existing schema-1 ledgers.
- Offer one comprehension question for the first three eligible human standard
  runs only, with clear yes/no choices and no free text or transmission.
- Persist the answer locally, show it in Run History, and include it in the same
  manual export as the paired record.
- Keep prompt failure or evidence-write failure isolated from restart,
  progression, and rewards.

## Verification

- Focused domain, application, persistence, input, and 1040×480 layout contracts.
- `git diff --check`.
- `python3 tools/verify.py --require-godot` on pinned Godot 4.7.1.
- `python3 bootstrap.py check --strict` after the required final status flip.
- Green `game-quality`, `substrate-gate`, and Android debug artifact on the exact
  reviewed PR head before merge.

## Known limitations

- The first wave records only one closed comprehension answer; it does not ask
  for fairness, cause attribution, or free text.
- Manual JSON copy remains the only way evidence leaves the device.

- **📊 Model:** gpt-5 · high · feature build
