# Production spider roster art session

> **Status:** `complete`

## Goal

Correct the Garden Spider's confusing visible-leg topology, integrate the
owner-approved Skitter, Ballooner, and Springtail production sprites through
the shared presentation-owned renderer, and land exact engine and Android
evidence without changing authoritative collision or movement.

## Scope guard

Production character art, presentation routing, asset contracts,
documentation, and build identity only. Preserve all approved profile tuning,
physics, collision radii, input behavior, upgrades, progression, and save data.

## About to happen

Garden will be restaged to four visible near-side legs plus two recessed
far-side front legs; all five profiles will then use one finished-sprite path
with transparent 384×181 sources, mipmaps, radius-based scaling, and regression
coverage at source and gameplay size.

## Previous-session review

**previous-session review:** PR #50 merged the biology/Field Guide layer before
this build began, correcting the old Skitter brief from stocky/short-legged to
the slender *Lyssomanes viridis* body plan. PR #51 then landed this task's work
claim. The three generated candidates had already received direct owner
approval in conversation; Garden alone still needed the same 4+2 leg staging.

## Shipped

- `assets/runtime/characters/` — corrected Garden plus new Skitter, Ballooner,
  and Springtail transparent 384×181 sprites; all five have mipmapped imports,
  clean frame alpha, no visible magenta key, and a committed reference manifest.
- `game/presentation/scripts/art_asset_catalog.gd` — one profile-to-asset map
  and one cosmetic-tint function shared by every presentation surface.
- `game/presentation/scripts/swing_lab.gd` — all profiles now use the existing
  radius-scaled finished-sprite renderer; procedural drawing remains only a
  missing-texture fallback.
- `game/presentation/scripts/front_end.gd` — one reusable, aspect-preserving,
  touch-transparent sprite preview serves both Garage selection and Shop
  upgrades, using the same asset and tint contract as gameplay.
- `tests/unit/mobile_hud_layout_tests.gd` and
  `tests/integration/front_end_flow_tests.gd` — roster parity, source size,
  mipmaps, transparent full-frame edges, chroma rejection, shared renderer,
  and Garage/Shop preview routing.
- `docs/decisions.md` D-0027 — the 4-near + 2-far-front visible-leg convention.
  Runtime/presentation/test docs and build identity now match the five-profile
  roster.

Remote implementation commits: `5f12c7b` (sprites and shared renderer),
`229b18d` (derived asset census), and `89434f4` (Garage/Shop previews).

## Deliberately unchanged

No simulation, collision geometry, collision radius, profile tuning, input,
ability, upgrade, progression, save, economy, course, or settlement behavior
changed. All five sprites remain presentation consumers of authoritative
profile state. No release signing, production package, store action, or public
branding was added.

## Verification

- `git diff --check` — clean.
- `python3 tools/check_architecture.py` —
  `check_architecture: OK -- inward dependencies hold`.
- `python3 tools/verify.py` — engine-independent checks pass locally; engine
  steps honestly skip because this container has no Godot executable.
- PR #52 `game-quality` run `30632785741` — Godot
  `4.7.1.stable.official.a13da4feb`, clean import, clean front-end boot, and
  **107/107 contracts pass** at exact implementation source `89434f47…`.
- PR #52 Android run `30632785775` — artifact `8794039474`, published ZIP
  SHA-256 `0dee328a11fe2889eff54d69dabd0627f6e17d7ca1eef90504262e0e75905deb`;
  outer ZIP and APK archives pass; `build-info.txt` proves build
  `0.17.0-five-spider-art-test` from exact source `89434f47…`; APK SHA-256
  `9f213e621fa1893541a93fbbb8ebd95d7057ab23dc4f2953a4960eb664f2889c`;
  all five imported character textures are packaged.

## Decide-and-flag

- The Garden correction uses the owner-approved six-visible-leg convention and
  preserves its dark/orange identity, but any generated correction necessarily
  repaints some pixels around the legs. Device review remains the final visual
  gate; reverting one PNG is isolated from code and gameplay.
- I extended integration into Garage and Shop because otherwise the production
  art would remain invisible during selection and upgrades. The reusable preview
  consumes existing state and is reversible presentation-only work.

## Idea grooming

The raw “show the real roster before Play” opportunity was groomed and shipped
as the shared Garage/Shop preview in this session rather than being left as a
note.

## 💡 Session idea

After device review confirms the 118×56 preview is readable on the owner's
phone, evolve the text-only profile grid into a horizontal silk-thread carousel
of compact sprite cards. Reuse the same preview component and selection signal;
do not introduce a second roster model or another scroller until the current
mobile scroll behavior is verified.

## PR

PR #52 is ready and green on the complete implementation head except for the
designed born-red hold. The final closeout head must rerun governance, pinned
Godot, and Android and may merge only after all required checks are green.

- **📊 Model:** gpt-5.6-sol · high · production art and integration
