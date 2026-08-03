# An environment setup script — one dependency, and it is not a package

> **Status:** `complete`

## Goal

Give the owner a startup script so a fresh Claude Code environment can run both
gates without hand-configuration. He supplied fleet-manager's
`archetype-coordinator.sh` as the shape to match.

## Scope guard

One new file, `scripts/env-setup.sh`. No code, no docs restructure, no change to
`.claude/settings.json`.

## Previous-session review

**previous-session review:** the north-star capture separated `inferred`
research from `measured` fact before anyone could act on it. Same instinct
applied here in a smaller way: the script reads the engine version from
`.godot-version` rather than hard-coding it, because a version pinned in two
places is a version that will drift.

## What this repo actually depends on

Checked rather than assumed: there is **no `requirements.txt`, no
`pyproject.toml`, no `package.json`.** Every import in `tools/*.py` is stdlib
(`__future__` and `concurrent` were the only non-obvious hits). `bootstrap.py`
is stdlib by kit design.

**The one real dependency is Godot 4.7.1 Standard**, and the two things that
make it painful in a fresh container are both undocumented anywhere:

1. `tools/verify.py` looks for `GODOT_BIN` / `GODOT` / `GODOT4`, then `godot`
   on PATH. A container has none of them.
2. **Headless Godot exits 134 (SIGABRT) with no useful message when the XDG
   dirs are not writable.** This cost real time in a live session before the
   cause was found.

So the script installs one engine and exports four variables. It deliberately
invents no manifest.

## Why `scripts/env-setup.sh` and not a SessionStart hook

- **fleet-manager's `setup-base.sh` auto-discovers `scripts/env-setup.sh`** in
  every child repo (`setup_one()`). Naming it this way makes spider-swing work
  unchanged as a solo environment *or* as a child of the coordinator workspace,
  and a fleet archetype for it need only call this file.
- **`.claude/settings.json` already has a SessionStart hook** owned by the kit
  (`bootstrap.py hook sessionstart`). Adding a second one risks fighting a file
  the kit regenerates.
- Environment setup runs once at container creation and is cached. A
  SessionStart hook would re-check a 100 MB engine on every session.

## The bug I shipped and then caught

The first version guarded its `.bashrc` writes with
`grep -q "GODOT_BIN=$GODOT_BIN_PATH"` while *writing* `GODOT_BIN="$PATH"` —
**with quotes.** The guard never matched, so every run appended another copy.
Three test runs left **16 duplicate lines**.

It looked idempotent and was not, which is the same shape as the checker that
looked sensitive and was not: a guard that is never exercised against the thing
it guards. Replaced with a sentinel-delimited block that is deleted and
rewritten, so N runs leave exactly one copy by construction rather than by a
string match.

## Verification — run, not claimed

- **Cold container** (no engine, no env vars): downloaded, installed, reported
  `4.7.1.stable.official.a13da4feb` — the exact build CI pins.
- **Warm re-run:** skipped the download.
- **Idempotency:** three consecutive runs → 1 sentinel block, 1 `GODOT_BIN`
  line, 3 XDG lines.
- **`CLAUDE_ENV_FILE` path:** four exports written.
- **Clean shell, nothing set by hand** (`env -i`):
  `tools/verify.py --require-godot` → exit 0, all checks passed;
  `bootstrap.py check --strict` → exit 0.

Worth recording: in one clean-shell run `GODOT_BIN` did not survive into the
child process, and **the `/usr/local/bin/godot` symlink carried it instead**.
The redundancy is not belt-and-braces decoration; it was load-bearing in a real
test.

## Owner questions

None. The contract is inherited rather than invented: every step is non-fatal
and the script always exits 0, per fleet playbook R15. A broken toolchain
degrades to "install it in-session", never to a container that will not start.

## 💡 Idea

**A guard that has never been run against the condition it guards is not a
guard.** The `.bashrc` dedup failed on a quoting mismatch that no amount of
reading would have surfaced — it needed three actual runs and a line count.
Both of the last two failures of this kind were found the same way, by running
the thing against reality instead of inspecting it.

Cheap generalisation for shell setup scripts specifically: **run it three times
and diff the environment**, rather than reading the idempotency guard. Worth
proposing to substrate-kit if a second setup script repeats it.

## Next slice

Unchanged and owner-driven: the three GPT sessions aimed at the 25 k north star.

- **📊 Model:** opus-5 · high · feature build — environment setup script
