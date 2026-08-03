# The gh recipe assumed a variable that is not in every environment

> **Status:** `in-progress`

## Goal

`#157` shipped a `gh` auth recipe that asserts `$GITHUB_PAT`. Some environments
working this repo do not have it. Branch on the variable instead.

## Scope guard

**`scripts/env-setup.sh` § 7 and one ledger entry.** No game code, no contract,
no build bump.

## ⟲ Previous-session review

`[[fill]]`

## 💡 Session idea

`[[fill]]`

## Verify

```
$ bash -n scripts/env-setup.sh
$ python3 bootstrap.py check --strict
```

- **📊 Model:** opus-5 · high · docs-only — one conditional, one ledger entry
