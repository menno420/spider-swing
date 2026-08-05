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

#### How testers actually join — verified 2026-08-05

Fetched from [answer/9845334](https://support.google.com/googleplay/android-developer/answer/9845334)
and [answer/14151465](https://support.google.com/googleplay/android-developer/answer/14151465).
This replaces the previous **NULL — unverified** paragraph.

| Track | Who can join | Ceiling |
|---|---|---|
| Internal | Only addresses on an email list you build. *"You can create a list of internal testers by email address."* | 100 per app |
| Closed | Email lists **or Google Groups**. *"In the 'Testers' section, you can add testers via email or Google Groups."* | 200 lists × 2,000 users |
| Open | *"If you run an open test, anyone can join your testing program"* — no list at all | unlimited, or a floor of 1,000 |

**A tester must be on the list or in the group before the opt-in link does
anything.** The link is an enrolment page for an already-permitted account, not
an invitation. Google states it for the group case directly: *"If you're running
a closed test with a Google Group, users need to join the group before opting
into your test."*

Two link shapes exist and they are not interchangeable:

- **Internal:** `https://play.google.com/apps/internaltest/<track-id>` — a
  numeric track id, not the package name. *(Measured from this app's Console on
  2026-08-05, not from a documentation page.)*
- **Closed:** `https://play.google.com/apps/testing/<package-name>` —
  **unverified.** Widely used, but it is not stated on any page fetched in
  session. Console prints the real link; trust Console over this line.

#### Open testing is not an escape hatch

The obvious reading — "skip the email collection, run an open test" — does not
work on this account. Google's page is explicit: *"Open testing is available
when you have production access."* Production access is exactly what the closed
test is a precondition for, so the ordering is closed test → production access →
open testing. There is no way to start with the open track.

#### The one self-serve route: closed testing + an open Google Group

Handing over an email address before you can see the game is a poor first
impression, and it makes the developer the bottleneck on every single tester.
The way around it is the Google Group, which closed testing accepts and internal
testing does not.

Google Groups has a **"Who can join group"** setting whose most permissive
option is **"Anyone can join"** — any person on the web adds themselves, with no
invitation and no approval
([groups/answer/2464926](https://support.google.com/groups/answer/2464926)).

Set that, add the group to the closed track, and the flow becomes: share one
link → the person joins the group themselves → they opt in and install. No
addresses collected, no approvals, no developer in the loop. **And it is the
track that counts toward the 12 × 14 requirement**, so the self-serve flow and
the clock are the same flow.

The cost is the gate in the first section of this document: a closed track
cannot roll out until the store listing and App content are complete and the
build has passed review. Internal testing is instant but manual; closed testing
is self-serve but gated. **This is the strongest practical argument for
finishing the store listing** — it is not paperwork before the fun part, it is
what unlocks the only link worth sharing.

#### Counting heads

**Every tester needs an Android device.** Obvious in hindsight, and it has
already cost one volunteer: a friend who asked to play on 2026-08-03 could not,
because he is on iPhone and Apple does not permit installs from outside the App
Store. **iOS contacts cannot count toward the 12**, however keen they are. Screen
for Android before counting heads.

**Recruit more than 12.** Google counts continuous days per tester: *"we won't
count testers who opted in, tested for less than 14 days, and then opted out.
Even if they opt back in so that they are opted in for a total of 14 days, these
14 days must be consecutive."* There is no single global timer — each tester
runs their own 14 days — so adding people later does not reset anyone else, it
only means those people finish later.

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

**Verified 2026-08-05, second pass:** the per-track tester ceilings (100 /
2,000 per list / unlimited); that Google Groups are accepted for closed testing
and not for internal; that a tester must be on the list or in the group before
the opt-in link works; that open testing requires production access and
therefore cannot precede the closed test; that a Google Group can be set so
anyone on the web joins without approval; and the consecutive-days rule quoted
verbatim.

**NULL — unverified:** the closed-test opt-in URL *format*
(`/apps/testing/<package>`) — the internal one is a numeric track id, so the
shapes differ and Console is the only trustworthy source; per-track review
durations; whether the store name can be freely changed after publishing
(believed yes, **not confirmed**); anything about Play Games Services; and
whether a Google Group added to a closed track admits people who join the group
*after* the track is rolled out without a further Console action.
