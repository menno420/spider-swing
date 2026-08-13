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
	+ "increase twice. Flies are earned in play — nothing here costs money."
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
var _home_best_caption: Label
var _home_best_value: Label
var _home_region_label: Label
var _loadout_chips: Array[Dictionary] = []
var _rail_badges: Dictionary = {}
var _spider_hub_preview: TextureRect
var _spider_hub_name: Label
var _spider_hub_summary: Label
var _spider_hub_status: Label
var _play_modes_status: Label
var _guide_hub_status: Label
var _tutorial: Control
var _settings: Control
var _garage: Control
var _shop: Control
var _creator: Control
var _practice: Control
var _campaign: Control
var _run_history: Control
var _run_history_scroll: ScrollContainer
var _run_history_content: VBoxContainer
var _run_history_lifetime: Label
var _run_history_latest: Label
var _run_history_recent: VBoxContainer
var _run_history_export_text: TextEdit
var _run_history_export_status: Label
var _run_history_view_json: Button
var _run_history_copy_json: Button
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
var _tutorial_point_panels: Array[Control] = []
var _tutorial_point_cues: Array[Label] = []
var _tutorial_point_texts: Array[Label] = []
var _tutorial_progress: Label
var _tutorial_action: Button
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
	_build_run_history()
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
	# Home is the run you are about to start, not an index of places to go. The
	# deck states the target and the loadout, the destinations demote to a rail,
	# and one filled control is the only thing on screen that looks pressable at
	# a glance. [D-0053]
	var deck := HBoxContainer.new()
	deck.add_theme_constant_override("separation", 14)
	_fill_with_margin(deck, card, 14.0)
	var run_column := VBoxContainer.new()
	run_column.name = "HomeRunColumn"
	run_column.add_theme_constant_override("separation", 10)
	run_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	deck.add_child(run_column)

	# Difficulty governs the standard PLAY run, so it is chosen here rather
	# than buried in Settings.
	run_column.add_child(_section_label("ENDLESS RUN · DIFFICULTY"))
	var difficulty_row := GridContainer.new()
	difficulty_row.name = "HomeDifficultyRow"
	difficulty_row.columns = 3
	difficulty_row.add_theme_constant_override("h_separation", 8)
	run_column.add_child(difficulty_row)
	for mode: Dictionary in DifficultyCatalog.all_modes():
		var mode_id := StringName(mode["id"])
		var button := _button(
			StringName("Difficulty_%s" % mode_id),
			str(mode["name"]),
			CYAN,
			84.0,
		)
		button.add_theme_font_size_override("font_size", 17)
		button.pressed.connect(_on_difficulty.bind(mode_id))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		difficulty_row.add_child(button)
		_difficulty_buttons[mode_id] = button

	run_column.add_child(_build_home_target_card())
	run_column.add_child(_section_label("RUN LOADOUT"))
	run_column.add_child(_build_home_loadout_row())

	_home_play_button = _button(
		&"Play",
		"▶  START RUN",
		GREEN,
		116.0,
	)
	_home_play_button.add_theme_font_size_override("font_size", 30)
	# The only filled control in the front end. Everything else is an outline, so
	# the eye lands here without having to compare border hues.
	_home_play_button.add_theme_stylebox_override(
		"normal", SpiderUiTheme.hero_style(GREEN))
	_home_play_button.add_theme_stylebox_override(
		"hover", SpiderUiTheme.hero_style(CYAN))
	_home_play_button.add_theme_color_override("font_color", DEEP)
	_home_play_button.add_theme_color_override("font_hover_color", DEEP)
	_home_play_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_home_play_button.pressed.connect(_on_play)
	run_column.add_child(_home_play_button)

	deck.add_child(_build_home_rail())


func _build_home_target_card() -> PanelContainer:
	var target := _panel(Color(PANEL_SOFT, 0.96), 14, CYAN)
	target.name = "HomeTargetCard"
	target.custom_minimum_size.y = 128.0
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 14)
	_fill_with_margin(body, target, 16.0)
	var figure := VBoxContainer.new()
	figure.add_theme_constant_override("separation", 0)
	figure.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	body.add_child(figure)
	_home_best_caption = _label("", 14, CYAN)
	_home_best_caption.name = "HomeBestCaption"
	figure.add_child(_home_best_caption)
	_home_best_value = _label("", 46, INK)
	_home_best_value.name = "HomeBestValue"
	figure.add_child(_home_best_value)
	_home_region_label = _label("", 15, MUTED)
	_home_region_label.name = "HomeRegionLabel"
	_home_region_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_home_region_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_home_region_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_home_region_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(_home_region_label)
	return target


func _build_home_loadout_row() -> GridContainer:
	var row := GridContainer.new()
	row.name = "HomeLoadoutRow"
	row.columns = 3
	row.add_theme_constant_override("h_separation", 8)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var accents: Array[Color] = [GREEN, ORANGE, CYAN]
	for index in range(3):
		var accent := accents[index]
		var chip := _panel(Color(PANEL_SOFT, 0.96), 12, accent)
		chip.name = "HomeLoadoutChip%d" % index
		chip.custom_minimum_size.y = 116.0
		chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		chip.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var body := VBoxContainer.new()
		body.add_theme_constant_override("separation", 2)
		_fill_with_margin(body, chip, 11.0)
		var heading := HBoxContainer.new()
		body.add_child(heading)
		var name_label := _label("", 15, accent)
		name_label.name = "HomeLoadoutName%d" % index
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		heading.add_child(name_label)
		var level_label := _label("", 22, INK)
		level_label.name = "HomeLoadoutLevel%d" % index
		heading.add_child(level_label)
		var detail := _label("", 14, MUTED)
		detail.name = "HomeLoadoutDetail%d" % index
		detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
		body.add_child(detail)
		var meter := ProgressBar.new()
		meter.name = "HomeLoadoutMeter%d" % index
		meter.show_percentage = false
		meter.custom_minimum_size.y = 7.0
		meter.max_value = 1.0
		meter.add_theme_stylebox_override(
			"background", SpiderUiTheme.meter_style(Color(INK, 0.12)))
		meter.add_theme_stylebox_override(
			"fill", SpiderUiTheme.meter_style(accent))
		body.add_child(meter)
		row.add_child(chip)
		_loadout_chips.append({
			"name": name_label,
			"level": level_label,
			"detail": detail,
			"meter": meter,
		})
	return row


## The four intention routes survive D-0047 unchanged; only their shape moves.
## A rail keeps each one a full-width target with room for the number that says
## whether it is worth opening, which a two-line label never had.
func _build_home_rail() -> VBoxContainer:
	var rail := VBoxContainer.new()
	rail.name = "HomeRouteGrid"
	rail.add_theme_constant_override("separation", 8)
	rail.custom_minimum_size.x = 214.0
	var routes := [
		[&"SpiderHub", "SPIDER", "choose · style · improve", YELLOW,
			_on_spider_hub],
		[&"PlayModesHub", "PLAY MODES", "campaign · practice · creator", ORANGE,
			_on_play_modes_hub],
		[&"GuideHub", "GUIDE", "learn controls · meet spiders", CYAN,
			_on_guide_hub],
		[&"Settings", "SETTINGS", "sound · motion · access", GREEN,
			_on_settings],
	]
	for route: Array in routes:
		var button := _rail_route_button(
			route[0] as StringName,
			route[1] as String,
			route[2] as String,
			route[3] as Color,
		)
		button.pressed.connect(route[4] as Callable)
		rail.add_child(button)
	_debug_run_route = _button(
		&"DebugRunSetup",
		"DEBUG TEST RUN\nQUICK SETUP · AWARDS NOTHING",
		ORANGE,
		64.0,
	)
	_debug_run_route.add_theme_font_size_override("font_size", 12)
	_debug_run_route.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_debug_run_route.pressed.connect(_on_debug_run_setup)
	_debug_run_route.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rail.add_child(_debug_run_route)
	return rail


## Sized against the thumb, not the reference viewport. `canvas_items`/`expand`
## maps 1280×720 onto a 2340×1080 phone at 1.5×, and an xxhdpi screen is
## 2.5 device px per dp, so a reference pixel is 0.6 dp: the 48 dp minimum this
## project targets is 80 reference pixels.
func _rail_route_button(
	button_name: StringName,
	title: String,
	subtitle: String,
	accent: Color,
) -> Button:
	var button := _button(button_name, "%s\n%s" % [title, subtitle], accent, 92.0)
	button.add_theme_font_size_override("font_size", 16)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# The badge rides on top of the button and never takes the tap, so the whole
	# rail item stays one event-consuming control.
	var badge := _label("", 15, accent)
	badge.name = "%sBadge" % button_name
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	badge.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	badge.set_anchors_preset(Control.PRESET_FULL_RECT)
	badge.offset_left = 10.0
	badge.offset_right = -12.0
	badge.offset_top = 8.0
	button.add_child(badge)
	_rail_badges[button_name] = badge
	return button


func _build_spider_hub() -> void:
	_spider_hub = _full_screen(&"SpiderHubScreen")
	var back := _button(&"SpiderHubBack", "‹  HOME", CYAN, 64.0)
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
	# Measured 247 px unused in this panel; the two routes absorb it.
	var garage := _hub_route_button(
		&"Garage", "SPIDER GARAGE\nchoose spider · body · silk", YELLOW)
	garage.pressed.connect(_on_garage)
	route_body.add_child(garage)
	var shop := _hub_route_button(
		&"Shop", "UPGRADES\ninspect tracks · spend flies", GREEN)
	shop.pressed.connect(_on_shop)
	route_body.add_child(shop)
	_spider_hub_status = _hub_status_panel(&"SpiderHubStatus")
	route_body.add_child(_spider_hub_status)


func _build_play_modes_hub() -> void:
	_play_modes_hub = _full_screen(&"PlayModesHubScreen")
	var back := _button(&"PlayModesHubBack", "‹  HOME", CYAN, 64.0)
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
	routes.columns = 4
	routes.add_theme_constant_override("h_separation", 16)
	routes.size_flags_vertical = Control.SIZE_EXPAND_FILL
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
	var history := _hub_route_button(
		&"RunHistory", "RUN HISTORY\nlocal evidence · JSON export", GREEN)
	history.pressed.connect(_on_run_history)
	routes.add_child(history)
	_play_modes_status = _hub_status_panel(&"PlayModesHubStatus")
	body.add_child(_play_modes_status)
	body.add_child(_setting_description(
		"Campaign awards stars. Practice and Course Lab are noncompetitive. Run History keeps local evidence separate from records and leaderboards."))


func _build_guide_hub() -> void:
	_guide_hub = _full_screen(&"GuideHubScreen")
	var back := _button(&"GuideHubBack", "‹  HOME", CYAN, 64.0)
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
	routes.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(routes)
	var tutorial := _hub_route_button(
		&"Tutorial", "HOW TO SWING\neight focused lessons · live previews", CYAN)
	tutorial.pressed.connect(_on_tutorial)
	routes.add_child(tutorial)
	var field_guide := _hub_route_button(
		&"FieldGuide", "SPIDER FIELD GUIDE\nreal animal · game ability · sources", YELLOW)
	field_guide.pressed.connect(
		_on_field_guide.bind(FrontEndState.Screen.GUIDE_HUB))
	routes.add_child(field_guide)
	_guide_hub_status = _hub_status_panel(&"GuideHubStatus")
	body.add_child(_guide_hub_status)
	body.add_child(_setting_description(
		"How to Swing teaches the controls. Field Guide explains identity and biology without mixing them into gameplay rules."))


func _hub_route_button(
	button_name: StringName,
	text_value: String,
	accent: Color,
) -> Button:
	var button := _button(button_name, text_value, accent, 132.0)
	button.add_theme_font_size_override("font_size", 18)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return button


## The hubs measured 48–57% empty. Letting the route cards absorb all of it made
## 400 px slabs, which is dead space wearing a border. Each hub instead ends in a
## block of live state, so the space answers "is it worth going in there?" — the
## context panel the research report asks a route list to carry.
func _hub_status_panel(status_name: StringName) -> Label:
	var status := _label("", 16, MUTED)
	status.name = status_name
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	status.size_flags_vertical = Control.SIZE_EXPAND_FILL
	status.custom_minimum_size.y = 48.0
	return status


func _build_tutorial() -> void:
	_tutorial = _full_screen(&"Tutorial")
	var back := _button(&"TutorialBack", "‹  GUIDE", CYAN, 80.0)
	back.pressed.connect(_on_guide_hub)
	_place(back, _tutorial, 0.025, 0.02, 0.18, 0.19)

	_tutorial_preview = TutorialPreview.new()
	_tutorial_preview.name = "AnimatedMechanicsPreview"
	_place(_tutorial_preview, _tutorial, 0.03, 0.20, 0.56, 0.78)

	var copy_card := _panel(PANEL)
	copy_card.name = "TutorialCopyWebPanel"
	_place(copy_card, _tutorial, 0.58, 0.11, 0.97, 0.79)
	var copy := VBoxContainer.new()
	copy.add_theme_constant_override("separation", 7)
	_fill_with_margin(copy, copy_card, 14.0)
	_tutorial_kicker = _section_label("")
	copy.add_child(_tutorial_kicker)
	_tutorial_title = _label("", 28, INK)
	_tutorial_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tutorial_title.custom_minimum_size.y = 38.0
	copy.add_child(_tutorial_title)
	var point_stack := VBoxContainer.new()
	point_stack.name = "TutorialTeachingPoints"
	point_stack.add_theme_constant_override("separation", 6)
	point_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	copy.add_child(point_stack)
	for index in range(FrontEndState.TUTORIAL_POINT_COUNT):
		var point_panel := _panel(
			Color("101c18f2"),
			11,
			Color(CYAN, 0.42),
		)
		point_panel.name = "TutorialPointCard%d" % (index + 1)
		point_panel.custom_minimum_size.y = 58.0
		point_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
		point_stack.add_child(point_panel)
		_tutorial_point_panels.append(point_panel)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 9)
		_fill_with_margin(row, point_panel, 8.0)
		var cue := _label("", 13, CYAN)
		cue.name = "TutorialPointCue%d" % (index + 1)
		cue.custom_minimum_size.x = 88.0
		cue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cue.add_theme_constant_override("outline_size", 3)
		cue.add_theme_color_override("font_outline_color", DEEP)
		row.add_child(cue)
		_tutorial_point_cues.append(cue)
		var point_text := _label("", 17, INK)
		point_text.name = "TutorialPointText%d" % (index + 1)
		point_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		point_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(point_text)
		_tutorial_point_texts.append(point_text)

	var nav := HBoxContainer.new()
	nav.name = "TutorialNavigation"
	nav.add_theme_constant_override("separation", 10)
	_place(nav, _tutorial, 0.04, 0.81, 0.96, 0.98)
	var previous := _button(&"TutorialPrevious", "PREVIOUS", MUTED, 80.0)
	previous.pressed.connect(_on_tutorial_previous)
	previous.custom_minimum_size.x = 150.0
	nav.add_child(previous)
	_tutorial_progress = _label("", 17, MUTED)
	_tutorial_progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tutorial_progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nav.add_child(_tutorial_progress)
	_tutorial_action = _button(&"TutorialLessonAction", "START RUN", ORANGE, 80.0)
	_tutorial_action.pressed.connect(_on_tutorial_action)
	_tutorial_action.custom_minimum_size.x = 190.0
	nav.add_child(_tutorial_action)
	_tutorial_next = _button(&"TutorialNext", "NEXT", GREEN, 80.0)
	_tutorial_next.pressed.connect(_on_tutorial_next)
	_tutorial_next.custom_minimum_size.x = 150.0
	nav.add_child(_tutorial_next)


func _build_settings() -> void:
	_settings = _full_screen(&"Settings")
	var back := _button(&"SettingsBack", "‹  HOME", CYAN, 64.0)
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
	var back := _button(&"GarageBack", "‹  SPIDER", CYAN, 64.0)
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
	var field_guide := _button(&"GarageFieldGuide", "FIELD GUIDE", ORANGE, 60.0)
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
			60.0,
		)
		style_button.add_theme_font_size_override("font_size", 16)
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
			60.0,
		)
		web_button.add_theme_font_size_override("font_size", 16)
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
	var back := _button(&"ShopBack", "‹  SPIDER", CYAN, 64.0)
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
		var detail_row := HBoxContainer.new()
		detail_row.add_theme_constant_override("separation", 12)
		row_content.add_child(detail_row)
		var description := _setting_description("")
		description.name = \
			"UpgradeDescription%s" % str(upgrade_id).to_pascal_case()
		description.add_theme_font_size_override("font_size", 16)
		description.custom_minimum_size.y = 34.0
		description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		detail_row.add_child(description)
		var milestones := _label("", 15, CYAN)
		milestones.name = "UpgradeKnots%s" % str(upgrade_id).to_pascal_case()
		milestones.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		milestones.custom_minimum_size.x = 190.0
		detail_row.add_child(milestones)
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
	var back := _button(&"CreatorBack", "‹  PLAY MODES", CYAN, 64.0)
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
	var back := _button(&"PracticeBack", "‹  PLAY MODES", CYAN, 64.0)
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
	var back := _button(&"CampaignBack", "‹  PLAY MODES", CYAN, 64.0)
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
	# Six levels across two tiers no longer fit the card, so the list scrolls
	# natively like Settings and Shop rather than the card growing off-screen.
	var scroll := ScrollContainer.new()
	scroll.name = "CampaignLevelScroll"
	SpiderUiTheme.configure_touch_scroll(scroll)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)
	var levels := VBoxContainer.new()
	levels.add_theme_constant_override("separation", 12)
	levels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(levels)

	for tier: Dictionary in CampaignCatalog.tiers():
		levels.add_child(_section_label(str(tier["name"])))
		var blurb := _label(str(tier["blurb"]), 15, MUTED)
		blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		levels.add_child(blurb)
		for level: Dictionary in CampaignCatalog.levels_for_tier(
				StringName(tier["id"])):
			var level_id := StringName(level["id"])
			var button := _button(
				_campaign_button_name(level_id),
				"",
				ORANGE,
				84.0,
			)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.pressed.connect(_on_campaign_level.bind(level_id))
			levels.add_child(button)
			_campaign_buttons[level_id] = button


func _campaign_button_name(level_id: StringName) -> StringName:
	return StringName("CampaignLevel_%s" % level_id)


func _build_run_history() -> void:
	_run_history = _full_screen(&"RunHistoryScreen")
	var back := _button(&"RunHistoryBack", "‹  PLAY MODES", CYAN, 64.0)
	back.pressed.connect(_on_play_modes_hub)
	_place(back, _run_history, 0.025, 0.025, 0.17, 0.13)
	var heading := _label("RUN HISTORY", 36, INK)
	_place(heading, _run_history, 0.19, 0.025, 0.61, 0.13)
	_run_history_view_json = _button(
		&"RunHistoryViewJson", "VIEW JSON", ORANGE, 64.0)
	_run_history_view_json.pressed.connect(_on_run_history_view_toggle)
	_place(_run_history_view_json, _run_history, 0.66, 0.025, 0.81, 0.13)
	_run_history_copy_json = _button(
		&"RunHistoryCopyJson", "COPY JSON", GREEN, 64.0)
	_run_history_copy_json.pressed.connect(_on_run_history_copy)
	_place(_run_history_copy_json, _run_history, 0.825, 0.025, 0.975, 0.13)

	var card := _panel(PANEL)
	card.name = "RunHistoryWebPanel"
	_place(card, _run_history, 0.04, 0.16, 0.96, 0.91)
	_run_history_scroll = ScrollContainer.new()
	_run_history_scroll.name = "RunHistoryScroll"
	SpiderUiTheme.configure_touch_scroll(_run_history_scroll)
	_fill_with_margin(_run_history_scroll, card, 16.0)
	_run_history_content = VBoxContainer.new()
	_run_history_content.name = "RunHistoryContent"
	_run_history_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_run_history_content.add_theme_constant_override("separation", 12)
	_run_history_scroll.add_child(_run_history_content)
	_run_history_content.add_child(_section_label(
		"LOCAL ONLY · LAST %d FULL RUNS" % RunRecordLedger.HISTORY_LIMIT))
	_run_history_lifetime = _label("", 16, MUTED)
	_run_history_lifetime.name = "RunHistoryLifetimeSummary"
	_run_history_lifetime.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_run_history_lifetime.custom_minimum_size.y = 48.0
	_run_history_content.add_child(_run_history_lifetime)
	_run_history_content.add_child(_section_label("LATEST COMPLETED RUN"))
	var latest_panel := _panel(PANEL_SOFT, 14, GREEN)
	latest_panel.name = "RunHistoryLatestPanel"
	latest_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_run_history_content.add_child(latest_panel)
	_run_history_latest = _label("", 15, INK)
	_run_history_latest.name = "RunHistoryLatestSummary"
	_run_history_latest.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_run_history_latest.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_run_history_latest.custom_minimum_size.y = 178.0
	_fill_with_margin(_run_history_latest, latest_panel, 14.0)
	_run_history_content.add_child(_section_label("RECENT RUNS · NEWEST FIRST"))
	_run_history_recent = VBoxContainer.new()
	_run_history_recent.name = "RunHistoryRecentList"
	_run_history_recent.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_run_history_recent.add_theme_constant_override("separation", 8)
	_run_history_content.add_child(_run_history_recent)

	_run_history_export_text = TextEdit.new()
	_run_history_export_text.name = "RunHistoryExportJson"
	_run_history_export_text.editable = false
	_run_history_export_text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_run_history_export_text.mouse_filter = Control.MOUSE_FILTER_STOP
	_run_history_export_text.add_theme_font_size_override("font_size", 15)
	_run_history_export_text.add_theme_color_override("font_color", INK)
	_run_history_export_text.add_theme_color_override("background_color", DEEP)
	_fill_with_margin(_run_history_export_text, card, 16.0)

	_run_history_export_status = _label("", 14, YELLOW)
	_run_history_export_status.name = "RunHistoryExportStatus"
	_run_history_export_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_run_history_export_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place(_run_history_export_status, _run_history, 0.06, 0.915, 0.94, 0.985)


func _build_debug_run_setup() -> void:
	_debug_run_setup = _full_screen(&"DebugRunSetupScreen")
	var back := _button(&"DebugRunBack", "‹  HOME", CYAN, 64.0)
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
	var back := _button(&"DebugTestLabBack", "‹  QUICK TEST", CYAN, 64.0)
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
		StringName("DebugTuningMinus_%s" % parameter_id), "−", CYAN, 64.0)
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
		StringName("DebugTuningPlus_%s" % parameter_id), "+", CYAN, 64.0)
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
	_field_guide_back = _button(&"FieldGuideBack", "‹  BACK", CYAN, 64.0)
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
	_run_history.visible = _state.screen == FrontEndState.Screen.RUN_HISTORY
	if _run_history.visible:
		_render_run_history()
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
		var points: Array = step.get("points", [])
		for index in range(FrontEndState.TUTORIAL_POINT_COUNT):
			var available := index < points.size()
			_tutorial_point_panels[index].visible = available
			if not available:
				continue
			var point: Dictionary = points[index]
			_tutorial_point_cues[index].text = "%d  %s" % [
				index + 1,
				str(point.get("label", "")),
			]
			_tutorial_point_texts[index].text = str(point.get("text", ""))
		_tutorial_progress.text = "%d / %d" % [
			_state.tutorial_index + 1,
			FrontEndState.TUTORIAL_STEPS.size(),
		]
		var practice: Dictionary = step.get("practice", {})
		var can_practise := bool(practice.get("practice_available", false))
		_tutorial_action.text = (
			"COMPLETED · PRACTISE AGAIN"
			if can_practise and bool(step.get("practice_completed", false))
			else "PRACTISE LESSON" if can_practise else "START RUN"
		)
		_tutorial_next.text = (
			"GUIDE HUB" if _state.tutorial_index ==
				FrontEndState.TUTORIAL_STEPS.size() - 1
			else "NEXT"
		)
		front_end_button(&"TutorialPrevious").disabled = \
			_state.tutorial_index == 0
		_tutorial_preview.configure(
			step,
			_state.settings.reduced_motion,
			_state.progress.selected_spider_id,
			_state.progress.selected_spider_style,
			_state.progress.selected_web_variant,
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
	_render_hub_status()
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
	_render_home_deck(spider_id, accent)


## Everything on the deck is read from PlayerProgress or resolved from the
## catalogue. There is no derived "power" or "control" score behind any of it —
## a number on this screen is a number the save actually holds.
func _render_home_deck(spider_id: StringName, accent: Color) -> void:
	var mode := _state.selected_difficulty()
	var best_pixels := _state.progress.best_distance_for_mode(mode)
	var best_metres := best_pixels / CourseRegionCatalog.PIXELS_PER_METRE
	_home_best_caption.text = "PERSONAL BEST · %s" % str(mode).to_upper()
	_home_best_value.text = (
		"%s m" % _grouped_metres(best_metres) if best_metres > 0.0
		else "NO RUN YET"
	)
	if best_metres > 0.0:
		var region := CourseRegionCatalog.region_for_distance(best_pixels)
		_home_region_label.text = "REACHED\n%s\nregion %d of %d" % [
			str(region.get("name", "")),
			CourseRegionCatalog.region_index_for_distance(best_pixels) + 1,
			CourseRegionCatalog.REGIONS.size(),
		]
	else:
		_home_region_label.text = "%s\nstarts here" % str(
			CourseRegionCatalog.REGIONS[0]["name"])

	var resolved := _state.resolved_progress()
	var preview := SpiderCatalog.resolved_config(
		SwingConfig.PRESET_BALANCED, resolved)
	var levels := resolved.upgrade_levels
	var groups := SpiderCatalog.loadout_groups(spider_id)
	for index in range(_loadout_chips.size()):
		var chip: Dictionary = _loadout_chips[index]
		if index >= groups.size():
			continue
		var group: Dictionary = groups[index]
		var totals := SpiderCatalog.loadout_group_progress(group, levels)
		(chip["name"] as Label).text = str(group["label"])
		(chip["level"] as Label).text = "%d/%d" % [
			int(totals["owned"]), int(totals["maximum"])]
		(chip["detail"] as Label).text = _loadout_detail(
			StringName(group["id"]), group, preview)
		var meter := chip["meter"] as ProgressBar
		var maximum := maxf(1.0, float(totals["maximum"]))
		meter.value = clampf(float(totals["owned"]) / maximum, 0.0, 1.0)

	_rail_badges[&"SpiderHub"].text = "%d ◆" % _state.progress.spendable_flies
	var stars := 0
	for level: Dictionary in CampaignCatalog.all_levels():
		stars += mini(1, _state.progress.campaign_stars_for(
			StringName(level["id"])))
	_rail_badges[&"PlayModesHub"].text = "%d/%d ★" % [
		stars, CampaignCatalog.all_levels().size()]
	_rail_badges[&"GuideHub"].text = "%d lessons" % \
		FrontEndState.TUTORIAL_STEPS.size()
	_rail_badges[&"Settings"].text = ""
	_home_best_caption.add_theme_color_override("font_color", accent)


func _loadout_detail(
	group_id: StringName,
	group: Dictionary,
	preview: SwingConfig,
) -> String:
	match group_id:
		&"reel":
			return "%.0f m/s pull · %.1f s meter" % [
				preview.reel_retraction_rate / CourseRegionCatalog.PIXELS_PER_METRE,
				preview.reel_energy_capacity / maxf(0.001, preview.reel_drain_rate),
			]
		&"burst":
			return "%.0f%% of the web · %d charge%s · from %.0f m" % [
				preview.burst_distance_fraction * 100.0,
				preview.burst_charge_capacity,
				"" if preview.burst_charge_capacity == 1 else "s",
				preview.burst_minimum_distance / CourseRegionCatalog.PIXELS_PER_METRE,
			]
	return str(group.get("detail", ""))


## 7339 reads faster as 7 339 at a glance, and the deck's whole job is a glance.
func _grouped_metres(metres: float) -> String:
	var digits := "%d" % roundi(maxf(0.0, metres))
	var grouped := ""
	for index in range(digits.length()):
		if index > 0 and (digits.length() - index) % 3 == 0:
			grouped += " "
		grouped += digits[index]
	return grouped


## What each hub is worth opening, in the hub itself. Every figure is read from
## PlayerProgress, so a hub cannot claim progress the save does not hold.
func _render_hub_status() -> void:
	var progress := _state.progress
	var spider_id := progress.selected_spider_id
	var tracks := SpiderCatalog.upgrades_for(spider_id)
	var owned_steps := 0
	var maxed_tracks := 0
	for item: Dictionary in tracks:
		var level := progress.upgrade_level(StringName(item["id"]))
		owned_steps += level
		if level >= SpiderCatalog.MAX_UPGRADE_LEVEL:
			maxed_tracks += 1
	var total_steps := tracks.size() * SpiderCatalog.MAX_UPGRADE_LEVEL
	_spider_hub_status.text = (
		"%d of %d spiders unlocked  ·  %d body palettes  ·  %d silk treatments\n"
		+ "UPGRADES  %d / %d levels on this spider  ·  %d of %d tracks maxed"
		+ "  ·  %d flies to spend"
	) % [
		progress.unlocked_spider_ids.size(), SpiderCatalog.ALL_IDS.size(),
		progress.unlocked_spider_styles.size(),
		progress.unlocked_web_variants.size(),
		owned_steps, total_steps, maxed_tracks, tracks.size(),
		progress.spendable_flies,
	]

	var levels := CampaignCatalog.all_levels()
	var stars := 0
	for level: Dictionary in levels:
		stars += mini(1, progress.campaign_stars_for(StringName(level["id"])))
	var regions := CourseRegionCatalog.practice_regions()
	var reached := 0
	for region: Dictionary in regions:
		if progress.has_region_checkpoint(StringName(region["id"])):
			reached += 1
	var pieces := 0
	for piece: StringName in progress.creator_pattern:
		if piece != &"empty":
			pieces += 1
	_play_modes_status.text = (
		"CAMPAIGN  %d / %d stars   ·   PRACTICE  %d of %d regions reached"
		+ "   ·   COURSE LAB  %d / %d pieces placed\n"
		+ "RUN HISTORY  %d completed run%s retained locally"
	) % [
		stars, levels.size(), reached, regions.size(),
		pieces, progress.creator_pattern.size(),
		_state.run_record_ledger.total_completed_recorded_runs,
		"" if _state.run_record_ledger.total_completed_recorded_runs == 1 else "s",
	]

	_guide_hub_status.text = (
		"HOW TO SWING  %d lessons, from the first anchor to recovery"
		+ "   ·   FIELD GUIDE  %d spiders, each with its real animal and sources"
	) % [FrontEndState.TUTORIAL_STEPS.size(), SpiderCatalog.ALL_IDS.size()]


func _render_run_history() -> void:
	var exporting := _state.run_history_export_visible
	_run_history_scroll.visible = not exporting
	_run_history_export_text.visible = exporting
	_run_history_copy_json.visible = exporting
	_run_history_view_json.text = "HISTORY" if exporting else "VIEW JSON"
	_run_history_export_status.visible = exporting
	_run_history_export_status.text = _state.run_history_export_status
	if exporting:
		var payload := _state.run_history_export_json()
		if _run_history_export_text.text != payload:
			_run_history_export_text.text = payload
		return

	var ledger := _state.run_record_ledger
	var total_km := ledger.total_distance_travelled_pixels / (
		CourseRegionCatalog.PIXELS_PER_METRE * 1000.0)
	_run_history_lifetime.text = (
		"%d completed run%s  ·  %s active play  ·  %.2f km travelled\n"
		+ "COMPARABLE BESTS  Relaxed %s  ·  Standard %s  ·  Harsh %s\n"
		+ "FIRST-SESSION CHECKS  %d answer%s · %d eligible human run%s"
	) % [
		ledger.total_completed_recorded_runs,
		"" if ledger.total_completed_recorded_runs == 1 else "s",
		_format_duration(ledger.total_active_duration_seconds),
		total_km,
		_format_optional_distance(ledger.best_distance_for_difficulty(
			DifficultyCatalog.MODE_RELAXED)),
		_format_optional_distance(ledger.best_distance_for_difficulty(
			DifficultyCatalog.MODE_STANDARD)),
		_format_optional_distance(ledger.best_distance_for_difficulty(
			DifficultyCatalog.MODE_HARSH)),
		ledger.feedback_responses.size(),
		"" if ledger.feedback_responses.size() == 1 else "s",
		ledger.total_feedback_eligible_runs,
		"" if ledger.total_feedback_eligible_runs == 1 else "s",
	]
	var latest := _state.latest_run_record()
	_run_history_latest.text = (
		"No completed settlement-backed run has been recorded on this install."
		if latest == null else _latest_run_text(latest)
	)
	for child: Node in _run_history_recent.get_children():
		_run_history_recent.remove_child(child)
		child.free()
	var recent := _state.recent_run_records()
	if recent.is_empty():
		var empty := _label(
			"Finish an Endless, Practice, Campaign, Course Lab, or classified replay run to create evidence.",
			15,
			MUTED,
		)
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_run_history_recent.add_child(empty)
		return
	for record: RunRecord in recent:
		var panel := _panel(PANEL_SOFT, 12, _record_accent(record))
		panel.name = "RunHistoryRecord%d" % record.lifetime_completed_run_ordinal
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_run_history_recent.add_child(panel)
		var summary := _label(_recent_run_text(record), 14, INK)
		summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		summary.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		summary.custom_minimum_size.y = 112.0
		_fill_with_margin(summary, panel, 11.0)


func _latest_run_text(record: RunRecord) -> String:
	var final_m := record.final_distance_pixels / \
		CourseRegionCatalog.PIXELS_PER_METRE
	var travelled_m := record.travelled_distance_pixels / \
		CourseRegionCatalog.PIXELS_PER_METRE
	var region := CourseRegionCatalog.region_for_id(record.final_region_id)
	var summary := (
		"%s · %s · %s\n"
		+ "FINAL %s m  ·  TRAVELLED %s m  ·  %s  ·  %s\n"
		+ "FLIES %d  ·  %.2f per travelled km\n"
		+ "SPEED %.1f m/s mean  ·  %.1f m/s max  ·  %.0f%% above reference\n"
		+ "ACTIONS  Web %d  ·  Reel %d / %.1f s / empty %d  ·  Burst %d  ·  Dive %d  ·  Rescue %s\n"
		+ "SPIDER %s  ·  DIFFICULTY %s  ·  PRESET %s  ·  SEED %d  ·  START %s m\n"
		+ "UPGRADES %s\n"
		+ "ELIGIBILITY rewards %s · records %s · leaderboard %s  ·  attempt %d · lifetime run %d\n"
		+ "BUILD %s · Android code %d · %s · physics %d · %s"
	) % [
		str(record.configuration_kind).to_upper(),
		str(record.terminal_outcome).to_upper(),
		str(record.death_cause),
		_grouped_metres(final_m),
		_grouped_metres(travelled_m),
		_format_duration(record.active_duration_seconds),
		str(region.get("name", record.final_region_id)),
		record.flies_collected,
		record.flies_per_kilometre,
		record.mean_forward_speed_pixels_per_second / \
			CourseRegionCatalog.PIXELS_PER_METRE,
		record.maximum_forward_speed_pixels_per_second / \
			CourseRegionCatalog.PIXELS_PER_METRE,
		record.above_reference_speed_share * 100.0,
		record.successful_web_attachments,
		record.reel_activations,
		record.reel_held_seconds,
		record.reel_empty_events,
		record.burst_activations,
		record.dive_activations,
		"USED" if record.rescue_consumed else "unused",
		str(record.spider_profile_id).to_upper(),
		str(record.difficulty_id).to_upper(),
		str(record.preset_id),
		record.course_seed,
		_grouped_metres(record.start_distance_pixels / \
			CourseRegionCatalog.PIXELS_PER_METRE),
		_upgrade_level_text(record),
		_yes_no(record.rewards_eligible),
		_yes_no(record.records_eligible),
		_yes_no(record.leaderboards_eligible),
		record.attempt_ordinal,
		record.lifetime_completed_run_ordinal,
		record.build_version,
		record.android_version_code,
		record.runtime_platform,
		record.swing_config_schema_version,
		record.trace_format,
	]
	return summary + _run_feedback_line(record.record_id)


func _recent_run_text(record: RunRecord) -> String:
	var final_m := record.final_distance_pixels / \
		CourseRegionCatalog.PIXELS_PER_METRE
	var travelled_m := record.travelled_distance_pixels / \
		CourseRegionCatalog.PIXELS_PER_METRE
	var summary := (
		"#%d  %s · %s · %s · %s\n"
		+ "%s m final · %s m travelled · %s · %.1f / %.1f m/s mean/max · %d flies (%.2f/km)\n"
		+ "Web %d · Reel %d (%.1f s, empty %d) · Burst %d · Dive %d · Rescue %s\n"
		+ "%s · seed %d · start %s m · rewards %s / records %s / board %s"
	) % [
		record.lifetime_completed_run_ordinal,
		str(record.configuration_kind).to_upper(),
		str(record.difficulty_id).to_upper(),
		str(record.spider_profile_id).to_upper(),
		str(record.death_cause),
		_grouped_metres(final_m),
		_grouped_metres(travelled_m),
		_format_duration(record.active_duration_seconds),
		record.mean_forward_speed_pixels_per_second / \
			CourseRegionCatalog.PIXELS_PER_METRE,
		record.maximum_forward_speed_pixels_per_second / \
			CourseRegionCatalog.PIXELS_PER_METRE,
		record.flies_collected,
		record.flies_per_kilometre,
		record.successful_web_attachments,
		record.reel_activations,
		record.reel_held_seconds,
		record.reel_empty_events,
		record.burst_activations,
		record.dive_activations,
		"USED" if record.rescue_consumed else "unused",
		record.build_version,
		record.course_seed,
		_grouped_metres(record.start_distance_pixels / \
			CourseRegionCatalog.PIXELS_PER_METRE),
		_yes_no(record.rewards_eligible),
		_yes_no(record.records_eligible),
		_yes_no(record.leaderboards_eligible),
	]
	return summary + _run_feedback_line(record.record_id)


func _run_feedback_line(record_id: String) -> String:
	var response := _state.run_record_ledger.feedback_for_record(record_id)
	if response == null:
		return ""
	var answer := (
		"KNEW WHAT TO DO"
		if response.answer_id == \
			RunFeedbackResponse.ANSWER_KNEW_WHAT_TO_DO
		else "NOT SURE WHAT TO DO"
	)
	return "\nFIRST-SESSION CHECK  %s" % answer


func _upgrade_level_text(record: RunRecord) -> String:
	var labels: Array[String] = []
	for item: Dictionary in SpiderCatalog.upgrades_for(record.spider_profile_id):
		var upgrade_id := str(item["id"])
		var short_id := upgrade_id.trim_prefix("%s_" % record.spider_profile_id)
		labels.append("%s L%d" % [short_id, int(
			record.resolved_upgrade_levels.get(upgrade_id, 0))])
	return ", ".join(labels)


func _record_accent(record: RunRecord) -> Color:
	match record.configuration_kind:
		&"standard":
			return GREEN
		&"campaign":
			return ORANGE
		&"trace_replay":
			return YELLOW
	return CYAN


func _format_optional_distance(distance_pixels: float) -> String:
	if distance_pixels <= 0.0:
		return "—"
	return "%s m" % _grouped_metres(
		distance_pixels / CourseRegionCatalog.PIXELS_PER_METRE)


func _format_duration(seconds: float) -> String:
	var whole := maxi(0, roundi(seconds))
	var hours := whole / 3600
	var minutes := (whole % 3600) / 60
	var remaining := whole % 60
	return (
		"%d:%02d:%02d" % [hours, minutes, remaining]
		if hours > 0 else "%d:%02d" % [minutes, remaining]
	)


func _yes_no(value: bool) -> String:
	return "yes" if value else "no"


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


func _on_run_history() -> void:
	if _state != null:
		_state.show_run_history()


func _on_run_history_view_toggle() -> void:
	if _state == null:
		return
	if _state.run_history_export_visible:
		_state.show_run_history_list()
	else:
		_state.show_run_history_export()


func _on_run_history_copy() -> void:
	if _state != null:
		_state.request_run_history_export()


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
		# Disabling the current choice made it the dimmest control on Home —
		# `font_disabled_color` is MUTED at 48% alpha, 2.6:1 against the panel,
		# so the difficulty you are actually on read as the one you could not
		# have. Selection is now the strongest state, and re-pressing it is a
		# harmless no-op in ProgressionService.
		var is_selected := bool(mode["selected"])
		button.disabled = false
		_set_selector_state(button, is_selected, CYAN)
		if is_selected:
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


## Derived from the region id rather than matched against a hard-coded pair.
## The 0.39.0 region swap changed which regions carry checkpoints, and a match
## statement would have silently produced `PracticeRegion` for the new one.
func _practice_button_name(region_id: StringName) -> StringName:
	var suffix := String(region_id).capitalize().replace(" ", "")
	if suffix.is_empty():
		return &"PracticeRegion"
	return StringName("Practice%s" % suffix)


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


func _on_tutorial_action() -> void:
	if _state != null:
		_state.request_current_tutorial_action()


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
