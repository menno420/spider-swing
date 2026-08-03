extends RefCounted
class_name TutorialPracticeTests
## Contracts for the noncompetitive tutorial teaching loop.


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_every_lesson_has_central_practice_metadata(failures)
	passed += _test_fixed_launches_reuse_campaign_verb_meanings(failures)
	passed += _test_attach_and_quality_release_need_authoritative_events(failures)
	passed += _test_distance_and_wrong_verbs_never_complete(failures)
	passed += _test_dive_requires_ordered_upper_recovery(failures)
	passed += _test_tutorial_run_is_deterministic_and_record_ineligible(failures)
	passed += _test_tutorial_death_creates_no_settlement(failures)
	passed += _test_front_end_returns_to_the_originating_lesson(failures)
	passed += _test_ordinary_play_and_campaign_modes_are_unchanged(failures)
	passed += _test_mobile_coaching_geometry_is_enclosed(failures)
	return {"passed": passed, "failures": failures}


static func _test_every_lesson_has_central_practice_metadata(
	failures: PackedStringArray,
) -> int:
	var tutorial_ids: Array[StringName] = []
	for lesson: Dictionary in FrontEndState.TUTORIAL_STEPS:
		tutorial_ids.append(StringName(lesson["id"]))
	var catalog_ids: Array[StringName] = []
	var practice_ids: Array[StringName] = []
	for metadata: Dictionary in TutorialPracticeCatalog.all_lessons():
		var lesson_id := StringName(metadata.get("lesson_id", &""))
		if lesson_id == &"" or lesson_id in catalog_ids:
			failures.append("tutorial practice metadata has a missing or duplicate id")
			return 0
		catalog_ids.append(lesson_id)
		if not bool(metadata.get("practice_available", false)):
			continue
		practice_ids.append(lesson_id)
		if StringName(metadata.get("objective_id", &"")).is_empty() or \
				int(metadata.get("fixed_seed", -1)) < 0 or \
				str(metadata.get("objective", "")).is_empty() or \
				str(metadata.get("coaching", "")).is_empty():
			failures.append("practice lesson %s has incomplete launch metadata" % lesson_id)
			return 0
	if catalog_ids != tutorial_ids:
		failures.append("practice metadata does not cover the tutorial in display order")
		return 0
	if practice_ids != [
		&"attach", &"swing_release", &"reel", &"anchor_burst",
		&"dive_recovery",
	]:
		failures.append("direct practice is not scoped to the five taught actions")
		return 0
	return 1


static func _test_fixed_launches_reuse_campaign_verb_meanings(
	failures: PackedStringArray,
) -> int:
	var seeds: Array[int] = []
	for lesson_id: StringName in [&"reel", &"anchor_burst", &"dive_recovery"]:
		var metadata := TutorialPracticeCatalog.lesson(lesson_id)
		var campaign_id := StringName(metadata.get("shared_campaign_level_id", &""))
		var required := StringName(metadata.get("required_verb", &""))
		if not CampaignCatalog.has_level(campaign_id) or \
				required not in CampaignCatalog.verbs_for_level(campaign_id):
			failures.append("%s does not reuse its Campaign teaching definition" % lesson_id)
			return 0
		var seed := int(metadata.get("fixed_seed", -1))
		if seed in seeds:
			failures.append("tutorial practices reuse a fixed course seed")
			return 0
		seeds.append(seed)
	return 1


static func _test_attach_and_quality_release_need_authoritative_events(
	failures: PackedStringArray,
) -> int:
	var attach := TutorialPracticeCatalog.initial_progress(&"attach")
	attach = TutorialPracticeCatalog.observe(
		&"attach", attach, SimulationEvent.make(SimulationEvent.Kind.ATTACHED))
	if not bool(attach.get("complete", false)):
		failures.append("authoritative ATTACHED did not complete attach practice")
		return 0
	var release := TutorialPracticeCatalog.initial_progress(&"swing_release")
	release = TutorialPracticeCatalog.observe(
		&"swing_release",
		release,
		SimulationEvent.make(
			SimulationEvent.Kind.RELEASED, Vector2.ZERO, "", {"forward_bonus": 0.0}),
	)
	if bool(release.get("complete", false)):
		failures.append("a release with no awarded momentum completed practice")
		return 0
	release = TutorialPracticeCatalog.observe(
		&"swing_release",
		release,
		SimulationEvent.make(
			SimulationEvent.Kind.RELEASED, Vector2.ZERO, "", {"forward_bonus": 8.0}),
	)
	if not bool(release.get("complete", false)):
		failures.append("a simulation-awarded rising release did not complete practice")
		return 0
	return 1


static func _test_distance_and_wrong_verbs_never_complete(
	failures: PackedStringArray,
) -> int:
	for lesson_id: StringName in [&"reel", &"anchor_burst", &"dive_recovery"]:
		var progress := TutorialPracticeCatalog.initial_progress(lesson_id)
		# RUN_RESTARTED carries course context and can include arbitrary distance;
		# objectives intentionally have no distance observation API.
		progress = TutorialPracticeCatalog.observe(
			lesson_id,
			progress,
			SimulationEvent.make(
				SimulationEvent.Kind.RUN_RESTARTED,
				Vector2.ZERO,
				"",
				{"distance_pixels": 999999.0},
			),
		)
		var wrong_kind := SimulationEvent.Kind.BURST_STARTED \
			if lesson_id != &"anchor_burst" else SimulationEvent.Kind.REEL_STARTED
		progress = TutorialPracticeCatalog.observe(
			lesson_id, progress, SimulationEvent.make(wrong_kind))
		if bool(progress.get("complete", false)) or \
				int(progress.get("stage", 0)) != 0:
			failures.append("distance or the wrong verb advanced %s" % lesson_id)
			return 0
	return 1


static func _test_dive_requires_ordered_upper_recovery(
	failures: PackedStringArray,
) -> int:
	var progress := TutorialPracticeCatalog.initial_progress(&"dive_recovery")
	progress = TutorialPracticeCatalog.observe(
		&"dive_recovery",
		progress,
		SimulationEvent.make(
			SimulationEvent.Kind.ATTACHED, Vector2.ZERO, "", {"dive_rearmed": true}),
	)
	if int(progress.get("stage", 0)) != 0:
		failures.append("upper attachment before Dive advanced recovery practice")
		return 0
	progress = TutorialPracticeCatalog.observe(
		&"dive_recovery", progress, SimulationEvent.make(SimulationEvent.Kind.DIVE_STARTED))
	progress = TutorialPracticeCatalog.observe(
		&"dive_recovery",
		progress,
		SimulationEvent.make(
			SimulationEvent.Kind.ATTACHED, Vector2.ZERO, "", {"dive_rearmed": false}),
	)
	if bool(progress.get("complete", false)) or int(progress.get("stage", 0)) != 1:
		failures.append("ordinary attachment falsely completed Dive recovery")
		return 0
	progress = TutorialPracticeCatalog.observe(
		&"dive_recovery",
		progress,
		SimulationEvent.make(
			SimulationEvent.Kind.ATTACHED, Vector2.ZERO, "", {"dive_rearmed": true}),
	)
	if not bool(progress.get("complete", false)):
		failures.append("Dive followed by its authoritative rearm did not complete")
		return 0
	return 1


static func _configured_tutorial_session(lesson_id: StringName) -> SwingLabSession:
	var session := SwingLabSession.new()
	session.configure_progress(PlayerProgress.defaults())
	session.configure_run(
		SwingLabSession.RUN_TUTORIAL_PRACTICE, 0.0, -1, false, &"", lesson_id)
	session._reset_run(false, true)
	return session


static func _test_tutorial_run_is_deterministic_and_record_ineligible(
	failures: PackedStringArray,
) -> int:
	var first := _configured_tutorial_session(&"attach")
	var second := _configured_tutorial_session(&"attach")
	var first_snapshot := first.current_snapshot()
	var second_snapshot := second.current_snapshot()
	var expected_seed := int(
		TutorialPracticeCatalog.lesson(&"attach").get("fixed_seed", -1))
	if first_snapshot.seed != expected_seed or \
			second_snapshot.seed != expected_seed or \
			first_snapshot.run_mode != SwingLabSession.RUN_TUTORIAL_PRACTICE or \
			first_snapshot.records_eligible or \
			first_snapshot.start_distance_pixels != 0.0:
		failures.append("tutorial launch is not fixed-seed, fixed-start, and ineligible")
		first.free()
		second.free()
		return 0
	first.free()
	second.free()
	return 1


static func _test_tutorial_death_creates_no_settlement(
	failures: PackedStringArray,
) -> int:
	var session := _configured_tutorial_session(&"reel")
	var settlements: Array[RunSettlement] = []
	var checkpoints: Array[StringName] = []
	session.settlement_created.connect(func(value: RunSettlement) -> void:
		settlements.append(value))
	session.checkpoint_reached.connect(func(region_id: StringName, _distance: float) -> void:
		checkpoints.append(region_id))
	session._world.run_flies = 99
	session._emit_settlement(&"tutorial-test-death")
	if not settlements.is_empty() or not checkpoints.is_empty():
		failures.append("tutorial practice emitted a settlement or checkpoint")
		session.free()
		return 0
	session.free()
	return 1


static func _test_front_end_returns_to_the_originating_lesson(
	failures: PackedStringArray,
) -> int:
	var state := FrontEndState.new()
	state.configure(PlayerSettings.defaults(), PlayerProgress.defaults())
	state.show_tutorial_lesson(&"anchor_burst")
	state.mark_tutorial_practice_completed(&"anchor_burst")
	var step := state.current_tutorial_step()
	if state.screen != FrontEndState.Screen.TUTORIAL or \
			StringName(step.get("id", &"")) != &"anchor_burst" or \
			not bool(step.get("practice_completed", false)):
		failures.append("completion feedback did not remain on its originating lesson")
		return 0
	var bootstrap := FileAccess.get_file_as_string("res://game/bootstrap/main.gd")
	if "tutorial_return_id" not in bootstrap or \
			"show_tutorial_lesson(tutorial_return_id)" not in bootstrap:
		failures.append("Menu/death/completion do not route back through lesson identity")
		return 0
	return 1


static func _test_ordinary_play_and_campaign_modes_are_unchanged(
	failures: PackedStringArray,
) -> int:
	var session := SwingLabSession.new()
	session.configure_run(SwingLabSession.RUN_STANDARD)
	session._reset_run(false, true)
	if session.current_snapshot().run_mode == SwingLabSession.RUN_TUTORIAL_PRACTICE:
		failures.append("ordinary Play was routed through tutorial practice")
		session.free()
		return 0
	session.configure_run(
		SwingLabSession.RUN_CAMPAIGN, 0.0, -1, false, CampaignCatalog.TEACH_REEL)
	session._reset_run(false, true)
	if session.current_snapshot().run_mode != SwingLabSession.RUN_CAMPAIGN:
		failures.append("Campaign no longer retains its own run purpose")
		session.free()
		return 0
	session.free()
	return 1


static func _test_mobile_coaching_geometry_is_enclosed(
	failures: PackedStringArray,
) -> int:
	for size: Vector2 in [
		Vector2(1280.0, 720.0), Vector2(1280.0, 600.0), Vector2(1040.0, 480.0),
	]:
		var rect := LabLayout.tutorial_coaching_rect(size)
		if rect.position.x < 0.0 or rect.position.y < 0.0 or \
				rect.end.x > size.x or rect.end.y > size.y:
			failures.append("tutorial coaching escapes the %s viewport" % size)
			return 0
		if rect.intersects(LabLayout.menu_rect(size)) or \
				rect.intersects(LabLayout.reel_rect(size)) or \
				rect.intersects(LabLayout.burst_rect(size)):
			failures.append("tutorial coaching obscures a touch control at %s" % size)
			return 0
	return 1
