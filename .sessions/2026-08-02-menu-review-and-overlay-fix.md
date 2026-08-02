# Review the menus against the owner's research report, and free the trapped upgrades

> **Status:** `complete`

## Close-out

**Evidence:**

- source: `front_end_state.gd` (`end_debug_run_overlay`), `main.gd`
  (`_show_front_end` releases it), `front_end.gd` (difficulty selection, touch
  floors, hub status blocks, Shop card compaction).
- contracts: two added — one replays the owner's exact debug-run sequence and
  separately asserts the composition root still calls the release; one pins the
  recovered touch heights per control, the selected-difficulty styling, and the
  three hub status lines. **Each was confirmed to fail when its fix is
  reverted** (three separate reverts, three distinct failure messages).
- verify: **`python3 tools/verify.py --require-godot` — PASS, 209/209** against
  the exactly-pinned `4.7.1.stable.official.a13da4feb`. `bootstrap.py check
  --strict` passes.
- docs: `docs/product/menu-ux-review-2026-08-02.md`; `decisions.md` [D-0051];
  `current-state.md` overlay rule, hub status, dp sizing, suite count 29 → 31.

**The bug, and why it was a missing edge rather than a wrong rule.** A debug run
applies a session-only upgrade overlay and pauses purchases while it is on —
both correct; you should not spend flies against levels you do not own, and the
Shop says so in plain words. But the overlay was released only when the *next*
normal run launched. Returning to the menu released nothing, so the state was
enterable and not leavable: every exit ran through starting a different run or
finding the DEBUG toggle in Settings. Saved levels were never touched at any
point — only the menu's view of them. `main._show_front_end()` now releases it,
after the launcher has read the level the finished run used.

**The measurement that made the review worth writing.** The report's 48 dp touch
guidance was being read against the wrong ruler. `canvas_items`/`expand` maps
the 1280×720 reference onto the owner's 2340×1080 phone at 1.5×, and xxhdpi is
2.5 device pixels per dp, so **one reference pixel is 0.6 dp and 48 dp is 80
reference pixels**. Laying the real `FrontEndView` out headlessly gave a
per-screen census: median 32–41 dp, Garage minimum 25 dp, Test Lab minimum
20 dp. Nothing in the build cleared the bar except the three hubs' route cards.

**The finding I did not expect.** `_refresh_difficulty_buttons` set
`button.disabled = selected`, so Godot painted the difficulty the owner was
actually playing with `font_disabled_color` — 2.60:1 — while the two he was not
on kept 14.7:1. **The current choice was the dimmest control on Home and read as
unavailable.** It is visible in his recording and had survived every prior menu
pass, because "grey out the current one" is a plausible-sounding idiom that
happens to be exactly backwards.

**A first attempt that measured worse.** Hub panels were 48–57% empty, so I let
the route cards absorb the slack. That produced 393–397 px slabs — dead space
wearing a border. Reverted in favour of bounded 132 px cards plus a live status
line per hub reading from `PlayerProgress`, which is what the report actually
asks a route list to carry.

**Decisions made:** [D-0051]. Menu control sizes are judged in dp; the selected
state is never `disabled`; a debug overlay ends with its run.

**Next session should know:** five things are proposed and deliberately not
taken, each an owner choice rather than an omission — Shop progressive
disclosure (still only 3.5 of 7 tracks visible), the Field Guide detail panel at
**69% empty** (the worst in the build and the one screen with genuinely long
content — something looks mis-wired, not merely under-filled), a Test Lab
search across ~48 knobs, raising Test Lab targets against its measured six-card
grid, and panel borders at 2.25:1 against the report's 3:1 — that last one
trades D-0044's slate identity. Also: **orientation headroom is 133 words**
(6867/7000). The next session that touches `current-state.md` should trim before
adding.

## 💡 Session idea

**Headless layout measurement is cheap and nobody was using it.** Twenty lines
of GDScript in a `SubViewport` produced a per-screen touch-target census, a
panel-occupancy table, and the Shop's exact "2.5 of 7 cards visible" — all
numbers that three prior menu sessions had discussed qualitatively and none had
measured. The dummy renderer refuses pixels, which is presumably why nobody
tried; but geometry is not pixels, and geometry was the whole question.

The cheap standing version is a `tools/` script that prints the census on
demand, so any menu change can be judged against the previous run instead of
against a recollection. The expensive version — and probably the right one — is
a contract that fails when a *new* control lands below its screen's floor,
rather than pinning only the controls that happen to exist today.

## ⟲ Previous-session review

The previous session cut build 0.34.0 specifically so a fix would be
distinguishable on the device, and named the recurring shape: work judged
complete at *merged and green* when the deliverable is *the owner can tell it
apart*. That held here — but this session found the mirror image of it. The
debug-overlay bug was reachable from any build since the overlay shipped, and
was never caught because every contract exercised the overlay's *entry* and none
exercised leaving it without launching something else.

**Workflow improvement:** when a feature introduces a mode with an explicit
entry point, write the contract for the exit before the entry. "Can I get out of
this without doing something unrelated?" would have caught this at review time,
costs one assertion, and generalises past this bug — the Test Lab, the debug
start distance and the bird overrides all have the same shape.

- **📊 Model:** opus-5 · high · runtime bugfix — menus reviewed and resized
