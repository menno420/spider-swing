# Menu review — the universal-menu research report against what ships

> **Status:** `audit`
>
> **Provenance vocabulary (PL-013):** `measured` = read off source or off a
> headless layout run · `inferred` = arithmetic on measured values · `assumed` =
> design hypothesis awaiting the owner's device verdict.
>
> **Inputs.** The owner's deep research report on universal game-menu design
> (Dutch, ~10 000 words, sourced against Xbox XAG, Steam Input, WCAG 2.2,
> Material, NN/g and GDC production cases), plus two device recordings of build
> `0.34.0-speed-cap-playtest` (2026-08-02, 1040×480 capture → a 2340×1080
> phone).
>
> **Method.** Every geometric claim below was produced by laying the real
> `FrontEndView` out in a headless `SubViewport` on the pinned
> `4.7.1.stable.official.a13da4feb` and reading control rectangles. Screenshots
> could not be captured — the dummy renderer returns an empty image
> (`docs/CAPABILITIES.md`, 2026-08-02) — so raster judgment stays with the owner.

---

## 1 · The one number that reframes the whole review

The report's touch-target guidance (Material 48 × 48 dp; WCAG 2.2's 24 CSS px
floor and 44 px enhanced criterion) was being read against the wrong ruler.

`project.godot` renders a **1280 × 720 reference viewport** with
`stretch/mode="canvas_items"` and `stretch/aspect="expand"`. On the owner's
2340 × 1080 device that resolves to a **1.5× scale** (`min(2340/1280,
1080/720)`), and an xxhdpi screen carries **2.5 device pixels per dp**.

> **One reference pixel is 0.6 dp.** The 48 dp minimum the report recommends is
> **80 reference pixels** — not 48. `inferred`, from `measured` project settings
> and the recording's 2340 × 1080 aspect.

Measured against that ruler, before this session:

| Screen | buttons | min | median | under 48 dp |
| --- | ---: | ---: | ---: | ---: |
| Home | 9 | 48 px · **29 dp** | 58 px · 35 dp | 9 / 9 |
| Garage | 14 | 42 px · **25 dp** | 54 px · 32 dp | 14 / 14 |
| Shop | 9 | 54 px · 32 dp | 68 px · 41 dp | 9 / 9 |
| Settings | 11 | 54 px · 32 dp | 58 px · 35 dp | 11 / 11 |
| Field Guide | 6 | 54 px · 32 dp | 68 px · 41 dp | 6 / 6 |
| Test Lab | 52 | 34 px · **20 dp** | 46 px · **28 dp** | 52 / 52 |
| Debug Run Setup | 25 | 48 px · 29 dp | 52 px · 31 dp | 25 / 25 |

`measured`. Only the three hubs cleared the bar, on their 112 px route cards.

This is the single most consequential gap between the report and the build, and
it was invisible in review because 44 px *looks* fine in a 1280-wide mockup. It
is 26 dp on the phone — roughly **half** the recommended target.

---

## 2 · What the report asks for, and what ships

Scored against the report's five layers. `measured` unless noted.

### 2.1 Informatiearchitectuur — **strong, and already deliberate**

The report's recommendation for a middle-complexity game is global intention
groups over a flat feature index, every core task within two navigation
actions, and one dominant primary action visible on open.

That is exactly what D-0047 decided and what source does: Home carries `PLAY
ENDLESS` as one dominant action reachable in **zero** taps, difficulty inline,
and four intention routes (Spider · Play Modes · Guide · Settings). Every one of
the twelve player-facing destinations is within **two** taps. Back paths are
authoritative `FrontEndState`, not presentation-local history — the report's
"teruggedrag" rule, satisfied structurally rather than by convention.

**No change recommended.** The report would endorse the current IA.

One small deviation: the report warns against vague container labels (`Meer`,
`Overig`, `Beheren`, `Hub`). Home's section heading is `WHERE TO NEXT` and the
Spider hub's is `CHOOSE WHAT TO CHANGE`. Both are verbs-with-context rather than
bare containers, so this is a near-miss, not a violation. Left alone.

### 2.2 Visuele hiërarchie — **one real inversion, now fixed**

> The report: *"één dominant focusaccent"*; selection must be the strongest
> state on screen, and never signalled by colour alone.

`_refresh_difficulty_buttons` set `button.disabled = selected`. Godot then
painted the current difficulty with `font_disabled_color` — MUTED at 48 % alpha,
**2.60 : 1** against the panel — while the two difficulties the player was *not*
on kept full-contrast INK at 14.7 : 1.

> **The difficulty you were actually playing was the dimmest, lowest-contrast
> control on Home, and read as unavailable.** Visible in the recording: STANDARD
> looks greyed out between an active-looking RELAXED and HARSH.

`measured` from source and confirmed against the frame. **Fixed this session** —
selection now uses the existing `_set_selector_state` path: heavier border, an
accent fill, and the `▸` prefix retained, so the state is marked three ways and
never by colour alone.

The same `disabled` styling is still used in the Shop for tracks you cannot
afford. There it is semantically correct — you genuinely cannot press it — so it
stays. Noted only because a maxed track and an unaffordable one currently look
alike; their *text* differs (`MAXIMUM` vs `N FLIES`), which meets the letter of
the rule.

### 2.3 Contrast — **passes, comfortably**

Every text colour against every panel fill, computed to WCAG 2.2:

| | on BACKGROUND | on PANEL | on PANEL_SOFT | on PANEL_RAISED |
| --- | ---: | ---: | ---: | ---: |
| INK | 16.80 | 14.74 | 12.89 | 10.59 |
| MUTED | 9.53 | 8.36 | 7.32 | 6.01 |
| SILK | 17.35 | 15.22 | 13.32 | 10.93 |
| DEW | 10.57 | 9.27 | 8.11 | 6.66 |
| MOSS | 7.39 | 6.48 | 5.67 | 4.66 |
| SAP | 7.09 | 6.22 | 5.44 | **4.47** |
| AMBER | 13.17 | 11.55 | 10.11 | 8.30 |

`measured`. Everything clears the 4.5 : 1 normal-text bar except SAP on
PANEL_RAISED at 4.47 — a rounding-width miss on a combination that does not
currently occur. **The slate palette is a genuine strength**; D-0044 paid off.

One sub-threshold value: panel borders are MOSS at 42 % alpha, blending to
**2.25 : 1** against the panel fill, below the report's 3 : 1 for meaningful UI
components. Panels are also separated by spacing and shadow, so this is a
second-cue weakness rather than a lost boundary. Not changed; recorded.

### 2.4 Informatiedichtheid — **the Shop was the worst offender**

> The report: *"Toon standaard alleen informatie die nodig is om de volgende
> beslissing te nemen"*, and add filtering *"zodra een verzameling niet meer
> betrouwbaar scanbaar is"*.

Measured on the device aspect, before this session: the Shop's scroll window was
**387 px** holding **1077 px** of content — **2.5 of 7 upgrade tracks visible at
once**, with two permanent paragraphs of explanatory prose consuming roughly a
third of a card's worth of the window above it. The recording shows the
consequence: the topmost card is cut through its description, and nothing on
screen says seven tracks exist.

**Improved this session** to **3.5 of 7** (887 px of content in a 422 px window)
by folding the two standing paragraphs into one and putting each card's effect
text and its silk-knot progress on the same line instead of stacked.

That is a 38 % gain and still not comfortable. The honest read: **seven cards
each carrying a name, a level, a cost, a per-step effect sentence and a
milestone row do not fit a phone in landscape**, and the next real fix is
progressive disclosure — show name/level/cost always, reveal the effect sentence
on selection. That is a genuine interaction change, so it is proposed in § 4
rather than taken unilaterally.

### 2.5 Dead space — **48–69 % of several panels**

The report treats empty space as a hierarchy failure when the screen had
something useful to say. Measured panel occupancy before this session:

| Panel | height | content | unused |
| --- | ---: | ---: | ---: |
| Field Guide detail | 583 | 178 | **405 px · 69 %** |
| Play Modes routes | 504 | 215 | **289 px · 57 %** |
| Guide routes | 504 | 219 | **285 px · 57 %** |
| Spider hub routes | 518 | 271 | **247 px · 48 %** |
| Garage roster | 598 | 324 | 274 px · 46 % |
| Home dashboard | 648 | 417 | 231 px · 36 % |
| Practice | 482 | 242 | 240 px · 50 % |

`measured`. This is the direct cost of D-0047's intention map: replacing a
nine-item grid with two- and three-item hubs left the hub panels mostly air.

**Fixed for the three hubs and Home.** The first attempt — letting the route
cards absorb everything — produced 400 px slabs, which is dead space wearing a
border. What shipped instead is the report's own answer: bounded cards
(112 → 132 px) plus a **live status line per hub**, so the space answers *is it
worth going in there?*

- Spider: spiders unlocked, palettes, silk treatments, levels owned across the
  selected spider's seven tracks, tracks maxed, flies to spend.
- Play Modes: campaign stars, practice regions reached, Course Lab pieces placed.
- Guide: lesson count, spider count.

Every figure reads from `PlayerProgress`, so a hub cannot claim progress the save
does not hold. Field Guide detail (69 %) and Practice (50 %) are untouched and
remain the two worst panels.

### 2.6 Interactie en invoer — **out of scope, honestly**

The report devotes its largest section to input abstraction, focus graphs,
controller glyphs and screen-reader narration. **None of it applies to this
build and none of it was attempted.** Spider Swing is Android-only, touch-only,
landscape-locked; there is no controller, no keyboard, no pointer. Godot 4
ships no TalkBack bridge, so screen-reader narration is not a matter of wiring
this project has declined to do — it is engine-level work.

Recording this plainly matters more than scoring it: if a second platform is
ever added, the report's `InputRouter` / `FocusGraph` split is the design to
adopt, and adopting it later costs more than the fourteen screens now carry.

What *does* apply and already holds: taps are event-consuming `Button`s
(contract-pinned), scroll regions bubble drags so a swipe beginning on a card
still scrolls, `follow_focus` is off so a tap cannot yank the viewport
mid-gesture, and selection is never activation.

---

## 3 · The reported bug, and why it happened

> Owner, 2026-08-02: *"when I play a debug run, the upgrades for my spider are
> not available anymore until I play a normal run first."*

Reproduced from source and fixed. `FrontEndState.request_quick_debug_play()`
applies a session-only upgrade overlay so the run uses borrowed levels. The
overlay is deliberately paired with a purchase block —
`request_upgrade_purchase` is a no-op while it is on, so you cannot spend flies
against levels you do not own, and the Shop says so.

**The overlay was released only when the *next* normal run was launched** — in
`request_play`, `request_campaign`, `request_practice` and
`request_creator_play`. Returning to the menu released nothing. So the state was
enterable but not leavable: every path out ran through starting a different run,
or finding the DEBUG toggle in Settings.

The fix states the rule the code was missing: **a debug overlay belongs to the
run it was launched for, and returning to the menu ends that run.**
`main._show_front_end()` now releases it, after the launcher has read the level
the finished run used, so the next debug run is unchanged. Saved levels were
never touched at any point — only the menu's view of them.

Pinned by a contract that replays the owner's exact sequence and separately
asserts the composition root still calls the release. Both halves were confirmed
to fail without the fix.

---

## 4 · What is proposed but not taken

Each of these is a real product choice, not a contained technical one.

1. **Progressive disclosure in the Shop.** Show name, level and cost always;
   reveal the per-step effect sentence for the selected card only. Would fit all
   seven tracks on screen. Cost: a selection concept the Shop does not have, and
   the effect text becomes something you must ask for. `assumed` to be worth it.

2. **Field Guide detail is 69 % empty** — the worst panel in the build, and the
   one screen whose content (real animal, in-game ability, field note, sources)
   is genuinely long. Something is mis-wired between the sections and the panel;
   worth a dedicated look rather than a size tweak.

3. **A `Test Lab` search or filter.** Eight categories × up to six cards ≈ 48
   knobs, median target 28 dp, no way to find a named parameter. The report's
   scannability threshold is clearly crossed. Debug-only, so it competes badly
   for owner device time — but it is the screen the owner uses most in a
   playtest.

4. **Raising the Test Lab's own targets.** It measured worst (20 dp minimum) and
   was left alone deliberately: the six-card grid is pinned by a measured
   contract (`mobile_hud_layout_tests.gd`), and growing the cards means fewer
   per screen or more categories. That is a Test Lab redesign, not a size bump.

5. **Panel borders to 3 : 1.** MOSS at 42 % alpha reads 2.25 : 1. Raising the
   alpha changes the material identity D-0044 chose, so it is the owner's call
   whether the slate look or the contrast floor wins.

---

## 5 · What shipped, measured before and after

| | before | after |
| --- | ---: | ---: |
| Home route cards | 58 px · 35 dp | 88 px min → ~110 px · **66 dp** |
| Home difficulty | 48 px · 29 dp | 72 px · **43 dp** |
| Hub route cards | 112 px · 67 dp | 132 px · **79 dp** |
| Garage palette / silk chips | 44 px · 26 dp | 60 px · **36 dp** |
| Garage → Field Guide | 42 px · **25 dp** | 60 px · **36 dp** |
| Back buttons (17 screens) | 50 px · 30 dp | 64 px · **38 dp** |
| Shop tracks visible at once | 2.5 of 7 | **3.5 of 7** |
| Selected difficulty contrast | 2.60 : 1, styled disabled | full contrast, three cues |
| Hubs stating live progress | none | three |

Nothing reached 48 dp everywhere — several screens genuinely cannot spend the
height without dropping content. The new contract pins the recovered ground per
control so it cannot quietly shrink again.

**Verification:** `python3 tools/verify.py --require-godot` — 209/209 on the
exactly-pinned engine. The two new contracts were each confirmed to fail when
the fix behind them is reverted.

---

## 6 · Where the report was most and least useful

**Most.** The touch-target section, because it forced the reference-pixel → dp
conversion nobody had written down. That one line of arithmetic turned "the
menus feel cramped" into a per-control measurement with a target.

**Least.** Roughly half the report — input abstraction, focus graphs, controller
glyph swapping, tree testing with representative cohorts, telemetry event
taxonomies — is written for a multi-platform team with a research budget. It is
good advice for a game with a controller and a QA pool. Applying it here would
mean building a `FocusGraph` for a device that has no focus.

The transferable core, and the part worth re-reading before any future menu
work, is three sentences: **stable zones, one dominant state per screen, and
never make the player's current position the dimmest thing on it.**
