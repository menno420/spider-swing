# Runtime gameplay SFX

> **Status:** `runtime-assets`

Twenty-five original procedural samples cover the first integrated gameplay
audio pass: web attach/release, Reel start/loop/empty, Burst, Dive, fly and boost
pickup, invalid actions, rescue, death, Buckler bounce, and five later-zone
warning cues.

`audio-sample-manifest.json` is authoritative for format, duration, headroom,
loop state, event mapping, provenance, and SHA-256. Authoring and regeneration
instructions live in `assets/source/audio/README.md`.

These are playtest samples, not locked final mixes. Device feedback should judge
whether each event reads through a phone speaker, whether the loop fatigues, and
whether later-zone warnings lead the hazard without becoming distracting.
