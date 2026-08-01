# `tests/unit/`

Per-system tests. A unit test here should exercise one system against `domain`
contracts with no scene tree and no engine services where avoidable.

Current suites cover fixed-step traversal, eight-zone geometry/mechanics,
spider biology, difficulty, Campaign, upgrades, economy, generated audio, and
mobile HUD/layout contracts. Prefer deterministic data/logic checks here; scene
composition and persistence seams belong in integration coverage.

Register new tests in `tests/test_runner.gd`.
