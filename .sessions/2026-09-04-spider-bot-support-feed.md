# 2026-09-04 — the Spider Bot support feed: this repo publishes what the bot may say

> **Status:** `in-progress` — branch `claude/spider-bot-support-feed-sthix0`,
> born red. Flipped to `complete` as the deliberate LAST step, once both
> required checks are green.

- **📊 Model:** opus-5 · xhigh · feature build
- **📍 Venue:** cloud-container
- **🔗 Session:** [session_01YCXH5D4omEgguaPYHwVz6d](https://claude.ai/code/session_01YCXH5D4omEgguaPYHwVz6d) · "Spider Bot AI operations bot"

**Why this repo is being touched at all.** The work is in `menno420/spider-bot`,
which is becoming the AI operations bot of the Slingy Spider Discord server
(owner direction, 2026-09-04). One thing that work needs cannot live there:
**what the bot may tell a tester about this game.** `spider-bot`'s
`spiderbot/knowledge.py` is a hand-copied block of prose from these docs, and it
has drifted.

## The drift, measured against this repository at `fc64a3f`

| the bot says | this repo says |
|---|---|
| *"currently in CLOSED ALPHA testing on Google Play"* | `docs/technical/play-closed-test-runbook.md` describes a closed track that **has not started**; the signed build sits on the **internal** track |
| *"wait ~15 minutes"* for group propagation | that figure appears **nowhere** in the runbook |
| *"wait an hour and retry"* for "App not available" | not present; the runbook's nearest figure is *"several hours"*, for a related but different step |
| four tester retention rules | **no textual match** anywhere in the runbook |
| *(no build version at all)* | `project.godot` carries `0.45.0-run-feedback`, version code 66 — the fastest-changing fact in the whole system, and the bot did not have it |

## What was done

- **`support/source.json`** — the curated half. Prose a person writes, edited
  here by whoever changes the game: testing state, join steps, known issues,
  troubleshooting, how the game works, what feedback is most useful, the
  retention rules, and the two official links.
- **`tools/generate_support_feed.py`** — stamps `schema_version`, reads the
  build identity **mechanically** from `project.godot`, validates the shape, and
  writes `support/spider-bot-support-feed.json`. `--check` fails when the
  committed artifact does not match its source.
- **`tools/verify.py`** — one more engine-independent step, beside the audio
  reproducibility check it is modelled on. Both required checks on `main`
  (`substrate-gate` and `game-quality`) run this script, so the feed is
  fail-closed in CI, which is `CONSTITUTION.md`'s own cross-repo-feed rule:
  *"the producer stamps the version into the artifact and enforces fail-closed
  parity in CI."*

**Two files rather than one, on purpose.** The build identity is read from
source and cannot drift. Everything else is prose, and pretending a regex could
extract join steps from a runbook would make the generator a second source of
truth rather than a projection of one.

**The artifact is byte-reproducible — no timestamp.** `source_sha` is the
SHA-256 of the curated source, which identifies exactly which content produced
the feed and, unlike a clock, is the same on every run. So `--check` is a plain
comparison with nothing carved out of it.

## Verification — real exit codes

```
python3 tools/generate_support_feed.py            → 0
python3 tools/generate_support_feed.py --check    → 0   (current)
python3 tools/verify.py                           → 0
    generated audio reproducibility  PASS
    spider-bot support feed          PASS   ← new
    architecture checker self-test   PASS
    architecture scan                PASS
    engine steps                     SKIP   (no Godot in this container;
                                             game-quality installs it and runs
                                             --require-godot)
```

**Fail-closed proven with positive controls, not assumed:**

| control | exit |
|---|---|
| artifact edited to disagree with its source | **1** — *"is stale"* |
| `join_steps` deleted from the source | **1** — *"missing join_steps"* |
| `facts` given the wrong shape | **1** — *"facts[0] must be an object with 'name' and 'value'"* |
| everything restored | **0** — *"current"* |

**And the consumer end was exercised against this exact artifact**, not against
a fixture: `spider-bot`'s `spiderbot/support.py` parsed the generated file and
produced a prompt block carrying `0.45.0-run-feedback` (version code 66) — the
build version the hand-copied block never had.

## What this does NOT do

No gameplay, tuning, balance or content is touched. No game source is modified.
Nothing about this repository's own behaviour changes: the artifact is a
projection of documents that already existed, plus two fields read from
`project.godot`.

`known_issues` ships **empty**. It is the field the bot most wants and the one
this session has no authority to fill — a known issue is the owner's call, not
an inference from a doc. The seam exists so it can be filled in one edit.

## 💡 Session idea

**The `--check` idiom in `tools/verify.py` is now a pattern with two instances**
(`generate_audio_samples.py --check` and this one), and both exist for the same
reason: a committed artifact that some other consumer reads must not silently
disagree with the source it is generated from. Worth naming as a recipe the next
generated artifact copies rather than re-derives — the shape is: pure generator
→ `--check` mode → one `run_step` in the engine-independent section.

*Guard recipe:* the anchors are `tools/generate_support_feed.py:main --check`
and `tools/verify.py`'s engine-independent block (the `run_step` calls between
`audio_generator` and `checker`); the test target is the three positive controls
in the table above.

## ⟲ Previous-session review

The last card here is `2026-08-13-run-feedback-prompt.md`. Its work — pairing
first-session comprehension feedback to run records — is what makes this feed's
`feedback_wanted` section answerable: it asked *"did you know what you should
have done differently?"* at the moment of death, and the answer to *what should
we ask testers for* now has evidence behind it rather than a guess. Nothing in
that session is contradicted here; this one adds a consumer for facts that
session's work makes worth publishing.
