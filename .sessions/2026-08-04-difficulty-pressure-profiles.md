# Profile Relaxed and Harsh on the pressure-driven course

> **Status:** `complete`

## Goal

Make Relaxed and Harsh structurally distinct pressure-envelope profiles while
preserving Standard's exact pattern sequence, geometry digest, physics, and
first-15-km behaviour.

## Scope guard

This PR centralizes mode profile data and lets deterministic selection consume
mode alongside seed, chunk, and pressure. It measures predictability, challenge
density, recovery cadence, and timing/spacing structure. It does not add
leaderboards, change Relaxed rail lethality or historic bests, alter physics,
extend authority beyond 15 km, or use simulator survival as a feel verdict.

## Previous-session review

**previous-session review:** PR #159 merged direct tutorial practice at
`69c73646b79b3d54185138ddcbe8a47b18f00f55`. Its application/run-purpose work
does not overlap course selection. PR #148's pressure curve and PR #156/#159's
tutorial sequence remain the prerequisites and base for this final requested
slice.

## Delivered

- `CourseDifficultyProfile` is the one pure pressure-composed mode model:
  Relaxed / Standard / Harsh expose 2 / 3 / 4 legal continuations, ordered
  recovery and challenge cadence, authored-rung admission, repetition memory,
  and 1.25× / 1.00× / 0.90× sequential reaction spacing.
- `CoursePatternCatalog`, `CourseStream`, and `ZoneCourseBuilder` consume those
  declared inputs without moving physics or duplicating geometry ownership.
  Standard remains the identity path; Harsh no longer tightens corridor width.
- Mode, seed, chunk and pressure now determine the course. Trace format @6
  rejects older Relaxed/Harsh replays whose stored inputs would resolve a
  different sequence.
- `course_audit.gd --mode=...` and its shared probe report legal continuations,
  cadence, admission and spacing alongside real polygons. The dated measurement
  records structural ordering and explicitly leaves feel to device play.
- Build identity is `0.42.0-difficulty-profiles`, Android version code 62, app
  name `Spider Swing Difficulty Profiles (dev)`.

## Verification

- `GODOT_BIN=/tmp/spider-swing-godot-4.7.1/Godot_v4.7.1-stable_linux.x86_64 python3 tools/verify.py --require-godot`
  — PASS: deterministic audio, all 14 architecture fixtures, live architecture,
  project import, boot smoke, and 251/251 Godot contracts.
- `python3 bootstrap.py check --strict` — PASS; only documented advisory notes
  remain, and the emitted guard-fire telemetry is retained.
- Three-seed 0–15 km course audits — PASS with distinct deterministic digests:
  Relaxed `782cd3e3…`, Standard `497b6bc6…`, Harsh `2a48dd0d…`.
- Two-seed Standard preservation audit — exact pre-change digest
  `087252417d164e4d2521b917084c63a39fb9f5d100e7826001a5241dcf75704b`;
  the extracted pre/post pattern sequence is also identical.
- Width contracts walk every mode: swing-class floors, the absolute fairness
  backstop, constriction bounds and near-minimum exposure all pass.

## Falsification

- Changed Standard's recovery-interval delta from identity to `+1`; the runner
  exited 1 with `Standard is not the identity course profile`.
- Changed Harsh's reaction-spacing scale from `0.90` to Relaxed's `1.25`; the
  runner exited 1 with
  `reaction spacing is not Relaxed > Standard > Harsh`.
- Each isolated mutation was restored byte-for-byte from commit `7675e9f`; the
  required full verification then returned green.

## Pull request

- PR [#160](https://github.com/menno420/spider-swing/pull/160) — Profile Relaxed
  and Harsh on the pressure-driven course.
- Owner action needed before merge: **None**. Device profile comparison follows
  from the separately versioned Android artifact. Issue #2 remains open.

## 💡 Session idea

Treat each mode as a pure set of pressure-composed axis transforms, never as
scattered mode conditionals or a second distance curve, and make the audit expose
the resulting structural ordering without claiming a device feel verdict.

- **📊 Model:** gpt-5.6-sol · high · feature build
