# Make the contract-count mismatch explain itself

> **Status:** `complete`

## Goal

Turn the one failure two overnight agents are most likely to hit into a message
that states its own fix.

## Scope guard

One failure string in the test runner. No contract added or removed, no logic
changed.

## Previous-session review

**previous-session review:** PR #71 put a floor under region pattern pools and
falsified it before trusting it. Good. What it did not do is reduce the cost of
the collision it was reasoning about — it guarded pool size but left the
check-count mismatch, the more frequent collision, reporting a number without a
diagnosis.

## Why

Two agents work this repository tonight: one on systems and progression, one on
zones. Both add contracts, and each addition bumps `EXPECTED_CHECK_COUNT`.

When two branches each bump it by one they write **identical text**, so git
merges the line with no conflict while the merged tree runs the sum. This
happened once today already, between PR #62 and PR #65. The runner catches it,
which is the important part — but its message said only "runner executed 124
checks but the declared suite requires 123", and the diff shows nothing wrong.
The wrong repair, going hunting for a stray test, is the natural one.

The message now names the cause and the fix, and bounds it: set the constant to
the executed total, and only lower it if a contract was deliberately removed.

## Shipped

- `tests/test_runner.gd` — the mismatch failure explains the merge cause, states
  the correct value, and warns against lowering it. A comment above records why
  the wording is doing work.

## Verification

Real exit codes, no pipes:

- Message rendered by simulating the collision (declared 122, executed 123):
  "runner executed 123 checks but the declared suite requires 122. If you just
  merged main, both sides likely added contracts: set EXPECTED_CHECK_COUNT to
  the executed total 123, not to either branch's value. Only lower it if you
  deliberately removed a contract."
- `python3 tools/verify.py --require-godot` → **exit 0**, **123 contracts**.
- `python3 bootstrap.py check --strict` → **exit 0**.

## Open owner questions

None.

## 💡 Idea

The deeper fix is to stop hand-maintaining the number. The runner already counts
what it executed; the constant exists to catch a silently skipped suite. A
manifest of expected suite names with their own counts would serve that purpose
and be merge-safe, because two branches adding contracts to different suites
would touch different lines and conflict honestly when they touch the same one.
Worth doing if this keeps costing cycles.

## Next slice

None queued here.

- **📊 Model:** opus-5 · high · runtime bugfix — the check-count mismatch now
  states its own fix
