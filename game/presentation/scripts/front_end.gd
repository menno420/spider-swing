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
const TEST_LAB_CATEGORIES: Array[StringName] = [
	TuningCatalog.CATEGORY_MOVEMENT,
	TuningCatalog.CATEGORY_PACING,
	TuningCatalog.CATEGORY_ROPE,
	TuningCatalog.CATEGORY_PULLS,
	TuningCatalog.CATEGORY_COURSE,
	TuningCatalog.CATEGORY_ROUTES,
	TuningCatalog.CATEGORY_RUN,
	TuningCatalog.CATEGORY_ABILITIES,
]

var _state: FrontEndState
var _home: Control
var _spider_hub: Control
var _play_modes_hub: Control
var _guide_hub: Control
var _home_spider_preview: TextureRect
var _home_spider_name: Label
var _home_run_summary: Label
var _home_play_button: Button
var _spider_hub_preview: TextureRect
var _spider_hub_name: Label
var _spider_hub_summary: Label
var _tutorial: Control
var _settings: Control
var _garage: Control
var _shop: Control
var _creator: Control
var _practice: Control
var _campaign: Control
var _debug_run_setup: Control
var _debug_test_lab: Control
var _field_guide: Control
var _field_guide_back: Button
var _field_guide_buttons: Dictionary = {}
var _field_guide_preview: TextureRect
var _field_guide_title: Label
var _field_guide_badge: Label
var _field_guide_inspiration: Label
var _field_guide_real: Label
var _field_guide_game: Label
var _field_guide_note: Label
var _field_guide_sources: Label
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
var _music_volume_slider: HSlider
var _music_volume_value: Label
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
var _quick_debug_run_distance_entry: LineEdit
var _quick_debug_run_distance_value: Label
var _debug_trace_label: Label
var _debug_trace_watch: Button
var _debug_run_upgrade_value: Label
var _quick_debug_run_upgrade_value: Label
var _quick_debug_bird_values: Dictionary = {}
var _debug_category_buttons: Dictionary = {}
var _debug_category_panels: Dictionary = {}
var _debug_tuning_values: Dictionary = {}
var _debug_profile_load_buttons: Dictionary = {}
var _debug_profile_status: Label
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
	_build_spider_hub()
	_build_play_modes_hub()
	_build_guide_hub()
	_build_tutorial()
	_build_settings()
	_build_garage()
	_build_shop()
	_build_creator()
	_build_practice()
	_build_campaign()
	_build_debug_run_setup()
	_build_debug_test_lab()
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
		drift = sin(_elapsed * 0.18) * 10.0
	# Layered graphite/bark planes replace the former empty green circles. The
	# texture is deterministic and quiet enough to sit behind long-form copy.
	for index in range(9):
		var band_x := size.x * float(index) / 8.0 + \
			drift * float(index % 2)
		var half_width := 72.0 + float(index % 3) * 28.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(band_x - half_width, -20.0),
			Vector2(band_x + half_width, -20.0),
			Vector2(band_x + half_width * 0.45, size.y + 20.0),
			Vector2(band_x - half_width * 1.25, size.y + 20.0),
		]), Color(
			SpiderUiTheme.PANEL_SOFT,
			0.075 if index % 2 == 0 else 0.035,
		))
		draw_line(
			Vector2(band_x + half_width, 0.0),
			Vector2(band_x + half_width * 0.45, size.y),
			Color(SpiderUiTheme.INK, 0.025),
			1.0,
			true,
		)
	for index in range(80):
		var grain_start := Vector2(
			fposmod(float(index * 97 + 31), 997.0) / 997.0 * size.x,
			fposmod(float(index * 53 + 17), 991.0) / 991.0 * size.y,
		)
		var grain_length := 8.0 + float((index * 11) % 34)
		draw_line(
			grain_start,
			Vector2(
				minf(size.x, grain_start.x + grain_length),
				grain_start.y + float((index % 5) - 2) * 0.7,
			),
			Color(SpiderUiTheme.INK, 0.028),
			1.0,
			true,
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
	]), Color(SpiderUiTheme.BARK, 0.34))
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

	var eyebrow := _label("MINIATURE FOREST · ENDLESS SWING", 16, CYAN)
	_place(eyebrow, _home, 0.045, 0.055, 0.35, 0.11)
	var title := _label("SPIDER\nSWING", 68, INK)
	title.add_theme_constant_override("line_spacing", -18)
	_place(title, _home, 0.045, 0.105, 0.35, 0.31)
	var subtitle := _label(
		"Momentum is the move.\nChoose an anchor. Commit to the arc.",
		19,
		MUTED,
	)
	_place(subtitle, _home, 0.05, 0.31, 0.35, 0.42)

	var identity := _panel(PANEL)
	identity.name = "HomeIdentityPanel"
	_place(identity, _home, 0.04, 0.44, 0.35, 0.84)
	var identity_body := VBoxContainer.new()
	identity_body.add_theme_constant_override("separation", 5)
	_fill_with_margin(identity_body, identity, 18.0)
	identity_body.add_child(_section_label("CURRENT SPIDER"))
	_home_spider_preview = _spider_preview(
		&"HomeSpiderPreview", Vector2(230.0, 126.0))
	_home_spider_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_home_spider_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	identity_body.add_child(_home_spider_preview)
	_home_spider_name = _label("", 25, GREEN)
	_home_spider_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	identity_body.add_child(_home_spider_name)
	_home_run_summary = _label("", 15, MUTED)
	_home_run_summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_home_run_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	identity_body.add_child(_home_run_summary)

	var version := _label(
		"BUILD %s" % ProjectSettings.get_setting(
			"application/config/version", "unknown"),
		13,
		MUTED,
	)
	_place(version, _home, 0.05, 0.875, 0.35, 0.92)

	var card := _panel(PANEL)
	card.name = "HomeWebPanel"
	_place(card, _home, 0.38, 0.05, 0.96, 0.95)
	var menu := VBoxContainer.new()
	menu.add_theme_constant_override("separation", 4)
	_fill_with_margin(menu, card, 6.0)
	menu.add_child(_section_label("ENDLESS RUN"))
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
		button.add_theme_font_size_override("font_size", 16)
		button.pressed.connect(_on_difficulty.bind(mode_id))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		difficulty_row.add_child(button)
		_difficulty_buttons[mode_id] = button
	_home_play_button = _button(
		&"Play",
		"PLAY ENDLESS  ·  STANDARD\nCHASE YOUR BEST DISTANCE",
		GREEN,
		72.0,
	)
	_home_play_button.add_theme_font_size_override("font_size", 21)
	_home_play_button.pressed.connect(_on_play)
	menu.add_child(_home_play_button)
	menu.add_child(_section_label("WHERE TO NEXT"))

	var routes := GridContainer.new()
	routes.name = "HomeRouteGrid"
	routes.columns = 2
	routes.add_theme_constant_override("h_separation", 8)
	routes.add_theme_constant_override("v_separation", 8)
	menu.add_child(routes)
	var spider_hub := _home_route_button(
		&"SpiderHub", "SPIDER\nchoose · style · improve", YELLOW)
	spider_hub.pressed.connect(_on_spider_hub)
	routes.add_child(spider_hub)
	var modes_hub := _home_route_button(
		&"PlayModesHub", "PLAY MODES\ncampaign · practice · creator", ORANGE)
	modes_hub.pressed.connect(_on_play_modes_hub)
	routes.add_child(modes_hub)
	var guide_hub := _home_route_button(
		&"GuideHub", "GUIDE\nlearn controls · meet spiders", CYAN)
	guide_hub.pressed.connect(_on_guide_hub)
	routes.add_child(guide_hub)
	var settings := _home_route_button(
		&"Settings", "SETTINGS\nsound · motion · access", GREEN)
	settings.pressed.connect(_on_settings)
	routes.add_child(settings)
	_debug_run_route = _button(
		&"DebugRunSetup",
		"DEBUG TEST RUN  ·  QUICK SETUP  ·  AWARDS NOTHING",
		ORANGE,
		48.0,
	)
	_debug_run_route.add_theme_font_size_override("font_size", 13)
	_debug_run_route.pressed.connect(_on_debug_run_setup)
	_debug_run_route.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu.add_child(_debug_run_route)
	var note := _label(
		"ENDLESS PLAY uses your owned spider and upgrades", 13, MUTED)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu.add_child(note)


func _home_route_button(
	button_name: StringName,
	text_value: String,
	accent: Color,
) -> Button:
	var button := _button(button_name, text_value, accent, 58.0)
	button.add_theme_font_size_override("font_size", 14)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return button


func _build_spider_hub() -> void:
	_spider_hub = _full_screen(&"SpiderHubScreen")
	var back := _button(&"SpiderHubBack", "‹  HOME", CYAN, 50.0)
	back.pressed.connect(_on_home)
	_place(back, _spider_hub, 0.025, 0.035, 0.16, 0.11)
	var heading := _label("YOUR SPIDER", 38, INK)
	_place(heading, _spider_hub, 0.19, 0.035, 0.58, 0.12)
	var explanation := _label(
		"Choose who you swing as, then decide whether to change its look or improve its abilities.",
		17,
		MUTED,
	)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place(explanation, _spider_hub, 0.19, 0.105, 0.94, 0.18)

	var identity := _panel(PANEL)
	identity.name = "SpiderHubIdentity"
	_place(identity, _spider_hub, 0.05, 0.20, 0.43, 0.92)
	var identity_body := VBoxContainer.new()
	identity_body.add_theme_constant_override("separation", 8)
	_fill_with_margin(identity_body, identity, 20.0)
	identity_body.add_child(_section_label("CURRENTLY EQUIPPED"))
	_spider_hub_preview = _spider_preview(
		&"SpiderHubPreview", Vector2(280.0, 180.0))
	_spider_hub_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_spider_hub_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	identity_body.add_child(_spider_hub_preview)
	_spider_hub_name = _label("", 28, GREEN)
	_spider_hub_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	identity_body.add_child(_spider_hub_name)
	_spider_hub_summary = _label("", 16, MUTED)
	_spider_hub_summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_spider_hub_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	identity_body.add_child(_spider_hub_summary)

	var actions := _panel(PANEL)
	actions.name = "SpiderHubRoutes"
	_place(actions, _spider_hub, 0.46, 0.20, 0.95, 0.92)
	var route_body := VBoxContainer.new()
	route_body.add_theme_constant_override("separation", 12)
	_fill_with_margin(route_body, actions, 18.0)
	route_body.add_child(_section_label("CHOOSE WHAT TO CHANGE"))
	var garage := _hub_route_button(
		&"Garage", "SPIDER GARAGE\nchoose spider · body · silk", YELLOW)
	garage.pressed.connect(_on_garage)
	route_body.add_child(garage)
	var shop := _hub_route_button(
		&"Shop", "UPGRADES\ninspect tracks · spend flies", GREEN)
	shop.pressed.connect(_on_shop)
	route_body.add_child(shop)


func _build_play_modes_hub() -> void:
	_play_modes_hub = _full_screen(&"PlayModesHubScreen")
	var back := _button(&"PlayModesHubBack", "‹  HOME", CYAN, 50.0)
	back.pressed.connect(_on_home)
	_place(back, _play_modes_hub, 0.025, 0.035, 0.16, 0.11)
	var heading := _label("PLAY MODES", 38, INK)
	_place(heading, _play_modes_hub, 0.19, 0.035, 0.58, 0.12)
	var explanation := _label(
		"Endless starts directly from Home. These modes change the goal, starting point, or route.",
		17,
		MUTED,
	)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place(explanation, _play_modes_hub, 0.19, 0.105, 0.94, 0.18)
	var card := _panel(PANEL)
	card.name = "PlayModesHubRoutes"
	_place(card, _play_modes_hub, 0.06, 0.21, 0.94, 0.91)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 16)
	_fill_with_margin(body, card, 26.0)
	body.add_child(_section_label("CHOOSE A DIFFERENT WAY TO SWING"))
	var routes := GridContainer.new()
	routes.name = "PlayModesRouteGrid"
	routes.columns = 3
	routes.add_theme_constant_override("h_separation", 16)
	body.add_child(routes)
	var campaign := _hub_route_button(
		&"Campaign", "CAMPAIGN\nfocused skill challenges · stars", ORANGE)
	campaign.pressed.connect(_on_campaign)
	routes.add_child(campaign)
	var practice := _hub_route_button(
		&"Practice", "REGION PRACTICE\ntrain reached checkpoints", CYAN)
	practice.pressed.connect(_on_practice)
	routes.add_child(practice)
	var creator := _hub_route_button(
		&"Creator", "COURSE LAB\nbuild a six-piece route", YELLOW)
	creator.pressed.connect(_on_creator)
	routes.add_child(creator)
	body.add_child(_setting_description(
		"Campaign awards stars. Practice and Course Lab are noncompetitive and never change Endless records."))


func _build_guide_hub() -> void:
	_guide_hub = _full_screen(&"GuideHubScreen")
	var back := _button(&"GuideHubBack", "‹  HOME", CYAN, 50.0)
	back.pressed.connect(_on_home)
	_place(back, _guide_hub, 0.025, 0.035, 0.16, 0.11)
	var heading := _label("GUIDE", 38, INK)
	_place(heading, _guide_hub, 0.19, 0.035, 0.58, 0.12)
	var explanation := _label(
		"Learn the movement first, then see where each playable spider ends and its real-world inspiration begins.",
		17,
		MUTED,
	)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place(explanation, _guide_hub, 0.19, 0.105, 0.94, 0.18)
	var card := _panel(PANEL)
	card.name = "GuideHubRoutes"
	_place(card, _guide_hub, 0.13, 0.21, 0.87, 0.91)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 18)
	_fill_with_margin(body, card, 28.0)
	body.add_child(_section_label("CHOOSE WHAT YOU WANT TO UNDERSTAND"))
	var routes := GridContainer.new()
	routes.name = "GuideRouteGrid"
	routes.columns = 2
	routes.add_theme_constant_override("h_separation", 18)
	body.add_child(routes)
	var tutorial := _hub_route_button(
		&"Tutorial", "HOW TO SWING\nsix visual lessons · practice", CYAN)
	tutorial.pressed.connect(_on_tutorial)
	routes.add_child(tutorial)
	var field_guide := _hub_route_button(
		&"FieldGuide", "SPIDER FIELD GUIDE\nreal animal · game ability · sources", YELLOW)
	field_guide.pressed.connect(
		_on_field_guide.bind(FrontEndState.Screen.GUIDE_HUB))
	routes.add_child(field_guide)
	body.add_child(_setting_description(
		"How to Swing teaches the controls. Field Guide explains identity and biology without mixing them into gameplay rules."))


func _hub_route_button(
	button_name: StringName,
	text_value: String,
	accent: Color,
) -> Button:
	var button := _button(button_name, text_value, accent, 112.0)
	button.add_theme_font_size_override("font_size", 18)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return button


func _build_tutorial() -> void:
	_tutorial = _full_screen(&"Tutorial")
	var back := _button(&"TutorialBack", "‹  GUIDE", CYAN, 50.0)
	back.pressed.connect(_on_guide_hub)
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
	var music_header := HBoxContainer.new()
	music_header.name = "MusicVolumeHeader"
	music_header.add_theme_constant_override("separation", 16)
	content.add_child(music_header)
	var music_title := _label("Haunted background music", 23, INK)
	music_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	music_header.add_child(music_title)
	_music_volume_value = _label("50%", 23, CYAN)
	_music_volume_value.name = "MusicVolumeValue"
	_music_volume_value.custom_minimum_size.x = 82.0
	_music_volume_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	music_header.add_child(_music_volume_value)
	_music_volume_slider = HSlider.new()
	_music_volume_slider.name = "MusicVolumeSlider"
	_music_volume_slider.min_value = 0.0
	_music_volume_slider.max_value = 100.0
	_music_volume_slider.step = 5.0
	_music_volume_slider.custom_minimum_size.y = 64.0
	_music_volume_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_music_volume_slider.focus_mode = Control.FOCUS_ALL
	_music_volume_slider.value_changed.connect(_on_music_volume_changed)
	content.add_child(_music_volume_slider)
	content.add_child(_setting_description(
		"50% matches the original mix. 0% is silent; 100% is about twice as "
		+ "strong. The chase layer still rises with pressure."))

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
	var back := _button(&"GarageBack", "‹  SPIDER", CYAN, 50.0)
	back.pressed.connect(_on_spider_hub)
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
	var back := _button(&"ShopBack", "‹  SPIDER", CYAN, 50.0)
	back.pressed.connect(_on_spider_hub)
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
	var back := _button(&"CreatorBack", "‹  PLAY MODES", CYAN, 50.0)
	back.pressed.connect(_on_play_modes_hub)
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
	var back := _button(&"PracticeBack", "‹  PLAY MODES", CYAN, 50.0)
	back.pressed.connect(_on_play_modes_hub)
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
	var back := _button(&"CampaignBack", "‹  PLAY MODES", CYAN, 50.0)
	back.pressed.connect(_on_play_modes_hub)
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
	_place(heading, _debug_run_setup, 0.19, 0.035, 0.58, 0.12)
	var explanation := _label(
		"Choose only the conditions needed for a quick comparison, then start. "
			+ "Advanced tuning stays separate and saved.",
		16,
		MUTED,
	)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place(explanation, _debug_run_setup, 0.19, 0.105, 0.68, 0.19)
	var advanced := _button(
		&"DebugTestLab",
		"ADVANCED TEST LAB\nSAVED A / B / C",
		ORANGE,
		58.0,
	)
	advanced.add_theme_font_size_override("font_size", 15)
	advanced.pressed.connect(_on_debug_test_lab)
	_place(advanced, _debug_run_setup, 0.70, 0.045, 0.955, 0.155)

	var card := _panel(PANEL)
	card.name = "DebugRunSetupCard"
	_place(card, _debug_run_setup, 0.045, 0.205, 0.955, 0.965)
	var shell := VBoxContainer.new()
	shell.name = "DebugRunSetupShell"
	shell.add_theme_constant_override("separation", 8)
	_fill_with_margin(shell, card, 16.0)

	var scroll := ScrollContainer.new()
	scroll.name = "DebugRunSetupScroll"
	SpiderUiTheme.configure_touch_scroll(scroll)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shell.add_child(scroll)
	var content := VBoxContainer.new()
	content.name = "DebugRunSetupContent"
	content.add_theme_constant_override("separation", 8)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)
	content.add_child(_section_label("QUICK CONDITIONS"))
	var columns := HBoxContainer.new()
	columns.name = "DebugRunSetupColumns"
	columns.add_theme_constant_override("separation", 12)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(columns)
	columns.add_child(_build_debug_distance_card())
	columns.add_child(_build_debug_upgrade_card())
	columns.add_child(_build_debug_bird_card())
	var warning := _label(
		"TEST RUN · NO FLIES · NO RECORDS · NO CHECKPOINTS · NO LEADERBOARD",
		14,
		YELLOW,
	)
	warning.name = "DebugRunAwardsWarning"
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning.custom_minimum_size.y = 24.0
	content.add_child(warning)
	var start := _button(
		&"DebugRunStart",
		"START QUICK TEST RUN  ·  AWARDS NOTHING",
		GREEN,
		64.0,
	)
	start.pressed.connect(_on_quick_debug_run_start)
	shell.add_child(start)
	SpiderUiTheme.enable_descendant_drag_bubbling(scroll)


func _build_debug_test_lab() -> void:
	_debug_test_lab = _full_screen(&"DebugTestLabScreen")
	var back := _button(&"DebugTestLabBack", "‹  QUICK TEST", CYAN, 50.0)
	back.pressed.connect(_on_debug_run_setup)
	_place(back, _debug_test_lab, 0.025, 0.035, 0.16, 0.11)

	var heading := _label("TEST LAB", 38, INK)
	_place(heading, _debug_test_lab, 0.19, 0.03, 0.48, 0.105)
	var explanation := _label(
		"Configure the same tuning catalogue available during a run. The working "
		+ "set auto-saves; A/B/C keep whole comparisons for later.",
		16,
		MUTED,
	)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place(explanation, _debug_test_lab, 0.19, 0.10, 0.95, 0.17)

	var card := _panel(PANEL)
	card.name = "DebugTestLabCard"
	_place(card, _debug_test_lab, 0.035, 0.18, 0.965, 0.965)
	var shell := VBoxContainer.new()
	shell.name = "DebugTestLabShell"
	shell.add_theme_constant_override("separation", 8)
	_fill_with_margin(shell, card, 16.0)
	shell.add_child(_build_debug_profile_strip())
	shell.add_child(_build_debug_category_rail())

	var category_stack := Control.new()
	category_stack.name = "DebugCategoryStack"
	category_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	category_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shell.add_child(category_stack)
	for category_id: StringName in TEST_LAB_CATEGORIES:
		var category_panel := _build_debug_category_panel(category_id)
		category_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		category_stack.add_child(category_panel)
		_debug_category_panels[category_id] = category_panel

	var footer := HBoxContainer.new()
	footer.name = "DebugTestLabFooter"
	footer.add_theme_constant_override("separation", 10)
	shell.add_child(footer)
	var warning := _label(
		"TEST RUN · NO FLIES · NO RECORDS · NO CHECKPOINTS · NO LEADERBOARD",
		14,
		YELLOW,
	)
	warning.name = "DebugTestLabAwardsWarning"
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(warning)
	var start := _button(
		&"DebugTestLabStart",
		"START TEST RUN  ·  AWARDS NOTHING",
		GREEN,
		62.0,
	)
	start.custom_minimum_size.x = 330.0
	start.pressed.connect(_on_debug_run_start)
	footer.add_child(start)


func _build_debug_profile_strip() -> PanelContainer:
	var panel := _panel(PANEL_SOFT, 14, ORANGE)
	panel.name = "DebugProfileStrip"
	panel.custom_minimum_size.y = 64.0
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	_fill_with_margin(row, panel, 8.0)
	var title := VBoxContainer.new()
	title.custom_minimum_size.x = 220.0
	row.add_child(title)
	title.add_child(_setting_heading("WORKING SET · AUTO-SAVED"))
	_debug_profile_status = _label("", 13, MUTED)
	title.add_child(_debug_profile_status)
	for slot_id: StringName in DebugTestProfile.SLOT_IDS:
		var slot := HBoxContainer.new()
		slot.add_theme_constant_override("separation", 4)
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(slot)
		var save := _button(
			StringName("DebugProfileSave_%s" % slot_id),
			"SAVE %s" % str(slot_id).to_upper(),
			ORANGE,
			46.0,
		)
		save.add_theme_font_size_override("font_size", 14)
		save.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		save.pressed.connect(_on_debug_profile_save.bind(slot_id))
		slot.add_child(save)
		var load := _button(
			StringName("DebugProfileLoad_%s" % slot_id),
			"EMPTY",
			CYAN,
			46.0,
		)
		load.add_theme_font_size_override("font_size", 14)
		load.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		load.pressed.connect(_on_debug_profile_load.bind(slot_id))
		slot.add_child(load)
		_debug_profile_load_buttons[slot_id] = load
	var reset := _button(&"DebugProfileReset", "RESET TO BASE", MUTED, 46.0)
	reset.add_theme_font_size_override("font_size", 14)
	reset.custom_minimum_size.x = 150.0
	reset.pressed.connect(_on_debug_profile_reset)
	row.add_child(reset)
	return panel


func _build_debug_category_rail() -> GridContainer:
	var rail := GridContainer.new()
	rail.name = "DebugCategoryRail"
	rail.columns = TEST_LAB_CATEGORIES.size()
	rail.add_theme_constant_override("h_separation", 6)
	for category_id: StringName in TEST_LAB_CATEGORIES:
		var category_index := TuningCatalog.category_index(category_id)
		var descriptor := TuningCatalog.category(category_index)
		var button := _button(
			StringName("DebugCategory_%s" % category_id),
			str(descriptor["label"]),
			CYAN,
			46.0,
		)
		button.add_theme_font_size_override("font_size", 14)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_debug_category.bind(category_index))
		rail.add_child(button)
		_debug_category_buttons[category_id] = button
	return rail


func _build_debug_category_panel(category_id: StringName) -> Control:
	var body := VBoxContainer.new()
	body.name = "DebugCategoryPanel_%s" % category_id
	body.add_theme_constant_override("separation", 5)
	var descriptor := TuningCatalog.category(
		TuningCatalog.category_index(category_id))
	var help := _label(str(descriptor["help"]), 14, MUTED)
	help.custom_minimum_size.y = 24.0
	body.add_child(help)
	if category_id == TuningCatalog.CATEGORY_PACING:
		body.add_child(_build_debug_bird_presets())
	if category_id == TuningCatalog.CATEGORY_RUN:
		body.add_child(_build_trace_watch_row())
	var scroll := ScrollContainer.new()
	scroll.name = "DebugTestLabScroll_%s" % category_id
	SpiderUiTheme.configure_touch_scroll(scroll)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	var grid := GridContainer.new()
	grid.name = "DebugParameterGrid_%s" % category_id
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)
	for parameter: Dictionary in TuningCatalog.parameters_for_category(category_id):
		grid.add_child(_build_debug_parameter_card(parameter))
	SpiderUiTheme.enable_descendant_drag_bubbling(scroll)
	return body


func _build_debug_bird_presets() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "DebugBirdPresets"
	row.add_theme_constant_override("separation", 6)
	row.add_child(_label("BIRD COMPARISON", 13, GREEN))
	for preset_id: StringName in [&"off", &"slow", &"base", &"fast"]:
		var button := _button(
			StringName("DebugBirdPreset_%s" % preset_id),
			str(preset_id).to_upper(),
			GREEN,
			44.0,
		)
		button.add_theme_font_size_override("font_size", 13)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_debug_bird_preset.bind(preset_id))
		row.add_child(button)
	return row


func _build_debug_parameter_card(parameter: Dictionary) -> PanelContainer:
	var parameter_id := StringName(parameter["id"])
	var card := _panel(PANEL_SOFT, 12, CYAN)
	card.name = "DebugParameter_%s" % parameter_id
	card.custom_minimum_size = Vector2(0.0, 132.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 3)
	_fill_with_margin(body, card, 10.0)
	var header := HBoxContainer.new()
	body.add_child(header)
	var title := _label(str(parameter["label"]).to_upper(), 16, INK)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var help := _label(str(parameter["help"]), 13, MUTED)
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.custom_minimum_size.y = 34.0
	body.add_child(help)
	var adjustment := HBoxContainer.new()
	adjustment.add_theme_constant_override("separation", 6)
	body.add_child(adjustment)
	var minus := _button(
		StringName("DebugTuningMinus_%s" % parameter_id), "−", CYAN, 50.0)
	minus.custom_minimum_size.x = 58.0
	minus.add_theme_font_size_override("font_size", 27)
	minus.pressed.connect(_on_debug_tuning_adjust.bind(parameter_id, -1))
	adjustment.add_child(minus)
	if parameter_id == TuningCatalog.DEBUG_START_DISTANCE:
		_debug_run_distance_entry = _debug_distance_entry()
		_debug_run_distance_entry.custom_minimum_size.y = 50.0
		_debug_run_distance_entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		adjustment.add_child(_debug_run_distance_entry)
	else:
		var value_panel := _panel(Color(SpiderUiTheme.BACKGROUND, 0.72), 8, CYAN)
		value_panel.custom_minimum_size.y = 50.0
		value_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		adjustment.add_child(value_panel)
		var value := _label("", 17, YELLOW)
		value.name = "DebugTuningValue_%s" % parameter_id
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_fill_with_margin(value, value_panel, 4.0)
		_debug_tuning_values[parameter_id] = value
		if parameter_id == TuningCatalog.DEBUG_UPGRADE_LEVEL:
			_debug_run_upgrade_value = value
	var plus := _button(
		StringName("DebugTuningPlus_%s" % parameter_id), "+", CYAN, 50.0)
	plus.custom_minimum_size.x = 58.0
	plus.add_theme_font_size_override("font_size", 25)
	plus.pressed.connect(_on_debug_tuning_adjust.bind(parameter_id, 1))
	adjustment.add_child(plus)
	var quick := HBoxContainer.new()
	quick.add_theme_constant_override("separation", 4)
	body.add_child(quick)
	var quick_values: Array = parameter.get("quick", [])
	for index in range(quick_values.size()):
		var quick_value := float(quick_values[index])
		var button := _button(
			StringName("DebugTuningQuick_%s_%d" % [parameter_id, index]),
			_quick_tuning_label(parameter_id, quick_value),
			ORANGE,
			34.0,
		)
		button.add_theme_font_size_override("font_size", 12)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(
			_on_debug_tuning_set.bind(parameter_id, quick_value))
		quick.add_child(button)
	return card


## One compact row for watching a recorded lab run inside the Run category.
##
## The trace carries its own distance and upgrade level, so it is visually
## separate from editable values and does not enlarge the pinned footer.
func _build_trace_watch_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "DebugTraceWatchRow"
	row.add_theme_constant_override("separation", 8)
	row.custom_minimum_size.y = 48.0
	var heading := _label("RECORDED RUN", 13, MUTED)
	heading.custom_minimum_size.x = 125.0
	heading.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(heading)
	var picker := HBoxContainer.new()
	picker.name = "DebugTracePicker"
	picker.add_theme_constant_override("separation", 8)
	picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(picker)
	var previous := _button(&"DebugTracePrevious", "‹", CYAN, 44.0)
	previous.custom_minimum_size.x = 52.0
	previous.pressed.connect(_on_debug_trace_step.bind(-1))
	picker.add_child(previous)
	_debug_trace_label = _label("", 16, CYAN)
	_debug_trace_label.name = "DebugTraceLabel"
	_debug_trace_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_debug_trace_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_debug_trace_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	picker.add_child(_debug_trace_label)
	var next := _button(&"DebugTraceNext", "›", CYAN, 44.0)
	next.custom_minimum_size.x = 52.0
	next.pressed.connect(_on_debug_trace_step.bind(1))
	picker.add_child(next)

	_debug_trace_watch = _button(
		&"DebugTraceWatch", "WATCH · NO AWARDS", CYAN, 44.0)
	_debug_trace_watch.custom_minimum_size.x = 220.0
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
	_fill_with_margin(body, card, 12.0)
	body.add_child(_setting_heading("START DISTANCE"))
	var description := _setting_description(
		"Type metres, use 100 m steps, or choose a preset.")
	description.add_theme_font_size_override("font_size", 14)
	body.add_child(description)

	var adjustment := HBoxContainer.new()
	adjustment.add_theme_constant_override("separation", 10)
	body.add_child(adjustment)
	var minus := _button(&"DebugDistanceMinus", "−", CYAN, 64.0)
	minus.custom_minimum_size.x = 60.0
	minus.add_theme_font_size_override("font_size", 34)
	minus.pressed.connect(_on_debug_distance_adjust.bind(-1))
	adjustment.add_child(minus)
	_quick_debug_run_distance_entry = _debug_distance_entry(
		&"DebugRunDistanceEntry")
	_quick_debug_run_distance_entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	adjustment.add_child(_quick_debug_run_distance_entry)
	var plus := _button(&"DebugDistancePlus", "+", CYAN, 64.0)
	plus.custom_minimum_size.x = 60.0
	plus.add_theme_font_size_override("font_size", 32)
	plus.pressed.connect(_on_debug_distance_adjust.bind(1))
	adjustment.add_child(plus)

	var presets := HBoxContainer.new()
	presets.add_theme_constant_override("separation", 8)
	body.add_child(presets)
	var quick_values: Array[float] = [0.0, 50000.0, 100000.0, 250000.0]
	var quick_labels := ["0", "5k", "10k", "25k"]
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
	_quick_debug_run_distance_value = _label("", 16, CYAN)
	_quick_debug_run_distance_value.name = "DebugRunDistanceValue"
	_quick_debug_run_distance_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_quick_debug_run_distance_value.custom_minimum_size.y = 26.0
	body.add_child(_quick_debug_run_distance_value)
	return card


func _build_debug_upgrade_card() -> PanelContainer:
	var card := _panel(PANEL_SOFT, 16, ORANGE)
	card.name = "DebugRunUpgradeCard"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 8)
	_fill_with_margin(body, card, 12.0)
	body.add_child(_setting_heading("TEMPORARY UPGRADES"))
	var description := _setting_description(
		"Use one temporary level across every track. Nothing is purchased.")
	description.add_theme_font_size_override("font_size", 14)
	body.add_child(description)

	var adjustment := HBoxContainer.new()
	adjustment.add_theme_constant_override("separation", 10)
	body.add_child(adjustment)
	var minus := _button(&"DebugUpgradeMinus", "−", ORANGE, 64.0)
	minus.custom_minimum_size.x = 60.0
	minus.add_theme_font_size_override("font_size", 34)
	minus.pressed.connect(_on_debug_upgrade_adjust.bind(-1))
	adjustment.add_child(minus)
	var value_panel := _panel(Color("071c23"), 10, ORANGE)
	value_panel.custom_minimum_size.y = 64.0
	value_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	adjustment.add_child(value_panel)
	_quick_debug_run_upgrade_value = _label("", 21, YELLOW)
	_quick_debug_run_upgrade_value.name = "DebugRunUpgradeValue"
	_quick_debug_run_upgrade_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_fill_with_margin(_quick_debug_run_upgrade_value, value_panel, 6.0)
	var plus := _button(&"DebugUpgradePlus", "+", ORANGE, 64.0)
	plus.custom_minimum_size.x = 60.0
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
		"− from L0 = OWNED · + from OWNED = L0",
		13,
		ORANGE,
	)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
	_fill_with_margin(body, card, 10.0)
	body.add_child(_setting_heading("PURSUING BIRD · ASSUMED"))
	var description := _setting_description(
		"Choose a chase preset or tune its three values. Speed 0 is off.")
	description.add_theme_font_size_override("font_size", 14)
	body.add_child(description)
	for parameter_id: StringName in [
		&"bird_speed", &"bird_acceleration", &"bird_start_offset",
	]:
		body.add_child(_build_debug_bird_row(parameter_id))

	var presets := HBoxContainer.new()
	presets.name = "DebugQuickBirdPresets"
	presets.add_theme_constant_override("separation", 5)
	body.add_child(presets)
	for preset_id: StringName in [&"off", &"slow", &"base", &"fast"]:
		var button := _button(
			StringName("DebugQuickBirdPreset_%s" % preset_id),
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
	label.name = "DebugQuickBirdLabel_%s" % parameter_id
	label.custom_minimum_size.x = 78.0
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(label)
	var minus := _button(
		StringName("DebugQuickBirdMinus_%s" % parameter_id), "−", GREEN, 48.0)
	minus.custom_minimum_size.x = 44.0
	minus.add_theme_font_size_override("font_size", 25)
	minus.pressed.connect(_on_debug_bird_adjust.bind(parameter_id, -1))
	row.add_child(minus)
	var value := _label("", 14, YELLOW)
	value.name = "DebugQuickBirdValue_%s" % parameter_id
	value.custom_minimum_size = Vector2(76.0, 48.0)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(value)
	_quick_debug_bird_values[parameter_id] = value
	var plus := _button(
		StringName("DebugQuickBirdPlus_%s" % parameter_id), "+", GREEN, 48.0)
	plus.custom_minimum_size.x = 44.0
	plus.add_theme_font_size_override("font_size", 23)
	plus.pressed.connect(_on_debug_bird_adjust.bind(parameter_id, 1))
	row.add_child(plus)
	return row


func _build_field_guide() -> void:
	_field_guide = _full_screen(&"FieldGuide")
	_field_guide_back = _button(&"FieldGuideBack", "‹  BACK", CYAN, 50.0)
	_field_guide_back.pressed.connect(_on_leave_field_guide)
	_place(_field_guide_back, _field_guide, 0.025, 0.03, 0.16, 0.105)
	var heading := _label("SPIDER FIELD GUIDE", 36, INK)
	_place(heading, _field_guide, 0.19, 0.025, 0.55, 0.10)
	var frame_note := _label(
		"Choose a spider, then compare the real animal with the ability invented for the game.",
		15,
		MUTED,
	)
	frame_note.name = "FieldGuideFrame"
	_place(frame_note, _field_guide, 0.19, 0.09, 0.92, 0.145)

	var index_card := _panel(PANEL)
	index_card.name = "FieldGuideIndex"
	_place(index_card, _field_guide, 0.035, 0.16, 0.31, 0.95)
	var index := VBoxContainer.new()
	index.add_theme_constant_override("separation", 8)
	_fill_with_margin(index, index_card, 14.0)
	index.add_child(_section_label("SPECIES INDEX"))
	var index_help := _label(
		"REAL names identify one animal. COMPOSITE names combine inspirations.",
		13,
		MUTED,
	)
	index_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	index_help.custom_minimum_size.y = 44.0
	index.add_child(index_help)
	for spider_id: StringName in SpiderCatalog.ALL_IDS:
		var profile_item := SpiderCatalog.profile(spider_id)
		var bio := SpiderBiologyCatalog.record(spider_id)
		var inspiration := StringName(bio.get("inspiration", &""))
		var button := _button(
			StringName("FieldGuideEntry%s" % str(spider_id).to_pascal_case()),
			"%s\n%s" % [
				str(profile_item["name"]).to_upper(),
				SpiderBiologyCatalog.inspiration_label(inspiration),
			],
			ORANGE if inspiration == SpiderBiologyCatalog.FICTIONAL else GREEN,
			68.0,
		)
		button.add_theme_font_size_override("font_size", 15)
		button.pressed.connect(_on_field_guide_spider.bind(spider_id))
		index.add_child(button)
		_field_guide_buttons[spider_id] = button

	var detail := _panel(PANEL)
	detail.name = "FieldGuideDetail"
	_place(detail, _field_guide, 0.33, 0.15, 0.965, 0.96)
	var detail_body := VBoxContainer.new()
	detail_body.add_theme_constant_override("separation", 8)
	_fill_with_margin(detail_body, detail, 18.0)
	var identity := HBoxContainer.new()
	identity.name = "FieldGuideIdentity"
	identity.custom_minimum_size.y = 142.0
	identity.add_theme_constant_override("separation", 18)
	detail_body.add_child(identity)
	_field_guide_preview = _spider_preview(
		&"FieldGuideSpiderPreview", Vector2(230.0, 136.0))
	_field_guide_preview.custom_minimum_size.x = 230.0
	identity.add_child(_field_guide_preview)
	var identity_copy := VBoxContainer.new()
	identity_copy.add_theme_constant_override("separation", 5)
	identity_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity.add_child(identity_copy)
	_field_guide_badge = _section_label("")
	identity_copy.add_child(_field_guide_badge)
	_field_guide_title = _label("", 32, INK)
	identity_copy.add_child(_field_guide_title)
	_field_guide_inspiration = _label("", 16, CYAN)
	_field_guide_inspiration.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	identity_copy.add_child(_field_guide_inspiration)

	var scroll := ScrollContainer.new()
	scroll.name = "FieldGuideScroll"
	SpiderUiTheme.configure_touch_scroll(scroll)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_body.add_child(scroll)
	var sections := VBoxContainer.new()
	sections.name = "FieldGuideSections"
	sections.add_theme_constant_override("separation", 10)
	sections.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(sections)
	var real_section := _field_guide_section(
		"REAL ANIMAL", "What biologists actually observe", GREEN)
	sections.add_child(real_section["panel"])
	_field_guide_real = real_section["body"] as Label
	var game_section := _field_guide_section(
		"IN SPIDER SWING", "The ability and trade-off created for play", YELLOW)
	sections.add_child(game_section["panel"])
	_field_guide_game = game_section["body"] as Label
	var note_section := _field_guide_section(
		"FIELD NOTE", "A useful myth correction or design boundary", ORANGE)
	sections.add_child(note_section["panel"])
	_field_guide_note = note_section["body"] as Label
	var source_section := _field_guide_section(
		"SOURCES", "Publishers used for the real-world description", CYAN)
	sections.add_child(source_section["panel"])
	_field_guide_sources = source_section["body"] as Label
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
	detail_body.add_child(provenance)


func _field_guide_section(
	title_text: String,
	caption_text: String,
	accent: Color,
) -> Dictionary:
	var panel := _panel(PANEL_SOFT, 14, accent)
	panel.name = "FieldGuideSection%s" % title_text.to_pascal_case()
	panel.custom_minimum_size.y = 104.0
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 3)
	_fill_with_margin(body, panel, 12.0)
	var header := HBoxContainer.new()
	body.add_child(header)
	var title := _label(title_text, 17, accent)
	title.custom_minimum_size.x = 170.0
	header.add_child(title)
	var caption := _label(caption_text, 13, MUTED)
	caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(caption)
	var copy := _label("", 16, INK)
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.custom_minimum_size.y = 50.0
	body.add_child(copy)
	return {"panel": panel, "body": copy}


func _render() -> void:
	if _state == null:
		return
	_home.visible = _state.screen == FrontEndState.Screen.HOME
	_spider_hub.visible = _state.screen == FrontEndState.Screen.SPIDER_HUB
	_play_modes_hub.visible = \
		_state.screen == FrontEndState.Screen.PLAY_MODES_HUB
	_guide_hub.visible = _state.screen == FrontEndState.Screen.GUIDE_HUB
	_tutorial.visible = _state.screen == FrontEndState.Screen.TUTORIAL
	_settings.visible = _state.screen == FrontEndState.Screen.SETTINGS
	_garage.visible = _state.screen == FrontEndState.Screen.GARAGE
	_shop.visible = _state.screen == FrontEndState.Screen.SHOP
	_creator.visible = _state.screen == FrontEndState.Screen.CREATOR
	_practice.visible = _state.screen == FrontEndState.Screen.PRACTICE
	if _home.visible:
		_refresh_difficulty_buttons()
	if _home.visible or _spider_hub.visible:
		_render_home()
	_campaign.visible = _state.screen == FrontEndState.Screen.CAMPAIGN
	if _campaign.visible:
		_refresh_campaign_buttons()
	_debug_run_setup.visible = \
		_state.screen == FrontEndState.Screen.DEBUG_RUN_SETUP and \
		_state.settings.show_debug_tools
	_debug_test_lab.visible = \
		_state.screen == FrontEndState.Screen.DEBUG_TEST_LAB and \
		_state.settings.show_debug_tools
	_field_guide.visible = _state.screen == FrontEndState.Screen.FIELD_GUIDE
	_debug_run_route.visible = _state.settings.show_debug_tools
	if _field_guide.visible:
		match _state.field_guide_return_screen:
			FrontEndState.Screen.GARAGE:
				_field_guide_back.text = "‹  GARAGE"
			FrontEndState.Screen.GUIDE_HUB:
				_field_guide_back.text = "‹  GUIDE"
			_:
				_field_guide_back.text = "‹  HOME"
		_render_field_guide()
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
	_music_volume_slider.value = _state.settings.music_volume * 100.0
	_music_volume_value.text = (
		"OFF"
		if _state.settings.music_volume <= PlayerSettings.MIN_MUSIC_VOLUME
		else "%d%%" % roundi(_state.settings.music_volume * 100.0)
	)
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


func _render_home() -> void:
	var spider_id := _state.progress.selected_spider_id
	var profile_item := SpiderCatalog.profile(spider_id)
	var accent := SpiderUiTheme.profile_accent(spider_id)
	_sync_spider_preview(_home_spider_preview, spider_id)
	_sync_spider_preview(_spider_hub_preview, spider_id)
	_home_spider_name.text = str(profile_item["name"]).to_upper()
	_home_spider_name.add_theme_color_override("font_color", accent)
	_spider_hub_name.text = str(profile_item["name"]).to_upper()
	_spider_hub_name.add_theme_color_override("font_color", accent)
	var best_metres := _state.progress.best_distance_for_mode(
		_state.selected_difficulty()) / CourseRegionCatalog.PIXELS_PER_METRE
	var summary := "%s · %s\n%s" % [
		str(profile_item["role"]),
		str(DifficultyCatalog.resolve(_state.selected_difficulty())).to_upper(),
		"BEST %.0f m" % best_metres if best_metres > 0.0 else "NO RUN YET",
	]
	_home_run_summary.text = summary
	_spider_hub_summary.text = summary


func _render_field_guide() -> void:
	var spider_id := _state.field_guide_spider_id
	var profile_item := SpiderCatalog.profile(spider_id)
	var bio := SpiderBiologyCatalog.record(spider_id)
	var inspiration := StringName(bio.get("inspiration", &""))
	var accent := ORANGE if inspiration == SpiderBiologyCatalog.FICTIONAL else GREEN
	for candidate_id: StringName in _field_guide_buttons:
		_set_selector_state(
			_field_guide_buttons[candidate_id] as Button,
			candidate_id == spider_id,
			accent if candidate_id == spider_id else CYAN,
		)
	_sync_spider_preview(_field_guide_preview, spider_id)
	_field_guide_title.text = str(profile_item["name"]).to_upper()
	_field_guide_title.add_theme_color_override("font_color", accent)
	_field_guide_badge.text = SpiderBiologyCatalog.inspiration_label(inspiration)
	_field_guide_badge.add_theme_color_override("font_color", accent)
	_field_guide_inspiration.text = "INSPIRED BY · %s\n%s" % [
		bio.get("inspired_by", ""),
		bio.get("hook", ""),
	]
	var scientific := SpiderBiologyCatalog.scientific_line(spider_id)
	var drawn_from := SpiderBiologyCatalog.drawn_from_line(spider_id)
	_field_guide_real.text = "%s%s" % [
		("SCIENTIFIC IDENTITY · %s\n\n" % scientific) if not scientific.is_empty()
		else "",
		str(bio.get("real_trait", "")),
	]
	if SpiderBiologyCatalog.has_invented_name(spider_id) and not drawn_from.is_empty():
		_field_guide_real.text += "\n\nBIOLOGY BORROWED FROM · %s" % drawn_from
	_field_guide_game.text = str(bio.get("game_adaptation", ""))
	var correction := str(bio.get("correction", ""))
	_field_guide_note.text = (
		correction if not correction.is_empty()
		else "No additional myth correction is recorded for this profile."
	)
	var source_lines := PackedStringArray()
	for source: Dictionary in SpiderBiologyCatalog.sources_for(spider_id):
		source_lines.append("• %s — %s" % [
			source["publisher"],
			source["title"],
		])
	_field_guide_sources.text = "\n".join(source_lines)


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
	for entry: LineEdit in [
		_quick_debug_run_distance_entry,
		_debug_run_distance_entry,
	]:
		if entry == null or entry.has_focus():
			continue
		_syncing_debug_run_setup = true
		entry.text = _format_debug_distance_metres(
			_state.debug_run_distance_pixels,
		)
		_syncing_debug_run_setup = false
	_quick_debug_run_distance_value.text = "STARTING AT %s m" % \
		_format_debug_distance_metres(_state.debug_run_distance_pixels)
	_quick_debug_run_upgrade_value.text = _format_debug_tuning_value(
		TuningCatalog.DEBUG_UPGRADE_LEVEL,
		float(_state.debug_run_upgrade_level),
	)
	for parameter_id: StringName in _quick_debug_bird_values:
		(_quick_debug_bird_values[parameter_id] as Label).text = \
			_format_debug_tuning_value(
				parameter_id,
				float(_state.debug_bird_overrides()[str(parameter_id)]),
			)
	for parameter_id: StringName in _debug_tuning_values:
		(_debug_tuning_values[parameter_id] as Label).text = \
			_format_debug_tuning_value(
				parameter_id,
				_state.debug_tuning_value(parameter_id),
			)
	var category := TuningCatalog.category(_state.debug_category_index)
	var active_category_id := StringName(category["id"])
	for category_id: StringName in _debug_category_panels:
		(_debug_category_panels[category_id] as Control).visible = \
			category_id == active_category_id
		_set_selector_state(
			_debug_category_buttons[category_id] as Button,
			category_id == active_category_id,
			CYAN,
		)
	_debug_profile_status.text = "%s · %d values in the working comparison" % [
		str(category["label"]),
		TuningCatalog.parameter_ids().size(),
	]
	for slot_id: StringName in DebugTestProfile.SLOT_IDS:
		var load := _debug_profile_load_buttons[slot_id] as Button
		var difference := _state.debug_test_profile.slot_difference_count(slot_id)
		load.disabled = difference < 0
		load.text = (
			"EMPTY"
			if difference < 0
			else "LOAD %s · %s" % [
				str(slot_id).to_upper(),
				"SAME" if difference == 0 else "%d DIFF" % difference,
			]
		)
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


func _on_spider_hub() -> void:
	if _state != null:
		_state.show_spider_hub()


func _on_play_modes_hub() -> void:
	if _state != null:
		_state.show_play_modes_hub()


func _on_guide_hub() -> void:
	if _state != null:
		_state.show_guide_hub()


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


func _on_field_guide_spider(spider_id: StringName) -> void:
	if _state != null:
		_state.select_field_guide_spider(spider_id)


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
	var selected_name := "ENDLESS"
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
		if bool(mode["selected"]):
			selected_name = str(mode["name"]).to_upper()
	_home_play_button.text = \
		"PLAY ENDLESS  ·  %s\nCHASE YOUR BEST DISTANCE" % selected_name


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


func _on_debug_test_lab() -> void:
	if _state != null:
		_state.show_debug_test_lab()


func _on_debug_category(category_index: int) -> void:
	if _state != null:
		_state.select_debug_category(category_index)


func _on_debug_tuning_adjust(
	parameter_id: StringName,
	direction: int,
) -> void:
	if _state != null:
		_state.adjust_debug_tuning_value(parameter_id, direction)


func _on_debug_tuning_set(
	parameter_id: StringName,
	value: float,
) -> void:
	if _state != null:
		_state.set_debug_tuning_value(parameter_id, value)


func _on_debug_profile_save(slot_id: StringName) -> void:
	if _state != null:
		_state.save_debug_test_slot(slot_id)


func _on_debug_profile_load(slot_id: StringName) -> void:
	if _state != null:
		_state.load_debug_test_slot(slot_id)


func _on_debug_profile_reset() -> void:
	if _state != null:
		_state.reset_debug_test_profile()


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


func _on_quick_debug_run_start() -> void:
	if _state == null:
		return
	_commit_debug_run_distance()
	_state.request_quick_debug_play()


func _commit_debug_run_distance() -> void:
	if _state == null:
		return
	var entry := _debug_run_distance_entry
	if _state.screen == FrontEndState.Screen.DEBUG_RUN_SETUP:
		entry = _quick_debug_run_distance_entry
	if entry == null:
		return
	var normalized := entry.text.strip_edges().replace(
		",",
		".",
	)
	if normalized.is_valid_float():
		_state.set_debug_run_distance_pixels(
			float(normalized) * CourseRegionCatalog.PIXELS_PER_METRE,
		)
	_syncing_debug_run_setup = true
	entry.text = _format_debug_distance_metres(
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


func _on_music_volume_changed(value: float) -> void:
	if _state != null and not _syncing_settings:
		_state.set_music_volume(value / 100.0)


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


func _debug_distance_entry(
	node_name: StringName = &"DebugTestLabDistanceEntry",
) -> LineEdit:
	var entry := LineEdit.new()
	entry.name = str(node_name)
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


func _format_debug_tuning_value(
	parameter_id: StringName,
	value: float,
) -> String:
	var descriptor := TuningCatalog.descriptor(parameter_id)
	var format := StringName(descriptor.get("format", &"number"))
	match format:
		&"toggle":
			return "ON" if value >= 0.5 else "OFF"
		&"percent":
			return "%.0f%%" % (value * 100.0)
		&"seconds":
			return "%.2f s" % value
		&"pixels":
			if parameter_id == &"bird_start_offset":
				return "%.0f m GAP" % (
					value / CourseRegionCatalog.PIXELS_PER_METRE)
			return "%.0f px" % value
		&"speed":
			if parameter_id == &"bird_speed" and is_zero_approx(value):
				return "OFF"
			return "%.1f m/s" % (
				value / CourseRegionCatalog.PIXELS_PER_METRE)
		&"speed_gain":
			return "+%.1f m/s / km" % (
				value / CourseRegionCatalog.PIXELS_PER_METRE)
		&"meters":
			return "%.0f m" % (
				value / CourseRegionCatalog.PIXELS_PER_METRE)
		&"debug_level":
			return (
				"OWNED LEVELS" if value < 0.0
				else "LEVEL %d / %d" % [
					roundi(value),
					SpiderCatalog.MAX_UPGRADE_LEVEL,
				]
			)
		_:
			return "%.0f" % value


func _quick_tuning_label(parameter_id: StringName, value: float) -> String:
	var descriptor := TuningCatalog.descriptor(parameter_id)
	var format := StringName(descriptor.get("format", &"number"))
	match format:
		&"toggle":
			return "ON" if value >= 0.5 else "OFF"
		&"percent":
			return "%.0f%%" % (value * 100.0)
		&"seconds":
			return "%.1fs" % value
		&"speed":
			return "%.0f" % (
				value / CourseRegionCatalog.PIXELS_PER_METRE)
		&"speed_gain":
			return "+%.1f" % (
				value / CourseRegionCatalog.PIXELS_PER_METRE)
		&"meters":
			return "%.0fm" % (
				value / CourseRegionCatalog.PIXELS_PER_METRE)
		&"debug_level":
			if value < 0.0:
				return "OWNED"
			if roundi(value) == SpiderCatalog.MAX_UPGRADE_LEVEL:
				return "MAX"
			return "L%d" % roundi(value)
		_:
			return "%.0f" % value


func _toggle(text_value: String) -> CheckButton:
	var toggle := CheckButton.new()
	toggle.text = text_value
	toggle.custom_minimum_size.y = 58.0
	toggle.add_theme_font_size_override("font_size", 23)
	toggle.add_theme_color_override("font_color", INK)
	return toggle
