# Re-scope the overnight brief to code, docs and measurement

> **Status:** `complete`

## Goal

Correct a drift in the overnight brief: it leaned zone-visual, which is work the
unattended Claude session cannot do, and it buried the campaign work the owner
asked for first.

## Scope guard

Two sections of one planning document. No code, no design change, no new
decision.

## Previous-session review

**previous-session review:** PR #68 added the cold-start requirement to the wake
chain, which was the right catch. Its blind spot was the backlog it left in
place: the slices were ordered around the Grok zone material because that was
the input in front of it, not around what the owner had actually asked the night
session to do. Follow the owner's stated priority, not the shape of the most
recent document.

## What was wrong

Two faults, one visible and one not.

**Claude cannot produce art.** The brief's zone slices said "wire its visual
identity", which reads as an art task. There is no image generation here, so
that slice would have burned a wake discovering it.

**The order followed the input, not the request.** The owner's original ask
opened with campaign levels, then mechanics, then upgrades, with the simulator
used wherever it helps. The brief opened with a moving-parts ADR and a zone
skeleton, because the Grok zone document was the freshest input. Zones matter,
but they are the half of the work with a hard dependency on art.

## What changed

- **An explicit division of labour.** The session produces code, documents and
  measurements, never art or audio. Where a feature needs art, it builds the
  mechanical half and defines the seam. That seam already exists:
  `visual_profile` per region branches the renderer, so a zone can be
  mechanically complete and playable on existing art while its own art is
  produced separately.
- **The backlog reordered to the owner's priority.** Measurement first because
  it is cheap and unblocks two later slices; then the campaign teaching tier;
  then difficulty modes; then the upgrade audit; then the moving-parts ADR, the
  moving-anchor proof, and Zone 4's mechanical half last.
- **The campaign slice made concrete.** The approved campaign decision already
  named the real gap: the tutorial explains Reel, Burst and Dive across six
  static steps and then never asks the player to perform any of them. The slice
  is now "build levels that cannot be finished without each verb", which needs
  no art at all.

## Verification

`python3 bootstrap.py check --strict` → **exit 0**. The gate first rejected the
brief for citing a decision id already stamped in `current-state.md`; the brief
now refers to those decisions without restamping them.

## Open owner questions

None.

## 💡 Idea

The division of labour deserves a home outside a dated planning file. Which work
belongs to which agent — Claude for code, documents and measurement; ChatGPT for
art; the `visual_profile` seam between them — is a working-agreement fact that
every future session and every future brief needs. A short section in
`AGENT_ORIENTATION.md` would stop each new brief rediscovering it.

## Next slice

Nothing queued for this session. The overnight session begins at slice 1,
difficulty curve measurement.

- **📊 Model:** opus-5 · high · idea/planning — brief re-scoped to the systems
  and progression lane
