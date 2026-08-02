# Forty-level upgrade progression

> **Status:** `in-progress`

## Goal

Expand every spider’s seven upgrade tracks from 20 to 40 levels. Ordinary tuning steps become smaller, five-level breakthroughs continue, and the level-40 total is stronger than today’s level-20 maximum.

## Scope guard

One progression migration slice: catalog limits/formulas/costs, schema migration, purchase and debug bounds, Shop/Garage copy, replay compatibility, build identity, tests, and living docs. Preserve the zero-level approved baseline, bird defaults, course geometry, difficulty rules, currencies, and authoritative simulation architecture.

## Intended balance

- `assumed`: each tuning step carries 70% of the old numerical gain.
- `inferred`: 48 effective steps at level 40 deliver about 140% of the old 24-step level-20 effect.
- Existing schema-7 level N migrates proportionally to level 2N, so an owned maximum remains maximum.
- Reel changes rope shortening only; no drive or direct horizontal velocity is added.

## Planned verification

- Falsify migration, cost, formula, UI-limit, and replay contracts independently.
- `python3 tools/verify.py --require-godot`
- `python3 bootstrap.py check --strict`

## Previous-session review

**previous-session review:** PR #104 correctly made the expanding Test Run form
scrollable while keeping its start action pinned. Its next-slice handoff named
progression as the highest-value independent change. The attached L20 high-speed
playtests also show that Reel remains useful for planned height changes at the
new pace, supporting a modest maximum Reel increase without a direct speed grant.

## Shipped

- All 35 tracks now span L0–L40 with eight five-level breakthroughs. Numerical
  tuning steps resolve at 70% of their old size; 48 effective L40 steps produce
  140% of the former L20 maximum.
- The forty-step cost curve totals 490 flies per track, 3,430 per spider, and
  17,150 for all five. Schema 8 doubles schema-7 ownership exactly once.
- Anchor Drive's second stored Burst moves to L20. Test Run quick levels are
  `OWNED`/L0/L20/`MAX` and the trace identity is `@4`.
- Max Garden Reel rises from 416 to 454.4 px/s and its full max meter from 2.48
  to 2.672 seconds. Reel still shortens rope and never adds velocity directly.
- Build identity is `0.27.0-forty-level-progression-playtest`, Android code 47.

## Adversarial verification

Six temporary production mutations each turned the exact engine suite red for
the intended contract: 71% step scaling, skipped schema-7 doubling, a 489-fly
cost curve, an L20 `MAX` quick selector, the reserve Burst at L10, and a stale
`@3` trace catalog. Every mutation was restored before the final gate.

## Verification evidence

- Exact Godot `4.7.1.stable.official.a13da4feb`: 197/197 contracts passed.
- The L0/bird-off `@4` fixture reproduces exactly at 2,894.978 m and 49.733 s.
- `git diff --check` passes. `python3 bootstrap.py check --strict` is rerun
  after the final lifecycle flip; advisory capability notices are non-blocking.

## 💡 Session idea

Make the menu-theme slice a reusable presentation layer: web corner ornaments,
fibrous panel texture, and spider-specific accent tokens should decorate the
existing scroll/navigation shells without owning layout or input behavior.

## Next slice

Create the reusable spider-web menu presentation layer without changing navigation or gameplay.

- **📊 Model:** gpt-5 · high · feature build
