# Substrate Kit provenance

> **Status:** `reference`
>
> How the vendored kit got here, and how to re-verify the pin at any time.

## Pinned version

**Substrate Kit v1.20.2**, from the release tag:
<https://github.com/menno420/substrate-kit/releases/tag/v1.20.2>

`bootstrap.py --version` reports `substrate-kit 1.20.2`.

## Provenance

`bootstrap.py` was downloaded from the **release assets of the pinned tag** — not
copied from `main`, not from another adopter, not from chat history, and not
reconstructed from memory. Its checksum was verified **before** it was executed.

## The published manifest

`release.json` from the same release, recorded here verbatim so the pin stays
auditable without a network call:

```json
{
  "breaking": false,
  "changelog_anchor": "https://github.com/menno420/substrate-kit/blob/main/CHANGELOG.md#1202---2026-07-21",
  "min_upgrade_from": "1.0.0",
  "requires_state_migration": false,
  "sha256": "48ecd4785f401bc76722ef312d1522abd2d9aff7b2e8931ed5e590bbfef9ece6",
  "upgrade_steps": [
    "download bootstrap.py next to your vendored copy as bootstrap.py.new",
    "run: python3 bootstrap.py.new upgrade"
  ],
  "version": "1.20.2"
}
```

The published `bootstrap.py.sha256` is committed at the repository root and agrees
with the `sha256` field above.

## Re-verifying the pin

```bash
sha256sum -c bootstrap.py.sha256   # must print: bootstrap.py: OK
python3 bootstrap.py --version      # must print: substrate-kit 1.20.2
```

## Upgrading

Follow the release's own `upgrade_steps` — download the new `bootstrap.py`
alongside the vendored copy as `bootstrap.py.new`, then run
`python3 bootstrap.py.new upgrade`. Verify the new checksum before executing it,
exactly as the founding adoption did.

After any upgrade, re-run:

```bash
python3 bootstrap.py adopt --include-claude --wire-enforcement
python3 bootstrap.py render --live
```

Upgrade regenerates the kit-owned workflows in place, so **hand edits to
`substrate-gate.yml`, `auto-merge-enabler.yml`, or `branch-sweep.yml` are
overwritten.** Change `substrate.config.json` and regenerate instead. Host-specific
CI belongs in `game-quality.yml` or `android-debug.yml`.

## Kit-owned files

Do not hand-edit:

```
bootstrap.py
.substrate/**
.github/workflows/substrate-gate.yml
.github/workflows/auto-merge-enabler.yml
.github/workflows/branch-sweep.yml
scripts/env-setup.sh
```

The Substrate-generated living ledgers under `docs/` (`architecture.md`,
`ownership.md`, `runtime_contracts.md`, `current-state.md`, `reading-path.md`,
`owner-profile.md`, `collaboration-model.md`, `ai-project-workflow.md`,
`AGENT_ORIENTATION.md`, and `CONSTITUTION.md`) are **rendered from interview
answers**. Change them with:

```bash
python3 bootstrap.py answer <slot> "new value"
python3 bootstrap.py render --live
```

## Local configuration changed during adoption

`substrate.config.json` → `automerge.branch_patterns` was extended to cover
`codex/*` alongside `claude/*` and `claim/*`, so both agent branch namespaces are
recognised. `branch_sweep.branch_patterns` already covered `codex/*`.

## One finding worth carrying forward

The adopt seed for `control/inbox.md` contains an italic placeholder line
(`*(no orders yet — …)*`) that is neither the file header nor a `## ORDER` block.
On a **newly added** inbox — where the merge-base blob is empty, so the whole file
counts as appended — that line trips the kit's own `inbox-order-grammar` check and
holds `check --strict` red. Removing the line resolves it. Any future adopter
starting from an empty repository will hit the same thing.
