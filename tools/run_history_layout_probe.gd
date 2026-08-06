extends SceneTree
## Settled-frame geometry probe for Run History at the strict mobile viewport.

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

	var ledger := RunRecordLedger.defaults()
	for index in range(RunRecordLedger.HISTORY_LIMIT):
		ledger.append_record(_record(index))
	var state := FrontEndState.new()
	state.configure(
		PlayerSettings.defaults(), PlayerProgress.defaults(), null, null, ledger)
	state.show_run_history()
	var view := FrontEndView.new()
	viewport.add_child(view)
	view.bind_state(state)
	await _settle()

	var screen := view.find_child("RunHistoryScreen", true, false) as Control
	var card := view.find_child("RunHistoryWebPanel", true, false) as Control
	var scroll := view.find_child("RunHistoryScroll", true, false) as ScrollContainer
	var latest := view.find_child("RunHistoryLatestPanel", true, false) as Control
	var last_record := view.find_child("RunHistoryRecord1", true, false) as Control
	var viewport_rect := Rect2(Vector2.ZERO, Vector2(VIEWPORT_SIZE))
	if screen == null or not screen.size.is_equal_approx(Vector2(VIEWPORT_SIZE)):
		failures.append("visible Run History root did not resolve to 1040×480")
	elif card == null or not viewport_rect.grow(0.5).encloses(card.get_global_rect()):
		failures.append("history card escaped the strict landscape viewport")
	if scroll == null or not scroll.visible or latest == null or last_record == null:
		failures.append("retained history did not render inside its native scroller")
	elif scroll.get_v_scroll_bar().max_value <= \
			scroll.get_v_scroll_bar().page:
		failures.append("100 retained records produced no vertical scroll range")
	var scroll_owners := (
		screen.find_children("", "ScrollContainer", true, false)
		if screen != null else []
	)
	if scroll_owners.size() != 1:
		failures.append("history list resolved with %d scroll owners" % scroll_owners.size())
	for button_name: StringName in [
		&"RunHistoryBack", &"RunHistoryViewJson",
	]:
		var button := view.front_end_button(button_name)
		if button == null or not viewport_rect.grow(0.5).encloses(
				button.get_global_rect()) or button.size.y < 48.0:
			failures.append("%s is clipped or below its strict-screen control floor" % button_name)

	state.show_run_history_export()
	await _settle()
	var export_text := view.find_child("RunHistoryExportJson", true, false) as TextEdit
	var status := view.find_child("RunHistoryExportStatus", true, false) as Control
	var copy := view.front_end_button(&"RunHistoryCopyJson")
	if export_text == null or not export_text.visible or \
			not card.get_global_rect().grow(0.5).encloses(export_text.get_global_rect()):
		failures.append("selectable JSON payload is not enclosed by the history card")
	if copy == null or not copy.visible or \
			not viewport_rect.grow(0.5).encloses(copy.get_global_rect()) or \
			copy.size.y < 48.0:
		failures.append("COPY JSON is clipped or below its strict-screen control floor")
	if status == null or not status.visible or \
			not viewport_rect.grow(0.5).encloses(status.get_global_rect()):
		failures.append("clipboard-verification status escaped the strict viewport")

	if failures.is_empty():
		print(
			"[run_history_layout_probe] PASS — 100 records and JSON export "
			+ "resolved at 1040×480 after %d frames" % SETTLE_FRAMES)
		quit(0)
		return
	printerr("[run_history_layout_probe] FAIL")
	for failure: String in failures:
		printerr("  ✗ %s" % failure)
	quit(1)


func _settle() -> void:
	for _frame in range(SETTLE_FRAMES):
		await process_frame


func _record(index: int) -> RunRecord:
	var settlement := RunSettlement.create(
		"layout-%d" % index,
		125000.0 + index * 10.0,
		index % 9,
		&"obstacle",
		SwingLabSession.RUN_PRACTICE,
		100000.0,
		false,
		7000 + index,
	)
	return RunRecord.create(settlement, {
		"active_duration_seconds": 90.0 + index,
		"mean_forward_speed_pixels_per_second": 430.0,
		"maximum_forward_speed_pixels_per_second": 780.0,
		"above_reference_speed_share": 0.42,
		"successful_web_attachments": 12,
		"reel_activations": 5,
		"reel_held_seconds": 11.0,
		"reel_empty_events": 1,
		"burst_activations": 3,
		"dive_activations": 2,
		"rescue_consumed": index % 2 == 0,
	}, {
		"build_version": "layout-probe",
		"android_version_code": 65,
		"runtime_platform": "probe",
		"swing_config_schema_version": SwingConfig.SCHEMA_VERSION,
		"trace_format": TraceCatalog.INPUT_TRACE_FORMAT,
		"difficulty_id": str(DifficultyCatalog.MODE_HARSH),
		"spider_profile_id": str(SpiderCatalog.CLASSIC),
		"resolved_upgrade_levels": {},
		"preset_id": str(SwingConfig.PRESET_BALANCED),
		"attempt_ordinal": index + 1,
		"input_source": "human",
		"configuration_kind": "debug_test",
		"configuration_details": {"debug_start_distance_pixels": 100000.0},
	})
