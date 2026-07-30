# Simulation lab v2 — adaptive bot session

> **Status:** `complete`

## Goal

Make the lab's player model adapt to the configuration it is handed — so
upgrade comparisons measure the tuning, not a bot's stale habits — and add
the instrumentation Menno's monetization/consumable direction needs: reel
usage styles, defensive save-Bursts, pull-death and rescue-distance metrics,
fly earn rate, and a parameter sweep mode for grid tuning.

## Scope guard

This session may change `tools/simulate.gd`, its documentation, the decision
ledger (recording the owner's money-as-grind-skip direction), and living-doc
pointers. It must not change any gameplay value, simulation rule, contract,
build identity, save schema, or CI gate. The declared suite remains 91
contracts; the lab stays diagnostic, never a gate.

## Previous-session review

**previous-session review:** PR #41 landed the simulation lab v1 green on
both gates; its first findings (skill scaling, Springtail's shell visible in
statistics, the never-emptying Reel meter, the maxed-upgrade regression for
an unadapting bot) directly shaped this session's scope. Menno confirmed the
Reel meter should become a managed resource and asked for upgrade-adaptive
simulation. PR #44 (Anchorite sprite) moved main under this branch; the
branch was restarted from the new head per the merged-PR rule.

## Shipped

- `tools/simulate.gd` — bot model v2. Adaptations derived from the resolved
  config: Reel reserve follows meter sustainability (regeneration vs
  drain), Reel engagement follows retraction rate, Burst aim shortens as
  the pull fraction grows, and a skill-scaled `care` habit consults the
  game's own pull-safety preview before committing. New options
  `--reel-style=adaptive|tap|hold`, `--save-bursts=on|off` (emergency Burst
  when no attachable web exists), `--start-m` (late-game warp at the pace
  curve's speed for that distance), and `--sweep=name:lo:hi:steps[,…]`
  (≤60-point grids over TuningCatalog ids or raw SwingConfig properties).
  New metrics: Reel held-time/energy-spent/time-at-empty, mid-pull deaths,
  rescue spend distance, save-Bursts, dives, and flies per km. JSON payload
  and summaries carry the bot model version.
- `docs/technical/simulation-lab.md` — v2 options, the adaptation rules in
  plain language, honest caveats including the early-game slow-reel
  divergence from the owner's device finding, and dated v2 observations.
- `docs/decisions.md` — D-0022: real money skips grinding, never buys
  exclusive power; consumables stay dual-currency with in-run collectible
  counterparts; paid exclusivity is limited to cosmetics.
- `docs/current-state.md` — In-flight refresh for this PR alongside the
  standing Anchorite/Reel device-review items.

## Decisions flagged

- Bot numbers are comparable only within one bot model version; summaries
  and JSON stamp the version so v1/v2 results are never mixed silently.
- The emergency save-Burst is deliberately rare (the attach fan almost
  always finds a web); modeling obstacle-anticipation saves is future work,
  not quietly faked.
- Where the bot's preference diverges from owner device evidence (slow reel
  early-game), the device wins and the divergence is documented rather than
  tuned away.
- A Reel regeneration delay — the most promising meter-pressure knob — does
  not exist as a gameplay parameter yet; adding it is a separate gameplay
  slice with its own device comparison, not lab work.

## 💡 Idea

Teach the bot obstacle anticipation: a short forward sweep against upcoming
obstacle polygons (the same geometry the player sees) that triggers an early
release, Reel, or save-Burst. That would make "great saves if you time them
right" measurable and let the lab price Burst cooldown against save
opportunity, not just opportunistic use.

- **📊 Model:** fable-5 · high · feature build

## Capability delta

None new. In-container Godot 4.7.1 and the lab's batch path were re-proven
by this session's runs (sweep grids, late-game warps); no new wall was hit.

## Verification evidence

- `python3 tools/verify.py --require-godot` on pinned
  `4.7.1.stable.official.a13da4feb`: all steps PASS, 91/91 contracts, after
  the v2 rewrite (import parses the script; architecture scan green).
- Lab evidence, adaptive bot, balanced preset: level 0 vs maxed-upgrade
  intermediate means 1 248 m vs 1 173 m (v1 gap ≈−13% → ≈−6%, medians
  1 289/1 191, shared p90 wall ≈1 571 m); greedy `hold` reeling never
  empties the 2.0 s meter (≈4 s held per run in short bouts);
  `--start-m=4000` runs survive ≈350 m at intermediate with rescue spent at
  ≈4 150 m; `--sweep=reel_rate:260:440:4` runs clean both at start 0 and
  warped starts.
- Strict Substrate check with CI's exact added-card invocation
  (`--session-log .sessions/__born-red-card-added__.md --added-card <card>`):
  all checks passed with this card complete; guard-fire telemetry delta
  committed with the session.
- PR opened from `claude/spider-swing-review-gujydb` after this card flip;
  `game-quality` and `substrate-gate` evidence lands on the PR, which the
  session drives to green and merges per the land-on-green rhythm.

## Documentation audit

`simulation-lab.md`, the decision ledger, current-state, and this card
agree: adaptive diagnostic tooling, two gates unchanged, 91 contracts
unchanged, no gameplay values touched, monetization direction recorded as
D-0022.

## Remaining owner review

Nothing playable changed. The lab's late-game numbers say a rescue life is
worth ≈150–250 m at 4 000 m pace — worth keeping in mind when pricing the
planned second life in flies. The Reel-pressure question now has a concrete
next step: a gameplay slice adding a regeneration-delay parameter, swept in
the lab first, then one isolated device comparison.
