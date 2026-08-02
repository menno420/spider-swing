# Cut build 0.35.0 so the menu pass is installable and distinguishable

> **Status:** `complete`

## Close-out

**Evidence:**

- source: `project.godot`, `export_presets.cfg` (version code 54 → 55),
  `tests/test_runner.gd` (`BUILD_VERSION`, `ANDROID_VERSION_CODE`),
  `.github/workflows/android-debug.yml` (`BUILD_VERSION` plus the pinned
  `version/code=` assertion), `docs/current-state.md`.
- verify: **`python3 tools/verify.py --require-godot` — PASS, 209/209** against
  the exactly-pinned `4.7.1.stable.official.a13da4feb`. `bootstrap.py check
  --strict` passes.

**Why this exists.** PR #120 changed how every front-end screen looks and reads
— touch floors raised toward 48 dp, the selected difficulty no longer painted as
disabled, three hubs given live status lines, Shop cards compacted — and it
ticked *"needs an owner playtest on a real device."* It shipped **without a
version bump**, so the next Android artifact would have installed as
`0.34.0-speed-cap-playtest`: the same string the owner already has, with a
visibly different menu underneath and no way to tell the two apart.

That is the exact failure the previous build-cut session named and wrote a
workflow rule against: *if the playtest box is ticked and the identity is
unchanged, the PR is not finished.* The rule was recorded and then not applied
by the very next PR that needed it, which is worth stating plainly rather than
quietly fixing.

Now `0.35.0-menu-pass-playtest`, Android version code 55.

**Decisions made:** none. Build identity only — no physics, progression, course,
bird, economy or presentation value moves, and no contract logic changes.

**Next session should know:** the identity is pinned in **five** files and the
Android workflow asserts the version code by exact string match, so a partial
bump fails CI rather than shipping a mismatched artifact. This bump asserted a
single match per pattern before substituting, which is the cheap guard against
the previous session's miss (an earlier substitution had rewritten the text two
later patterns keyed on). One deliberate survivor: the 0.34.0 string still
appears in `docs/product/menu-ux-review-2026-08-02.md`, where it records the
build the owner's recordings came from and must not be bumped.

**Orientation headroom is 133 words** (6867/7000). This card's `current-state.md`
edit is word-neutral by construction, but the next session that adds prose there
should trim first.

## 💡 Session idea

**The gate for this already exists and is one comparison away.** The Android
workflow is path-filtered to `game/**`, `tests/**` and the runtime assets —
very nearly "this diff can change what the owner sees." A `substrate-gate` step
that fails when that filter matches *and* `BUILD_VERSION` equals the merge
base's would convert a slip that has now happened twice in one afternoon into a
red check, reusing a path filter that is already written.

The narrower half — that all five files carry the *same* identity — is already
enforced. The missing half is that it *differs from the base branch* when the
diff can change feel. Both sessions that missed the bump would have been caught
by that one line, and neither was caught by review.

## ⟲ Previous-session review

The previous session recorded this exact workflow improvement — treat the bump
as part of any change that needs a playtest — and the next PR still shipped
without one. A recorded lesson that lives only in a session card is a lesson the
next session has to *remember*, and remembering is what failed both times. The
correct response is not a more emphatic note; it is the CI comparison the idea
above describes.

**Workflow improvement:** when a session card's own idea section proposes a
mechanical guard against a repeated human slip, that guard is the next session's
work item, not a suggestion for someone eventually. This is the second cut in one
day whose entire content is a number nobody remembered to change.

- **📊 Model:** opus-5 · high · docs-only — build identity
