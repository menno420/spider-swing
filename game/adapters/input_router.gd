extends Node
class_name InputRouter
## Captures render-time input and emits intent without mutating simulation.

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

var _reel_touch_ids: Dictionary = {}
var _reel_active: bool = false
var _debug_visible: bool = false
var _keyboard_reel_active: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true)
	set_process(true)


func _process(_delta: float) -> void:
	var keyboard_reel := Input.is_action_pressed("reel_in")
	if keyboard_reel != _keyboard_reel_active:
		_keyboard_reel_active = keyboard_reel
		_publish_reel_state()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_screen_touch(event)
		return

	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			if not _handle_ui_press(mouse.position):
				web_tapped.emit(mouse.position)
		return

	if event.is_action_pressed("web_action"):
		web_tapped.emit(get_viewport().get_mouse_position())
	elif event.is_action_pressed("restart_run"):
		restart_requested.emit()
	elif event.is_action_pressed("toggle_debug"):
		_debug_visible = not _debug_visible
		debug_toggle_requested.emit()
	elif event.is_action_pressed("pause"):
		debug_pause_requested.emit()

	if event is InputEventKey:
		_handle_debug_key(event as InputEventKey)


func _handle_screen_touch(touch: InputEventScreenTouch) -> void:
	if touch.pressed:
		if LabLayout.reel_rect(_viewport_size()).has_point(touch.position):
			_reel_touch_ids[touch.index] = true
			_publish_reel_state()
			return
		if _handle_ui_press(touch.position):
			return
		web_tapped.emit(touch.position)
		return

	if _reel_touch_ids.erase(touch.index):
		_publish_reel_state()


func _handle_ui_press(position: Vector2) -> bool:
	var viewport_size := _viewport_size()
	if LabLayout.debug_toggle_rect(viewport_size).has_point(position):
		_debug_visible = not _debug_visible
		debug_toggle_requested.emit()
		return true
	if not _debug_visible:
		return false

	for index in range(SwingConfig.preset_names().size()):
		if LabLayout.preset_rect(index).has_point(position):
			preset_requested.emit(SwingConfig.preset_names()[index])
			return true
	if LabLayout.tuning_previous_rect().has_point(position):
		tuning_parameter_requested.emit(-1)
		return true
	if LabLayout.tuning_next_rect().has_point(position):
		tuning_parameter_requested.emit(1)
		return true
	if LabLayout.tuning_minus_rect().has_point(position):
		tuning_adjustment_requested.emit(-1.0)
		return true
	if LabLayout.tuning_plus_rect().has_point(position):
		tuning_adjustment_requested.emit(1.0)
		return true

	for index in range(6):
		if not LabLayout.utility_rect(index).has_point(position):
			continue
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
		return true
	return false


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
	_reel_touch_ids.clear()
	_keyboard_reel_active = false
	_publish_reel_state()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or \
			what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		cancel_held_input()


func _publish_reel_state() -> void:
	var next_active := not _reel_touch_ids.is_empty() or _keyboard_reel_active
	if next_active == _reel_active:
		return
	_reel_active = next_active
	reel_changed.emit(_reel_active)


func _viewport_size() -> Vector2:
	var size := get_viewport().get_visible_rect().size
	return LabLayout.REFERENCE_SIZE if size.x <= 0.0 or size.y <= 0.0 else size
