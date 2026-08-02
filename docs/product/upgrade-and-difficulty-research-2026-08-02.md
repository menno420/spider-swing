# Upgrade and difficulty research — external benchmarks plus a source audit, 2026-08-02

> **Status:** `reference`
>
> Combines two owner-supplied external research sessions with a **source
> re-verification pass** against `main` @ `5afa54a`. It is the companion to
> [`player-preference-research-2026-08-02.md`](player-preference-research-2026-08-02.md):
> that document set the 25 km north star, this one supplies the comparative
> evidence and the code-level audit of why the current build does not reach it.
>
> **Nothing here is a decision**, with one exception recorded after the fact:
> the leaderboard fork in § 4.4 was answered by the owner and is now **[D-0045]**.
> No physics, progression, course, or bird value is changed by this document.
>
> **Still current after PR #109 merged** (build `0.30.0-menu-system-playtest`).
> Re-checked: none of the eight source files behind the § 2 findings moved
> between `5afa54a` and the merge — `course_pattern_catalog.gd`,
> `course_region_catalog.gd`, `spider_catalog.gd`, `spider_motor.gd`,
> `simulation_world.gd`, `swing_config.gd`, `course_stream.gd` and
> `swing_lab.gd` are byte-identical. `swing_lab_session.gd` did change, and the
> trace/recording seams cited in § 5.2 were re-confirmed present in it.

## ⚠ Provenance — read before quoting anything

Two sources, with **very different evidential weight**, and they must not be
quoted as if they were one thing.

| Source | What it is | Weight |
| --- | --- | --- |
| **Session A — external benchmark research** | A third-party deep-research synthesis of difficulty curves, skill ceilings, progression and monetisation across commercial endless games | `inferred` — same class as the Grok synthesis in the preference-research doc. Its inline citation markers did not survive extraction, so **the underlying sources have not been verified from this repository** |
| **Session B — repository systems review** | A read-only, source-grounded review of this repository at commit `5afa54a` | Claims re-checked here against live source. **Every repo claim reproduced below was independently verified in this session**, with file and line |

**The re-verification is the point.** Session B made a number of claims about
this codebase. Some were new and correct, one corrected an error in a previous
Claude session's analysis, and none were taken on trust. Each finding in § 2
carries the source location that establishes it.

Session A's *transferable design reasoning* is useful. Session A's *numbers about
other games* are third-party and uncited here — treat them exactly as the
preference-research doc's provenance block requires: weaker than anything in
`docs/measurements/`, never quoted as measured.

---

# 1 · External benchmark evidence (Session A — `inferred`)

## 1.1 The findings that change how the 25 km target should be read

**Expert performance does not require continuously accelerating difficulty.**
Canabalt is reported to use sharply *diminishing* acceleration — roughly 100 px/s
start toward an 800 px/s maximum, with acceleration falling across bands from 50
to 30 to 20 to 10 px/s² — so the game spends a long time near top speed instead
of running away from human reaction. Super Hexagon reaches its ceiling
differently: speed is fixed and high, and mastery comes from recognising a
limited pattern vocabulary presented in changing order.

> **Why this matters here:** it is direct external support for the shape this
> repository has already half-built — content difficulty that plateaus, with
> pressure supplied by something else. See § 2.3.

**A long expert tail can exist with no numerical progression at all.** Super
Hexagon: reportedly 19 of ~50,000 early owners lasted 60 seconds on the final
level (~0.038%), against an expert run of 117.20 s. Geometry Dash Steam
achievement funnel: ~84.7% complete the first normal level, 39% clear one Demon,
19.5% clear ten, 2.8% clear eighty, ~1.1% clear two hundred — with no purchased
movement power anywhere in the game.

> **Why this matters here:** the 5–10× spread this project wants between median
> and excellent play does **not** require upgrades to supply it. A stable
> ruleset, an expressive control set and a learnable pattern grammar can produce
> it alone. That reframes what upgrades are *for*.

**There is no defensible "experts reach 10× the median" law.** Session A
classifies this as folklore and finds no cross-game evidence for any universal
ratio. The distribution depends on whether failure probability rises, whether
there is a stationary endgame, whether revives count, and whether expert play is
memorisation or live adaptation.

> **Consequence:** 2–5 km median / 25 km excellent is a **product target to
> validate**, not an industry constant to satisfy. It is legitimate precisely
> because the owner chose it.

**Score multipliers destroy comparability without changing survival skill.**
Subway Surfers is reported to allow a permanent mission multiplier to ×30, a
purchased cap extension to ×35, plus seasonal, character, booster and in-run ×2
effects — so two players performing identical movement can post radically
different scores.

> **Why this matters here:** `docs/game-design/Spider-Swing-GDD-v2.0.md` §12.1
> already forbids the failure mode ("Special flies and style actions do not add
> fake metres"). This is external corroboration that the rule is load-bearing,
> not fussiness.

**Immediate retries do not make unfair deaths acceptable.** Geometry Dash
attempt statistics are extreme — reportedly ~87.1% of Steam players reach 100
attempts, 71.6% reach 500, 53.6% reach 2,000, 32.9% reach 10,000 — but Session A
is explicit that repetition is tolerated because failures are *deterministic and
attributable*, not because restarts are fast.

**Procedural playability must be validated against state, not geometry.** Search
based PCG research repeatedly finds that local placement rules do not guarantee
playability; a 2026 endless-runner implementation used both geometric scans and
navigation agents ahead of the player. The literature also warns that **agent
difficulty is only a proxy for human difficulty**.

> **This is the academic form of the rule this repository already enforces from
> its own measurements** — the non-pumping bot is a floor, not a target. Two
> independent lines of evidence now say the same thing.

## 1.2 Session A's folklore table, kept because it is directly usable

| Common claim | Session A verdict | Bearing on this project |
| --- | --- | --- |
| Difficulty should ramp exponentially forever | **Folklore — false** | Supports a plateau + bounded chase |
| Increasing speed is the best endless difficulty lever | **Contradicted** | Speed cuts reaction time; cap it before reflex failure |
| Upgrades should never exceed a fixed percentage | **Folklore** | Define per-system budgets instead of one global cap |
| More upgrade levels create more meaningful progression | **False in general** | 40 levels of indistinguishable increments become balancing debt |
| Procedural games inevitably generate unfair situations | **Valid risk, not inevitable** | Requires runtime validation, which this repo partly has |
| A solvable procedural route is fair | **False** | Solvable ≠ readable ≠ reachable from the incoming state |
| Players accept unfair deaths when retries are immediate | **Weak convention** | Never rely on it |
| Experts should reach ~10× the median | **Folklore / target hypothesis** | Use only as an explicit product target |
| Difficulty must keep rising forever in an endless game | **False** | A stationary endgame with nonzero hazard still produces attrition |

## 1.3 Session A's recommended target bands

Offered as hypotheses, not constants. The **moderate** model is the one that
matches this project's stated north star.

| Model | Median | Strong | Expert | Exceptional | Ratio |
| --- | --- | --- | --- | --- | --- |
| Conservative | 2–4 km | 5–8 km | 10–15 km | 20–25 km | 6–10× |
| **Moderate** | **2–5 km** | **6–10 km** | **15–25 km** | **30–50 km** | **8–15×** |
| Ambitious | 2–5 km | 8–15 km | 25–50 km | 75 km+ | 20×+ |

## 1.4 Session A's upgrade-impact bands — the most decision-relevant table here

| Band | Effect of maximum upgrades on run distance | Verdict for this project |
| --- | --- | --- |
| Conservative | +20–40%, mostly consistency and recovery | Fits a purely competitive board |
| **Moderate** | **+50–100%**, expert baseline still beats weak maxed play | **Recommended for the shared five-track core** |
| Strong | 2–4×+ | **Explicitly rejected** — makes early play feel defective, turns late distance into an account-age gate, and forces difficulty to serve incompatible power bands |

> **Read this against § 3.** It is the single most important external input,
> because it says the 25 km target must be reached **mostly by the difficulty
> curve, not by the upgrade ladder** — and this repository's own arithmetic
> independently arrives at the same conclusion.

## 1.5 Fair-death engineering — the parts worth adopting

**Reaction-time budget.** Visibility is not fairness. The available time is

```
T_available = D_visible / V_closing − T_display − T_input − T_recognition − T_movement_commitment
```

and Session A notes that for a momentum game **movement commitment may dominate
raw reaction time**: changing height through a swing takes far longer than a lane
change. A hazard that is visible for 0.9 s is not fair if the swing needed to
avoid it takes 1.2 s to execute.

**Failure taxonomy**, useful as a death-classification vocabulary: hard but
readable · player-created dead state · procedurally impossible sequence · camera
failure · control failure · collision-model failure · monetisation-created
failure · technically avoidable but unreadable.

**Procedural safety rules** (condensed): geometric clearance; dynamic
reachability from the incoming state envelope; control feasibility given
cooldowns; commitment fairness (the decision was visible before the previous
irreversible choice); recovery feasibility after plausible minor error; state
continuity between segments; **velocity-aware spacing measured in seconds-to
contact, not metres**; validation fallback before the visible horizon; validation
under the authoritative physics; and human verification, because bot solvability
is a lower bound.

**Death attribution fields**: collider, speed, attached state, last inputs, time
since the hazard became visible, whether any valid trajectory still existed,
nearest safe route, cooldown/resource availability, frame-time anomalies, whether
generation passed validation, whether the run used assistance.

## 1.6 Leaderboard run classes

Session A's cleanest structural recommendation, and it resolves a live conflict
in this repository (§ 4.4):

| Class | Definition |
| --- | --- |
| **Baseline** | Garden/Classic, level-zero upgrades, no assistance |
| **Upgraded** | Permanent earned upgrades, no consumable assistance |
| **Assisted** | Revive, checkpoint, head start, temporary bonus, or experimental configuration |

All classes record version, seed, spider, upgrade snapshot and configuration. A
revive may keep the player's personal run and rewards while ending canonical
eligibility at the first death.

## 1.7 Monetisation ordering

Lowest risk first: cosmetics → visual themes → cosmetic acceleration → ad removal
→ rewarded ads for cosmetic currency after a run → paid challenge content →
convenience outside canonical runs → revives confined to assisted runs.

Avoid: permanent stat purchases, paid upgrade tiers, purchased score multipliers,
energy systems, mechanically superior paid spiders, consumable boosts on the
canonical board, and **monetisation prompts immediately after ambiguous deaths**.

> This is fully consistent with [`economy-model.md`](economy-model.md) and the
> owner's hard boundaries. The one addition worth carrying: *never place a
> purchase prompt in the causal path of a death.*

---

# 2 · Repository findings — verified against source this session

Every claim below was re-checked against `main` @ `5afa54a`. File and line are
the evidence.

## 2.1 🔴 Ancient Forest is excluded from the recovery cadence every other region receives

**The single most actionable finding in either session, and it is `measured`.**

`game/application/course_pattern_catalog.gd:288-299`:

```gdscript
var recovery_interval := 5
if region_id != CourseRegionCatalog.ANCIENT_FOREST and \
        posmod(local_chunk, recovery_interval) == recovery_interval - 1:
    return RECOVERY_PATTERN.duplicate(true)
if region_id == CourseRegionCatalog.ANCIENT_FOREST and \
        distance_at_chunk >= MASTERY_START_DISTANCE and \
        posmod(chunk_index, 8) == 7:
    return {"id": &"tight_rail", "lane": &"tight", "difficulty": 4}
```

Read plainly:

- **Every region except Ancient Forest** gets a guaranteed `open_recovery` chunk
  every fifth local chunk.
- **Bramble Canopy gets one every *other* chunk** — 50% open ground
  (`:277-280`), deliberately, so each high↔low commitment has a full settling
  window.
- **Ancient Forest — 0–5 km, where essentially all play happens — gets none.**
  It is not merely absent from the cadence; after 2 km it instead receives a
  **difficulty-4 `tight_rail`** every eighth global chunk.

Ancient Forest also carries `"checkpoint": false` with no `safe_entry` flag
(`game/domain/course_region_catalog.gd:33-42`), so the safe-entry branch at
`:265-267` never fires for it either. **Its guaranteed-recovery count is exactly
zero.**

**Independent corroboration from this repository's own measurements.** The death
cause table in
[`2026-08-01-difficulty-curve.md`](../measurements/2026-08-01-difficulty-curve.md)
lists patterns at death per band. `open_recovery` appears in the 10 km, 15 km,
20 km and 25 km rows — and **never in the 0 m row**. The bot could not die on a
recovery chunk in Ancient Forest because there are none to die on.

**The region metadata contradicts the code.** `course_region_catalog.gd:38`
declares Ancient Forest's quirk as **`"Wide recovery rhythm"`**. The region
advertises precisely the property the selector denies it. This is a
source-versus-source contradiction, not a doc drift.

> **Why this is the strongest available explanation for the 2–5 km wall.** A
> failed swing in Ancient Forest can flow directly into the next commitment with
> no authored settling window, in the one region where players are still learning
> to generate speed. The later regions — designed for more advanced play — are
> structurally *more forgiving* than the first one.

## 2.2 🔴 The early-course thresholds are in pixels, and they are ten times earlier than previously reported

`CoursePatternCatalog` (`:9-11`) and `SwingConfig` (`:123-124`) express these in
**pixels**, and `CourseRegionCatalog.PIXELS_PER_METRE = 10.0`.

| Threshold | Source value | **Actual distance** |
| --- | ---: | ---: |
| `CONTROL_START_DISTANCE` (control pattern pool) | 10 000 px | **1 km** |
| `MASTERY_START_DISTANCE` (mastery pool, `tight_rail` begins) | 20 000 px | **2 km** |
| `DEEP_FOREST_START_DISTANCE` (deep pool) | 35 000 px | **3.5 km** |
| `middle_hazard_start_distance` | 10 000 px | **1 km** |
| `tight_corridor_start_distance` | 20 000 px | **2 km** |
| `speed_curve_distance` (reference reaches maximum) | 50 000 px | **5 km** |
| Region length (each biome) | 50 000 px | **5 km** |

**This corrects a prior Claude session's analysis**, which read these as 10 km,
20 km and 35 km. The error mattered: it made the early course look like a long
gentle runway when it is in fact **fully escalated by 3.5 km**.

Obstacle growth saturates on the same schedule
(`game/application/course_stream.gd:717-722`): 1.00 → 1.08 at 1 km → 1.14 at
2 km → **1.16 at 3.5 km, and never rises again**.

**Compound spikes, now correctly located:**

| Distance | What begins simultaneously |
| ---: | --- |
| **1 km** | Middle-lane hazards **and** the control pattern pool — with no recovery cadence |
| **2 km** | Mastery pool **and** tight corridors **and** `tight_rail` insertion — the sharpest early spike in the game |
| **3.5 km** | Deep-forest pool, while the speed reference is already near maximum |

> Everything the difficulty curve has to say to a player is said between 1 km and
> 3.5 km, with no guaranteed recovery anywhere in it. That is the 2–5 km wall
> described in code.

## 2.3 Content difficulty is already asymptotic; only the bird is unbounded

`measured`. Pattern difficulty cost caps at 4; obstacle growth caps at 1.16 by
3.5 km; the speed reference completes at 5 km; region vocabulary changes every
5 km to 35 km. The **only** term that rises without limit is the bird:

`game/domain/swing_config.gd:266-270` — `bird_speed + bird_acceleration × km`,
forever.

| Distance | Named player reference | Bird |
| ---: | ---: | ---: |
| 0 km | 36.0 m/s | 30.0 m/s |
| 5 km | 76.0 m/s | 36.0 m/s |
| 25 km | 76.0 m/s | **60.0 m/s** |
| 40 km | 76.0 m/s | **78.0 m/s** |

**The endurance terminal is therefore arithmetic**, `inferred`: a player who
sustains *V* px/s is overtaken at **D = (V − 300) / 12 km**.

| Sustainable speed | Terminal at gain 12 | Terminal at gain 20 (FAST) |
| --- | ---: | ---: |
| 60 m/s | 25 km | 15 km |
| 80 m/s | **41.7 km** | **25 km** |
| 112 m/s (release cap) | 68.3 km | 41 km |

> **One constant chooses where excellent runs end.** It can be *derived* from a
> single device measurement of sustainable speed rather than guessed — and both
> sessions independently recommend replacing the unbounded line with a tapered,
> capped curve. Session B's comparison candidate (explicitly **not** for
> adoption) is `0–10 km: 300 + 12/km · 10–25 km: 420 + 6/km · 25 km+: cap 510`,
> which reaches 51 m/s at 25 km instead of 60 and removes the eventual purely
> mathematical chase wall.

## 2.4 Warning time shrinks as skill rises — twice over

`measured`, and this is the mechanism that makes speed self-defeating.

**Hazard cues are fixed-distance.** `game/simulation/simulation_world.gd:507`
gates cues to a 700–820 px band, independent of velocity:

| Player speed | Cue lead time |
| --- | ---: |
| 60 m/s | 1.17–1.37 s |
| 76 m/s | 0.92–1.08 s |
| 112 m/s | 0.63–0.73 s |

**Camera preview is also fixed.** `game/presentation/scripts/swing_lab.gd:243-247`
places the spider one third into a 1280 px reference viewport — 853 px of forward
view — plus `0.22 × overspeed` of look-ahead, with no zoom. Preview time falls
from ~1.77 s at 500 px/s to ~0.83 s at the 1120 px/s cap, while chunks arrive
every 960 px.

> **The better the player, the less time they get to read the course, from two
> independent systems.** No upgrade can buy either back: `camera_look_ahead` sits
> in `DifficultyCatalog.PHYSICS_FIELDS` and no track touches it. Combined with
> Session A's commitment-time point (§ 1.5) — a swing takes far longer to execute
> than a tap — this is the hard ceiling sitting across the path from
> "skill earns speed earns distance".

## 2.5 The zero-drive motor also disabled the overspeed correction

`measured` — `game/simulation/spider_motor.gd:16-27`. Both branches of the motor
are scaled by `horizontal_drive_acceleration`:

```gdscript
if velocity.x < target_speed:
    velocity.x = move_toward(..., config.horizontal_drive_acceleration * delta)
elif velocity.x > target_speed + config.maximum_horizontal_overspeed:
    velocity.x = move_toward(..., config.horizontal_drive_acceleration * 0.25 * delta)
```

At drive zero, **neither** fires. The removal of the floor also removed the
ceiling. The `forward_cap` in `_release_web` bounds the *release award* only;
pendulum conversion, Reel work, pull exits and moving highway anchors have no
restoring force above the reference band, and **air drag is the sole decay**.

That is not necessarily wrong — it is what "speed is earned" means — but it
should be a stated design property rather than a side effect, and it means the
release cap is doing more work than its comment claims.

## 2.6 Progression contains purchases that buy nothing

`measured`, both re-derived from `game/domain/spider_catalog.gd:345-422`.

**Quick Feet is exactly inert.** `QUICK_FEET` multiplies
`horizontal_drive_acceleration`, whose baseline is `0.0` in every preset. The
resolved value is exactly zero at every level, it remains purchasable through
`ProgressionService`, and `tests/unit/upgrade_audit_tests.gd:27` exempts it by
name. Known and tracked as OQ-13 — recorded here because it is a **live currency
sink that changes nothing**, not merely an open question.

**Compact Stance sells four dead levels.** The formula is
`max(0.88, 1 − 0.004 × steps)` with `steps = effective_steps(level) × 0.70`. The
floor is reached when `steps ≥ 30`, i.e. `effective_steps ≥ 42.86`:

| Level | `effective_steps` | steps | Radius |
| ---: | ---: | ---: | ---: |
| 35 | 42 | 29.40 | 13.659 px |
| **36** | **43** | **30.10** | **13.622 px — floor reached** |
| 37–40 | 44–48 | 30.8–33.6 | **13.622 px — identical** |

Levels 37, 38, 39 and 40 are paid no-effect purchases. The existing cap contract
(`upgrade_audit_tests.gd:128`) asserts the ceiling *holds*; nothing asserts that
each purchased level *does something*.

**All profile drive modifiers are inert.** Skitter +16%, Anchorite −12%,
Ballooner −6% and Buckler −8% all multiply a zero baseline. Their user-facing
copy still describes drive trade-offs ("Forward recovery gains…", "weaker drive")
that resolve to nothing. Their radius, gravity, reference-speed, Reel, Burst,
glide and shell differences remain real.

## 2.7 Reliable Launch and Anchor Drive interact against fine control

`measured` structure, `inferred` consequence — `simulation_world.gd:1219-1222`:

```gdscript
var requested_travel := minf(
    maxf(anchor_distance * distance_fraction, minimum_distance),
    maximum_travel,
)
```

The **larger** of proportional and minimum travel wins, and
`_pull_radial_speed = requested_travel / duration` with duration fixed at 0.20 s.
Raising both tracks expands the range in which the floor dominates:

| Level | Fraction | Minimum | Floor dominates below | Radial speed at a 300 px anchor |
| ---: | ---: | ---: | ---: | ---: |
| L0 | 40.0% | 80 px | 200 px | 600 px/s |
| L40 | 56.8% | 248 px | **437 px** | **1240 px/s** |

A fully upgraded player asking for a small nearby correction gets a pull that is
twice as long and twice as fast. Configuration monotonicity is preserved;
**controllability may not be**, and no contract currently tests it. This is a
genuinely new observation and it belongs on the device-verdict list, not in a
tuning change.

## 2.8 Later-zone pressure systems have no shared budget

`measured` — `game/simulation/zone_mechanics.gd:9-16`, plus the pattern catalog
and the bird law, are authored independently of one another:

| Distance | Pressure added | Interacts with |
| ---: | --- | --- |
| 18.5 km | Forced rotor + pane compound lesson | Bird at ~49.8 m/s |
| 20 km | Storm base wind, backward/upward, only 18% while attached | Bird at 54 m/s |
| 21–25 km | Seeded 5-second gusts, then lightning | Bird 55.2 → 60 m/s |
| 27 km+ | Sticky anchors bleed **42% of velocity per second while attached** | Bird 62.4 m/s and rising |

The sticky case is the sharpest: **a correct attachment can still worsen chase
distance**, because the environmental mechanic drains precisely the resource
needed to escape the pursuer. Nothing coordinates these, and the warning-time
floor (§ 2.4) does not adapt to any of them.

## 2.9 Bird deaths still settle as `camera_boundary`

`measured` — `simulation_world.gd:488-493`. The player-facing message says
"Caught by the pursuing bird"; the authoritative cause remains the legacy
invisible-boundary identifier. Every measurement document, search artifact and
diagnostic therefore groups bird deaths with the old camera-boundary deaths, and
no death record carries bird gap, closing speed, or which recovery verbs were
still available.

Cheap to fix, and it is a prerequisite for any honest measurement of whether the
bird creates pressure or death spirals.

---

# 3 · Synthesis — the two sessions agree, and the arithmetic explains why

## 3.1 Distance is geometric in per-encounter survival

`inferred`, from `measured` constants. `CourseStream.CHUNK_WIDTH = 960 px = 96 m`,
one authored pattern per chunk, so **E[distance] ≈ 96 m × lives × p/(1−p)** where
*p* is per-chunk survival.

| Outcome | Chunks per life | Required *p* | Per-chunk failure |
| --- | ---: | ---: | ---: |
| 2.4 km — owner L0 standing (`measured`, 4 runs) | 25 | 0.9615 | 3.85% |
| 5 km — owner L20, 2 lives (`measured by recall`) | 26 | 0.9630 | 3.70% |
| **25 km — the target, 2 lives** | **130** | **0.99237** | **0.76%** |

**25 km requires roughly a 5× reduction in per-encounter failure for
already-excellent play** (0.47 → 0.08 deaths/km), and ~10× from median play.

Because chunk outcomes are in reality *correlated* — a bad exit state poisons the
next chunk — this is a **lower bound** on the required improvement. It is also
exactly the mechanism § 2.1 attacks: a guaranteed recovery chunk is a chunk with
a near-zero failure rate *and* it restores the entry state for the next one.

## 3.2 Why upgrades cannot close the gap, and were never supposed to

The owner's `measured` upgrade benefit is ~2.5× (2 km → 5 km) at L20. L40 supplies
1.4× the numeric steps of that ladder on additive-then-clamped curves, so
extending it plausibly reaches **6.5–8 km**. A 3–4× gap remains after every
existing multiplier is maxed *and* extended.

Session A, from an entirely different direction, says maximum upgrades should
move distance by **+50–100%** and that 2–4× is a power ladder to avoid (§ 1.4).

**These are the same answer.** If upgrades are held in the moderate band — which
both the GDD's fairness boundary and the economy model already require — then

> **the 25 km target must be met mainly by raising what excellent *baseline* play
> can achieve, and only secondarily by upgrades.**

Excellent baseline play must reach roughly 12–15 km for a moderate upgrade band to
land at 25 km. Today it reaches ~2.4 km. **That is a difficulty-curve problem, and
§ 2.1, § 2.2 and § 2.4 are three named, source-verified reasons for it.**

This also retires the framing that the upgrade system is the primary lever. It is
not. It is the *second* lever, and it is currently pointed at the wrong surface —
no track touches release quality, Dive, or anything that raises the ceiling
(see [`current-state.md`](../current-state.md) and § 2.6).

## 3.3 What both sessions independently recommend

| Recommendation | Session A | Session B | Repo already supports |
| --- | --- | --- | --- |
| Plateau content difficulty; stop scaling speed | ✓ (Canabalt, Super Hexagon) | ✓ | Partly — content caps at 3.5 km |
| Replace unbounded chase with a tapered, capped curve | ✓ (stationary endgame) | ✓ (explicit candidate) | No — bird is linear forever |
| Warning in **seconds**, not pixels | ✓ (reaction budget) | ✓ (Change 6) | No — fixed 700–820 px |
| Guarantee recovery opportunities | ✓ (recovery feasibility rule) | ✓ (Change 2) | Yes, in every region **except** Ancient Forest |
| Hybrid progression: numeric levels, sparse capability breakthroughs | ✓ (breakthrough guidance) | ✓ | Yes — the L20 second Burst charge already is one |
| Upgrades conditional on good execution | ✓ | ✓ (Quick Feet → release conversion) | Not yet |
| Separate baseline / upgraded / assisted leaderboards | ✓ | — | GDD §12.3 says yes; source says otherwise (§ 4.4) |
| Never tune to bot output | ✓ (agent ≠ human difficulty) | ✓ (emphatic) | Yes — binding rule already |

---

# 4 · Corrections to existing repository documents

## 4.1 "All fifteen upgrade kinds are numeric multipliers" is 14 of 15

`player-preference-research-2026-08-02.md:129` states that not one upgrade grants
a capability. `BURST_REACH` sets `burst_charge_capacity` from 1 to 2 at level 20
(`spider_catalog.gd:378-382`), pinned by
`tests/unit/upgrade_audit_tests.gd:109-125`. **A capability breakthrough already
ships, in a mechanism built for exactly this.** Both external sessions flagged it
independently. The accurate statement: *the kinds are primarily numeric, but one
track already crosses a capability threshold.*

## 4.2 Early-course thresholds are 1 / 2 / 3.5 km, not 10 / 20 / 35 km

See § 2.2. This corrects a prior Claude session's reading, which treated pixel
constants as metres.

## 4.3 Ancient Forest's declared "Wide recovery rhythm" is not implemented

See § 2.1. `course_region_catalog.gd:38` versus
`course_pattern_catalog.gd:288-299`. Source-versus-source, not doc drift.

## 4.4 The leaderboard-eligibility conflict — **answered by the owner, D-0045**

GDD §12.3 says a future leaderboard's standard mode uses *fixed Classic stats*
with gameplay purchases excluded. `DifficultyCatalog.MODES` marks **Standard,
with upgrades fully applied**, as the sole `leaderboards_eligible` mode. Session A
recommended splitting the board into baseline / upgraded / assisted classes
(§ 1.6).

**The owner chose none of those.** Recorded as **[D-0045]**, 2026-08-02:

> One **general** leaderboard, not segmented by upgrade level. Upgrades apply
> normally. Every entry records **its course seed and upgrade levels** — plus
> spider, difficulty mode and build/trace identity — so anyone can reproduce the
> exact run.

Transparency instead of segmentation. It resolves the conflict by superseding
GDD §12.3's eligibility rule rather than the source, so **`DifficultyCatalog`'s
current behaviour is now correct as written** and needs no change.

Three consequences worth carrying forward:

1. **Disclosure makes the difference visible, not absent.** Two entries at
   different upgrade levels are still not like-for-like. The board's fairness
   therefore rests on upgrades staying in a bounded band (§ 1.4's +50–100%) and
   remaining earnable only by play — both already required by
   [`economy-model.md`](economy-model.md). This *raises* the stakes on § 3.2:
   if upgrades were ever allowed into the 2–4× band, the general board would
   become an account-age ranking.
2. **"Reproduce the run" has two strengths, and both already have seams.**
   *Reproduce the course* needs only metadata — seed, upgrade levels, spider,
   mode — and lets another player attempt the same conditions. *Reproduce the
   run itself* needs the input trace, and that is what makes an entry
   **verifiable** rather than merely believable. Production already draws a
   fresh course seed per run (`SwingLabSession._next_course_seed`);
   `toggle_recording` already captures human input; `export_diagnostic()`
   already writes seed plus resolved config plus commands; and `--replay` /
   `load_input_trace` already reproduce a recorded run within a
   contract-enforced one metre.
3. **Entries are reproducible only within one physics generation.** The trace
   format already refuses input recorded under different authoritative physics
   (`spider-swing-input-trace@4`, bumped by the forty-level progression work).
   Any change that moves upgrade-bearing outcomes — including most options in
   this document — invalidates reproduction of older entries unless the
   identity is stored on each one. **Store it from the first entry**, not after
   the first regeneration.

**GDD §12.3 still reads the other way.** The GDD is vendored byte-exact and
checksum-pinned (`docs/game-design/README.md`), so it cannot be edited in place:
changing it means a new owner-authored version with a new checksum. Until then,
D-0045 is the current rule and §12.3 is the superseded text. This is flagged, not
silently left to drift.

## 4.5 Profile copy describes drive trade-offs that no longer exist

See § 2.6. Four of five spider descriptions reference a system that resolves to
zero.

---

# 5 · Findings by priority

Ordered by *evidence strength × effect on the north star*. **None of these is
approved work** — each needs its own session and, where marked, an owner verdict.

| # | Finding | Class | Verified | Needs device verdict |
| --- | --- | --- | --- | --- |
| 1 | Ancient Forest has no guaranteed recovery, while later regions do (§ 2.1) | Structural | ✓ source + measurement corroboration | Cadence value |
| 2 | Early thresholds are 10× earlier than documented; curve fully escalated by 3.5 km (§ 2.2) | Structural | ✓ source | Whether the ramp is too compressed |
| 3 | Warning time shrinks with skill, from cues **and** camera (§ 2.4) | Structural | ✓ source + arithmetic | Minimum understandable warning at 60 / 76 / 100+ m/s |
| 4 | Bird is unbounded; terminal is one constant (§ 2.3) | Tuning | ✓ source + arithmetic | OQ-15 — all values |
| 5 | Quick Feet is an inert purchase (§ 2.6) | Progression defect | ✓ source | OQ-13 — its new identity |
| 6 | Compact Stance sells four dead levels (§ 2.6) | Progression defect | ✓ arithmetic | No |
| 7 | Bird deaths settle as `camera_boundary` (§ 2.9) | Observability | ✓ source | No |
| 8 | Burst floor × fraction may cost fine control (§ 2.7) | Feel risk | ✓ formula | Yes — is a short Burst still a correction? |
| 9 | Later-zone pressures have no shared budget (§ 2.8) | Structural | ✓ source | Readability of combinations |
| 10 | Profile drive copy is untrue (§ 2.6, § 4.5) | Doc accuracy | ✓ source | No |

**Two of these are pure data-quality fixes** (6, 7) that need no owner input.
**Three are structural and gate honest measurement of everything else** (1, 3, 4).
**One is a live currency sink** (5).

## 5.1 The A/B harness these findings need has just landed

PR **#109 merged** on 2026-08-02 (build `0.30.0-menu-system-playtest`), while
this document was being written. It ships a separately versioned
`DebugTestProfile` that auto-saves the Test Lab working set and **A/B/C
comparison slots**, applying the chosen profile before the session's first
simulation tick, with resolved values that never enter `PlayerSettings` or
`PlayerProgress`.

That converts the coordination risk noted earlier into an asset: **the paired
comparisons every device verdict in § 5.2 needs now have a harness.** The
comparisons that matter most — current Ancient Forest cadence versus a candidate
with guaranteed recovery, and current linear bird versus a tapered capped
curve — are exactly the A/B shape it was built for, and both must hold the course
seed fixed across the pair to be worth anything.

## 5.2 What can be settled headlessly, and what cannot

**Headless:** every resolved upgrade milestone value; that each paid level changes
something or crosses a declared threshold; bird-curve continuity, monotonicity,
bound, and independence from player speed; recovery-gap maxima and hard-pattern
adjacency; seed determinism and debug-start equality; L0 Garden route passability;
cue uniqueness and timing formula; preview-time arithmetic; exploit regression via
`arc per web`.

**Device-only:** sustainable speed with pumping; whether release timing feels
rewarding; readability at earned speed on a phone; bird speed, gap, taper and cap;
minimum understandable warning time; whether a short Burst still reads as a
correction at L40; Reel targets; whether 25 km should be credible at L0 or only
with mature upgrades.

> **The bridge between them already exists in source.** `SwingLabSession`
> records human input (`toggle_recording` → `_recorded_commands`) and
> `export_diagnostic()` writes it with seed and resolved config;
> `tools/simulate.gd --replay` and `load_input_trace` replay the
> `spider-swing-input-trace@4` format deterministically within one metre. The two
> formats differ — closing that gap would let the **owner's own runs** be replayed
> headlessly with the full lab instrumentation, retiring the largest measurement
> blind spot in the project without fitting a bot at all.

---

# 6 · Owner decisions this research surfaces

Only forks that source inspection cannot resolve.

1. ~~**Does the competitive lane run on base or upgraded stats?**~~
   **Answered 2026-08-02 — [D-0045].** One general board, not segmented by
   upgrade level; upgrades apply; every entry carries its course seed and
   upgrade levels so the run can be reproduced. § 4.4 records the three
   consequences, the most load-bearing being that a general board turns the
   **bounded upgrade band into a fairness requirement** rather than a design
   preference — which raises the stakes on § 3.2 rather than lowering them.
2. **Which progression state should make 25 km credible** — excellent Garden L0,
   excellent with mature upgrades, or L0 approaching it with upgrades adding
   consistency? Both sessions flag this; it materially changes both targets.
3. **How much chase should remain after 25 km?** Bounded is recommended by both;
   the owner decides whether post-25 km mastery is course execution, buffer
   maintenance, or an escalating race.
4. **Should capability breakthroughs stay rare?** The L20 reserve Burst already
   proves the hybrid model. Whether it stays exceptional or becomes a repeated
   pattern is a product fork, not a technical one.
5. **OQ-13 — Quick Feet's identity.** Both sessions independently propose the same
   answer: point it at the **qualified release award**, so its value is multiplied
   by `release_quality` and rewards execution rather than restoring passive drive.
   Strength and feel still need the owner.
6. **OQ-14 / OQ-15 / OQ-16** remain live and now gate measurement, not just feel.

---

# 7 · Standing warning, restated

> **No bird value, Reel value, release coefficient, recovery cadence, warning
> time, or 25 km target may be selected because it makes the bot travel further.**
>
> The model cannot pump a pendulum, has never performed a Dive, reels far more
> lightly than the owner, and ignores anchor classes. Its no-drive distances are
> **floors**. Session A supplies the independent academic form of the same rule:
> agent difficulty is a proxy for human difficulty that is known to fail across
> player styles.
>
> Bot runs remain valid for deterministic regression, exploit detection, exact
> counters, route existence, invariant checking, and relative floors.
