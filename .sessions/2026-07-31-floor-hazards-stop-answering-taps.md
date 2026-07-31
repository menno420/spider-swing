# Floor-grown hazards stay lethal but stop answering web taps

> **Status:** `complete`

## Goal

Stop accidental Dive Pulls without touching the Dive itself, by making web
anchor eligibility depend on which rail a hazard grows from.

## Scope guard

One domain field and its accessor, seven tag sites in the course stream, one
filter in the anchor search, one contract, and the records. No physics values,
no collision change, no change to the Dive's availability or reach.

## Previous-session review

**previous-session review:** PR #63 fixed the death-confirmation window and the
tutorial's Burst ordering, and falsified its own contract before trusting it —
worth keeping as a habit. The miss it should be judged on is an argument, not
code: it pushed back on the owner's proposed anchor fix by claiming the floor
rail sits under the spider "constantly" and would keep eating release taps. That
was asserted from stills without measuring anything, and it was wrong. The owner
knew where his taps land; the session did not. Measure or ask before
contradicting a report from play.

## What the owner reported

> "all the accidental dives have been from obstacles and not from the floor,
> since most of the time I'm using a consistent area for my taps, release and
> anchor points both the same, only different aiming point is for the dives"

That is the whole diagnosis. Release and attach are aimed at the same place, and
only a Dive is aimed somewhere else — so anything tappable that sits *below* the
spider inside that shared aiming area will steal releases. The floor never did,
because it is nowhere near that area. Obstacles did, because they are.

And the constraint that rules out the tempting shortcut:

> "The whole purpose of the dives is to give you a way to go down quickly, which
> is really necessary and so it must be always available"

So the Dive target itself cannot be restricted. The fix has to be on the anchor
side.

## What shipped

Anchor eligibility is now a property of the hazard, not of the tap direction.

- `game/domain/course_geometry.gd` — `obstacle_anchorable`, parallel to
  `obstacles`, with `append_obstacle(polygon, anchorable)` and
  `is_obstacle_anchorable(index)`. An index past the end reads as anchorable, so
  geometry assembled without the flag keeps the old behaviour — several existing
  contracts build geometry by hand and must stay meaningful.
- `game/application/course_stream.gd` — all **seven** obstacle creation sites
  tagged. Growth direction was already encoded and was verified against each
  polygon rather than trusted from the function name (+y is down):
  `_append_leaf_cluster` and `_append_root_stump` follow their own `hanging`
  flag; `_append_vine_fork` builds upward from `floor_y`, so floor-grown;
  `_append_hanging_seed_pod` builds down from `ceiling_y`;
  `_append_split_root_gate` appends its two halves separately, so its upper root
  stays tappable and its lower root does not.
- `game/simulation/simulation_world.gd` — `nearest_solid_point` skips
  non-anchorable obstacles. **`_collision_at` is untouched and still iterates
  every obstacle**, so untappable never means safe to touch.
- `tests/unit/phase0_physics_tests.gd` —
  `_test_floor_grown_hazards_are_lethal_but_not_tappable`.
  `EXPECTED_CHECK_COUNT` 120 → 121.
- `README.md`, `docs/current-state.md` — the README's "Every solid edge is a
  valid target" was made false by this change and is corrected.

This moves the implementation *toward* the GDD rather than away: §7.1 already
says "webs attach only to surfaces or anchor volumes marked as web-compatible."
Everything being anchorable was the deviation.

## The one case the owner's rule does not name

Floating silk-suspended seed burrs are neither floor-grown nor ceiling-grown.
Taken literally — "obstacles hanging from the ceiling should still be valid…
those coming from the floor should not" — a burr hangs, so it stays tappable,
and that is what shipped. The argument for flipping it is that a burr sits
mid-field at exactly tap height, which is the geometry that causes the problem
in the first place; the argument against is that its silk runs to the ceiling
and the owner's rule is about origin. Left as the owner stated it rather than
substituted with a guess. One boolean at the burr's tag site flips it.

## Verification

Real exit codes, no pipes:

- `python3 tools/verify.py --require-godot` against Godot 4.7.1 stable →
  **exit 0**, **121 contracts**.
- **Falsified before trusted.** Disabling only the anchor-search filter →
  `FAIL — 1 failed`, reporting "floor-grown hazard still answered a tap and can
  steal a release". Restoring it → `PASS — 121`.
- The contract also pins the parts that must *not* move: the ceiling-grown twin
  still answers a tap, the floor-grown one still collides, the flag survives
  `duplicate_geometry`, and untagged geometry still defaults to tappable.
- `python3 bootstrap.py check --strict` → green, run after committing so the
  diff-aware card rules apply.

## Open owner questions

**Dive charges — deliberately not added.** The owner raised a second Dive charge
in the same message, motivated by accidental dives wasting the one he has. That
motivation should be largely gone now, so this is worth re-feeling before
building: Dive rearming only through an upper attach is what forces the
drop-climb-drop alternation, and a second charge lets a player chain two drops
and skip the climb. Adding a resource to absorb an input bug would have hidden
the bug; the bug is fixed instead.

**Reel is not under-powered.** The owner described Reel as early/mid-swing
correction that is too slow to save a bad line. At 320 px/s against 760 px/s of
travel that is arithmetic, and it reads as GDD §23's "Reel-In is useful without
being mandatory" being satisfied. Logged as gate evidence, not as a complaint.

## 💡 Idea

Anchor eligibility is now real data, so the aim guides could tell the truth for
free: the off-by-default web-target guide already knows which solids it draws,
and drawing it only for anchorable geometry would make the new rule visible
instead of something the player infers from misses. Cheap, presentation-only,
and it would answer "why did nothing attach there" before it becomes a question.

- **📊 Model:** opus-5 · high · runtime bugfix — surface-typed web anchors from
  device evidence
