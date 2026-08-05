# ADR 0005 — Android release: App Bundle, placeholder identity, owner-held keys

> **Status:** `binding`
>
> Decided 2026-08-05. **Extends ADR 0003**; does not replace it.
> Answers the buildable half of GDD § 25 decision 7 and leaves the rest owner-gated.

## Context

ADR 0003 deferred every release concern to "an explicit owner-controlled step"
and built exactly one export preset: `Android Debug`, an APK, with
`gradle_build/use_gradle_build=false`. That was right for its purpose — putting
an installable build in the owner's hands — and it has a consequence that was
not spelled out at the time:

**Google Play has not accepted an APK for a new app since August 2021.** New
apps must be published as an Android App Bundle
([developer.android.com/guide/app-bundle](https://developer.android.com/guide/app-bundle),
fetched 2026-08-05: *"From August 2021, new apps are required to publish with
the Android App Bundle on Google Play"*). So the debug path cannot become a
submission by adding credentials to it — it is the wrong artifact format, built
by the wrong builder. Godot refuses `export_format=AAB` unless the Gradle build
is enabled, verified in engine source (`export_plugin.cpp`, the
`gradle_build/export_format` validator).

The owner-controlled step ADR 0003 pointed at has now arrived. This ADR opens
only the part that can be built without making an irreversible choice.

## The irreversibility that shapes this decision

A published `applicationId` **can never be changed or reused**. From
[developer.android.com/build/configure-app-module](https://developer.android.com/build/configure-app-module)
(fetched 2026-08-05): *"Once you publish your app, you should never change the
application ID. If you change the application ID, Google Play Store treats the
upload as a completely different app."*

The release name is also unsettled — "Spider Swing" is a codename, the store
name is not confirmed (`docs/product/name-status.md`), and the applicationId
conventionally reflects it. An agent picking either value would be making a
permanent product decision as a side effect of a build config.

## Decision

### The release preset exists, and its identity is a placeholder

- A second preset, named exactly `Android Release`, committed as text in
  `export_presets.cfg`:
  - `gradle_build/use_gradle_build=true` — required for AAB.
  - `gradle_build/export_format=1` — AAB. Verified from engine source, where the
    property hint is `"Export APK,Export AAB"` and the bounds check proves
    `APK=0 < AAB=1`; the numeric mapping is not in the class reference.
  - `gradle_build/min_sdk="24"`, `gradle_build/target_sdk="36"`. These match
    Godot 4.7's own defaults (`DEFAULT_MIN_SDK_VERSION = 24`,
    `DEFAULT_TARGET_SDK_VERSION = 36`) and are pinned explicitly so an engine
    upgrade cannot move the target level silently. API 36 is what Play requires
    of new submissions from 2026-08-31.
  - `package/unique_name="com.example.PLACEHOLDER.setbyworkflow"` and
    `package/name="PLACEHOLDER SET BY WORKFLOW"`.
  - `package/signed=false` — no key exists in this tree.
  - `arm64-v8a` and `x86_64`, matching ADR 0003's device floor.
- **The placeholder is fail-safe by construction.** It is a valid Android package
  name (so the export config itself is sound and testable) while being one Play
  refuses, so a mis-wired build cannot quietly publish under it. Note the
  strength of that claim: the `com.example` refusal is reported by a Play
  Console error message in a Google support community thread, **not** by official
  documentation — it is a second belt, not the trousers. The workflow's own
  explicit `com.example.*` rejection is the load-bearing guard.
- The `Android Debug` preset is unchanged, byte for byte. Its contracts in
  `tests/test_runner.gd` still bind, and the owner's device-testing loop is
  untouched.

### The real identity arrives at build time, from owner-set variables

`.github/workflows/android-release.yml` substitutes `RELEASE_PACKAGE_ID` and
`RELEASE_APP_NAME` (repository variables) into the preset per build and **fails
loudly while either is unset**, rather than defaulting to anything. It also
rejects a package id still matching `com.example.*` or containing `PLACEHOLDER`,
and rejects an app name over Play's 30-character store-listing limit.

This keeps a permanent identifier out of git while leaving the build fully
reproducible: the value is owner-set, in one place, visible in Settings.

### The workflow never publishes

`workflow_dispatch` only. It builds a bundle, proves it is a bundle
(`BundleConfig.pb` and `base/manifest/AndroidManifest.xml` present, not merely
"a file exists" or "it is a zip"), uploads it as an artifact, and stops.
Uploading to Play is a deliberate owner action in the Play Console.

### Signing is absent by default, and says so

Play App Signing splits the key in two: the developer holds an **upload key**
that signs the bundle for upload, and Google holds the **app signing key** that
signs what users install
([support.google.com/…/answer/9842756](https://support.google.com/googleplay/android-developer/answer/9842756),
fetched 2026-08-05). New apps are enrolled automatically and cannot opt out.

No upload key exists yet, so with no secret configured the workflow builds an
**unsigned** bundle and emits a warning saying it cannot be uploaded. That is a
genuine build validation and an honest artifact. When the owner creates an
upload key it goes in as `RELEASE_KEYSTORE_BASE64` / `_USER` / `_PASSWORD`, is
materialised only in the runner's temp directory at mode 600, and the same
workflow signs with it.

**The public debug key from ADR 0003 must never sign a release bundle**, and a
CI step fails the build if it is ever wired into release signing.

## Consequences

- The repository can produce the artifact Play requires. It cannot publish one,
  by design.
- Losing the upload key is recoverable — Play supports an upload key reset — but
  losing it is still avoidable; it must be backed up outside CI when created.
- `.gitignore` now also refuses `keystore.properties`, `upload-keystore.*`, and
  base64-encoded keystores. The base64 rule matters specifically: a keystore
  encoded for a secret no longer matches `*.jks` or `*.keystore` and would
  otherwise slip past every rule ADR 0003 added.
- The first real run of `android-release.yml` has **not** happened and cannot
  happen here: it needs the owner's variables. What is verified is that the
  preset parses, that Godot resolves it by name, and that the identity
  substitution rewrites only the release preset. Recorded as a known gap rather
  than implied to be a passing build.

## What is still owner-only

Unchanged from ADR 0003, and now itemised with sources in fleet-manager's owner
queue: the developer account and its fee, identity verification, the closed-test
gate before production access, the upload keystore, the production applicationId
and store name, the privacy policy URL, and the store listing copy and assets.
