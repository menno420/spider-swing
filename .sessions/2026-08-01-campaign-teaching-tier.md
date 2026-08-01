# Slice 2 — campaign teaching tier

> **Status:** `in-progress`

## Goal

Close the gap D-0033 names: the tutorial explains Reel, Burst and Dive across
six static text steps and then never asks the player to perform any of them.
Build short levels that each *require* one verb.

## Scope guard

Systems and progression only. No physics values touched, no zone content, no
new art. Levels are authored teaching fixtures built from the existing geometry
vocabulary, not new obstacle types.

## Previous-session review

**previous-session review:** slice 1 landed the difficulty baseline (PR #74,
main `066804a`). Its lesson for this slice is procedural: `main` moved three
times under that PR, once replacing an entire pattern pool the committed
measurement described, which forced a full re-measure before merge. Expect the
same here and re-check before letting anything land.

## 💡 Idea

"Requires the verb" should be a **contract, not a claim**. The simulator can
drive a level twice — once with the verb available and once with it suppressed
— and assert the level completes in the first case and fails in the second.
That turns the teaching guarantee into something the suite can falsify, which
is exactly what a taught mechanic needs: if a later tuning change makes the
Reel level passable without reeling, the suite says so.

- **📊 Model:** opus-5 · high · feature build — campaign teaching tier

## Next slice

*(filled in at close)*
