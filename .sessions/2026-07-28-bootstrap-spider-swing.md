# 2026-07-28 · Founding bootstrap — Spider Swing repository substrate

> **Status:** `in-progress`

📊 Model: opus-5 · effort high · task class feature build

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

### Out of scope by design (Phase 0 is a separate follow-up)

No swing physics, obstacles, flies, currency, spiders, progression, missions,
monetization, production art, production signing, or store integration. The runtime
content ceiling is a boot scene, a visible placeholder, input-action definitions, a
headless smoke-test entry point, and test/config infrastructure.

---

## Work log

- [x] Verified GDD SHA-256 before use:
      `a63e804bfadfe6fd9db88686bf55ea2b57ce488157069190d8350968c39c7a53`
      — matches the owner's expected checksum exactly. Placed byte-identical at
      `docs/game-design/Spider-Swing-GDD-v2.0.md`; not rewritten, summarized, or
      reinterpreted.
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
      alongside `claude/*` (config change + regenerate; the generated workflow was
      never hand-edited).
- [x] Product layout, Godot 4.7.1 shell, verification tooling, ADRs, CI workflows.
- [x] Governance: ruleset on `main`, squash-only, delete-on-merge.
- [x] Phase 0 implementation issue opened and left open for the next agent.

---

## Verification results

Filled with exact evidence at close — see the close-out section below.

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

Filled at close.

---

## Owner actions

Filled at close — recorded only where a capability was actually attempted and
denied.
