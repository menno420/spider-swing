# Getting the closed test live — the critical path

> **Status:** `reference`
>
> Written 2026-08-05, after the developer account was created, verified and
> paid. Every requirement below was verified against an official Google page
> fetched in-session; anything unconfirmed is marked **NULL — unverified**.
>
> **The one number that matters: 12 testers opted in for 14 continuous days.**
> That clock cannot start until a build is downloadable, so every step here
> exists to make a build downloadable sooner.

## Why this is not "just upload the bundle"

A release **cannot** be rolled out to a closed track until the store listing,
the App content page, and pricing are all complete
([answer/9859348](https://support.google.com/googleplay/android-developer/answer/9859348),
fetched 2026-08-05). Closed testing is not a back door around the paperwork —
it is the front door with the same paperwork.

That inverts the ordering the previous session assumed. Screenshots and
descriptions are **on the critical path**, not after it.

Verified track facts ([answer/14151465](https://support.google.com/googleplay/android-developer/answer/14151465),
fetched 2026-08-05): *"You must run a closed test before you can apply to
publish your app to production."* **Internal testing does not count** toward the
12×14 requirement — it is faster and reviewless, but it buys no progress on the
clock. Use it only to sanity-check that the bundle installs.

## The order to do things in

Steps 1–3 are the ones that block everything else. Do them first even if the
listing text is not final.

### 1. Set the application ID and app name — permanent, five minutes

`com.menno420.slingyspider` is the recommended identifier. It can **never** be
changed or reused once published. It is invisible to players and does **not**
have to match the store name.

Set it in the repository so builds stop refusing to run — GitHub → `spider-swing`
→ Settings → Secrets and variables → Actions → Variables:

| Variable | Value |
|---|---|
| `RELEASE_PACKAGE_ID` | `com.menno420.slingyspider` |
| `RELEASE_APP_NAME` | `Slingy Spider` (13/30) |

The store name is **decided — `Slingy Spider`** (see
[`../product/name-status.md`](../product/name-status.md)) and can still be
revised later if needed. The application ID cannot.

### 2. Create the upload key — 15 minutes

Run `tools/make_upload_keystore.sh`. It generates the keystore, prints the exact
base64 blob to paste, and never writes anything into the repository.

Then add three **secrets** (not variables) at Settings → Secrets and variables →
Actions → Secrets: `RELEASE_KEYSTORE_BASE64`, `RELEASE_KEYSTORE_USER`,
`RELEASE_KEYSTORE_PASSWORD`.

**Back the `.jks` file up somewhere that is not this repository and not only
your laptop.** Losing it is recoverable — Play supports an upload-key reset
([answer/9842756](https://support.google.com/googleplay/android-developer/answer/9842756))
— but recovering costs days you would rather spend on the clock.

### 3. Build the bundle

Actions → `android-release` → Run workflow. It substitutes the values from step
1, signs with the key from step 2, verifies the output is a real bundle, and
uploads it as an artifact. It does **not** publish — that stays a deliberate
Console action.

Set `version_code` to a positive integer that is unique and strictly increasing
per upload. Play rejects a reused value.

> **Honest gap:** this workflow has never run end to end. It could not — it
> needed the variables from step 1. Expect the first run to want an adjustment,
> most likely in the Android SDK/NDK package list. That is a ten-minute fix, not
> a redesign, and it is better found now than at 2 a.m. before a submission.

### 4. Create the app in Play Console

Play Console → **Create app**. Observed on the live form, 2026-08-05:

| Field | Value | Reversible? |
|---|---|---|
| App name | `Slingy Spider` (13/30) | yes, editable later |
| **Package name** | **`com.menno420.slingyspider`** | **NO — permanent** |
| Default language | English (United States) – en-US | yes |
| App or game | **Game** | yes, in Store settings |
| Free or paid | **Free** | **NO once published** |

**Two irreversible choices sit on this one screen.**

- **Package name.** Newer Console asks for it at creation rather than at first
  upload, with a *"Check availability"* button beside it. It must be globally
  unique, and it must match `RELEASE_PACKAGE_ID` **character for character** or
  the bundle will not be accepted for this app.
- **Free.** The form states it plainly: once a free app is published it can never
  be converted to paid. In-app purchases and ads remain possible on a free app; a
  one-time price does not. Free is the right default here, but it is a decision,
  not a formality.

Three declaration checkboxes must all be ticked:

1. **Developer Program Policies** — unticked by default; the form will not submit
   without it.
2. **Play App Signing terms** — required to publish an App Bundle at all. This is
   what enables the upload-key / app-signing-key split from step 2.
3. **US export laws.**

Creating the app publishes nothing. It produces a Console entry and unlocks the
two checklists: **Store listing** and **App content**.

### 5. Store listing — the blocking assets

Verified limits ([answer/9866151](https://support.google.com/googleplay/android-developer/answer/9866151)
and [answer/9859152](https://support.google.com/googleplay/android-developer/answer/9859152),
fetched 2026-08-05):

| Item | Requirement |
|---|---|
| App name | ≤ **30** characters |
| Short description | ≤ **80** characters |
| Full description | ≤ **4,000** characters |
| App icon | **512×512**, 32-bit PNG **with** alpha, ≤1024 KB |
| Feature graphic | **1024×500**, JPEG or 24-bit PNG, **no** alpha |
| Screenshots | **≥2** to publish, ≤8 per device type; min side ≥320 px, max side ≤3840 px, and **max ≤ 2× min** |
| Games recommendation eligibility | **≥3 landscape 16:9 screenshots at ≥1920×1080** |

Draft copy is in [`../product/play-store-listing.md`](../product/play-store-listing.md).

**Screenshots must be real capture.** Generated imagery invents interface and
physics — a generated clip in this estate produced three ATTACH buttons in one
frame. Generated art is fine for the feature graphic; never for anything
implying "this is how it plays". The game renders 16:9 landscape natively, so
1920×1080 captures need no cropping.

### 6. App content — the declarations

Every one of these applies to this game. Prepared answers, with the reasoning
for each, are in [`../product/play-console-answers.md`](../product/play-console-answers.md).

- **Privacy policy URL** — required even with no data collection. Publish
  [`../legal/privacy-policy.md`](../legal/privacy-policy.md) first and paste the URL.
- **Data safety** — required for closed testing; only *internal*-only apps are
  exempt. Today's honest answer is **no data collected**; see § below.
- **Content rating (IARC)** — mandatory; without it the app cannot publish.
- **Target audience and content** — mandatory.
- Ads, government apps, financial features declarations — all "no".

### 7. Closed testing track and testers

Create the closed track, upload the bundle, add testers, roll out. Review for a
closed track typically takes **up to 7 days**, and after the first publish it
can take several hours for the opt-in link to work.

Testers join at `https://play.google.com/apps/testing/com.menno420.slingyspider`
and each needs a Google account.

**Every tester needs an Android device.** Obvious in hindsight, and it has
already cost one volunteer: a friend who asked to play on 2026-08-03 could not,
because he is on iPhone and Apple does not permit installs from outside the App
Store. **iOS contacts cannot count toward the 12**, however keen they are. Screen
for Android before counting heads.

**Recruit more than 12.** The 14 days must be continuous per tester; someone
opting out breaks their own streak. There is no single global timer — each
tester counts their own 14 days — so adding people later does not reset anyone
else, it just means those people finish later.

*(Tester mechanics above came back **ungrounded** from the research model and
are recorded as **NULL — unverified** except the opt-in URL format and the
12×14 rule itself, which are on the fetched pages. Console will show the exact
opt-in link for your app; trust that over this paragraph.)*

## When leaderboards go online

Online leaderboards cannot work without sending a score off the device, and that
is exactly the line Google's Data safety form draws
([answer/10787469](https://support.google.com/googleplay/android-developer/answer/10787469)):
*"Collect means transmitting data from your app off a user's device."*

So today's "no data collected" is accurate, and it stops being accurate the
moment the first build uploads a score. **The declaration must be updated before
that build is released, not after.** Concretely, that release needs:

1. **Data safety updated** — at minimum an "App activity" / in-game actions
   entry, plus "Device or other IDs" if scores are tied to any identifier, and
   the account-linking answers if a sign-in appears.
2. **Privacy policy updated** — say what is sent, why, whether a display name is
   attached, and how someone gets their entry removed.
3. **Content rating re-checked** — the questionnaire asks about user
   interaction and shared content; a public leaderboard can change the rating.
4. **The Play Games Services question answered properly** — still
   **unresearched**. The research model returned zero grounding chunks on every
   games-specific question, so nothing about PGS is verified here. Treat it as
   an open investigation, not a known-optional add-on.

Declaring collection now, in anticipation, would be its own inaccuracy — the
form describes the version being uploaded. The correct move is an accurate
declaration today and a hard gate on the leaderboard release.

## What is verified, and what is not

**Verified by fetching the page in-session:** the closed-testing requirement and
its 12×14 shape; that store listing, App content and pricing block a release;
privacy policy and Data safety being required for closed testing; the content
rating and target-audience requirements; every listing dimension and character
limit; the Data safety definition of "collect"; the upload-key/app-signing-key
split and upload-key recoverability.

**NULL — unverified:** the internal-vs-closed *tester limits* and per-track
review details (ungrounded model output); tester opt-in/opt-out mechanics beyond
the URL format; whether the store name can be freely changed after publishing
(believed yes, **not confirmed**); anything about Play Games Services; and the
first end-to-end run of `android-release.yml`.
