# Rebuild Home as a run deck, and cut the build that makes it judgeable

> **Status:** `complete`

## Close-out

**Evidence:**

- source: `spider_catalog.gd` (`loadout_groups`, `loadout_group_progress`),
  `spider_ui_theme.gd` (`hero_style`, `meter_style`), `front_end.gd`
  (`_build_home` rebuilt as deck + rail, `_render_home_deck`), plus the build
  identity in its five pinned files.
- contracts: one added — the deck must report the owner's own figures (best
  distance, region, three group totals against their ceilings) and the effect
  lines must move when upgrades are owned. The Home hierarchy contract was
  rewritten from grid shape to substance, and now asserts Start Run is the only
  filled control by comparing style-box luminance. **Three separate reverts, three
  distinct failures**, so neither is vacuous.
- verify: **`python3 tools/verify.py --require-godot` — PASS, 211/211** against
  the exactly-pinned `4.7.1.stable.official.a13da4feb`. `bootstrap.py check
  --strict` passes.
- docs: `decisions.md` [D-0053]; `current-state.md` Home shape and 0.37.0.

**The mechanism, which measurement found and reading had not.** The owner
reviewed twelve external menu concepts and could not pick one, but was exact
about the fault: the buttons have no identity. The left panel holds an image and
a number; the right panel holds neither — and **one button style was doing four
different jobs** (primary action, navigation, selection, debug utility),
separated only by border hue. The previous session had already raised those same
buttons toward the 48 dp floor and he still called them dull, which is the proof
that size was never the complaint.

**A temptation refused, and it is the most important line in this card.** The
mockup he chose from showed Control / Power / Recovery stat bars. They read
beautifully and correspond to **nothing in the data**. Building them would have
meant inventing a weighted score over `SwingConfig` fields, putting a number on
Home that no field backs and no contract could defend. The three loadout chips
are the catalogue's own scopes and kinds instead — Reel is the three core reel
tracks, Burst is the two core burst tracks, the third is the spider's two
identity tracks — so the totals cannot drift from the tracks that produce them,
and the contract asserts the exact sums.

**Decisions made:** [D-0053], recorded as explicitly reversible. The owner chose
this direction as an experiment — *"a good way to actually compare what the
change actually means for the UX"* — so it is expected to move again.

**Next session should know:** two hazards fired during this session and both
were caught by machinery rather than by memory. `EXPECTED_CHECK_COUNT` collided
on the merge — main and this branch each added a contract and each wrote `210`,
so the line merged clean while the tree ran 211; the runner's own error message
named the cause and the fix. And **D-0052 was taken by #119 while this was in
flight**, so the ledger id and its three source references were renumbered to
D-0053. Both are recurring; check the ledger tail and re-run the suite after any
rebase.

Orientation headroom was down to 61 words and is now **287** — three
2026-08-01 entries were dropped from the shipped log, which its own closing rule
already permits, and the one durable instruction inside them (the live contract
total is `EXPECTED_CHECK_COUNT`, never prose) was kept.

Also unchanged and still open from the previous card: Shop progressive
disclosure, the Field Guide detail panel at 69% empty, a Test Lab search, and
panel borders at 2.25:1.

## 💡 Session idea

**The right deliverable for an undecidable visual choice was not a longer
argument, it was a rendering.** The owner had twelve concepts and could not say
why he liked parts of each. Three directions mocked at his device's real aspect
ratio, in the game's own palette, with his own save figures, turned an
unanswerable question into a one-line answer in a single reply.

That is repeatable and currently ad hoc. The seat cannot screenshot Godot menus
— the dummy renderer returns an empty image — but it can lay out the real
`FrontEndView` headlessly and read every rectangle, and it can render HTML at
the same aspect. A small `tools/` script that dumps the measured geometry of a
screen as an HTML skeleton would make "show me two options" cost minutes instead
of an afternoon, and would keep the mock honest by construction, because its
boxes would come from the engine rather than from a guess.

## ⟲ Previous-session review

The previous session raised every Home control toward a measured 48 dp floor and
reported the improvement in dp. The owner's next message called the same screen
dull. Nothing in that work was wrong — the targets really were 25–35 dp and
really did need raising — but it answered the question that had been *measured*
rather than the one that had been *asked*, and no amount of extra height was
ever going to fix a screen whose problem was sameness.

**Workflow improvement:** when a measurement produces a clean number, check that
the number is a proxy for the complaint before spending the session on it.
"Buttons are too small" and "buttons look identical" both present as "the menu
feels bad", they have different fixes, and only one of them has a metric — which
is exactly why the metric is the one that gets worked on.

- **📊 Model:** opus-5 · high · feature build — Home run deck
