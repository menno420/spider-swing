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

> **And the block below then made the same mistake in the other direction, seven
> times (corrected 2026-08-03).** It asserted that every fact in it was read from
> three named files. Four contradicted those files — the hazard vocabulary gave
> Bramble Canopy six patterns that only exist in Ancient Forest, the debug banner
> string was truncated to a form the game never prints, the stated restart
> giveaway was the opposite of what `_draw_spider` does, and the "8–50 m" rule
> holds only for runs that start at zero. Three more were omissions that would
> each make a **correct** reading look wrong: two of the four death strings were
> missing, the death line's dependence on a player setting was unstated, and the
> rescue life was absent, so a survived lethal hit read as a physics bug.
>
> Same shape as the entry above, opposite sign: the earlier error suppressed a
> true reading, these would have manufactured false ones. Both were written
> confidently, and both were one grep from being caught. **Re-reading a document
> is not re-deriving it** — the region order here was right precisely because it
> had changed the day before and got checked, while the vocabulary had been
> stable for days and got written from memory. The stable facts are the dangerous
> ones.

## The grounding block

Paste this into a custom assistant's instructions or knowledge file (Gemini
"Gem", or the system prompt of whatever reads the clips). Regenerate it from
source when the region layout, HUD or pattern catalogue changes — every fact
below is read from `game/domain/course_region_catalog.gd`,
`game/application/course_pattern_catalog.gd`,
`game/presentation/scripts/swing_lab.gd`,
`game/simulation/simulation_world.gd` and
`game/application/swing_lab_session.gd`. **Re-derive, do not re-read**: the
2026-08-03 correction above was a re-read that missed four contradictions of the
files it named.

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

HUD. Top left, stacked: the distance, then the current region name under it.
Distance renders as "%05.1f m" — ZERO-PADDED to five characters. So "014.8 m" is
fourteen point eight metres, not a truncated larger number, and "8180.7 m" and
"13208.4 m" are ordinary readings. Never report a missing digit.
Top right, stacked: "FLIES n · TOTAL n" — the first is THIS run, the second is
the lifetime total and does not reset. Then, when active: "BURST FRENZY n.ns",
"RESCUE READY" or "RESCUE SPENT", "GLIDE n.ns", "SHELL READY" or "SHELL SPENT".

PRACTICE BANNER. Centred at the top, yellow, and drawn ONLY in practice mode.
It is exactly one of four strings:
  DEBUG START <n> m · UPGRADES L<n> · AWARDS NOTHING
  DEBUG START <n> m · AWARDS NOTHING
  DEBUG UPGRADES L<n> · AWARDS NOTHING
  PRACTICE · NO FLIES OR RECORDS
"DEBUG START <n> m" means the run BEGINS at n metres — the distance readout
starts there, it is not an offset to subtract. Upgrade levels run 1–40. The
fourth string is a banner but does NOT mean a debug start. No banner at all
means an ordinary scoring run on the player's own save, and the upgrade state is
then unknown — say so rather than guessing.

RESTART FRAMES — the most common misreading. The player restarts instantly on
death, so the frames AFTER a death fade belong to a NEW run. They are not a
separate short run and must not be reported as one. One recording contains one
run plus the first seconds of the next, unless the recording plainly shows
several deaths.
The giveaways are: "RUN ENDED" and "Tap anywhere to restart" appeared just
before; the FLIES counter reset to zero while TOTAL did not; the distance
dropped and the region name went with it; and the event line at top left was
replaced by a run-start message such as "Opening web ready", "BRAMBLE CANOPY
ready" or "DEBUG START <n> m · awards nothing".
The spider is STILL DRAWN on the ended-run screen, so "no spider on screen" is
not a giveaway.
A restart returns to the run's START distance, which is NOT always zero. An
ordinary run restarts at 0 m and those frames read 8–50 m. A "DEBUG START
10000 m" run restarts at 10 000 m and those frames read a little over 10 000 m
in SILK HOLLOW. Read the banner before deciding what a low or high number after
a death means.

HOW A RUN ENDS. First "FALLING…" centred for about half a second, during which
taps do nothing; then a dark overlay with "RUN ENDED" and, under it in cyan,
"Tap anywhere to restart".
One fatal contact does not always end the run: if a rescue life is available the
game rescues the player instead and the run continues, and the HUD flips
"RESCUE READY" to "RESCUE SPENT" at that moment. A survived lethal-looking hit
is this, not a physics bug.

DEATH CAUSE. There are exactly four strings, in the game's own words:
  Hit a laboratory obstacle
  Hit the solid ceiling or floor
  Fell below the laboratory
  Caught by the pursuing bird
"laboratory" is what this game calls its own test environment, not a hazard type
and not a biome. Quote the line verbatim; do not paraphrase it into a hazard
name.
These appear on the general event line at top left, under the region name — NOT
on a dedicated end-of-run panel — and only when the player has "Show control
hints" enabled. With that setting off there is no death text anywhere on screen
and the cause is simply not readable from the recording. Say so rather than
inferring one.

HAZARD VOCABULARY. These are internal names and NONE of them is ever displayed
in-game — they are here so you can describe what you see precisely. Never claim
the game labelled something. Each region draws from its own pool and the pools
do not overlap.
  BRAMBLE CANOPY — the whole pool is eight entries: canopy hook high, canopy
  hook low, canopy leaf high, canopy leaf low, and four paired weaves (canopy
  hook high/low, canopy hook low/high, canopy shutter high/low, canopy shutter
  low/high). Nothing else appears here.
  ANCIENT FOREST — the widest pool: floor vine, canopy pod, thorn ridge, hanging
  vine, rooted gate, fallen stump, ceiling stump, bramble curve, high/low weave,
  low/high weave, silk burr high, silk burr low, staggered S, tall vine, long
  pod, alternating thorns, vine curtain, bramble steps, stump and vine, recovery
  pair.
  SILK HOLLOW — cocoon chute, spindle gate, thread eye, lattice high, lattice
  low, droplet needles, orb cluster, twin sacs, suspended bridge.
Every region also gets "open recovery" chunks, which are deliberately empty.
Note what this means for a common mistake: canopy pods, bramble curves and
bramble steps are ANCIENT FOREST content, not BRAMBLE CANOPY content, despite
their names.
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

- **`measured`** — every fact in the grounding block, **re-derived** from the
  five source files named above on 2026-08-03, one file per section; the failure
  modes, checked against the eight hand-read runs.
- **`inferred`** — that batching causes the attribution errors. Consistent with
  the evidence (correct numbers, wrong files, tail clips collapsed) and **not yet
  falsified**: the test is to re-send two clips individually and check whether
  distance, region and upgrade state all come back correct.
- **`assumed`** — that the grounding block reduces misreadings at all. Untested
  until a review runs with it in place. This label survives the 2026-08-03
  correction unchanged: fixing seven wrong facts makes the block *correct*, which
  is not the same claim as *effective*.
- **`retracted`** — the "invented vocabulary" failure class. It was one example,
  the example was wrong, and the class had no other members. See the note under
  the failure table.
- **`corrected`** — the first version of this section labelled the whole
  grounding block `measured` while four of its facts contradicted the files it
  named and three more were missing. The label was applied to the document, not
  earned by the sentences. **A provenance label is a claim like any other**, and
  it is the one claim that stops anyone downstream from checking the rest — which
  is precisely why this document now names five source files instead of three,
  and says re-derive rather than regenerate.
