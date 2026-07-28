extends RefCounted
class_name FrontEndFlowTests
## Contracts for startup navigation, tutorial completeness, and real settings.


static func run() -> Dictionary:
	var failures := PackedStringArray()
	var passed := 0
	passed += _test_startup_is_home_not_gameplay(failures)
	passed += _test_primary_routes_are_real_buttons(failures)
	passed += _test_tutorial_covers_current_mechanics(failures)
	passed += _test_settings_are_validated_and_emitted(failures)
	passed += _test_settings_codec_round_trip(failures)
	passed += _test_composition_root_mounts_front_end_first(failures)
	return {"passed": passed, "failures": failures}


static func _test_startup_is_home_not_gameplay(
	failures: PackedStringArray,
) -> int:
	var state := FrontEndState.new()
	var plays: Array[PlayerSettings] = []
	state.play_requested.connect(func(settings: PlayerSettings) -> void:
		plays.append(settings))
	state.configure(PlayerSettings.defaults())
	if state.screen != FrontEndState.Screen.HOME or not plays.is_empty():
		failures.append("front end does not start at HOME without starting a run")
		return 0
	return 1


static func _test_primary_routes_are_real_buttons(
	failures: PackedStringArray,
) -> int:
	var state := FrontEndState.new()
	state.configure(PlayerSettings.defaults())
	var view := FrontEndView.new()
	view.bind_state(state)
	for button_name: StringName in [&"Play", &"Tutorial", &"Settings"]:
		var button := view.front_end_button(button_name)
		if button == null or button.mouse_filter != Control.MOUSE_FILTER_STOP:
			failures.append("%s is not an event-consuming Button" % button_name)
			view.free()
			return 0
	view.front_end_button(&"Tutorial").pressed.emit()
	if state.screen != FrontEndState.Screen.TUTORIAL:
		failures.append("Tutorial button does not route to tutorial")
		view.free()
		return 0
	view.front_end_button(&"TutorialBack").pressed.emit()
	view.front_end_button(&"Settings").pressed.emit()
	if state.screen != FrontEndState.Screen.SETTINGS:
		failures.append("Settings button does not route to settings")
		view.free()
		return 0
	view.free()
	return 1


static func _test_tutorial_covers_current_mechanics(
	failures: PackedStringArray,
) -> int:
	if FrontEndState.TUTORIAL_STEPS.size() != 5:
		failures.append("tutorial must have exactly five focused steps")
		return 0
	var combined := ""
	for step: Dictionary in FrontEndState.TUTORIAL_STEPS:
		for key in ["title", "body", "tip"]:
			combined += " " + str(step.get(key, ""))
	for required: String in [
		"moves forward automatically",
		"glowing cyan anchor",
		"tap anywhere",
		"hold REEL",
		"ends the run",
		"MENU",
	]:
		if required.to_lower() not in combined.to_lower():
			failures.append("tutorial omits required concept: %s" % required)
			return 0
	return 1


static func _test_settings_are_validated_and_emitted(
	failures: PackedStringArray,
) -> int:
	var state := FrontEndState.new()
	state.configure(PlayerSettings.defaults())
	var published: Array[PlayerSettings] = []
	state.settings_changed.connect(func(settings: PlayerSettings) -> void:
		published.append(settings))
	state.set_swing_preset(SwingConfig.PRESET_AGILE)
	state.set_control_hints(false)
	state.set_reduced_motion(true)
	state.set_debug_tools(false)
	state.set_swing_preset(&"not_a_real_preset")
	if published.size() != 4:
		failures.append("settings changes were not emitted exactly once each")
		return 0
	if state.settings.swing_preset != SwingConfig.PRESET_AGILE or \
			state.settings.show_control_hints or \
			not state.settings.reduced_motion or \
			state.settings.show_debug_tools:
		failures.append("settings state did not retain validated choices")
		return 0
	return 1


static func _test_settings_codec_round_trip(
	failures: PackedStringArray,
) -> int:
	var expected := PlayerSettings.defaults()
	expected.swing_preset = SwingConfig.PRESET_WEIGHTY
	expected.show_control_hints = false
	expected.reduced_motion = true
	expected.show_debug_tools = false
	var decoded := SaveRepository.decode_settings(JSON.stringify(
		expected.to_dictionary()))
	if decoded.to_dictionary() != expected.to_dictionary():
		failures.append("settings codec did not round-trip versioned values")
		return 0
	var invalid := SaveRepository.decode_settings(
		"{\"swing_preset\":\"impossible\"}")
	if invalid.swing_preset != SwingConfig.PRESET_BALANCED:
		failures.append("invalid persisted preset did not fall back safely")
		return 0
	return 1


static func _test_composition_root_mounts_front_end_first(
	failures: PackedStringArray,
) -> int:
	var file := FileAccess.open("res://game/bootstrap/main.gd", FileAccess.READ)
	if file == null:
		failures.append("composition root source cannot be read")
		return 0
	var source := file.get_as_text()
	if not source.contains("var failures := _mount_front_end()"):
		failures.append("startup does not explicitly mount the front end")
		return 0
	if source.contains("var failures: PackedStringArray = _mount_swing_lab()"):
		failures.append("startup still directly mounts gameplay")
		return 0
	if not source.contains("_front_end_state.play_requested.connect(_start_game)"):
		failures.append("Play does not own the transition into gameplay")
		return 0
	return 1
