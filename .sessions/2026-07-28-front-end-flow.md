# Front-end menu, tutorial, and settings session

> **Status:** `in-progress`

## Goal

Replace immediate gameplay startup with a real front-end flow: a clear Play route, a complete animated tutorial, persistent settings that affect actual behavior, and an in-game return-to-menu path.

## Scope guard

This session changes application composition, presentation UI, settings persistence, gameplay input wiring, tests, build identity, and truthful ledgers. It does not add Phase 1 obstacles, flies, progression, monetization, production branding, or a prerecorded video asset.

## Previous-session review

**previous-session review:** PR #8 and Menno's real-device confirmation were reviewed. Reel and DEBUG now work physically, so the obsolete control-verification owner action can be withdrawn. The physics baseline choice remains open.

## 💡 Idea

Use a data-driven tutorial step model rendered as a lightweight in-engine animation. It stays synchronized with actual mechanics, localizes cleanly later, and avoids a large prerecorded asset becoming stale after control or art changes.

- **📊 Model:** gpt-5 · high · feature build
