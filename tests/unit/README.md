# `tests/unit/`

Per-system tests. A unit test here should exercise one system against `domain`
contracts with no scene tree and no engine services where avoidable.

Empty at bootstrap. Phase 0 adds the fixed-rate and trajectory tests from its
acceptance criteria: attach/release behaviour must be predictable across supported
frame rates, and release must preserve momentum (GDD § 23 Phase 0 exit gate).

Register new tests in `tests/test_runner.gd`.
