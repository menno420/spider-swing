# Mobile Test Run scrolling

> **Status:** `complete`

## Goal

Make every Test Run setup control and the primary start action fully reachable on phone viewports through one native vertical scroller, while preserving the existing session-only tuning and noncompetitive-run contracts.

## Scope guard

Presentation layout and its mobile/integration contracts only. Do not change bird tuning, upgrade values, progression, persistence, simulation, or ordinary Play.

## Planned verification

- Falsify the new scroll/layout contract before trusting it.
- `python3 tools/verify.py --require-godot`
- `python3 bootstrap.py check --strict`

## Shipped

- `game/presentation/scripts/front_end.gd` puts the staged Test Run conditions
  in the shared native touch scroller and pins the 68 px start action below it.
- `tests/integration/front_end_flow_tests.gd` rejects a disabled vertical
  scroller or a start action placed back inside the overflowing content.
- Build `0.26.1-debug-scroll-playtest`, Android code 46, and the living depth
  handoff identify the independently installable slice.
- Remote implementation commit: `022a529ac23b431de57ec4a1caff500edec28d1e`.

## Measured layout

Godot 4.7.1 laid out the real `FrontEndView` for two frames in a headless
`SubViewport`, at one-pixel rectangle resolution. At 1280×720 the body has
76 px of scroll travel and the full start rectangle is enclosed by the card.
At 1280×600 it has 164 px of scroll travel and the same 68 px action remains
fully enclosed.

## Adversarial verification

- Setting `DebugRunSetupScroll` to `SCROLL_MODE_DISABLED` turned the front-end
  contract red for the intended Test Run scroll failure.
- Moving `DebugRunStart` back into the scrolling body independently turned the
  same contract red for the intended pinned-action failure.
- Both mutations were restored before the final gate.

## Verify

- `python3 tools/verify.py --require-godot`: exact Godot
  `4.7.1.stable.official.a13da4feb`; 197/197 contracts passed.
- `python3 bootstrap.py check --strict`: passed after this final lifecycle
  flip; advisory capability/headroom/stale-wall notes remain non-exit-affecting.

## Previous-session review

**previous-session review:** the earned-speed bird PR correctly supplied three
session-only chase tunables and a phone-sized setup card, but its static vertical
composition assumed the whole 533 px card remained usable. The owner found the
real failure immediately: the launch action was partly clipped and there was no
scroll path to it. This slice fixes the shared layout seam without touching any
of the bird or traversal values he was trying to test.

## Owner questions

None. The reported clipping has one reversible presentation fix and does not
need a product fork.

## 💡 Session idea

The menu-theme slice should extract a reusable `scroll body + pinned primary
action` shell before another expanding setup form needs it. The visual web and
texture layer can then decorate that shell without owning navigation or touch
behavior.

## Next slice

Expand all upgrade tracks from 20 to 40 levels with proportional save migration, a longer fly-cost curve, smaller per-level gains, and a larger level-40 total reward.

- **📊 Model:** gpt-5 · high · feature build
