# Name status — "Spider Swing" is a codename

> **Status:** `owner-guidance`
>
> Tracks GDD § 25 decision 7 (release name and brand identity) and the codename
> warning at the head of `docs/game-design/Spider-Swing-GDD-v2.0.md`.

## DECIDED, 2026-08-05: the game is **Slingy Spider**

**Owner decision. This is the release name.** 13 characters, inside Play's
30-character limit.

It was rejected earlier the same day by this repository's own research, on three
grounds. All three were subsequently **retracted against evidence**, and the
retraction is recorded here because the reasoning failure is more instructive
than the conclusion:

| Objection raised | Why it was dropped |
|---|---|
| "Sling" names the wrong mechanic — this is a pendulum, not a slingshot | **A person who had only watched gameplay independently generated the name "Slingy Spider".** Others endorsed the fit. That is the mechanic-inference test passed empirically; the objection was armchair semantics and lost to observed human behaviour. |
| Confusable with **SLINKY** (live US mark, genericised) | The owner's Play Store search — captured on video — shows Play offering **no "did you mean"** and no correction toward "slinky". Nobody who saw or heard the name misread it. The concern had no empirical support at any point. |
| The `[sling]+[spider]` namespace is saturated and mistrained | **Measured wrong.** Play's results for "slingy spider" are dominated by **Spider Solitaire** (~15 of 52 results; Play's own related-search suggestion is *"spider solitair classic"*), not by superhero titles. Direct competitors are negligible — Spider Swinger delisted, **Spider Swinger 2 at 10K+ installs**, Spider Swing 3D rated 3.6. |

### Where the name actually came from

Provenance, because this is the evidence that overturned the research and it
should not decay into "someone liked it":

**Discord, 2026-07-30, ~10:20–10:23.** The owner posted a single gameplay clip —
the real game, `RUN ENDED` on screen, `REEL` and `ATTACH` controls visible,
987.7 m distance. A friend who had never seen the project responded *"You made
that??"*, *"On what PC?"*, *"That's cool man"*, then — on learning it was a
phone-made mobile game — *"Upload to Google play bro"*, *"Flappy bird"*.

His next message was **"Slingy Spider"**. It drew a 🔥 reaction.

Three things make this stronger than a naming exercise:

1. **Unprompted.** There was no brief, no candidate list, no request for a name.
   He was reacting to gameplay.
2. **Roughly three minutes** from first seeing the game to producing the name.
   That is mechanic inference at conversational speed — the thing a store
   listing has to achieve on a cold viewer.
3. **Generated in the right register.** It arrived immediately after "upload to
   Google Play" and "Flappy bird" — he was thinking about what works as a
   snappy, shareable mobile title, which is exactly the commercial frame this
   product needs. A methodology-driven exercise optimises for structure; this
   optimised for the actual job.

It also **predates every research pass by a week**, so it cannot have been
contaminated by any candidate list generated on 2026-08-05.

**Second data point, and a weaker kind — recorded as such.** Discord, **2026-08-03,
08:55**. A different friend, having watched a gameplay clip (`953.2 m`, `FLIES 3`,
`REEL` and `ATTACH` visible), asked *"What's tho game called bro?"*. The owner
answered *"I think it will be 'slingy spider'"* — adding *"but still haven't
fully decided"* — and the reply was **"That's a good fit for it"**, with a 🔥.

This is **endorsement, not independent generation**: the name was put to him
rather than produced by him. It is genuine supporting evidence and it is not a
second instance of the mechanic-inference result. The distinction matters,
because the strength of the 2026-07-30 exchange rests entirely on the name being
unprompted.

**Two useful things surfaced in the same conversation, unrelated to naming:**

- **Demand exists before launch.** The friend's first message was *"How can I
  play it xD"*. He could not: he is on iPhone, and Apple does not permit installs
  from outside the App Store. Pre-release testing is therefore **Android-only**,
  which reinforces the Android-first strategy and means iOS contacts cannot serve
  as closed-test testers.
- **Tester recruitment is already in motion.** The owner stated an intent to open
  a Discord server for testers "somewhere this week", explicitly because he needs
  multiple opinions rather than his own. That is the recruiting half of
  `OQ-PLAY-CLOSED-TEST` — which needs **12 testers opted in for 14 continuous
  days** on Android, each with a Google account. See
  [`../technical/play-closed-test-runbook.md`](../technical/play-closed-test-runbook.md).

**One finding actively favours the name.** Searching "slingy spider" on Play
returns **Stickman Hook (Madbox, 100M+ installs) at position 2**, with
*A Webbing Journey* also present. Play's search parses "slingy" as
swing/momentum and surfaces the canonical games of exactly this genre — the
store already understands what the word means.

**Exact-phrase search is clean:** no app on Google Play carries this name.

### What remains open on the name

**Trademark only.** Unrelated to everything above and still owner work: **BOIP**
(Benelux — the owner's home registry) and **EUIPO**, for exact and phonetically
similar marks in **Nice Class 9** (software) and **Class 41** (entertainment
services). Also worth reserving: social handles and the domain — checked via
**WHOIS/RDAP rather than a registrar search bar**, which front-runs queries.

### The competitive picture behind the decision

Owner review of the genre on Play, 2026-08-05:

- **Store art across the category is cheap and dull.** Nearly every swinging
  game's cover looks low-effort. Presentation is therefore a *differentiator*,
  not a formality — the feature graphic and screenshots carry unusual weight
  here, and are on the critical path anyway (see
  [`play-store-listing.md`](play-store-listing.md)).
- **"Spider Swing" — the closest name-neighbour — is weak, and documented.**
  Owner-captured store listing and gameplay, 2026-08-05:

  | | |
  |---|---|
  | Developer | "Hyper casual go go" |
  | Downloads | **10K+** |
  | Monetisation | contains ads |
  | Rating label | PEGI 3, "Casual games" |
  | Description | *"Bestuur de spin om naar de finishlijn te slingeren"* |
  | Presentation | flat solid-blue background, thin magenta line anchors, portrait |
  | **Live build** | carries a **"trial version" watermark** in the corner |

  A watermarked trial export is shipping on the Play Store. The owner's verdict —
  less enjoyable than this project's first prototype — is consistent with what
  the screenshots show.

  **The failure is in the settlement, and it is worth understanding precisely.**
  The red strip *is* the finish line, and reaching it *is* a win — but the game
  stops instantly with no feedback of any kind. Owner's account: it feels the
  same as dying, and less enjoyable.

  So a player cannot distinguish victory from death **by the game's response**,
  not by misreading the art. Winning and losing produce the same event: the run
  simply ends. Whatever the level design does, the moment that decides whether a
  run felt worth playing is unhandled.

  That is the clearest possible argument for this project's own settlement work.
  GDD § 2.2 promises **Ownership** — a death should be understandable and feel
  caused by a player decision — and the same obligation applies to a win. The
  category's closest name-neighbour fails exactly there, at 10K installs, with a
  watermarked build. The bar is not just low on art; it is low on the thing this
  game is actually built around.

The bar in this genre is low, and it is low on exactly the axes this game
optimises for — feel, momentum, and readability. That is the argument for a
legible spider name rather than an abstract one: the audience searching for
these games exists and is currently underserved.

## Ruled out, 2026-08-05: "Swingy Spider"

The working release candidate has been **eliminated**, and so has the whole
naming construction behind it.

**"Swingy Spider" is taken by two same-genre products**, verified by fetching
the listings rather than reading a search summary:

- [`goodwingames.itch.io/swingy-spider`](https://goodwingames.itch.io/swingy-spider)
  — HTTP 200, "Swingy Spider by Garrett Goodwin", a 2D web-swinging game where
  you **eat flies and avoid enemy bugs**.
- [Amazon Appstore](https://www.amazon.com/Tim-Mendez-Swingy-Spider/dp/B017V0UL8M)
  — "Swingy Spider" by Tim Mendez, an endless swing game, *swing from leaf to
  leaf*, with leaderboards.

**"Slingy Spider" was checked and is also rejected.** No exact store conflict,
but it is one letter from **SLINKY** — a live US trademark (reg. 1455493) that
is genericised in everyday speech — and it names the wrong mechanic. This game
is a pendulum, not a slingshot.

**The construction itself is the problem.** `[swing|sling] + spider` is
saturated — *Spider Swing*, *Spider Swinger*, *Spider Swing 3D*, *Slinging
Spider*, *Spider Slingers* — and those titles have trained store search to
return urban superhero brawlers. A calm physics game named this way is buried by
algorithmic mismatch even when the exact string is unused. That fails § 2.5's
store-searchable requirement structurally, not incidentally.

**Researched replacements with no exact-match conflicts** (independent search
plus a Deep Research pass that agreed on every verdict): `Silken Pendulum`
(ranked first — its footprint is antique horology and poetry, so the term is
winnable), `Thread Momentum`, `Tension Weaver`, `Arcing Arachnid`.

**The owner is holding the decision** as of 2026-08-05. Nothing may ship under
"Swingy Spider". Candidates above are **not clearances** — a Play Console search
under the owner's account and a trademark check remain owner work.

### The naming method to use, and why the first shortlist was weak

The owner supplied a titling-methodology study (2026-08-05) that **invalidates
the four candidates above on structure**, independently of their availability:

- **Ceiling of three syllables.** `Silken Pendulum` and `Arcing Arachnid` are
  five; `Thread Momentum` and `Tension Weaver` are four. All fail the
  conversational test the method requires.
- **Archetype risk.** All four are *Evocative Phrase* (adjective + noun) — the
  archetype the study marks **"high trademark collision risk"**. The recommended
  sweet spot is **compound / portmanteau**: distinctive, trademarkable,
  SEO-clean, and still semantic (Skyrim, Cuphead, Owlboy).
- **Formula:** one-syllable concrete noun + one-syllable action or abstract term.
- **Phonetics:** plosives (`p b t d k g`) and trochaic stress read as precision
  and kinetic energy — which is exactly this game's feel.
- **Avoid saturated lexicon** (War, Craft, Battle, Heroes, Quest…).

That first shortlist optimised for availability and theme and never applied
syllabic economy at all. Recorded because the error was method, not taste.

**Candidates regenerated against the method** — availability spot-checked by web
search only, **not cleared**:

| Candidate | Syl | Notes |
|---|---|---|
| `Silkarc` | 2 | Compound, `/k/` twice, names the arc itself. Silk- prefix is moderately occupied (Silk, Silkgrove, Silkdown on Steam) — none are swing games, but it would not own the prefix. |
| `Bramblefall` | 3 | Compound, `/b/` plosives, **no prefix crowding**, and borrows equity from the game's existing Bramble region. |
| `Silkline` | 2 | Clean, no conflicts found, but flat — no action term. |

Rejected in generation: `Threadfall` ([thread-fall.com](https://thread-fall.com/)
plus Anne McCaffrey's Pern usage) and `Webkite` — "web" pulls toward the
superhero association § 17.1 forbids.

### Clearance steps that remain owner-only

From the same study, and none of these are agent-runnable:

1. **USPTO TESS and EUIPO** searches for exact and *phonetically similar* marks
   in **Nice Class 009** (software) and **Class 041** (entertainment services).
2. **Common-law audit** across Steam, itch.io and mobile stores for unregistered
   prior use.
3. **Domain check via WHOIS, not a registrar search bar** — registrars are known
   to front-run searched terms and register them for resale markup.
4. **Social handle reservation** across platforms before any public announcement.
5. **Blind scoring** of the final shortlist to strip familiarity bias.

Note also the syntax hazard: avoid ampersands and special characters, which
corrupt URL parameters and store API integrations.

## Current status: internal codename only

**"Spider Swing" is an internal codename. It is not approved for release
branding.** It appears in this repository's name, the Godot project name, and the
development package identifier purely so that development has something stable to
refer to.

The GDD states this directly in its own header:

> "Spider Swing" is a codename, not an approved release name. Existing games
> already use the name and similar spider-swinging concepts. Complete a naming and
> store-conflict review before public branding.

## What remains future product work

None of the following has been done, and none of it can be done by an agent —
each needs the owner, and several cost money or are irreversible:

| Item | Status | Why it is owner work |
| --- | --- | --- |
| Public release name | **Not chosen** | A product and brand decision. |
| Google Play store-conflict review | **Not done** | Requires searching the live store and judging confusability. |
| Apple App Store conflict review | **Not done** | Same, for the later iOS platform. |
| Trademark search and clearance | **Not done** | May need legal advice; jurisdiction-dependent. |
| Domain availability and registration | **Not done** | Costs money; registration is a commitment. |
| Social handle availability | **Not done** | First-come-first-served across platforms. |
| Production package identifier | **Not chosen** | Irreversible once published — see ADR 0003. |
| Visual identity / logo | **Not started** | Must avoid Spider-Man and superhero-property similarity (GDD § 17.1). |
| Store listing copy and screenshots | **Not started** | Depends on the final name and art. |

## Constraints the eventual name must satisfy

Carried from the GDD so the review has criteria rather than taste alone:

- **No superhero association.** The GDD requires avoiding visual and naming
  similarity to Spider-Man or other superhero properties (§ 17.1). The visual
  identity must read as an actual or stylized spider in a miniature world, not a
  city-swinging human hero.
- **Distinguishable from existing swing games.** The broad "swing, avoid obstacles,
  catch flies" premise already exists in small web and mobile games (§ 2.5). The
  name should not collide with them.
- **Store-searchable.** A name that returns established competitors on the first
  page of store search is a discovery problem regardless of legal clearance.

## What this means for the repository right now

- The repository name `spider-swing`, the Godot `config/name` ("Spider Swing"),
  and the package identifier `com.menno420.spiderswing.dev` are all **development
  identifiers** and are all expected to change.
- The `.dev` suffix on the package identifier is deliberate: it leaves the
  production identifier unclaimed. `tests/test_runner.gd` asserts the exact
  development value, so a production identifier cannot slip in without a failing
  check and a deliberate decision.
- Renaming later is a contained change (project name, package identifier, README,
  store assets) as long as no production build has shipped. **It stops being
  contained the moment a package identifier is published** — which is why ADR 0003
  keeps publishing behind an explicit owner step.

## Owner action

Tracked as an owner action in the founding session card. Nothing in Phase 0, 1, or
2 is blocked by it; the naming review must complete **before public branding or any
store submission**, not before implementation.
