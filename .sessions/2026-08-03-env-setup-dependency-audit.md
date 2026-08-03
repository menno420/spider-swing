# Auditing the setup script against the whole repo, not against memory

> **Status:** `complete`

## Goal

Answer the owner's question — *does this load all packages a session working on
the game would use?* — by auditing rather than asserting.

## Scope guard

One file. No new tooling, no docs restructure.

## Previous-session review

**previous-session review:** the last card corrected the script's invocation
shape after the owner pointed out the setup field runs before Claude Code
launches. This card is the same lesson at the dependency layer: the previous
version's package list came from an audit run on **2026-08-01, at build 0.29.0**.
The repo is now at **0.38.0**. A dependency list is a claim about a tree, and
the tree moved.

## The answer was "almost", and the gap was real

An AST walk over every `.py` in the repo (excluding the vendored kit) found
exactly one third-party import, and the script did not install it:

**`tools/zone_art_audit.py:13` — `from PIL import Image, ImageDraw, ImageFont,
ImageOps`.** Hard, unguarded, module-level. Without Pillow the tool cannot print
`--help`.

Two things made this worth catching rather than shrugging at:

- **It does not gate CI.** `verify.py` never calls it, so both gates stay green
  without Pillow. The failure surfaces only when someone does zone-art work —
  the kind of gap that hides until it is expensive.
- **Pillow was already present in this container**, at 12.3.0, by luck of the
  base image rather than because anything installed it. Checking
  `importlib.util.find_spec` would have reported "ok" and been useless. The gap
  only appeared by reading the imports and asking where they came from.

Verified the failure is real by blocking `PIL` through `sys.meta_path` and
confirming the `ImportError`, rather than assuming an unguarded import fails.

## What changed

- **Pillow is now installed as REQUIRED**, with the reason and the exact file
  and line in a comment, so the next person to read the script knows why it is
  there.
- `imageio-ffmpeg` stays but is labelled OPTIONAL — no file imports it.
- **A new "deliberately NOT installed" block** records that JDK, the Android SDK
  and Godot export templates are excluded on purpose: no tool runs a local
  `godot --export`, the APK is built by `android-debug.yml` through the
  chickensoft action, and pulling ~1 GB of Android toolchain into every session
  would buy nothing. Written down so a future session reads it as a decision
  rather than an omission.

## Verification

- AST walk over every repo `.py`: `PIL` is the only third-party import.
  `verify.py`, `check_architecture.py`, `difficulty_curve.py`, `fit_bot.py`,
  `generate_audio_samples.py` and `bootstrap.py` are pure stdlib.
- No local export path exists (`grep` for `--export` / `export_presets` in
  `tools/*.py` returns nothing), which is what licenses the exclusion above.
- Script run: Pillow reported installed.
- `tools/verify.py --require-godot` → exit 0. `bootstrap.py check --strict` →
  exit 0. `tools/zone_art_audit.py --help` → runs.

## Owner questions

None. The contract is unchanged: non-fatal steps, always exits 0. A failed
Pillow install now logs a WARNING naming the tool it disables, rather than
passing silently.

## 💡 Idea

**A dependency list is a claim with an expiry date, and nothing re-checks it.**
This one was audited at 0.38.0 and had already gone stale, because
`zone_art_audit.py` arrived somewhere in between. The script will drift again
the next time a tool grows an import.

Cheap fix worth proposing to substrate-kit: an advisory that AST-walks the
repo's Python for third-party imports and warns when one is absent from the
environment setup script. It is the same shape as `check_claim_provenance` —
compare a document's claim against the tree it describes — and it would have
caught this without anyone asking the question.

## Next slice

Unchanged: the owner's three GPT sessions aimed at the 25 k north star.

- **📊 Model:** opus-5 · high · review/verify — audit the setup script's dependency list
