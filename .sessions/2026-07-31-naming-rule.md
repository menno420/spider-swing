# Naming rule — real name first, otherwise name the science

> **Status:** `complete`

## Goal

Settle the naming question the real-first policy opened, on the owner's rule:
use a real spider's name where one is usable; where none is, invent a good name
and have the Field Guide explain the scientific name(s) the invented spider
draws its abilities from — including where several real spiders each contribute
one part.

## Scope guard

Identity, data, and documentation. No physics, collision, economy, upgrade, or
tuning value changed. One presentational change: the Garage roster font drops
20 → 17 so the longest real common name fits its column.

## Previous-session review

**previous-session review:** PR #53 was open and green on this branch carrying
the Buckler rename, the research verification, and the real-first policy
(D-0030). That policy set the priority but left the remedy for invented cases
unstated, which left two profiles — Skitter and Buckler — as open owner
questions. The owner answered both with a general rule.

## The rule

**A real spider with a usable name always wins.** Where none exists, invent a
good name — and the Field Guide then owes the player the science instead: every
real spider the profile borrows from, named, **and what each one contributes**.
One invented spider may deliberately combine several real ones; that is the
point, not a compromise.

That last part is what made `drawn_from` a list rather than a single reference.

## Shipped

- **Skitter → Magnolia Green Jumper.** *Lyssomanes viridis* has a usable common
  name, so the invented one had no justification. The persisted id stays
  `skitter`, like every other internal key.
- **Buckler keeps its invented name.** *Cyclocosmia* has no settled English
  common name a player would recognise, and the profile genuinely blends two
  genera. Its guide entry now names both with their contributions:
  - *Ummidia* Thorell, 1875 — the compact glossy body and hinged trapdoor
  - *Cyclocosmia* Ausserer, 1871 — the hardened abdominal disc
- **`name_origin` and `drawn_from` in `SpiderBiologyCatalog`.** Every record
  declares whether its display name is real or invented, and lists the real
  spiders behind it — accepted name, authority where verified, family, and what
  that animal contributes.
- **Field Guide renders it**: `SCIENTIFIC NAME · …` for a real-named profile,
  `ABILITIES DRAWN FROM · …` for an invented one, each animal followed by its
  contribution.
- **An eleventh biology contract** fails the build if an invented name ships
  without that list, if any entry omits its contribution, or if a species-level
  record borrows from anything but the one animal it claims to be.
- `docs/decisions.md` — **D-0031**. Folio §2 now leads with the naming rule and
  the five audited against it. `docs/owner-questions.md` — OQ-1 answered.
  `docs/current-state.md` updated.

## Verification

`python3 tools/verify.py --require-godot` green against Godot 4.7.1 stable —
**109 contracts passing** (49 physics, 11 biology, 22 HUD layout, 17 front-end
flow, 10 project/engine). `python3 bootstrap.py check --strict` green.

Garage roster width measured headlessly at 1280×720 **with the selected tick
prefixed**, which is the widest state: "✓ MAGNOLIA GREEN JUMPER" is 239 px in a
281 px button at font 17. All five fit.

Field Guide copy rendered and read back to confirm both line forms.

## Deliberately not done

- **No change to the persisted ids.** `skitter` and `springtail` remain the
  storage keys, consistent with every earlier rename decision; no save migration.
- **No asset filename churn.** Same reasoning.
- **No new profile.** The rule now makes combining several real spiders into one
  invented profile explicitly legitimate, but adding one is still gated.

## Open owner questions

Only OQ-2 remains: Field Guide on Home, or Garage-only as shipped.

## 💡 Idea

The `contributes` field makes a genuinely new kind of Field Guide entry
possible: for a combined profile, show the borrowed animals as a short list with
a thumbnail each, so a player can see that Buckler is two real spiders wearing
one name. That is the clearest possible statement of the rule, and it needs no
new data — only art for the animals already named.

- **📊 Model:** opus-5 · high · feature build
