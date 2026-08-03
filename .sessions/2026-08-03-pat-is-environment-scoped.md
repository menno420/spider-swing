# The gh recipe assumed a variable that is not in every environment

> **Status:** `complete`

## Goal

`#157` shipped a `gh` auth recipe that asserts `$GITHUB_PAT`. Some environments
working this repo do not have it. Branch on the variable instead.

## Scope guard

**`scripts/env-setup.sh` § 7 and one ledger entry.** No game code, no contract,
no build bump.

## ⟲ Previous-session review

`2026-08-03-gh-present-by-default.md` closed on: *a wall entry should carry the
command that would refute it, not just the one that produced it.* It then shipped
a recipe carrying a precondition it never named, and the owner supplied the
missing fact within the hour. The lesson generalises one step further than that
card put it: **a claim needs its preconditions stated, not only its refutation.**
A recipe whose environment assumption is silent fails in the same way a wall
whose test is silent does — the reader cannot tell whether the claim is false or
merely inapplicable to them.

## 💡 Session idea

**A ledger entry has an implied audience, and this repo's entries do not say who
it is.** Every capability line here is written as though the reader shares the
writer's environment. Most of the time that holds and the omission is invisible;
when it does not hold, the entry reads as a wall to whoever lacks the
precondition — because "the recipe does not work for me" and "the capability is
absent" are indistinguishable from the inside.

The cheap fix is a habit, not a schema: **when a workaround depends on something
the environment supplies — a variable, a binary, a mounted path — name the check
that confirms it, in the same line.** `printenv GITHUB_PAT` costs four words and
turns "this does not work" into "this needs the other branch". The `gh` entry two
below now does it; the older entries do not, and they are where the next false
wall will come from.

## Verify

```
$ bash -n scripts/env-setup.sh
(exit 0)

$ python3 bootstrap.py check --strict
check: all checks passed.
```

Both branches of the conditional were exercised directly — with the variable set,
and under `env -u GITHUB_PAT`. Testing only the branch this environment takes
would have reproduced the original defect exactly.

- **📊 Model:** opus-5 · high · docs-only — one conditional, one ledger entry
