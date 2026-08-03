# Reviewing gameplay recordings

> **Status:** `reference`
>
> How owner and tester screen recordings get read, what a video is allowed to
> establish, and the grounding block to paste into an external visual reviewer.
> Sibling of [`replay-review-loop`](replay-review-loop.md), which covers the
> *other* direction — a run the lab found, put in front of a human. This one is
> about a run a human played, put in front of a reader.

## Why this exists

On 2026-08-03 eight owner runs were read out of ten screen recordings by hand:
a folder download, 693 extracted frames, a purpose-built digit classifier that
decoded ~15% of frames and emitted `99 003 m` on a 15 km course, discarded, then
a manual read of individual death frames. That produced eight numbers the game
knew exactly at the moment of death.

The session's conclusion was **"instrument the program, never the recording"**,
and the argument was entirely about cost. Later the same day the owner
demonstrated a natively multimodal reviewer (Gemini, free tier) reading the same
ten recordings in seconds, with every checkable distance exactly right.

**That does not overturn the conclusion; it splits it.** Cost was the reason
video was a last resort, and cost is gone. What remains true is the part that
was never about cost:

| question | instrument | why |
| --- | --- | --- |
| how far, how long, which verbs, what was equipped | **the game** | exact, free, no reader in the loop, and most of it never renders |
| *why did that feel bad* | **video** | no counter can see "those two things look alike at speed" |

So the rule becomes: **the game reports the numbers, the video answers where to
look.** Nothing numeric from a video review enters a document without being
verified against source or instrumentation.

## What a video review is allowed to establish

**Allowed** — a timestamp and a claim about legibility, pacing or feel:

- a hazard and an anchor that are hard to tell apart at speed;
- a corridor that reads as unfair rather than as the player's mistake;
- HUD elements that stop being readable once the speed is up;
- a region transition that does or does not announce itself;
- where a player's attention actually went.

**Not allowed** — anything the program already knows:

- distances, durations, fly counts, verb counts, speeds;
- which upgrade tier was equipped;
- death cause.

Those come from the run itself. A video reviewer that happens to read them
correctly is doing an expensive, verifiable-only-by-hand version of something
the game can emit for free.

## Known failure modes, and what fixes each

Measured against ground truth from the 2026-08-03 recordings
([`device verdict`](../measurements/2026-08-03-device-verdict-on-the-curve.md)):

| failure | example | fix |
| --- | --- | --- |
| **attribution across a batch** | a run's correct distance filed under the wrong clip, with an impossible start point | **one clip per message** |
| **attention thinning down a batch** | five clips collapsed into one vague sentence | one clip per message |
| **restart frames read as runs** | a reported run ending at 53.1 m | the grounding block below |

The first two are protocol; the third is grounding. **A batch of nine clips
answered in five seconds is not evidence of comprehension failure** — it is
evidence that attention was spread across nine files, which is a property to
design around rather than a flaw to complain about.

> **A fourth entry belongs here and does not, and the reason is the useful
> part.** *"The spider hits a laboratory obstacle"* was written up as an invented
> hazard name. **It is not invented — it is the game's own death-cause string**,
> `"Hit a laboratory obstacle"`, rendered on the run-ended screen
> (`game/simulation/simulation_world.gd:1497`). The reviewer read the HUD
> correctly and this document called it a hallucination without grepping for the
> word, then wrote an instruction telling the reviewer that string does not
> exist — which would have taught it to suppress a correct reading.
>
> Kept visible rather than deleted, because it is the sharpest available example
> of the rule this whole document exists to enforce: **an unverified claim about
> a recording is not made safer by being made confidently, and the direction of
> the error is not predictable.** The check is a grep, and it costs seconds.

## The grounding block

Paste this into a custom assistant's instructions or knowledge file (Gemini
"Gem", or the system prompt of whatever reads the clips). Regenerate it from
source when the region layout or pattern catalogue changes — every fact below is
read from `game/domain/course_region_catalog.gd`,
`game/application/course_pattern_catalog.gd` and
`game/presentation/scripts/swing_lab.gd`.

```text
You are reviewing screen recordings of an Android game built in Godot: a
side-scrolling physics swinging game. The player is a spider that fires webs at
anchors, swings, reels in and out, dives, and bursts. The run ends on contact
with a hazard. Distance only increases within a run.

REGIONS, in play order. Each is 5000 m long and is named on screen when entered.
  0 – 5 000 m      BRAMBLE CANOPY   height control, rapid high/low choices
  5 000 – 10 000 m ANCIENT FOREST   mixed fundamentals, wide recovery rhythm
  10 000 – 15 000 m SILK HOLLOW     precision, suspended hazards, narrow lines
Regions past 15 km exist but do not appear in current recordings: RUINED
ARBORETUM, STORM RIDGE, WEB CITY, ASHEN HOLLOW, DEEP MIST.

HUD. Distance renders as "%05.1f m" — ZERO-PADDED to five characters. So
"014.8 m" is fourteen point eight metres, not a truncated larger number, and
"8180.7 m" and "13208.4 m" are ordinary readings. Never report a missing digit.

DEBUG RUNS. A run started from the test lab shows a banner reading
"DEBUG START <n> m · UPGRADES L<n>". If there is no banner, it is an ordinary
run on the player's own save and the upgrade state is unknown — say so rather
than guessing.

RESTART FRAMES — the most common misreading. The player restarts instantly on
death, so the frames AFTER a death fade belong to a NEW run and read 8–50 m.
They are not a separate short run and must not be reported as one. The giveaway
is that there is no spider on screen. One recording contains one run plus the
first seconds of the next, unless the recording plainly shows several deaths.

DEATH CAUSE. The run-ended screen states the cause in the game's own words, at
the top left under the region name. "Hit a laboratory obstacle" and "Fell below
the laboratory" are REAL strings — "laboratory" is what this game calls its own
test environment, not a hazard type. Quote the on-screen line verbatim when you
report a death; do not paraphrase it into a hazard name.

HAZARD VOCABULARY. Obstacles have real names. Bramble Canopy: canopy hooks
(high, low, and paired), canopy leaves, canopy pods, canopy shutters, bramble
curves, bramble steps. Silk Hollow: cocoon chutes, droplet needles, lattices,
orb clusters, spindle gates, suspended bridges, thread eyes, twin sacs. Shared:
alternating thorns, ceiling stumps, rooted gates. Ancient Forest uses a wide
mixed ladder of the above families.
IF YOU DO NOT RECOGNISE A HAZARD, WRITE "unnamed hazard at <timestamp>", and
say what it looked like. Do not guess a name from this list to fill the gap.

WHAT TO REPORT. Timestamps and judgements about legibility, pacing and fairness:
where a hazard and an anchor were hard to tell apart at speed; where a death
read as unfair rather than as the player's own mistake; whether the HUD stayed
readable once speed was up; whether a region transition announced itself.

WHAT NOT TO REPORT. Do not count things. Distances, durations, fly counts, verb
counts, speeds and upgrade tiers are recorded by the game itself and are not
what this review is for. If a distance is genuinely needed for context, quote it
as a direct reading of a single visible frame and say which frame.

ONE CLIP PER MESSAGE. Do not review several recordings in one response.
```

## The loop

1. Owner or tester records a run and sends **one clip per message** to the
   visual reviewer.
2. Its output — timestamps and judgements — comes back here as text.
3. That becomes a measurement, a contract, or a fix. **Any number in it is
   re-derived from source or from the run record before it lands in a
   document.**

The bottleneck was never the analysis; it was the extraction. Step 1 used to
cost an afternoon and now costs an upload, which is what makes this viable for a
tester cohort rather than for one player — the constraint named in
[`run records and the tester programme`](../ideas/run-records-and-tester-programme-2026-08-03.md)
as the thing that breaks at ten testers.

## Claim provenance (PL-013)

- **`measured`** — every fact in the grounding block, read from the source files
  named above; the failure modes, checked against the eight hand-read runs.
- **`inferred`** — that batching causes the attribution errors. Consistent with
  the evidence (correct numbers, wrong files, tail clips collapsed) and **not yet
  falsified**: the test is to re-send two clips individually and check whether
  distance, region and upgrade state all come back correct.
- **`assumed`** — that the grounding block reduces misreadings at all. Untested
  until a review runs with it in place.
- **`retracted`** — the "invented vocabulary" failure class. It was one example,
  the example was wrong, and the class had no other members. See the note under
  the failure table.
