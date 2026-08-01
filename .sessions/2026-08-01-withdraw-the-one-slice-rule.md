# A slice boundary that hands someone an untestable build is a delay, not a boundary

> **Status:** `complete`

## Goal

Undo the sequencing error in my own brief. The drive removal and the bird now
ship as one testable whole, with a prompt that says why.

## Scope guard

Documentation and planning only. No code, no physics values.

## Previous-session review

**previous-session review:** the last card found that slice 1's feel verdict was
unavailable while the drive was on, and correctly deferred OQ-16. It stopped one
step short. It fixed the *verification* order and left the *slicing* intact,
when the slicing was the thing causing the problem. This card finishes it.

## What the owner said

> *"This is genuinely a mistake that does cost me valuable time, I could have
> already tested this if it did these things as one pr instead of separate
> tasks, and now it could have been focusing on creating the bird correctly…
> Based on the eventual result I think I would have achieved more by just
> sending the instructions I told you directly to chat gpt."*

He is right, and his counterfactual is credible. The GPT session produced 26
files and 2 150 lines in 54 minutes. Pointed at the drive and the bird, it would
plausibly have delivered both.

**What it did produce is good, and verified — the output is banked, not
wasted.** Independently re-run here: 184/184 contracts; `release_quality` called
in exactly one place so forced detach genuinely earns nothing; `spider_motor.gd`
absent from the diff so the drive is genuinely untouched; the tuning constants
marked `assumed` **in the source** with the reason (*"the bot cannot pump, so it
is not a tuning instrument"*); and a second-order consequence caught that the
spec missed — changing authoritative physics invalidates the bundled replay
traces — then versioned rather than papered over. The owner cannot read a diff,
so it is worth stating plainly: that slice is sound and stays.

**What was lost was a day of ordering, not a day of work.**

## The error, named precisely

**I imported a cadence from a document I had myself just superseded.** The old
recording-led handoff spaced slices one device verdict apart because each visual
change needed the owner to *look* at it. The moment he said no new recordings
would be supplied and the work went headless, that premise was gone. I carried
the rhythm across anyway and wrote *"one slice, one green PR — do not combine"*
into the prompt as a rule.

**And I reordered his priorities.** He asked for the bird and for speed to
become earned. Release quality was *my* find in the code — real, and genuinely
a debt the tutorial had been promising — but I promoted it ahead of both things
he named. He received a mechanic he did not request and cannot test, and neither
of the two he did.

The prep's *content* held up: `CourseMotion` being unusable, `target_speed_at`
load-bearing in six places, Quick Feet dying. The GPT session used all of it.
**The sequencing destroyed more than the findings saved.**

## The design reason to combine, which is the stronger one

This is not only "combine to go faster".

**Removing the drive without the bird produces a game that is only harder.**
The drive is what makes stalling impossible today. Without it,
`left_kill_boundary()` — `furthest_x − 520 px`, ratcheting — becomes a live
failure mode with nothing on screen explaining it. `measured`: 4 of 10 bot runs
time out at drive zero, and `camera_boundary` appears as a death cause.

The bird is not decoration on that. **It is what makes the no-drive world
legible** — an invisible ratcheting line becomes a visible pursuer whose
distance states how much slack you have. Shipping the drive removal alone would
have produced a misleading feel verdict for precisely the reason slice 1's
verdict is unavailable: a mechanic judged in a configuration built to make it
feel bad. That would have been the same mistake, one slice later.

**Attribution survives the merge.** Bird speed, acceleration and start offset
are debug tunables; bird speed zero isolates the drive change, and the drive is
one config value. Two knobs, four combinations, one build.

## What shipped

- The one-slice rule struck through and **withdrawn** in the brief, with why.
- Slices 2–4 collapsed into one section, "The current work", with internal build
  order, the six coupling sites, the bird's two-axis movement law, the
  bird-like-motion requirements, and the do-not-tune-from-a-bot rule.
- A new paste-ready prompt covering both, written to say *why they ship
  together* rather than just what to do.
- The spec's build order corrected with the rule that replaces the old one.
- OQ-16 retimed to one session covering all three.

## Verification

`python3 tools/verify.py --require-godot` → exit 0, **184 contracts**.
`python3 bootstrap.py check --strict` → exit 0. Documentation only.

## Owner questions

None new. OQ-13 → OQ-16 unchanged in substance; OQ-16's timing now points at
the combined build.

## 💡 Idea

**"Small PRs" and "testable increments" are not the same rule, and I conflated
them.** A small PR optimises for review and revert. A testable increment
optimises for someone being able to form an opinion. When the reviewer is CI,
small wins. When the reviewer is a person with one device session a day, the
unit is *whatever produces a build they can have a reaction to* — and a
boundary that hands them something they cannot react to is pure latency.

The generalisable rule: **the slice boundary belongs where the feedback is, not
where the code is.** Worth proposing to substrate-kit with the two earlier
brief-template ideas; all three are about the same document and the same
failure of writing plans for the writer rather than the reader.

## Addendum — the prompt is now time-boxed

Same slice, added minutes later. The owner said he intends to run this tonight
and take a few runs before sleeping. That changes what a good outcome is: **an
installable APK beats a perfect PR.**

The prompt now states the priority order (drive → bird simulation → a bird
visual that is correct rather than polished → exploit regression) and says
explicitly which item to **drop** if the session runs long: the
exploit-regression search, because it is measurement rather than gameplay and
can follow tomorrow. It also names the one thing that must **not** be dropped —
the debug tunables — because without them he cannot isolate the two changes, and
that isolation is the entire reason they were allowed to ship together.

It closes by asking for the two lines he actually needs: which Actions run holds
the APK, and what to change on the Test Run screen to try bird-off, bird-slow
and bird-fast.

## Next slice

**Drive → 0 and the bird, one PR.** Prompt is in the brief, ready to paste.

- **📊 Model:** opus-5 · high · idea/planning — withdraw the slicing rule, re-cut the work
