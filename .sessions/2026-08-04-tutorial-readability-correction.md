# Correct tutorial orientation and teaching clarity

> **Status:** `in-progress`

## Goal

Use the owner's 1040×480 device recording to correct upside-down Bramble
obstacles and make every tutorial page readable and understandable without
requiring the player to decode small prose or ambiguous scene badges.

## Scope guard

This PR may change tutorial lesson presentation data, the shared canopy-art
orientation seam, front-end tutorial layout, focused contracts, live
documentation, and Android build identity. It does not change simulation,
input, lesson-practice objectives, course generation, difficulty profiles,
progression, rewards, saves, or gameplay balance.

## Previous-session review

**previous-session review:** PRs #156 and #159 established eight stable lessons
and real noncompetitive practice, but the owner's first device review found
that their screenshot-style presentation still relied on small paragraph copy
and that ceiling-mounted hook-vine art ignored the production renderer's
vertical orientation rule. PR #160's difficulty-profile work is unrelated and
must remain unchanged.

## Shipped

- In progress: frame-by-frame device review, shared orientation correction,
  numbered visual explanations, readable lesson hierarchy, focused contracts,
  documentation, and Android artifact.

## Verification

- Pending implementation, deliberate falsification, full Godot verification,
  strict repository checks, CI, and Android artifact inspection.

## Pull request

- Pending. Owner action needed before merge: **None**.

## 💡 Session idea

Make each tutorial scene and its copy use the same three numbered teaching
points, so visual meaning and text cannot drift into two competing explanations.

- **📊 Model:** gpt-5.6-sol · high · feature build
