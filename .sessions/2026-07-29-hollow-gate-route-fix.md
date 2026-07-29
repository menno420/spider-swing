# Hollow gate route fix session

> **Status:** `complete`

## Goal

Turn the Ancient Forest's closed round root obstacle into a physically traversable
split gate so its fly trail communicates a route the Classic spider can actually
follow.

## Scope guard

This session changes the gate's authoritative obstacle geometry, matching forest
presentation, deterministic route validation, documentation, and development build
identity. It does not retune spider physics, speed progression, rewards, course
frequency, or unrelated obstacles.

## Previous-session review

**previous-session review:** PR #22 added the first finished Ancient Forest art
slice while deliberately preserving existing course geometry. Menno's Android
recording of that build exposes a pre-existing topology error that the realistic
art made easier to see: a horizontal fly trail enters the centre of a closed ring,
but a 2D spider approaching from either side must collide with the ring wall before
it can reach the nominal hole.

## Decisions flagged

- The gate will become two separated upper/lower root arcs with an uninterrupted
  horizontal opening; visual and collision geometry must agree.
- Validation will sweep a Classic-sized circle along the advertised route rather
  than checking only isolated fly centres.

## 💡 Idea

Treat collectible trails as executable route contracts: every authored trail
segment should be clearance-tested against the same authoritative geometry used by
the simulation.

- **📊 Model:** gpt-5 · high · runtime bugfix

## Verification evidence

- Menno's 1040×480 Android recording was reviewed frame-by-frame. At roughly
  1019–1100 m, the fly line entered a visually hollow but collision-closed root
  ring; the spider died before reaching its centre because either side wall had
  to be crossed first.
- The regression was committed born-red before implementation:
  `Phase 0 physics — gate fly route is not traversable by a Classic-sized
  spider`.
- `python3 tools/verify.py --require-godot` passes on Godot
  `4.7.1.stable.official.a13da4feb`: 14 architecture fixtures, full architecture
  scan, clean import, boot, and 77 headless contracts. The physics group contains
  40 deterministic checks; the gate sweep clears roots plus floor/ceiling at
  80%, 112%, and 140% openings.
- A synthetic subprocess that printed `SCRIPT ERROR:` while exiting 0 was
  correctly rejected by `tools/verify.py`; `tests/test_runner.gd` also enforces
  the exact 77-check count.
- PR [#23](https://github.com/menno420/spider-swing/pull/23)
  `game-quality` run
  [30463832533](https://github.com/menno420/spider-swing/actions/runs/30463832533)
  passed on source `5e11740ccd249b5754114443316fa64207490de5`.
- Android run
  [30463832706](https://github.com/menno420/spider-swing/actions/runs/30463832706)
  passed and produced artifact
  [`spider-swing-android-debug`](https://github.com/menno420/spider-swing/actions/runs/30463832706/artifacts/8728752470),
  ID `8728752470`, 58,590,815 bytes, digest
  `sha256:7702d3245b236bb19eccc1a9a3e10a79d613bf0e4b6915c54d3f2a8abd154fd4`.
  A gameplay-identical artifact was downloaded; its 58,979,706-byte APK passed
  archive verification with SHA-256
  `670e78776eb7596a5c81328722ea08be655ed592d637de6df18f236a51ac0527`,
  and `build-info.txt` proved version `0.8.1-split-gate-test`.
- `python3 bootstrap.py check --strict` passes after this deliberate completion
  flip; before the flip, its only remaining blocking finding was the designed
  born-red session hold.

## Documentation audit

Passed. D-0015 records the open-movement-plane route rule; the superseded
four-piece gate grouping is explicit; current state, capability evidence,
testing counts, art provenance, runtime inventory, build identity, and owner
heartbeat all match the verified source. The byte-frozen GDD was not modified.

## Remaining owner review

Install `Spider Swing Split Gate (dev)` and follow fly trails through multiple
Ancient Forest root gates. Use Course Lab to test GATE at minimum, default, and
maximum GATE OPENING, then enable DEBUG once to compare both visible root arcs
with their exact lethal overlays. This is a reversible feel/readability review,
not an unverified engineering or publishing action.
