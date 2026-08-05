# Sync the closed-test runbook to the decided name

> **Status:** `in-progress`

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

[[fill: shipped]]

## Verification

[[fill: verification]]

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
