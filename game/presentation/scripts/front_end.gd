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
var _garage: Control
var _shop: Control
var _creator: Control
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
var _garage_name: Label
var _garage_role: Label
var _garage_description: Label
var _garage_tradeoff: Label
var _garage_stats: Label
var _garage_style_picker: OptionButton
var _garage_web_picker: OptionButton
var _profile_buttons: Dictionary = {}
var _shop_flies: Label
var _shop_title: Label
var _shop_description: Label
var _upgrade_buttons: Dictionary = {}
var _creator_slot_buttons: Array[Button] = []
var _buttons: Dictionary = {}
var _interface_ready: bool = false
var _syncing_settings: bool = false
var _syncing_progress: bool = false
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
	_build_garage()
	_build_shop()
	_build_creator()


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
	menu.add_theme_constant_override("separation", 10)
	_fill_with_margin(menu, card, 24.0)
	menu.add_child(_section_label("READY TO SWING?"))
	menu.add_child(_paragraph(
		"Learn the controls, choose your swing feel, then take the laboratory "
		+ "as far as you can.",
	))
	var play := _button(&"Play", "PLAY", GREEN, 68.0)
	play.pressed.connect(_on_play)
	menu.add_child(play)
	var routes := GridContainer.new()
	routes.columns = 2
	routes.add_theme_constant_override("h_separation", 10)
	routes.add_theme_constant_override("v_separation", 10)
	menu.add_child(routes)
	var garage := _button(&"Garage", "GARAGE", YELLOW, 54.0)
	garage.pressed.connect(_on_garage)
	garage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	routes.add_child(garage)
	var shop := _button(&"Shop", "SHOP", GREEN, 54.0)
	shop.pressed.connect(_on_shop)
	shop.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	routes.add_child(shop)
	var tutorial := _button(&"Tutorial", "TUTORIAL", CYAN, 54.0)
	tutorial.pressed.connect(_on_tutorial)
	tutorial.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	routes.add_child(tutorial)
	var creator := _button(&"Creator", "COURSE LAB", ORANGE, 54.0)
	creator.pressed.connect(_on_creator)
	creator.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	routes.add_child(creator)
	var settings := _button(&"Settings", "SETTINGS", ORANGE, 54.0)
	settings.pressed.connect(_on_settings)
	menu.add_child(settings)
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
	_place(card, _settings, 0.16, 0.05, 0.84, 0.96)
	var scroll := ScrollContainer.new()
	scroll.name = "SettingsScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.follow_focus = true
	_fill_with_margin(scroll, card, 28.0)
	var content := VBoxContainer.new()
	content.name = "SettingsContent"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 20)
	scroll.add_child(content)
	content.add_child(_section_label("SETTINGS"))
	var title := _label("Make the laboratory fit how you play.", 34, INK)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(title)
	content.add_child(_paragraph(
		"Every option below affects the current build and is restored the next "
		+ "time the game opens.",
	))
	content.add_child(_setting_heading("SWING FEEL"))
	_preset_picker = OptionButton.new()
	_preset_picker.name = "SwingPreset"
	_preset_picker.custom_minimum_size.y = 68.0
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
	actions.add_theme_constant_override("separation", 18)
	content.add_child(actions)
	var reset := _button(&"ResetSettings", "RESET DEFAULTS", MUTED, 68.0)
	reset.pressed.connect(_on_reset_settings)
	reset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(reset)
	var play := _button(&"SettingsPlay", "PLAY WITH THESE", GREEN, 68.0)
	play.pressed.connect(_on_play)
	play.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(play)
	var scroll_hint := _label("Swipe up or down for every option.", 17, CYAN)
	scroll_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scroll_hint.custom_minimum_size.y = 42.0
	content.add_child(scroll_hint)


func _build_garage() -> void:
	_garage = _full_screen(&"Garage")
	var back := _button(&"GarageBack", "‹  HOME", CYAN, 50.0)
	back.pressed.connect(_on_home)
	_place(back, _garage, 0.025, 0.035, 0.16, 0.11)
	var heading := _label("SPIDER GARAGE", 34, INK)
	_place(heading, _garage, 0.20, 0.035, 0.58, 0.12)

	var roster_card := _panel(PANEL)
	_place(roster_card, _garage, 0.04, 0.15, 0.49, 0.93)
	var roster := VBoxContainer.new()
	roster.add_theme_constant_override("separation", 14)
	_fill_with_margin(roster, roster_card, 24.0)
	roster.add_child(_section_label("CHOOSE A HANDLING STYLE"))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	roster.add_child(grid)
	for spider_id: StringName in SpiderCatalog.ALL_IDS:
		var item := SpiderCatalog.profile(spider_id)
		var button := _button(
			StringName("Spider%s" % str(spider_id).capitalize()),
			str(item["name"]).to_upper(),
			YELLOW,
			76.0,
		)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_spider_profile.bind(spider_id))
		grid.add_child(button)
		_profile_buttons[spider_id] = button
	roster.add_child(_setting_description(
		"All five candidates are open in this comparison build. Each changes the "
		+ "same tested motor through explicit trade-offs."))

	var detail_card := _panel(PANEL)
	_place(detail_card, _garage, 0.51, 0.15, 0.96, 0.93)
	var detail := VBoxContainer.new()
	detail.add_theme_constant_override("separation", 10)
	_fill_with_margin(detail, detail_card, 24.0)
	_garage_role = _section_label("")
	detail.add_child(_garage_role)
	_garage_name = _label("", 32, INK)
	detail.add_child(_garage_name)
	_garage_description = _setting_description("")
	detail.add_child(_garage_description)
	_garage_tradeoff = _setting_description("")
	_garage_tradeoff.add_theme_color_override("font_color", YELLOW)
	detail.add_child(_garage_tradeoff)
	_garage_stats = _label("", 17, CYAN)
	_garage_stats.custom_minimum_size.y = 72.0
	detail.add_child(_garage_stats)
	var pickers := HBoxContainer.new()
	pickers.add_theme_constant_override("separation", 12)
	detail.add_child(pickers)
	_garage_style_picker = OptionButton.new()
	_garage_style_picker.name = "SpiderStylePicker"
	_garage_style_picker.custom_minimum_size.y = 56.0
	_garage_style_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for label: String in ["Garden body", "Amber body", "Comet body"]:
		_garage_style_picker.add_item(label)
	_garage_style_picker.item_selected.connect(_on_style_selected)
	_style_option_button(_garage_style_picker)
	pickers.add_child(_garage_style_picker)
	_garage_web_picker = OptionButton.new()
	_garage_web_picker.name = "WebVariantPicker"
	_garage_web_picker.custom_minimum_size.y = 56.0
	_garage_web_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for label: String in ["Classic silk", "Dew silk", "Ember silk"]:
		_garage_web_picker.add_item(label)
	_garage_web_picker.item_selected.connect(_on_web_variant_selected)
	_style_option_button(_garage_web_picker)
	pickers.add_child(_garage_web_picker)
	var play := _button(&"GaragePlay", "PLAY THIS SPIDER", GREEN, 64.0)
	play.pressed.connect(_on_play)
	detail.add_child(play)


func _build_shop() -> void:
	_shop = _full_screen(&"Shop")
	var back := _button(&"ShopBack", "‹  HOME", CYAN, 50.0)
	back.pressed.connect(_on_home)
	_place(back, _shop, 0.025, 0.035, 0.16, 0.11)
	var card := _panel(PANEL)
	_place(card, _shop, 0.14, 0.08, 0.86, 0.94)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	_fill_with_margin(content, card, 28.0)
	var header := HBoxContainer.new()
	content.add_child(header)
	_shop_title = _label("", 32, INK)
	_shop_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_shop_title)
	_shop_flies = _label("", 22, YELLOW)
	header.add_child(_shop_flies)
	content.add_child(_paragraph(
		"Prototype upgrades use flies collected in play. No store purchase or "
		+ "real-money entitlement is connected in this build."))
	var upgrades := VBoxContainer.new()
	upgrades.add_theme_constant_override("separation", 12)
	content.add_child(upgrades)
	for upgrade_item: Dictionary in SpiderCatalog.UPGRADES:
		var upgrade_id := StringName(upgrade_item["id"])
		var button := _button(
			StringName("Upgrade%s" % str(upgrade_id).to_pascal_case()),
			"",
			GREEN,
			78.0,
		)
		button.pressed.connect(_on_upgrade.bind(upgrade_id))
		upgrades.add_child(button)
		_upgrade_buttons[upgrade_id] = button
	_shop_description = _setting_description("")
	_shop_description.custom_minimum_size.y = 56.0
	content.add_child(_shop_description)
	var garage := _button(&"ShopGarage", "CHANGE SPIDER", CYAN, 58.0)
	garage.pressed.connect(_on_garage)
	content.add_child(garage)


func _build_creator() -> void:
	_creator = _full_screen(&"Creator")
	var back := _button(&"CreatorBack", "‹  HOME", CYAN, 50.0)
	back.pressed.connect(_on_home)
	_place(back, _creator, 0.025, 0.035, 0.16, 0.11)
	var card := _panel(PANEL)
	_place(card, _creator, 0.12, 0.08, 0.88, 0.94)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	_fill_with_margin(content, card, 28.0)
	content.add_child(_section_label("COURSE LAB · CREATOR FOUNDATION"))
	content.add_child(_paragraph(
		"Tap each slot to cycle EMPTY → LEAF → POD → VINE → GATE. "
		+ "PLAYTEST repeats the saved six-piece sequence after the opening swing."))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	content.add_child(grid)
	for index in range(PlayerProgress.DEFAULT_CREATOR_PATTERN.size()):
		var button := _button(
			StringName("CourseSlot%d" % index),
			"",
			ORANGE,
			82.0,
		)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_creator_slot.bind(index))
		grid.add_child(button)
		_creator_slot_buttons.append(button)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 14)
	content.add_child(actions)
	var clear := _button(&"CreatorClear", "CLEAR", MUTED, 62.0)
	clear.pressed.connect(_on_creator_clear)
	clear.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(clear)
	var play := _button(&"CreatorPlay", "PLAYTEST COURSE", GREEN, 62.0)
	play.pressed.connect(_on_creator_play)
	play.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(play)
	content.add_child(_setting_description(
		"This is a deterministic local prototype. Sharing, moderation, and an "
		+ "online level browser remain later work after the swing is approved."))


func _render() -> void:
	if _state == null:
		return
	_home.visible = _state.screen == FrontEndState.Screen.HOME
	_tutorial.visible = _state.screen == FrontEndState.Screen.TUTORIAL
	_settings.visible = _state.screen == FrontEndState.Screen.SETTINGS
	_garage.visible = _state.screen == FrontEndState.Screen.GARAGE
	_shop.visible = _state.screen == FrontEndState.Screen.SHOP
	_creator.visible = _state.screen == FrontEndState.Screen.CREATOR
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
	_syncing_progress = true
	_render_garage()
	_render_shop()
	_render_creator()
	_syncing_progress = false
	queue_redraw()


func _render_garage() -> void:
	var selected := _state.progress.selected_spider_id
	var item := SpiderCatalog.profile(selected)
	for spider_id: StringName in _profile_buttons:
		var button: Button = _profile_buttons[spider_id]
		var profile_item := SpiderCatalog.profile(spider_id)
		button.text = "%s%s" % [
			"✓ " if spider_id == selected else "",
			str(profile_item["name"]).to_upper(),
		]
	_garage_role.text = str(item["role"])
	_garage_name.text = str(item["name"])
	_garage_description.text = str(item["description"])
	_garage_tradeoff.text = "TRADE-OFF · %s" % item["tradeoff"]
	var preview := SwingConfig.from_preset(SwingConfig.PRESET_BALANCED)
	SpiderCatalog.apply_to_config(preview, _state.progress)
	var stats_format := (
		"HITBOX %.1f px  ·  GRAVITY %.0f  ·  REEL %.0f px/s%s\n"
		+ "BURST %.0f%%  ·  MINIMUM %.0f px%s"
	)
	_garage_stats.text = stats_format % [
			preview.player_collision_radius,
			preview.gravity,
			preview.reel_retraction_rate,
			(
				"  ·  GLIDE %.2f s" % preview.glide_duration
				if preview.glide_duration > 0.0
				else ""
			),
			preview.burst_distance_fraction * 100.0,
			preview.burst_minimum_distance,
			(
				"  ·  IMPACT SHELL"
				if preview.surface_bounce_enabled
				else ""
			),
		]
	_garage_style_picker.selected = PlayerProgress.ALL_STYLES.find(
		_state.progress.selected_spider_style)
	for index in range(PlayerProgress.ALL_STYLES.size()):
		_garage_style_picker.get_popup().set_item_disabled(
			index,
			PlayerProgress.ALL_STYLES[index] not in \
				_state.progress.unlocked_spider_styles,
		)
	_garage_web_picker.selected = PlayerProgress.ALL_WEB_VARIANTS.find(
		_state.progress.selected_web_variant)


func _render_shop() -> void:
	var selected := _state.progress.selected_spider_id
	var profile_item := SpiderCatalog.profile(selected)
	_shop_title.text = "%s UPGRADES" % str(profile_item["name"]).to_upper()
	_shop_flies.text = "%d FLIES AVAILABLE" % _state.progress.spendable_flies
	for upgrade_id: StringName in _upgrade_buttons:
		(_upgrade_buttons[upgrade_id] as Button).visible = false
	var descriptions := PackedStringArray()
	for upgrade_item: Dictionary in SpiderCatalog.upgrades_for(selected):
		var upgrade_id := StringName(upgrade_item["id"])
		var button: Button = _upgrade_buttons[upgrade_id]
		var level := _state.progress.upgrade_level(upgrade_id)
		var maximum := level >= SpiderCatalog.MAX_UPGRADE_LEVEL
		var cost := SpiderCatalog.cost_for_level(level)
		button.visible = true
		button.disabled = maximum or _state.progress.spendable_flies < cost
		button.text = (
			"%s  ·  LEVEL %d/%d  ·  %s"
			% [
				str(upgrade_item["name"]).to_upper(),
				level,
				SpiderCatalog.MAX_UPGRADE_LEVEL,
				"MAXIMUM" if maximum else "%d FLIES" % cost,
			]
		)
		descriptions.append(
			"%s: %s" % [upgrade_item["name"], upgrade_item["description"]])
	_shop_description.text = "\n".join(descriptions)


func _render_creator() -> void:
	for index in range(_creator_slot_buttons.size()):
		var piece := _state.progress.creator_pattern[index]
		_creator_slot_buttons[index].text = "%02d · %s" % [
			index + 1,
			_creator_piece_label(piece),
		]


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


func _on_garage() -> void:
	if _state != null:
		_state.show_garage()


func _on_shop() -> void:
	if _state != null:
		_state.show_shop()


func _on_creator() -> void:
	if _state != null:
		_state.show_creator()


func _on_spider_profile(spider_id: StringName) -> void:
	if _state != null:
		_state.request_spider_profile(spider_id)


func _on_style_selected(index: int) -> void:
	if _state == null or _syncing_progress:
		return
	_state.request_spider_style(
		PlayerProgress.ALL_STYLES[clampi(
			index,
			0,
			PlayerProgress.ALL_STYLES.size() - 1,
		)])


func _on_web_variant_selected(index: int) -> void:
	if _state == null or _syncing_progress:
		return
	_state.request_web_variant(
		PlayerProgress.ALL_WEB_VARIANTS[clampi(
			index,
			0,
			PlayerProgress.ALL_WEB_VARIANTS.size() - 1,
		)])


func _on_upgrade(upgrade_id: StringName) -> void:
	if _state != null:
		_state.request_upgrade_purchase(upgrade_id)


func _on_creator_slot(index: int) -> void:
	if _state != null:
		_state.request_creator_piece(index)


func _on_creator_clear() -> void:
	if _state != null:
		_state.request_creator_clear()


func _on_creator_play() -> void:
	if _state != null:
		_state.request_creator_play()


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


func _creator_piece_label(piece: StringName) -> String:
	match piece:
		&"leaf":
			return "LEAF CLUSTER"
		&"pod":
			return "SEED POD"
		&"vine":
			return "VINE FORK"
		&"gate":
			return "SPLIT ROOT GATE"
		_:
			return "EMPTY"


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
	var label := _label(text_value, 21, MUTED)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _section_label(text_value: String) -> Label:
	var label := _label(text_value, 16, CYAN)
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_color_override("font_outline_color", DEEP)
	return label


func _setting_heading(text_value: String) -> Label:
	var label := _label(text_value, 18, CYAN)
	label.custom_minimum_size.y = 36.0
	return label


func _setting_description(text_value: String) -> Label:
	var label := _label(text_value, 18, MUTED)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.y = 48.0
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
	toggle.custom_minimum_size.y = 58.0
	toggle.add_theme_font_size_override("font_size", 23)
	toggle.add_theme_color_override("font_color", INK)
	return toggle


func _style_option_button(option: OptionButton) -> void:
	option.add_theme_font_size_override("font_size", 22)
	option.add_theme_color_override("font_color", INK)
	option.add_theme_stylebox_override(
		"normal", _button_style(PANEL_SOFT, ORANGE))
