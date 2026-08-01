# `tests/fixtures/`

Deterministic test inputs. Fixtures are what make physics regressions detectable
rather than anecdotal.

## Expected contents

| Kind | Purpose |
| --- | --- |
| Recorded input traces | Replay a run tick-by-tick to catch trajectory regressions (GDD § 22.1 input recording and replay). |
| Fixed seeds | Reproduce a chunk sequence for a known content version. |
| Save files | Exercise forward migration between schema versions. |
| Chunk metadata samples | Feed route-validation checks. |

## Rules

- **Text formats.** A fixture must be diff-reviewable; a binary blob makes a
  regression invisible in review.
- **Version them.** A fixture recorded against one physics configuration is not
  valid against another. Record the configuration version alongside it, so a
  changed fixture is a visible decision rather than silent drift.
- **Never wall-clock.** Fixed timestep only.

`phase0_trace.json` is the current versioned input trace used by deterministic
record/replay coverage.
