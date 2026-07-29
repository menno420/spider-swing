# Remove legacy obstacle backing session

> **Status:** `in-progress`

## Goal

Make the Ancient Forest artwork the only normal-game obstacle silhouette while
preserving the authoritative polygons for collision, targeting, and opt-in
diagnostics.

## Scope guard

This session may change presentation composition, related rendering contracts,
documentation, and development build identity. It does not change authoritative
course geometry, obstacle frequency, route planning, physics, rewards, or
progression.

## Previous-session review

**previous-session review:** PR #24 made the rail-grown root gate physically
traversable and hid collision outlines and unattached web guides by default.
Menno's `0.8.2-wide-passage-test` recording proves the route fix works, but also
reveals the legacy geometric backing layer behind the finished branches,
brambles, vines, and root passages.

## Decisions flagged

- Remove the duplicated normal-game silhouette at the centralized presentation
  seam instead of special-casing individual obstacle types.
- Preserve authoritative geometry unchanged and render it only when the
  collision-outline diagnostic is explicitly enabled.
- Add a runtime contract that fails if finished Ancient Forest obstacles fall
  back to legacy filled polygons.

## 💡 Idea

Treat each environment theme as a complete presentation policy: a finished theme
must declare how authoritative geometry is surfaced, preventing a prototype
fallback from silently leaking beneath production-candidate art.

- **📊 Model:** gpt-5 · high · runtime bugfix

## Verification evidence

Pending implementation and gate runs.

## Documentation audit

Pending.

## Remaining owner review

Pending a verified Android candidate.
