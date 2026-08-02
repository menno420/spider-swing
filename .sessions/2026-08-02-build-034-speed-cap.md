# Cut build 0.34.0 so the speed-cap fix is installable and distinguishable

> **Status:** `complete`

## Close-out

**Evidence:**

- source: `project.godot`, `export_presets.cfg` (version code 53 → 54),
  `tests/test_runner.gd` (`BUILD_VERSION`, `ANDROID_VERSION_CODE`),
  `.github/workflows/android-debug.yml` (`BUILD_VERSION` plus the pinned
  `version/code=` assertion), `docs/current-state.md`.
- verify: **`python3 tools/verify.py --require-godot` — PASS, 207/207**.
  `bootstrap.py check --strict` passes.

**Why this exists.** PRs #115 (speed ceiling restored, bird bounded) and #117
(cap given its own curve) both landed **without a version bump**, so the next
Android artifact would have shipped as `0.33.0-quick-debug-run-playtest` — the
same string the owner already has installed, with materially different physics
underneath.

That is worse than forgetting to bump. Two builds with the *same* name and
*different* behaviour make the next device session unfalsifiable: the owner
reported "the speed cap is still missing or too high" against 0.33, and could
not have told a fixed 0.33 from the one he already had. Every prior playtest
change bumped the identity (0.29 → 0.30 → 0.31 → 0.32 → 0.33); two of my PRs
broke that convention in a row.

Now `0.34.0-speed-cap-playtest`, Android version code 54. The name says what
changed, so the artifact is self-describing on the device.

**Decisions made:** none. Build identity only — no physics, progression, course,
bird or economy value moves, and no contract logic changes.

**Next session should know:** the identity is pinned in **five** places and the
Android workflow asserts the version code by exact string match, so a partial
bump fails CI rather than shipping a mismatched artifact. Grep the old string
before assuming a bump is complete — the first pass here missed the workflow's
`grep -F 'version/code=53'` assertion and a stale "version code 53" in
`current-state.md`, because an earlier substitution had already rewritten the
surrounding text those patterns keyed on.

## 💡 Session idea

**A version bump should not be a separate act of memory.** It was missed twice
in a row by the same agent in the same afternoon, and the cost lands entirely on
the owner — who tests a build he cannot distinguish from the last one.

The repository already knows when it matters: the Android workflow is
path-filtered to `game/**`, `tests/**` and the runtime assets, which is very
close to "this diff can change how the game feels". A gate that fails when that
filter matches **and** `BUILD_VERSION` is unchanged against the merge base would
make the omission impossible rather than merely discouraged. It is a handful of
lines in `substrate-gate.yml`, it reuses a path filter that already exists, and
it converts a recurring human slip into a red check.

The narrower version — assert that `project.godot`, `export_presets.cfg`,
`tests/test_runner.gd` and the workflow all carry the *same* identity — is
already partly enforced; extending it to "and it differs from the base branch
when gameplay files changed" is the missing half.

## ⟲ Previous-session review

The previous session did the analysis well and shipped the fix, then left it
uninstallable-in-practice by not cutting a build. That is a recurring shape
worth naming: the work was judged complete at *merged and green*, when the
actual deliverable is *the owner can play it and tell it apart*. Green CI was
never the finish line for a change whose only verification instrument is device
play.

**Workflow improvement:** for any change whose PR ticks "needs an owner
playtest", treat the version bump as part of that change rather than as
follow-up. If the box is ticked and the identity is unchanged, the PR is not
finished — the fix is unreachable by the only instrument that can verify it.

- **📊 Model:** opus-5 · high · docs-only — build identity
