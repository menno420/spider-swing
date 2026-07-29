# Phase 0.16 forest biome art pass

> **Status:** `in-progress`

## Goal

Turn Ancient Forest from a repeated material comparison into one cohesive,
production-quality visual slice with natural boundary edges, environment-native
hazards, and readable Classic spider and fly art.

## Scope

- Add a seamless tree-branch treatment for the lethal ceiling and floor without
  changing authoritative collision geometry.
- Add a small, deliberate set of thorned bramble and hanging-vine obstacle
  sprites whose visible silhouettes remain honest about their hit regions.
- Replace the prototype Classic spider and fly drawing with polished,
  small-screen-readable sprites.
- Keep collision outlines available only in DEBUG and preserve Graybox plus the
  existing comparison themes.
- Record asset provenance, validate runtime imports, and ship a testable Android
  artifact.

## Previous-session review

**previous-session review:** PR #21 proved four lightweight texture packs and a
safe presentation-only theme seam, but its single repeated tile made walls and
obstacles monotonous. This pass builds on that seam and separates boundary,
hazard, character, and collectible art while preserving the playable geometry.

## 💡 Idea

Treat the biome as a small visual grammar rather than one texture: bark is the
mass behind the corridor, branches define its collision edge, and distinct
rooted or hanging plants communicate each hazard's origin and lethality.

- **📊 Model:** gpt-5 · high · feature build

## Verification evidence

In progress.
