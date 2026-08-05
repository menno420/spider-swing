# Name status — "Spider Swing" is a codename

> **Status:** `owner-guidance`
>
> Tracks GDD § 25 decision 7 (release name and brand identity) and the codename
> warning at the head of `docs/game-design/Spider-Swing-GDD-v2.0.md`.

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
