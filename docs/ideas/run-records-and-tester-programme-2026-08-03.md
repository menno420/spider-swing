---
state: captured
origin: owner
shipped_pr: null
shipped_repo: null
merged_date: null
outcome: open
---

# Run records and the tester programme — one system, half of it already designed

> **Status:** `ideas`
>
> Captured from a live owner planning session, 2026-08-03, immediately after the
> `0.39.0` device verdict. Two asks that arrived as separate topics and are not
> separate: **per-run stat retention**, and **recruiting testers for
> perspectives rather than for more recordings**.
>
> **Nothing here is approved**, with one exception recorded as it happened:
> **distribution was settled by the owner on 2026-08-03**, mid-document, in
> favour of a Play Console testing track from the start. The remaining forks are
> listed at the end, two of them owner-only.

> **Promoted slice, 2026-08-06:** the bounded local-evidence portion of §1 and
> sequence step 1 shipped through PR #172 as `0.44.0-run-evidence`. The canonical
> implemented contract is [`../technical/run-evidence.md`](../technical/run-evidence.md):
> one settlement-paired schema, 100 retained records, fixed-size lifetime
> aggregates, a state-owned in-game history, and explicit manual JSON copy with
> no transmission. This promotion does **not** approve or ship recruitment,
> prompts, consent for remote collection, identity, automatic upload, tester
> rewards, Discord work, or leaderboards; those forks remain here.

## Why these are one system

The owner's ask for run stats — *"how many times someone used reel or burst, how
often they dived and the average speed and maximum speed etc… These stats could
also be useful to add to the eventual leaderboard entries"* — turns out to be a
prerequisite for a feature this repository already designed.

[`competitive-layer`](competitive-layer-2026-08-01.md) lists the boards the owner
wants: *distance in any mode · total flies · most flies in a single run ·
**furthest without burst or dive** · **furthest with no upgrades** · furthest per
spider.*

**Two of those are stat-gated categories.** "Furthest without burst or dive" is
unenforceable unless a run records which verbs it used, and "furthest with no
upgrades" is unenforceable unless it records what was equipped. So run records
are not a side feature that might one day help the boards — they are the thing
that makes half the board list possible at all.

The other half was already solved.
[`player-feedback-loop`](player-feedback-loop-2026-08-01.md) covers what to *do*
with what testers say, including the rule that the nos get published too. What
is missing from that doc is the **collecting** half, which is most of this one.

## 1 · Run records

### Two shapes, and conflating them is the mistake to avoid

|  | **run record** | **leaderboard entry** |
| --- | --- | --- |
| purpose | answering design questions | ranking players |
| size | rich, ~25 fields | small, only what validates the category |
| lifetime | rolling window, bounded | immutable, permanent |
| trust model | trusted — it is a tester's own device | **adversarial** — boards get cheated |
| schema churn | expected, frequent | must be near-frozen |

Keeping them separate costs nothing now and is very expensive to undo later.
Attaching the rich record to a board entry would freeze a schema that needs to
change weekly, and would widen the surface a cheater can forge from "a distance"
to "twenty-five correlated fields".

### The fields

**The definitions already exist and are exercised.** `tools/simulate.gd` computes
almost exactly this list for the bot every run, so reusing its definitions makes
lab output and real play directly comparable at no cost. One real lab line:

```
per run 33.9s · 36.0 flies (19.7/km) · 36.9 webs · 10.2 bursts (0.0 saves)
· 24.9 dives · input 4.62 taps/s · reel 10.78s held · 1.07 empties
· own speed +3.8 m/s vs the drive's floor · above it 64% of the run
```

| group | fields |
| --- | --- |
| **performance** | distance, duration, mean speed, maximum speed, share of run above the speed floor |
| **verbs** | webs fired, reel activations, reel seconds held, reel empties, bursts used, dives used |
| **outcome** | death cause, death distance, **death region**, rescue consumed |
| **economy** | flies collected, flies per kilometre |

`death region` is not in the owner's list and is added deliberately: every
difficulty question this project has asked so far has been answered per region,
and a distance without a region has to be re-derived against whatever the region
boundaries were on that build.

### The context block, which is the part that will silently ruin everything

**Every record carries the world it was recorded in, or it is worthless within a
week.** Builds ship here every day or two; a stat with no build version attached
cannot be compared against anything after the next one.

Required on every record:

```
build_version · difficulty_mode · spider_id · upgrade_levels
course_seed · run_mode · start_distance
```

This repository already holds exactly this discipline elsewhere and it has
already paid for itself: `TraceCatalog.INPUT_TRACE_FORMAT` **refuses**
cross-generation input rather than replaying it into a world it was not recorded
in — and the 0.39.0 slice proved why, when a trace from the previous course
replayed 1 586 m short without erroring. Same rule, same reason, same failure
mode if skipped.

### Two context fields the owner did not ask for, and the reason is a live example

`attempt_ordinal` — which run this is in the current sitting — and
`lifetime_runs`.

Without them, **skill cannot be separated from anything else**, and this is not
hypothetical. In the 2026-08-03 device session the owner played L0 *after* his
upgraded runs, and one L0 run out-ran four upgraded ones. That result is real but
uninterpretable: it cannot distinguish *"upgrades barely matter"* from *"he was
warmed up"*. See
[`device verdict`](../measurements/2026-08-03-device-verdict-on-the-curve.md).

An attempt counter makes that comparison answerable for free, forever.

### Retention

Every run kept forever is unbounded growth on a phone. Bound it in two parts:

- **a rolling window** of the last ~100 full records — answers "what happened
  lately", which is what a design question needs;
- **lifetime aggregates** that never grow — answers "is this player improving",
  which is what a tester programme needs.

### One rule to hold this to

**Every stat needs a named consumer before it ships** — a board, a specific
question, or a contract.

This is F1 and R10 from the difficulty doctrine, applied to a new surface. The
`difficulty` label sat unread for months and drifted precisely because nothing
consumed it, and the fix was to give it a consumer rather than to keep it around
in case. A stat nobody reads is a stat nobody notices going wrong.

## 2 · The tester programme

### The problem is the question, not the testers

The owner's report — *"I already asked a few of my friends but I feel that they
aren't really taking the feedback part very seriously"* — reads as a motivation
problem and probably is not one.

**Open questions get open answers.** *"What did you think?"* returns *"it was
fun"* from anyone who is not already a designer. That is the question's fault.

**Closed questions asked in-app, at the moment the thing happened, survive a
disengaged tester.** After a death: *"your mistake, or unfair?"* — two taps, and
it is the single most valuable datapoint available about difficulty, because it
is the one thing no amount of instrumentation can infer.

### The owner's six areas need six different instruments

Behaviour answers *what*; questions answer *why*. Asking people things that can
be measured wastes the one resource testers have least of.

| what he wants to know | instrument |
| --- | --- |
| too easy / too hard | in-run prompt **and** run stats — *perceived versus actual, and the gap between them is the finding* |
| do upgrades feel meaningful, are costs right | **behaviour**: does a player buy a second level of the same track? plus one direct question |
| are the game modes sufficient or too narrow | session-level question — this is not a per-run question and asking it per run trains people to dismiss it |
| the spiders | **which one they pick** is stronger evidence than anything they say; ask why afterwards |
| visuals | moment-based: a screenshot with a comment. Aggregates cannot see this |
| general likes / dislikes | open-ended, low volume, high value — read personally, do not aggregate |

### Give each tester one assignment

Unfocused testers produce unfocused feedback. *"Play until you reach 5 km and
tell me the first moment that felt unfair"* outperforms *"try the game"* by a
wide margin, and it makes two testers' reports comparable.

<!-- OWNER SECTION — the recruitment plan is the owner's. Items marked `+agent`
     are additions written into it, kept visually separate so the owner's plan
     stays legible as his. -->

### Recruitment and cohort plan

**The owner's plan, as stated** (planning session, 2026-08-03):

1. **`superbot-next` ships first.** The Discord server is stood up by an agent
   driving the bot, not clicked together by hand.
2. **The game gets a public name** — likely *Slingy Spider*.
3. **Builds are uploaded manually, older versions included**, so testers can
   compare across versions.
4. **Recruit from Reddit and dedicated tester platforms.**
5. **Dedicated channels for videos and for written feedback**, kept apart.
6. **Reward testers after time played plus good feedback.**
7. **The bot's AI is scoped to live game details**, so it can answer testers
   about the actual build rather than improvising.
8. **A Google Play testing account, set up from the start** — because a real
   share of testers will not enable installs from unknown sources.

Point 8 arrived last and is the one that changes the shape of everything else.

#### What the Play decision settles, and what it costs

**It closes owner fork 1 in §5** — distribution is a Play testing track, not
hand-delivered APKs. That was the fork gating recruitment, so recruitment is no
longer blocked on a decision.

It also **retires hazard 1 in §3** (GitHub Actions artifacts: account required,
14-day expiry) as the tester funnel, and it **reassigns the APK channel to the
job the owner already named for it** — an archive of older versions for
comparison, which is a genuinely useful thing that is simply not a funnel.

`+agent` — **two things to check while setting the account up**, because they
change the cohort's *size*, not merely its plumbing:

- **Internal testing vs closed testing are different products.** Internal
  testing takes up to 100 testers and publishes near-instantly with no review
  wait; closed testing is larger and goes through review. For a first cohort of
  ten, internal testing is the right track and the fast one.
- **A personal (non-organisation) developer account carries a testing
  requirement before production release** — a minimum tester count sustained
  over a period. If that still holds, it sets a **floor on cohort size** and a
  **clock that only starts once testers are actually opted in**, which is an
  argument for opening the track early even with nobody in it yet. Worth
  confirming at signup rather than trusting this paragraph — Play's policies
  move, and this one is worth being right about.

#### The channels, mapped to subsystems that already exist

`+agent` — every row below is an existing `superbot-next` subsystem, so this is
configuration rather than bot development. Named so the server build is a
morning's work and not a project.

| channel | its one job | subsystem |
| --- | --- | --- |
| `#start-here` | what the game is, what testing costs, the consent line, one tap to join | `welcome` · `setup` |
| `#get-the-build` | the Play opt-in link, and only that | — |
| `#version-archive` | older builds, for the compare-two-versions assignment | `media` |
| `#your-assignment` | the current wave's single question, posted once | `automation` |
| `#run-clips` | video only, no discussion — discussion drowns clips | `media` · `starboard` |
| `#feedback` | one thread per report, structured intake | `ticket` |
| `#bug-reports` | separate from feedback, so bugs do not bury perspectives | `ticket` |
| `#what-changed` | the nos published, per `player-feedback-loop` | — |
| `#lounge` | free chat, and where peer credit happens | `karma` |
| `#rewarded` | locked; opened per tester as the reward lands | `proof_channel` |

Two of those are load-bearing rather than decorative:

- **`proof_channel`** is the prize-session family (`+prize`, `timedprize`,
  `-prize`, `prizestatus`) — it grants one member access to a locked channel,
  optionally with an automatic expiry. That is a reward mechanism with an audit
  trail, already built, already tested.
- **`karma`** (`!thanks @user`) is peer credit with a per-actor grant cap. It is
  what lets *"good feedback"* be judged by more than one person without becoming
  the owner's second job.

#### The joining flow

`+agent` — written as a funnel because every step loses people, and it is worth
knowing which step.

1. **Post → Discord invite.** The recruitment post links to the server, never
   straight to a build. The invite is free, revocable, and the consent screen has
   to happen before anything is collected regardless.
2. **`#start-here`.** What the game is, what is asked (time, honesty), what is
   given (the reward), and the consent line — §3 hazard 5, and it belongs
   *here*, before a build exists on anyone's phone.
3. **One tap.** Accepting grants the `tester` role and triggers a DM with the
   Play opt-in link.
4. **Opt in → install → play.**
5. **`#your-assignment`** carries the wave's question from that point on.

**Why Discord before build:** an invite costs nothing to hand out and nothing to
withdraw; a Play tester slot on a personal account is a scarcer thing and, if
the testing-requirement clock above is real, one that starts ticking.

#### Cohort 1: about ten people, one wave at a time

`+agent` — **eight to twelve.** Large enough that two testers disagreeing is
information rather than noise; small enough that the owner can read every word
personally, which §2 says is the correct handling for the open-ended half and
which stops working somewhere around twenty.

Each wave runs one assignment, for everyone, for a fixed stretch. §2's rule —
*give each tester one assignment* — becomes *give the cohort one assignment*,
which is strictly better: it makes ten reports directly comparable.

| wave | assignment | what it answers | not asked, deliberately |
| ---: | --- | --- | --- |
| 1 | *"Play until you die three times. Tell me the first moment you did not know what to do."* | first-session comprehension — §3 hazard 2, the non-renewable asset | anything about balance |
| 2 | *"Get as far as you can. Tell me the first moment that felt unfair."* | difficulty perception, read against the run records | — |
| 3 | *"Spend your first upgrades however you like, then tell me whether you would spend them the same way again."* | upgrade meaningfulness and costs — the answer is mostly in *what they bought* | — |
| 4 | *"Play this version and the older one in `#version-archive`. Which is better, and why?"* | the archive channel's real job, and the only question that gets at "have the changes helped" | — |

Spiders, visuals and mode sufficiency ride along inside these waves per the §2
instrument table — pick-rate for spiders, screenshots for visuals — rather than
taking waves of their own. **Wave 1 asks one question and no others.** It is the
only wave whose asset cannot be recovered.

#### The reward rule, made exact

The owner's rule is *"time played plus good feedback"*. Both halves need a
definition that cannot be argued with at payout time.

A tester qualifies for a wave's reward when **all three** hold:

1. **Played** — a minimum number of runs on that wave's build, **evidenced by
   run records rather than by claim.** This is the concrete reason §4 puts run
   records first: without them, "time played" is self-reported and the reward
   rule is unenforceable.
2. **Reported** — at least one `#feedback` thread that answers *that wave's*
   assignment. Off-assignment feedback is welcome and does not count here.
3. **Judged good** — the report drew peer credit (`!thanks`) from at least two
   other testers, **or** the owner marked it. `+agent`

Then `+prize` opens `#rewarded` for them, which is both the reward and its
receipt.

`+agent` — **the failure mode of criterion 3, named now rather than discovered
later:** in a cohort of ten, peer credit can decay into mutual back-scratching.
Three things hold it: `karma`'s per-actor grant cap is already built, the owner
mark is an unconditional override in both directions, and — the real one — the
reward should be **small and repeatable** (a role, an early build, a name in the
credits) rather than large and rivalrous. A reward worth farming will be farmed.

#### What recruiting will actually cost, said before it is tried

`+agent` — three things that are true about the two channels the owner named:

- **Most subreddits ban self-promotion**, and the ones that permit it are mostly
  other developers — who are excellent at spotting a bad control scheme and bad
  at representing a player. Worth using, worth knowing what it returns.
- **Paid tester platforms buy compliance, not curiosity.** They reliably produce
  someone who completes the checklist. The owner's complaint about his friends is
  not that they skipped the checklist — it is that they did not engage — and a
  paid tester is engaged with the task, not the game. Expect structure from that
  channel and insight from the Reddit one.
- **The strongest recruiting asset this project has is the videos.** A clip of
  the 10 km wall does more than any description, and it costs nothing to post.

#### The one signal that needs no questions

§3 hazard 3 — *do they come back tomorrow?* — becomes measurable the moment the
Discord exists, at zero cost: **is the tester in the server on day 3, and did
they play again.** Weak as a proxy, free as a measurement, and the single
strongest number in the whole programme.

#### Owner-only, in this section

The Play Console account and its spend; the public name; the reward itself; and
the recruitment post's wording. Everything else here is configuration an agent
can perform.

## 3 · What will bite, that has not been named yet

**1 · How testers actually get a build.** ~~Today it is a GitHub Actions
artifact: it needs a GitHub account and it **expires after 14 days**.~~
**Answered while this document was being written** — the owner is opening a Play
Console testing track from the start, so the funnel is a Play opt-in link and
the Actions artifact never touches a tester. See the recruitment plan above.
[`distribution-and-first-contact`](distribution-and-first-contact-2026-08-01.md)
still owns the wider problem; this closes its tester-facing half.

**2 · A tester's first session is a one-time, non-renewable asset.** Nobody meets
these controls cold twice, and the owner cannot see this failure mode at all
because he wrote them. Spend it deliberately: for a first run, capture *only*
whether they understood what to do — and do not waste it asking about difficulty
balance.

**3 · Do they come back tomorrow?** The strongest single signal in the programme,
it requires no questions at all, and nothing currently records it.

**4 · Other people's phones.** The simulation is fixed-step 60 Hz and the owner
has one device. A tester on weaker hardware finding a sustained frame drop is
worth more than any opinion in this document — but only if something reports it.

**5 · Consent.** The owner is in the EU. Even local-only data becomes personal
data the moment a tester is asked to send it. One plain screen and one plain
sentence, before any external tester plays. Cheap now; expensive to retrofit over
a live cohort.

**6 · Publishing the nos.** Already the settled position in
[`player-feedback-loop`](player-feedback-loop-2026-08-01.md), and it becomes
load-bearing the moment there is more than one tester: a cohort that sees nothing
happen disengages faster than one that is told why.

## 4 · Suggested sequence

Ordered by what unblocks what, and by what is expensive to undo.

1. ~~**Run records, local only, fully context-labelled.**~~ **Shipped in
   `0.44.0-run-evidence` / PR #172.** No network, no remote consent flow, no
   spend. The rich local schema remains explicitly separate from any future
   leaderboard entry.
2. **In-app closed prompts.** Cheap, and only useful once there are stats to
   compare the answers against.
3. **Distribution — decided, and running in parallel.** The Play track is the
   owner's own work and does not block steps 1 and 2, which is the best possible
   arrangement: the thing that gates recruitment is being built by the person who
   is not writing the code.
4. **Consent.** Gates anything leaving the device — and now also gates the
   `#start-here` tap, which is the first place a real tester meets this project.
5. **A server — deliberately last.** Local records plus manual export carry a
   cohort of ~20 at zero cost and zero liability, and they establish which stats
   are worth collecting *before* anything is built to receive them. Building the
   receiver first guarantees collecting the wrong fields.

## 5 · Open forks

Three are owner-only. The rest are contained technical calls and can be made by
an agent and recorded.

**Owner:**

1. ~~**Distribution**~~ — **settled 2026-08-03: a Play Console testing track,
   set up from the start**, on the owner's reasoning that a real share of
   testers will not enable installs from unknown sources. Hand-delivered APKs
   are demoted to the version archive. This was the fork gating recruitment;
   recruitment is no longer waiting on a decision.
2. ~~**Data posture for the first evidence slice**~~ — **settled local-only with
   manual JSON copy on 2026-08-06.** Whether any later version adds automatic
   upload remains an owner-only fork and must reopen consent/privacy design
   before implementation; this build contains no receiver or upload seam.
3. **Board scope** — do run records get built to serve the narrow boards
   immediately, or to answer design questions first with boards following?

**Agent-decidable, recorded when made:** the exact field list, the retention
window, the storage format and its schema-version discipline, and where the
record type lives in the layer model.

## Provenance

Owner planning session, 2026-08-03, following the `0.39.0` playtest, in three
parts: the run-stats ask, the tester-perspectives ask, and the Discord plan with
its Play-track addendum. Interlocks with
[`competitive-layer`](competitive-layer-2026-08-01.md) (the boards that need
these stats), [`player-feedback-loop`](player-feedback-loop-2026-08-01.md) (what
happens to what testers say), and
[`distribution-and-first-contact`](distribution-and-first-contact-2026-08-01.md)
(how a tester gets a build at all).

**Outside this repository:** the channel and reward mechanics above are read
from `menno420/superbot-next` — `proof_channel`, `karma`, `ticket`, `welcome`,
`role`, `media`, `automation` are shipped subsystems there, not proposals. The
server build is configuration of an existing bot. Nothing in this document asks
for bot development.
