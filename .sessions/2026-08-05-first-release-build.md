# Drive the first real release build to green

> **Status:** `in-progress`

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

[[fill: shipped]]

## Verification

[[fill: verification]]

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
