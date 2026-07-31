# Spider Swing · status
updated: 2026-07-31T19:00:00Z
phase: Phase 0.25 depth setup verified — owner device traversal/feel gate remains next
health: green
kit: v1.20.2 · check: green except deliberate active-session hold · engaged: yes
last-shipped: PR #54 merged; PR #60 pre-run depth-control candidate verified
blockers: Phase 1 and further numeric tuning remain product-gated on issue #2 device playtesting
orders: acked= done=
⚑ needs-owner: 1 ask — install the stable-key repair and evaluate pre-run depth setup plus traversal feel

⚑ OWNER-ACTION
WHAT: Verify the debug-only pre-run distance and temporary-upgrade workflow on the real Android device, then continue issue #2's far-course traversal/feel test.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30656983045/artifacts/8803635374 — download `spider-swing-android-debug`, unzip it, and install `spider-swing-debug.apk`.
HOW: If `0.19.0-depth-testing` or a later stable-key build is installed, update over it without uninstalling. Otherwise perform the one final uninstall first. Launch build `0.19.1-depth-control-repair`, enable Debug Tools in Settings, return Home, open `DEBUG TEST RUN`, type an off-grid distance such as `12345.7`, switch temporary upgrades with the large `−`/`+` and `OWNED`/`MAX`, then start. Confirm the HUD says `AWARDS NOTHING`, return Home, and confirm ordinary PLAY uses the exact owned levels. Repeat at 5000 m and 10000 m while judging the existing swing checklist.
RISK: ↩️ reversible — this is a development-only APK and session-only overlay; no purchase, owned level, fly balance, record, or checkpoint can be written by the test run. Do not uninstall an existing stable-key build because doing so wipes its app data.
WHY-IT-MATTERS: this is the first workflow that lets the owner configure deep deterministic content and upgraded-versus-owned feel before play, so the open traversal gate can be evaluated without menu timing or save resets distorting the result.
UNBLOCKS: issue #2's device exit gate, an evidence-based movement decision, and only then Phase 1 content work.
VERIFIED-NEEDED: Godot 4.7.1 Standard passed architecture, import, boot, and 118/118 contracts on exact source `34b8d5d1a9a98d8f1a8bef434bb4535d0a9ebc6b`. `game-quality` run 30656982928 passed. Android run 30656983045 passed stable-key, export, APK/version, and signer assertions. Artifact 8803635374 is 61,797,497 bytes with ZIP SHA-256 `cb9cb31d7d12d1992061efcbe5055212a29b07205c9a5bc6533f3aa58f3218b6`; its intact APK is 62,202,652 bytes with SHA-256 `7a9aa69d89af2d3813e3b54c0ab3ad1b8ffb3c684cfd8ab5c863a4e74885ed44` and pinned certificate SHA-256 `83ff0bc27903351779ffd1439f115e8c7e4c228fddd683e2a801c9700b30a741`.
notes: PR #60 keeps the existing in-run DEBUG controls, adds a gated Home setup with exact distance and 64-pixel upgrade `−`/`+`, applies the overlay only on explicit test start, and clears it before every ordinary run. Physics, collision, balance, economy, ownership, persistence, and settlement are unchanged.
