# Pair first-session comprehension feedback with local run evidence

> **Status:** `complete`

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

## Shipped

- Added schema-1 `RunFeedbackResponse`, keyed by exact record ID and versioned
  question ID, with only `knew_what_to_do` and `not_sure_what_to_do` answers.
- Bumped `RunRecord` and `RunRecordLedger` to schema 2. Existing schema-1
  histories migrate forward without inventing answers, and rolling record
  eviction removes the paired response without changing lifetime aggregates.
- Added pure `RunFeedbackPromptPolicy`: only the first three ordinary zero-start
  human Relaxed/Standard/Harsh deaths are eligible. Practice, debug, Campaign,
  Course Lab, replay, tutorial, later runs, and non-death endings are excluded.
- Added the dead-state **QUICK CHECK** with real GUI-owned yes/no/skip controls.
  It waits for authoritative `DEAD`, suppresses world/restart input, keeps Menu
  available, and restarts after answer or skip. Skip records nothing.
- Stored accepted answers through the existing optional `SaveRepository` seam,
  after progression. A response failure cannot repeat or alter settlement,
  flies, unlocks, stars, rewards, or best distances.
- Added answer/eligible counts and paired response text to Run History, and
  bumped the manual local-only export to
  `spider-swing-local-run-evidence@2`.
- Bumped source/debug identity to `0.45.0-run-feedback`, Android version code
  66, and `Spider Swing Run Feedback (dev)`. No release or Play publication was
  attempted.
- Updated the run-evidence, front-end, testing, privacy, current-state, idea
  index, and tester-programme documentation without promoting later feedback
  waves or remote collection.

## Verification

- `git diff --check` → **exit 0**.
- `python3 tools/check_architecture.py` → **exit 0**; inward dependencies hold.
- `python3 tools/verify.py --require-godot` with isolated writable XDG paths on
  pinned Godot 4.7.1 → **exit 0**; import, boot, architecture, reproducible
  audio, and all 270 declared contracts passed.
- `godot --headless --path . --script res://tools/run_history_layout_probe.gd`
  → **exit 0** after four settled frames with 100 records, paired feedback, and
  JSON export at strict 1040×480.
- `godot --headless --path . --script res://tools/run_feedback_layout_probe.gd`
  → **exit 0** after four settled frames with the dead-state prompt, 48 px input
  floors, and visible Menu at strict 1040×480.
- `python3 bootstrap.py check --strict` → **exit 0** after this required final
  status flip and claim deletion; advisory walls were read and no session gate
  remained.

PR #176 is the coherent implementation PR. Exact-head Codex review,
`game-quality`, `substrate-gate`, and the code-66 Android debug artifact are
post-push observations and must all be green before merge.

## Known limitations

- The first wave records only one closed comprehension answer; it does not ask
  for fairness, cause attribution, or free text.
- Manual JSON copy remains the only way evidence leaves the device.

## Device questions

1. After each of the first three new ordinary deaths, does the prompt appear
   only after falling finishes, remain readable at 1040×480, and offer a clear
   Menu escape?
2. Do **YES**, **NO**, and **SKIP** each restart exactly once without also firing
   a web or Burst? Does Skip leave no answer in Run History?
3. Does Run History show the selected answer beside the exact run, and does
   **COPY JSON** include the paired `record_id`, `death_comprehension_v1`, and
   answer inside `spider-swing-local-run-evidence@2`?
4. Does the code-66 debug APK update the existing stable dev package in place
   and preserve progression plus older schema-1 run history?

## Next slice

The next valuable action is human evidence, not another speculative code slice:
install the code-66 artifact, answer the four device questions above, then run
the same three-death assignment with the first external testers. Difficulty and
fairness tuning should wait for the paired answers and records.

## 💡 Session idea

Instrumentation can say exactly how a player died, but not whether the player
understood it. Pairing one closed answer to the same immutable run identity turns
the existing evidence into a comprehension instrument without creating a data
collection system.

- **📊 Model:** gpt-5 · high · feature build
