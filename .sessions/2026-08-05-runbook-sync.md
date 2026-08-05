# Sync the closed-test runbook to the decided name

> **Status:** `complete`

## Goal

The runbook was written before the name was decided and still carried
`com.menno420.swingyspider` — an identifier derived from a name later ruled out
for being taken. Correct it, and rewrite the Play Console step to match the form
the owner is actually looking at.

## Scope guard

One technical document. No code, no configuration, no workflow.

## Previous-session review

**previous-session review:** PRs #164–#167 ruled out "Swingy Spider", decided
"Slingy Spider", and recorded the provenance. The runbook was not part of those
changes and fell out of step with them.

## Shipped

- `docs/technical/play-closed-test-runbook.md`:
  - Package ID corrected to **`com.menno420.slingyspider`** in both places, and
    `RELEASE_APP_NAME` given its decided value `Slingy Spider` (13/30).
  - Step 1 retitled — it now sets both identifiers rather than deferring the name.
  - **Step 4 rewritten against the live Console form**: the five fields with an
    explicit reversible/permanent column, the two irreversible choices called out
    (package name; free-vs-paid, which can never become paid after publishing),
    and the three declaration checkboxes including the Developer Program Policies
    box that is unticked by default and blocks submission.
  - Step 7 now states that **every tester needs an Android device** — iOS
    contacts cannot count toward the 12, with the 2026-08-03 volunteer who could
    not install as the concrete case.
  - Tester opt-in URL made concrete with the real package id.

## Verification

- `python3 tools/verify.py --require-godot` → **exit 0**, 256/256 contracts.
  Documentation-only; the run proves the tree is undisturbed.
- `python3 bootstrap.py check --strict` → **exit 0**, run **post-commit**.
- Drift found by `grep -rn "swingyspider"` rather than recall; the same sweep
  found two more references in fleet-manager's owner queue, fixed there.
- Console field behaviour transcribed from the owner's screenshot of the live
  form, not inferred from documentation.

**Honest nulls unchanged:** `android-release.yml` has still never run end to end;
store graphics are still not produced; trademark clearance is untouched.

## 💡 Session idea

**A stale identifier is not the same kind of error as a stale note.** The runbook
recommended a package name derived from a name this repository had already ruled
out — and the owner was mid-way through the Play Console *Create app* form when
it was caught. Newer Console fixes the package name at creation, permanently and
non-reusably, so the stale line pointed at the one field that cannot be undone.

The document had been correct when written and became dangerous without being
touched. Nothing in the repository flags that; only a grep for the superseded
string found it. Worth remembering that "written before the decision" is a
category of defect, and that decisions should be followed by a sweep for the
strings they invalidate rather than a memory of where they were used.

- **📊 Model:** opus-5 · high · docs-only
