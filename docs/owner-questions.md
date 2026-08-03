# Owner questions — open forks only

> **Status:** `owner-guidance`
>
> Genuinely owner-only decisions, consolidated so they are not scattered across
> session cards. Everything here is **parked, not blocking** — work continues
> under a stated default, and each entry says what that default currently is.
>
> Agents: add an entry only for a real product fork — branding, spending,
> publishing, or a choice where different answers mean materially different
> work. Routine technical calls are decide-and-flag, not questions.

## Open

One fork remains from the 2026-08-01 overnight systems run (OQ-9). Two
others (OQ-8, OQ-11) were **closed by owner device evidence the same morning** —
the lab audit behind them was wrong. **OQ-12 was answered the same evening** and
opened the earned-speed follow-ups OQ-13 … OQ-16. **OQ-17 was raised and
answered on 2026-08-03** — ship the curve's default slope and judge it on device.

### OQ-13 · What does *Quick Feet* become when the drive is gone?

**The problem:** `skitter_drive` (*Quick Feet*, `QUICK_FEET`) multiplies
`horizontal_drive_acceleration` (`game/domain/spider_catalog.gd:393-394`).
Removing the free forward drive makes it buy **nothing**. It is a named, priced
identity track on a shipped spider, so it cannot simply be left dead.

**Default:** it remains deliberately inert in the combined playtest, with an
explicit upgrade-audit exception, rather than being silently repointed before
the owner chooses its identity. Nothing is renamed, repriced, or presented as a
working benefit without an answer here.

**The fork:** which term. Release-momentum bonus, reel retraction rate, and
burst exit speed all read as "quick", and they produce genuinely different
spiders. That is a feel decision, not a measurable one.

### OQ-14 · Does the bird kill on contact, or stagger first?

**Default:** it kills, reusing the existing `camera_boundary` death path
(`game/simulation/simulation_world.gd:471-477`) — cheapest to build and
consistent with the invisible line it replaces. Build
`0.26.0-earned-speed-bird-playtest` implements this default; rescue restores the
configured bird gap after the first contact.

**The fork:** a non-lethal first contact (a stagger, a slowdown, a stolen fly)
softens the death spiral that earned speed plus an accelerating pursuer creates,
at the cost of making the bird less frightening. Worth deciding before the
visual work, because it changes what the bird has to communicate.

### OQ-15 · How fast does the bird start, and how fast does it accelerate?

**This one cannot be answered from the lab, and that is measured, not a
guess.** The bot now pumps (model v4, 2026-08-02), and it is still 26 m/s below
the reference curve in the warp band where the owner sustains 78.6 m/s — it
fails every pace acceptance target. Every bot number here is a **floor**, not a
target, and a bird tuned against it would be tuned against a player far slower
than the one this design is about.

**Default:** build `0.26.0-earned-speed-bird-playtest` ships `assumed` values of
300 px/s start speed, +12 px/s per 1,000 m, and 760 px start gap. Test Run
exposes all three directly and provides OFF (0/12/760), SLOW (240/8/900), BASE
(300/12/760), and FAST (380/20/600). These are comparison points, not claims
about correct tuning.

**The fork:** the values themselves, after one device playtest of a no-drive
build. No recording is needed — only a verdict.

### OQ-16 · Does earned release feel strong and legible, without becoming a tap engine?

**The problem:** headless contracts can prove which releases qualify and that
the award is deterministic and bounded; they cannot prove that a player feels
the connection between timing and speed on a phone, so the lab is explicitly not
a tuning instrument for this question. One piece of bot evidence is worth
putting in front of it rather than hiding: model v4 measured that **holding a
swing to collect the release award costs more than the award is worth** (−9%
distance at both tested arc gates). Whether a human faces the same trade is
exactly the device question.

**Default:** build `0.26.0-earned-speed-bird-playtest` uses an `assumed` 100 px/s
maximum award and an `assumed` 90° full-arc threshold. The release must be
forward, right of the anchor, and rising; falling, backward, forced-detach, and
near-zero-arc releases receive no meaningful award.

The combined build keeps those two assumed values and changes only the safety
ceiling to the run-wide maximum reference plus overspeed: 1120 px/s / 112 m/s
with current config. That ceiling is `inferred`, not a feel target.

**The fork:** keep, strengthen, weaken, or reshape those two assumed values after
one device playtest. No recording is needed — only whether good timing feels
rewarding and whether repeated shallow releases read as an exploit.

> **This verdict is now ready in the combined build.** The earlier deferral was
> added 2026-08-01 after
> slice 1 merged. Two mechanisms make the current build the worst possible
> place to judge this, and they compound:
>
> - **The drive erases the penalty.** A good release survives 4.4 s of airtime
>   at 0 m on drag alone, so the award is real — but a *bad* release costs
>   nothing, because the drive floors you at `target_speed` and rebuilds at
>   470 px/s. The good-vs-bad contrast is a fraction of what it becomes once
>   the drive is gone.
> - **The award's ceiling sits inside the band you already play in.**
>   `target_speed_at + maximum_horizontal_overspeed` is 72.0 m/s at 0 m and
>   76.2 m/s at 1 km; your standing-start L0 runs sustain ~73–78 m/s. For the
>   first kilometre the award may be near zero.
>
> A weak verdict gathered now would send someone tuning the 100 px/s value when
> neither the value nor the formula is at fault. **Test this together with the
> no-drive world and the bird in one session** — they ship as one build, and the
> bird's debug tunables let one sitting isolate all three.

### OQ-9 · Should Harsh pay a fly premium?

**Measured:** Harsh pays the same flies per minute as Standard (~46/min at
intermediate) while killing the player roughly twice as fast. Income is
~13 flies/km and near-invariant across every skill tier and both banking
modes, so difficulty is currently **economically invisible**.

**Default:** no premium. Harsh is chosen for preference, never for reward.

**The fork:** whether a harder course should pay for the shorter runs it
causes, and by how much. A multiplier is the obvious shape; the size is a feel
decision, not a measurable one.

## Answered

### OQ-17 · How fast should difficulty rise over the first 15 km? — *answered 2026-08-03*

**Ship the default and judge it on device.** Menno, the same day it was raised:
*"I think we should first test the default, this is a reversible action so it's
not bad if we get it wrong the first time."*

So `ONSET_SHAPE` stays **0.70** — a front-loaded ramp that climbs fastest between
roughly 2 and 5 km and eases off after 10 km, reaching about 41% of full pressure
at 5 km and 84% at 10 km. The phase that moves selection onto the curve exposes
it in the Test Lab; a verdict then replaces this one rather than reopening it.

The three spacing-floor constants (0.60 s learned, 0.8–1.0 s unlearned,
1.2–1.4 s with swing correction) ride the same build and stay `assumed` until
content actually uses them.



### OQ-10 · Is a ~21-minute upgrade economy the intended length? — *answered 2026-08-02*

**No.** Every one of the 35 upgrade tracks now has forty smaller levels. Each
numerical step is 70% of its former size, while the eight breakthroughs make
the L40 total 140% of the old L20 maximum. Costs total 490 flies per track,
3,430 per spider, and 17,150 for all five. At the historical **measured**
~46 flies/min income this is an **inferred** ~74.6 minutes per spider or ~6.2
hours for the roster; current-device economy pacing remains to be measured.

### OQ-12 · Which anti-hauling mechanic should ship? — *answered 2026-08-01*

**Both halves of the owner's own proposal, as one package: remove the free
forward drive, and add the bird.** He confirmed it directly — *"stop the forward
motion that the game gives you, so only swinging itself makes you go forward"* —
and extended it: the difficulty ramp moves from the pace curve into player-earned
speed, through *"upgrades, swing control, reel and burst timing"*.

The measurement supports it precisely: ablating the drive costs the intended
style a third and destroys hauling outright (−98%), and in a world searched
inside the no-drive rules **wide swinging wins outright**. The intended style
becomes optimal by physics rather than by prohibition.

Specified in
[`game-design/earned-speed-and-the-bird.md`](game-design/earned-speed-and-the-bird.md).
It opened OQ-13, OQ-14 and OQ-15, which are the parts the measurement could not
settle.

### OQ-8 / OQ-11 · Are the upgrade tracks weak, inert, or harmful? — *answered 2026-08-01*

**No. They are fine, and the simulator was measuring itself.** The owner
reports that max upgrades play far better than none, and that a previous
session had already established the simulator does not adjust correctly for
upgrades.

The mechanism was then identified in code: the bot's Reel policy is expressed
entirely in fractions of the meter, so scaling capacity scales both sides and
it behaves identically — Silk Reserve's real 2.00 s → 2.48 s gain in continuous
reel time is invisible to it. The audit's supporting premise, "the Reel meter
never empties", was circular: the bot stops reeling at 6% remaining.

**Consequences applied:** the shop suspension was reverted, the audit document
carries a superseded banner, and `docs/technical/simulation-lab.md` now states
plainly that the lab must not be used to evaluate upgrades. Nothing was ever
retuned, which is the one thing that went right.

### OQ-6 · Difficulty modes, campaign shape, rewards, and audio sourcing — *answered 2026-07-31*

Four product directions, settled ahead of the work so a future session does not
guess. Reasoning and constraints live in the decision ledger.

- **Campaign purpose: both, staged.** Early levels teach one mechanic each;
  later levels combine them into challenges. Build the teaching tier first —
  attempting both at once tends to do neither well.
- **Difficulty and records: separate best per mode; only Standard competes.**
  Relaxed and Harsh each keep their own best distance so progress still feels
  real, but only Standard is eligible for a future leaderboard.
  **Superseded 2026-08-03:** every records-eligible mode now gets its own board,
  and Relaxed's rails become lethal so it qualifies. The separate-best-per-mode
  half of this answer stands unchanged.
- **Campaign rewards: cosmetics and stars only, no flies.** Campaign levels are
  fixed-seed and repeatable, so paying currency would make them the optimal
  farm and force an endless-economy rebalance.
- **Audio: generated SFX, CC0 ambience and music.** Generate the spider and web
  sounds where set consistency matters most; source ambience and music where
  quality is harder to synthesise. Every CC0 file's licence is verified per file
  and recorded in the manifest. **Superseded for the first soundtrack on
  2026-08-02:** the owner's direct request to create the haunted score is
  implemented as original deterministic synthesis under D-0043; future sourced
  ambience still requires per-file CC0 verification.

### OQ-7 · Who merges — *answered 2026-07-31*

**Agents merge their own work once green.** The owner does not review diffs; he
reviews the running build. This was already the working agreement — agents
"land or clearly park their own PRs" — and is restated here because a session
asked him to gate a merge, which is not his job. Consequence worth holding
onto: with no human diff review, contracts and CI are the entire safety net, so
claims must be measured rather than asserted.


### OQ-2 · Should the Field Guide be reachable from Home? — *answered 2026-07-31*

**Yes — its own button on Home, for discoverability.** It stays reachable from
the Garage too, and now remembers which route the player took so BACK returns
there instead of always landing in a Garage they never opened.


### OQ-1 · Should Skitter and Buckler take real spider names? — *answered 2026-07-31*

**Rule:** use the real name when a spider is real and has a usable one. When it
does not, invent a good name — and the Field Guide then names the scientific
name(s) the profile draws its abilities from, including when several real
spiders each contribute one part.

- **Skitter → Magnolia Green Jumper.** *Lyssomanes viridis* has a usable common
  name, so the invented one had no justification.
- **Buckler stays Buckler.** *Cyclocosmia* has no settled English common name a
  player would recognise, and the profile blends two genera. Its guide entry now
  names both, with what each contributes.


### OQ-3 · Springtail's name — *answered 2026-07-31*

Renamed to **Buckler**. Recorded in the decision ledger. (Superseded in part by OQ-1, which
re-opens whether the replacement should be a real spider rather than an invented
one.)

### OQ-4 · Who approves scientific and medical claims before publication — *answered 2026-07-31*

**Agents verify against trustworthy sources — World Spider Catalog,
peer-reviewed papers, museums, health authorities — and that is sufficient.** No
separate human approval gate. Recorded in the decision ledger — see the biology folio for the
reasoning.

### OQ-5 · Image licensing — *answered 2026-07-31*

**Generated in-house, or unencumbered.** Public-domain/CC0 verified per file, or
owner-produced. Anything needing attribution, share-alike, or per-use permission
is avoided rather than negotiated. Reasoning lives in the biology folio.
