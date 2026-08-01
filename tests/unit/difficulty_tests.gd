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
