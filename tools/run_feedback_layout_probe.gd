extends SceneTree
## Settled-frame geometry probe for the dead-state prompt at 1040×480.

const VIEWPORT_SIZE := Vector2i(1040, 480)
const SETTLE_FRAMES := 4


func _initialize() -> void:
	call_deferred("_run_probe")


func _run_probe() -> void:
	var failures := PackedStringArray()
	var viewport := SubViewport.new()
	viewport.size = VIEWPORT_SIZE
	viewport.handle_input_locally = true
	root.add_child(viewport)
	var view := SwingLabView.new()
	var router := InputRouter.new()
	viewport.add_child(view)
	viewport.add_child(router)
	var record := _record()
	var ledger := RunRecordLedger.defaults()
	ledger.append_record(record)
	var prompt := RunFeedbackPromptPolicy.prompt_for(
		ledger.record_by_id(record.record_id), ledger)
	view.configure_run_feedback_prompt(prompt)
	router.configure_run_feedback_prompt(prompt)
	var dead := SimulationSnapshot.new()
	dead.run_state = &"dead"
	view.present(dead)
	router.present_snapshot(dead)
	await _settle()

	var viewport_rect := Rect2(Vector2.ZERO, Vector2(VIEWPORT_SIZE))
	var panel := LabLayout.run_feedback_panel_rect(VIEWPORT_SIZE)
	if prompt.is_empty() or not view.run_feedback_prompt_visible() or \
			not router.run_feedback_prompt_visible() or \
			not viewport_rect.grow(0.5).encloses(panel):
		failures.append("eligible dead-state prompt did not resolve inside 1040×480")
	for button_name: StringName in [
		&"RunFeedbackYes", &"RunFeedbackNo", &"RunFeedbackSkip",
	]:
		var button := router.hud_button(button_name)
		if button == null or not button.visible or button.size.y < 48.0 or \
				not panel.grow(0.5).encloses(button.get_global_rect()):
			failures.append("%s escaped the prompt or touch floor" % button_name)
	var menu := router.hud_button(&"Menu")
	if menu == null or not menu.visible or \
			not viewport_rect.grow(0.5).encloses(menu.get_global_rect()) or \
			panel.intersects(menu.get_global_rect()):
		failures.append("Menu escape is clipped or hidden behind the prompt")

	if failures.is_empty():
		print(
			"[run_feedback_layout_probe] PASS — dead-state prompt and Menu "
			+ "resolved at 1040×480 after %d frames" % SETTLE_FRAMES)
		quit(0)
		return
	printerr("[run_feedback_layout_probe] FAIL")
	for failure: String in failures:
		printerr("  ✗ %s" % failure)
	quit(1)


func _settle() -> void:
	for _frame in range(SETTLE_FRAMES):
		await process_frame


func _record() -> RunRecord:
	var settlement := RunSettlement.create(
		"feedback-layout",
		24000.0,
		3,
		&"obstacle",
		SwingLabSession.RUN_STANDARD,
		0.0,
		true,
		9917,
	)
	return RunRecord.create(settlement, {}, {
		"build_version": "feedback-layout-probe",
		"android_version_code": 66,
		"runtime_platform": "probe",
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
	})
