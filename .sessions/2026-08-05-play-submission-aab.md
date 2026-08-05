# Prepare the Android App Bundle release path for Google Play

> **Status:** `in-progress`

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

[[fill: shipped]]

## Verification

[[fill: verification]]

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
