extends RefCounted
class_name AudioPresentationTests
## Contracts for original generated audio and presentation-only playback wiring.

const MANIFEST_PATH := "res://assets/runtime/audio/audio-sample-manifest.json"
const GENERATOR_PATH := "res://tools/generate_audio_samples.py"
const EXPECTED_SFX_COUNT := 25
const EXPECTED_MUSIC_COUNT := 2
const EXPECTED_ASSET_COUNT := EXPECTED_SFX_COUNT + EXPECTED_MUSIC_COUNT
const MAX_SFX_BYTES := 600 * 1024
const MAX_MUSIC_BYTES := 6 * 1024 * 1024


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_manifest_proves_original_reproducible_sources(failures)
	passed += _test_pcm_assets_are_mobile_sized_and_headroom_safe(failures)
	passed += _test_catalog_and_manifest_have_exact_asset_parity(failures)
	passed += _test_core_events_have_audible_treatments(failures)
	passed += _test_variants_and_cooldowns_bound_audio_fatigue(failures)
	passed += _test_music_stems_are_loop_safe_and_mobile_bounded(failures)
	passed += _test_music_mix_is_independent_and_pressure_driven(failures)
	passed += _test_music_volume_preserves_reference_and_headroom(failures)
	passed += _test_composition_keeps_audio_and_haptics_optional(failures)
	return {"passed": passed, "failures": failures}


static func _manifest(failures: PackedStringArray) -> Dictionary:
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if file == null:
		failures.append("generated audio manifest cannot be read")
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		failures.append("generated audio manifest is not valid JSON")
		return {}
	return parsed as Dictionary


static func _test_manifest_proves_original_reproducible_sources(
	failures: PackedStringArray,
) -> int:
	var manifest := _manifest(failures)
	if manifest.is_empty():
		return 0
	var assets: Array = manifest.get("assets", [])
	var policy := str(manifest.get("source_policy", ""))
	if int(manifest.get("schema_version", 0)) != 2 or \
			assets.size() != EXPECTED_ASSET_COUNT or \
			not policy.contains("no recorded, sampled, or third-party") or \
			str(manifest.get("generator", "")) != \
				"tools/generate_audio_samples.py" or \
			str(manifest.get("generator_sha256", "")) != \
				FileAccess.get_sha256(GENERATOR_PATH):
		failures.append(
			"audio manifest lost its source policy, generator hash, or asset count")
		return 0
	return 1


static func _test_pcm_assets_are_mobile_sized_and_headroom_safe(
	failures: PackedStringArray,
) -> int:
	var manifest := _manifest(failures)
	if manifest.is_empty():
		return 0
	var sfx_bytes := 0
	for raw_asset: Variant in manifest.get("assets", []):
		var asset: Dictionary = raw_asset
		var path := "res://assets/runtime/audio/%s" % str(asset.get("file", ""))
		var category := str(asset.get("category", ""))
		if category not in ["sfx", "music"]:
			failures.append("generated audio asset has no owned category: %s" % path)
			return 0
		if not FileAccess.file_exists(path):
			failures.append("generated audio asset is missing: %s" % path)
			return 0
		var bytes := FileAccess.get_file_as_bytes(path)
		if category == "sfx":
			sfx_bytes += bytes.size()
		if FileAccess.get_sha256(path) != str(asset.get("sha256", "")):
			failures.append("generated audio hash drifted: %s" % path)
			return 0
		if int(asset.get("sample_rate_hz", 0)) != 44100 or \
				int(asset.get("channels", 0)) != 1 or \
				int(asset.get("bits_per_sample", 0)) != 16 or \
				float(asset.get("duration_seconds", 0.0)) <= 0.05 or \
				float(asset.get("peak_dbfs", 0.0)) > -2.9:
			failures.append("generated audio format or level is unsafe: %s" % path)
			return 0
		if category == "sfx" and (
				float(asset.get("duration_seconds", 0.0)) > 0.55 or \
				float(asset.get("rms_dbfs", -100.0)) < -30.0):
			failures.append("generated SFX duration or level is unsafe: %s" % path)
			return 0
		if bool(asset.get("loop", false)) and \
				float(asset.get("loop_seam_ratio", 999.0)) > 1.5:
			failures.append("generated Reel loop has an audible boundary risk")
			return 0
		if not ResourceLoader.exists(path) or not load(path) is AudioStreamWAV:
			failures.append("Godot cannot load generated PCM WAV: %s" % path)
			return 0
	if sfx_bytes > MAX_SFX_BYTES:
		failures.append("generated SFX exceed the 600 KiB Android budget")
		return 0
	return 1


static func _test_catalog_and_manifest_have_exact_asset_parity(
	failures: PackedStringArray,
) -> int:
	var manifest := _manifest(failures)
	if manifest.is_empty():
		return 0
	var manifested := PackedStringArray()
	for raw_asset: Variant in manifest.get("assets", []):
		manifested.append(str((raw_asset as Dictionary).get("file", "")))
	manifested.sort()
	var catalogued := PackedStringArray()
	for path: String in AudioAssetCatalog.all_paths():
		catalogued.append(path.get_file())
	catalogued.sort()
	if manifested != catalogued:
		failures.append("audio catalog and generated manifest differ")
		return 0
	return 1


static func _test_core_events_have_audible_treatments(
	failures: PackedStringArray,
) -> int:
	var required := [
		SimulationEvent.Kind.ATTACHED,
		SimulationEvent.Kind.RELEASED,
		SimulationEvent.Kind.REEL_STARTED,
		SimulationEvent.Kind.REEL_EMPTY,
		SimulationEvent.Kind.BURST_STARTED,
		SimulationEvent.Kind.DIVE_STARTED,
		SimulationEvent.Kind.FLY_COLLECTED,
		SimulationEvent.Kind.INVALID_TARGET,
		SimulationEvent.Kind.OUT_OF_RANGE,
		SimulationEvent.Kind.REEL_UNAVAILABLE,
		SimulationEvent.Kind.BURST_UNAVAILABLE,
		SimulationEvent.Kind.DIVE_UNAVAILABLE,
		SimulationEvent.Kind.RESCUE_USED,
		SimulationEvent.Kind.DEATH_REQUESTED,
		SimulationEvent.Kind.BOOST_COLLECTED,
		SimulationEvent.Kind.SURFACE_BOUNCED,
		SimulationEvent.Kind.ANCHOR_FAILED,
	]
	for kind: int in required:
		var event := SimulationEvent.make(kind)
		if AudioAssetCatalog.paths_for_event(event).is_empty():
			failures.append("core event has no SFX mapping: %d" % kind)
			return 0
	var cue_paths := PackedStringArray()
	for cue: StringName in AudioAssetCatalog.HAZARD_CUES:
		var event := SimulationEvent.make(
			SimulationEvent.Kind.HAZARD_CUE,
			Vector2.ZERO,
			"",
			{"cue": cue},
		)
		var paths := AudioAssetCatalog.paths_for_event(event)
		if paths.size() != 1 or paths[0] in cue_paths:
			failures.append("later-zone warning cues are missing or share one file")
			return 0
		cue_paths.append(paths[0])
	return 1


static func _test_variants_and_cooldowns_bound_audio_fatigue(
	failures: PackedStringArray,
) -> int:
	if AudioAssetCatalog.WEB_ATTACH.size() < 3 or \
			AudioAssetCatalog.WEB_RELEASE.size() < 2 or \
			AudioAssetCatalog.BURST.size() < 2 or \
			AudioAssetCatalog.DIVE.size() < 2 or \
			AudioAssetCatalog.FLY_CATCH.size() < 3:
		failures.append("high-frequency actions lost their required SFX variants")
		return 0
	var director := AudioDirector.new()
	var attach := SimulationEvent.make(SimulationEvent.Kind.ATTACHED)
	var sequence := PackedStringArray()
	for _index in range(4):
		sequence.append(director.choose_path(attach))
	if sequence[0] == sequence[1] or sequence[1] == sequence[2] or \
			sequence[0] != sequence[3] or \
			AudioAssetCatalog.cooldown_seconds(attach) <= 0.0 or \
			AudioAssetCatalog.cooldown_seconds(
				SimulationEvent.make(SimulationEvent.Kind.FLY_COLLECTED)) <= 0.0:
		failures.append("audio variants do not round-robin or lack cooldowns")
		director.free()
		return 0
	director.free()
	return 1


static func _test_music_stems_are_loop_safe_and_mobile_bounded(
	failures: PackedStringArray,
) -> int:
	var manifest := _manifest(failures)
	if manifest.is_empty():
		return 0
	var music_assets: Array[Dictionary] = []
	var music_bytes := 0
	for raw_asset: Variant in manifest.get("assets", []):
		var asset: Dictionary = raw_asset
		if str(asset.get("category", "")) != "music":
			continue
		music_assets.append(asset)
		var path := "res://assets/runtime/audio/%s" % str(asset.get("file", ""))
		music_bytes += FileAccess.get_file_as_bytes(path).size()
		if not bool(asset.get("loop", false)) or \
				not is_equal_approx(float(asset.get("duration_seconds", 0.0)), 32.0) or \
				float(asset.get("loop_seam_ratio", 999.0)) > 1.5 or \
				float(asset.get("peak_dbfs", 0.0)) > -9.9 or \
				float(asset.get("rms_dbfs", -100.0)) < -32.0:
			failures.append("music stem lost its seamless mobile-safe mix contract")
			return 0
	var catalogued := AudioAssetCatalog.music_paths()
	if music_assets.size() != EXPECTED_MUSIC_COUNT or catalogued.size() != 2 or \
			catalogued[0] == catalogued[1] or music_bytes > MAX_MUSIC_BYTES:
		failures.append("haunted soundtrack does not own two bounded unique stems")
		return 0
	return 1


static func _test_music_mix_is_independent_and_pressure_driven(
	failures: PackedStringArray,
) -> int:
	var director := AudioDirector.new()
	director.configure_effects(false)
	director.configure_music_volume(PlayerSettings.DEFAULT_MUSIC_VOLUME)
	var quiet := SimulationSnapshot.new()
	quiet.velocity = Vector2(200.0, 0.0)
	var normal := SimulationSnapshot.new()
	normal.velocity = Vector2(650.0, 0.0)
	normal.bird_enabled = true
	normal.bird_gap = 760.0
	normal.bird_closing = true
	var danger := SimulationSnapshot.new()
	danger.velocity = Vector2(850.0, 0.0)
	danger.bird_enabled = true
	danger.bird_gap = 280.0
	danger.bird_closing = true
	var ended := SimulationSnapshot.new()
	ended.run_state = &"dead"
	ended.bird_enabled = true
	ended.bird_gap = 260.0
	var quiet_mix := AudioDirector.music_tension_for_snapshot(quiet)
	var normal_mix := AudioDirector.music_tension_for_snapshot(normal)
	var danger_mix := AudioDirector.music_tension_for_snapshot(danger)
	var ended_mix := AudioDirector.music_tension_for_snapshot(ended)
	if director.effects_enabled() or not is_equal_approx(
			director.music_volume(), PlayerSettings.DEFAULT_MUSIC_VOLUME) or \
			quiet_mix != 0.0 or normal_mix < 0.1 or normal_mix > 0.5 or \
			danger_mix < 0.85 or ended_mix != 0.0:
		failures.append(
			("music is not independent or its pressure mix is unbounded "
			+ "(quiet=%.3f normal=%.3f danger=%.3f ended=%.3f)") % [
				quiet_mix, normal_mix, danger_mix, ended_mix,
			])
		director.free()
		return 0
	director.configure_effects(true)
	director.configure_music_volume(0.0)
	if not is_zero_approx(director.music_volume()) or \
			not director.effects_enabled():
		failures.append("Music volume does not reach silence independently from effects")
		director.free()
		return 0
	director.free()
	return 1


static func _test_music_volume_preserves_reference_and_headroom(
	failures: PackedStringArray,
) -> int:
	var reference_gain := AudioDirector.music_gain_db(
		PlayerSettings.DEFAULT_MUSIC_VOLUME)
	var maximum_gain := AudioDirector.music_gain_db(
		PlayerSettings.MAX_MUSIC_VOLUME)
	var silent_gain := AudioDirector.music_gain_db(
		PlayerSettings.MIN_MUSIC_VOLUME)
	var reference_levels := AudioDirector.music_levels_for(
		PlayerSettings.DEFAULT_MUSIC_VOLUME, 1.0)
	var maximum_levels := AudioDirector.music_levels_for(
		PlayerSettings.MAX_MUSIC_VOLUME, 1.0)
	# The original maximum combined stem mix was measured at -10.3 dBFS. A
	# doubled-amplitude ceiling therefore stays below -4 dBFS before SFX.
	if not is_zero_approx(reference_gain) or \
			not is_equal_approx(maximum_gain, linear_to_db(2.0)) or \
			silent_gain > AudioDirector.MUSIC_TENSION_SILENT_DB or \
			not is_equal_approx(
				maximum_levels.x - reference_levels.x, maximum_gain) or \
			not is_equal_approx(
				maximum_levels.y - reference_levels.y, maximum_gain) or \
			-10.3 + maximum_gain > -4.0:
		failures.append("Music slider lost its original midpoint or safe +6 dB ceiling")
		return 0
	return 1


static func _test_composition_keeps_audio_and_haptics_optional(
	failures: PackedStringArray,
) -> int:
	var settings := PlayerSettings.defaults()
	settings.music_volume = 0.0
	settings.effects_enabled = false
	settings.haptics_enabled = false
	var decoded := PlayerSettings.from_dictionary(settings.to_dictionary())
	var main_file := FileAccess.open("res://game/bootstrap/main.gd", FileAccess.READ)
	if main_file == null:
		failures.append("composition root cannot be read for audio wiring")
		return 0
	var source := main_file.get_as_text()
	if not is_zero_approx(decoded.music_volume) or decoded.effects_enabled or \
			decoded.haptics_enabled or \
			not source.contains(
				"snapshot_published.connect(_audio_director.present_snapshot)") or \
			not source.contains(
				"event_published.connect(_audio_director.present_event)") or \
			not source.contains(
				"_input_router.configure_haptics(settings.haptics_enabled)") or \
			not source.contains(
				"_audio_director.configure_music_volume(settings.music_volume)") or \
			source.count("add_child(_audio_director)") != 1 or \
			source.find("add_child(_audio_director)") > \
				source.find("var failures := _mount_front_end()"):
		failures.append("music, effects, or haptics bypass optional presentation wiring")
		return 0
	return 1
