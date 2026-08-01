---
state: routed
origin: owner
shipped_pr: null
shipped_repo: null
merged_date: null
outcome: open
---

# Distribution — the install funnel is currently eating the signal

> **Status:** `ideas`
>
> **The cheapest high-value fix available.** Not a game problem; a delivery
> problem. The people who said "cool" probably never got to play.

## The finding

The repository has **exactly one export preset: Android Debug**. No web build, no
desktop. Builds are shared as **GitHub Actions artifact links**.

**Actions artifacts require the downloader to be signed in to GitHub.** So the
funnel for a friend is: have a GitHub account → open the link → sign in →
download a zip → extract it on a phone → find the APK → enable unknown sources →
install.

That filters by *"has a GitHub account"*, not by *"would enjoy this game."*

### It fits the observed data exactly

Reactions collected 2026-07-30/31 split cleanly:

- **One person clearly installed and played.** He came back across multiple
  builds (noticed a menu update), reached 4 km, and complained that 10 km felt
  out of reach — *"Bro whos reaching 10k. Way too hard"*, *"I reached 4k with
  LUCK."* Frustration in the **engaged** register, not the quitting one, on a
  game that was two days old. He also carries a YouTube creator badge.
- **Everyone else responded to the video** — "holy moly", "Goated", "Woa, cool",
  🔥 reactions, and one "yeah i would" to *"would you play something like this?"*.

**The owner's read on their sincerity is correct and evidenced** — the one person
who got through the funnel gave genuine criticism, so this circle does deliver
honest negatives. The point is narrower: a sincere reaction to a fifteen-second
clip is real evidence *about the clip*. It is not evidence about retention,
because most of them could not reach the thing.

**The deeper someone got into the funnel, the better the signal became.** That is
the optimistic reading and the actionable one.

## Options, all private — this does not conflict with holding back the launch

The owner does not want a public release before the game is finished and on the
Play Store, out of concern about the idea being copied. **That is not in tension
with fixing the funnel.** Three routes give a one-tap install to invited people
with *zero* public exposure — all more private than a GitHub link:

| Route | Cost | Privacy |
| --- | --- | --- |
| **Google Play internal/closed testing** | $25 one-time Play Console (needed anyway) | invited by email, installs from the Play Store, appears in no search or chart |
| **Firebase App Distribution** | free | invite-only by email, direct APK |
| **itch.io restricted/unlisted project** | free | password or secret URL, not indexed |

**What exists today is not privacy — it is friction that happens to be private.**

## ⚠ The deadline that may point the other way — verify

Google requires personal developer accounts to run a **closed test with a minimum
number of testers, continuously, for a minimum period**, before granting
production access. Believed to be on the order of a dozen testers for a couple of
weeks — **the policy has changed more than once and the current thresholds must
be verified in the Play Console before relying on this.**

If it holds, **starting a closed test is a prerequisite for launching, not a risk
to it**, and starting late directly delays the Play Store date by the length of
the test.

## On the copying concern

Real, but **reactive to success rather than to exposure**. Nobody clones an
unknown game — Flappy Bird sat unnoticed for months and was cloned only after it
hit #1. Clone shops watch the top charts, not itch.io. An invite-only test with
twenty people generates no signal to react to.

And the idea is not the defensible part. *"Endless runner where you swing on
webs"* is one sentence and swinging games already exist. What is hard to copy is
the **feel** — the pendulum that converts momentum, the reel that shortens the
rope and buys speed, the interaction of reel/burst/dive/release timing, tuned
over thousands of measured runs. Someone copying from a video gets the sentence.

**The velocity is the moat**, more than the idea: this repo went from creation to
76 merged PRs, 184 contracts, eight zones and signed Android builds in four days.

## Paying testers — the owner intends to

> *"I'm also considering to pay people to help me thoroughly test this game…
> it allows me to help people in a fair way by allowing them to help me as well
> in ways they can afford."*

**Highest-value use is not paying people to play — it is paying for the feedback
he structurally cannot otherwise get.** Friends will tell him the truth, but they
already know him and the game. What is missing is **strangers on first contact**:

> *Play for one session with no explanation from me. Tell me what confused you in
> the first thirty seconds, and when you first understood what you were
> supposed to do.*

That is unobtainable from anyone who has seen it before, and it converges with
the funnel fix — a closed test makes it possible for people who currently cannot
reach the game at all.

## Two cheap experiments

**The fifteen-second clip test.** Both of the owner's reference hits spread
through footage — Flappy Bird via shared scores, Subway Surfers via gameplay
clips. So: *can a fifteen-second clip make someone who has never heard of it want
to try?* He already records gameplay; this is answerable this week and builds
nothing. A "no" is a **readability** finding — too fast, too busy, unclear what
the player is doing well — which is fixable but invisible from the inside.

**A web export experiment.** The project renders with `gl_compatibility`, which
is the renderer that targets Web. A link that plays instantly in a mobile browser
with no install would be transformative for sharing. **Unverified** — Godot's web
export on mobile browsers is historically shaky on audio and touch. Worth one
timeboxed experiment, not a promise.
