# Balanced promoted to the approved baseline preset

> **Status:** `complete`

## Goal

Land the owner's approval of `balanced_baseline` as the Phase 0 physics
baseline — one of issue #2's six exit-gate criteria — and record both what that
approval covers and, more importantly, what it does not.

## Scope guard

One preset id, its migration path, the labels that describe it, and the records.
No physics values changed. No exit-gate criterion other than the preset one is
touched, and issue #2 stays open.

## Previous-session review

**previous-session review:** the fleet-manager correction (fm PR #635) merged
clean — it caught that the hub's ledger called `api.github.com` blocked when only
the proxied path 403s, and following that thread found a doctrine with no
machinery behind it. Good instinct on measuring rather than asserting. The miss
worth carrying: it summarised issue #2 to the owner as "the device playtest",
which is wrong — #2 is the whole Phase 0 build with an owner-judged feel gate.
The owner corrected it, and that correction is what produced this session's work.
Read an issue before characterising it.

## What the owner actually approved

> "The balanced baseline should indeed be promoted, it's honestly the only one
> I've been testing and adjusting, so right now it's already much further ahead
> then it was at the time where those 3 presets were made."

Two things in one sentence, and the second is the load-bearing one. Balanced is
approved. It is also **the only preset that was ever played**. It absorbed days
of tuning while `weighty_candidate` and `agile_candidate` sat at the fork point
they were created at.

So this is not the outcome of a three-way comparison, and writing it up as one
would be an inflated progress claim of exactly the kind this repo's working
agreement rejects. The sharper risk is downstream: if the other two read as
vetted alternatives, a later session comparing balanced against agile would
interpret a pure tuning gap as a design signal and tune toward noise. The code
comment, the ledger entry, the README, and `current-state.md` all now say this
in as many words.

Naming a baseline still earns its keep. Without a committed reference, every
observation across the coming months of testing is measured against a config
nobody agreed to.

## Shipped

- `game/domain/swing_config.gd` — `PRESET_BALANCED` is now `balanced_baseline`.
  New `LEGACY_PRESET_IDS` and `resolve_preset()`: a current id resolves to
  itself, `balanced_candidate` migrates to the baseline, and anything genuinely
  unknown returns `&""` so callers can distinguish migration from rejection. The
  class docstring records the approval and the staleness of the other two.
- `game/domain/player_settings.gd` — stored settings resolve through
  `resolve_preset` instead of a bare membership test.
- `game/domain/simulation_snapshot.gd`, `tools/simulate.gd` — the hardcoded
  `"balanced_candidate"` defaults now reference `SwingConfig.PRESET_BALANCED`,
  so the next rename cannot leave them behind.
- `game/presentation/scripts/front_end.gd` — the Home rail reads
  BALANCED/BASELINE, WEIGHTY/UNTUNED, AGILE/UNTUNED, and its description says
  the other two were forked early and never tuned rather than calling them
  candidates.
- `README.md`, `docs/technical/simulation-lab.md`, `docs/current-state.md`,
  `docs/decisions.md` (**D-0036**) — records.
- `tests/unit/phase0_physics_tests.gd` — new contract
  `_test_baseline_preset_id_and_legacy_migration`. `EXPECTED_CHECK_COUNT`
  116 → 117.

## The rename was survivable by accident, which is why it is now under contract

`apply_preset` ends in a `_:` arm that assigns balanced physics and rewrites
`preset_name` to `PRESET_BALANCED`. `PlayerSettings.from_dictionary` rejected
unknown ids and fell back to a default that is also balanced. So a pre-rename
save carrying `balanced_candidate` would have landed on the right physics
through two independent accidents, with nothing asserting it.

That is the shape of a bug that surfaces at the next rename, not this one. The
new contract pins the intended behaviour: legacy id migrates, current id is
preserved, unknown id is rejected, and a stored `agile_candidate` is not
clobbered by the migration.

## What issue #2's status actually is

Unchanged and long-running, by owner instruction: it stays open for weeks or
months. One of six exit criteria is now met. Owner testing so far concentrates
on the Garden Spider, whose core mechanics behave correctly at the distances
reached — explicitly **not** a completion claim for that spider. The owner named
two substantial gaps himself: baseline-versus-upgrade comparison, and behaviour
at longer distances. `current-state.md` records it in those terms. No spider is
finished; one is further along.

## Verification

Real exit codes, no pipes:

- `python3 tools/verify.py --require-godot` against Godot 4.7.1 stable →
  **exit 0**, all checks passed, **117 contracts**.
- Same command with `godot` absent from PATH → **exit 1**. Worth stating
  because plain `tools/verify.py` skips the engine checks and still reports
  success; a green run without `--require-godot` proves much less than it looks.
- `python3 bootstrap.py check --strict` → green.

## Open owner questions

None new. The one live question is unchanged and is not blocking: whether the
untuned pair should eventually be re-forked from the baseline so there is a real
comparison to make, or left as-is. Not urgent — nothing depends on them.

## 💡 Idea

The preset rail sits on Home, where it is reachable mid-testing. Now that one
preset is the baseline and the others are known-stale, switching away from the
baseline silently changes what every subsequent observation means. A session-only
marker — the run HUD noting a non-baseline preset the way debug runs already
announce that they award nothing — would make that visible without adding a
setting. The precedent exists in `RUN_PRACTICE`; this would reuse it.

- **📊 Model:** opus-5 · high · mechanical refactor — one preset id, its
  migration shim, its contract, and the records
