extends RefCounted
class_name MobileHudLayoutTests
## Regression coverage for GUI-owned Android HUD input.


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_real_controls_own_primary_hud(failures)
	passed += _test_thumb_controls_are_large_and_separated(failures)
	passed += _test_reel_button_emits_only_reel(failures)
	passed += _test_burst_button_emits_only_burst(failures)
	passed += _test_action_feedback_is_event_driven(failures)
	passed += _test_double_tap_has_a_separate_burst_route(failures)
	passed += _test_touch_mouse_emulation_produces_one_intent(failures)
	passed += _test_device_tap_keeps_recovery_web_attached(failures)
	passed += _test_menu_button_returns_without_world_tap(failures)
	passed += _test_debug_button_and_panel_controls(failures)
	passed += _test_debug_controls_are_large_and_direct(failures)
	passed += _test_debug_catalog_uses_plain_language(failures)
	passed += _test_debug_panel_expands_for_wide_phone(failures)
	passed += _test_debug_controls_can_be_disabled(failures)
	passed += _test_world_input_waits_for_gui(failures)
	return {"passed": passed, "failures": failures}


static func _make_router() -> InputRouter:
	var router := InputRouter.new()
	router.install_touch_surface()
	return router


static func _test_real_controls_own_primary_hud(
	failures: PackedStringArray,
) -> int:
	var router := _make_router()
	var reel := router.hud_button(&"Reel")
	var burst := router.hud_button(&"Burst")
	var debug := router.hud_button(&"Debug")
	var menu := router.hud_button(&"Menu")
	if reel == null or burst == null or debug == null or menu == null:
		failures.append(
			"Reel, Burst, DEBUG, or MENU is not backed by a Godot Button")
		router.free()
		return 0
	if reel.mouse_filter != Control.MOUSE_FILTER_STOP or \
			burst.mouse_filter != Control.MOUSE_FILTER_STOP or \
			debug.mouse_filter != Control.MOUSE_FILTER_STOP or \
			menu.mouse_filter != Control.MOUSE_FILTER_STOP:
		failures.append("primary HUD controls do not stop GUI input")
		router.free()
		return 0
	if reel.anchor_left != 0.0 or reel.anchor_top != 1.0 or \
			burst.anchor_left != 1.0 or burst.anchor_top != 1.0 or \
			debug.anchor_left != 1.0 or debug.anchor_top != 0.0 or \
			menu.anchor_left != 0.0 or menu.anchor_top != 0.0:
		failures.append("primary HUD anchors are not tied to intended corners")
		router.free()
		return 0
	router.free()
	return 1


static func _test_thumb_controls_are_large_and_separated(
	failures: PackedStringArray,
) -> int:
	var size := Vector2(1280.0, 720.0)
	var reel := LabLayout.reel_rect(size)
	var burst := LabLayout.burst_rect(size)
	if reel.size.x < 220.0 or reel.size.y < 220.0:
		failures.append("Reel touch target is still too small for focused play")
		return 0
	if burst.size.x < 220.0 or burst.size.y < 220.0:
		failures.append("Burst touch target is too small for focused play")
		return 0
	if reel.intersects(burst):
		failures.append("left-thumb Reel overlaps right-thumb Burst")
		return 0
	if reel.get_center().x >= size.x * 0.5 or \
			burst.get_center().x <= size.x * 0.5:
		failures.append("thumb controls are not split across the lower corners")
		return 0
	if reel.get_center().x < 140.0 or burst.get_center().x > size.x - 140.0:
		failures.append("thumb controls remain too close to the device edges")
		return 0
	if reel.end.y > size.y - 24.0 or burst.end.y > size.y - 24.0:
		failures.append("thumb controls remain too close to the bottom edge")
		return 0

	var router := _make_router()
	var reel_button := router.hud_button(&"Reel")
	var burst_button := router.hud_button(&"Burst")
	var resolved_reel := _resolved_rect(reel_button, size)
	var resolved_burst := _resolved_rect(burst_button, size)
	if resolved_reel != reel or resolved_burst != burst:
		failures.append("GUI hit targets drifted from the shared layout contract")
		router.free()
		return 0
	router.free()
	return 1


static func _test_reel_button_emits_only_reel(
	failures: PackedStringArray,
) -> int:
	var router := _make_router()
	var reel_states: Array[bool] = []
	var world_taps: Array[Vector2] = []
	router.reel_changed.connect(func(active: bool) -> void:
		reel_states.append(active))
	router.web_tapped.connect(func(position: Vector2) -> void:
		world_taps.append(position))
	var reel := router.hud_button(&"Reel")
	reel.button_down.emit()
	reel.button_up.emit()
	if reel_states != [true, false]:
		failures.append("Reel Button did not emit the hold lifecycle: %s" %
			[reel_states])
		router.free()
		return 0
	if not world_taps.is_empty():
		failures.append("Reel Button leaked into the web action")
		router.free()
		return 0
	router.free()
	return 1


static func _test_burst_button_emits_only_burst(
	failures: PackedStringArray,
) -> int:
	var router := _make_router()
	var bursts: Array[bool] = []
	var world_taps: Array[Vector2] = []
	router.burst_requested.connect(func() -> void:
		bursts.append(true))
	router.web_tapped.connect(func(position: Vector2) -> void:
		world_taps.append(position))
	router.hud_button(&"Burst").pressed.emit()
	if bursts.size() != 1:
		failures.append("Burst Button did not emit one Burst request")
		router.free()
		return 0
	if not world_taps.is_empty():
		failures.append("Burst Button leaked into the web action")
		router.free()
		return 0
	router.free()
	return 1


static func _test_action_feedback_is_event_driven(
	failures: PackedStringArray,
) -> int:
	var view := SwingLabView.new()
	var reel_event := SimulationEvent.make(
		SimulationEvent.Kind.REEL_STARTED,
		Vector2(480.0, 150.0),
		"Reel engaged",
	)
	view.present_event(reel_event)
	if view._reel_feedback_remaining <= 0.0:
		failures.append("Reel success event did not arm visible feedback")
		view.free()
		return 0
	var burst_event := SimulationEvent.make(
		SimulationEvent.Kind.BURST_STARTED,
		Vector2(640.0, 150.0),
		"Anchor Pull",
		{
			"origin_x": 300.0,
			"origin_y": 420.0,
			"direction_x": 0.8,
			"direction_y": -0.6,
		},
	)
	view.present_event(burst_event)
	if view._burst_feedback_remaining <= 0.0 or \
			view._burst_feedback_direction.length() < 0.99:
		failures.append("Burst success event did not arm directional feedback")
		view.free()
		return 0
	view.free()

	var bootstrap := FileAccess.open(
		"res://game/bootstrap/main.gd",
		FileAccess.READ,
	)
	if bootstrap == null or not bootstrap.get_as_text().contains(
			"_session.event_published.connect(_input_router.present_simulation_event)"):
		failures.append("authoritative action events are not wired to haptics")
		return 0
	return 1


static func _test_double_tap_has_a_separate_burst_route(
	failures: PackedStringArray,
) -> int:
	var file := FileAccess.open(
		"res://game/adapters/input_router.gd",
		FileAccess.READ,
	)
	if file == null:
		failures.append("InputRouter source cannot be read")
		return 0
	var source := file.get_as_text()
	if not source.contains("touch.double_tap") or \
			not source.contains("burst_gesture.emit(touch.position)"):
		failures.append("touch double-tap is not routed as a Burst gesture")
		return 0
	if not source.contains("mouse.double_click") or \
			not source.contains("burst_gesture.emit(mouse.position)"):
		failures.append("mouse double-click cannot exercise the Burst gesture")
		return 0
	return 1


static func _test_touch_mouse_emulation_produces_one_intent(
	failures: PackedStringArray,
) -> int:
	var router := _make_router()
	var world_taps: Array[Vector2] = []
	var burst_gestures: Array[Vector2] = []
	router.web_tapped.connect(func(position: Vector2) -> void:
		world_taps.append(position))
	router.burst_gesture.connect(func(position: Vector2) -> void:
		burst_gestures.append(position))

	var position := Vector2(860.0, 140.0)
	var touch := _pressed_touch(position)
	router._unhandled_input(touch)
	var emulated_mouse := _left_mouse_press(
		position, InputEvent.DEVICE_ID_EMULATION)
	router._unhandled_input(emulated_mouse)
	if world_taps != [position] or not burst_gestures.is_empty():
		failures.append((
			"one touchscreen tap plus its emulated mouse copy emitted %d web " +
			"intents and %d Burst intents") % [
				world_taps.size(), burst_gestures.size()])
		router.free()
		return 0

	world_taps.clear()
	burst_gestures.clear()
	touch.double_tap = true
	emulated_mouse.double_click = true
	router._unhandled_input(touch)
	router._unhandled_input(emulated_mouse)
	if not world_taps.is_empty() or burst_gestures != [position]:
		failures.append((
			"one touchscreen double-tap plus its emulated mouse copy emitted " +
			"%d web intents and %d Burst intents") % [
				world_taps.size(), burst_gestures.size()])
		router.free()
		return 0

	world_taps.clear()
	burst_gestures.clear()
	var physical_mouse := _left_mouse_press(
		position, InputEvent.DEVICE_ID_MOUSE)
	router._unhandled_input(physical_mouse)
	if world_taps != [position] or not burst_gestures.is_empty():
		failures.append("filtering touch emulation also disabled physical mouse")
		router.free()
		return 0

	router.free()
	return 1


static func _test_device_tap_keeps_recovery_web_attached(
	failures: PackedStringArray,
) -> int:
	var router := _make_router()
	var session := SwingLabSession.new()
	session._reset_run()
	router.web_tapped.connect(session.request_web_tap)
	router.burst_gesture.connect(session.request_burst_from_gesture)
	session._world.pull_active = true
	session._world.pull_kind = &"burst"
	session._world.burst_cooldown_remaining = 1.0

	var target := Vector2(720.0, 150.0)
	var touch := _pressed_touch(target)
	var emulated_mouse := _left_mouse_press(
		target, InputEvent.DEVICE_ID_EMULATION)
	router._unhandled_input(touch)
	router._unhandled_input(emulated_mouse)
	if session._command_buffer.size() != 1:
		failures.append(
			"one post-Burst device tap buffered %d gameplay commands" %
			session._command_buffer.size())
		session.free()
		router.free()
		return 0
	session._step_once()
	if session._world.pull_active or not session._world.web.attached:
		failures.append(
			"one post-Burst device tap did not leave its recovery web attached")
		session.free()
		router.free()
		return 0

	session.free()
	router.free()
	return 1


static func _pressed_touch(position: Vector2) -> InputEventScreenTouch:
	var touch := InputEventScreenTouch.new()
	touch.position = position
	touch.pressed = true
	return touch


static func _left_mouse_press(
	position: Vector2,
	device: int,
) -> InputEventMouseButton:
	var mouse := InputEventMouseButton.new()
	mouse.position = position
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = true
	mouse.device = device
	return mouse


static func _test_menu_button_returns_without_world_tap(
	failures: PackedStringArray,
) -> int:
	var router := _make_router()
	var menu_requests: Array[bool] = []
	var world_taps: Array[Vector2] = []
	router.menu_requested.connect(func() -> void:
		menu_requests.append(true))
	router.web_tapped.connect(func(position: Vector2) -> void:
		world_taps.append(position))
	router.hud_button(&"Menu").pressed.emit()
	if menu_requests.size() != 1 or not world_taps.is_empty():
		failures.append("MENU did not emit one clean return request")
		router.free()
		return 0
	router.free()
	return 1


static func _test_debug_button_and_panel_controls(
	failures: PackedStringArray,
) -> int:
	var router := _make_router()
	var toggles: Array[bool] = []
	router.debug_toggle_requested.connect(func() -> void:
		toggles.append(true))
	var debug := router.hud_button(&"Debug")
	var movement_control := router.hud_button(&"gravityMinus")
	var pause := router.hud_button(&"Utility0")
	var tools_tab := router.hud_button(StringName(
		"Category%d" % TuningCatalog.tools_category_index()))
	if movement_control == null or pause == null or tools_tab == null or \
			movement_control.visible or pause.visible:
		failures.append("debug section controls are not initially hidden")
		router.free()
		return 0
	debug.pressed.emit()
	if toggles.size() != 1 or not movement_control.visible or pause.visible:
		failures.append("DEBUG did not open on the Movement section")
		router.free()
		return 0
	tools_tab.pressed.emit()
	if movement_control.visible or not pause.visible:
		failures.append("DEBUG category selection did not reveal Tools directly")
		router.free()
		return 0
	debug.pressed.emit()
	if toggles.size() != 2 or movement_control.visible or pause.visible:
		failures.append("DEBUG did not hide its GUI controls on second press")
		router.free()
		return 0
	router.free()
	return 1


static func _test_debug_controls_are_large_and_direct(
	failures: PackedStringArray,
) -> int:
	var router := _make_router()
	var adjustments: Array[Dictionary] = []
	var selections: Array[Dictionary] = []
	var world_taps: Array[Vector2] = []
	router.tuning_parameter_adjustment_requested.connect(
		func(parameter: StringName, direction: float) -> void:
			adjustments.append({
				"parameter": parameter,
				"direction": direction,
			}))
	router.tuning_value_requested.connect(
		func(parameter: StringName, value: float) -> void:
			selections.append({"parameter": parameter, "value": value}))
	router.web_tapped.connect(func(position: Vector2) -> void:
		world_taps.append(position))
	router.hud_button(&"Debug").pressed.emit()

	var plus := router.hud_button(&"gravityPlus")
	var quick := router.hud_button(&"gravityQuick1")
	if plus == null or quick == null:
		failures.append("Movement settings lack direct adjustment controls")
		router.free()
		return 0
	plus.pressed.emit()
	quick.pressed.emit()
	if adjustments != [{"parameter": &"gravity", "direction": 1.0}]:
		failures.append("large + control did not identify Gravity directly")
		router.free()
		return 0
	if selections != [{"parameter": &"gravity", "value": 1120.0}]:
		failures.append("one-tap Gravity choice emitted the wrong value")
		router.free()
		return 0
	if not world_taps.is_empty():
		failures.append("DEBUG tuning controls leaked into world web input")
		router.free()
		return 0

	for category_index in range(TuningCatalog.category_count()):
		if LabLayout.category_rect(category_index).size.y < 48.0:
			failures.append("DEBUG category target is below 48 px")
			router.free()
			return 0
	for card_index in range(3):
		if LabLayout.parameter_minus_rect(card_index).size.y < 48.0 or \
				LabLayout.parameter_plus_rect(card_index).size.y < 48.0:
			failures.append("DEBUG − / + target is below 48 px")
			router.free()
			return 0
	router.free()
	return 1


static func _test_debug_catalog_uses_plain_language(
	failures: PackedStringArray,
) -> int:
	var drive := TuningCatalog.descriptor(&"drive")
	var cooldown := TuningCatalog.descriptor(&"pull_cooldown")
	var dive := TuningCatalog.descriptor(&"dive_pull_pct")
	if str(drive.get("label", "")) != "Forward drive" or \
			not str(drive.get("help", "")).contains("forward speed"):
		failures.append("Drive still lacks a clear name and explanation")
		return 0
	if str(cooldown.get("label", "")) != "Burst cooldown" or \
			not str(cooldown.get("help", "")).contains("does not limit Dive"):
		failures.append("Burst cooldown is still ambiguous in DEBUG")
		return 0
	if str(dive.get("label", "")) != "Downward pull distance" or \
			not str(dive.get("help", "")).contains("Dive Pull"):
		failures.append("Dive distance still lacks a clear DEBUG description")
		return 0
	return 1


static func _test_debug_panel_expands_for_wide_phone(
	failures: PackedStringArray,
) -> int:
	var wide_size := Vector2(1560.0, 720.0)
	var router := InputRouter.new()
	router.install_touch_surface(wide_size)
	var blocker := router.hud_button(&"DebugPanelBlocker")
	var last_tab := router.hud_button(StringName(
		"Category%d" % TuningCatalog.tools_category_index()))
	var first_plus := router.hud_button(&"gravityPlus")
	var panel := LabLayout.debug_panel_rect(wide_size)
	if blocker == null or last_tab == null or first_plus == null:
		failures.append("wide DEBUG layout did not create its shared hit regions")
		router.free()
		return 0
	if _resolved_rect(blocker, wide_size) != panel or \
			panel.size.x <= LabLayout.debug_panel_rect().size.x:
		failures.append("DEBUG panel did not expand across a wide phone viewport")
		router.free()
		return 0
	if not _resolved_rect(last_tab, wide_size).is_equal_approx(
			LabLayout.category_rect(
				TuningCatalog.tools_category_index(),
				wide_size,
			)) or \
			_resolved_rect(first_plus, wide_size) != \
			LabLayout.parameter_plus_rect(0, wide_size):
		failures.append("wide DEBUG visuals and native hit targets drifted")
		router.free()
		return 0
	router.free()
	return 1


static func _test_debug_controls_can_be_disabled(
	failures: PackedStringArray,
) -> int:
	var router := _make_router()
	router.configure_debug_controls(false)
	var debug := router.hud_button(&"Debug")
	var utility := router.hud_button(&"Utility0")
	if debug.visible or utility.visible:
		failures.append("disabled laboratory tools remain touchable")
		router.free()
		return 0
	router.free()
	return 1


static func _test_world_input_waits_for_gui(
	failures: PackedStringArray,
) -> int:
	var file := FileAccess.open(
		"res://game/adapters/input_router.gd",
		FileAccess.READ,
	)
	if file == null:
		failures.append("InputRouter source cannot be read")
		return 0
	var source := file.get_as_text()
	if source.contains("func _input("):
		failures.append("InputRouter intercepts input before Godot GUI controls")
		return 0
	if not source.contains("func _unhandled_input("):
		failures.append("world input is not routed through _unhandled_input")
		return 0
	return 1


static func _resolved_rect(button: Button, viewport_size: Vector2) -> Rect2:
	var anchor := Vector2(button.anchor_left, button.anchor_top)
	return Rect2(
		anchor * viewport_size + Vector2(
			button.offset_left,
			button.offset_top,
		),
		Vector2(
			button.offset_right - button.offset_left,
			button.offset_bottom - button.offset_top,
		),
	)
