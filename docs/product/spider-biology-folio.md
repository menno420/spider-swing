# Spider biology folio — approved mappings for the current five

> **Status:** `binding` for identity claims · `ideas` for §6 candidates
>
> The authoritative record of what each playable profile is inspired by, what
> the real animal does, and what this game invents. `game/domain/spider_biology_catalog.gd`
> is the runtime copy of §2 and always wins on wording; this file carries the
> reasoning, sources, art cues, and the parked backlog that do not belong in
> shipped data.
>
> Source: owner-supplied deep research, *Real Spider Diversity, Abilities, and
> Educational Game Design*, 31 July 2026. Accepted names follow the World
> Spider Catalog v27; records reviewed 2026-07-31.

## 1. The rule this folio exists to enforce

Four things are separate and are never merged into one sentence:

| Layer | Owns | Changes when |
|---|---|---|
| **Game identity** | Profile name, role, strength, trade-off | Balance changes |
| **Inspiration** | What the profile is drawn from, and how strong that claim is | An art or mapping review |
| **Real-world trait** | Observed biology, cited | Taxonomy or evidence changes |
| **Game adaptation** | The explicit statement of what is invented | The mechanic changes |

A profile may exaggerate as much as the game needs. What it may not do is let
the exaggeration read as zoology. Every record therefore carries its own
disclosure, and contracts in `tests/unit/spider_biology_tests.gd` fail the
build if one goes missing.

**Claim strength** is stored, not implied:

- `species` — one accepted species, art matches its diagnostic traits. Only
  this level may state an accepted binomial.
- `composite` — several relatives blended; no species-level claim.
- `behaviour` — a behaviour recorded across many families, not a taxon.
- `fictional` — an invented animal. Welcome here (see §3); real biology may
  still guide the art, and the disclosure must say the spider itself is
  invented, not merely that a stat is tuned.

## 2. Approved mappings

### Garden Spider — `composite`

- **Inspired by:** garden orb-weavers, family Araneidae. Reference animal:
  *Araneus diadematus* Clerck, 1757.
- **Why composite:** the finished sprite reads as a dark-furred, orange-banded
  orb-weaver. That is honest Araneidae; it is not a diagnostic match for the
  cross orb-weaver's pale dorsal cross. Promote to `species` only if a future
  art pass adds the cross and banding deliberately.
- **Real trait:** rebuilds a vertical capture web, often daily; reads prey as
  vibration through the silk; spins frame lines, sticky spiral, dragline and
  egg-sac silk from different glands.
- **Game adaptation:** continuous high-speed grappling, Reel-In, Anchor Burst
  and Dive Pull are invented. No orb-weaver travels by swinging.
- **Correction carried:** spider does not mean orb web — many spiders build no
  capture web at all.
- **Sources:** WSC v27; NHM London, *Spider webs*.

### Skitter — `species`

- **Inspired by:** magnolia green jumper, *Lyssomanes viridis* (Walckenaer, 1837),
  family Salticidae.
- **Real trait:** slender translucent green salticid of broadleaf foliage in the
  south-eastern United States; stalks prey visually and pays out a dragline
  before jumping.
- **Game adaptation:** smaller hitbox, faster forward recovery and weaker Burst
  are balance numbers. Burst is not a jump; no rechargeable dash exists in the
  animal.
- **Correction carried:** *Lyssomanes* is long-legged and slender for a jumping
  spider. **This contradicts the pre-existing sprite brief** and is the reason
  `docs/ideas/spider-sprite-briefs.md` was corrected before production.
- **Sources:** WSC v27.

### Anchorite — `composite`

- **Inspired by:** burrowing mygalomorphs — terrestrial tarantula and
  trapdoor-spider body plans (*Tliltocatl albopilosus* and *Aphonopelma
  chalcodes* are the closest references for the finished sprite's bulk).
- **Why composite:** the broad charcoal-and-bronze silhouette is compatible with
  several theraphosids and with no one of them diagnostically. A species label
  here would be false precision.
- **Real trait:** robust, often long-lived mygalomorphs that line a burrow or
  retreat with silk and strike at prey passing the entrance; fangs move roughly
  in parallel and drive downward.
- **Game adaptation:** stronger Reel-In, heavier fall and more powerful Burst
  are tuning. Body mass gives no real spider a stronger line.
- **Correction carried:** size is no guide to medical significance.
- **Sources:** WSC v27.

### Ballooner — `behaviour`

- **Inspired by:** ballooning, a dispersal behaviour recorded across many
  families and life stages. **No species is claimed and none should be.**
- **Real trait:** the spider climbs to an exposed point, raises its abdomen in a
  tiptoe posture and releases silk; airflow carries it, and experiments show
  atmospheric electric fields can also trigger and help lift.
- **Game adaptation:** a predictable reduced-gravity glide the player steers
  after every release is fictional. Ballooning is one-way dispersal, not powered
  or steered flight.
- **Correction carried:** ballooning is shared across families, not one
  species' ability.
- **Sources:** Morley & Robert 2018, *Current Biology*; Cho et al. 2021.
- **Note:** ballooning is overwhelmingly a behaviour of small spiders and
  spiderlings. The adult silver showpiece in the art brief is a readability
  choice; it must never be captioned as "the ballooning spider."

### Buckler — `fictional`

- **Inspired by:** cork-lid trapdoor spiders, *Ummidia* Thorell, 1875, family
  Halonoproctidae. **Buckler is an invented spider** — a buckler is a small
  round shield made to absorb one blow, which is exactly the profile's identity.
- **Real trait:** compact mygalomorphs with a hard glossy carapace that build a
  silk-lined burrow closed by a hinged door and ambush from behind it.
- **Game adaptation:** the animal is invented and so is the rebound. A hardened
  carapace resists drying out and predators at the burrow door; it is not impact
  armour.
- **Correction carried:** armour is not why small animals survive falls — low
  mass and high air resistance are. This corrects the exact misconception the
  mechanic would otherwise plant.
- **Sources:** WSC v27.
- **Naming history:** this profile was called **Springtail** until 2026-07-31.
  That name belongs to Collembola — six-legged hexapods, not arachnids — and a
  disclaimer was doing work an invented name does for free. See D-0027. The
  persisted id stays `springtail` because it keys saved progression; no player
  ever sees it.

## 3. Designing fictional spiders

**Invented spiders belong in this game.** The product is fun first and
educational second, and `fictional` is a first-class claim strength, not a
grudging exception. Read the rest of this folio as *how to invent well*, never
as *only real species allowed*.

The reasoning is worth stating plainly, because it is the opposite of the
intuition: **fiction is not what costs an educational game its credibility —
undisclosed fiction is.** A wholly invented spider is the *safest* content the
game can ship, because there is no real animal a player can walk away holding a
wrong fact about. The genuinely risky content is a half-accurate real species,
which is why Garden Spider and Anchorite are composites rather than named
species. A labelled invention costs a player nothing and teaches by contrast:
knowing which one is made up is what makes the real ones land.

### The four rules

1. **Fiction must not be the exciting tier.** If real spiders are the starters
   and invented ones are the rewards, the game quietly teaches that reality is
   the boring part. It is not. Real spiders cast nets held in their front legs,
   spit glue in a zigzag, cartwheel down dunes to escape, and build underwater
   air bells they breathe from. Most of that is stranger than what anyone would
   invent. Invented profiles sit *alongside* that, never above it.
2. **Never borrow a real animal's name.** This is the only way fiction actually
   misinforms, and it is what the Springtail rename fixed. An invented mechanic
   on an invented name is free. An invented mechanic on a real animal's name
   makes a disclaimer carry weight it should not have to. The same applies to
   invented Latin binomials and real-sounding common-name patterns — a
   `-back`, `-weaver`, or `-jumper` suffix reads as a documented species.
   Check any candidate name against the World Spider Catalog before it ships.
3. **An invented spider still says what it borrowed.** "Invented for this game
   — the glossy shell is drawn from cork-lid trapdoor spiders; the bounce is
   not something any spider does" is a better card than either pure fantasy or
   a dry fact. The `inspired_by` field works exactly the same for a fictional
   profile as for a real one.
4. **Give it an honest correction too.** A fictional profile is the *best* place
   for a myth correction, because the invention creates a specific
   misconception and the entry can answer it directly. Buckler invents impact
   armour, so its correction explains what actually lets small animals survive
   falls.

### The pattern worth chasing

Use fiction as the **on-ramp**, not the destination. An invented spider built
around one exaggerated real trait becomes a doorway to the animal that inspired
it — a player who enjoys a fictional net-caster is a player who will read the
*Deinopis* entry. That is fiction serving the education instead of competing
with it, and it scales: every parked candidate in §6 could arrive first as an
invented profile and later as a field-guide entry about the real thing.

### What is still rejected

Not fiction — only dishonesty. A fictional profile may not claim an accepted
name, may not cite sources for invented behaviour, and may not present a
medically significant real species as a power fantasy. And no profile, invented
or real, may require a second motor.

## 4. Editorial voice

- Write "can", "has been observed", "in this species", "in these experiments".
  Avoid "designed to", "knows", "decides", and universal claims.
- Defensive behaviour is not aggression. A raised posture, fang display or a
  bite after compression is defence.
- Never rank spiders by "deadliest", "most aggressive" or "strongest". Those
  collapse distribution, encounter probability, delivered dose and clinical
  outcome into one number that does not exist.
- Never reward killing a spider, and never present venom as a damage stat.
- Medical information is regional and belongs to health authorities, not to
  this game. The current five carry no medical claims at all, which is the
  correct amount.
- Younger readers get shorter text, not less accurate text.

## 5. Art and reference rules

The production contract in `docs/ideas/spider-sprite-briefs.md` stands. This
folio adds the identity rules that outlive any single brief:

- Preserve the body plan that carries the biological story — abdomen/prosoma
  ratio, stance, first-leg orientation, one or two high-contrast markings —
  rather than copying colour alone.
- Fine eye arrays, individual setae, spinnerets and silk filaments may exist in
  the 384×181 source but must not be load-bearing at the 96×46 gameplay size.
- Hidden far-side legs are an explicit 2D readability convention, not an anatomy
  claim.
- Choose one sex explicitly when dimorphism changes the silhouette.
- **Never combine diagnostic markings from several species and then label the
  result as one species.** That is exactly what `composite` exists to prevent.
- Every reference image needs a manifest entry: URL, creator, licence, access
  date, permitted transformations, attribution text. Wikimedia licences are
  per-file. Museum imagery is not automatically reusable. Figures in open-access
  papers can still be separately copyrighted.

## 6. Parked candidates — ideas, not scope

Phase 0's owner-judged feel gate (issue #2) is open. Nothing below is planned,
promised or estimated; this section exists so the research is not lost and so a
future session does not re-derive it. **Any new profile that would need a second
motor is rejected outright.**

### Future playable profiles, best first

| Candidate | Movement axis it would add | Trade-off | Blocked on |
|---|---|---|---|
| Flattie, *Selenops* spp. | Directed aerial descent — real righting and steering during a fall | Weaker Reel/Burst, wider laterigrade body | Nothing but the gate; fits the existing detached-state modifier |
| Fishing spider, *Dolomedes triton* | Water-surface travel and launch; airflow sensing | No benefit on dry routes | A water biome existing at all |
| Diving-bell spider, *Argyroneta aquatica* | Underwater endurance via air-bell pockets | Buoyancy, drag, dependence on air structures | A water biome; better biome-locked than a starter |
| Trapdoor guardian, *Ummidia* composite | One deliberate guarded setup window | Slow correction, large body | Overlaps Buckler — use as its mapping, not a second profile |

### Temporary modes or pickups, never permanent powers

Net cast (*Deinopis*); stored web-tension release (*Hyptiotes*); bolas
precision lure (*Mastophora*); spitting entanglement (*Scytodes*); ballooning
updraft as an environment trigger rather than a species power; vibration route
preview (*Portia*). Each would be a short window with setup cost — none may
become a ranged attack, because that changes the control grammar from traversal
to combat.

### Biome inhabitants and field-guide subjects

Social *Stegodyphus* communal webs; trapdoor ambush animations; cellar-spider
vibrating tangles with the venom myth corrected; funnel/sheet-web tunnels;
intertidal *Desis*; desert wheel and flic-flac escapes; flower crab spiders;
ant-mimicking jumpers; pelican spiders; cave *Trogloraptor*; peacock spiders;
*Bagheera kiplingi*; uloborids and cribellate silk. These add diversity without
roster inflation, which is the point.

### Rejected

A 50–70 profile roster. Species picked for a "deadly" reputation. Permanent
combat powers replacing swinging. Several tarantulas with near-identical
silhouettes. Wheel/flic-flac spiders as ordinary traversal. Colony and maternal
behaviour reduced to a solo stat buff. Taxonomy copied into game data without
review provenance.

## 7. Maintenance

- `SpiderBiologyCatalog.REVIEWED_ON` and `NAME_AUTHORITY` travel with the data.
  When the World Spider Catalog moves a genus, correct the record and bump the
  date — **without touching a profile id, a saved upgrade level, or one tuned
  number.** The contract suite proves the two tables stay disjoint.
- A new profile is not finished until it has a record here and in the runtime
  catalog. The suite fails on a profile with no biological record.
- Recheck accepted names against the WSC before any educational release, and
  before any store copy quotes a species name.
