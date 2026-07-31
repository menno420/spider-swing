# ADR 0003 — Android build strategy: debug-only CI now, owner-controlled release later

> **Status:** `binding`
>
> Decided 2026-07-28, founding bootstrap session.
> Answers GDD § 25 decision 3 in part (minimum device/API) and defers § 25 decision 7.

## Context

Spider Swing is Android-first, and the GDD's exit gates are all *feel* gates:
Phase 0 requires that attach/release behave predictably across supported frame
rates and that test players can attribute their deaths (§ 23). None of that can be
judged from CI output — it requires the owner holding a phone.

So the build pipeline's job during development is narrow and specific: **put an
installable debug APK in the owner's hands on every change to `main`**, without
production credentials or a publishing path.

Publishing is a different activity with different risk. It needs a production
package identifier, a release keystore that must never leak, a Play Console
account, and a store listing — all of which are owner decisions with real
consequences, and several of which are irreversible once taken (a published
package name cannot be reused).

## Decision

### Now: debug-only, public conventional credentials

- One export preset, named exactly `Android Debug`, committed as text in
  `export_presets.cfg`.
- Temporary development package identifier: **`com.menno420.spiderswing.dev`**.
  This is **not approved for Google Play publication.** The `.dev` suffix is
  deliberate: it keeps the eventual production identifier unclaimed and
  unambiguous, and `tests/test_runner.gd` asserts this exact value so a production
  identifier cannot appear without failing CI.
- `.github/workflows/android-debug.yml` runs on pushes to `main` and manual
  dispatch, exports `build/spider-swing-debug.apk`, and uploads it as the artifact
  `spider-swing-android-debug` with 14-day retention.
- **Debug signing uses the stable conventional public key committed at
  `.github/android/debug.keystore`.** Its `androiddebugkey` / `android` /
  `android` credentials are not secrets. The workflow verifies the key's file
  and certificate digests, wires it through Godot's
  `GODOT_ANDROID_KEYSTORE_DEBUG_PATH`, `_USER`, and `_PASSWORD` environment
  variables, and verifies the exported APK signer. A source contract rejects
  any return to per-run `keytool` generation.
- This key must **NEVER** be reused for Google Play, a release build, production
  signing, or any signed distribution. It exists only so development APKs share
  one Android identity and can update in place. No release signing exists.
- JDK 17 for the Android toolchain, per Godot's current Android export
  requirements.
- `gradle_build/use_gradle_build=false`: the export uses Godot's prebuilt APK
  template. A custom Gradle build adds an Android source template and a much
  larger failure surface, and buys nothing until a plugin or a custom manifest
  actually requires it.
- Architectures: `arm64-v8a` (real devices) and `x86_64` (emulators). `armeabi-v7a`
  and `x86` are off — 32-bit Android is below the intended device floor and each
  extra ABI inflates the APK.
- `android-debug.yml` is **not** a required merge check. A device build failing
  must not block a documentation fix, and its inputs (external SDK downloads) are
  outside this repository's control.

### Later: production, behind an explicit owner step

Deliberately absent from this repository, and each is an owner action when the
time comes:

| Deferred | Why it is an owner decision |
| --- | --- |
| Production package identifier | Irreversible once published; depends on the final release name (GDD § 25.7). |
| Release keystore | Losing it means never updating the app again. Must be owner-generated, owner-backed-up, and stored as a repository secret. |
| Google Play account, listing, content rating | Requires payment, legal identity, and store policy acceptance. |
| Release/upload workflow | Only meaningful once the above exist. |
| iOS signing | Needs an Apple Developer identity and a macOS runner; no macOS runner is configured. |

**No production credential, key, token, signing material, or store integration is
committed to this repository, and none will be added without an explicit
owner-controlled step.** `.gitignore` refuses `*.keystore`, `*.jks`, `*.p12`,
`*.pepk`, and provisioning profiles so an accidental `git add -A` cannot leak
one; the exact public debug key above is the only documented exception.

### Minimum supported device

Provisional: **Android 8.0 (API 26), arm64, GLES3-capable**. Provisional because
the GDD's performance target (60 fps on the supported device floor, § 21) can only
be confirmed on real hardware, which is an owner playtest. Phase 1's exit gate
sets the final floor.

## Consequences

- CI proves the project *exports* on every push to `main`, so an export break is
  caught within one change instead of at release time.
- The owner can install a playtest build by downloading an Actions artifact — no
  store, no signing, no distribution account.
- The first stable-key install still needs one final uninstall because earlier
  artifacts used unrelated throwaway certificates. Every later debug build can
  update in place, preserving settings and progression for device migration
  tests.
- A debug APK installs alongside a future production build rather than conflicting
  with it, because the identifiers differ.
- 14-day retention keeps storage bounded; a build worth keeping longer is worth a
  tagged release, which is a separate later decision.
- Switching to a Gradle build later is a contained change to the preset options
  plus the workflow — the export preset name and artifact contract stay stable.

## Alternatives considered

- **Signed release APK/AAB in CI now** — rejected: requires a release keystore in
  secrets before the game is playable, which is risk with no payoff.
- **Store the debug key as an Actions secret** — rejected: the conventional
  debug identity is not a security boundary, while hiding it would make local
  reproduction depend on repository configuration and make accidental secret
  rotation silently break in-place updates.
- **Publishing to an internal Play track** — rejected: needs a Play account and a
  production identifier; the GDD explicitly defers naming and store-conflict review
  (§ 25.7, and the codename warning at the head of the GDD).
- **Gradle build from the start** — rejected: larger failure surface, slower CI,
  and no current need. Revisit when a Godot Android plugin or custom manifest
  requires it.
- **Building the APK on PRs as a required check** — rejected: slow, and dependent
  on external SDK availability, so it would convert third-party outages into merge
  blocks.
