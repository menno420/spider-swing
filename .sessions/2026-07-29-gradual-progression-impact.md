# Phase 0.13 gradual progression and impact survival

> **Status:** `in-progress`

## Goal

Turn the latest owner playtest direction into one reversible comparison build:
stretch the forward-speed progression across several kilometres, make shaped
ceiling/floor rails lethal by default, give the starter spider deliberately
modest pull tools with meaningful upgrade headroom, and test a limited
surface-impact survival archetype without creating permanent invulnerability.

## Scope

- Keep maximum pace exciting while moving its practical arrival from the first
  few hundred metres to roughly 5000 m.
- Preserve continuous ceiling/floor structure while authoring upper bypass,
  lower bypass, open-choice, tight-gate, and recovery corridor profiles.
- Make visible course rails lethal by default while retaining DEBUG comparison
  controls.
- Add explicit starting pace, maximum pace, acceleration distance, Burst
  minimum distance, and corridor/impact controls to the touch-first DEBUG lab.
- Reduce Classic Reel-In and Burst strength and add bounded, profile-specific
  upgrade tracks over the same authoritative configuration.
- Add one impact-survival profile whose charged shell converts a qualifying
  rail impact into a controlled bounce, then requires a normal upper-web
  attachment before it can recharge.
- Keep obstacle collision lethal, keep every change deterministic, and do not
  introduce billing, production entitlements, or shared course publication.

## Previous-session review

**previous-session review:** PR #18 added the guided opening, one explicit
rescue, four centralized spider profiles, fly-funded laboratory upgrades,
scaled hazards, and a local Course Lab. Menno's follow-up runs now reach beyond
2000 m and roughly 4000 m with the gliding profile, proving that later mechanics
can be evaluated; the remaining pacing issue is that the current exponential
speed curve is effectively complete before the first kilometre.

## 💡 Idea

Treat impact survival as a traversal rhythm rather than health: one charged
surface shell may bounce a qualifying floor/ceiling hit, but it is spent until
the player earns another successful upper-web attachment. The same explicit
charge/rearm pattern already proven for Dive keeps the ability legible,
skill-dependent, and impossible to spam.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

- **Implementation:** `SwingConfig` now uses an exact smooth 5000 m default
  speed ramp, lethal shaped rails, 400 px/s base Reel, 40% base Burst, and
  80 px minimum Burst travel. `CourseStream` keeps a quiet opening screen,
  continuous seams, obstacle-correlated bypasses, and late tight gaps. All
  values remain editable through eight plain-language DEBUG sections.
- **Progression:** all five centralized profiles expose three five-level
  laboratory tracks. Springtail alone gets one moderate free-flight rail
  bounce; it spends immediately, rearms only after a normal upper web, and
  never protects against obstacles, hard impacts, pulls, or a second hit.
- **Local checks:** `git diff --check`, the 14-fixture architecture self-test,
  and the full architecture scan pass. `python3 tools/verify.py` passes every
  available host check; engine steps report an honest skip because this
  workspace does not contain Godot.
- **Godot proof:** PR #19
  [`game-quality` run 30444418170](https://github.com/menno420/spider-swing/actions/runs/30444418170)
  passes import, boot, 38 deterministic physics checks, 15 mobile GUI
  contracts, 11 front-end contracts, and 10 bootstrap/build checks—74 total—on
  Godot 4.7.1 at gameplay source
  `bc582e25a2a2fd7d6da18ed2cf127cc568b834ca`.
- **Android proof:** PR #19
  [`android-debug` run 30444418230](https://github.com/menno420/spider-swing/actions/runs/30444418230)
  passes and produces downloadable artifact
  [`spider-swing-android-debug` ID 8720817780](https://github.com/menno420/spider-swing/actions/runs/30444418230/artifacts/8720817780),
  56,859,911 bytes, digest
  `sha256:ba83d0a7c1f6cd64706da933f3d6e08af10459fcf6d1f28c231228a3842863ef`.
  The workflow proves package `com.menno420.spiderswing.dev`, version code
  `13`, and version `0.6.0-gradual-progression-test`; the connected download
  endpoint returned the ZIP successfully.
- **Docs audit:** README, current state, capability ledger, decision ledger,
  testing/playtest guide, simulation/application/presentation boundaries, and
  heartbeat match the implemented source. The checksum-pinned GDD is unchanged.
- **Reversible decisions flagged:** 5000 m is a comparison default rather than
  a fixed balance promise; Springtail recovery is a single rearmable traversal
  charge rather than generic health; the first screen remains flat so the
  deterministic training web stays readable; all three remain centralized and
  DEBUG-adjustable.
- **PR:** [#19](https://github.com/menno420/spider-swing/pull/19) was opened
  ready while the session card's designed hold was active.
