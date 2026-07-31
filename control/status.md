# Spider Swing · status
updated: 2026-07-31T20:15:00Z
phase: Phase 0.25 Bramble Canopy device candidate — owner visual/route read remains next
health: green
kit: v1.20.2 · check: green · engaged: yes
last-shipped: PR #63 merged; PR #62 Bramble Canopy candidate exact artifact verified
blockers: Phase 1 and further numeric tuning remain product-gated on issue #2 device playtesting
orders: acked= done=
⚑ needs-owner: 1 ask — install the Bramble candidate and judge its 4900→5000 m transition plus high-speed route read

⚑ OWNER-ACTION
WHAT: Judge whether Bramble Canopy now feels materially different and whether its high↔low cues preserve the useful predictive-Reel/reactive-Burst split at full pace.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30662003775/artifacts/8805521840 — download `spider-swing-android-debug`, unzip it, and install `spider-swing-debug.apk`.
HOW: Update over any `0.19.0`+ stable-key build without uninstalling. Enable Debug Tools, use `DEBUG TEST RUN`, and start at 4900 m with `OWNED`; cross 5000 m and watch the braided green rails/hazards arrive from the right before the lime-lit backdrop changes. Then start exactly at 5000 m and compare `OWNED` versus `MAX`. Confirm the signature pairs require a real high↔low choice, Reel is useful when the route is read early, and Burst is the faster late correction. Silk Hollow at 10000 m still lacks its own finished-art pack, so record that separately rather than treating it as this test's expected result.
RISK: ↩️ reversible — this is a development-only APK and session-only overlay; no purchase, owned level, fly balance, record, or checkpoint can be written by the test run. Do not uninstall an existing stable-key build because doing so wipes its app data.
WHY-IT-MATTERS: the first depth recordings proved the controls but also proved that a name and tint do not create a region. This is the first real material environment transition and establishes the content contract for later 5000 m packs without flattening high-speed play.
UNBLOCKS: issue #2's device exit gate, an evidence-based movement decision, and only then Phase 1 content work.
VERIFIED-NEEDED: Godot 4.7.1 Standard passed architecture, import, boot, and 121/121 contracts on exact source `b4eb76e18b56c30bb503c04d761b78e62936c4da`. `game-quality` runs 30662003736/30662011415 passed. Android run 30662003775 passed stable-key, export, APK/version, and signer assertions. Artifact 8805521840 is 64,564,251 bytes with ZIP SHA-256 `c3d8eb300b8552ee2be722c160f1019fa7a6bce9bf281a8320943313bdd5acca`; its intact APK is 64,968,926 bytes with SHA-256 `e7d783bb3a680f4f057585efd7a7ccf7305974e4c32dd72e6e4f75b54ba60da5` and pinned certificate SHA-256 `83ff0bc27903351779ffd1439f115e8c7e4c228fddd683e2a801c9700b30a741`.
notes: PR #62 changes Bramble presentation and deterministic content only. Physics, speed, collision ownership, Reel, Burst, upgrades, economy, persistence, and settlement are unchanged. Silk Hollow remains the next visual-region slice.
