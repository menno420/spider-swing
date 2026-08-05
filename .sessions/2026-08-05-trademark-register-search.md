# Record the trademark register search against the decided name

> **Status:** `in-progress`

## Goal

The name was decided on Play Store evidence — nobody is *using* "Slingy Spider".
That is not the same question as whether anyone has *registered* it. The owner
ran the register search on TMview and it returned a live Benelux mark for the
first word. Record what was found, and what the classes actually mean.

## Scope guard

One product document plus this card. No code, no configuration. The name is
**not** reopened — this is clearance evidence attached to a settled decision.

## Previous-session review

PR #170 corrected the tester-recruiting route from fetched sources and merged.
The trademark step has sat untouched in the owner queue since the name was
decided; this is the first evidence against it.

## Planned

- `docs/product/name-status.md` — the search result, the live mark's classes
  read from WIPO's own Nice Classification rather than assumed, and an honest
  reading of what class separation does and does not buy.

## Verification

To run: `python3 tools/verify.py --require-godot`, then
`python3 bootstrap.py check --strict` post-commit.

- **📊 Model:** opus-5 · high · docs-only
