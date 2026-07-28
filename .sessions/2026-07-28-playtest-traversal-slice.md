# Phase 0.5 mobile traversal and obstacle test session

> **Status:** `in-progress`

## Goal

Turn Menno's second Android playtest into the next coherent laboratory slice: readable scrolling Settings, thumb-safe action controls, continuous ceiling attachment, a deterministic forward Burst, a course that streams beyond the original anchor field, and a small fair obstacle vocabulary.

## Scope guard

This session may change Phase 0 domain, simulation, application, input, presentation, tests, documentation, and debug build identity. It will not add currency, collectibles, unlocks, permanent progression, monetization, production art, or treat graybox obstacle tuning as approved Phase 1 content.

## Previous-session review

**previous-session review:** PR #9 and Menno's 1040×480 recording were reviewed. Home, Tutorial, Settings, Play, Menu, Reel, and DEBUG work on-device. The recording proves the Settings card is too small and clipped; the owner's run also reveals the finite anchor field, Reel reach cost, dot-only targeting limitation, and need for an avoidance test.

## Decisions flagged

- Add one authoritative `BURST` command reached by both a large button and an optional double-tap shortcut; the simulation owns cooldown and impulse.
- Model the upper attachment area as repeating ceiling surface segments while retaining small visual markers only as aim guidance.
- Stream deterministic chunks around the player instead of prebuilding a finite course.
- Start with static posts, gates, and low barriers; defer moving obstacles until the readable collision contract is proven.

## 💡 Idea

Use a deterministic chunk descriptor as the single source for ceiling surfaces, visual hints, and collision geometry. The same small set can loop with mirrored height/pattern variation, later gaining flies and moving obstacles without creating a second world-generation system.

- **📊 Model:** gpt-5 · high · feature build
