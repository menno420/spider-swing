# Spider Swing · status
updated: 2026-08-01T09:48:50Z
phase: Bramble Canopy clearance correction — PR #86 final checks
health: exact engine and Android green · final-head checks pending
kit: v1.20.2 · check: green · engaged: yes
last-shipped: PR #85 rebuilds the player model from owner recordings
blockers: no code blocker; corrected Bramble passability needs owner-device evidence
orders: acked= done=
⚑ needs-owner: build 0.22.1 first-sequence Bramble verdict

⚑ OWNER-ACTION
WHAT: Install `0.22.1-bramble-clearance` and decide whether Bramble's first few obstacles are now physically traversable while still demanding clear vertical play.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30694253389/artifacts/8816709938
HOW: Install over any stable-key `0.19.0` or later build without uninstalling; open `DEBUG TEST RUN`, set 5000 m and `MAX`, then play several seeds. Confirm that every hard single or pair has a visibly open chunk around it, each hook/leaf is smaller without losing its silhouette, and mirrored pairs leave enough time for a planned Reel or a late Burst correction.
RISK: ↩️ reversible — install any later stable-key debug APK over this one; do not uninstall, so saved data remains.
WHY-IT-MATTERS: Exact geometry proves the prior overcrowding is gone, but only real touch play can prove the new 0.85-second commitment spacing feels achievable rather than merely fitting a mathematical route.
UNBLOCKS: Accept or revise Bramble's scale/cadence and decide whether to generalize timed traversal envelopes across the other authored zones.
VERIFIED-NEEDED: Exact Godot 4.7.1, 170/170 contracts, `game-quality`, Android export, ZIP/APK integrity, embedded source/build/package/assets, and the pinned stable signer are green; the remaining proof is this owner-device verdict.

notes: PR #86 changes only Bramble obstacle dimensions, pair spacing/recovery
cadence, build identity, contracts, and living records. Physics, speed,
Reel/Burst/Dive, upgrades, input, economy, saves, settlement, and every other
zone remain unchanged. Audio and later-zone device gates remain open after this
focused passability verdict.
