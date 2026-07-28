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
signal restart_requested
signal debug_toggle_requested
signal debug_pause_requested
signal debug_frame_step_requested
signal slow_motion_requested
signal preset_requested(name: StringName)
signal tuning_parameter_requested(direction: int)
signal tuning_adjustment_requested(direction: float)
signal recording_requested
signal replay_requested
signal diagnostic_export_requested

var _reel_active: bool = false
var _touch_reel_active: bool = false
var _debug_visible: bool = false
var _keyboard_reel_active: bool = false
var _touch_surface: Control
var _reel_button: Button
var _debug_button: Button
var _debug_controls: Array[Control] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	install_touch_surface()
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
			web_tapped.emit(touch.position)
		return

	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			web_tapped.emit(mouse.position)
		return

	if event.is_action_pressed("web_action"):
		web_tapped.emit(get_viewport().get_mouse_position())
	elif event.is_action_pressed("restart_run"):
		restart_requested.emit()
	elif event.is_action_pressed("toggle_debug"):
		_toggle_debug_from_touch()
	elif event.is_action_pressed("pause"):
		debug_pause_requested.emit()

	if event is InputEventKey:
		_handle_debug_key(event as InputEventKey)


func install_touch_surface() -> void:
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

	_reel_button = _make_anchored_button(
		&"Reel",
		Vector2.ONE,
		Rect2(-184.0, -184.0, 148.0, 148.0),
	)
	_reel_button.button_down.connect(_set_touch_reel.bind(true))
	_reel_button.button_up.connect(_set_touch_reel.bind(false))

	_debug_button = _make_anchored_button(
		&"Debug",
		Vector2(1.0, 0.0),
		Rect2(-88.0, 24.0, 64.0, 52.0),
	)
	_debug_button.pressed.connect(_toggle_debug_from_touch)

	for index in range(SwingConfig.preset_names().size()):
		var preset_name := SwingConfig.preset_names()[index]
		var button := _make_fixed_button(
			StringName("Preset%d" % index),
			LabLayout.preset_rect(index),
		)
		button.pressed.connect(_emit_preset.bind(preset_name))
		_debug_controls.append(button)

	var previous := _make_fixed_button(
		&"TuningPrevious", LabLayout.tuning_previous_rect())
	previous.pressed.connect(_emit_tuning_parameter.bind(-1))
	_debug_controls.append(previous)
	var minus := _make_fixed_button(&"TuningMinus", LabLayout.tuning_minus_rect())
	minus.pressed.connect(_emit_tuning_adjustment.bind(-1.0))
	_debug_controls.append(minus)
	var plus := _make_fixed_button(&"TuningPlus", LabLayout.tuning_plus_rect())
	plus.pressed.connect(_emit_tuning_adjustment.bind(1.0))
	_debug_controls.append(plus)
	var next := _make_fixed_button(&"TuningNext", LabLayout.tuning_next_rect())
	next.pressed.connect(_emit_tuning_parameter.bind(1))
	_debug_controls.append(next)

	for index in range(6):
		var utility := _make_fixed_button(
			StringName("Utility%d" % index),
			LabLayout.utility_rect(index),
		)
		utility.pressed.connect(_emit_utility.bind(index))
		_debug_controls.append(utility)
	_set_debug_controls_visible(false)


func hud_button(button_name: StringName) -> Button:
	if _touch_surface == null:
		return null
	return _touch_surface.get_node_or_null(NodePath(str(button_name))) as Button


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
	_debug_visible = not _debug_visible
	_set_debug_controls_visible(_debug_visible)
	debug_toggle_requested.emit()


func _set_debug_controls_visible(visible: bool) -> void:
	for control: Control in _debug_controls:
		control.visible = visible


func _emit_preset(preset_name: StringName) -> void:
	preset_requested.emit(preset_name)


func _emit_tuning_parameter(direction: int) -> void:
	tuning_parameter_requested.emit(direction)


func _emit_tuning_adjustment(direction: float) -> void:
	tuning_adjustment_requested.emit(direction)


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
	if not key.pressed or key.echo:
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
