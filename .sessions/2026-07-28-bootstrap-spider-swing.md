# 2026-07-28 · Founding bootstrap — Spider Swing repository substrate

> **Status:** `complete`

- **📊 Model:** opus-5 · high · feature build

**Session type:** founding session (session 0 → 1). This is the repository's first
session; there is no earlier work to inherit.

**previous-session review:** none exists — this is the founding session of
`menno420/spider-swing`. The repository was created empty (initial README commit
only) on 2026-07-28, and this card is the first session card ever written here, so
there is no prior card to review, no prior deferred fix to pick up, and no prior
guard recipe to honour. The inherited context is external instead: the owner's
`Spider-Swing-GDD-v2.0.md` (checksum-verified, see below) and the pinned Substrate
Kit v1.20.2 release.

---

## Declared scope

Establish a trustworthy development substrate and a **bootable Godot shell** —
explicitly *not* the swing physics. Five deliverables:

1. Pinned Substrate Kit v1.20.2, adopted with enforcement wired, guided mode.
2. Minimal Godot 4.7.1 project that boots and terminates cleanly headless.
3. The GDD placed byte-exact, plus architectural contracts (ADRs 0001–0003).
4. Working CI: `game-quality` on PRs/main, plus an Android debug APK artifact.
5. Safe GitHub governance: labels, milestones, ruleset, squash-only merges.

**Scope delivered in full**, with one item constrained by a verified platform
limit (the `main` ruleset — see Owner actions).

### Out of scope by design (Phase 0 is a separate follow-up)

No swing physics, obstacles, flies, currency, spiders, progression, missions,
monetization, production art, production signing, or store integration. The runtime
content ceiling is a boot scene, a visible placeholder, input-action definitions, a
headless smoke-test entry point, and test/config infrastructure. Held.

---

## Work log

- [x] Verified GDD SHA-256 **before** use:
      `a63e804bfadfe6fd9db88686bf55ea2b57ce488157069190d8350968c39c7a53`
      — matches the owner's expected checksum exactly. Placed byte-identical at
      `docs/game-design/Spider-Swing-GDD-v2.0.md` and **re-verified in place after
      every subsequent commit**; not rewritten, summarized, or reinterpreted.
- [x] Created `menno420/spider-swing` private, default branch `main`, Issues and
      Actions enabled, no licence.
- [x] Labels `phase:0-swing-lab`, `type:infrastructure`, `owner-action`,
      `type:feature`; milestones Phase 0–3.
- [x] Downloaded Substrate Kit v1.20.2 release assets (`bootstrap.py`,
      `bootstrap.py.sha256`, `release.json`) from the pinned release tag — not from
      `main`, not from another adopter, not from memory. Checksum
      `48ecd4785f401bc76722ef312d1522abd2d9aff7b2e8931ed5e590bbfef9ece6` verified
      against **both** published manifests before execution.
      `bootstrap.py --version` → `substrate-kit 1.20.2`.
- [x] `adopt --include-claude --wire-enforcement`, `mode guided`.
- [x] All 16 interview slots answered from the owner's supplied values (14 named by
      the owner, plus `new_area_ownership` and `staleness_review` derived from those
      answers so no living ledger keeps an unrendered banner). `render --live`
      reports **0 unfilled placeholders**. Second `adopt` regenerated kit-owned
      artifacts against the real answers.
- [x] `substrate.config.json` → `automerge.branch_patterns` now covers `codex/*`
      alongside `claude/*` and `claim/*` (config change + regenerate; the generated
      workflow was never hand-edited). The enabler template already matched both
      namespaces; the config now agrees with it.
- [x] Godot 4.7.1 shell: Compatibility renderer, landscape, 1280×720 reference
      viewport with `canvas_items`/`expand`, 60 Hz fixed tick, 4 catch-up steps,
      five input actions defined and unconsumed, `Android Debug` export preset.
- [x] Verification tooling: `tools/verify.py` (single host entry point),
      `tools/check_architecture.py` (14 fixtures), `tests/test_runner.gd`
      (15 checks).
- [x] CI: `game-quality.yml`, `android-debug.yml`, `dependabot.yml`, issue and PR
      templates. Every host-owned `uses:` pinned to a full commit SHA resolved from
      the upstream repository's own git ref.
- [x] Docs: ADRs 0001–0003, `repository-layout.md`, `testing.md`,
      `substrate-kit-provenance.md`, `product/name-status.md`, `docs/README.md`,
      `docs/game-design/README.md`, rewritten root `README.md`,
      `project.index.json` with six areas.
- [x] Governance: squash-only merges, merge commits and rebase disabled,
      delete-branch-on-merge on, `allow_auto_merge` deliberately **off**.
- [x] Phase 0 implementation issue opened and left open for the next agent.
- [x] **Fixed a real CI conflict found by running the gates, not by reading them.**
      The kit-owned `substrate-gate` runs this repository's confirmed
      `verify_command` (`python3 tools/verify.py`) in a job that installs Python
      but **not** Godot — so the gate went red on a missing engine even though its
      own hygiene checks had passed. Resolved by giving `verify.py` three outcomes
      instead of two, and by moving the strict engine assertion into the job that
      actually installs the engine. Detail in the verification section below.

---

## Verification results

Exact, as run. Real exit codes throughout (never `$?` after a pipe).

### `python3 tools/verify.py` → **exit 0**

```
verify.py summary:
  [PASS] architecture checker self-test (0.1s)
  [PASS] architecture scan (0.0s)
  [PASS] Godot discovery and version (0.0s)
  [PASS] headless project import (5.8s)
  [PASS] headless boot smoke test (0.2s)
  [PASS] headless test runner (0.2s)
[verify] all checks passed
```

- Godot reported `4.7.1.stable.official.a13da4feb` — matches the pinned `4.7.1`.
- `tests/test_runner.gd`: **15 checks, 15 passed.**
- `tools/check_architecture.py --self-test`: **14 fixtures, 14 passed.**
- Boot smoke test output: engine `4.7.1-stable (official)`, main scene
  `res://game/bootstrap/main.tscn`, `physics_ticks_per_second 60`, display server
  `headless`, `boot: OK — smoke test passed`.

**Negative testing — the green is meaningful.** The runner was verified to *fail*,
not merely to pass. Injecting four regressions into a scratch copy (tick rate 60→30,
`toggle_debug` action removed, export preset renamed, and an outward
`simulation → presentation` preload) produced **exit 1** with all five expected
failures reported and 8 checks still passing. A gate that cannot go red is not a
gate.

### The `verify_command` / toolchain conflict, and how it was resolved

The kit-owned `substrate-gate` runs the interview's `verify_command` as its test
step. That command is `python3 tools/verify.py`, which needs Godot — but the gate's
job installs only Python (`3.14.6` via `actions/setup-python`). The gate's hygiene
checks passed and printed `check: all checks passed`; the *next* step then failed on
a missing engine. So the red was a toolchain mismatch, not a hygiene failure.

Three candidate fixes were considered. Making `verify.py` lenient about a missing
engine everywhere would have made `game-quality` meaningless the day an install
silently broke. Changing `verify_command` away from `tools/verify.py` would have
contradicted the single-entry-point requirement. Editing the kit-owned gate would be
overwritten by the next `adopt`.

What landed instead puts the strict assertion in the job that owns the engine:

| Situation | Result |
| --- | --- |
| Godot installed, correct version | everything runs |
| Godot absent, no flag | engine-independent checks run **strictly**; engine steps report `SKIP` behind a loud banner stating nothing about the Godot project was verified |
| Godot absent, `--require-godot` | **hard failure** |
| Godot present but wrong version, or a Mono/.NET build | **hard failure in every mode** — never a skip |

`game-quality` installs Godot and runs `--require-godot`, so a skip there could only
mean the install failed, and it is an error. `substrate-gate` stays useful in its
Python-only job: it still runs the architecture self-test and scan strictly.

All five paths verified by direct execution, real exit codes: present +
`--require-godot` → 0 (6 PASS) · absent → 0 (2 PASS, 4 SKIP) · absent +
`--require-godot` → 1 · wrong version 4.6.3 → 1 · Mono build → 1.

*Guard recipe:* this class recurs for any adopter whose `verify_command` needs a
toolchain the kit's Python-only gate does not install. The durable fix is kit-side —
either let the gate's verify step be opted out of, or document that
`verify_command` must be runnable with Python alone. Anchor: the
`verify suite` step in `.github/workflows/substrate-gate.yml`, generated from the
kit's gate template; the adopter-side lever is `tools/verify.py`'s
`--require-godot` split.

### `python3 bootstrap.py check --strict` → **exit 0** at close

One finding is suppressed through the kit's reason-required allowlist
(`.substrate/check-exceptions.yml`), recorded with verdict `false_positive`:
the vendored GDD carries no Substrate Status badge because adding one would change
its bytes and break the owner's checksum. `docs/game-design/README.md` carries the
badge on its behalf and records the hash plus the re-verification command. This is
the kit's own documented triage seam, not a bypass — a reason-less entry suppresses
nothing and is itself reported.

Remaining output is advisory-only (never exit-affecting) and concerns **kit-owned
seed rows** in `docs/CAPABILITIES.md` that refresh at upgrade, not this session's
work.

### CI

| Workflow | Result | Run |
| --- | --- | --- |
| `game-quality` | **success on its first real run** | https://github.com/menno420/spider-swing/actions/runs/30343017818 |
| `substrate-gate` | red by design while this card was born-red | https://github.com/menno420/spider-swing/actions/runs/30343017817 |
| `auto-merge-enabler` | red — surfacing the verified plan limit below, not a defect | https://github.com/menno420/spider-swing/actions/runs/30343017799 |
| `android-debug` | first run is the merge commit; proof appended below | https://github.com/menno420/spider-swing/actions/workflows/android-debug.yml |

**PR:** https://github.com/menno420/spider-swing/pull/1
**Phase 0 issue:** https://github.com/menno420/spider-swing/issues/2

---

## 💡 Idea

**The kit's stance vocabulary has no seat for a founding session.** v1.20.2 offers
`question`, `analysis`, `debug`, `review`, `plan` — and of those only `debug`
("targeted edits to fix a *known fault*") permits edits at all. A founding
bootstrap is neither a fault fix nor a read-only analysis, so this session had to
label itself `debug` to be allowed to write the very substrate the stance system
describes. Every adopting repo's first session hits this, which makes it a
systematic first-impression mislabel rather than a local annoyance.

*Guard recipe for a future kit session:* add a `build` (or `implement`) stance to
the stance table in the kit's stance registry — the same structure that emits the
`Stance:` / `In-scope actions:` / `Output:` block printed by
`bootstrap.py stance <name>` and `session-start` — with in-scope actions
`read, run, edit, create`. Assert it in the `--simulate` behaviour suite the way
the existing per-mode asserts work, so the founding session of the *next* adopter
can name what it is doing. Anchor: `bootstrap.py`, the stance definition table
backing the `stance` subcommand; test target: `bootstrap.py --simulate N
--mode guided`.

---

## Docs audit

**Result: clean at close.** `check --strict` reports no `badge`, `link`,
`reachable`, or `encoding` findings that are not triaged with a stated reason.

What the audit surfaced and what was done:

- **8 orphan findings** — every product doc I added (the GDD, `name-status.md`, all
  three ADRs, `repository-layout.md`, `testing.md`,
  `substrate-kit-provenance.md`) was unreachable from the doc graph. Cause worth
  recording: `check_reachable` seeds its roots from `docs/<readpath_docs>` plus
  `docs/**/README.md` — the **repository-root `README.md` is not a root**, so my
  links from there did not count, and `_is_adr` exempts only `decisions/NNN-*.md`,
  which does not match `technical/adr/`. Fixed by adding `docs/README.md` (a real
  documentation index) and `docs/game-design/README.md`, both of which become roots
  and link everything. All 8 cleared.
- **1 badge finding** on the vendored GDD — triaged as `false_positive` with a
  stated reason rather than "fixed", because fixing it would mean editing a
  byte-frozen document. See the verification section.
- **`[owner-action-fields]` advisory** — the `⚑ needs-owner` ask initially lacked
  the required OWNER-ACTION fields. Rewritten in full grammar (WHAT / WHERE / HOW /
  RISK / WHY-IT-MATTERS / UNBLOCKS / VERIFIED-NEEDED). Cleared.
- **`[seat-digest-stale]` advisory** — regenerated mechanically with
  `bootstrap.py seat-digest`. Cleared.
- **`control/inbox.md`** — the adopt seed's italic placeholder line is neither the
  file header nor a `## ORDER` block, and on a first-commit inbox (empty merge-base
  blob, so the whole file counts as appended) it reds the kit's own
  `inbox-order-grammar` check. Removed that one line. Recorded in
  `docs/CAPABILITIES.md` and `docs/technical/substrate-kit-provenance.md` so the
  next adopter does not re-derive it.

Living ledgers updated with verified facts, not aspirations:
`docs/current-state.md` (stability baseline, in-flight, shipped),
`docs/CAPABILITIES.md` (appended below the kit fence — never inside it),
`control/status.md` (real heartbeat, written last).

---

## Owner actions

One. Recorded only because the capability was actually attempted and denied.

### `main` is unprotected — branch protection is unavailable on this plan

The full OWNER-ACTION block (WHAT / WHERE / HOW / RISK / WHY-IT-MATTERS /
UNBLOCKS / VERIFIED-NEEDED) is in `control/status.md`. Summary:

**Attempted once per the discovery rule, on both endpoints, via the direct-PAT
path:**

- `POST /repos/menno420/spider-swing/rulesets` → **HTTP 403**
  `"Upgrade to GitHub Pro or make this repository public to enable this feature."`
- `PUT /repos/menno420/spider-swing/branches/main/protection` → **HTTP 403**,
  identical message.

The same token successfully changed every other repository setting this session
(squash-only merges, merge/rebase disabled, delete-branch-on-merge, labels,
milestones, issue creation, PR creation). So this is a GitHub **plan/visibility**
constraint on private repositories — not a token scope, venue, or agent capability
limit, and not routable-around agent-side.

**Consequences, all deliberate:**

- `allow_auto_merge` is left **off**. With zero required contexts, arming
  auto-merge merges a PR instantly — the opposite of a gate. The kit's
  `auto-merge-enabler` independently refuses to arm in this state; its red run is
  that refusal surfacing, not a workflow defect.
- Both gates were verified green by hand before merge, and that stays the landing
  protocol until the owner decides.

**The owner picks one:** GitHub Pro (~$4/month, keeps the repo private, then an
agent applies the ruleset in one step) · make the repository public (rulesets free,
but publishes the code and the GDD) · accept an unprotected `main` for now
(status quo, zero cost). All three are reversible; nothing is blocked on the answer.

### Not owner actions, but owner-only by nature (queued, not blocking)

- **Phase 0's exit gate is owner-judged** (GDD § 23): whether test players
  understand attach/release/Reel-In, whether deaths feel attributable, and approving
  one named physics preset as the baseline. Needs a real device.
- **Release naming** — trademark, domain, and store-conflict review before any
  public branding (`docs/product/name-status.md`).

---

## Flagged reversible decisions

Decide-and-flag, per the review ritual. Each is contained and reversible.

1. **Kit-owned workflows keep upstream tag refs, not SHA pins.** The SHA-pinning
   rule was applied to every host-owned `uses:` (9 references across
   `game-quality.yml` and `android-debug.yml`, each resolved from the upstream git
   ref). `substrate-gate.yml`, `auto-merge-enabler.yml`, and `branch-sweep.yml` use
   `actions/checkout@v5` / `actions/setup-python@v6` because they are kit-owned
   templates that adopt/upgrade overwrites — hand-pinning them would be reverted on
   the next upgrade. The durable fix belongs upstream in the kit.
2. **`branch-sweep.yml` retained.** Planted by adopt and not in the requested
   workflow list. Kept because it is kit-owned; deleting it would be undone by the
   next `adopt`.
3. **`gradle_build/use_gradle_build=false`.** Uses Godot's prebuilt APK template
   instead of a custom Gradle build — smaller failure surface, no Android source
   template to maintain. Revisit when a Godot Android plugin or custom manifest
   needs it (ADR 0003).
4. **ABIs limited to `arm64-v8a` + `x86_64`.** 32-bit Android is below the intended
   device floor and each ABI inflates the APK. One preset option to change.
5. **Two extra interview slots answered** (`new_area_ownership`,
   `staleness_review`) beyond the owner's 14, derived from the owner's own answers,
   so no living ledger shipped with an unrendered banner. Re-answer freely.
6. **Provisional device floor: Android 8.0 (API 26), arm64, GLES3.** Marked
   provisional in ADR 0003; Phase 1's exit gate sets the real floor on hardware.
7. **`docs/README.md` and `docs/game-design/README.md` added** beyond the requested
   layout, to satisfy the doc-reachability contract. Both are genuine indexes.
8. **Input actions bound to keyboard keys only** for now. Touch bindings arrive with
   the Phase 0 input router, because touch needs the buffered-command seam rather
   than a raw action poll.

---

## Handover — next session starts here

`main` carries the merged bootstrap. `python3 tools/verify.py` and
`python3 bootstrap.py check --strict` both pass. The next work is
[issue #2, Phase 0: Build the Swing Laboratory](https://github.com/menno420/spider-swing/issues/2)
— scoped, in the Phase 0 milestone, with nine acceptance categories and the
architecture constraints spelled out.

Read `docs/AGENT_ORIENTATION.md` → `docs/current-state.md` →
`docs/game-design/Spider-Swing-GDD-v2.0.md` § 5, 6, 8, 22, 23 →
`docs/technical/adr/0002-simulation-and-event-boundaries.md`. Keep the headless
smoke-test contract in `game/bootstrap/main.gd` working — CI depends on it.
