# Difficulty curves for a fast procedurally-composed physics runner — external research, 2026-08-02

> **Status:** `reference`
>
> An owner-supplied **ChatGPT Deep Research** report, commissioned specifically
> to pressure-test
> [`difficulty-and-obstacle-doctrine.md`](difficulty-and-obstacle-doctrine.md)
> before any generator code moves. Written in Dutch; synthesised here in English
> with its own evidence grades preserved.
>
> **Nothing here is a decision, and nothing here is measurement.** It is
> external evidence about how other games and studies behave. Where it disagrees
> with a `measured` finding in the doctrine, **the measurement wins** — the same
> precedence this repository uses for source over prose.

## ⚠ Provenance — read before quoting anything

| Property | Assessment |
| --- | --- |
| **Class** | `inferred` — third-party synthesis, same evidential class as the Session A research in [`../product/upgrade-and-difficulty-research-2026-08-02.md`](../product/upgrade-and-difficulty-research-2026-08-02.md) |
| **Citations** | The report carries inline citation tokens (`citeturn16view0` and similar). **These are the research tool's internal anchors and do not resolve from this repository**, so the underlying sources are named but not independently verified here |
| **What raises its weight above the earlier synthesis** | It names specific primary sources (Saltsman on *Canabalt*, Valve's *Left 4 Dead* director-commentary, Hayashida on *kishōtenketsu*, Thorson's *Celeste* forgiveness list, Yu on *Spelunky*), reports study sizes and effect sizes rather than round numbers, **grades its own evidence strength per section**, and closes with an explicit *"where the evidence is thin or absent"* section |
| **What it is still not** | Verified. No claim below has been checked against a primary source from this seat. Treat every external number as reported, not established |

**The self-assessed weakness section is the most valuable part of the report**
and is reproduced in full at the end. A report that names what it could not find
is a much better instrument than one that does not.

---

## 1 · What it corroborates — independent agreement with what we measured

These are the cases where the report arrives at a conclusion this repository had
already reached by a different route. **Independent agreement is not proof**, but
convergence from a different instrument is worth recording.

### 1.1 Corridor width is a protected error margin — agrees with F8

The report's recommendation is almost word-for-word the doctrine's F8 and the
owner's own O2 verdict:

> *"Treat corridor width as a protected error margin, spend most extra pressure
> on decision density and timing, and never combine strong narrowing with a new
> mechanic or an immediate opposite commitment."*

Its reasoning is mechanical and matches ours: higher density raises the number
of decisions and execution demands per second, but a wide corridor **preserves
alternative trajectories, correction opportunities, and the chance that one bad
swing is not immediately fatal.** Narrowing removes states from the survival
space — when a gap is only a few player-widths, perception error, pendulum
phase, touch timing and collision margin can all produce the same binary
failure.

**Evidence grade (the report's own):** strong for forgiveness techniques as
shipped practice; **weak** for the specific comparison. It states plainly that it
found **no controlled study** comparing "high density + wide" against "low
density + narrow". So this corroborates our reasoning; it does not prove it.

### 1.2 The T-coupling in O3 — reached independently

The doctrine's O3 derived that **spacing floor `T` is not one number but a
function of local predictability** — a known route is executed, an unknown one is
read, and R13/R14 are the same knob seen from two sides.

The report reaches the same structure from reaction-time literature without
having seen that derivation: a known beat lets anticipation begin *before* the
formal window opens, so 0.60 s can work as an expert *execution* window, while an
unlearned choice cannot use anticipation at all. **Two different instruments,
same coupling.**

### 1.3 Constrained randomness with a pattern library is the norm

*Canabalt* teaches recurring kinds of buildings, gaps and obstacles while
avoiding a fixed level order — Saltsman's stated goal being that randomness "gets
you in this crisis-management state of mind". *Sure Footing* formalises the
middle position with **action grammars**: choose the desired sequence of actions
first, build geometry for it second, with rules preventing unwanted transitions
and forbidding the same action twice in a row. *Spelunky*'s generator and the
player's tools were designed together, so randomness may produce hard situations
because fixed system rules keep the exits and their costs legible.

This is what the doctrine already proposes. The report adds that there is **no
known universal optimum** — no "60% predictable / 40% random" figure exists, and
appropriate entropy depends on sight distance, available recovery actions,
failure penalty and how much state must be read at once.

### 1.4 The section-entry ramp has an established name

Teach → test → twist, or Nintendo's four-part *kishōtenketsu* (introduction,
development, unexpected variation, closing demonstration of mastery). Hayashida
on *Super Mario 3D Land*: *"First, you have to learn how to use that gameplay
mechanic,"* then a slightly more complex application, then a twist, then a
mastery moment. **Evidence grade: strong** as an established level-design
pattern — but only **indirect** evidence that it works mid-run in a procedural
endless context.

---

## 2 · What it sharpens — new constraints and numbers we did not have

### 2.1 Reaction windows — this settles the numeric half of O3

The single most directly usable section. Its core argument is that a laboratory
reaction time is **not** the same as the time to read a route and execute an
opposing movement in a physics game: the lab task measures time to *begin* a
button response to a known stimulus-response mapping, while our window also
contains detection, classification, choice, touch input, pendulum phase, and
enough physical displacement to matter.

| Finding | Value | Source as reported |
| --- | --- | --- |
| Simple visual reaction time | ≈ **253 ms** | n = 100 young adults |
| Four-choice reaction time | ≈ **369 ms** | same study; *"simple VRT is shorter than choice reaction time"* |
| Effect of a second choice | **+50%** response time | CHI PLAY, n > 150 |
| Effect of three choices | **≈ 2×** versus one choice | same |
| Target size and distance | *"substantial effects"*; self-reported gamer skill had only a small effect | same |
| Pattern learning | Response times decrease significantly under both explicit and implicit learning | serial-reaction-time experiment; **no transferable millisecond figure for games** |

**The arithmetic that matters for us.** Subtract ≈ 0.37 s of choice-reaction time
from a 0.60 s window and roughly **0.23 s remains** for screen and touch latency,
pattern interpretation, pendulum dynamics and actual displacement.

> **The report's recommendation:** reserve **0.60 s** exclusively for
> **pre-learned and well-telegraphed expert beats**; use **0.8–1.0 s minimum**
> for an *unknown* opposite-side choice; use **1.2–1.4 s** where significant
> swing correction is also required.

It labels its own 0.8–1.0 s a **conservative extrapolation, not a published
mobile standard**, and its "where evidence is thin" section repeats that it found
no publicly audited timing dataset from shipped mobile runners.

**What this means for our two numbers.** Our normal chunk window is **1.37 s** —
the report explicitly calls a window of that size *"substantial room for choice
and correction"*. Our weave's **0.60 s** between its two commitments is the
problem, and only when the pattern is unlearned. That is precisely the
predictability coupling in §1.2.

### 2.2 Pressure is not additive — the axis budget needs re-framing

**This is the report's most substantive correction to the doctrine's model.**

The doctrine's §4 says a region declares an **axis budget** and that at the
plateau every region *spends the same total on different axes*. The report's
verdict on that shape:

> `pressure ≠ density + narrowness + timing + unpredictability`

Its objection is interaction, and it is concrete: a point of corridor narrowing
is **not** equivalent to a point of extra density. Narrowing can be mild at low
speed with a known pattern and extreme when it coincides with a new required
verb, a vertical reversal and short telegraphing.

> **What it proposes instead: an *envelope with interaction rules*.** The
> monotone scalar decides which *profiles* are admissible at a distance at all.
> Each axis additionally carries **its own caps, slope limits and cooldowns**.
> **Combination rules explicitly forbid** e.g. maximum narrowness coinciding with
> maximum novelty and minimum reaction time. The scalar stays an orchestration
> instrument without pretending the axes are fungible currency.

It also notes the scalar remains excellent for **regression tests and content
authoring** — every chunk gets a vector, every region a target profile, every
kilometre an allowed envelope — and that comparisons should look at **maxima,
consecutive exposure and interaction terms** (`density × narrowness`,
`novelty × required_verbs`), not only at means.

**Evidence grade:** strong for multidimensional level metrics; **absent** for any
validated conserved difficulty budget. The report is not claiming our budget is
wrong — it is claiming nothing validates it, and that the envelope framing costs
nothing and survives the interaction problem.

### 2.3 Local waves must not lower the floor — and how that meets our ramp

Valve's *Left 4 Dead* commentary is the clearest shipped prior art for
deliberate oscillation: *"Constant, unchanging combat is fatiguing"* while long
inactivity is boring, so the system alternates build-up, peak, fade and relax.
The crucial distinction, verbatim:

> *"Amplitude (difficulty) is not changed, frequency (pacing) is."*

*Canabalt* independently averages **≈ 10 s of ordinary rooftops** between special
crisis elements, and its speed ramp decelerates as it rises — Saltsman:
*"Basically, the faster you go, the slower you speed up."* That is a
ramp-to-plateau, not unbounded linear escalation.

**The report's recommendation is explicit that local waves should not be large
regional fallbacks.** Read naively, that is in tension with the doctrine's
section-entry ramp, which opens each region with 100–150 m of open space.

**The resolution — and it is a genuine refinement rather than a contradiction.**
The same report *also* recommends reserving a seed-independent teach–test–twist
sequence at the start of every region. Both recommendations hold simultaneously
only if the section-entry ramp is an **axis-local reset, not a global one**: the
entry lowers *novelty* and *width* pressure for the mechanic being introduced,
while the monotone base pressure from §4 keeps rising underneath it. That is
exactly the multi-axis envelope of §2.2, applied to the section boundary.

**This is the sharpest single change the report suggests to the plan**, and it is
recorded as a proposal, not a decision.

### 2.4 A safe introduction that still kills teaches distrust, not the mechanic

A concrete, checkable constraint the doctrine did not state:

> A "safe" introduction that is nonetheless lethal — through high speed, a poorly
> visible entrance, or **simultaneous bird stress** — does not teach the
> mechanic; it teaches distrust. The first encounter must use the **same
> perceptual language, the same collision rules and the same required movement**
> as later variants, with only **one** generous error margin.

The bird clause matters: our pursuer is an independent pressure source that does
not know a teaching chunk is in progress.

### 2.5 Do not ceremonially introduce every obstacle

The largest relevant tutorial study — eight tutorial variants across three games,
**> 45 000 players** — concluded that *"the usefulness of tutorials depends
greatly on game complexity."* In the most complex game, tutorials raised playtime
by up to **29%**; in two simpler games there was **no significant engagement
gain**.

So the teach treatment should be spent where a mechanic genuinely requires new
interpretation or new input — not on every new visual silhouette.

### 2.6 Give every recognisable beat two to four legal continuations

The report's concrete answer to the predictability question, and a number the
doctrine lacked:

> *"Keep handmade chunks, give every recognisable beat two to four legal
> continuations, and impose cadence, transition and telegraphing rules on the
> chaotic region, so players can predict categories without memorising exact
> routes."*

It reads our two extremes exactly as F7 does — Bramble's memorisable four-beat
loop carries too little conditional uncertainty, and Ancient Forest's fully
seed-driven region offers too little rhythmic compression — and it explicitly
warns against **pulling both to the same mean**. The prescription is to move
their *grammars* toward each other: several legal variants per recognisable
cadence.

---

## 3 · Calibration with one tester and no competent bot

The section most directly useful to how this project actually works.

**On the bot.** Use it *only* for properties its behaviour genuinely covers:
determinism, seed reproducibility, chunk connectivity, collision leaks,
theoretical route availability, extreme geometric values. Research on procedural
personas positions them as models of **pre-chosen play styles**, not as
guaranteed human skill measurements — *"an agent that does not use the core verbs
mostly measures its own policy errors."* This is the same conclusion
[`../technical/simulation-lab.md`](../technical/simulation-lab.md) already
enforces as a publication ban, arrived at independently.

**On the single expert tester.** The owner's own death-distance curve is
*severely* biased by memorisation, specialist technique and continuous skill
growth. But he can be used effectively for **relative, blinded comparisons**:

> Have tooling present two or more profile variants under **neutral seed codes**,
> play them in **randomised order**, and compare successes, near-misses and
> subjective readability **only after** the variant identity is revealed.

That does not estimate median player performance — it removes confirmation bias
from design decisions. **This is a new and directly actionable idea for this
project.**

**On external testing.** A **rolling small-N** process beats one broad beta: a
few players per iteration from at least three experience bands — little
experience with momentum games, competent action players, and one or more
specialists in swing/speedrun/precision-platform games. Use them to **find
different failure modes**, not to compute one average difficulty.

**On telemetry — this specifies our Phase 0.** The most useful instrument is a
**survival model per distance**:

- Report, per chunk / pattern / region, **how many runs enter alive and how many
  fail there.**
- Use **hazard** — deaths divided by the number of runs that *actually reached*
  the point — **never raw death counts.**
- **Separate first exposure from later exposure**, because pattern learning
  otherwise simulates a difficulty improvement.
- Separate **quits** from physical deaths; report **medians and percentiles**
  beside means.
- Log at minimum: entry speed, seed, pattern ID, corridor width, time to next
  commitment, required verb, last input, cause of death, and **whether the player
  has seen this exact pattern family before**.

**On geometric proxies.** Minimum corridor in player-widths, commitment time,
sight time, required vertical displacement, number of directional reversals,
route count, recovery distance and novelty are all useful **so long as they are
not called "difficulty"**. Their function is regression detection and
stratification of playtests. An A\*-based difficulty metric is cited that
correlated with existing estimates in one domain and had problems in another —
automated difficulty metrics are domain-dependent.

---

## 4 · Where the evidence is thin or absent — the report's own words

Reproduced because it is the padding check, and because every item below is a
place where our own measurement is the *better* evidence.

- **Ramp shape:** no controlled study found comparing continuous ramps,
  ramp-to-plateau and deterministic oscillation on retention or enjoyment for
  2–5 minute runs. The recommendation rests on shipped postmortems, pacing
  research and extrapolation.
- **Mechanic introductions:** teach–test–twist and *kishōtenketsu* are well
  documented, but there is **no direct evidence that players consciously
  recognise a recurring promise** that new mechanics appear safely first, or that
  such a promise raises later acceptance of death.
- **Predictability:** no known universal optimum between memorisability and
  randomisation, and no validated entropy measure predicting perceived fairness
  for fast runners.
- **Error margin:** no controlled comparison of high obstacle density in a wide
  corridor against lower density in a narrow one.
- **Reaction windows:** no publicly audited timing dataset from shipped mobile
  runners relating minimum choice windows to speed, sight distance, touch input
  and required physical displacement. The proposed 0.8–1.0 s is a conservative
  extrapolation from reaction-time research.
- **Multi-axis budgeting:** multidimensional metrics exist; a validated model in
  which density, corridor width, timing, predictability and required verbs can be
  safely traded as one conserved point-sum **does not**.
- **One tester:** there is **no reliable method** to derive a median or
  population-wide difficulty curve from a single very experienced player, and a
  bot without the relevant movement verbs cannot replace that missing human
  sample.

---

## 5 · What this does *not* license

Stated explicitly, because a confident report is the easiest thing to over-apply.

1. **No physics, course, bird or upgrade value may change because this document
   recommends it.** Every number in it is external and most are extrapolations.
2. **It does not lift the simulation-lab publication ban.** It independently
   argues *for* that ban (§3).
3. **It does not settle O3's constants.** It bounds them and confirms their
   structure; the constants remain the owner's reaction time on his own device.
4. **It does not override F7.** Our finding that the most predictable region is
   where the owner is fastest is `measured`; the report's contribution is the
   prescription (2–4 legal continuations), not a contradiction of the finding.
5. **Adaptive difficulty stays ruled out.** The report is clear that Valve's
   Director is adaptive and *"therefore unsuitable for your generator"* — it
   recommends applying the *principle* deterministically, which is what the
   doctrine already does.

## 6 · What changes in the doctrine

Recorded here so the diff to
[`difficulty-and-obstacle-doctrine.md`](difficulty-and-obstacle-doctrine.md) is
traceable. All three are **proposals for the owner's analysis**, not decisions.

| # | Change | Where |
| --- | --- | --- |
| 1 | The axis **budget** becomes an axis **envelope**: per-axis caps, slope limits, cooldowns and explicitly forbidden combinations, rather than a fungible point-sum | §4, R4 |
| 2 | O3 gains external bounds — 0.60 s for learned beats only, 0.8–1.0 s unlearned, 1.2–1.4 s with swing correction — and its coupling is independently confirmed | O3, R13 |
| 3 | The section-entry ramp is an **axis-local** reset, not a global drop; and the teaching chunk must survive bird pressure and use the same collision rules as later variants | R12 |
