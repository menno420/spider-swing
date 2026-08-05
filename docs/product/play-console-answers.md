# Play Console — prepared answers for the App content declarations

> **Status:** `owner-approval-required`
>
> Every declaration Play requires before a closed-test release can roll out,
> with the answer and **why** it is that answer. Read the reasoning — you are
> certifying these, and a wrong declaration is a policy violation rather than a
> typo. Verified against the source 2026-08-05.
>
> Answers describe **the build being uploaded**. See § "The leaderboard trigger".

## Data safety

**Answer: no data collected, no data shared.**

The reasoning matters, because your instinct that "the game collects data" is
correct in plain English and Google is asking a narrower question. Verbatim from
[answer/10787469](https://support.google.com/googleplay/android-developer/answer/10787469):

> *"Collect means transmitting data from your app off a user's device."*
> *"User data accessed by your app that is only processed locally on the user's
> device and not sent off device does not need to be disclosed."*

The game records your runs, inputs, bests, currencies and progression — and
writes every byte of it to `user://` on the device. Verified in source
2026-08-05: `game/` contains no `HTTPRequest`, `HTTPClient`, `StreamPeer`,
`PacketPeer`, `WebSocket`, or multiplayer class of any kind.

So: **it retains data, and it collects none.** Both true.

| Console question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | **No** |
| Is all of the user data collected by your app encrypted in transit? | n/a — nothing is transmitted |
| Do you provide a way for users to request that their data is deleted? | n/a — uninstalling removes the local save |

**The form is still mandatory.** Only apps exclusively on *internal* testing are
exempt; closed, open and production all require it.

## Content rating (IARC)

Mandatory — an app without a rating cannot publish. Answers to the questionnaire
for this game:

| Topic | Answer | Why |
|---|---|---|
| Category | **Game** | |
| Violence | **No** | A spider swings past hazards. Failure ends a run; there is no combat, no injury depiction, no blood. |
| Sexuality, nudity | **No** | |
| Language | **No** | |
| Controlled substances | **No** | |
| Gambling / simulated gambling | **No** | Currencies are earned by playing and spent on upgrades. No wagering, no randomised paid rewards. |
| User interaction / user-generated content | **No** | No chat, no sharing, no accounts. **Changes when leaderboards ship.** |
| Shares user location | **No** | |
| Digital purchases | **No** | Nothing is sold in the build. |

Misrepresenting content *"may result in its removal or suspension"* — so if
monetisation or leaderboards land later, re-run the questionnaire.

## Target audience and content

| Console question | Answer |
|---|---|
| Target age groups | **13+** (do not tick under-13) |
| Is your app appealing to children? | **No** |
| Do you want your app in the Designed for Families programme? | **No** |

Ticking an under-13 group pulls the app into the Families programme, which adds
certified-ad-SDK rules, parental-control obligations and stricter review. There
is no reason to opt into that here. Google may still assess whether the declared
audience matches the app's actual content and presentation.

## The remaining declarations

| Declaration | Answer | Note |
|---|---|---|
| Ads — does your app contain ads? | **No** | No ad SDK exists in the build. |
| Advertising ID | **No** | The game does not use one. Declaring "yes" wrongly triggers extra policy checks. |
| Government apps | **No** | |
| Financial features | **No** | Certify that none are offered. |
| App access — is any part login-gated? | **All functionality available without special access** | No accounts exist. |
| News app | **No** | |
| COVID-19 contact tracing | **No** | |
| Data deletion request URL | leave blank / n/a | Nothing is collected. |

These last few were **not individually verified** against official pages — the
research model cited a bare site root for them. The Console will show exactly
what it wants; the answers above are what this build's behaviour supports.

## The leaderboard trigger

The moment a build sends a score off the device, this page is wrong and must be
redone **before** that build is released:

1. **Data safety** flips to collection — at minimum "App activity" for in-game
   actions, plus "Device or other IDs" if scores carry any identifier, and
   account-linking answers if a sign-in appears. Also then required: an
   encrypted-in-transit answer and a data-deletion route.
2. **Content rating** — the *user interaction* answer likely flips to **yes**,
   which can change the rating itself.
3. **Privacy policy** — must state what is sent, whether a display name is
   attached, and how an entry is removed.
4. **Play Games Services** — genuinely unresearched. Every games-specific
   research answer came back ungrounded, so nothing about PGS is verified here.

Declaring collection *now*, before it happens, would be its own false
declaration — the form describes the version you are uploading. Accurate today,
gated at that release.
