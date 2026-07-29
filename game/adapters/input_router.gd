extends Node
class_name InputRouter
## Captures render-time input and emits intent without mutating simulation.
##
## HUD input is owned by real Godot Controls. World taps are handled only in
## `_unhandled_input`, after the GUI pipeline has had the opportunity to consume
## them. This keeps device stretch, safe areas, and pointer routing inside Godot
## instead of recreating those rules with manual coordinate math.

signal web_tapped(screen_position: Vector2)
signal reel_changed(active: bool)
signal burst_requested
signal burst_gesture(screen_position: Vector2)
signal restart_requested
signal menu_requested
signal debug_toggle_requested
signal debug_pause_requested
signal debug_frame_step_requested
signal slow_motion_requested
signal preset_requested(name: StringName)
signal tuning_parameter_requested(direction: int)
signal tuning_adjustment_requested(direction: float)
signal tuning_category_requested(index: int)
signal tuning_parameter_adjustment_requested(
	parameter: StringName,
	direction: float,
)
signal tuning_value_requested(parameter: StringName, value: float)
signal recording_requested
signal replay_requested
signal diagnostic_export_requested

var _reel_active: bool = false
var _touch_reel_active: bool = false
var _debug_visible: bool = false
var _keyboard_reel_active: bool = false
var _touch_surface: Control
var _reel_button: Button
var _burst_button: Button
var _debug_button: Button
var _menu_button: Button
var _debug_controls: Array[Control] = []
var _debug_always_controls: Array[Control] = []
var _debug_category_controls: Dictionary = {}
var _debug_controls_enabled: bool = true
var _active_debug_category_index: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	install_touch_surface(get_viewport().get_visible_rect().size)
	set_process_unhandled_input(true)
	set_process(true)


func _process(_delta: float) -> void:
	var keyboard_reel := Input.is_action_pressed("reel_in")
	if keyboard_reel != _keyboard_reel_active:
		_keyboard_reel_active = keyboard_reel
		_publish_reel_state()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			if touch.double_tap:
				burst_gesture.emit(touch.position)
			else:
				web_tapped.emit(touch.position)
		return

	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		# Godot emits a synthetic mouse event after a touchscreen event when
		# touch-to-mouse emulation is enabled for the Control-based HUD. The
		# touchscreen event already owns world intent, so accepting this copy
		# would turn one physical tap into attach+release (or two Bursts).
		if mouse.device == InputEvent.DEVICE_ID_EMULATION:
			return
		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			if mouse.double_click:
				burst_gesture.emit(mouse.position)
			else:
				web_tapped.emit(mouse.position)
		return

	if event.is_action_pressed("web_action"):
		web_tapped.emit(get_viewport().get_mouse_position())
	elif event.is_action_pressed("burst_action"):
		burst_requested.emit()
	elif event.is_action_pressed("restart_run"):
		restart_requested.emit()
	elif event.is_action_pressed("ui_cancel"):
		_request_menu()
	elif event.is_action_pressed("toggle_debug"):
		_toggle_debug_from_touch()
	elif event.is_action_pressed("pause"):
		debug_pause_requested.emit()

	if event is InputEventKey:
		_handle_debug_key(event as InputEventKey)


func install_touch_surface(
	layout_size: Vector2 = LabLayout.REFERENCE_SIZE,
) -> void:
	if _touch_surface != null:
		return
	var layer := CanvasLayer.new()
	layer.name = "HudTouchLayer"
	layer.layer = 100
	add_child(layer)

	_touch_surface = Control.new()
	_touch_surface.name = "Surface"
	_touch_surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_touch_surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_touch_surface)
	if layout_size.x <= 0.0 or layout_size.y <= 0.0:
		layout_size = LabLayout.REFERENCE_SIZE

	_menu_button = _make_anchored_button(
		&"Menu",
		Vector2.ZERO,
		Rect2(24.0, 24.0, 92.0, 52.0),
	)
	_menu_button.pressed.connect(_request_menu)

	_reel_button = _make_anchored_button(
		&"Reel",
		Vector2(0.0, 1.0),
		_offset_from_reference(
			LabLayout.reel_rect(LabLayout.REFERENCE_SIZE),
			Vector2(0.0, 1.0),
		),
	)
	_reel_button.button_down.connect(_set_touch_reel.bind(true))
	_reel_button.button_up.connect(_set_touch_reel.bind(false))

	_burst_button = _make_anchored_button(
		&"Burst",
		Vector2.ONE,
		_offset_from_reference(
			LabLayout.burst_rect(LabLayout.REFERENCE_SIZE),
			Vector2.ONE,
		),
	)
	_burst_button.pressed.connect(func() -> void: burst_requested.emit())

	_debug_button = _make_anchored_button(
		&"Debug",
		Vector2(1.0, 0.0),
		_offset_from_reference(
			LabLayout.debug_toggle_rect(LabLayout.REFERENCE_SIZE),
			Vector2(1.0, 0.0),
		),
	)
	_debug_button.pressed.connect(_toggle_debug_from_touch)

	var panel_blocker := _make_fixed_button(
		&"DebugPanelBlocker",
		LabLayout.debug_panel_rect(layout_size),
	)
	_debug_controls.append(panel_blocker)
	_debug_always_controls.append(panel_blocker)

	for index in range(SwingConfig.preset_names().size()):
		var preset_name := SwingConfig.preset_names()[index]
		var button := _make_fixed_button(
			StringName("Preset%d" % index),
			LabLayout.preset_rect(index, layout_size),
		)
		button.pressed.connect(_emit_preset.bind(preset_name))
		_debug_controls.append(button)
		_debug_always_controls.append(button)

	for category_index in range(TuningCatalog.category_count()):
		_debug_category_controls[category_index] = []
		var category_button := _make_fixed_button(
			StringName("Category%d" % category_index),
			LabLayout.category_rect(category_index, layout_size),
		)
		category_button.pressed.connect(
			_emit_tuning_category.bind(category_index))
		_debug_controls.append(category_button)
		_debug_always_controls.append(category_button)

	for category_index in range(TuningCatalog.tools_category_index()):
		var category := TuningCatalog.category(category_index)
		var parameters := TuningCatalog.parameters_for_category(
			StringName(category["id"]))
		var category_controls: Array = _debug_category_controls[category_index]
		for card_index in range(parameters.size()):
			var descriptor: Dictionary = parameters[card_index]
			var parameter := StringName(descriptor["id"])
			var minus := _make_fixed_button(
				StringName("%sMinus" % parameter),
				LabLayout.parameter_minus_rect(card_index, layout_size),
			)
			minus.pressed.connect(
				_emit_parameter_adjustment.bind(parameter, -1.0))
			_register_category_control(category_controls, minus)

			var plus := _make_fixed_button(
				StringName("%sPlus" % parameter),
				LabLayout.parameter_plus_rect(card_index, layout_size),
			)
			plus.pressed.connect(
				_emit_parameter_adjustment.bind(parameter, 1.0))
			_register_category_control(category_controls, plus)

			var quick_values: Array = descriptor["quick"]
			for quick_index in range(quick_values.size()):
				var value := float(quick_values[quick_index])
				var quick := _make_fixed_button(
					StringName("%sQuick%d" % [parameter, quick_index]),
					LabLayout.parameter_quick_rect(
						card_index,
						quick_index,
						quick_values.size(),
						layout_size,
					),
				)
				quick.pressed.connect(
					_emit_tuning_value.bind(parameter, value))
				_register_category_control(category_controls, quick)

	for index in range(6):
		var utility := _make_fixed_button(
			StringName("Utility%d" % index),
			LabLayout.utility_rect(index, layout_size),
		)
		utility.pressed.connect(_emit_utility.bind(index))
		var tool_controls: Array = _debug_category_controls[
			TuningCatalog.tools_category_index()]
		_register_category_control(tool_controls, utility)
	_touch_surface.move_child(_debug_button, _touch_surface.get_child_count() - 1)
	_set_debug_controls_visible(false)


func hud_button(button_name: StringName) -> Button:
	if _touch_surface == null:
		return null
	return _touch_surface.get_node_or_null(NodePath(str(button_name))) as Button


func configure_debug_controls(enabled: bool) -> void:
	_debug_controls_enabled = enabled
	if _debug_button != null:
		_debug_button.visible = enabled
	if not enabled and _debug_visible:
		_debug_visible = false
		_set_debug_controls_visible(false)
		debug_toggle_requested.emit()


func present_snapshot(snapshot: SimulationSnapshot) -> void:
	if snapshot.debug_category_index != _active_debug_category_index:
		_active_debug_category_index = snapshot.debug_category_index
		if _debug_visible:
			_set_debug_controls_visible(true)


func present_simulation_event(event: SimulationEvent) -> void:
	match event.kind:
		SimulationEvent.Kind.REEL_STARTED:
			Input.vibrate_handheld(28, 0.35)
		SimulationEvent.Kind.BURST_STARTED:
			Input.vibrate_handheld(52, 0.8)
		SimulationEvent.Kind.DIVE_STARTED:
			Input.vibrate_handheld(38, 0.62)


func _make_anchored_button(
	button_name: StringName,
	anchor: Vector2,
	offset_rect: Rect2,
) -> Button:
	var button := _new_input_button(button_name)
	button.anchor_left = anchor.x
	button.anchor_top = anchor.y
	button.anchor_right = anchor.x
	button.anchor_bottom = anchor.y
	button.offset_left = offset_rect.position.x
	button.offset_top = offset_rect.position.y
	button.offset_right = offset_rect.end.x
	button.offset_bottom = offset_rect.end.y
	return button


func _offset_from_reference(rect: Rect2, anchor: Vector2) -> Rect2:
	return Rect2(
		rect.position - anchor * LabLayout.REFERENCE_SIZE,
		rect.size,
	)


func _make_fixed_button(button_name: StringName, rect: Rect2) -> Button:
	return _make_anchored_button(button_name, Vector2.ZERO, rect)


func _new_input_button(button_name: StringName) -> Button:
	var button := Button.new()
	button.name = str(button_name)
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.self_modulate = Color(1.0, 1.0, 1.0, 0.01)
	_touch_surface.add_child(button)
	return button


func _set_touch_reel(active: bool) -> void:
	_touch_reel_active = active
	_publish_reel_state()


func _toggle_debug_from_touch() -> void:
	if not _debug_controls_enabled:
		return
	_debug_visible = not _debug_visible
	_set_debug_controls_visible(_debug_visible)
	debug_toggle_requested.emit()


func _set_debug_controls_visible(visible: bool) -> void:
	if _reel_button != null:
		_reel_button.disabled = visible
	if _burst_button != null:
		_burst_button.disabled = visible
	for control: Control in _debug_controls:
		control.visible = false
	if not visible or not _debug_controls_enabled:
		return
	for control: Control in _debug_always_controls:
		control.visible = true
	var active_controls: Array = _debug_category_controls.get(
		_active_debug_category_index,
		[],
	)
	for control: Control in active_controls:
		control.visible = true


func _request_menu() -> void:
	cancel_held_input()
	menu_requested.emit()


func _emit_preset(preset_name: StringName) -> void:
	preset_requested.emit(preset_name)


func _emit_tuning_parameter(direction: int) -> void:
	tuning_parameter_requested.emit(direction)


func _emit_tuning_adjustment(direction: float) -> void:
	tuning_adjustment_requested.emit(direction)


func _emit_tuning_category(index: int) -> void:
	_active_debug_category_index = clampi(
		index,
		0,
		TuningCatalog.category_count() - 1,
	)
	_set_debug_controls_visible(_debug_visible)
	tuning_category_requested.emit(_active_debug_category_index)


func _emit_parameter_adjustment(
	parameter: StringName,
	direction: float,
) -> void:
	tuning_parameter_adjustment_requested.emit(parameter, direction)


func _emit_tuning_value(parameter: StringName, value: float) -> void:
	tuning_value_requested.emit(parameter, value)


func _register_category_control(
	category_controls: Array,
	control: Control,
) -> void:
	category_controls.append(control)
	_debug_controls.append(control)


func _emit_utility(index: int) -> void:
	match index:
		0:
			debug_pause_requested.emit()
		1:
			debug_frame_step_requested.emit()
		2:
			slow_motion_requested.emit()
		3:
			recording_requested.emit()
		4:
			replay_requested.emit()
		5:
			diagnostic_export_requested.emit()


func _handle_debug_key(key: InputEventKey) -> void:
	if not key.pressed or key.echo or not _debug_controls_enabled:
		return
	match key.keycode:
		KEY_1:
			preset_requested.emit(SwingConfig.PRESET_BALANCED)
		KEY_2:
			preset_requested.emit(SwingConfig.PRESET_WEIGHTY)
		KEY_3:
			preset_requested.emit(SwingConfig.PRESET_AGILE)
		KEY_COMMA:
			tuning_parameter_requested.emit(-1)
		KEY_PERIOD:
			tuning_parameter_requested.emit(1)
		KEY_MINUS:
			tuning_adjustment_requested.emit(-1.0)
		KEY_EQUAL:
			tuning_adjustment_requested.emit(1.0)
		KEY_F2:
			debug_pause_requested.emit()
		KEY_F3:
			debug_frame_step_requested.emit()
		KEY_F4:
			slow_motion_requested.emit()
		KEY_F6:
			recording_requested.emit()
		KEY_F7:
			replay_requested.emit()
		KEY_F8:
			diagnostic_export_requested.emit()


func cancel_held_input() -> void:
	_keyboard_reel_active = false
	_touch_reel_active = false
	_publish_reel_state()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or \
			what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		cancel_held_input()


func _publish_reel_state() -> void:
	var next_active := _keyboard_reel_active or _touch_reel_active
	if next_active == _reel_active:
		return
	_reel_active = next_active
	reel_changed.emit(_reel_active)
