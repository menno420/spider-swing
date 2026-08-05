# Prepare everything the closed test needs before it can go live

> **Status:** `in-progress`

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

[[fill: shipped]]

## Verification

[[fill: verification]]

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
