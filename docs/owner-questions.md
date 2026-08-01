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

Four forks opened by the 2026-08-01 overnight systems run. Each is measured,
each has a stated default, and none blocks further work.

### OQ-8 · What should the two inert upgrade tracks become?

**Measured:** Silk Reserve (Reel capacity) and Rapid Recovery (Reel
regeneration and empty-lockout) change the resolved config and produce
**bit-identical** play at every skill tier, because the Reel meter never
empties in any band, mode or reel style. They were 29% of the total upgrade
spend — 282 of 987 flies — for zero measured effect.
See `docs/measurements/2026-08-01-upgrade-audit.md`.

**Default the work proceeds under:** both tracks are **withdrawn from sale**.
Levels already bought stay bought and still apply; ids stay valid; the shop
says why. This is a holding position, not an answer.

**The fork:** repoint them at an effect that binds, retire them, or make the
Reel meter bind (which means moving owner-approved physics — capacity or drain
— and is why no session has done it). Different answers mean materially
different work.

### OQ-9 · Should Harsh pay a fly premium?

**Measured:** Harsh pays the same flies per minute as Standard (~46/min at
intermediate) while killing the player roughly twice as fast. Income is
~13 flies/km and near-invariant across every skill tier and both banking
modes, so difficulty is currently **economically invisible**.

**Default:** no premium. Harsh is chosen for preference, never for reward.

**The fork:** whether a harder course should pay for the shorter runs it
causes, and by how much. A multiplier is the obvious shape; the size is a feel
decision, not a measurable one.

### OQ-10 · Is a ~21-minute upgrade economy the intended length?

**Measured:** maxing Classic's seven tracks costs 987 flies — 45 runs, about
**21.5 minutes** of intermediate play. That is the game's only long-term sink.

**Default:** prices are left exactly as they are.

**The fork:** if that is too short, the fix is **more sinks**, not higher
prices — raising costs makes the same twenty minutes feel slower without adding
anything to reach for. Adding sinks is a design decision about what else is
worth wanting.

### OQ-11 · Do Silk Winder and Anchor Drive feel good on a device?

**Measured:** both are negative at every skill tier and positive at none — Silk
Winder −4.3 / −10.4 / −3.2%, Anchor Drive −0.7 / −6.2 / −11.8% by tier. But
magnitudes swing with tier, these are bot-preference results, and the lab has
already disagreed with a device finding on exactly the Reel-rate axis.

**Default:** **nothing was retuned.** Both tracks ship unchanged.

**The fork:** this one only you can settle, because it is a feel question. If
they feel good in the hand, the bot is wrong and the tracks stay as they are.
If they feel as bad as they measure, the numbers are worth revisiting — but on
device evidence, not lab evidence alone.

## Answered

### OQ-6 · Difficulty modes, campaign shape, rewards, and audio sourcing — *answered 2026-07-31*

Four product directions, settled ahead of the work so a future session does not
guess. Reasoning and constraints live in the decision ledger.

- **Campaign purpose: both, staged.** Early levels teach one mechanic each;
  later levels combine them into challenges. Build the teaching tier first —
  attempting both at once tends to do neither well.
- **Difficulty and records: separate best per mode; only Standard competes.**
  Relaxed and Harsh each keep their own best distance so progress still feels
  real, but only Standard is eligible for a future leaderboard.
- **Campaign rewards: cosmetics and stars only, no flies.** Campaign levels are
  fixed-seed and repeatable, so paying currency would make them the optimal
  farm and force an endless-economy rebalance.
- **Audio: generated SFX, CC0 ambience and music.** Generate the spider and web
  sounds where set consistency matters most; source ambience and music where
  quality is harder to synthesise. Every CC0 file's licence is verified per file
  and recorded in the manifest.

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
