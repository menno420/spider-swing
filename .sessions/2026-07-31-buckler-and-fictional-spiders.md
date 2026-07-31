# Buckler rename and first-class fictional spiders

> **Status:** `complete`

## Goal

The owner read the folio landed in PR #50 and corrected its posture: the game is
meant to be fun *and* educational, and that must not mean excluding fictional
spiders. Make invented spiders first-class in the folio, and rename Springtail —
the one profile where fiction genuinely misinformed.

## Scope guard

Naming, content, and documentation. No physics, collision, economy, upgrade, or
tuning value changed. No save migration: the persisted id is deliberately frozen.

## Previous-session review

**previous-session review:** PR #50 merged as `bb780b6`, landing
`SpiderBiologyCatalog`, the Garage inspiration strip, the Field Guide route, and
the folio. It left three owner questions open. The owner answered one of them
(rename Springtail) and corrected the folio's tone.

## The correction that prompted this

The previous session's folio *permitted* fiction but did not *invite* it, and a
future session could reasonably have read it as "real species only." That was
the previous session's tone, not the owner's product direction, and it was
flagged for exactly this reason.

The reasoning now written into the folio is the opposite of the intuition:
**fiction is not what costs an educational game its credibility — undisclosed
fiction is.** A wholly invented spider is the *safest* content the game can
ship, because there is no real animal a player can walk away holding a wrong
fact about. The risky content is a half-accurate real species, which is why
Garden Spider and Anchorite are composites.

Springtail was the single case where fiction actually misinformed: it borrowed
the name of Collembola — six-legged hexapods, not arachnids — and made a
disclaimer carry work an invented name does for free.

## Shipped

- **Springtail → Buckler.** A buckler is a small round shield made to absorb one
  blow: it matches the compact round amber carapace, matches the one-hit Impact
  Carapace mechanic, sits in the same archaic register as Anchorite, and names
  no animal. Role kicker changed `SPRING · RECOVERY` → `GUARDED · RECOVERY`.
  Renamed through the catalog, tutorial step 6, swing lab, progress defaults,
  tests, README, asset and progression docs.
- **The persisted id stays `springtail`.** It keys saved profile selection and
  the `springtail_shell` / `springtail_bounce` upgrade levels. Renaming it would
  cost a save migration for something no player ever sees. Verified rather than
  assumed — a pre-rename save loads, resolves to Buckler, and keeps both
  identity upgrade levels (12 and 7) with the bounce enabled at 855 px/s.
- **Folio §3 "designing fictional spiders"** — invented spiders belong here, with
  four rules: fiction is never the exciting tier (real spiders cast nets, spit
  glue, cartwheel down dunes — most of that is stranger than what anyone would
  invent); it never borrows a real animal's name, binomial, or common-name
  suffix pattern; it still says what it borrowed; and it carries a correction for
  the misconception it creates. Plus the pattern worth chasing — fiction as the
  **on-ramp**, where an invented profile becomes the doorway to the real animal
  that inspired it.
- **Buckler's biology record** now discloses the animal itself as invented, and
  its correction explains that low mass and air resistance — not armour — are why
  small animals survive falls. That answers the exact misconception the mechanic
  creates.
- **Contract change, not addition:** `_test_springtail_corrects_the_non_spider_name`
  became `_test_fictional_profiles_name_themselves_as_invented`, a more general
  rule — every fictional record must say the spider is invented and must
  disclaim its own display name. Still nine biology contracts.
- `docs/decisions.md` — D-0027. `docs/current-state.md` updated.
- Build identity `0.17.0-buckler-test`, Android version code 33.

## Deliberately not done

- **No save migration.** Proven unnecessary; adding one would be risk without
  benefit.
- **No new fictional profiles.** The folio now invites them; the Phase 0 feel
  gate still governs when a roster grows.
- **No change to the other four mappings.** Only the profile whose name actually
  misinformed was touched.

## Verification

`python3 tools/verify.py --require-godot` green against Godot 4.7.1 stable —
**107 contracts passing** (49 physics, 9 biology, 22 HUD layout, 17 front-end
flow, 10 project/engine). Legacy-save resolution probed headlessly and confirmed
byte-compatible.

## Open owner questions (parked, not blocking)

1. Release roster — fictional names throughout, species names, or the current
   mix? Buckler and Skitter now sit at opposite ends of that spectrum, which
   makes the question easier to judge in the Garage.
2. Field Guide reach — Garage-only (as shipped), or also linked from Home?

## 💡 Idea

Buckler is the proof that an invented profile can carry a *better* field-guide
entry than a real one, because the invention creates a specific misconception
the entry gets to answer. That suggests the on-ramp pattern should be
deliberate: when a parked candidate from §6 eventually lands, ship the invented
version first with a correction pointing at the real animal, and add the real
animal's entry as the payoff.

- **📊 Model:** opus-5 · high · feature build
