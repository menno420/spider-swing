# Spider Swing · status
updated: 2026-07-29T20:44:00Z
phase: Phase 0.22 deep progression foundation — owner device balance/clarity gate next
health: green
kit: v1.20.2 · check: final completed-status flip pending; 86/86 game contracts green · engaged: yes
last-shipped: PR #27; PR #28 candidate verified — seven-track progression, safe save migration, and stable spider presentation
blockers: deeper progression features and Phase 1 remain product-gated on owner device playtesting
orders: acked= done=
⚑ needs-owner: 1 ask — compare migrated progression and spider clarity on device

⚑ OWNER-ACTION
WHAT: Confirm that migrated upgrades still feel fair and that the Classic spider no longer looks blurry or vibrates away from its attached web.
WHERE: https://github.com/menno420/spider-swing/actions/runs/30489461754/artifacts/8739088355 — download artifact `spider-swing-android-debug`, unzip it, and install `spider-swing-debug.apk`.
HOW: uninstall the previous development app first because each CI build uses a fresh ephemeral signing key. Launch `Spider Swing Deep Progression (dev)` and confirm `BUILD 0.10.0-deep-progression-test`. Open Shop on the 1040×480 device and scroll all seven Garden Spider rows. Play a migrated near-max save at steady speed, during Reel, and during Burst; check that motion is crisp, the web stays visually attached, and the small poses do not wobble. If possible, buy level 5/10/15/20 and confirm the breakthrough reads clearly. Compare max Reel against the previous build: its shared cap is now +30%, below the former maxed Garden track.
RISK: ↩️ reversible — this replaces only the development APK. Existing five-level saves migrate proportionally and the old build remains recoverable from git history. Level-zero physics, reach, aim forgiveness, collision, course generation, and score did not change.
WHY-IT-MATTERS: this review separates progression value and rendering clarity from swing or course changes, so the next decision has one understandable cause.
UNBLOCKS: numeric tuning of the seven-track foundation, then one temporary style-mode experiment and fixed-stat Challenge planning in the documented order.
VERIFIED-NEEDED: `game-quality` run 30489461720 passed all 86 contracts on Godot 4.7.1 at source `c8d093109860d4a0716aa2e3ddd7b6d163c82a70`. Android run 30489461754 passed; artifact `spider-swing-android-debug` ID `8739088355` is 61,370,244 bytes with digest `sha256:4e466ec3453c51dc2e2f0d9a2828916fe258bb2be0e76256e4b3895a69982eac`. The downloaded ZIP matched that digest and passed archive verification; its 61,770,490-byte APK passed archive verification with SHA-256 `310ea5419e0bd0df5ee78c7a1626a5a5ef560b272229ef2f79c40a4c186e14b5`, and `build-info.txt` proves the deep-progression build identity and source.
notes: Every spider now has five shared core tracks and two identity tracks over 20 small levels. Breakthroughs at 5/10/15/20 grant one extra tuning step, not a new input. Former level 1 maps to 4 and level 5 maps to 20 exactly once. Custom presentation interpolates fixed snapshots, snaps teleports, enables mipmaps for downscaled moving art, and disables pose changes with Reduced Motion. Temporary modes, spider locks, paid power, extra Burst charges, Challenge mode, and new course difficulty remain deferred.
