# Phase 0.10 gameplay foundation pass

> **Status:** `in-progress`

## Goal

Turn Menno's latest Android playtests and design direction into one coherent
next build: more predictable vertical control, an optionally self-shortening
rope, safer and more varied course patterns, explicit ceiling/floor experiments,
and a small progression-ready gameplay slice that does not duplicate simulation
or persistence ownership.

## Scope

- Keep gravity, Dive Pull, Burst, Reel, aim, range, and all new feel controls
  editable in the DEBUG panel.
- Promote the 1120-gravity / 40%-Dive candidate for the next controlled test.
- Add configurable natural rope take-up that retains a chosen percentage of
  inward movement without becoming another speed impulse.
- Keep continuous authored ceiling/floor rails with deliberate gaps, and allow
  their presence and lethality to be compared through DEBUG.
- Keep the opening 1000 m free from mid-lane hazards, then introduce validated
  lower anchors, readable route choices, and a larger organic graybox shape
  vocabulary.
- Add a predicted Dive path diagnostic so unsafe target routes are visible.
- If the existing boundaries support it cleanly, add deterministic fly
  collection, one temporary Burst-cooldown boost, persistent settlement, and
  initial cosmetic unlock progression through named owners rather than UI-owned
  writes.

The checksum-pinned GDD remains unchanged. Production art, monetization, store
publishing, analytics, cloud save, and a finalized upgrade economy are outside
this session.

## Previous-session review

**previous-session review:** PR #15 solved duplicate Android world intents and
Menno's subsequent recordings show that gravity 1120 produces longer,
more-readable runs. Dive Pull at 35% now creates useful lane changes, but 40% is
the next candidate. Some remaining deaths come from unsafe lower-anchor paths
through central obstacles, so pull strength and course validation must be
improved together.

## Decisions flagged

- Keep the movement lab as the one authoritative configuration surface.
- Treat permanent upgrade values as modifiers over a base `SwingConfig`, never
  as independent physics implementations.
- Start progression with one end-to-end, testable slice before adding a broad
  catalogue of currencies, boosts, spiders, or upgrade types.

## 💡 Idea

Generate collectible trails and lower-anchor windows from the same deterministic
route descriptor used by obstacle geometry. A course can then prove that its
visual hint, safe traversal line, collectible line, and recovery anchor describe
one route instead of four independently drifting systems.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

Born red. Exact local and CI results, PR/workflow URLs, artifact identity, and
documentation audit will be recorded before the final status flip.
