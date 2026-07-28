extends Control
class_name FrontEndView
## Read-only front-end presentation bound to FrontEndState.

const DEEP := Color("07141d")
const PANEL := Color("0b202b")
const PANEL_SOFT := Color("102f3a")
const INK := Color("d9fbff")
const MUTED := Color("8ba9b5")
const CYAN := Color("4de8ee")
const GREEN := Color("73e0a4")
const ORANGE := Color("f28c45")
const YELLOW := Color("ffd166")

var _state: FrontEndState
var _home: Control
var _tutorial: Control
var _settings: Control
var _tutorial_preview: TutorialPreview
var _tutorial_kicker: Label
var _tutorial_title: Label
var _tutorial_body: Label
var _tutorial_tip: Label
var _tutorial_progress: Label
var _tutorial_next: Button
var _preset_picker: OptionButton
var _hints_toggle: CheckButton
var _motion_toggle: CheckButton
var _debug_toggle: CheckButton
var _buttons: Dictionary = {}
var _interface_ready: bool = false
var _syncing_settings: bool = false
var _elapsed: float = 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ensure_interface()
	set_process(true)
	queue_redraw()


func bind_state(state: FrontEndState) -> void:
	ensure_interface()
	if _state != null and _state.changed.is_connected(_render):
		_state.changed.disconnect(_render)
	_state = state
	_state.changed.connect(_render)
	_render()


func ensure_interface() -> void:
	if _interface_ready:
		return
	_interface_ready = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_home()
	_build_tutorial()
	_build_settings()


func front_end_button(button_name: StringName) -> Button:
	ensure_interface()
	return _buttons.get(button_name, null) as Button


func _process(delta: float) -> void:
	if _state == null or _state.settings.reduced_motion:
		return
	_elapsed += delta
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), DEEP)
	var drift := 0.0
	if _state == null or not _state.settings.reduced_motion:
		drift = sin(_elapsed * 0.22) * 42.0
	for index in range(7):
		var center := Vector2(
			size.x * (0.08 + float(index) * 0.17) + drift * float(index % 2),
			size.y * (0.14 + float(index % 3) * 0.31),
		)
		draw_circle(center, 110.0 + float(index % 3) * 46.0,
			Color(0.12, 0.38, 0.38, 0.13))
	draw_line(Vector2(0.0, size.y * 0.88),
		Vector2(size.x, size.y * 0.88), Color(CYAN, 0.16), 2.0)


func _build_home() -> void:
	_home = _full_screen(&"Home")

	var eyebrow := _label("PHASE 0 · SWING LABORATORY", 18, CYAN)
	_place(eyebrow, _home, 0.055, 0.12, 0.58, 0.18)
	var title := _label("SPIDER\nSWING", 72, INK)
	title.add_theme_constant_override("line_spacing", -18)
	_place(title, _home, 0.055, 0.19, 0.58, 0.46)
	var subtitle := _label(
		"Momentum is the move.\nChoose an anchor. Commit to the arc.",
		22,
		MUTED,
	)
	_place(subtitle, _home, 0.06, 0.51, 0.55, 0.64)

	var version := _label(
		"BUILD %s" % ProjectSettings.get_setting(
			"application/config/version", "unknown"),
		14,
		MUTED,
	)
	_place(version, _home, 0.06, 0.83, 0.46, 0.88)

	var card := _panel(PANEL)
	_place(card, _home, 0.62, 0.14, 0.94, 0.86)
	var menu := VBoxContainer.new()
	menu.add_theme_constant_override("separation", 16)
	_fill_with_margin(menu, card, 30.0)
	menu.add_child(_section_label("READY TO SWING?"))
	menu.add_child(_paragraph(
		"Learn the controls, choose your swing feel, then take the laboratory "
		+ "as far as you can.",
	))
	menu.add_spacer(false)
	var play := _button(&"Play", "PLAY", GREEN, 76.0)
	play.pressed.connect(_on_play)
	menu.add_child(play)
	var tutorial := _button(&"Tutorial", "TUTORIAL", CYAN, 66.0)
	tutorial.pressed.connect(_on_tutorial)
	menu.add_child(tutorial)
	var settings := _button(&"Settings", "SETTINGS", ORANGE, 66.0)
	settings.pressed.connect(_on_settings)
	menu.add_child(settings)
	menu.add_spacer(false)
	var note := _label("Your choices save automatically.", 14, MUTED)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu.add_child(note)


func _build_tutorial() -> void:
	_tutorial = _full_screen(&"Tutorial")
	var back := _button(&"TutorialBack", "‹  HOME", CYAN, 50.0)
	back.pressed.connect(_on_home)
	_place(back, _tutorial, 0.025, 0.035, 0.16, 0.11)

	_tutorial_preview = TutorialPreview.new()
	_tutorial_preview.name = "AnimatedMechanicsPreview"
	_place(_tutorial_preview, _tutorial, 0.05, 0.18, 0.56, 0.78)

	var copy_card := _panel(PANEL)
	_place(copy_card, _tutorial, 0.60, 0.14, 0.95, 0.8)
	var copy := VBoxContainer.new()
	copy.add_theme_constant_override("separation", 16)
	_fill_with_margin(copy, copy_card, 30.0)
	_tutorial_kicker = _section_label("")
	copy.add_child(_tutorial_kicker)
	_tutorial_title = _label("", 36, INK)
	_tutorial_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.add_child(_tutorial_title)
	_tutorial_body = _paragraph("")
	_tutorial_body.custom_minimum_size.y = 126.0
	copy.add_child(_tutorial_body)
	var tip_panel := _panel(Color(0.05, 0.18, 0.22, 0.95), 12)
	tip_panel.custom_minimum_size.y = 90.0
	copy.add_child(tip_panel)
	_tutorial_tip = _label("", 17, YELLOW)
	_tutorial_tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_fill_with_margin(_tutorial_tip, tip_panel, 18.0)

	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 14)
	_place(nav, _tutorial, 0.05, 0.84, 0.95, 0.95)
	var previous := _button(&"TutorialPrevious", "PREVIOUS", MUTED, 60.0)
	previous.pressed.connect(_on_tutorial_previous)
	previous.custom_minimum_size.x = 190.0
	nav.add_child(previous)
	_tutorial_progress = _label("", 17, MUTED)
	_tutorial_progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tutorial_progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nav.add_child(_tutorial_progress)
	var practice := _button(&"TutorialPractice", "PRACTICE NOW", ORANGE, 60.0)
	practice.pressed.connect(_on_play)
	practice.custom_minimum_size.x = 210.0
	nav.add_child(practice)
	_tutorial_next = _button(&"TutorialNext", "NEXT", GREEN, 60.0)
	_tutorial_next.pressed.connect(_on_tutorial_next)
	_tutorial_next.custom_minimum_size.x = 190.0
	nav.add_child(_tutorial_next)


func _build_settings() -> void:
	_settings = _full_screen(&"Settings")
	var back := _button(&"SettingsBack", "‹  HOME", CYAN, 50.0)
	back.pressed.connect(_on_home)
	_place(back, _settings, 0.025, 0.035, 0.16, 0.11)

	var card := _panel(PANEL)
	_place(card, _settings, 0.22, 0.08, 0.78, 0.92)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 15)
	_fill_with_margin(content, card, 34.0)
	content.add_child(_section_label("SETTINGS"))
	content.add_child(_label("Make the laboratory fit how you play.", 28, INK))
	content.add_child(_paragraph(
		"Every option below affects the current build and is restored the next "
		+ "time the game opens.",
	))
	content.add_child(_setting_heading("SWING FEEL"))
	_preset_picker = OptionButton.new()
	_preset_picker.name = "SwingPreset"
	_preset_picker.custom_minimum_size.y = 58.0
	_preset_picker.add_item("Balanced · steady and readable")
	_preset_picker.add_item("Weighty · heavier momentum")
	_preset_picker.add_item("Agile · quicker corrections")
	_preset_picker.item_selected.connect(_on_preset_selected)
	_style_option_button(_preset_picker)
	content.add_child(_preset_picker)
	content.add_child(_setting_description(
		"This selects the active Phase 0 candidate when Play starts."))

	_hints_toggle = _toggle("Show control hints")
	_hints_toggle.toggled.connect(_on_hints_toggled)
	content.add_child(_hints_toggle)
	content.add_child(_setting_description(
		"Shows attach, release, and feedback guidance during a run."))

	_motion_toggle = _toggle("Reduced motion")
	_motion_toggle.toggled.connect(_on_motion_toggled)
	content.add_child(_motion_toggle)
	content.add_child(_setting_description(
		"Stops decorative menu motion and tutorial animation, and removes "
		+ "camera easing during play."))

	_debug_toggle = _toggle("Show laboratory debug tools")
	_debug_toggle.toggled.connect(_on_debug_toggled)
	content.add_child(_debug_toggle)
	content.add_child(_setting_description(
		"Keeps DEBUG available for tuning and diagnostics."))

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 14)
	content.add_child(actions)
	var reset := _button(&"ResetSettings", "RESET DEFAULTS", MUTED, 56.0)
	reset.pressed.connect(_on_reset_settings)
	reset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(reset)
	var play := _button(&"SettingsPlay", "PLAY WITH THESE", GREEN, 56.0)
	play.pressed.connect(_on_play)
	play.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(play)


func _render() -> void:
	if _state == null:
		return
	_home.visible = _state.screen == FrontEndState.Screen.HOME
	_tutorial.visible = _state.screen == FrontEndState.Screen.TUTORIAL
	_settings.visible = _state.screen == FrontEndState.Screen.SETTINGS
	if _tutorial.visible:
		var step := _state.current_tutorial_step()
		_tutorial_kicker.text = str(step.get("kicker", ""))
		_tutorial_title.text = str(step.get("title", ""))
		_tutorial_body.text = str(step.get("body", ""))
		_tutorial_tip.text = "TIP · %s" % step.get("tip", "")
		_tutorial_progress.text = "%d / %d" % [
			_state.tutorial_index + 1,
			FrontEndState.TUTORIAL_STEPS.size(),
		]
		_tutorial_next.text = (
			"START" if _state.tutorial_index ==
				FrontEndState.TUTORIAL_STEPS.size() - 1
			else "NEXT"
		)
		front_end_button(&"TutorialPrevious").disabled = \
			_state.tutorial_index == 0
		_tutorial_preview.configure(
			_state.tutorial_index,
			_state.settings.reduced_motion,
		)
	_syncing_settings = true
	_preset_picker.selected = _preset_index(_state.settings.swing_preset)
	_hints_toggle.button_pressed = _state.settings.show_control_hints
	_motion_toggle.button_pressed = _state.settings.reduced_motion
	_debug_toggle.button_pressed = _state.settings.show_debug_tools
	_syncing_settings = false
	queue_redraw()


func _on_play() -> void:
	if _state != null:
		_state.request_play()


func _on_home() -> void:
	if _state != null:
		_state.show_home()


func _on_tutorial() -> void:
	if _state != null:
		_state.show_tutorial()


func _on_settings() -> void:
	if _state != null:
		_state.show_settings()


func _on_tutorial_previous() -> void:
	if _state != null:
		_state.previous_tutorial_step()


func _on_tutorial_next() -> void:
	if _state != null:
		_state.next_tutorial_step()


func _on_preset_selected(index: int) -> void:
	if _state == null or _syncing_settings:
		return
	_state.set_swing_preset([
		SwingConfig.PRESET_BALANCED,
		SwingConfig.PRESET_WEIGHTY,
		SwingConfig.PRESET_AGILE,
	][clampi(index, 0, 2)])


func _on_hints_toggled(enabled: bool) -> void:
	if _state != null and not _syncing_settings:
		_state.set_control_hints(enabled)


func _on_motion_toggled(enabled: bool) -> void:
	if _state != null and not _syncing_settings:
		_state.set_reduced_motion(enabled)


func _on_debug_toggled(enabled: bool) -> void:
	if _state != null and not _syncing_settings:
		_state.set_debug_tools(enabled)


func _on_reset_settings() -> void:
	if _state != null:
		_state.reset_settings()


func _preset_index(preset: StringName) -> int:
	match preset:
		SwingConfig.PRESET_WEIGHTY:
			return 1
		SwingConfig.PRESET_AGILE:
			return 2
		_:
			return 0


func _full_screen(node_name: StringName) -> Control:
	var control := Control.new()
	control.name = str(node_name)
	control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(control)
	return control


func _place(
	node: Control,
	parent: Control,
	left: float,
	top: float,
	right: float,
	bottom: float,
) -> void:
	node.anchor_left = left
	node.anchor_top = top
	node.anchor_right = right
	node.anchor_bottom = bottom
	node.offset_left = 0.0
	node.offset_top = 0.0
	node.offset_right = 0.0
	node.offset_bottom = 0.0
	parent.add_child(node)


func _fill_with_margin(node: Control, parent: Control, margin: float) -> void:
	node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	node.offset_left = margin
	node.offset_top = margin
	node.offset_right = -margin
	node.offset_bottom = -margin
	parent.add_child(node)


func _panel(color: Color, radius: int = 22) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(CYAN, 0.28)
	style.set_border_width_all(2)
	style.set_corner_radius_all(radius)
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _label(text_value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _paragraph(text_value: String) -> Label:
	var label := _label(text_value, 18, MUTED)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _section_label(text_value: String) -> Label:
	var label := _label(text_value, 16, CYAN)
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_color_override("font_outline_color", DEEP)
	return label


func _setting_heading(text_value: String) -> Label:
	var label := _label(text_value, 15, CYAN)
	label.custom_minimum_size.y = 30.0
	return label


func _setting_description(text_value: String) -> Label:
	var label := _label(text_value, 14, MUTED)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.y = 38.0
	return label


func _button(
	button_name: StringName,
	text_value: String,
	accent: Color,
	height: float,
) -> Button:
	var button := Button.new()
	button.name = str(button_name)
	button.text = text_value
	button.custom_minimum_size.y = height
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", INK)
	button.add_theme_color_override("font_pressed_color", DEEP)
	button.add_theme_stylebox_override("normal", _button_style(PANEL_SOFT, accent))
	button.add_theme_stylebox_override(
		"hover", _button_style(Color(0.08, 0.28, 0.32), accent))
	button.add_theme_stylebox_override("focus", _button_style(PANEL_SOFT, INK, 3))
	button.add_theme_stylebox_override("pressed", _button_style(accent, accent))
	button.add_theme_stylebox_override(
		"disabled", _button_style(Color(0.08, 0.12, 0.15), MUTED))
	_buttons[button_name] = button
	return button


func _button_style(
	fill: Color,
	border: Color,
	width: int = 2,
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(14)
	style.content_margin_left = 18.0
	style.content_margin_right = 18.0
	return style


func _toggle(text_value: String) -> CheckButton:
	var toggle := CheckButton.new()
	toggle.text = text_value
	toggle.custom_minimum_size.y = 46.0
	toggle.add_theme_font_size_override("font_size", 19)
	toggle.add_theme_color_override("font_color", INK)
	return toggle


func _style_option_button(option: OptionButton) -> void:
	option.add_theme_font_size_override("font_size", 18)
	option.add_theme_color_override("font_color", INK)
	option.add_theme_stylebox_override(
		"normal", _button_style(PANEL_SOFT, ORANGE))
