extends Control
class_name FrontEndView
## Read-only front-end presentation bound to FrontEndState.

const SpiderWebPanelScript = preload(
	"res://game/presentation/scripts/spider_web_panel.gd")

const DEEP := SpiderUiTheme.BACKGROUND
const PANEL := SpiderUiTheme.PANEL
const PANEL_SOFT := SpiderUiTheme.PANEL_SOFT
const INK := SpiderUiTheme.INK
const MUTED := SpiderUiTheme.MUTED
const CYAN := SpiderUiTheme.DEW
const GREEN := SpiderUiTheme.MOSS
const ORANGE := SpiderUiTheme.SAP
const YELLOW := SpiderUiTheme.AMBER
const SHOP_PROGRESSION_COPY := (
	"Five CORE tracks shape every spider consistently; two IDENTITY tracks "
	+ "reinforce its trade-off. Every fifth level through 40 applies the listed "
	+ "increase twice."
)

var _state: FrontEndState
var _home: Control
var _tutorial: Control
var _settings: Control
var _garage: Control
var _shop: Control
var _creator: Control
var _practice: Control
var _campaign: Control
var _debug_run_setup: Control
var _field_guide: Control
var _field_guide_back: Button
var _tutorial_preview: TutorialPreview
var _tutorial_kicker: Label
var _tutorial_title: Label
var _tutorial_body: Label
var _tutorial_tip: Label
var _tutorial_progress: Label
var _tutorial_next: Button
var _preset_buttons: Dictionary = {}
var _hints_toggle: CheckButton
var _motion_toggle: CheckButton
var _music_toggle: CheckButton
var _effects_toggle: CheckButton
var _haptics_toggle: CheckButton
var _debug_toggle: CheckButton
var _garage_name: Label
var _garage_role: Label
var _garage_spider_preview: TextureRect
var _garage_description: Label
var _garage_tradeoff: Label
var _garage_stats: Label
var _garage_inspiration: Label
var _garage_style_buttons: Dictionary = {}
var _garage_web_buttons: Dictionary = {}
var _garage_silk_preview: SilkPreview
var _garage_roster_panel: PanelContainer
var _garage_detail_panel: PanelContainer
var _profile_buttons: Dictionary = {}
var _shop_flies: Label
var _shop_title: Label
var _shop_spider_preview: TextureRect
var _shop_panel: PanelContainer
var _shop_description: Label
var _upgrade_buttons: Dictionary = {}
var _upgrade_rows: Dictionary = {}
var _upgrade_descriptions: Dictionary = {}
var _upgrade_milestones: Dictionary = {}
var _creator_slot_buttons: Array[Button] = []
var _practice_buttons: Dictionary = {}
var _campaign_buttons: Dictionary = {}
var _difficulty_buttons: Dictionary = {}
var _debug_run_route: Button
var _debug_run_distance_entry: LineEdit
var _debug_run_distance_value: Label
var _debug_trace_label: Label
var _debug_trace_watch: Button
var _debug_run_upgrade_value: Label
var _debug_bird_values: Dictionary = {}
var _buttons: Dictionary = {}
var _interface_ready: bool = false
var _syncing_settings: bool = false
var _syncing_progress: bool = false
var _syncing_debug_run_setup: bool = false
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
	theme = SpiderUiTheme.create_theme()
	_build_home()
	_build_tutorial()
	_build_settings()
	_build_garage()
	_build_shop()
	_build_creator()
	_build_practice()
	_build_campaign()
	_build_debug_run_setup()
	_build_field_guide()


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
		drift = sin(_elapsed * 0.22) * 28.0
	for index in range(6):
		var center := Vector2(
			size.x * (0.04 + float(index) * 0.20) + drift * float(index % 2),
			size.y * (0.12 + float(index % 3) * 0.34),
		)
		draw_circle(
			center,
			120.0 + float(index % 3) * 52.0,
			Color(0.16, 0.35, 0.20, 0.11),
		)
	var floor_y := size.y * 0.91
	draw_colored_polygon(PackedVector2Array([
		Vector2(0.0, floor_y),
		Vector2(size.x * 0.18, floor_y - 14.0),
		Vector2(size.x * 0.39, floor_y + 5.0),
		Vector2(size.x * 0.62, floor_y - 18.0),
		Vector2(size.x * 0.82, floor_y - 4.0),
		Vector2(size.x, floor_y - 20.0),
		Vector2(size.x, size.y),
		Vector2(0.0, size.y),
	]), Color(SpiderUiTheme.BARK, 0.56))
	_draw_corner_web(Vector2(size.x - 18.0, 18.0), -1.0, 250.0)
	_draw_corner_web(Vector2(18.0, size.y - 18.0), 1.0, 150.0, -1.0)


func _draw_corner_web(
	anchor: Vector2,
	x_direction: float,
	radius: float,
	y_direction: float = 1.0,
) -> void:
	var directions: Array[Vector2] = []
	for spoke_index in range(7):
		var progress := float(spoke_index) / 6.0
		var direction := Vector2(
			x_direction * cos(progress * PI * 0.5),
			y_direction * sin(progress * PI * 0.5),
		)
		directions.append(direction)
		draw_line(
			anchor,
			anchor + direction * radius,
			Color(SpiderUiTheme.SILK, 0.11),
			1.4,
			true,
		)
	for ring_index in range(1, 5):
		var ring_radius := radius * float(ring_index) / 5.0
		var points := PackedVector2Array()
		for direction: Vector2 in directions:
			points.append(anchor + direction * ring_radius)
		draw_polyline(
			points,
			Color(SpiderUiTheme.SILK, 0.09 + ring_index * 0.012),
			1.2,
			true,
		)


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
	card.name = "HomeWebPanel"
	_place(card, _home, 0.62, 0.14, 0.94, 0.86)
	var menu := VBoxContainer.new()
	menu.add_theme_constant_override("separation", 10)
	_fill_with_margin(menu, card, 24.0)
	menu.add_child(_section_label("READY TO SWING?"))
	# Eight routes leave this card tight; the intro carries the least weight,
	# so it gives up the height rather than the buttons shrinking.
	var intro := _paragraph(
		"Learn the controls, pick your swing feel, then go as far as you can.")
	intro.add_theme_font_size_override("font_size", 18)
	menu.add_child(intro)
	var play := _button(&"Play", "PLAY", GREEN, 68.0)
	play.pressed.connect(_on_play)
	menu.add_child(play)
	# Difficulty governs the standard PLAY run, so it is chosen here rather
	# than buried in Settings.
	menu.add_child(_section_label("DIFFICULTY"))
	var difficulty_row := GridContainer.new()
	difficulty_row.columns = 3
	difficulty_row.add_theme_constant_override("h_separation", 8)
	menu.add_child(difficulty_row)
	for mode: Dictionary in DifficultyCatalog.all_modes():
		var mode_id := StringName(mode["id"])
		var button := _button(
			StringName("Difficulty_%s" % mode_id),
			str(mode["name"]),
			CYAN,
			48.0,
		)
		button.pressed.connect(_on_difficulty.bind(mode_id))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		difficulty_row.add_child(button)
		_difficulty_buttons[mode_id] = button

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
	var practice := _button(&"Practice", "REGION PRACTICE", CYAN, 54.0)
	practice.pressed.connect(_on_practice)
	practice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	routes.add_child(practice)
	var campaign := _button(&"Campaign", "CAMPAIGN", ORANGE, 54.0)
	campaign.pressed.connect(_on_campaign)
	campaign.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	routes.add_child(campaign)
	var settings := _button(&"Settings", "SETTINGS", ORANGE, 54.0)
	settings.pressed.connect(_on_settings)
	settings.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	routes.add_child(settings)
	var field_guide := _button(&"FieldGuide", "FIELD GUIDE", YELLOW, 54.0)
	field_guide.pressed.connect(_on_field_guide.bind(FrontEndState.Screen.HOME))
	field_guide.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	routes.add_child(field_guide)
	_debug_run_route = _button(
		&"DebugRunSetup",
		"DEBUG TEST RUN",
		ORANGE,
		54.0,
	)
	_debug_run_route.pressed.connect(_on_debug_run_setup)
	_debug_run_route.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	routes.add_child(_debug_run_route)
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
	card.name = "SettingsWebPanel"
	_place(card, _settings, 0.16, 0.05, 0.84, 0.96)
	var scroll := ScrollContainer.new()
	scroll.name = "SettingsScroll"
	SpiderUiTheme.configure_touch_scroll(scroll)
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
	var preset_rail := HBoxContainer.new()
	preset_rail.name = "SwingPresetRail"
	preset_rail.add_theme_constant_override("separation", 10)
	content.add_child(preset_rail)
	var preset_labels := ["BALANCED\nBASELINE", "WEIGHTY\nUNTUNED", "AGILE\nUNTUNED"]
	for preset_index in range(preset_labels.size()):
		var preset_button := _button(
			StringName("SwingPreset%d" % preset_index),
			preset_labels[preset_index],
			ORANGE,
			68.0,
		)
		preset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		preset_button.pressed.connect(_on_preset_selected.bind(preset_index))
		preset_rail.add_child(preset_button)
		_preset_buttons[preset_index] = preset_button
	content.add_child(_setting_description(
		"Balanced is the approved baseline. The other two were forked early and "
		+ "never tuned — they are kept for future work, not offered as tested "
		+ "alternatives."))

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

	content.add_child(_setting_heading("AUDIO & FEEDBACK"))
	_music_toggle = _toggle("Haunted background music")
	_music_toggle.name = "MusicToggle"
	_music_toggle.toggled.connect(_on_music_toggled)
	content.add_child(_music_toggle)
	content.add_child(_setting_description(
		"Plays the original silk-and-forest score. Its quiet chase layer rises "
		+ "with pressure without changing gameplay."))

	_effects_toggle = _toggle("Gameplay sound effects")
	_effects_toggle.name = "EffectsToggle"
	_effects_toggle.toggled.connect(_on_effects_toggled)
	content.add_child(_effects_toggle)
	content.add_child(_setting_description(
		"Plays the current generated silk, movement, pickup, impact, and "
		+ "later-zone warning samples."))

	_haptics_toggle = _toggle("Handheld haptics")
	_haptics_toggle.name = "HapticsToggle"
	_haptics_toggle.toggled.connect(_on_haptics_toggled)
	content.add_child(_haptics_toggle)
	content.add_child(_setting_description(
		"Keeps Reel, Burst, Dive, and shell feedback tactile on supported devices."))

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
	SpiderUiTheme.enable_descendant_drag_bubbling(scroll)


func _build_garage() -> void:
	_garage = _full_screen(&"Garage")
	var back := _button(&"GarageBack", "‹  HOME", CYAN, 50.0)
	back.pressed.connect(_on_home)
	_place(back, _garage, 0.025, 0.035, 0.16, 0.11)
	var heading := _label("SPIDER GARAGE", 34, INK)
	_place(heading, _garage, 0.20, 0.035, 0.58, 0.12)

	_garage_roster_panel = _panel(PANEL)
	_garage_roster_panel.name = "GarageRosterWebPanel"
	var roster_card := _garage_roster_panel
	_place(roster_card, _garage, 0.04, 0.13, 0.49, 0.96)
	var roster := VBoxContainer.new()
	roster.add_theme_constant_override("separation", 11)
	_fill_with_margin(roster, roster_card, 20.0)
	roster.add_child(_section_label("CHOOSE A HANDLING STYLE"))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	roster.add_child(grid)
	for spider_id: StringName in SpiderCatalog.ALL_IDS:
		var item := SpiderCatalog.profile(spider_id)
		var button := _button(
			StringName("Spider%s" % str(spider_id).capitalize()),
			str(item["name"]).to_upper(),
			YELLOW,
			68.0,
		)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# Real common names are longer than the invented ones they replaced;
		# 17 keeps the widest ("Magnolia Green Jumper", plus its selected tick)
		# inside the narrower grid column.
		button.add_theme_font_size_override("font_size", 17)
		button.pressed.connect(_on_spider_profile.bind(spider_id))
		grid.add_child(button)
		_profile_buttons[spider_id] = button
	roster.add_child(_setting_description(
		"All five candidates are open in this comparison build. Each changes the "
		+ "same tested motor through explicit trade-offs."))

	_garage_detail_panel = _panel(PANEL)
	_garage_detail_panel.name = "GarageDetailWebPanel"
	var detail_card := _garage_detail_panel
	_place(detail_card, _garage, 0.51, 0.13, 0.96, 0.96)
	var detail := VBoxContainer.new()
	detail.add_theme_constant_override("separation", 6)
	_fill_with_margin(detail, detail_card, 18.0)
	_garage_role = _section_label("")
	detail.add_child(_garage_role)
	var identity_row := HBoxContainer.new()
	identity_row.add_theme_constant_override("separation", 10)
	detail.add_child(identity_row)
	_garage_name = _label("", 29, INK)
	_garage_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity_row.add_child(_garage_name)
	_garage_spider_preview = _spider_preview(
		&"GarageSpiderPreview",
		Vector2(118.0, 56.0),
	)
	identity_row.add_child(_garage_spider_preview)
	_garage_description = _setting_description("")
	_garage_description.add_theme_font_size_override("font_size", 15)
	_garage_description.custom_minimum_size.y = 30.0
	detail.add_child(_garage_description)
	_garage_tradeoff = _setting_description("")
	_garage_tradeoff.add_theme_color_override("font_color", YELLOW)
	_garage_tradeoff.add_theme_font_size_override("font_size", 14)
	_garage_tradeoff.custom_minimum_size.y = 28.0
	detail.add_child(_garage_tradeoff)
	_garage_stats = _label("", 14, CYAN)
	_garage_stats.custom_minimum_size.y = 40.0
	detail.add_child(_garage_stats)
	_garage_inspiration = _label("", 13, MUTED)
	_garage_inspiration.name = "GarageInspiration"
	_garage_inspiration.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_garage_inspiration.custom_minimum_size.y = 30.0
	detail.add_child(_garage_inspiration)
	var field_guide := _button(&"GarageFieldGuide", "FIELD GUIDE", ORANGE, 42.0)
	field_guide.add_theme_font_size_override("font_size", 16)
	field_guide.pressed.connect(_on_field_guide.bind(FrontEndState.Screen.GARAGE))
	detail.add_child(field_guide)
	detail.add_child(_compact_heading("BODY PALETTE"))
	var style_rail := HBoxContainer.new()
	style_rail.name = "SpiderStyleRail"
	style_rail.add_theme_constant_override("separation", 8)
	detail.add_child(style_rail)
	var style_labels := ["GARDEN", "AMBER", "COMET"]
	for style_index in range(PlayerProgress.ALL_STYLES.size()):
		var style: StringName = PlayerProgress.ALL_STYLES[style_index]
		var style_button := _button(
			StringName("SpiderStyle%s" % str(style).to_pascal_case()),
			style_labels[style_index],
			YELLOW,
			44.0,
		)
		style_button.add_theme_font_size_override("font_size", 15)
		style_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		style_button.pressed.connect(_on_style_selected.bind(style_index))
		style_rail.add_child(style_button)
		_garage_style_buttons[style] = style_button
	detail.add_child(_compact_heading("SILK TREATMENT"))
	var web_rail := HBoxContainer.new()
	web_rail.name = "WebVariantRail"
	web_rail.add_theme_constant_override("separation", 8)
	detail.add_child(web_rail)
	var web_labels := ["CLASSIC", "DEW", "EMBER"]
	for web_index in range(PlayerProgress.ALL_WEB_VARIANTS.size()):
		var web_variant: StringName = PlayerProgress.ALL_WEB_VARIANTS[web_index]
		var web_button := _button(
			StringName("WebVariant%s" % str(web_variant).to_pascal_case()),
			web_labels[web_index],
			CYAN,
			44.0,
		)
		web_button.add_theme_font_size_override("font_size", 15)
		web_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		web_button.pressed.connect(_on_web_variant_selected.bind(web_index))
		web_rail.add_child(web_button)
		_garage_web_buttons[web_variant] = web_button
	_garage_silk_preview = SilkPreview.new()
	_garage_silk_preview.name = "SilkTreatmentPreview"
	detail.add_child(_garage_silk_preview)
	var play := _button(&"GaragePlay", "PLAY THIS SPIDER", GREEN, 54.0)
	play.pressed.connect(_on_play)
	detail.add_child(play)


func _build_shop() -> void:
	_shop = _full_screen(&"Shop")
	var back := _button(&"ShopBack", "‹  HOME", CYAN, 50.0)
	back.pressed.connect(_on_home)
	_place(back, _shop, 0.025, 0.035, 0.16, 0.11)
	_shop_panel = _panel(PANEL)
	_shop_panel.name = "ShopWebPanel"
	var card := _shop_panel
	_place(card, _shop, 0.14, 0.08, 0.86, 0.94)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 11)
	_fill_with_margin(content, card, 24.0)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 14)
	content.add_child(header)
	_shop_spider_preview = _spider_preview(
		&"ShopSpiderPreview",
		Vector2(112.0, 53.0),
	)
	header.add_child(_shop_spider_preview)
	_shop_title = _label("", 32, INK)
	_shop_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_shop_title)
	_shop_flies = _label("", 22, YELLOW)
	var flies_badge := PanelContainer.new()
	flies_badge.name = "FlyBalanceBadge"
	flies_badge.add_theme_stylebox_override(
		"panel",
		SpiderUiTheme.badge_style(YELLOW),
	)
	flies_badge.add_child(_shop_flies)
	header.add_child(flies_badge)
	var shop_note := _paragraph(
		"Prototype upgrades use flies collected in play. No store purchase or "
		+ "real-money entitlement is connected in this build.")
	shop_note.add_theme_font_size_override("font_size", 17)
	content.add_child(shop_note)
	_shop_description = _setting_description(SHOP_PROGRESSION_COPY)
	_shop_description.name = "ShopProgressionRule"
	_shop_description.add_theme_font_size_override("font_size", 16)
	_shop_description.custom_minimum_size.y = 34.0
	content.add_child(_shop_description)
	var scroll := ScrollContainer.new()
	scroll.name = "ShopUpgradeScroll"
	SpiderUiTheme.configure_touch_scroll(scroll)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)
	var upgrades := VBoxContainer.new()
	upgrades.add_theme_constant_override("separation", 12)
	upgrades.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(upgrades)
	for upgrade_item: Dictionary in SpiderCatalog.all_upgrades():
		var upgrade_id := StringName(upgrade_item["id"])
		var scope := StringName(upgrade_item["scope"])
		var row := _panel(
			Color(PANEL_SOFT, 0.96),
			16,
			GREEN if scope == SpiderCatalog.SCOPE_CORE else ORANGE,
		)
		row.name = "UpgradeRow%s" % str(upgrade_id).to_pascal_case()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var row_content := VBoxContainer.new()
		row_content.add_theme_constant_override("separation", 4)
		_fill_with_margin(row_content, row, 10.0)
		var button := _button(
			StringName("Upgrade%s" % str(upgrade_id).to_pascal_case()),
			"",
			GREEN if scope == SpiderCatalog.SCOPE_CORE else ORANGE,
			68.0,
		)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_upgrade.bind(upgrade_id))
		row_content.add_child(button)
		var description := _setting_description("")
		description.name = \
			"UpgradeDescription%s" % str(upgrade_id).to_pascal_case()
		description.add_theme_font_size_override("font_size", 16)
		description.custom_minimum_size.y = 38.0
		row_content.add_child(description)
		var milestones := _label("", 15, CYAN)
		milestones.name = "UpgradeKnots%s" % str(upgrade_id).to_pascal_case()
		milestones.custom_minimum_size.y = 24.0
		row_content.add_child(milestones)
		upgrades.add_child(row)
		_upgrade_buttons[upgrade_id] = button
		_upgrade_rows[upgrade_id] = row
		_upgrade_descriptions[upgrade_id] = description
		_upgrade_milestones[upgrade_id] = milestones
	SpiderUiTheme.enable_descendant_drag_bubbling(scroll)
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


func _build_practice() -> void:
	_practice = _full_screen(&"Practice")
	var back := _button(&"PracticeBack", "‹  HOME", CYAN, 50.0)
	back.pressed.connect(_on_home)
	_place(back, _practice, 0.025, 0.035, 0.16, 0.11)

	var heading := _label("REGION PRACTICE", 38, INK)
	_place(heading, _practice, 0.19, 0.04, 0.62, 0.13)
	var explanation := _label(
		"Reached checkpoints let you train later sections immediately. "
		+ "Practice runs award no flies, records, checkpoint unlocks, or "
		+ "leaderboard eligibility.",
		19,
		MUTED,
	)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place(explanation, _practice, 0.19, 0.13, 0.92, 0.24)

	var card := _panel(PANEL)
	_place(card, _practice, 0.17, 0.25, 0.83, 0.92)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	_fill_with_margin(content, card, 22.0)
	content.add_child(_section_label("CHOOSE A REACHED REGION"))
	for region: Dictionary in CourseRegionCatalog.practice_regions():
		var region_id := StringName(region["id"])
		var button := _button(
			_practice_button_name(region_id),
			"",
			CYAN,
			80.0,
		)
		button.pressed.connect(_on_practice_region.bind(region_id))
		content.add_child(button)
		_practice_buttons[region_id] = button
	var note := _label(
		"Standard PLAY always starts at 0 m with a fresh deterministic course seed.",
		16,
		YELLOW,
	)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(note)


func _build_campaign() -> void:
	_campaign = _full_screen(&"Campaign")
	var back := _button(&"CampaignBack", "‹  HOME", CYAN, 50.0)
	back.pressed.connect(_on_home)
	_place(back, _campaign, 0.025, 0.035, 0.16, 0.11)

	var heading := _label("CAMPAIGN", 38, INK)
	_place(heading, _campaign, 0.19, 0.04, 0.62, 0.13)
	var explanation := _label(
		"Short levels that each ask you to perform one mechanic. Reaching "
		+ "the goal is not enough — the level is only cleared once you have "
		+ "used the move it teaches. Campaign runs award stars, never flies, "
		+ "and set no records.",
		19,
		MUTED,
	)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place(explanation, _campaign, 0.19, 0.13, 0.92, 0.24)

	var card := _panel(PANEL)
	_place(card, _campaign, 0.17, 0.25, 0.83, 0.92)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	_fill_with_margin(content, card, 22.0)
	content.add_child(_section_label("TEACHING TIER"))
	for level: Dictionary in CampaignCatalog.all_levels():
		var level_id := StringName(level["id"])
		var button := _button(
			_campaign_button_name(level_id),
			"",
			ORANGE,
			84.0,
		)
		button.pressed.connect(_on_campaign_level.bind(level_id))
		content.add_child(button)
		_campaign_buttons[level_id] = button


func _campaign_button_name(level_id: StringName) -> StringName:
	return StringName("CampaignLevel_%s" % level_id)


func _build_debug_run_setup() -> void:
	_debug_run_setup = _full_screen(&"DebugRunSetupScreen")
	var back := _button(&"DebugRunBack", "‹  HOME", CYAN, 50.0)
	back.pressed.connect(_on_home)
	_place(back, _debug_run_setup, 0.025, 0.035, 0.16, 0.11)

	var heading := _label("DEBUG TEST RUN", 38, INK)
	_place(heading, _debug_run_setup, 0.19, 0.035, 0.64, 0.12)
	var explanation := _label(
		"Set distance, temporary upgrades, and the pursuing bird before the run. "
		+ "These choices are session-only and never change what you own.",
		18,
		MUTED,
	)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place(explanation, _debug_run_setup, 0.19, 0.115, 0.93, 0.205)

	var card := _panel(PANEL)
	card.name = "DebugRunSetupCard"
	_place(card, _debug_run_setup, 0.075, 0.215, 0.925, 0.955)
	var shell := VBoxContainer.new()
	shell.name = "DebugRunSetupShell"
	shell.add_theme_constant_override("separation", 10)
	_fill_with_margin(shell, card, 20.0)

	var scroll := ScrollContainer.new()
	scroll.name = "DebugRunSetupScroll"
	SpiderUiTheme.configure_touch_scroll(scroll)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shell.add_child(scroll)

	var content := VBoxContainer.new()
	content.name = "DebugRunSetupContent"
	content.add_theme_constant_override("separation", 10)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)
	content.add_child(_section_label("CHOOSE THE TEST CONDITIONS, THEN START ONCE"))

	var columns := HBoxContainer.new()
	columns.name = "DebugRunSetupColumns"
	columns.add_theme_constant_override("separation", 16)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(columns)
	columns.add_child(_build_debug_distance_card())
	columns.add_child(_build_debug_upgrade_card())
	columns.add_child(_build_debug_bird_card())

	content.add_child(_build_trace_watch_row())

	var warning := _label(
		"DEBUG PRACTICE · NO FLIES · NO RECORD · NO CHECKPOINTS · NO LEADERBOARD",
		16,
		YELLOW,
	)
	warning.name = "DebugRunAwardsWarning"
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning.custom_minimum_size.y = 28.0
	content.add_child(warning)
	var start := _button(
		&"DebugRunStart",
		"START TEST RUN  ·  AWARDS NOTHING",
		GREEN,
		68.0,
	)
	start.pressed.connect(_on_debug_run_start)
	shell.add_child(start)
	SpiderUiTheme.enable_descendant_drag_bubbling(scroll)


## One row for watching a recorded lab run, under the two setup cards.
##
## It is a row rather than a third column because the trace carries its own
## distance and upgrade level — choosing them here would only invite them to
## disagree with what is actually replayed.
func _build_trace_watch_row() -> VBoxContainer:
	var row := VBoxContainer.new()
	row.name = "DebugTraceWatchRow"
	row.add_theme_constant_override("separation", 6)
	row.add_child(_section_label("OR WATCH A RECORDED LAB RUN"))

	var picker := HBoxContainer.new()
	picker.name = "DebugTracePicker"
	picker.add_theme_constant_override("separation", 8)
	row.add_child(picker)
	var previous := _button(&"DebugTracePrevious", "‹", CYAN, 48.0)
	previous.custom_minimum_size.x = 60.0
	previous.pressed.connect(_on_debug_trace_step.bind(-1))
	picker.add_child(previous)
	_debug_trace_label = _label("", 16, CYAN)
	_debug_trace_label.name = "DebugTraceLabel"
	_debug_trace_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_debug_trace_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_debug_trace_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	picker.add_child(_debug_trace_label)
	var next := _button(&"DebugTraceNext", "›", CYAN, 48.0)
	next.custom_minimum_size.x = 60.0
	next.pressed.connect(_on_debug_trace_step.bind(1))
	picker.add_child(next)

	_debug_trace_watch = _button(
		&"DebugTraceWatch", "WATCH THIS RUN  ·  AWARDS NOTHING", CYAN, 52.0)
	_debug_trace_watch.pressed.connect(_on_debug_trace_watch)
	row.add_child(_debug_trace_watch)
	return row


func _on_debug_trace_step(step: int) -> void:
	_state.select_debug_trace(step)


func _on_debug_trace_watch() -> void:
	_state.request_watch_trace()


func _build_debug_distance_card() -> PanelContainer:
	var card := _panel(PANEL_SOFT, 16, CYAN)
	card.name = "DebugRunDistanceCard"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 8)
	_fill_with_margin(body, card, 16.0)
	body.add_child(_setting_heading("START DISTANCE"))
	var description := _setting_description(
		"Type an exact distance in metres, or move in 100 m steps.")
	description.add_theme_font_size_override("font_size", 16)
	body.add_child(description)

	var adjustment := HBoxContainer.new()
	adjustment.add_theme_constant_override("separation", 10)
	body.add_child(adjustment)
	var minus := _button(&"DebugDistanceMinus", "−", CYAN, 64.0)
	minus.custom_minimum_size.x = 72.0
	minus.add_theme_font_size_override("font_size", 34)
	minus.pressed.connect(_on_debug_distance_adjust.bind(-1))
	adjustment.add_child(minus)
	_debug_run_distance_entry = _debug_distance_entry()
	_debug_run_distance_entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	adjustment.add_child(_debug_run_distance_entry)
	var plus := _button(&"DebugDistancePlus", "+", CYAN, 64.0)
	plus.custom_minimum_size.x = 72.0
	plus.add_theme_font_size_override("font_size", 32)
	plus.pressed.connect(_on_debug_distance_adjust.bind(1))
	adjustment.add_child(plus)

	var presets := HBoxContainer.new()
	presets.add_theme_constant_override("separation", 8)
	body.add_child(presets)
	var quick_values: Array[float] = [0.0, 50000.0, 100000.0, 250000.0]
	var quick_labels := ["0 m", "5,000", "10,000", "25,000"]
	for index in range(quick_values.size()):
		var button := _button(
			StringName("DebugDistanceQuick%d" % index),
			quick_labels[index],
			CYAN,
			52.0,
		)
		button.add_theme_font_size_override("font_size", 16)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_debug_distance_set.bind(quick_values[index]))
		presets.add_child(button)
	_debug_run_distance_value = _label("", 16, CYAN)
	_debug_run_distance_value.name = "DebugRunDistanceValue"
	_debug_run_distance_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_debug_run_distance_value.custom_minimum_size.y = 26.0
	body.add_child(_debug_run_distance_value)
	return card


func _build_debug_upgrade_card() -> PanelContainer:
	var card := _panel(PANEL_SOFT, 16, ORANGE)
	card.name = "DebugRunUpgradeCard"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 8)
	_fill_with_margin(body, card, 16.0)
	body.add_child(_setting_heading("TEMPORARY UPGRADES"))
	var description := _setting_description(
		"Set one test level across all seven tracks. Nothing is bought or saved.")
	description.add_theme_font_size_override("font_size", 16)
	body.add_child(description)

	var adjustment := HBoxContainer.new()
	adjustment.add_theme_constant_override("separation", 10)
	body.add_child(adjustment)
	var minus := _button(&"DebugUpgradeMinus", "−", ORANGE, 64.0)
	minus.custom_minimum_size.x = 72.0
	minus.add_theme_font_size_override("font_size", 34)
	minus.pressed.connect(_on_debug_upgrade_adjust.bind(-1))
	adjustment.add_child(minus)
	var value_panel := _panel(Color("071c23"), 10, ORANGE)
	value_panel.custom_minimum_size.y = 64.0
	value_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	adjustment.add_child(value_panel)
	_debug_run_upgrade_value = _label("", 21, YELLOW)
	_debug_run_upgrade_value.name = "DebugRunUpgradeValue"
	_debug_run_upgrade_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_fill_with_margin(_debug_run_upgrade_value, value_panel, 6.0)
	var plus := _button(&"DebugUpgradePlus", "+", ORANGE, 64.0)
	plus.custom_minimum_size.x = 72.0
	plus.add_theme_font_size_override("font_size", 32)
	plus.pressed.connect(_on_debug_upgrade_adjust.bind(1))
	adjustment.add_child(plus)

	var presets := HBoxContainer.new()
	presets.add_theme_constant_override("separation", 8)
	body.add_child(presets)
	var levels := [
		ProgressionService.DEBUG_UPGRADE_OVERLAY_DISABLED,
		0,
		20,
		SpiderCatalog.MAX_UPGRADE_LEVEL,
	]
	var labels := ["OWNED", "L0", "L20", "MAX"]
	for index in range(levels.size()):
		var button := _button(
			StringName("DebugUpgradeQuick%d" % index),
			labels[index],
			ORANGE,
			52.0,
		)
		button.add_theme_font_size_override("font_size", 17)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_debug_upgrade_set.bind(levels[index]))
		presets.add_child(button)
	var note := _label(
		"− from L0 returns to OWNED · + from OWNED begins at L0",
		15,
		ORANGE,
	)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.custom_minimum_size.y = 26.0
	body.add_child(note)
	return card


func _build_debug_bird_card() -> PanelContainer:
	var card := _panel(PANEL_SOFT, 16, GREEN)
	card.name = "DebugRunBirdCard"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 6)
	_fill_with_margin(body, card, 14.0)
	body.add_child(_setting_heading("PURSUING BIRD · ASSUMED"))
	var description := _setting_description(
		"Tune the chase without changing the no-drive world. Speed 0 is bird-off.")
	description.add_theme_font_size_override("font_size", 14)
	body.add_child(description)
	for parameter_id: StringName in [
		&"bird_speed", &"bird_acceleration", &"bird_start_offset",
	]:
		body.add_child(_build_debug_bird_row(parameter_id))

	var presets := HBoxContainer.new()
	presets.name = "DebugBirdPresets"
	presets.add_theme_constant_override("separation", 5)
	body.add_child(presets)
	for preset_id: StringName in [&"off", &"slow", &"base", &"fast"]:
		var button := _button(
			StringName("DebugBirdPreset_%s" % preset_id),
			str(preset_id).to_upper(),
			GREEN,
			48.0,
		)
		button.add_theme_font_size_override("font_size", 14)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_debug_bird_preset.bind(preset_id))
		presets.add_child(button)
	return card


func _build_debug_bird_row(parameter_id: StringName) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "DebugBirdRow_%s" % parameter_id
	row.add_theme_constant_override("separation", 5)
	var descriptor := TuningCatalog.descriptor(parameter_id)
	var label := _label(str(descriptor.get("label", parameter_id)), 13, MUTED)
	label.custom_minimum_size.x = 96.0
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(label)
	var minus := _button(
		StringName("DebugBirdMinus_%s" % parameter_id), "−", GREEN, 48.0)
	minus.custom_minimum_size.x = 48.0
	minus.add_theme_font_size_override("font_size", 25)
	minus.pressed.connect(_on_debug_bird_adjust.bind(parameter_id, -1))
	row.add_child(minus)
	var value := _label("", 14, YELLOW)
	value.name = "DebugBirdValue_%s" % parameter_id
	value.custom_minimum_size = Vector2(90.0, 48.0)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(value)
	_debug_bird_values[parameter_id] = value
	var plus := _button(
		StringName("DebugBirdPlus_%s" % parameter_id), "+", GREEN, 48.0)
	plus.custom_minimum_size.x = 48.0
	plus.add_theme_font_size_override("font_size", 23)
	plus.pressed.connect(_on_debug_bird_adjust.bind(parameter_id, 1))
	row.add_child(plus)
	return row


func _build_field_guide() -> void:
	_field_guide = _full_screen(&"FieldGuide")
	_field_guide_back = _button(&"FieldGuideBack", "‹  BACK", CYAN, 50.0)
	_field_guide_back.pressed.connect(_on_leave_field_guide)
	_place(_field_guide_back, _field_guide, 0.025, 0.035, 0.18, 0.11)
	var card := _panel(PANEL)
	_place(card, _field_guide, 0.14, 0.08, 0.86, 0.94)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	_fill_with_margin(content, card, 24.0)
	content.add_child(_label("SPIDER FIELD GUIDE", 32, INK))
	var frame_note := _paragraph(
		"Each spider in this game names what inspired it, what the real animal "
		+ "does, and what the game invents. Those are three different things and "
		+ "this page never mixes them.")
	frame_note.name = "FieldGuideFrame"
	frame_note.add_theme_font_size_override("font_size", 16)
	frame_note.custom_minimum_size.y = 46.0
	content.add_child(frame_note)
	var scroll := ScrollContainer.new()
	scroll.name = "FieldGuideScroll"
	SpiderUiTheme.configure_touch_scroll(scroll)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)
	var entries := VBoxContainer.new()
	entries.add_theme_constant_override("separation", 12)
	entries.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(entries)
	for spider_id: StringName in SpiderCatalog.ALL_IDS:
		entries.add_child(_field_guide_entry(spider_id))
	SpiderUiTheme.enable_descendant_drag_bubbling(scroll)
	var provenance := _label(
		"Accepted names follow %s. Records reviewed %s." % [
			SpiderBiologyCatalog.NAME_AUTHORITY,
			SpiderBiologyCatalog.REVIEWED_ON,
		],
		14,
		MUTED,
	)
	provenance.name = "FieldGuideProvenance"
	provenance.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(provenance)


func _field_guide_entry(spider_id: StringName) -> Control:
	var profile_item := SpiderCatalog.profile(spider_id)
	var bio := SpiderBiologyCatalog.record(spider_id)
	var inspiration := StringName(bio.get("inspiration", &""))
	var accent := ORANGE if inspiration == SpiderBiologyCatalog.FICTIONAL else GREEN
	var row := _panel(Color(PANEL_SOFT, 0.96), 16, accent)
	row.name = "FieldGuideEntry%s" % str(spider_id).to_pascal_case()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 4)
	_fill_with_margin(body, row, 16.0)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	body.add_child(header)
	var title := _label(str(profile_item["name"]).to_upper(), 22, INK)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	header.add_child(_label(
		SpiderBiologyCatalog.inspiration_label(inspiration),
		14,
		accent,
	))
	body.add_child(_field_guide_line(
		"INSPIRED BY · %s" % bio.get("inspired_by", ""), CYAN))
	# An invented name owes the player the science it borrowed. A real name
	# already carries it, so that entry states the animal's own binomial.
	var drawn_from := SpiderBiologyCatalog.drawn_from_line(spider_id)
	if not drawn_from.is_empty():
		body.add_child(_field_guide_line(
			"%s · %s" % [
				"ABILITIES DRAWN FROM"
				if SpiderBiologyCatalog.has_invented_name(spider_id)
				else "SCIENTIFIC NAME",
				drawn_from,
			],
			MUTED,
		))
	body.add_child(_field_guide_line(
		"REAL SPIDER · %s" % bio.get("real_trait", ""), INK))
	body.add_child(_field_guide_line(
		"IN THIS GAME · %s" % bio.get("game_adaptation", ""), YELLOW))
	var correction := str(bio.get("correction", ""))
	if not correction.is_empty():
		body.add_child(_field_guide_line(
			"GOOD TO KNOW · %s" % correction, ORANGE))
	var citations := PackedStringArray()
	for source: Dictionary in SpiderBiologyCatalog.sources_for(spider_id):
		citations.append(str(source["publisher"]))
	if not citations.is_empty():
		# Publishers contain their own commas ("Natural History Museum, London"),
		# so a comma-joined list reads as more sources than were cited.
		body.add_child(_field_guide_line(
			"SOURCES · %s" % "  ·  ".join(citations), MUTED))
	return row


func _field_guide_line(text_value: String, color: Color) -> Label:
	var label := _label(text_value, 15, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


func _render() -> void:
	if _state == null:
		return
	_home.visible = _state.screen == FrontEndState.Screen.HOME
	_tutorial.visible = _state.screen == FrontEndState.Screen.TUTORIAL
	_settings.visible = _state.screen == FrontEndState.Screen.SETTINGS
	_garage.visible = _state.screen == FrontEndState.Screen.GARAGE
	_shop.visible = _state.screen == FrontEndState.Screen.SHOP
	_creator.visible = _state.screen == FrontEndState.Screen.CREATOR
	_practice.visible = _state.screen == FrontEndState.Screen.PRACTICE
	if _home.visible:
		_refresh_difficulty_buttons()
	_campaign.visible = _state.screen == FrontEndState.Screen.CAMPAIGN
	if _campaign.visible:
		_refresh_campaign_buttons()
	_debug_run_setup.visible = \
		_state.screen == FrontEndState.Screen.DEBUG_RUN_SETUP and \
		_state.settings.show_debug_tools
	_field_guide.visible = _state.screen == FrontEndState.Screen.FIELD_GUIDE
	_debug_run_route.visible = _state.settings.show_debug_tools
	if _field_guide.visible:
		_field_guide_back.text = (
			"‹  GARAGE"
			if _state.field_guide_return_screen == FrontEndState.Screen.GARAGE
			else "‹  HOME"
		)
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
	var selected_preset := _preset_index(_state.settings.swing_preset)
	for preset_index: int in _preset_buttons:
		_set_selector_state(
			_preset_buttons[preset_index] as Button,
			preset_index == selected_preset,
			ORANGE,
		)
	_hints_toggle.button_pressed = _state.settings.show_control_hints
	_motion_toggle.button_pressed = _state.settings.reduced_motion
	_music_toggle.button_pressed = _state.settings.music_enabled
	_effects_toggle.button_pressed = _state.settings.effects_enabled
	_haptics_toggle.button_pressed = _state.settings.haptics_enabled
	_debug_toggle.button_pressed = _state.settings.show_debug_tools
	_syncing_settings = false
	_syncing_progress = true
	_render_garage()
	_render_shop()
	_render_creator()
	_render_practice()
	_render_debug_run_setup()
	_syncing_progress = false
	queue_redraw()


func _render_garage() -> void:
	var selected := _state.progress.selected_spider_id
	var item := SpiderCatalog.profile(selected)
	var profile_accent := SpiderUiTheme.profile_accent(selected)
	_garage_roster_panel.call("set_accent", profile_accent)
	_garage_detail_panel.call("set_accent", profile_accent)
	_garage_name.add_theme_color_override("font_color", profile_accent)
	var overlay_level := _state.debug_upgrade_overlay_level()
	for spider_id: StringName in _profile_buttons:
		var button: Button = _profile_buttons[spider_id]
		var profile_item := SpiderCatalog.profile(spider_id)
		button.text = "%s%s" % [
			"✓ " if spider_id == selected else "",
			str(profile_item["name"]).to_upper(),
		]
	_garage_role.text = (
		"DEBUG UPGRADE OVERLAY · LEVEL %d · NOT OWNED" % overlay_level
		if _state.debug_upgrade_overlay_enabled()
		else str(item["role"])
	)
	_garage_name.text = str(item["name"])
	_sync_spider_preview(_garage_spider_preview, selected)
	_garage_description.text = str(item["description"])
	_garage_tradeoff.text = "TRADE-OFF · %s" % item["tradeoff"]
	var preview := SpiderCatalog.resolved_config(
		SwingConfig.PRESET_BALANCED,
		_state.resolved_progress(),
	)
	var stats_format := (
		"HITBOX %.1f px  ·  GRAVITY %.0f  ·  REEL %.0f px/s · %.2f s%s\n"
		+ "BURST %.0f%%  ·  MINIMUM %.0f px%s"
	)
	_garage_stats.text = stats_format % [
			preview.player_collision_radius,
			preview.gravity,
			preview.reel_retraction_rate,
			preview.reel_energy_capacity / preview.reel_drain_rate,
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
	for style: StringName in _garage_style_buttons:
		var style_button := _garage_style_buttons[style] as Button
		style_button.disabled = \
			style not in _state.progress.unlocked_spider_styles
		_set_selector_state(
			style_button,
			style == _state.progress.selected_spider_style,
			YELLOW,
		)
	for web_variant: StringName in _garage_web_buttons:
		var web_button := _garage_web_buttons[web_variant] as Button
		web_button.disabled = \
			web_variant not in _state.progress.unlocked_web_variants
		_set_selector_state(
			web_button,
			web_variant == _state.progress.selected_web_variant,
			_web_variant_color(web_variant),
		)
	_garage_inspiration.text = SpiderBiologyCatalog.garage_summary(selected)
	_garage_silk_preview.show_variant(_state.progress.selected_web_variant)


func _render_shop() -> void:
	var selected := _state.progress.selected_spider_id
	var profile_item := SpiderCatalog.profile(selected)
	var profile_accent := SpiderUiTheme.profile_accent(selected)
	_shop_panel.call("set_accent", profile_accent)
	_shop_title.add_theme_color_override("font_color", profile_accent)
	var overlay_enabled := _state.debug_upgrade_overlay_enabled()
	var overlay_level := _state.debug_upgrade_overlay_level()
	_sync_spider_preview(_shop_spider_preview, selected)
	_shop_title.text = "%s UPGRADES%s" % [
		str(profile_item["name"]).to_upper(),
		" · DEBUG" if overlay_enabled else "",
	]
	_shop_flies.text = "%d FLIES AVAILABLE" % _state.progress.spendable_flies
	_shop_description.text = (
		"DEBUG OVERLAY · LEVEL %d ON EVERY TRACK · NOT OWNED. Saved levels "
		+ "are unchanged; purchases are paused."
	) % overlay_level if overlay_enabled else SHOP_PROGRESSION_COPY
	for upgrade_id: StringName in _upgrade_buttons:
		(_upgrade_rows[upgrade_id] as Control).visible = false
	for upgrade_item: Dictionary in SpiderCatalog.upgrades_for(selected):
		var upgrade_id := StringName(upgrade_item["id"])
		var button: Button = _upgrade_buttons[upgrade_id]
		var row: Control = _upgrade_rows[upgrade_id]
		var description: Label = _upgrade_descriptions[upgrade_id]
		var milestones: Label = _upgrade_milestones[upgrade_id]
		var owned_level := _state.progress.upgrade_level(upgrade_id)
		var level := _state.displayed_upgrade_level(upgrade_id)
		var maximum := level >= SpiderCatalog.MAX_UPGRADE_LEVEL
		var cost := SpiderCatalog.cost_for_level(owned_level)
		var next_level := mini(SpiderCatalog.MAX_UPGRADE_LEVEL, level + 1)
		var next_is_breakthrough := \
			SpiderCatalog.is_breakthrough_level(next_level)
		var scope := StringName(upgrade_item["scope"])
		row.visible = true
		button.disabled = overlay_enabled or maximum or \
			_state.progress.spendable_flies < cost
		button.text = (
			"%s · %s\nDEBUG OVERLAY LEVEL %d/%d · NOT OWNED"
			% [
				"CORE" if scope == SpiderCatalog.SCOPE_CORE else "IDENTITY",
				str(upgrade_item["name"]).to_upper(),
				level,
				SpiderCatalog.MAX_UPGRADE_LEVEL,
			]
			if overlay_enabled
			else (
			"%s · %s\nLEVEL %d/%d  ·  %s%s"
			% [
				"CORE" if scope == SpiderCatalog.SCOPE_CORE else "IDENTITY",
				str(upgrade_item["name"]).to_upper(),
				level,
				SpiderCatalog.MAX_UPGRADE_LEVEL,
				"MAXIMUM" if maximum else "%d FLIES" % cost,
				(
					"  ·  BREAKTHROUGH ×2"
					if next_is_breakthrough and not maximum
					else ""
				),
			]
			)
		)
		var next_breakthrough := SpiderCatalog.next_breakthrough_level(level)
		description.text = "%s  ·  %s" % [
			upgrade_item["description"],
			(
				"%d breakthroughs earned · %d tuning steps total" % [
					SpiderCatalog.breakthrough_count(level),
					SpiderCatalog.effective_steps(level),
				]
				if maximum
				else "Level %d breakthrough grants 2 tuning steps" %
					next_breakthrough
			),
		]
		milestones.text = "SILK KNOTS  %s" % _breakthrough_knots(level)


func _render_creator() -> void:
	for index in range(_creator_slot_buttons.size()):
		var piece := _state.progress.creator_pattern[index]
		_creator_slot_buttons[index].text = "%02d · %s" % [
			index + 1,
			_creator_piece_label(piece),
		]


func _render_practice() -> void:
	for region: Dictionary in CourseRegionCatalog.practice_regions():
		var region_id := StringName(region["id"])
		var button := _practice_buttons[region_id] as Button
		var unlocked := _state.progress.has_region_checkpoint(region_id)
		var start_metres := float(region["start_distance"]) / \
			CourseRegionCatalog.PIXELS_PER_METRE
		button.disabled = not unlocked
		button.text = "%s  ·  %.0f m\n%s  ·  %s" % [
			"UNLOCKED" if unlocked else "LOCKED",
			start_metres,
			region["name"],
			region["focus"],
		]


func _render_debug_run_setup() -> void:
	if not _debug_run_distance_entry.has_focus():
		_syncing_debug_run_setup = true
		_debug_run_distance_entry.text = _format_debug_distance_metres(
			_state.debug_run_distance_pixels,
		)
		_syncing_debug_run_setup = false
	_debug_run_distance_value.text = "STAGED START · %s m" % \
		_format_debug_distance_metres(_state.debug_run_distance_pixels)
	_debug_run_upgrade_value.text = (
		"OWNED LEVELS"
		if _state.debug_run_upgrade_level < 0
		else "LEVEL %d / %d" % [
			_state.debug_run_upgrade_level,
			SpiderCatalog.MAX_UPGRADE_LEVEL,
		]
	)
	(_debug_bird_values[&"bird_speed"] as Label).text = (
		"OFF" if is_zero_approx(_state.debug_bird_speed)
		else "%.1f m/s" % (
			_state.debug_bird_speed / CourseRegionCatalog.PIXELS_PER_METRE)
	)
	(_debug_bird_values[&"bird_acceleration"] as Label).text = \
		"+%.1f m/s" % (
			_state.debug_bird_acceleration /
			CourseRegionCatalog.PIXELS_PER_METRE)
	(_debug_bird_values[&"bird_start_offset"] as Label).text = \
		"%.0f m gap" % (
			_state.debug_bird_start_offset /
			CourseRegionCatalog.PIXELS_PER_METRE)
	# No bundled traces is an ordinary state, not an error: the screen simply
	# has nothing to offer and says so rather than presenting a dead button.
	var trace := _state.selected_trace()
	var has_trace := not trace.is_empty()
	_debug_trace_label.text = (
		str(trace["label"]) if has_trace else "no recorded runs in this build"
	)
	_debug_trace_watch.disabled = not has_trace


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


func _on_field_guide(return_to: int) -> void:
	if _state != null:
		_state.show_field_guide(return_to)


func _on_leave_field_guide() -> void:
	if _state != null:
		_state.leave_field_guide()


func _on_creator() -> void:
	if _state != null:
		_state.show_creator()


func _on_practice() -> void:
	if _state != null:
		_state.show_practice()


func _on_difficulty(mode_id: StringName) -> void:
	if _state != null:
		_state.request_difficulty(mode_id)


func _refresh_difficulty_buttons() -> void:
	if _state == null:
		return
	for mode: Dictionary in _state.difficulty_modes():
		var mode_id := StringName(mode["id"])
		if not _difficulty_buttons.has(mode_id):
			continue
		var button: Button = _difficulty_buttons[mode_id]
		var best_m := float(mode["best_distance_pixels"]) / 10.0
		button.text = "%s%s\n%s" % [
			"▸ " if bool(mode["selected"]) else "",
			str(mode["name"]),
			"best %.0f m" % best_m if best_m > 0.0 else "no run yet",
		]
		button.disabled = bool(mode["selected"])


func _on_campaign() -> void:
	if _state != null:
		_state.show_campaign()


func _on_campaign_level(level_id: StringName) -> void:
	if _state != null:
		_state.request_campaign(level_id)


func _refresh_campaign_buttons() -> void:
	if _state == null:
		return
	for level: Dictionary in _state.campaign_levels():
		var level_id := StringName(level["id"])
		if not _campaign_buttons.has(level_id):
			continue
		var button: Button = _campaign_buttons[level_id]
		var cleared := int(level["stars"]) > 0
		button.text = "%s  %s\n%s" % [
			"★" if cleared else "☆",
			str(level["name"]),
			str(level["objective"]),
		]


func _on_debug_run_setup() -> void:
	if _state != null:
		_state.show_debug_run_setup()


func _on_debug_distance_changed(text_value: String) -> void:
	if _state == null or _syncing_debug_run_setup:
		return
	var normalized := text_value.strip_edges().replace(",", ".")
	if normalized.is_valid_float():
		_state.set_debug_run_distance_pixels(
			float(normalized) * CourseRegionCatalog.PIXELS_PER_METRE,
		)


func _on_debug_distance_submitted(_text_value: String) -> void:
	_commit_debug_run_distance()


func _on_debug_distance_focus_exited() -> void:
	_commit_debug_run_distance()


func _on_debug_distance_adjust(direction: int) -> void:
	if _state != null:
		_state.adjust_debug_run_distance(direction)


func _on_debug_distance_set(value: float) -> void:
	if _state != null:
		_state.set_debug_run_distance_pixels(value)


func _on_debug_upgrade_adjust(direction: int) -> void:
	if _state != null:
		_state.adjust_debug_run_upgrade_level(direction)


func _on_debug_upgrade_set(level: int) -> void:
	if _state != null:
		_state.set_debug_run_upgrade_level(level)


func _on_debug_bird_adjust(parameter_id: StringName, direction: int) -> void:
	if _state != null:
		_state.adjust_debug_bird_value(parameter_id, direction)


func _on_debug_bird_preset(preset_id: StringName) -> void:
	if _state != null:
		_state.apply_debug_bird_preset(preset_id)


func _on_debug_run_start() -> void:
	if _state == null:
		return
	_commit_debug_run_distance()
	_state.request_debug_play()


func _commit_debug_run_distance() -> void:
	if _state == null:
		return
	var normalized := _debug_run_distance_entry.text.strip_edges().replace(
		",",
		".",
	)
	if normalized.is_valid_float():
		_state.set_debug_run_distance_pixels(
			float(normalized) * CourseRegionCatalog.PIXELS_PER_METRE,
		)
	_syncing_debug_run_setup = true
	_debug_run_distance_entry.text = _format_debug_distance_metres(
		_state.debug_run_distance_pixels,
	)
	_syncing_debug_run_setup = false


func _on_practice_region(region_id: StringName) -> void:
	if _state != null:
		_state.request_practice(region_id)


func _on_spider_profile(spider_id: StringName) -> void:
	if _state != null:
		_state.request_spider_profile(spider_id)


func _practice_button_name(region_id: StringName) -> StringName:
	match region_id:
		CourseRegionCatalog.BRAMBLE_CANOPY:
			return &"PracticeBrambleCanopy"
		CourseRegionCatalog.SILK_HOLLOW:
			return &"PracticeSilkHollow"
	return &"PracticeRegion"


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


func _on_effects_toggled(enabled: bool) -> void:
	if _state != null and not _syncing_settings:
		_state.set_effects_enabled(enabled)


func _on_music_toggled(enabled: bool) -> void:
	if _state != null and not _syncing_settings:
		_state.set_music_enabled(enabled)


func _on_haptics_toggled(enabled: bool) -> void:
	if _state != null and not _syncing_settings:
		_state.set_haptics_enabled(enabled)


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


func _set_selector_state(
	button: Button,
	selected: bool,
	accent: Color,
) -> void:
	var normal := (
		SpiderUiTheme.selected_style(accent)
		if selected
		else SpiderUiTheme.button_style(PANEL_SOFT, Color(accent, 0.68))
	)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override(
		"hover",
		SpiderUiTheme.selected_style(accent) if selected else \
			SpiderUiTheme.button_style(SpiderUiTheme.PANEL_RAISED, accent),
	)
	button.add_theme_color_override(
		"font_color",
		INK if not selected else SpiderUiTheme.SILK,
	)


func _web_variant_color(web_variant: StringName) -> Color:
	match web_variant:
		PlayerProgress.WEB_DEW:
			return GREEN
		PlayerProgress.WEB_EMBER:
			return YELLOW
		_:
			return CYAN


func _breakthrough_knots(level: int) -> String:
	var knots := PackedStringArray()
	for milestone in range(
		SpiderCatalog.BREAKTHROUGH_INTERVAL,
		SpiderCatalog.MAX_UPGRADE_LEVEL + 1,
		SpiderCatalog.BREAKTHROUGH_INTERVAL,
	):
		knots.append("●" if level >= milestone else "○")
	return "  ".join(knots)


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


func _spider_preview(
	node_name: StringName,
	minimum_size: Vector2,
) -> TextureRect:
	var preview := TextureRect.new()
	preview.name = str(node_name)
	preview.custom_minimum_size = minimum_size
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return preview


func _sync_spider_preview(
	preview: TextureRect,
	spider_id: StringName,
) -> void:
	var asset_id := ArtAssetCatalog.spider_asset_id(spider_id)
	var path := ArtAssetCatalog.texture_path(asset_id)
	preview.texture = (
		load(path) as Texture2D
		if ResourceLoader.exists(path)
		else null
	)
	preview.modulate = ArtAssetCatalog.spider_style_tint(
		_state.progress.selected_spider_style,
	)


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


func _panel(
	color: Color,
	radius: int = 22,
	border: Color = Color(GREEN, 0.42),
) -> PanelContainer:
	var panel := SpiderWebPanelScript.new()
	panel.configure(color, radius, border)
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


func _compact_heading(text_value: String) -> Label:
	var label := _label(text_value, 13, CYAN)
	label.custom_minimum_size.y = 18.0
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
		"hover", _button_style(SpiderUiTheme.PANEL_RAISED, accent))
	button.add_theme_stylebox_override("focus", _button_style(PANEL_SOFT, INK, 3))
	button.add_theme_stylebox_override("pressed", _button_style(accent, accent))
	button.add_theme_stylebox_override(
		"disabled", _button_style(Color("101812"), Color(MUTED, 0.34)))
	_buttons[button_name] = button
	return button


func _button_style(
	fill: Color,
	border: Color,
	width: int = 2,
) -> StyleBoxFlat:
	return SpiderUiTheme.button_style(fill, border, width)


func _debug_distance_entry() -> LineEdit:
	var entry := LineEdit.new()
	entry.name = "DebugRunDistanceEntry"
	entry.placeholder_text = "METRES"
	entry.alignment = HORIZONTAL_ALIGNMENT_CENTER
	entry.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER_DECIMAL
	entry.custom_minimum_size.y = 64.0
	entry.mouse_filter = Control.MOUSE_FILTER_STOP
	entry.add_theme_font_size_override("font_size", 24)
	entry.add_theme_color_override("font_color", YELLOW)
	entry.add_theme_color_override("caret_color", CYAN)
	entry.add_theme_color_override("selection_color", Color("245b65"))
	var normal := SpiderUiTheme.button_style(Color("071c23"), CYAN, 2)
	entry.add_theme_stylebox_override("normal", normal)
	var focus := normal.duplicate() as StyleBoxFlat
	focus.border_color = YELLOW
	entry.add_theme_stylebox_override("focus", focus)
	entry.text_changed.connect(_on_debug_distance_changed)
	entry.text_submitted.connect(_on_debug_distance_submitted)
	entry.focus_exited.connect(_on_debug_distance_focus_exited)
	return entry


func _format_debug_distance_metres(distance_pixels: float) -> String:
	var metres := distance_pixels / CourseRegionCatalog.PIXELS_PER_METRE
	if is_equal_approx(metres, roundf(metres)):
		return "%.0f" % metres
	return ("%.1f" % metres).trim_suffix(".0")


func _toggle(text_value: String) -> CheckButton:
	var toggle := CheckButton.new()
	toggle.text = text_value
	toggle.custom_minimum_size.y = 58.0
	toggle.add_theme_font_size_override("font_size", 23)
	toggle.add_theme_color_override("font_color", INK)
	return toggle
