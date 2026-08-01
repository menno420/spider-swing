# Zone progression — 0 m to 35 000 m and beyond

> **Status:** `owner-guidance`
>
> Owner-approved direction (2026-07-31). Zones 1–8 are **shipped**; Zones 1–3
> retain frozen persisted ids/ranges, while Zones 4–8 are append-only content.
> Owner-rejected content remains correctable. Bramble's identity is shipped but
> its revised clearance remains an open device gate. PR #73 implemented Zones
> 4–8; their success sentences remain real-device acceptance gates.
> This document remains the source of
> truth for zone identity, hazards and mechanics. Balance numbers live in
> `SwingConfig` and the pattern catalog, never here.
>
> Origin: an owner + Grok brainstorm, reconciled against the shipped game and
> extended with the constraints that brainstorm could not know about.

## The rule that shapes everything below

**Speed stops being the difficulty.** `speed_curve_distance` completes at
5000 m, so from Bramble Canopy onward the player is already at
`maximum_target_speed` — measured at 76–77 m/s on device. Every zone after that
escalates by **composition**, never by pace.

So each zone must declare **one axis** it owns. Repeating an axis is how a zone
ends up feeling like a re-skin.

| # | Zone | Range (m) | Axis it owns | State |
|---|---|---|---|---|
| 1 | Ancient Forest | 0–5 000 | Teaching — wide recovery rhythm | **shipped** |
| 2 | Bramble Canopy | 5 000–10 000 | Vertical displacement | **shipped · clearance device gate open** |
| 3 | Silk Hollow | 10 000–15 000 | Precision around suspended hazards | **shipped** |
| 4 | Ruined Arboretum | 15 000–20 000 | **Timing** — the world moves | **shipped · device gate open** |
| 5 | Storm Ridge | 20 000–25 000 | **External force** — your arc is fought | **shipped · device gate open** |
| 6 | Web City | 25 000–30 000 | **Route choice** — the world offers help | **shipped · device gate open** |
| 7 | Ashen Hollow | 30 000–35 000 | **Trust** — anchors fail | **shipped · device gate open** |
| 8 | Deep Mist | 35 000+ | **Information** — you cannot see it coming | **shipped · device gate open** |

Zones 1–3 have frozen ids and ranges. Their ids (`ancient_forest`,
`bramble_canopy`, `silk_hollow`) key persisted checkpoints, so renaming them
breaks saves. That is not permission to freeze content the owner has tested and
rejected: Bramble's first visual pass kept the old obstacle roles under new art,
so its normal pool now owns hook-vine and diagonal leaf-shutter families that
Ancient Forest cannot select. Its first obstacle-identity pass then made those
families too large and dense to traverse reliably. Bramble now isolates every
vertical commitment with open preparation/recovery space; its axis is height
change, not wall-to-wall obstacle density. Zones 4–8 append to `REGIONS`; they
do not restructure or renumber the persisted entries.

## Constraints any zone must satisfy

These are not style notes. A zone that violates one of them cannot ship.

**1. Every moving part must be deterministic.**
The simulation is fixed-step and seeded, geometry derives from chunk index plus
course seed, and contracts assert identical trajectories at 30/60/90/120 Hz plus
exact geometry equality for an off-grid debug start. So a moving hazard must be
a pure function of `(chunk_index, course_seed, tick)` — a phase, not a physics
body, and never a runtime RNG draw. Wind is a deterministic field over distance.
A swinging shard has a phase derived from its chunk index. Nothing may drift.
ADR 0004 was written before the first moving part landed and now binds this
contract.

**2. Readability budget: about one second.**
At 76 m/s the player crosses 76 m per second and roughly 760 px of lead is all
the warning there is. A hazard must be identifiable from silhouette and palette
at that distance. Anything that *reduces* visibility — fog, spore clouds, ash —
spends this budget directly and must repay it with a compensating cue: rim light
on the silhouette, an audio tell, or a guaranteed recovery pocket after it.

**3. New feelings, not new buttons.**
The owner reports never using the BURST button in play, because at speed
reaching for it is not feasible — he double-taps instead. Adding controls is the
wrong direction. New mechanics must express themselves through the verbs that
already exist: attach, release, Reel-In, Anchor Burst, Dive Pull, rescue.

**4. Hazards must declare anchor eligibility.**
Since 2026-07-31 anchor eligibility is per-obstacle data
(`CourseGeometry.append_obstacle(polygon, anchorable)`). Ceiling-grown hazards
answer web taps; floor-grown ones are lethal but untappable, so a release tap
cannot be stolen as a Dive. **Every new hazard must state which it is**, and
anything genuinely new — a silk highway, a rotten branch — needs its rule
written down here before it is built.

**5. One sentence a playtester would say.**
Each zone declares the single sentence that means it worked. That sentence is
the acceptance test; if a build does not produce it, the zone is not done.

**6. Nothing may weaken settlement.**
Flies, records, checkpoints and the noncompetitive rules for practice and debug
runs are contract-covered. A zone mechanic that grants distance, flies or
survival must route through the existing settlement path.

---

## Zone 4 — Ruined Arboretum · 15 000–20 000 m

**Axis: timing.** The first zone where the world moves. Everything before it was
static geometry the player read at speed; here the same reading skill has to
account for a phase.

**Mood.** Abandoned glasshouses swallowed by the forest. Iron ribs with the
glass long gone, a few panes still hanging. Machinery that never got switched
off, turning slowly because the water still runs. Quiet, not menacing — the
threat is that it moves, not that it hunts.

**Palette.** Cold structure against warm decay: oxidised copper-green and rust
on wet grey-black iron, pale sun through dirty glass, moss reclaiming the joints.
Reads instantly against Silk Hollow's warm interior tones.

**Hazards.**
1. **Broken beam** — a static iron span, anchorable, the zone's safe furniture.
2. **Hanging pane** — a glass shard on a pivot, swinging on a fixed phase.
   Anchorable at the pivot, lethal along the edge.
3. **Slow rotor** — an old fan or wheel rotating at a constant seeded rate; its
   spokes open and close a gap on a predictable cycle.
4. **Collapsed frame** — a static diagonal that narrows the corridor and forces
   a committed line, giving the eye a rest between moving pieces.
5. **Drip chain** — a vertical line of falling droplets on a repeating phase;
   harmless, and it teaches the player to read phase before the lethal versions.

**Mechanics.**
- **Phase-gated gaps.** A gap that is open or closed depending on where you are
  in the cycle. The skill is arriving at the right time, which the player can
  only control with Reel-In and Burst — giving Reel a genuine late-game job
  beyond arc-shaping.
- **Anchorable moving pivots.** Attaching to a swinging pane's pivot is legal
  and the anchor moves with it. This is the zone's signature moment and its
  biggest technical risk: the web constraint must handle a moving anchor without
  injecting energy. Prove it in the simulator before it ships.
- **Readable telegraph.** Every moving part carries a visible rest position, so
  a stationary silhouette still tells you where it will be.

**Cues.** Metal groan on the rotor cycle, glass chime near panes, drip audio on
the same phase as the visual. A faint motion-blur trail on anything that moves,
so movement is legible in a still frame.

**Density.** Open with drip chains and static beams only (15 000–16 500 m), one
moving element at a time. Introduce paired phases at 17 000 m. Reserve
rotor-plus-pane combinations for 18 500 m onward, always with a static recovery
span immediately after.

**Success sentence.** *"I had to wait for the gap."*

---

## Zone 5 — Storm Ridge · 20 000–25 000 m

**Axis: external force.** The first zone where the arc you planned is not the
arc you get.

**Mood.** Out of the forest and onto exposed rock. Sky for the first time. Rain
driving sideways, the canopy replaced by open air and the sense that the world
is much bigger than the corridor you were in.

**Palette.** Desaturated slate and wet stone, bruised blue-grey sky, white rain
streaks, and one warm accent — the lightning, and the flies, which must stay
readable against the coldest palette in the game.

**Hazards.**
1. **Exposed spire** — tall, narrow, anchorable, the reliable furniture.
2. **Gust corridor** — a marked stretch where lateral wind is strongest.
3. **Loose scree shelf** — floor-grown, lethal, untappable; punishes a low line.
4. **Wind-bent tree** — leans with the gust, telegraphing wind direction.
5. **Lightning strike point** — a marked spire that discharges on a phase,
   lethal briefly, and lights the whole corridor for a moment.

**Mechanics.**
- **Continuous lateral wind.** A deterministic force field varying with
  distance, applied to the detached spider. Attached swinging is affected far
  less — so the wind's real message is *stay on silk*, which inverts the usual
  incentive to release for speed.
- **Gusts as phase, not surprise.** A gust ramps in and out on a visible cycle
  with a wind-bent visual tell. Deterministic, never a coin flip.
- **Lightning as illumination.** A strike briefly reveals the corridor further
  ahead than normal. Trading a lethal point for information is the zone's one
  bargain.

**Cues.** Wind direction must be visible at all times through rain streak angle
and tree lean. Rising audio before a gust peak. Lightning flash on a beat the
player can learn.

**Density.** Mild constant wind from 20 000 m with no gusts. First gust cycle at
21 000 m in an open corridor with nothing else to hit. Gusts plus geometry from
22 500 m. Lightning from 23 500 m.

**Success sentence.** *"I stayed on the web because letting go was worse."*

---

## Zone 6 — Web City · 25 000–30 000 m

**Axis: route choice.** The first zone that offers the player help and makes
taking it a decision.

**Mood.** Ancient silk architecture spanning a canyon, built by generations of
something much larger than you. Cathedral scale. The first zone where the player
is a visitor in someone else's structure rather than alone in a landscape.

**Palette.** Pale silver-white silk against deep canyon shadow — the highest
contrast in the game, and the strongest silhouette read. Resident spiders in
warning colours that are never used elsewhere.

**Hazards.**
1. **Silk highway** — a long anchorable strand; riding it is fast and safe but
   commits you to its line.
2. **Sticky strand** — visually distinct, anchorable, but bleeds speed while
   attached. A trap that punishes careless aim, not a kill.
3. **Resident spider** — stationary or patrolling on a fixed phase; lethal on
   contact, and the zone's only active threat.
4. **Egg sac cluster** — a static obstacle that blocks a tempting shortcut.
5. **Torn span** — a highway that ends early, so the player must read a strand's
   length before committing.

**Mechanics.**
- **Ridable silk.** A highway is a route the player can commit to for a stretch
  of guaranteed progress at the cost of choosing it over a faster free line.
  This is a genuinely new anchor class and needs its own rule in the anchor
  model, not an obstacle flag.
- **Speed-bleeding attachment.** Sticky strands make attachment cost something
  for the first time, which forces target discrimination at speed.
- **Living hazards on a phase.** Patrolling residents reuse Zone 4's phase
  machinery so no new determinism model is required.

**Cues.** Sticky strands must be unmistakable from silhouette alone — thicker,
beaded, and a different colour temperature. Residents need a silhouette readable
at 760 px lead.

**Density.** Introduce highways as pure gifts (25 000–26 500 m). Add sticky
strands at 27 000 m so the player learns to look. Residents from 28 000 m.

**Success sentence.** *"I chose the slow safe line."*

---

## Zone 7 — Ashen Hollow · 30 000–35 000 m

**Axis: trust.** Anchors stop being reliable.

**Mood.** A burnt forest that has not finished falling down. Everything is
structurally present and none of it is sound. Embers, heat shimmer, the sense
that the level is still collapsing around the player.

**Palette.** Charcoal and bone-grey with ember orange as the only saturation.
Ash haze reduces contrast — spend that against the readability budget carefully
and keep ember light on the silhouettes that matter.

**Hazards.**
1. **Rotten branch** — anchorable **once**: it holds, then fails after a short
   attached duration.
2. **Falling ember** — a descending hazard on a deterministic phase.
3. **Ash drift** — a visibility-reducing volume; the zone's readability cost.
4. **Standing char** — reliable, anchorable, visually distinct from rotten
   branches. The distinction must be unmissable.
5. **Collapsing span** — begins failing when the player attaches anywhere on it.

**Mechanics.**
- **Timed anchors.** An anchor with a lifetime turns swinging from a spatial
  problem into a spatial-plus-temporal one, and it makes the release the
  decision rather than the attach.
- **Reading soundness.** Rotten versus sound must be legible at speed. If the
  player cannot tell them apart, this zone is unfair rather than hard.
- **Ember pressure.** Falling hazards discourage lingering, which pairs with
  timed anchors to keep the player moving.

**Cues.** A rotten branch must announce itself before contact and again on
attachment — a crack, a shudder, falling embers from the joint. The failure must
never be the first information the player gets.

**Density.** Rotten branches at 30 000 m with generous sound alternatives. Ash
drift from 31 500 m. Collapsing spans from 33 000 m.

**Success sentence.** *"I let go before it broke."*

---

## Zone 8 — Deep Mist · 35 000 m+

**Axis: information.** The final zone, and the endless tail.

**Mood.** Everything gone except the few metres in front of you. Not
threatening — empty. The player is alone with a skill they have spent 35 km
building.

**Palette.** Near-monochrome grey-white. Only two things carry colour: valid
anchors, and flies. Everything else recedes.

**Hazards.** Deliberately fewer and simpler than Ashen Hollow. The mist *is* the
difficulty; stacking complex geometry behind it produces unfair deaths rather
than tension. Reuse proven shapes from earlier zones, spaced wider.

**Mechanics.**
- **Reduced draw distance.** The readability budget is deliberately spent. To
  stay fair, anchors must be *lit* — they glow through the mist while hazards do
  not. The player can always see where they may go, never what they must avoid.
- **Audio leads vision.** Hazards announce themselves by sound before they are
  visible. This is the zone's fairness contract.
- **Endless tail.** As the terminal zone it must remain playable indefinitely
  without new content, so its difficulty comes from spacing rather than
  escalation.

**Success sentence.** *"I was listening."*

---

## Fungal Grove — recommended for the campaign, not the endless run

Grok's brainstorm placed a bioluminescent Fungal Grove at 10 000–15 000 m, which
is Silk Hollow's range, and Silk Hollow is shipped. The bounce mechanic and the
bioluminescence are worth keeping, but the zone reads as a **gentle, spectacular
palette-cleanser** — which sits badly at 20 000 m+ where every other zone is
escalating.

The recommendation is to make Fungal Grove a **campaign environment** instead.
The campaign teaching tier needs distinct settings, can afford a low-pressure
one, and would benefit from the strongest visual in the set. Its bounce surfaces
also overlap the Buckler profile's Impact Carapace, so a campaign level is the
natural place to teach that spider.

This is a recommendation, not a decision — flagged for the owner.

---

## Implemented build order

1. **ADR for deterministic moving parts** — landed before Zone 4.
2. **Zone 4, Ruined Arboretum** — landed with the production moving-anchor
   proof.
3. **Zone 5, Storm Ridge** — reused Zone 4's phase machinery and added the force
   field.
4. **Zone 6, Web City** — added the ridable/sticky silk anchor classes.
5. **Zones 7 and 8** — added timed anchors, embers, restricted visibility and
   audio-first warnings.

Zones 4–8 are additive: append to `REGIONS`, add a `*_PATTERNS` set per zone,
and extend the pattern-band logic. Ancient Forest and Bramble Canopy geometry
remain owned by their existing builders.

## Implementation evidence (PR #73)

- ADR 0004 binds all authored motion to pure fixed-tick phase descriptors.
- `CourseGeometry` carries obstacle eligibility, typed safe anchors, harmless
  phase decorations, visual identity, and immutable motion specifications.
- `tools/simulate.gd --moving-anchor-proof` passes the production moving-pivot
  solver for twenty complete cycles without accumulating relative energy.
- Every region pool contains at least seven patterns and admits multiple
  coprime seeded strides; the dedicated 15-contract zone group covers each
  density gate and mechanic above without changing the approved Balanced
  physics values. The complete live suite total lives in
  `EXPECTED_CHECK_COUNT` (`tests/test_runner.gd`); the added contracts
  lock two-plane depth, wall/surface/obstacle routing, diagnostic-only outlines,
  and ceiling-support continuity for every family visible in the owner's
  10–30 km recordings.
- Build `0.24.0-environment-finish-playtest` retains the five distinct original
  samples for mist, glass, rot, gust, and charge and replaces the recorded flat
  Silk/Arboretum obstacle fallbacks with explicit single-object art. Their
  700–820 px deterministic lead remains simulation-owned.
- The full-color captures and 25% black-silhouette sort test live under
  `docs/visual/zones/`; all thirty-three generated assets pass source, runtime, and
  gameplay-scale transparency/fringe inspection.

The success sentences above remain human device-playtest exit criteria. An
automated contract can prove the mechanic exists and stays deterministic; it
cannot claim that a playtester actually said the sentence.
