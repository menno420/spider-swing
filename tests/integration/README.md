# `tests/integration/`

Cross-system tests: the seams where guarantees actually live.

Empty at bootstrap. The high-value targets, in rough priority order:

1. **Settlement idempotency** — applying the same `RunSettlement` twice has no
   effect, including across a simulated app suspension during results (GDD § 20).
2. **One outcome per contact** — repeated collision callbacks in a single tick
   cannot consume two shields or settle a run twice (GDD § 13.2).
3. **Seeded reproducibility** — a seed produces the same chunk sequence for the same
   content version (GDD § 9.2).
4. **Save migration** — forward migrations preserve balances and unlocks.
5. **Frame-rate independence** — identical input at 30/60/90/120 Hz rendering
   produces the same simulation trajectory (GDD § 21).

Register new tests in `tests/test_runner.gd`.
