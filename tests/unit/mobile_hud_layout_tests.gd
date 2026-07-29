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
	passed += _test_spider_presentation_is_interpolated_and_mipmapped(
		failures)
	passed += _test_double_tap_has_a_separate_burst_route(failures)
	passed += _test_touch_mouse_emulation_produces_one_intent(failures)
	passed += _test_device_tap_keeps_recovery_web_attached(failures)
	passed += _test_menu_button_returns_without_world_tap(failures)
	passed += _test_debug_button_and_panel_controls(failures)
	passed += _test_diagnostic_overlays_are_opt_in(failures)
	passed += _test_debug_controls_are_large_and_direct(failures)
	passed += _test_debug_catalog_uses_plain_language(failures)
	passed += _test_environment_theme_packs_are_visual_only(failures)
	passed += _test_finished_forest_has_no_legacy_obstacle_backing(failures)
	passed += _test_forest_obstacles_join_the_rails_without_gate_distortion(
		failures,
	)
	passed += _test_living_forest_has_continuous_rails_and_depth_layers(
		failures,
	)
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


static func _test_spider_presentation_is_interpolated_and_mipmapped(
	failures: PackedStringArray,
) -> int:
	var view := SwingLabView.new()
	var first := SimulationSnapshot.new()
	first.tick = 10
	first.position = Vector2(100.0, 200.0)
	first.velocity = Vector2(300.0, -80.0)
	first.target_speed = 360.0
	view.present(first)
	var second := SimulationSnapshot.new()
	second.tick = 11
	second.position = Vector2(120.0, 240.0)
	second.velocity = Vector2(340.0, -40.0)
	second.target_speed = 360.0
	second.reel_active = true
	view.present(second)
	if not view._render_spider_position(0.5).is_equal_approx(
		Vector2(110.0, 220.0),
	) or not view._render_spider_velocity(0.5).is_equal_approx(
		Vector2(320.0, -60.0),
	):
		failures.append("custom spider rendering does not interpolate fixed snapshots")
		view.free()
		return 0
	var pose := view._spider_pose_scale(view._render_spider_velocity(0.5))
	if pose.x < 0.97 or pose.x > 1.045 or \
			pose.y < 0.97 or pose.y > 1.035 or \
			pose.is_equal_approx(Vector2.ONE):
		failures.append("spider action pose is missing or too strong")
		view.free()
		return 0
	view.configure_player_options(true, true, true)
	if not view._spider_pose_scale(Vector2(600.0, 100.0)).is_equal_approx(
		Vector2.ONE,
	):
		failures.append("reduced motion does not disable spider pose animation")
		view.free()
		return 0
	var teleported := SimulationSnapshot.new()
	teleported.tick = 12
	teleported.position = Vector2(900.0, 240.0)
	teleported.velocity = Vector2.ZERO
	view.present(teleported)
	if not view._render_spider_position(0.5).is_equal_approx(
		teleported.position,
	):
		failures.append("presentation interpolation smears run resets or teleports")
		view.free()
		return 0
	view.free()

	var renderer := FileAccess.open(
		"res://game/presentation/scripts/swing_lab.gd",
		FileAccess.READ,
	)
	if renderer == null:
		failures.append("spider presentation source cannot be inspected")
		return 0
	var source := renderer.get_as_text()
	if not source.contains("Engine.get_physics_interpolation_fraction()") or \
			not source.contains("TEXTURE_FILTER_LINEAR_WITH_MIPMAPS"):
		failures.append("spider smoothing is not tied to Godot interpolation and mips")
		return 0
	for import_path in [
		"res://assets/runtime/characters/classic-garden-spider.png.import",
		"res://assets/runtime/collectibles/golden-forest-fly.png.import",
	]:
		var import_file := FileAccess.open(import_path, FileAccess.READ)
		if import_file == null or not import_file.get_as_text().contains(
			"mipmaps/generate=true",
		):
			failures.append("minified moving art lacks mipmaps: %s" % import_path)
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


static func _test_diagnostic_overlays_are_opt_in(
	failures: PackedStringArray,
) -> int:
	var session := SwingLabSession.new()
	if not session.has_method("toggle_collision_outlines") or \
			not session.has_method("toggle_web_guides"):
		failures.append("diagnostic overlays are not independent session controls")
		session.free()
		return 0
	session._reset_run()
	var initial: SimulationSnapshot = session._make_snapshot()
	if initial.get("collision_outlines_visible") != false or \
			initial.get("web_guides_visible") != false:
		failures.append("collision outlines or web guides load enabled by default")
		session.free()
		return 0
	session.call("toggle_collision_outlines")
	session.call("toggle_web_guides")
	var enabled: SimulationSnapshot = session._make_snapshot()
	if enabled.get("collision_outlines_visible") != true or \
			enabled.get("web_guides_visible") != true:
		failures.append("diagnostic overlay state did not publish in the snapshot")
		session.free()
		return 0
	session.free()

	var router := _make_router()
	if not router.has_signal("collision_outlines_toggle_requested") or \
			not router.has_signal("web_guides_toggle_requested"):
		failures.append("debug input does not expose diagnostic overlay intents")
		router.free()
		return 0
	var outline_requests: Array[bool] = []
	var guide_requests: Array[bool] = []
	router.connect(
		"collision_outlines_toggle_requested",
		func() -> void: outline_requests.append(true),
	)
	router.connect(
		"web_guides_toggle_requested",
		func() -> void: guide_requests.append(true),
	)
	router.hud_button(&"Debug").pressed.emit()
	var overlays_tab := router.hud_button(StringName(
		"Category%d" % TuningCatalog.category_index(&"overlays")))
	var outlines := router.hud_button(&"CollisionOutlines")
	var guides := router.hud_button(&"WebGuides")
	if overlays_tab == null or outlines == null or guides == null:
		failures.append("DEBUG lacks direct outline and web-guide controls")
		router.free()
		return 0
	overlays_tab.pressed.emit()
	if not outlines.visible or not guides.visible:
		failures.append("OVERLAYS section did not reveal both diagnostic controls")
		router.free()
		return 0
	outlines.pressed.emit()
	guides.pressed.emit()
	if outline_requests.size() != 1 or guide_requests.size() != 1:
		failures.append("diagnostic controls did not emit one intent each")
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


static func _test_environment_theme_packs_are_visual_only(
	failures: PackedStringArray,
) -> int:
	if EnvironmentThemeCatalog.count() != LabLayout.ENVIRONMENT_THEME_COUNT or \
			EnvironmentThemeCatalog.count() != 5:
		failures.append(
			"environment theme catalog and touch layout disagree on five looks")
		return 0
	var texture_paths := EnvironmentThemeCatalog.texture_paths()
	if texture_paths.size() != 4:
		failures.append("environment selector does not expose four texture packs")
		return 0
	for path: String in texture_paths:
		if not ResourceLoader.exists(path):
			failures.append("environment texture is missing: %s" % path)
			return 0
		var texture := load(path) as Texture2D
		if texture == null or texture.get_size() != Vector2(384.0, 384.0):
			failures.append("environment texture is not a 384 px runtime tile")
			return 0
	var art_paths := ArtAssetCatalog.texture_paths()
	if art_paths.size() != 10:
		failures.append("finished forest slice does not expose ten active art assets")
		return 0
	for path: String in art_paths:
		if not ResourceLoader.exists(path):
			failures.append("finished runtime art is missing: %s" % path)
			return 0
		var art_texture := load(path) as Texture2D
		if art_texture == null or \
				art_texture.get_width() < 128 or \
				art_texture.get_height() < 100:
			failures.append("finished runtime art is invalid or undersized: %s" % path)
			return 0

	var router := _make_router()
	var requests: Array[int] = []
	router.environment_theme_requested.connect(func(index: int) -> void:
		requests.append(index))
	router.hud_button(&"Debug").pressed.emit()
	var look_tab := router.hud_button(StringName(
		"Category%d" % TuningCatalog.category_index(
			TuningCatalog.CATEGORY_VISUALS)))
	var attic := router.hud_button(&"EnvironmentTheme4")
	if look_tab == null or attic == null:
		failures.append("LOOK section is not backed by direct Godot Buttons")
		router.free()
		return 0
	look_tab.pressed.emit()
	if not attic.visible or \
			LabLayout.environment_theme_card_rect(4).size.x < 300.0 or \
			LabLayout.environment_theme_card_rect(4).size.y < 180.0:
		failures.append("environment choices are not large, direct touch cards")
		router.free()
		return 0
	attic.pressed.emit()
	if requests != [4]:
		failures.append("environment card did not emit its exact visual index")
		router.free()
		return 0
	router.free()

	var stream := CourseStream.new()
	stream.reset()
	var before: CourseGeometry = stream.geometry().duplicate_geometry()
	var view := SwingLabView.new()
	if view.environment_theme_index() != \
			EnvironmentThemeCatalog.default_index():
		failures.append("generated Ancient Forest pack is not the default look")
		view.free()
		return 0
	for index in range(EnvironmentThemeCatalog.count()):
		view.select_environment_theme(index)
		if view.environment_theme_index() != index:
			failures.append("environment view rejected a valid theme index")
			view.free()
			return 0
	var after: CourseGeometry = stream.geometry()
	view.free()
	if before.boundary_surfaces != after.boundary_surfaces or \
			before.obstacles != after.obstacles or \
			before.aim_guides != after.aim_guides:
		failures.append("visual theme selection mutated course geometry")
		return 0
	return 1


static func _test_finished_forest_has_no_legacy_obstacle_backing(
	failures: PackedStringArray,
) -> int:
	var forest_index := EnvironmentThemeCatalog.index_for(
		EnvironmentThemeCatalog.ANCIENT_FOREST,
	)
	var forest := EnvironmentThemeCatalog.theme(forest_index)
	if bool(forest.get("draw_obstacle_geometry_backing", true)):
		failures.append(
			"finished forest still requests the legacy obstacle backing fill")
		return 0
	var renderer := FileAccess.open(
		"res://game/presentation/scripts/swing_lab.gd",
		FileAccess.READ,
	)
	if renderer == null:
		failures.append("finished forest renderer source cannot be inspected")
		return 0
	if renderer.get_as_text().contains("FOREST_OBSTACLE_SHADOW"):
		failures.append(
			"finished forest still draws the old polygon silhouette behind art")
		return 0
	return 1


static func _test_forest_obstacles_join_the_rails_without_gate_distortion(
	failures: PackedStringArray,
) -> int:
	var renderer := FileAccess.open(
		"res://game/presentation/scripts/swing_lab.gd",
		FileAccess.READ,
	)
	var catalog := FileAccess.open(
		"res://game/presentation/scripts/art_asset_catalog.gd",
		FileAccess.READ,
	)
	if renderer == null or catalog == null:
		failures.append("forest presentation sources cannot be inspected")
		return 0
	var renderer_source := renderer.get_as_text()
	var catalog_source := catalog.get_as_text()
	if not renderer_source.contains("FOREST_RAIL_JOIN_OVERLAP") or \
			not renderer_source.contains("_redraw_forest_boundary_edges"):
		failures.append(
			"wall-grown forest art has no explicit rail-overlap composition")
		return 0
	if renderer_source.contains("FOREST_GATE_UPPER_SOURCE") or \
			renderer_source.contains("FOREST_GATE_LOWER_SOURCE") or \
			renderer_source.contains("_draw_forest_gate"):
		failures.append(
			"broad forest passage still stretches cropped circular gate halves")
		return 0
	if catalog_source.contains("FOREST_ROOT_GATE") or \
			catalog_source.contains("split-thorn-root-gate.png"):
		failures.append(
			"retired circular gate art remains in the runtime asset catalog")
		return 0
	if not renderer_source.contains("_draw_texture_cover"):
		failures.append(
			"forest obstacle art still permits non-uniform texture distortion")
		return 0
	return 1


static func _test_living_forest_has_continuous_rails_and_depth_layers(
	failures: PackedStringArray,
) -> int:
	var renderer := FileAccess.open(
		"res://game/presentation/scripts/swing_lab.gd",
		FileAccess.READ,
	)
	var catalog := FileAccess.open(
		"res://game/presentation/scripts/art_asset_catalog.gd",
		FileAccess.READ,
	)
	if renderer == null or catalog == null:
		failures.append("living forest presentation sources cannot be inspected")
		return 0
	var renderer_source := renderer.get_as_text()
	var catalog_source := catalog.get_as_text()
	for token in [
		"FOREST_RAIL_TILE",
		"FOREST_GROWTH_SOCKET",
		"FOREST_BACKDROP_FAR",
		"FOREST_BACKDROP_MID",
		"FOREST_BACKDROP_NEAR",
		"FOREST_ROOT_STUMP",
	]:
		if not catalog_source.contains(token):
			failures.append("living forest art catalog is missing %s" % token)
			return 0
	for token in [
		"_draw_continuous_forest_profile",
		"draw_texture_rect_region",
		"_draw_forest_growth_socket",
		"_draw_forest_backdrop_layer",
	]:
		if not renderer_source.contains(token):
			failures.append("living forest renderer is missing %s" % token)
			return 0
	for path in [
		"res://assets/runtime/forest-biome/ancient-branch-rail-tile.png",
		"res://assets/runtime/forest-biome/mossy-growth-socket.png",
		"res://assets/runtime/forest-biome/forest-backdrop-far.webp",
		"res://assets/runtime/forest-biome/forest-backdrop-mid.png",
		"res://assets/runtime/forest-biome/forest-backdrop-near.png",
		"res://assets/runtime/forest-biome/fallen-root-stump.png",
	]:
		if not ResourceLoader.exists(path):
			failures.append("living forest runtime asset is missing: %s" % path)
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
