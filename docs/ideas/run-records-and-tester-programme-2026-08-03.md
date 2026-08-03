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
> **Nothing here is approved.** The open forks are listed at the end and three of
> them are owner-only.

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

<!-- OWNER SECTION — the recruitment plan is the owner's and is being written
     separately. This heading exists so it lands here rather than displacing the
     analysis above. -->

### Recruitment and cohort plan

*Owner-authored, pending.*

## 3 · What will bite, that has not been named yet

**1 · How testers actually get a build.** Today it is a GitHub Actions artifact:
it needs a GitHub account and it **expires after 14 days**. That is an unusable
funnel for strangers recruited from a testing platform, and it gates the entire
programme.
[`distribution-and-first-contact`](distribution-and-first-contact-2026-08-01.md)
already owns this problem.

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

1. **Run records, local only, fully context-labelled.** No network, no consent
   requirement, no spend. Unblocks the stat-gated boards, the difficulty
   questions and the upgrade questions simultaneously.
2. **In-app closed prompts.** Cheap, and only useful once there are stats to
   compare the answers against.
3. **Distribution.** Gates recruitment, so it must be settled before a cohort
   exists rather than after.
4. **Consent.** Gates anything leaving the device.
5. **A server — deliberately last.** Local records plus manual export carry a
   cohort of ~20 at zero cost and zero liability, and they establish which stats
   are worth collecting *before* anything is built to receive them. Building the
   receiver first guarantees collecting the wrong fields.

## 5 · Open forks

Three are owner-only. The rest are contained technical calls and can be made by
an agent and recorded.

**Owner:**

1. **Distribution** — a Play Console internal-testing track (account plus spend,
   handles 100 testers properly), or hand-delivered APKs while the cohort is
   small?
2. **Data posture** — local-only with manual export, or design now for automatic
   upload later? This changes the consent design, not merely the plumbing.
3. **Board scope** — do run records get built to serve the narrow boards
   immediately, or to answer design questions first with boards following?

**Agent-decidable, recorded when made:** the exact field list, the retention
window, the storage format and its schema-version discipline, and where the
record type lives in the layer model.

## Provenance

Owner planning session, 2026-08-03, following the `0.39.0` playtest. Interlocks
with [`competitive-layer`](competitive-layer-2026-08-01.md) (the boards that need
these stats), [`player-feedback-loop`](player-feedback-loop-2026-08-01.md) (what
happens to what testers say), and
[`distribution-and-first-contact`](distribution-and-first-contact-2026-08-01.md)
(how a tester gets a build at all).
