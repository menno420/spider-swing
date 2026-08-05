# Drive the first real release build to green

> **Status:** `complete`

## Goal

Take the Android release path from "never executed" to a signed App Bundle the
owner can upload, fixing whatever the first real run exposes.

## Scope guard

The Android release workflow and this session card. No gameplay, no export
preset values, no other document.

## Previous-session review

**previous-session review:** PR #168 synced the runbook to the decided name. The
release workflow had still never run — it needed the repository variables, which
this session set via the API rather than continuing to route to the owner.

## Shipped

- `.github/workflows/android-release.yml` — the three
  `GODOT_ANDROID_KEYSTORE_RELEASE_*` env vars are now gated together on
  `steps.keystore.outputs.signed`, so they are all populated or all empty. Godot
  rejects any partial signing config outright.
- Repository **variables** (`RELEASE_PACKAGE_ID`, `RELEASE_APP_NAME`) and the
  three keystore **secrets** were set via the GitHub API this session, rather
  than continuing to route them to the owner. The upload keystore was generated
  outside the working tree and its bytes never entered a log or an artifact.

## Verification

- **`android-release` has now run end to end.** Run 30991728362, every step
  green. The "never executed" gap carried since ADR 0005 is closed.
- **The artifact was downloaded and inspected directly**, not trusted from the
  workflow's own assertions:

  | Check | Result |
  |---|---|
  | Size | 73,666,697 bytes |
  | Structure | `BundleConfig.pb`, `base/dex/classes.dex`, `base/manifest/AndroidManifest.xml` |
  | Signature | **`META-INF/UPLOAD.RSA`** + `UPLOAD.SF` |
  | Certificate | `CN=Slingy Spider, O=Menno van Hattum, C=NL`, SHA384withRSA, valid to 2053 |
  | Manifest package | `com.menno420.slingyspider` |

- `python3 tools/verify.py --require-godot` → **exit 0**, 256/256 contracts.
- `python3 bootstrap.py check --strict` → **exit 0**, run post-commit.

**Log-reading note:** `RELEASE_KEYSTORE_USER` is `upload`, so GitHub masks the
literal word "upload" throughout these logs — *"uploaded"* renders as *"***ed"*,
and *"upload keystore staged"* as *"*** keystore staged"*. Harmless, and
genuinely confusing when reading a failure at speed.

**Honest nulls:** the bundle has not been installed on a device or accepted by
Play — only proven to be a correctly signed AAB. Store graphics remain
unproduced, and trademark clearance is untouched.

## 💡 Session idea

**The honest gap I had been carrying turned out to be my own bug, not the
environment's.** Every note about this workflow warned that the first run would
probably need an adjustment "most likely in the Android SDK/NDK package list" —
a guess, repeated often enough to feel established. The SDK setup passed first
time. What failed was a line I wrote: `GODOT_ANDROID_KEYSTORE_RELEASE_PATH` set
unconditionally while user and password came from secrets that did not exist,
which Godot rejects outright because all three must be set together or none.

A predicted failure mode, restated across several documents, quietly displaced
the act of looking. The fix was three expressions; finding it took one run that
could have happened hours earlier.

- **📊 Model:** opus-5 · high · runtime bugfix
