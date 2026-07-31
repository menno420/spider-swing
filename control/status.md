# Spider Swing · status
updated: 2026-07-31T21:47:19Z
phase: Phase 0.25 Bramble obstacle-identity correction — PR #69 complete
health: green
kit: v1.20.2 · check: green · engaged: yes
last-shipped: PR #69 gives Bramble an exclusive hook-vine/leaf-shutter vocabulary
blockers: Phase 1 and further numeric tuning remain product-gated on issue #2 device playtesting
orders: acked= done=
⚑ needs-owner: PR #69 Android obstacle-identity device pass

⚑ OWNER-ACTION
WHAT: Install the PR #69 debug APK and confirm Bramble's hook vines and giant leaf shutters feel like genuinely different obstacles at 5000 m.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30667529691/artifacts/8807542392
HOW: Install over the current stable-key debug build; enable Debug Tools; open DEBUG TEST RUN; set distance to 5000 m and upgrades to MAX; then play through several hook and shutter singles and high↔low pairs.
RISK: ↩️ reversible — install any later stable-key debug APK over this one; do not uninstall, so saved data remains.
WHY-IT-MATTERS: This is the decisive real-device check that the new area changes obstacle silhouette and route decisions rather than only repainting old hazards.
UNBLOCKS: Acceptance of Bramble's obstacle identity and the same region-ownership standard for later 5000 m areas.
VERIFIED-NEEDED: Exact Godot 4.7.1, 124/124 contracts, phone-scale texture inspection, GitHub quality checks, Android export, embedded-asset inspection, provenance, and signer verification all pass; this seat's headless Godot renderer cannot produce framebuffer pixels, so only a real device can judge motion-scale readability and feel.

WITHDRAWN: The PR #62 artifact ask is closed. Menno's device verdict accepted
the presentation direction but rejected the obstacles as old roles under new
skins. A new owner action will name only PR #69's source-identified replacement
artifact after its Android proof is green.
notes: PR #69 replaces Bramble's inherited obstacle pool with explicit hook-vine
and leaf-shutter geometry/art only. Exact Godot, 124 contracts, GitHub quality,
Android export/assets/provenance, and signer proof are green. Physics, speed,
Reel, Burst, upgrades, economy, persistence, and settlement remain unchanged.
