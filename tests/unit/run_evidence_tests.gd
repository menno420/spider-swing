extends RefCounted
class_name RunEvidenceTests
## Contracts for authoritative local run evidence, retention, and ownership.

const MAIN_SCRIPT = preload("res://game/bootstrap/main.gd")


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_fixed_tick_metric_semantics(failures)
	passed += _test_record_derives_travelled_outcome_and_context(failures)
	passed += _test_session_finalizes_once_and_resets_attempt_metrics(failures)
	passed += _test_campaign_tutorial_and_replay_classification(failures)
	passed += _test_schema_round_trip_and_tolerant_decode(failures)
	passed += _test_bounded_history_and_lifetime_aggregates(failures)
	passed += _test_repository_defaults_round_trip_and_backup(failures)
	passed += _test_evidence_failure_cannot_change_progression(failures)
	passed += _test_history_route_export_and_scroll_ownership(failures)
	passed += _test_persistence_and_metric_ownership_are_single_seams(failures)
	return {"passed": passed, "failures": failures}


static func _test_fixed_tick_metric_semantics(
	failures: PackedStringArray,
) -> int:
	var metrics := RunMetricsAccumulator.new()
	metrics.observe_tick(-20.0, 100.0, false)
	metrics.observe_tick(100.0, 80.0, true)
	metrics.observe_tick(300.0, 300.0, true)
	for kind: int in [
		SimulationEvent.Kind.ATTACHED,
		SimulationEvent.Kind.REEL_STARTED,
		SimulationEvent.Kind.REEL_EMPTY,
		SimulationEvent.Kind.BURST_STARTED,
		SimulationEvent.Kind.DIVE_STARTED,
		SimulationEvent.Kind.RESCUE_USED,
		SimulationEvent.Kind.REEL_UNAVAILABLE,
		SimulationEvent.Kind.BURST_UNAVAILABLE,
		SimulationEvent.Kind.DIVE_UNAVAILABLE,
	]:
		metrics.observe_event(SimulationEvent.make(kind))
	var result := metrics.result()
	if int(result["sampled_ticks"]) != 3 or \
			not is_equal_approx(float(result["active_duration_seconds"]), 3.0 / 60.0) or \
			not is_equal_approx(float(result["mean_forward_speed_pixels_per_second"]), 400.0 / 3.0) or \
			not is_equal_approx(float(result["maximum_forward_speed_pixels_per_second"]), 300.0) or \
			not is_equal_approx(float(result["above_reference_speed_share"]), 1.0 / 3.0) or \
			not is_equal_approx(float(result["reel_held_seconds"]), 2.0 / 60.0):
		failures.append("fixed-tick duration, speed, reference-share, or Reel time drifted")
		return 0
	if int(result["successful_web_attachments"]) != 1 or \
			int(result["reel_activations"]) != 1 or \
			int(result["reel_empty_events"]) != 1 or \
			int(result["burst_activations"]) != 1 or \
			int(result["dive_activations"]) != 1 or \
			not bool(result["rescue_consumed"]):
		failures.append("accepted action facts or rescue use were not counted exactly once")
		return 0
	return 1


static func _test_record_derives_travelled_outcome_and_context(
	failures: PackedStringArray,
) -> int:
	var settlement := RunSettlement.create(
		"record-derived",
		125000.0,
		5,
		&"hazard_rail",
		SwingLabSession.RUN_PRACTICE,
		100000.0,
		false,
		7781,
	)
	var upgrade_id := str(SpiderCatalog.upgrades_for(SpiderCatalog.CLASSIC)[0]["id"])
	var record := RunRecord.create(settlement, {
		"active_duration_seconds": 12.5,
		"mean_forward_speed_pixels_per_second": 420.0,
		"maximum_forward_speed_pixels_per_second": 780.0,
		"above_reference_speed_share": 0.4,
		"successful_web_attachments": 4,
		"reel_activations": 2,
		"reel_held_seconds": 3.0,
		"reel_empty_events": 1,
		"burst_activations": 3,
		"dive_activations": 2,
		"rescue_consumed": true,
	}, {
		"build_version": "contract-build",
		"android_version_code": 65,
		"runtime_platform": "Android",
		"swing_config_schema_version": SwingConfig.SCHEMA_VERSION,
		"trace_format": TraceCatalog.INPUT_TRACE_FORMAT,
		"difficulty_id": str(DifficultyCatalog.MODE_HARSH),
		"spider_profile_id": str(SpiderCatalog.CLASSIC),
		"resolved_upgrade_levels": {upgrade_id: 9, "not_an_upgrade": 40},
		"preset_id": str(SwingConfig.PRESET_BALANCED),
		"attempt_ordinal": 7,
		"input_source": "human",
		"configuration_kind": "debug_test",
		"configuration_details": {"debug_start_distance_pixels": 100000.0},
	})
	if record.record_id != settlement.settlement_id or \
			record.settlement_id != settlement.settlement_id or \
			record.travelled_distance_pixels != 25000.0 or \
			not is_equal_approx(record.flies_per_kilometre, 2.0) or \
			record.final_region_id != CourseRegionCatalog.SILK_HOLLOW or \
			record.death_cause != &"hazard_rail" or not record.rescue_consumed:
		failures.append("record did not derive travelled distance, rate, region, or raw outcome")
		return 0
	if record.configuration_kind != &"debug_test" or \
			record.difficulty_id != DifficultyCatalog.MODE_HARSH or \
			record.course_seed != 7781 or record.attempt_ordinal != 7 or \
			int(record.resolved_upgrade_levels.get(upgrade_id, -1)) != 9 or \
			record.resolved_upgrade_levels.has("not_an_upgrade"):
		failures.append("record lost authoritative build, seed, configuration, or upgrade context")
		return 0
	return 1


static func _test_session_finalizes_once_and_resets_attempt_metrics(
	failures: PackedStringArray,
) -> int:
	var session := SwingLabSession.new()
	var service := ProgressionService.new()
	service.set_debug_upgrade_overlay_level(7)
	session.configure_progress(PlayerProgress.defaults(), service)
	session.configure_attempt_counter(RunAttemptCounter.new())
	session.configure_run(
		SwingLabSession.RUN_PRACTICE, 100000.0, 8891, true)
	session._reset_run(false, false)
	var settlements: Array[RunSettlement] = []
	var records: Array[RunRecord] = []
	session.run_finalized.connect(func(
		settlement: RunSettlement, record: RunRecord,
	) -> void:
		settlements.append(settlement)
		records.append(record)
	)
	session._metrics.observe_tick(600.0, 400.0, true)
	session._metrics.observe_event(SimulationEvent.make(
		SimulationEvent.Kind.BURST_STARTED))
	session._world.distance_pixels = 125000.0
	session._world.run_flies = 4
	session._emit_settlement(&"obstacle")
	session._emit_settlement(&"bird")
	if records.size() != 1 or settlements.size() != 1 or \
			records[0].settlement_id != settlements[0].settlement_id or \
			records[0].configuration_kind != &"debug_test" or \
			records[0].attempt_ordinal != 1 or \
			records[0].burst_activations != 1 or \
			records[0].build_version != str(ProjectSettings.get_setting(
				"application/config/version")) or \
			records[0].android_version_code != int(ProjectSettings.get_setting(
				"application/config/android_version_code")):
		failures.append("one terminal seam did not produce exactly one classified record")
		session.free()
		return 0
	for item: Dictionary in SpiderCatalog.upgrades_for(SpiderCatalog.CLASSIC):
		if int(records[0].resolved_upgrade_levels.get(str(item["id"]), -1)) != 7:
			failures.append("debug upgrade overlay was not captured as the resolved run loadout")
			session.free()
			return 0
	session.request_restart()
	session._world.distance_pixels = 100100.0
	session._emit_settlement(&"bird")
	if records.size() != 2 or records[1].attempt_ordinal != 2 or \
			records[1].record_id == records[0].record_id or \
			records[1].burst_activations != 0 or \
			records[1].active_duration_seconds != 0.0:
		failures.append("restart leaked counters, identity, or attempt ordinal into the next run")
		session.free()
		return 0
	session.free()
	return 1


static func _test_campaign_tutorial_and_replay_classification(
	failures: PackedStringArray,
) -> int:
	var campaign := SwingLabSession.new()
	var campaign_records: Array[RunRecord] = []
	campaign.run_finalized.connect(func(
		_settlement: RunSettlement, record: RunRecord,
	) -> void: campaign_records.append(record))
	campaign.configure_run(
		SwingLabSession.RUN_CAMPAIGN, 0.0, -1, false,
		CampaignCatalog.TEACH_REEL)
	campaign._reset_run(false, false)
	campaign._world.distance_pixels = CampaignCatalog.goal_distance_pixels(
		CampaignCatalog.TEACH_REEL)
	campaign._verbs_performed = [CampaignCatalog.VERB_REEL]
	campaign._check_campaign_completion()
	campaign._check_campaign_completion()
	if campaign_records.size() != 1 or \
			campaign_records[0].terminal_outcome != &"campaign_complete" or \
			campaign_records[0].configuration_kind != &"campaign" or \
			campaign_records[0].rewards_eligible or \
			campaign_records[0].records_eligible:
		failures.append("Campaign completion did not finalize once as noncompetitive evidence")
		campaign.free()
		return 0
	var first_record_id := campaign_records[0].record_id
	campaign.request_restart()
	campaign._world.distance_pixels = CampaignCatalog.goal_distance_pixels(
		CampaignCatalog.TEACH_REEL)
	campaign._verbs_performed = [CampaignCatalog.VERB_REEL]
	campaign._check_campaign_completion()
	if campaign_records.size() != 2 or \
			campaign_records[1].record_id == first_record_id or \
			campaign_records[1].settlement_id != \
				campaign_records[0].settlement_id:
		failures.append("repeat Campaign clear was suppressed by its reward settlement ID")
		campaign.free()
		return 0
	var campaign_ledger := RunRecordLedger.defaults()
	if not campaign_ledger.append_record(campaign_records[0]) or \
			not campaign_ledger.append_record(campaign_records[1]) or \
			campaign_ledger.total_completed_recorded_runs != 2:
		failures.append("repeat Campaign evidence could not coexist in the bounded ledger")
		campaign.free()
		return 0
	campaign.free()

	var tutorial := SwingLabSession.new()
	var tutorial_count := 0
	tutorial.run_finalized.connect(func(
		_settlement: RunSettlement, _record: RunRecord,
	) -> void: tutorial_count += 1)
	tutorial.configure_run(
		SwingLabSession.RUN_TUTORIAL_PRACTICE, 0.0, -1, false, &"", &"attach")
	tutorial._reset_run(false, false)
	tutorial._emit_settlement(&"obstacle")
	if tutorial_count != 0:
		failures.append("settlement-free tutorial practice entered the main evidence ledger")
		tutorial.free()
		return 0
	tutorial.free()

	var ordinary := SwingLabSession.new()
	var ordinary_records: Array[RunRecord] = []
	ordinary.run_finalized.connect(func(
		_settlement: RunSettlement, record: RunRecord,
	) -> void: ordinary_records.append(record))
	ordinary.configure_run(SwingLabSession.RUN_STANDARD)
	ordinary._reset_run(false, false)
	ordinary._emit_settlement(&"bird")
	if ordinary_records.size() != 1 or \
			ordinary_records[0].configuration_kind != &"standard" or \
			ordinary_records[0].input_source != &"human":
		failures.append("ordinary human Play was not classified as standard")
		ordinary.free()
		return 0
	ordinary.free()

	var practice := SwingLabSession.new()
	var practice_records: Array[RunRecord] = []
	practice.run_finalized.connect(func(
		_settlement: RunSettlement, record: RunRecord,
	) -> void: practice_records.append(record))
	practice.configure_run(SwingLabSession.RUN_PRACTICE, 50000.0)
	practice._reset_run(false, false)
	practice._emit_settlement(&"obstacle")
	if practice_records.size() != 1 or \
			practice_records[0].configuration_kind != &"region_practice" or \
			practice_records[0].start_distance_pixels != 50000.0:
		failures.append("Region Practice lost its explicit nonstandard identity")
		practice.free()
		return 0
	practice.free()

	var course_lab := SwingLabSession.new()
	var lab_records: Array[RunRecord] = []
	course_lab.run_finalized.connect(func(
		_settlement: RunSettlement, record: RunRecord,
	) -> void: lab_records.append(record))
	course_lab.configure_creator_pattern([&"leaf", &"gate"])
	course_lab.configure_run(SwingLabSession.RUN_STANDARD)
	course_lab._reset_run(false, false)
	course_lab._emit_settlement(&"obstacle")
	if lab_records.size() != 1 or \
			lab_records[0].configuration_kind != &"course_lab" or \
			lab_records[0].configuration_details.get("creator_pattern", []) != \
				["leaf", "gate"]:
		failures.append("Course Lab record lost its bounded configuration identity")
		course_lab.free()
		return 0
	course_lab.free()

	var replay := SwingLabSession.new()
	var replay_records: Array[RunRecord] = []
	replay.run_finalized.connect(func(
		_settlement: RunSettlement, record: RunRecord,
	) -> void: replay_records.append(record))
	var command := InputCommand.release(1, 0).to_record()
	command["playback_tick"] = 0
	var loaded := replay.load_input_trace({
		"format": TraceCatalog.INPUT_TRACE_FORMAT,
		"setup": {
			"difficulty": str(DifficultyCatalog.MODE_STANDARD),
			"preset": str(SwingConfig.PRESET_BALANCED),
			"course_seed": 9012,
			"start_m": 5000,
			"upgrades": 3,
		},
		"commands": [command],
	})
	replay._emit_settlement(&"trace_end")
	if not bool(loaded.get("ok", false)) or replay_records.size() != 1 or \
			replay_records[0].input_source != &"trace_replay" or \
			replay_records[0].configuration_kind != &"trace_replay" or \
			replay_records[0].records_eligible or \
			replay_records[0].start_distance_pixels != 50000.0:
		failures.append("trace replay could be mistaken for a human production run")
		replay.free()
		return 0
	replay.free()
	return 1


static func _test_schema_round_trip_and_tolerant_decode(
	failures: PackedStringArray,
) -> int:
	var original := _sample_record("schema-record", 25000.0, 0.0, true)
	original.configuration_details = {"known": true}
	var encoded := original.to_dictionary()
	encoded["future_optional_field"] = {"ignored": true}
	var decoded := RunRecord.from_dictionary(encoded)
	if decoded == null or decoded.to_dictionary() != original.to_dictionary():
		failures.append("schema-1 record did not round-trip while ignoring unknown fields")
		return 0
	var future := encoded.duplicate(true)
	future["schema_version"] = RunRecord.SCHEMA_VERSION + 1
	if RunRecord.from_dictionary(future) != null:
		failures.append("future run-record schema was accepted as current data")
		return 0
	var ledger := RunRecordLedger.defaults()
	ledger.append_record(original)
	var ledger_data := ledger.to_dictionary()
	ledger_data["future_optional_field"] = "ignored"
	var ledger_round_trip := RunRecordLedger.from_dictionary(ledger_data)
	var future_ledger := ledger_data.duplicate(true)
	future_ledger["schema_version"] = RunRecordLedger.SCHEMA_VERSION + 1
	if ledger_round_trip == null or ledger_round_trip.records.size() != 1 or \
			RunRecordLedger.from_dictionary(future_ledger) != null:
		failures.append("ledger decoding is not tolerant within schema or safe for future schema")
		return 0
	return 1


static func _test_bounded_history_and_lifetime_aggregates(
	failures: PackedStringArray,
) -> int:
	var ledger := RunRecordLedger.defaults()
	for index in range(RunRecordLedger.HISTORY_LIMIT + 1):
		var record := _sample_record(
			"ledger-%d" % index, 1000.0 + index, 0.0, true)
		record.active_duration_seconds = 1.0
		record.travelled_distance_pixels = 100.0
		if not ledger.append_record(record):
			failures.append("ledger rejected unique record %d" % index)
			return 0
	if ledger.records.size() != RunRecordLedger.HISTORY_LIMIT or \
			ledger.records[0].record_id != "ledger-1" or \
			ledger.total_completed_recorded_runs != RunRecordLedger.HISTORY_LIMIT + 1 or \
			not is_equal_approx(ledger.total_active_duration_seconds, 101.0) or \
			not is_equal_approx(ledger.total_distance_travelled_pixels, 10100.0) or \
			ledger.latest_record().lifetime_completed_run_ordinal != 101:
		failures.append("rolling eviction changed fixed-size lifetime aggregates or ordinals")
		return 0
	if ledger.append_record(_sample_record("ledger-100", 900000.0, 0.0, true)):
		failures.append("duplicate retained record id was appended twice")
		return 0
	var comparable_best := ledger.best_distance_for_difficulty(
		DifficultyCatalog.MODE_STANDARD)
	var debug := _sample_record("debug-best", 999999.0, 50000.0, false)
	debug.configuration_kind = &"debug_test"
	ledger.append_record(debug)
	if ledger.best_distance_for_difficulty(DifficultyCatalog.MODE_STANDARD) != \
			comparable_best or ledger.total_completed_recorded_runs != 102:
		failures.append("debug evidence polluted comparable best or lifetime participation")
		return 0
	return 1


static func _test_repository_defaults_round_trip_and_backup(
	failures: PackedStringArray,
) -> int:
	var prefix := "user://run_evidence_repository_contract"
	var paths := {
		"settings": "%s_settings.json" % prefix,
		"progress": "%s_progress.json" % prefix,
		"debug": "%s_debug.json" % prefix,
		"ledger": "%s_ledger.json" % prefix,
	}
	_cleanup_repository_paths(paths)
	var repository := SaveRepository.new(
		paths["settings"], paths["progress"], paths["debug"], paths["ledger"])
	if repository.load_run_record_ledger().total_completed_recorded_runs != 0:
		failures.append("missing ledger did not decode to an empty default")
		return 0
	var ledger := RunRecordLedger.defaults()
	ledger.append_record(_sample_record("repository-record", 42000.0))
	if not repository.save_run_record_ledger(ledger):
		failures.append("SaveRepository could not atomically write run evidence")
		_cleanup_repository_paths(paths)
		return 0
	var restored := repository.load_run_record_ledger()
	if JSON.stringify(restored.to_dictionary()) != \
			JSON.stringify(ledger.to_dictionary()):
		failures.append("SaveRepository did not round-trip the ledger schema")
		_cleanup_repository_paths(paths)
		return 0
	var valid_text := JSON.stringify(ledger.to_dictionary(), "\t")
	_write_test_file("%s.bak" % paths["ledger"], valid_text)
	_write_test_file(paths["ledger"], "{ corrupt primary")
	var recovered := repository.load_run_record_ledger()
	_cleanup_repository_paths(paths)
	if recovered.records.size() != 1 or \
			recovered.latest_record().record_id != "repository-record":
		failures.append("corrupt primary did not recover from its valid ledger backup")
		return 0
	return 1


static func _test_evidence_failure_cannot_change_progression(
	failures: PackedStringArray,
) -> int:
	var suffix := str(Time.get_ticks_usec())
	var paths := {
		"settings": "user://evidence_failure_%s_settings.json" % suffix,
		"progress": "user://evidence_failure_%s_progress.json" % suffix,
		"debug": "user://evidence_failure_%s_debug.json" % suffix,
		"ledger": "user://missing_evidence_directory_%s/ledger.json" % suffix,
	}
	_cleanup_repository_paths(paths)
	var repository := SaveRepository.new(
		paths["settings"], paths["progress"], paths["debug"], paths["ledger"])
	var settlement := RunSettlement.create(
		"evidence-failure-settlement", 12000.0, 17, &"bird")
	var record := RunRecord.create(settlement, {}, _standard_context())
	var root := MAIN_SCRIPT.new()
	root._save_repository = repository
	root._progression_service = ProgressionService.new()
	root._progress = PlayerProgress.defaults()
	root._run_record_ledger = RunRecordLedger.defaults()
	root._front_end_state = FrontEndState.new()
	root._front_end_state.configure(
		PlayerSettings.defaults(), root._progress, root._progression_service)
	root._apply_run_finalization(settlement, record)
	root._apply_run_finalization(settlement, record)
	var restored := repository.load_progress()
	var safe := root._progress.total_flies == 17 and \
		root._progress.spendable_flies == 17 and \
		root._progress.applied_settlement_ids.count(settlement.settlement_id) == 1 and \
		restored.total_flies == 17 and \
		root._run_record_ledger.total_completed_recorded_runs == 1 and \
		not repository.save_run_record_ledger(root._run_record_ledger)
	root.free()
	_cleanup_repository_paths(paths)
	if not safe:
		failures.append("optional evidence failure changed or duplicated progression")
		return 0
	return 1


static func _test_history_route_export_and_scroll_ownership(
	failures: PackedStringArray,
) -> int:
	var ledger := RunRecordLedger.defaults()
	var debug := _sample_record("visible-debug", 125000.0, 100000.0, false)
	debug.configuration_kind = &"debug_test"
	debug.difficulty_id = DifficultyCatalog.MODE_HARSH
	ledger.append_record(debug)
	var state := FrontEndState.new()
	state.configure(
		PlayerSettings.defaults(), PlayerProgress.defaults(), null, null, ledger)
	var view := FrontEndView.new()
	view.bind_state(state)
	view.front_end_button(&"PlayModesHub").pressed.emit()
	view.front_end_button(&"RunHistory").pressed.emit()
	var screen := view.find_child("RunHistoryScreen", true, false) as Control
	var latest := view.find_child("RunHistoryLatestSummary", true, false) as Label
	var scrolls := screen.find_children("", "ScrollContainer", true, false) \
		if screen != null else []
	if state.screen != FrontEndState.Screen.RUN_HISTORY or screen == null or \
			latest == null or not latest.text.contains("DEBUG_TEST") or \
			scrolls.size() != 1:
		failures.append("Run History route lost context or introduced competing scroll owners")
		view.free()
		return 0
	for button_name: StringName in [
		&"RunHistory", &"RunHistoryBack", &"RunHistoryViewJson",
		&"RunHistoryCopyJson",
	]:
		var button := view.front_end_button(button_name)
		if button == null or button.mouse_filter != Control.MOUSE_FILTER_STOP:
			failures.append("%s can leak export/navigation input" % button_name)
			view.free()
			return 0
	var exports: Array[String] = []
	state.run_history_export_requested.connect(func(payload: String) -> void:
		exports.append(payload))
	view.front_end_button(&"RunHistoryViewJson").pressed.emit()
	var export_text := view.find_child("RunHistoryExportJson", true, false) as TextEdit
	view.front_end_button(&"RunHistoryCopyJson").pressed.emit()
	if not state.run_history_export_visible or export_text == null or \
			not export_text.visible or export_text.editable or \
			export_text.mouse_filter != Control.MOUSE_FILTER_STOP or \
			exports.size() != 1 or \
			not exports[0].contains(RunRecordLedger.EXPORT_FORMAT) or \
			not exports[0].contains("\"transmission\": \"none\""):
		failures.append("owner-facing JSON export is not explicit, selectable, or input-owning")
		view.free()
		return 0
	view.front_end_button(&"RunHistoryBack").pressed.emit()
	if state.screen != FrontEndState.Screen.PLAY_MODES_HUB:
		failures.append("Run History does not return through its Play Modes owner")
		view.free()
		return 0
	view.free()
	return 1


static func _test_persistence_and_metric_ownership_are_single_seams(
	failures: PackedStringArray,
) -> int:
	var session_source := _read_source("res://game/application/swing_lab_session.gd")
	var front_end_source := _read_source("res://game/presentation/scripts/front_end.gd")
	var state_source := _read_source("res://game/application/front_end_state.gd")
	var main_source := _read_source("res://game/bootstrap/main.gd")
	var simulator_source := _read_source("res://tools/simulate.gd")
	var repository_source := _read_source("res://game/adapters/save_repository.gd")
	var clipboard_source := _read_source("res://game/adapters/clipboard_adapter.gd")
	var record_source := _read_source("res://game/domain/run_record.gd")
	var ledger_source := _read_source("res://game/domain/run_record_ledger.gd")
	var accumulator_source := _read_source(
		"res://game/application/run_metrics_accumulator.gd")
	if session_source.is_empty() or front_end_source.is_empty() or \
			state_source.is_empty() or main_source.is_empty() or \
			simulator_source.is_empty() or repository_source.is_empty() or \
			clipboard_source.is_empty() or record_source.is_empty() or \
			ledger_source.is_empty() or accumulator_source.is_empty():
		failures.append("run-evidence ownership sources could not be read")
		return 0
	if session_source.contains("user://") or \
			front_end_source.contains("FileAccess.open") or \
			front_end_source.contains("append_record(") or \
			front_end_source.contains("save_run_record") or \
			state_source.contains("FileAccess.open") or \
			state_source.contains("append_record(") or \
			state_source.contains("save_run_record") or \
			not main_source.contains("save_run_record_ledger") or \
			not main_source.contains("save_diagnostic"):
		failures.append("simulation, application, or presentation bypassed SaveRepository")
		return 0
	if not session_source.contains("run_finalized(settlement: RunSettlement, record: RunRecord)") or \
			not session_source.contains("_metrics.observe_tick(") or \
			not session_source.contains("_metrics.observe_event(event)") or \
			not simulator_source.contains("RunMetricsAccumulator.new()") or \
			not simulator_source.contains("evidence_metrics.observe_tick("):
		failures.append("game and simulator no longer share authoritative metric semantics")
		return 0
	var evidence_source := "\n".join([
		session_source, front_end_source, state_source, main_source,
		repository_source, clipboard_source, record_source, ledger_source,
		accumulator_source,
	])
	for forbidden: String in [
		"HTTPRequest", "HTTPClient", "WebSocket", "StreamPeer", "PacketPeer",
		"get_unique_id",
	]:
		if evidence_source.contains(forbidden):
			failures.append("local run evidence introduced forbidden remote/device seam %s" % forbidden)
			return 0
	return 1


static func _sample_record(
	id: String,
	final_distance_pixels: float,
	start_distance_pixels: float = 0.0,
	eligible: bool = true,
) -> RunRecord:
	var settlement := RunSettlement.create(
		id,
		final_distance_pixels,
		2,
		&"obstacle",
		DifficultyCatalog.MODE_STANDARD,
		start_distance_pixels,
		eligible,
		1337,
	)
	return RunRecord.create(settlement, {
		"active_duration_seconds": 2.0,
		"mean_forward_speed_pixels_per_second": 400.0,
		"maximum_forward_speed_pixels_per_second": 600.0,
		"above_reference_speed_share": 0.5,
	}, _standard_context())


static func _standard_context() -> Dictionary:
	return {
		"build_version": "test-build",
		"android_version_code": 65,
		"runtime_platform": "test",
		"swing_config_schema_version": SwingConfig.SCHEMA_VERSION,
		"trace_format": TraceCatalog.INPUT_TRACE_FORMAT,
		"difficulty_id": str(DifficultyCatalog.MODE_STANDARD),
		"spider_profile_id": str(SpiderCatalog.CLASSIC),
		"resolved_upgrade_levels": {},
		"preset_id": str(SwingConfig.PRESET_BALANCED),
		"attempt_ordinal": 1,
		"input_source": "human",
		"configuration_kind": "standard",
		"configuration_details": {},
	}


static func _cleanup_repository_paths(paths: Dictionary) -> void:
	for key: String in paths:
		var path := str(paths[key])
		for candidate: String in [path, "%s.tmp" % path, "%s.bak" % path]:
			if FileAccess.file_exists(candidate):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(candidate))


static func _write_test_file(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(text)
	file.close()


static func _read_source(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text := file.get_as_text()
	file.close()
	return text
