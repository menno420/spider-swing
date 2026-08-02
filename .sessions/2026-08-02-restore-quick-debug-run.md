# Restore the compact Debug Test Run launcher

> **Status:** `complete`

## Goal

Restore the former quick Debug Test Run setup as a distinct Home route for
distance, one temporary all-track upgrade level, bird configuration, and an
immediate noncompetitive start. Preserve the complete persistent Test Lab as an
Advanced Test Lab route and leave the concurrent menu-style work untouched.

## Scope guard

Front-end state, routing, quick-launch presentation, staging semantics,
regression contracts, build identity, and living documentation only. Do not
change ordinary Play, upgrade ownership, saved progression, simulation tuning,
the Test Lab parameter catalogue, A/B/C profiles, or menu visual direction.

## Planned verification

- Prove Home opens the compact launcher first and Advanced Test Lab remains
  reachable from it.
- Prove quick runs apply only visible distance, temporary upgrade, and bird
  choices; saved advanced overrides must not leak into them.
- Measure the restored screen at 1280×720, 1280×600, and 1040×480.
- Falsify routing, upgrade overlay, baseline isolation, and reward eligibility.
- `python3 tools/verify.py --require-godot`
- `python3 bootstrap.py check --strict`

## About to happen

Recover the former purpose-built launch form from repository history, reconnect
it to the current state-owned navigation, and keep the detailed Test Lab behind
an explicitly secondary action.

## Previous-session review

**previous-session review:** PR #109 correctly centralized all tuning in a
persistent eight-category Test Lab, but it replaced rather than complemented the
earlier quick launch form. PR #112 then made that full editor a subordinate Home
utility without recovering the distance/upgrade-first workflow. The owner's
current recording and reference screenshot show that the capability remained
present while the fast comparison path was functionally gone.

## Implemented

- Home's existing debug-only route now opens a compact Debug Test Run screen
  with typed distance, 0/5k/10k/25k presets, one temporary OWNED/L0/L20/MAX
  all-track level, bird values and OFF/SLOW/BASE/FAST presets, and one pinned
  start action.
- Advanced Test Lab is a distinct state-owned screen one tap from the launcher;
  it retains all eight categories, auto-save, A/B/C comparisons, and trace review.
- Quick requests carry no sparse tuning dictionary. The composition root accepts
  an empty profile only while the compact screen is authoritative and accepts
  the saved sparse profile only while Advanced Test Lab is authoritative.
- Both launches retain the shared temporary progression overlay and the existing
  no-flies/no-records/no-checkpoints/no-leaderboard practice path. Ordinary Play
  still clears the overlay and neither route mutates owned progression.
- Build identity is `0.33.0-quick-debug-run-playtest`, Android code 53. D-0048
  records the quick-versus-advanced boundary; no menu material or visual layout
  direction changed.

## Shipped

- PR #114 implementation commit
  `ef6e88e97a53e0ac1f94dcd0b453fee4608da3c4` carries the complete 16-file
  batch. Its remote Git tree and the locally verified commit both resolve to
  `86c4c607a7d0a3eb45b60da01c1af07625cb96c1`.
- This final closeout withdraws only `claude/restore-quick-debug-run`'s claim.
  Required GitHub checks and Android export decide the terminal merge/build
  state.

## Layout evidence

- Exact Godot `SubViewport` measurements enclose card, Advanced route, and pinned
  Start at 1280×720, 1280×600, and strict unscaled 1040×480.
- The first probe found a 1094 px conditions row that expanded the 1040 px screen
  to x=1152.8. Compact quick-only copy and controls reduced the row to 914 px.
- At 1040×480, the card ends at x=993.2, Advanced at x=993.2, and Start at
  x=990.8; the conditions scroller has 85 px of travel. The taller sizes need no
  scroll.

## Adversarial verification

- Emitting the saved advanced tuning dictionary from Quick Start turned the
  front-end contract red for hidden-override leakage.
- Routing the Advanced button to Home turned the contract red for losing the
  distinct full editor.
- Increasing the compact bird-label width past its phone budget turned the
  contract red for recreating the horizontal overflow. All mutations were
  restored before the complete gate.

## Capability delta

The owner-approved `github_create_file` control-lane write succeeded directly on
`main` at `257377f5b7b95e72de5e7528019246c043549005`; the exact one-file boundary
is appended to `docs/CAPABILITIES.md`. Local HTTPS push remains unauthenticated,
so the already-recorded exact-tree GitHub app publication path remains the
implementation workaround. The requested `app_block` capability is still absent
and was not duplicated in the ledger.

## Verification evidence

- `python3 tools/verify.py --require-godot`: exact Godot
  `4.7.1.stable.official.a13da4feb`; tail: `[test_runner] PASS — 205 check(s)
  passed` and `[verify] all checks passed`.
- `python3 bootstrap.py check --strict`: tail: `session log
  .sessions/2026-08-02-restore-quick-debug-run.md complete` and `check: all
  checks passed.` Advisory stale-wall and orientation-headroom notes remain
  non-exit-affecting.

## Owner questions

None. The requested behavior has one reversible route split and does not require
a menu-style decision from this session.

## 💡 Session idea

Give debug launch requests a small typed launch-kind value (`quick`, `advanced`,
`trace`) at the application boundary. The current synchronous screen guard is
safe, but an explicit kind would make future automation and replay telemetry
self-describing without inferring intent from which screen emitted the signal.

## Next slice

Install the Android artifact and compare a 0 m/L0 run with a 25 km/MAX run from
the compact launcher, then open Advanced Test Lab and confirm the prior A/B/C
profiles still load unchanged.

- **📊 Model:** gpt-5.6-sol · high · feature build
