# Prepare everything the closed test needs before it can go live

> **Status:** `complete`

## Goal

The owner has the developer account — verified and paid. The binding constraint
is now the **12 testers × 14 continuous days** closed-test clock, which cannot
start until a build is actually downloadable. Prepare every artefact that gate
depends on so the owner's remaining work is paste-and-click, not authorship.

## Scope guard

This PR may add legal, product, and technical documentation and one developer
tool script. It does not change simulation, input, gameplay, course generation,
difficulty, progression, rewards, saves, tutorial content, export presets, or
any workflow. It commits no credential and generates no key.

## Previous-session review

**previous-session review:** PR #162 landed the `Android Release` preset and the
dispatch-only bundle workflow (ADR 0005), leaving the artifact side ready and
the account side owner-gated. The owner has since resolved the account gate and
corrected a factual assumption from that session — the game *does* retain run
data — which changes what the privacy policy and Data safety form must say.

## Shipped

- `docs/legal/privacy-policy.md` — publishable draft, marked
  `owner-approval-required`. Play requires a live policy URL before any track
  above internal testing, including the closed test.
- `docs/product/play-console-answers.md` — every App content declaration with
  the answer **and the reasoning**, so the owner is certifying something he
  understands rather than copying a table.
- `docs/product/play-store-listing.md` — app name, three short-description
  options and a full description, written from the GDD's own § 2.1–2.5 product
  definition. Character counts **measured**, not estimated.
- `docs/technical/play-closed-test-runbook.md` — the critical path in order,
  with what is verified and what is not stated per item.
- `tools/make_upload_keystore.sh` — generates the upload key, refuses to write
  anywhere inside the working tree, prints the exact secrets to paste, and
  commits nothing.

## Verification

- `python3 tools/verify.py --require-godot` → **exit 0**, **256/256** contracts.
  Real exit code, not `$?` after a pipe. No runtime change was expected and none
  occurred; the run proves the docs did not disturb the tree.
- `python3 bootstrap.py check --strict` → **exit 0** once this card flips.
- **Keystore script guards tested rather than asserted.** Pointed at `./build`
  and at the repo root it refused both with real **exit 1**; `bash -n` clean;
  `git status` confirmed nothing was written into the tree. Pointed outside the
  repo it passed the guard and reached `keytool`, which then wanted a TTY. The
  first reading of that test was itself wrong — `... | head` reported `exit=0`,
  which was `head`'s status, and re-running without the pipe gave the real 1.
  The repo warns about exactly that trap and it still nearly landed.
- **Character counts corrected after measuring.** The listing doc claimed
  "measured, not estimated" while carrying four estimated numbers (69/67/63 and
  1,412). Measured values are 70/68/64 and 1,488; all are within limits, and the
  label was the defect rather than the copy.
- **Data-collection claim verified in source, not assumed:** `game/` contains no
  `HTTPRequest`, `HTTPClient`, `StreamPeer`, `PacketPeer`, `WebSocket` or
  multiplayer class; every persistent write targets `user://`; the only
  `https://` strings are citation text in `spider_biology_catalog.gd`;
  `leaderboards_eligible` is a local settlement boolean with no backend.

**Honest nulls:** `android-release.yml` still has never run end to end — it needs
the owner's repository variables. Store graphics are **not produced**, and cannot
be from a session: screenshots must be real capture and this repo's own tooling
records that the headless renderer gives untrustworthy pixels. Tester
opt-in/opt-out mechanics beyond the URL format, whether a published store name
can later be changed, and everything about Play Games Services all remain
unverified and are marked as such where they appear.

## 💡 Session idea

Two findings inverted the plan the previous session left behind, and both came
from reading a source rather than reasoning from a sensible-sounding premise.

**The store listing is on the critical path, not after it.** A release cannot be
rolled out to a *closed* track until the store listing, the App content page and
pricing are all complete — so icon, screenshots and descriptions block the
tester clock rather than following it. The previous session filed the listing as
a late item; that ordering was wrong.

**"Collects data" and "collects data" are two different sentences.** The owner
is right that the game retains run and input data. Google's Data safety form
defines *collect* as **transmitting off the device** — and `game/` contains no
network API at all, with every write going to `user://`. So the honest answer to
Google is "no data collected", and the honest answer to the owner is "yes, it
records your runs." Both are true because the words mean different things. The
form asks the narrower question, and answering it with the broader intuition
would have been a false declaration.

- **📊 Model:** opus-5 · high · documentation + tooling
