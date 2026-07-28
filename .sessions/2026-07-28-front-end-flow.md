# Front-end menu, tutorial, and settings session

> **Status:** `complete`

## Goal

Replace immediate gameplay startup with a real front-end flow: a clear Play route,
a complete animated tutorial, persistent settings that affect actual behavior,
and an in-game return-to-menu path.

## Scope guard

This session changed application composition, presentation UI, settings
persistence, gameplay input wiring, tests, build identity, and truthful ledgers.
It did not add Phase 1 obstacles, flies, progression, monetization, production
branding, or a prerecorded video asset.

## Previous-session review

**previous-session review:** PR #8 and Menno's real-device confirmation were
reviewed. Reel and DEBUG now work physically, so the obsolete
control-verification owner action is withdrawn. The physics baseline choice
remains open.

## Result

- The app mounts Home before creating the gameplay simulation. Home offers Play,
  Tutorial, and Settings.
- Tutorial is a responsive five-step in-engine animation covering automatic
  movement, web targeting, release and momentum, Reel energy, death boundaries,
  restart, Menu, and optional diagnostics.
- Settings persist through the exclusive `SaveRepository`: Balanced/Weighty/Agile
  swing candidate, control hints, reduced motion, and debug-tool visibility.
- Each setting has a real runtime effect; Reset Defaults is available.
- Gameplay now has a GUI-owned Menu button that safely releases held Reel input,
  tears down the lab, and returns to Home.
- Android identity is version `0.1.0-front-end`, version code 3, display name
  `Spider Swing Menu (dev)`.

## Ownership and capability delta

- `FrontEndState` owns navigation and validated settings state.
- `SaveRepository` remains the sole persistent writer and performs versioned,
  recoverable writes.
- The bootstrap composition root is the only code that mounts or unmounts the
  front end and simulation.
- Presentation consumes state and emits intent; it does not mutate simulation
  truth or persistent data directly.
- **capability delta:** the game now has a boot-first player front end and
  verified local settings persistence. No cloud save, account, analytics, store,
  or production-signing capability was introduced.

## Verification

- `game-quality` run
  [30361453579](https://github.com/menno420/spider-swing/actions/runs/30361453579)
  passed on Godot `4.7.1.stable.official.a13da4feb`.
- `tools/verify.py --require-godot` passed: 14/14 architecture fixtures, clean
  architecture scan, clean headless import and Home-first boot, and 31/31 runtime
  contracts.
- The seven front-end contracts include an actual filesystem write/load
  round-trip, not only dictionary serialization.
- `android-debug` run
  [30361449955](https://github.com/menno420/spider-swing/actions/runs/30361449955)
  passed from source `debc6a3f77caea5f0ee5cd014732e461dd4555f7`.
- Artifact `spider-swing-android-debug` ID `8688986336` is 56,692,335 bytes,
  expires 2026-08-11, and has digest
  `sha256:2e085948033f73684d5c3b9d77624f540892c5dd2ee0d420cbc5b06d729e155b`.
- Final `substrate-gate` and `game-quality` results are required on this completed
  card before PR #9 may merge.

## Docs audit

**docs audit:** added the front-end flow contract and updated README, application,
adapter and presentation ownership docs, the Phase 0 playtest guide, testing
guide, project index, current-state ledger, heartbeat, PR body, and Phase 0 issue.
The frozen GDD was not edited.

## Reversible decisions

- Use an in-engine tutorial animation now; a video can be added later if it adds
  teaching value beyond the maintainable interactive version.
- Keep all four settings local and versioned; there is no account or cloud-sync
  contract.
- Reuse the existing three Phase 0 swing candidates rather than inventing a
  fourth preset from an untested assumption.
- Keep the temporary development package identifier and ephemeral debug signing.

## Owner verification

Uninstall the old development app, install the artifact from Android run
30361449955, and launch **Spider Swing Menu (dev)**. Confirm Home appears before
the run, all five Tutorial pages are clear, Settings survive a relaunch, Play
applies the selected swing candidate, and MENU returns Home. Then select or
reject the candidate that should become the Phase 0 baseline.

## 💡 Idea

Use a data-driven tutorial step model rendered as a lightweight in-engine
animation. It stays synchronized with actual mechanics, localizes cleanly later,
and avoids a large prerecorded asset becoming stale after control or art
changes.

- **📊 Model:** gpt-5 · high · feature build
