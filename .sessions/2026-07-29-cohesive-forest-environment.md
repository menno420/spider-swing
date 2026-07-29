# Cohesive forest environment session

> **Status:** `in-progress`

## Goal

Make every Ancient Forest hazard read as growth from one continuous floor and
ceiling environment: close visible attachment gaps and replace the distorted
split-circle gate art with a broad, organic rail-grown passage.

## Scope guard

This session may change Ancient Forest presentation composition, one dedicated
passage asset if required, related rendering contracts, documentation, and
development build identity. It does not change authoritative course geometry,
the broad gate clearance, obstacle frequency, route planning, physics, rewards,
or progression.

## Previous-session review

**previous-session review:** PR #25 removed the legacy polygon backing from
finished Ancient Forest art. Menno's `0.8.3-clean-forest-test` recording confirms
that cleanup worked, while exposing transparent gaps at some wall attachments
and showing that the broad passage is still drawn from two stretched halves of
the old circular root asset.

## Decisions flagged

- Keep collision and fly-route geometry unchanged; repair only the presentation
  seam that maps that geometry into finished forest art.
- Give every wall-grown obstacle a deliberate overlap zone into the textured
  rail so transparent source padding cannot make it appear detached.
- Retire the circular gate crop rather than disguising its distortion with
  further non-uniform scaling.

## 💡 Idea

Treat wall contact as an authored visual socket: the hazard overlaps behind the
rail, then the rail is redrawn over the join. This makes independent transparent
assets read as one environment without adding deceptive collision mass.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

In progress.

## Documentation audit

In progress.

## Remaining owner review

In progress.
