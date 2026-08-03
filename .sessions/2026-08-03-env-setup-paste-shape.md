# The setup script runs before the repo exists — correcting the shape

> **Status:** `complete`

## Goal

Correct `scripts/env-setup.sh` for how the environment setup field actually
works, and provide the thin paste-in wrapper that belongs in it.

## Scope guard

One file hardened. No new dependency, no docs restructure.

## Previous-session review

**previous-session review:** the previous card claimed this script was validated
end to end. It was — but **against the wrong invocation**. Every test ran it
from inside a checkout, because that is how I assumed the environment would call
it. The owner corrected the mechanism, which invalidated the assumption rather
than the code.

## The correction

The environment's **Setup script** field holds the script itself, and its own
description says it *"runs when a new session starts, **before Claude Code
launches**."*

So it cannot assume a checkout exists. Two things in the original were wrong:

- `REPO_ROOT` derived from `${BASH_SOURCE[0]}/..`, which resolves to a temp
  directory when the script is pasted rather than committed.
- The engine pin was then read from `$REPO_ROOT/.godot-version`, which would
  silently miss and fall back to a hard-coded `4.7.1` — reintroducing exactly
  the two-places-to-drift problem the pin-reading was added to prevent.

That the fallback *worked* is what makes it worth recording: the script would
have installed the right engine while its stated reason for being correct was
false.

## What changed

- **`REPO_ROOT` is searched, not derived** — `CLAUDE_PROJECT_DIR`, the script's
  own parent, `$PWD`, `$PWD/spider-swing`, `/workspace/spider-swing`,
  `$HOME/spider-swing`, `/home/user/spider-swing` — first one holding a
  `.godot-version` wins.
- **With no checkout anywhere, the pin is fetched from `origin/main`.**
  spider-swing is public and `raw.githubusercontent.com` answers 200
  unauthenticated, so the pin is still read rather than guessed. The hard-coded
  constant survives only as a third fallback, and it now logs a warning when it
  is used.

## Why the paste-in script stays thin

It follows fleet-manager's `archetype-coordinator.sh` pattern exactly: a thin
config that resolves the real implementation locally, then falls back to a raw
fetch of the canonical copy. **One lineage, one place to maintain.** A
self-contained paste would be simpler to hand over once and would then drift
from the repo the first time anything changed.

## Verification — the invocations that were previously untested

- **Invoked from a temp path with the repo present** → found
  `/home/user/spider-swing/.godot-version`, resolved 4.7.1.
- **Invoked with every search path suppressed** → *"engine pin read from
  origin/main (no local checkout yet)"*, resolved 4.7.1.
- Raw fetch in isolation returns `4.7.1`.
- Idempotency, cold install and both gates were verified on the previous card
  and are unchanged by this edit.

## Owner questions

None. The contract is unchanged: every step non-fatal, always exits 0.

## 💡 Idea

**A test that exercises the wrong invocation proves nothing about the right
one.** The previous card ran the script five ways and called it validated —
every one from inside a checkout, because that was the assumption under test
rather than a thing being tested. The owner corrected the mechanism in one
sentence and all five results became irrelevant.

That is the third instance of the same shape in three days: a checker tested
against synthetic fixtures instead of the real corpus, an idempotency guard
never run three times, and now a setup script never run the way setup runs it.
**Test the invocation, not the function.** Worth proposing to substrate-kit
once there is a fourth, because three is now a pattern rather than a
coincidence.

## Next slice

Unchanged: the owner's three GPT sessions aimed at the 25 k north star.

- **📊 Model:** opus-5 · high · runtime bugfix — correct the setup-script invocation shape
