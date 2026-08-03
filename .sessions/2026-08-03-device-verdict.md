# The first device verdict on the curve

> **Status:** `complete`

## Goal

Record the owner's play data on `0.39.0` — eight recorded attempts, two of them
at L0 — plus the Drive-folder access finding that made reading them possible.

Born red on purpose: the previous card was committed already `complete` and said
so, and this one exists before its own work does.

## Scope guard

**Documentation only. No code, no contract, no generator change, no build bump.**
The Burst-charge bound found here is deliberately left uncontracted — it is a
measurement of shipped constants, not a defect, and the owner's L0 clear shows it
is not binding. It gets a contract in the slice that raises Bramble's density,
if one ever does.

## Previous-session review

The curve-driven-course session shipped an APK and named three device questions.
All three came back answered in one sitting, which is the fastest turnaround this
project has had:

1. **Ancient Forest at 5–10 km** — no complaint. The two deepest runs both died
   there, but at 6 582 m and 8 181 m, not on entry.
2. **The 162 px opening obstacle** — no complaint about the art. The size floor
   stands at 0.60 unchallenged for now.
3. **The first 2 km** — answered by data rather than opinion: six runs entered
   the 2 000–2 500 m band and none died there, against 41% before.

Its weakness was one I created and then hit myself: **the card claimed the
session's own contract count in prose** and I had to remove it in a follow-up
commit. The rule existed, the brief restated it, and I wrote it anyway because
it was pasted verify output in one place and prose in another.

## What was found

**The 2 km spike does not appear in this sample.** The primary target of the
whole 0.39.0 slice, and the first evidence about it that is not geometry.

**L0 clears the opening, and beats most of the upgraded runs.** Run 7 reached
5 869.9 m unupgraded, past four of the six fully-upgraded attempts. The owner's
reading — *"upgrades mostly made it faster to play, not necessarily a lot
easier"* — is consistent with every number here, and is confounded by the L0 runs
being played last.

**A Burst-charge bound nothing watches.** `burst_cooldown` is 1.65 s against a
1.26–1.35 s chunk, and base `burst_charge_capacity` is 1. Two consecutive
Burst-demanding chunks are therefore unclearable at L0 — and [D-0057] raised
Bramble from "never two challenge chunks in a row" to runs of up to four. Not
binding today; the first thing to break if that density rises again.

Numbers, method and limits:
[`device verdict`](../docs/measurements/2026-08-03-device-verdict-on-the-curve.md).

## What I got wrong on the way

**I misread two death frames as finals.** The owner restarts instantly, so each
recording carries the opening of the next attempt at 8–50 m. I read `014.8 m` as
a broken HUD dropping a digit, measured glyph positions to "prove" it, and was
wrong — the format is zero-padded, and the giveaway was in the frame all along:
**no spider on screen.** The owner said it plainly before I got there.

**I built a digit classifier that did not work and nearly reported its output.**
Template matching decoded 15% of frames and emitted 99 003 m on a 15 km course.
Caught only because the values were absurd on their face; a subtler failure would
have gone into a document. Discarded and recorded as a wall.

## Close-out

**Evidence:**

- source: none. Documentation, the capability ledger, and this card.
- verify: `python3 tools/verify.py --require-godot` and
  `python3 bootstrap.py check --strict` both pass — nothing under `game/`,
  `tests/` or `tools/` moved.

**Decisions made:** none. Nothing here changes behaviour, and the one number it
argues about — Bramble's density — is left where [D-0057] put it.

**Next session should know:** the owner is recruiting external testers this week
because he wants opinions beyond his own, and says friends have not taken the
feedback seriously. **Before that lands, the highest-leverage work is making a
run report itself.** Everything in this document was extracted by hand from
video; that does not survive contact with ten testers. The game already records
deterministic input traces, and the attrition doc names one behavioural signal
with a predicted direction — **reel usage per kilometre over the first 2 km** —
that costs nothing to log and would have answered question 3 above directly.
Anything leaving the device is an owner call: consent, hosting and spend.

## 💡 Session idea

**Play data arrives as video, and video is the most expensive form of evidence
this project accepts.** Eight runs cost a folder download, 693 frame extractions,
a failed classifier and a long manual read, to produce eight numbers the game
already knew exactly at the moment of death.

The asymmetry is worth naming as a rule: **when the thing being measured is
already inside the program, instrument the program, never the recording.** A
death event carrying `{distance, cause, region, verbs_held, reel_seconds}` is
four lines and is exact; deriving the same four fields from a screen capture is
an afternoon and is approximate. Video keeps its own irreplaceable job — it shows
*how* something felt wrong, which no counter can — but it should be the second
instrument, not the first.

The moment this stops being a preference and becomes a blocker is the tester
recruitment above: one player's videos are readable, ten players' are not.

## ⟲ Previous-session review

Covered above under its own heading — all three device questions came back
answered, and the prose contract count was the one self-inflicted miss.

**Workflow improvement:** the previous card ended by naming three questions for
the owner and that is exactly why they came back answered in one sitting. **Keep
ending cards with a numbered, ordered list of what only the owner can settle** —
ordered by how much rides on it, so a short session answers the top one. It cost
three lines and turned an open-ended "please playtest" into three closed
questions with three answers.

- **📊 Model:** opus-5 · high · research
