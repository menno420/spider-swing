# Privacy policy — publishable text

> **Status:** `owner-guidance`
>
> ⚠️ **The name is not chosen.** "Swingy Spider" was ruled out on 2026-08-05 —
> it is taken by a same-genre game. Replace the placeholder in the heading
> before publishing. See `../product/name-status.md`.
>
> This is a **draft for the owner to read and publish**, not a published policy.
> Google Play requires a live, public privacy-policy URL before a release can be
> rolled out to any track above internal testing — including the closed test.
>
> **It describes the app as it is today.** The moment a build uploads a score to
> an online leaderboard, both this text and the Data safety form must change
> *before* that build goes out. The trigger and the required edits are in
> [`../technical/play-closed-test-runbook.md`](../technical/play-closed-test-runbook.md)
> § "When leaderboards go online".

---

## Publishable text begins

# Privacy Policy for [GAME NAME — NOT YET CHOSEN]

**Last updated: 5 August 2026**

This policy explains what the game does with information on your device. It is written to be read, not to be survived.

## The short version

The game does not collect your data. It does not send anything about you, your
device, or how you play to us or to anyone else. There are no user accounts, no
advertising, no analytics, and no third-party tracking software in the game.

## What the game stores, and where

The game saves your progress so it can carry on where you left off. That
includes your settings, your best distances, which upgrades and cosmetics you
own, your in-game currency balances, which regions you have reached, and a
record of your recent runs.

**All of this is stored only on your own device**, inside the private storage
area Android gives the game. We cannot see it. It is not uploaded anywhere.

If you uninstall the game, Android deletes that storage and the saved progress
goes with it.

## What the game does not do

- It does not ask you to create an account or sign in.
- It does not show advertisements.
- It does not contain analytics, crash-reporting, or tracking software.
- It does not use an advertising identifier.
- It does not request your location, camera, microphone, contacts, or files.
- It does not sell or share information about you, because it does not have any.

## Permissions

The game does not request any Android permission that gives it access to your
personal information.

## Children

The game is not directed at children under 13 and does not knowingly collect
information from anyone. Because it collects nothing, there is nothing to
delete — uninstalling removes the local save.

## Changes to this policy

Features that would change this — most likely online leaderboards, which need to
send a score off your device to work at all — are not in the game today. If that
changes, this policy will be updated to say exactly what is sent and why, and
the app's Data safety information on Google Play will be updated **before** that
version is released.

## Contact

Questions about this policy: **mennovanhattum@gmail.com**

## Publishable text ends

---

## Maintainer notes — not part of the published policy

**Contact address.** Google Play requires a public contact email on the store
listing regardless, so this address is public either way. Swap it for a
dedicated one if you would rather keep your personal inbox off the listing —
change it in both places.

**Why it claims no collection.** Verified against the source on 2026-08-05, not
assumed:

- `game/` contains **no** network API — no `HTTPRequest`, `HTTPClient`,
  `StreamPeer`, `PacketPeer`, `WebSocket`, or multiplayer class anywhere.
- Every persistent write goes to `user://` — `player_settings.json`,
  `player_progress.json`, `debug_test_profile.json` — which is Android's
  app-private sandbox.
- The only `https://` strings in game code are citation links in
  `spider_biology_catalog.gd`, shown as reference text.
- `leaderboards_eligible` is a boolean on a local run settlement. There is no
  leaderboard backend.

Google's Data safety definition, fetched from
[answer/10787469](https://support.google.com/googleplay/android-developer/answer/10787469):
*"Collect means transmitting data from your app off a user's device"*, and
*"User data accessed by your app that is only processed locally on the user's
device and not sent off device does not need to be disclosed."*

So the game genuinely retains run and input data — the owner is right about that
— and Google still counts it as **not collected**, because none of it leaves the
device. Both statements are true; they answer different questions.

**Where to publish it.** The repository is public, so the two cheapest options
are GitHub Pages (Settings → Pages → deploy from a branch) or, as an immediate
stopgap, the rendered file URL on github.com. Play needs a URL that loads a
readable policy; it does not care what hosts it.
