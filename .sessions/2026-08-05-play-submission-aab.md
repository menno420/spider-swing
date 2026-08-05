# Prepare the Android App Bundle release path for Google Play

> **Status:** `complete`

## Goal

Establish what Google Play actually requires today from grounded, personally
fetched official sources, then land every buildable part of that in this
repository: an Android App Bundle export preset, the Gradle build configuration
an AAB export requires, hardened signing-material ignore rules, and the
contracts that keep a production identifier or a real key from arriving by
accident.

## Scope guard

This PR may change Android export presets, the Android release workflow, ignore
rules for signing material, Android build contracts in the test runner, and
technical documentation. It does not change simulation, input, gameplay, course
generation, difficulty, progression, rewards, saves, tutorial content, or the
existing `Android Debug` preset's identity.

## Previous-session review

**previous-session review:** PR #161 corrected tutorial orientation and teaching
clarity and left `main` at build `0.43.0-tutorial-clarity`, version code 63, with
251/251 runtime contracts green. ADR 0003 deliberately deferred every release
concern — production package identifier, release keystore, Play account, release
workflow — to an explicit owner-controlled step. This session opens exactly that
step for the buildable half only, and must not weaken 0003's guarantee that no
production credential exists in the tree.

## Shipped

- Added the `Android Release` preset: Gradle build, `export_format=1` (AAB),
  min/target SDK pinned to 24/36, `arm64-v8a` + `x86_64`, export path
  `build/spider-swing-release.aab`. The `Android Debug` preset is byte-unchanged
  and its contracts still bind.
- Added `.github/workflows/android-release.yml`: dispatch-only, never publishes,
  substitutes owner-set `RELEASE_PACKAGE_ID` / `RELEASE_APP_NAME` into the preset
  per build and refuses to build while either is unset or still an example value,
  rejects an app name over Play's 30-character limit, and proves the output is a
  real bundle (`BundleConfig.pb` + `base/manifest/AndroidManifest.xml` present)
  rather than merely a file that exists and unzips.
- Committed identity is a deliberate placeholder. A published `applicationId` can
  never be changed or reused, and the store name is still unconfirmed, so no
  agent should freeze either into git.
- Signing is absent and says so: with no upload key configured the workflow
  builds an **unsigned** bundle and warns that Play will reject it. That is a
  genuine build validation, not a pretend release.
- `.gitignore` now also refuses `keystore.properties`, `upload-keystore.*`, and
  base64-encoded keystores — the last matters specifically, because a keystore
  encoded for a repository secret stops matching `*.jks`/`*.keystore` and would
  slip past every rule ADR 0003 added.
- ADR 0005 records the decision as an explicit extension of ADR 0003 rather than
  a silent contradiction of its "release is deferred" stance.
- Five new contracts (`_check_android_release_preset`) guarding the bundle
  format, the SDK pins, the placeholder identity, the unsigned state, and the
  workflow's dispatch-only shape.

## Verification

- `python3 tools/verify.py --require-godot` → **exit 0**, **256/256** contracts,
  against the pinned Godot 4.7.1 Standard. Real exit code, not `$?` after a pipe.
- `python3 bootstrap.py check --strict` → exit 1 with the designed born-red
  `[session-card-hold]` as its only finding, until this commit.
- **Mutation-tested**, both restored byte-for-byte afterwards:
  - `export_format` 1 → 0 failed with *"Android Release preset does not export an
    App Bundle"* (251 passed, 1 failed).
  - Committing a real package id in place of the placeholder failed with
    *"…a permanent applicationId must not be committed"* (253 passed, 1 failed).
- **A contract caught its own defect during this session.** The first version
  tested for the *string* `androiddebugkey` anywhere in the release workflow —
  and failed on the workflow's own guard step, which contained that token while
  forbidding it. A substring test cannot distinguish a prohibition from a use.
  Replaced with a `RegEx` matched against the release signing **assignments**,
  and the redundant in-workflow grep removed. The comment above the check records
  why, so the weaker version does not come back.
- Local export attempt (`--export-release "Android Release"`) reached
  configuration validation and failed **only** on missing export templates and a
  missing Android SDK — never on preset configuration. That is the available
  evidence that Godot resolves the preset by name and accepts its options.
- Engine behaviour read from Godot 4.7 source rather than assumed: the
  `export_format` hint is `"Export APK,Export AAB"` with a bounds check proving
  APK=0 < AAB=1 (the class reference gives no numbers); AAB is rejected without
  the Gradle build; `.aab` extension is enforced; `DEFAULT_MIN_SDK_VERSION = 24`
  and `DEFAULT_TARGET_SDK_VERSION = 36`; `--install-android-build-template`
  exists and pairs with `--export-release`.
- CI on PR #162: `game-quality` **success**, `android-debug` **success**.

**Honest null:** `android-release.yml` has **never run end to end**, and cannot
from a session — it needs the owner's repository variables, by design. Expect the
first real run to need adjustment, particularly around the Android SDK/NDK
package set. Recorded in ADR 0005 rather than implied to be a passing build.

## 💡 Session idea

The store requirement everyone repeats — "Play wants an `.aab`, not an `.apk`" —
is the easy half. The half that decides whether a submission is weeks or months
away is the part nobody quotes: a personal developer account created after
2023-11-13 must run a closed test with **12 testers opted in for 14 continuous
days** before it may even *apply* for production access. Landing the build
config is a day's work; that gate is a calendar, and it starts only when the
owner does. Both belong in the record, and the calendar one belongs in front of
the owner first.

- **📊 Model:** opus-5 · high · feature build
