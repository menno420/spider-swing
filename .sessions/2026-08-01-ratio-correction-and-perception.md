# A ratio read without its denominator, and what the model can actually see

> **Status:** `complete`

## Goal

Answer two owner questions about the simulations — what they tell us and how
far to trust them — and correct what the answers exposed.

## Scope guard

Documentation only. No code, no measurement re-run, no tuning.

## Previous-session review

**previous-session review:** #92 landed the upgrade sweep, the first fair-play
verdict, and the external-review audit. The owner then asked how trustworthy
the simulations are, and mentioned two impressions of the runs he watched.
Both impressions turned out to be worth checking; one was my error and one was
his, and his was caused by my wording.

## The correction

I wrote that the flagged 10 773 m run **"abandoned Dive"**, from
`dives_per_attach` falling 0.96 → 0.28. The owner read that and asked how it
could possibly handle the course without diving. It cannot, and it did not:

| | endorsed | flagged |
| --- | ---: | ---: |
| Dives per run | 13.1 | **36.2** |
| Dives per second | 0.60 | 0.37 |
| Webs per second | 0.63 | **1.34** |

It dives nearly **three times as often per run**. The ratio collapsed because
its *denominator* doubled — web attaches went to 1.34 per second — not because
diving stopped. **I read a ratio without reading its denominator and described
a verb as abandoned when its absolute count had tripled.**

The genuinely unusual thing about that run is the web rate, and only that.
Corrected in the sweep measurement and in current-state.

## What the model can actually see

The owner watched the endorsed traces and read them as *"the simulation
recognized the obstacles and did its best to avoid them."* They do look like
that. **The bot never reads `world.obstacles`.**

Its entire perception: own position and velocity, the fly trail, the
nearest-solid query at an aimed tap, and the HUD's own pull-safety preview.
A path lookahead that did read obstacles was built and deleted the same day
for measuring worse.

So the apparent avoidance is **emergent from following the authored fly
trail** — a finding about the level design, not the model: the fly route is
good enough that following it competently keeps a player clear. It also
explains the model's one real weakness, since 95% of its deaths are obstacle
collisions and the trail is all it has when the trail is not enough.

Recorded in `docs/technical/simulation-lab.md` § "What the model can actually
see", with the standing warning: **do not read intent into a replay.**

## The trust answer, as given

- **Trust** comparisons holding one policy constant across configurations —
  confounds cancel, and that is where the upgrade findings come from.
- **Do not trust** absolute difficulty numbers, or anything about the reel.
  That gap is now vivid rather than abstract: the bundled 97-second,
  640-command trace contains **9 reel presses**, against an owner who taps
  reel about once a second and empties the meter repeatedly at L0.
- **Undecided** until watched: anything from the flagged web-spam policy.

## Verification

`python3 tools/verify.py --require-godot` → exit 0, 181 contracts.
`python3 bootstrap.py check --strict` → exit 0. Documentation only.

## Owner questions

None new.

## 💡 Idea

Both errors today were the same error at different scales. Comparing
best-per-configuration searches let *search luck* masquerade as an upgrade
effect; quoting `dives_per_attach` let a *denominator change* masquerade as a
verb being abandoned. In both cases a normalised number was reported as if it
were an observation. **A ratio is a claim about two things; state both, or
state the absolute count.** The near-miss reporting added earlier has the same
shape and the same fix.

## Next slice

Unchanged: the owner's judgement on
`lab-flagged-webspam-standing-l20.json`. His observation that the endorsed
runs read as genuine play — and the correction that the flagged run dives
*more*, not less — makes "legitimate high-frequency style" a live possibility
rather than the exploit I framed it as.
- **📊 Model:** opus-5 · high · docs-only — ratio correction and perception note
