# Let players practise each tutorial lesson directly

> **Status:** `in-progress`

## Goal

Turn the focused tutorial into a short teaching loop: start the real simulation
from a practice-enabled lesson, prove the requested authoritative action,
receive clear completion feedback, and return to that same lesson.

## Scope guard

This PR adds centralized application-owned tutorial objectives, deterministic
noncompetitive runs, in-run coaching/progress, and same-lesson return. It does
not grant Campaign stars, flies, records, checkpoints, leaderboard eligibility,
or persistent tutorial completion, and it does not change physics or course
truth.
