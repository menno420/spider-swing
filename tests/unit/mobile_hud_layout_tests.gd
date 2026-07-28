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
	passed += _test_double_tap_has_a_separate_burst_route(failures)
	passed += _test_menu_button_returns_without_world_tap(failures)
	passed += _test_debug_button_and_panel_controls(failures)
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
	if reel.size.x < 180.0 or reel.size.y < 180.0:
		failures.append("Reel touch target is still too small for focused play")
		return 0
	if burst.size.x < 170.0 or burst.size.y < 170.0:
		failures.append("Burst touch target is too small for focused play")
		return 0
	if reel.intersects(burst):
		failures.append("left-thumb Reel overlaps right-thumb Burst")
		return 0
	if reel.get_center().x >= size.x * 0.5 or \
			burst.get_center().x <= size.x * 0.5:
		failures.append("thumb controls are not split across the lower corners")
		return 0
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
	var pause := router.hud_button(&"Utility0")
	if pause == null or pause.visible:
		failures.append("debug utility controls are not initially hidden")
		router.free()
		return 0
	debug.pressed.emit()
	if toggles.size() != 1 or not pause.visible:
		failures.append("DEBUG did not expose its real GUI controls")
		router.free()
		return 0
	debug.pressed.emit()
	if toggles.size() != 2 or pause.visible:
		failures.append("DEBUG did not hide its GUI controls on second press")
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
