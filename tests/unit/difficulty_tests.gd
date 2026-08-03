extends RefCounted
class_name DifficultyTests
## Contracts for difficulty modes.
##
## The load-bearing guarantee is the one D-0033 makes and the overnight brief
## repeats: a mode changes which content the stream serves and how much
## recovery the player gets, and **never the physics**. That is asserted
## directly — every mode is applied to a fresh config and every field in
## `DifficultyCatalog.PHYSICS_FIELDS` must come out identical to Standard's.
## The rest guard the record rules, which are what stop a Relaxed run reading
## as equivalent to a Harsh one.

const Probe := preload("res://tools/course_audit_probe.gd")
const PROFILE_FIRST_CHUNK := 0
const PROFILE_LAST_CHUNK := 156
const PROFILE_SEEDS := [1000, 1001, 1002]
const STANDARD_SEQUENCE_DIGEST := \
	"c40f126d894dc7739fd1af1325066a0e84a7a78990724cc95b6b41c696d110f4"
const PROFILE_AXIS_KEYS := [
	"id", "legal_continuations", "recovery_interval_delta",
	"repetition_cooldown_chunks", "admission_pressure_scale",
	"admission_pressure_offset", "multi_obstacle_pressure_delta",
	"reaction_spacing_scale", "selection_style",
]


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_no_mode_changes_physics(failures)
	passed += _test_standard_is_the_approved_preset_untouched(failures)
	passed += _test_every_override_names_a_content_field(failures)
	passed += _test_every_mode_resolves_to_a_valid_config(failures)
	passed += _test_record_and_leaderboard_rules(failures)
	passed += _test_unknown_mode_resolves_to_standard(failures)
	passed += _test_every_mode_keeps_its_own_best(failures)
	passed += _test_only_eligible_modes_move_the_authoritative_best(failures)
	passed += _test_schema_six_best_migrates_to_standard_only(failures)
	passed += _test_course_profiles_are_selection_only(failures)
	passed += _test_standard_sequence_is_exact(failures)
	passed += _test_profile_sequences_are_deterministic_and_diverge(failures)
	passed += _test_profile_axes_order_from_standard(failures)
	passed += _test_reaction_spacing_is_consumed_by_geometry(failures)
	passed += _test_profile_pools_and_bramble_pair_rule_hold(failures)
	return {"passed": passed, "failures": failures}


static func _config_for(mode_id: StringName) -> SwingConfig:
	var config := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	DifficultyCatalog.apply_to_config(config, mode_id)
	return config


## The whole promise, in one contract: the swing must feel identical in every
## mode. If a knob ever needs to move per mode, it belongs in CONTENT_FIELDS
## and this test is the thing that forces that conversation.
static func _test_no_mode_changes_physics(
	failures: PackedStringArray,
) -> int:
	var baseline := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	for mode_id: StringName in DifficultyCatalog.mode_ids():
		var config := _config_for(mode_id)
		for field: String in DifficultyCatalog.PHYSICS_FIELDS:
			if config.get(field) != baseline.get(field):
				failures.append(
					"mode %s changed physics field %s (%s -> %s)" % [
						mode_id, field,
						str(baseline.get(field)), str(config.get(field))])
				return 0
	return 1


static func _test_standard_is_the_approved_preset_untouched(
	failures: PackedStringArray,
) -> int:
	var mode := DifficultyCatalog.mode_for_id(DifficultyCatalog.MODE_STANDARD)
	if mode.is_empty():
		failures.append("Standard difficulty is missing")
		return 0
	var overrides: Dictionary = mode["overrides"]
	if not overrides.is_empty():
		failures.append(
			"Standard overrides the approved preset (%d field(s))" %
				overrides.size())
		return 0
	# Belt and braces: content fields too, not just physics.
	var baseline := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	var config := _config_for(DifficultyCatalog.MODE_STANDARD)
	for field: String in DifficultyCatalog.CONTENT_FIELDS:
		if config.get(field) != baseline.get(field):
			failures.append("Standard changed content field %s" % field)
			return 0
	return 1


static func _test_every_override_names_a_content_field(
	failures: PackedStringArray,
) -> int:
	for mode: Dictionary in DifficultyCatalog.all_modes():
		var overrides: Dictionary = mode["overrides"]
		for field: String in overrides:
			if not field in DifficultyCatalog.CONTENT_FIELDS:
				failures.append("mode %s overrides non-content field %s" % [
					mode["id"], field])
				return 0
			if field in DifficultyCatalog.PHYSICS_FIELDS:
				failures.append("field %s is both content and physics" % field)
				return 0
	return 1


static func _test_every_mode_resolves_to_a_valid_config(
	failures: PackedStringArray,
) -> int:
	for mode_id: StringName in DifficultyCatalog.mode_ids():
		var config := _config_for(mode_id)
		var invalid := config.validate()
		if not invalid.is_empty():
			failures.append("mode %s produced an invalid config: %s" % [
				mode_id, invalid[0]])
			return 0
	return 1


## D-0033: separate best per mode, only Standard leaderboard-eligible.
## Relaxed is additionally excluded from records because non-lethal rails
## would unlock every checkpoint on a first attempt.
##
## **Scheduled to change.** The 2026-08-03 ledger entry gives every
## records-eligible mode a board and makes Relaxed's rails lethal. This contract
## keeps enforcing the shipped rule until that lands, so the two cannot drift
## apart silently — and its own invariant below (a mode that cannot set a record
## must not claim a board) is what forced the rails question to be answered
## rather than assumed.
static func _test_record_and_leaderboard_rules(
	failures: PackedStringArray,
) -> int:
	var leaderboard_modes: Array[StringName] = []
	for mode_id: StringName in DifficultyCatalog.mode_ids():
		if DifficultyCatalog.leaderboards_eligible(mode_id):
			leaderboard_modes.append(mode_id)
	if leaderboard_modes.size() != 1 or \
			leaderboard_modes[0] != DifficultyCatalog.MODE_STANDARD:
		failures.append(
			"leaderboard eligibility is %s, must be Standard alone" %
				str(leaderboard_modes))
		return 0
	if DifficultyCatalog.records_eligible(DifficultyCatalog.MODE_RELAXED):
		failures.append("Relaxed sets records despite non-lethal rails")
		return 0
	if not DifficultyCatalog.records_eligible(DifficultyCatalog.MODE_HARSH):
		failures.append("Harsh does not set records")
		return 0
	# A mode that cannot set a record must not claim a leaderboard slot.
	for mode_id: StringName in DifficultyCatalog.mode_ids():
		if DifficultyCatalog.leaderboards_eligible(mode_id) and \
				not DifficultyCatalog.records_eligible(mode_id):
			failures.append(
				"mode %s is leaderboard-eligible without records" % mode_id)
			return 0
	return 1


static func _test_unknown_mode_resolves_to_standard(
	failures: PackedStringArray,
) -> int:
	if DifficultyCatalog.resolve(&"nightmare") != \
			DifficultyCatalog.MODE_STANDARD:
		failures.append("an unknown mode did not resolve to Standard")
		return 0
	if DifficultyCatalog.has_mode(&"nightmare"):
		failures.append("an unknown mode reported as known")
		return 0
	return 1


## "Separate best distance per mode" includes the modes that set no record —
## otherwise Relaxed would have nothing to show for a good run.
static func _test_every_mode_keeps_its_own_best(
	failures: PackedStringArray,
) -> int:
	var progress := PlayerProgress.defaults()
	var service := ProgressionService.new()
	var distances := {
		DifficultyCatalog.MODE_RELAXED: 50000.0,
		DifficultyCatalog.MODE_STANDARD: 30000.0,
		DifficultyCatalog.MODE_HARSH: 20000.0,
	}
	var index := 0
	for mode_id: StringName in distances:
		index += 1
		var settlement := RunSettlement.create(
			"mode-run-%d" % index,
			float(distances[mode_id]),
			0,
			&"obstacle",
			mode_id,
			0.0,
			DifficultyCatalog.records_eligible(mode_id),
			1337,
		)
		service.apply_settlement(progress, settlement)
	for mode_id: StringName in distances:
		var expected := float(distances[mode_id])
		var actual := progress.best_distance_for_mode(mode_id)
		if not is_equal_approx(actual, expected):
			failures.append("mode %s best is %.0f, expected %.0f" % [
				mode_id, actual, expected])
			return 0
	return 1


## The authoritative best drives region checkpoints. A Relaxed run — which
## cannot fall off the course — must never move it.
static func _test_only_eligible_modes_move_the_authoritative_best(
	failures: PackedStringArray,
) -> int:
	var progress := PlayerProgress.defaults()
	var service := ProgressionService.new()
	service.apply_settlement(progress, RunSettlement.create(
		"relaxed-huge",
		400000.0,
		0,
		&"obstacle",
		DifficultyCatalog.MODE_RELAXED,
		0.0,
		DifficultyCatalog.records_eligible(DifficultyCatalog.MODE_RELAXED),
		1337,
	))
	if progress.best_distance_pixels > 0.0:
		failures.append(
			"a Relaxed run moved the authoritative best to %.0f" %
				progress.best_distance_pixels)
		return 0
	if progress.best_distance_for_mode(DifficultyCatalog.MODE_RELAXED) <= 0.0:
		failures.append("the Relaxed run recorded no per-mode best")
		return 0
	service.apply_settlement(progress, RunSettlement.create(
		"harsh-run",
		25000.0,
		0,
		&"obstacle",
		DifficultyCatalog.MODE_HARSH,
		0.0,
		DifficultyCatalog.records_eligible(DifficultyCatalog.MODE_HARSH),
		1337,
	))
	if not is_equal_approx(progress.best_distance_pixels, 25000.0):
		failures.append(
			"a Harsh run did not move the authoritative best (%.0f)" %
				progress.best_distance_pixels)
		return 0
	return 1


## A schema-6 save's single best was necessarily set on Standard, because no
## other mode existed. It must land there and nowhere else.
static func _test_schema_six_best_migrates_to_standard_only(
	failures: PackedStringArray,
) -> int:
	var legacy := {
		"schema_version": 6,
		"best_distance_pixels": 88000.0,
		"total_flies": 40,
	}
	var progress := PlayerProgress.from_dictionary(legacy)
	if not is_equal_approx(
			progress.best_distance_for_mode(DifficultyCatalog.MODE_STANDARD),
			88000.0):
		failures.append("a schema-6 best did not migrate to Standard")
		return 0
	if progress.best_distance_for_mode(DifficultyCatalog.MODE_RELAXED) > 0.0 \
			or progress.best_distance_for_mode(
				DifficultyCatalog.MODE_HARSH) > 0.0:
		failures.append("a schema-6 best leaked into another mode")
		return 0
	if progress.selected_difficulty != DifficultyCatalog.MODE_STANDARD:
		failures.append("a schema-6 save did not default to Standard")
		return 0
	if PlayerProgress.SCHEMA_VERSION < \
			PlayerProgress.DIFFICULTY_MODE_SCHEMA_VERSION:
		failures.append("difficulty modes ship below their schema version")
		return 0
	return 1


## D-0055's shared shape is deliberately not a second config preset. These are
## selection/cadence axes, and Standard must remain the identity on every one.
static func _test_course_profiles_are_selection_only(
	failures: PackedStringArray,
) -> int:
	var profiles := CourseDifficultyProfile.all_profiles()
	if profiles.size() != DifficultyCatalog.mode_ids().size():
		failures.append("course difficulty profiles do not cover every mode")
		return 0
	for profile: Dictionary in profiles:
		for key: String in profile:
			if not key in PROFILE_AXIS_KEYS:
				failures.append("course profile owns undeclared axis %s" % key)
				return 0
			if key in DifficultyCatalog.PHYSICS_FIELDS:
				failures.append("course profile owns physics field %s" % key)
				return 0
	var standard := CourseDifficultyProfile.for_mode(
		DifficultyCatalog.MODE_STANDARD)
	if int(standard["legal_continuations"]) != 3 or \
			int(standard["recovery_interval_delta"]) != 0 or \
			int(standard["repetition_cooldown_chunks"]) != 2 or \
			not is_equal_approx(float(standard["admission_pressure_scale"]), 1.0) or \
			not is_zero_approx(float(standard["admission_pressure_offset"])) or \
			not is_zero_approx(float(standard["multi_obstacle_pressure_delta"])) or \
			not is_equal_approx(float(standard["reaction_spacing_scale"]), 1.0) or \
			StringName(standard["selection_style"]) != \
				CourseDifficultyProfile.SELECTION_STANDARD:
		failures.append("Standard is not the identity course profile")
		return 0
	var harsh_overrides: Dictionary = DifficultyCatalog.mode_for_id(
		DifficultyCatalog.MODE_HARSH)["overrides"]
	for width_field: String in [
		"gate_opening_scale", "corridor_clearance_scale",
		"corridor_tight_gap_scale",
	]:
		if harsh_overrides.has(width_field):
			failures.append("Harsh still spends difficulty on %s" % width_field)
			return 0
	return 1


static func _sequence_for_mode(mode_id: StringName) -> PackedStringArray:
	var result := PackedStringArray()
	for course_seed: int in PROFILE_SEEDS:
		for chunk_index in range(PROFILE_FIRST_CHUNK, PROFILE_LAST_CHUNK + 1):
			var distance := maxf(
				0.0,
				float(chunk_index) * CoursePatternCatalog.CHUNK_WIDTH -
					CourseStream.START_X,
			)
			result.append(str(CoursePatternCatalog.pattern_id_for_chunk(
				chunk_index, distance, course_seed, mode_id)))
	return result


static func _sequence_digest(
	mode_id: StringName,
	seeds: Array,
) -> String:
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	for course_seed: int in seeds:
		for chunk_index in range(PROFILE_FIRST_CHUNK, PROFILE_LAST_CHUNK + 1):
			var distance := maxf(
				0.0,
				float(chunk_index) * CoursePatternCatalog.CHUNK_WIDTH -
					CourseStream.START_X,
			)
			var pattern_id := CoursePatternCatalog.pattern_id_for_chunk(
				chunk_index, distance, course_seed, mode_id)
			hashing.update(("%d:%d:%s\n" % [
				course_seed, chunk_index, pattern_id]).to_utf8_buffer())
	return hashing.finish().hex_encode()


## The geometry digest in CourseAuditTests pins Standard's whole built course;
## this second pin makes the unchanged pattern sequence explicit on its own.
static func _test_standard_sequence_is_exact(
	failures: PackedStringArray,
) -> int:
	var digest := _sequence_digest(
		DifficultyCatalog.MODE_STANDARD, [1000, 1001])
	if digest != STANDARD_SEQUENCE_DIGEST:
		failures.append("Standard pattern sequence changed to %s, not %s" % [
			digest, STANDARD_SEQUENCE_DIGEST])
		return 0
	return 1


static func _test_profile_sequences_are_deterministic_and_diverge(
	failures: PackedStringArray,
) -> int:
	var sequences := {}
	for mode_id: StringName in DifficultyCatalog.mode_ids():
		var first := _sequence_for_mode(mode_id)
		var second := _sequence_for_mode(mode_id)
		if first != second:
			failures.append("%s course sequence is not deterministic" % mode_id)
			return 0
		sequences[mode_id] = first
	if sequences[DifficultyCatalog.MODE_RELAXED] == \
			sequences[DifficultyCatalog.MODE_STANDARD] or \
			sequences[DifficultyCatalog.MODE_HARSH] == \
			sequences[DifficultyCatalog.MODE_STANDARD] or \
			sequences[DifficultyCatalog.MODE_RELAXED] == \
			sequences[DifficultyCatalog.MODE_HARSH]:
		failures.append("difficulty profiles still generate one shared sequence")
		return 0
	return 1


## Structural comparison only. This proves ordering on the declared generator
## axes; it deliberately does not pretend headless output is a feel verdict.
static func _test_profile_axes_order_from_standard(
	failures: PackedStringArray,
) -> int:
	var metrics := {}
	for mode_id: StringName in DifficultyCatalog.mode_ids():
		var recovery := 0
		var challenge := 0
		var label_total := 0
		var longest_run := 0
		for course_seed: int in PROFILE_SEEDS:
			var current_run := 0
			for chunk_index in range(PROFILE_FIRST_CHUNK, PROFILE_LAST_CHUNK + 1):
				var distance := maxf(
					0.0,
					float(chunk_index) * CoursePatternCatalog.CHUNK_WIDTH -
						CourseStream.START_X,
				)
				var pattern := CoursePatternCatalog.pattern_for_chunk(
					chunk_index, distance, course_seed, mode_id)
				var pattern_id := StringName(pattern.get("id", &""))
				if pattern_id.is_empty():
					continue
				if pattern_id == &"open_recovery":
					recovery += 1
					current_run = 0
				else:
					challenge += 1
					label_total += int(pattern.get("difficulty", 0))
					current_run += 1
					longest_run = maxi(longest_run, current_run)
		metrics[mode_id] = {
			"recovery": recovery,
			"challenge": challenge,
			"label_mean": float(label_total) / float(maxi(1, challenge)),
			"longest_run": longest_run,
		}
	var relaxed: Dictionary = metrics[DifficultyCatalog.MODE_RELAXED]
	var standard: Dictionary = metrics[DifficultyCatalog.MODE_STANDARD]
	var harsh: Dictionary = metrics[DifficultyCatalog.MODE_HARSH]
	if not (int(relaxed["recovery"]) > int(standard["recovery"]) and \
			int(standard["recovery"]) > int(harsh["recovery"])):
		failures.append("profile recovery cadence is not Relaxed > Standard > Harsh")
		return 0
	if not (int(relaxed["challenge"]) < int(standard["challenge"]) and \
			int(standard["challenge"]) < int(harsh["challenge"])):
		failures.append("profile challenge density is not Relaxed < Standard < Harsh")
		return 0
	if not (float(relaxed["label_mean"]) < float(standard["label_mean"]) and \
			float(standard["label_mean"]) < float(harsh["label_mean"])):
		failures.append("profile authored-rung means do not rise by mode")
		return 0
	if int(relaxed["longest_run"]) >= int(standard["longest_run"]) or \
			int(harsh["longest_run"]) < int(standard["longest_run"]):
		failures.append("profile challenge runs do not preserve recovery ordering")
		return 0
	if CourseDifficultyProfile.legal_continuations(
			DifficultyCatalog.MODE_RELAXED, 8) != 2 or \
			CourseDifficultyProfile.legal_continuations(
				DifficultyCatalog.MODE_STANDARD, 8) != 3 or \
			CourseDifficultyProfile.legal_continuations(
				DifficultyCatalog.MODE_HARSH, 8) != 4:
		failures.append("legal continuation profiles are not 2 / 3 / 4")
		return 0
	return 1


## Same authored Silk beat, same speed, same polygons: only the profile's
## reaction-spacing scalar moves the second opposite-side commitment.
static func _test_reaction_spacing_is_consumed_by_geometry(
	failures: PackedStringArray,
) -> int:
	var gaps := {}
	for mode_id: StringName in DifficultyCatalog.mode_ids():
		var geometry := CourseGeometry.new()
		ZoneCourseBuilder.append_challenge(
			geometry,
			0.0,
			CourseStream.CEILING_Y,
			CourseStream.FLOOR_Y,
			&"hollow_spindle_gate",
			&"centre",
			10000.0,
			0,
			1000,
			CourseDifficultyProfile.reaction_spacing_scale(mode_id),
		)
		var pairs := Probe.classify_pairs(
			Probe.commitments_in(geometry, 0.0), 900.0)
		gaps[mode_id] = float(pairs["edge_px"])
	if not (float(gaps[DifficultyCatalog.MODE_RELAXED]) > \
			float(gaps[DifficultyCatalog.MODE_STANDARD]) and \
			float(gaps[DifficultyCatalog.MODE_STANDARD]) > \
			float(gaps[DifficultyCatalog.MODE_HARSH])):
		failures.append("reaction spacing is not Relaxed > Standard > Harsh")
		return 0
	return 1


static func _test_profile_pools_and_bramble_pair_rule_hold(
	failures: PackedStringArray,
) -> int:
	var bramble_pairs := [
		&"canopy_hook_high_low", &"canopy_hook_low_high",
		&"canopy_shutter_high_low", &"canopy_shutter_low_high",
	]
	for mode_id: StringName in DifficultyCatalog.mode_ids():
		for course_seed: int in PROFILE_SEEDS:
			var prior_open := true
			for chunk_index in range(PROFILE_FIRST_CHUNK, PROFILE_LAST_CHUNK + 1):
				var distance := maxf(
					0.0,
					float(chunk_index) * CoursePatternCatalog.CHUNK_WIDTH -
						CourseStream.START_X,
				)
				var pressure := CoursePressure.at(distance)
				var pattern_id := CoursePatternCatalog.pattern_id_for_chunk(
					chunk_index, distance, course_seed, mode_id)
				if pressure > 0.0 and pattern_id.is_empty():
					failures.append("%s has an empty admissible pool at chunk %d" % [
						mode_id, chunk_index])
					return 0
				if pattern_id in bramble_pairs and not prior_open:
					failures.append("%s admits a Bramble pair without its open lead-in" % mode_id)
					return 0
				prior_open = pattern_id.is_empty() or pattern_id == &"open_recovery"
	return 1
