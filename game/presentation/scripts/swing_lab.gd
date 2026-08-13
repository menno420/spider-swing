extends Node2D
class_name SwingLabView
## Code-drawn Phase 0 presentation.
##
## It consumes snapshots/events and emits no authoritative writes. The visual
## web follows physics endpoints; it never drives the constraint.

const SPIDER_DARK := Color("17202b")
const SPIDER_ACCENT := Color("f28c45")
const WEB := Color("d9fbff")
const CYAN := Color("4de8ee")
const GREEN := Color("73e0a4")
const YELLOW := Color("ffd166")
const RED := Color("ff6577")
const MUTED := Color("8ba9b5")
const OBSTACLE := Color("f06449")
const OBSTACLE_DARK := Color("632e34")
const REEL_FEEDBACK_DURATION := 0.22
const BURST_FEEDBACK_DURATION := 0.3
const ENVIRONMENT_TEXTURE_WORLD_SIZE := 420.0
const FOREST_BRANCH_HEIGHT := 122.0
const FOREST_BRANCH_BASELINE := 94.0
const FOREST_OBSTACLE_ART_OVERSCAN := 8.0
const FOREST_RAIL_JOIN_OVERLAP := 28.0
const FOREST_RAIL_WORLD_REPEAT := 768.0
const FOREST_RAIL_SEGMENT_OVERLAP := 38.0
const MOTION_TELEPORT_THRESHOLD := 240.0
const REGION_BANNER_DURATION := 2.8
const REGION_VISUAL_TRANSITION_DURATION := 2.2
const BIRD_CANVAS_SIZE := Vector2(300.0, 300.0)
const BIRD_FLAP_ASSETS := [
	ArtAssetCatalog.PURSUING_BIRD_UPSTROKE,
	ArtAssetCatalog.PURSUING_BIRD_DOWNSTROKE,
	ArtAssetCatalog.PURSUING_BIRD_DEEPSTROKE,
]
const BIRD_FLAP_SEQUENCE := [0, 1, 2, 1]

var _snapshot: SimulationSnapshot
var _previous_spider_position := Vector2.ZERO
var _current_spider_position := Vector2.ZERO
var _previous_spider_velocity := Vector2.ZERO
var _current_spider_velocity := Vector2.ZERO
var _previous_bird_position := Vector2.ZERO
var _current_bird_position := Vector2.ZERO
var _previous_bird_velocity := Vector2.ZERO
var _current_bird_velocity := Vector2.ZERO
var _motion_tick: int = -1
var _motion_time: float = 0.0
var _camera_x: float = 0.0
var _feedback_message: String = "Tap any cyan ceiling surface to attach"
var _feedback_position: Vector2 = Vector2.ZERO
var _feedback_color: Color = GREEN
var _feedback_remaining: float = 3.0
var _font: Font
var _show_control_hints: bool = true
var _reduced_motion: bool = false
var _show_debug_tools: bool = true
var _reel_feedback_remaining: float = 0.0
var _burst_feedback_remaining: float = 0.0
var _burst_feedback_origin: Vector2 = Vector2.ZERO
var _burst_feedback_anchor: Vector2 = Vector2.ZERO
var _burst_feedback_direction: Vector2 = Vector2.ZERO
var _environment_theme_index: int = EnvironmentThemeCatalog.default_index()
var _environment_textures: Dictionary = {}
var _art_textures: Dictionary = {}
var _region_banner_remaining: float = 0.0
var _region_banner_name: String = ""
var _region_banner_focus: String = ""
var _region_visual_transition_from: StringName = \
	CourseRegionCatalog.VISUAL_OLD_GROWTH
var _region_visual_transition_remaining: float = 0.0
var _run_feedback_prompt: Dictionary = {}


func _ready() -> void:
	_font = ThemeDB.fallback_font
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_load_environment_textures()
	_load_art_textures()
	set_process(true)
	queue_redraw()


func configure_player_options(
	show_control_hints: bool,
	reduced_motion: bool,
	show_debug_tools: bool,
) -> void:
	_show_control_hints = show_control_hints
	_reduced_motion = reduced_motion
	_show_debug_tools = show_debug_tools
	if _reduced_motion:
		_region_visual_transition_remaining = 0.0
	queue_redraw()


func present(snapshot: SimulationSnapshot) -> void:
	var had_snapshot := _snapshot != null
	var previous_visual_profile := \
		CourseRegionCatalog.VISUAL_OLD_GROWTH
	if had_snapshot:
		previous_visual_profile = _snapshot.region_visual_profile
	var region_changed := not had_snapshot or \
		_snapshot.region_id != snapshot.region_id
	if _snapshot == null or snapshot.tick < _motion_tick or \
			_current_spider_position.distance_to(snapshot.position) > \
				MOTION_TELEPORT_THRESHOLD:
		_previous_spider_position = snapshot.position
		_current_spider_position = snapshot.position
		_previous_spider_velocity = snapshot.velocity
		_current_spider_velocity = snapshot.velocity
		_previous_bird_position = snapshot.bird_position
		_current_bird_position = snapshot.bird_position
		_previous_bird_velocity = snapshot.bird_velocity
		_current_bird_velocity = snapshot.bird_velocity
	elif snapshot.tick > _motion_tick:
		_previous_spider_position = _current_spider_position
		_previous_spider_velocity = _current_spider_velocity
		_current_spider_position = snapshot.position
		_current_spider_velocity = snapshot.velocity
		_previous_bird_position = _current_bird_position
		_previous_bird_velocity = _current_bird_velocity
		_current_bird_position = snapshot.bird_position
		_current_bird_velocity = snapshot.bird_velocity
	else:
		_current_spider_position = snapshot.position
		_current_spider_velocity = snapshot.velocity
		_current_bird_position = snapshot.bird_position
		_current_bird_velocity = snapshot.bird_velocity
	_motion_tick = snapshot.tick
	_snapshot = snapshot
	if region_changed:
		_region_banner_name = snapshot.region_name
		_region_banner_focus = snapshot.region_focus
		_region_banner_remaining = REGION_BANNER_DURATION
		_region_visual_transition_from = previous_visual_profile
		if had_snapshot and \
				previous_visual_profile != snapshot.region_visual_profile and \
				not _reduced_motion:
			_region_visual_transition_remaining = \
				REGION_VISUAL_TRANSITION_DURATION
		else:
			_region_visual_transition_remaining = 0.0
	queue_redraw()


func select_environment_theme(index: int) -> void:
	_environment_theme_index = clampi(
		index,
		0,
		EnvironmentThemeCatalog.count() - 1,
	)
	queue_redraw()


func configure_run_feedback_prompt(prompt: Dictionary) -> void:
	_run_feedback_prompt = prompt.duplicate(true)
	queue_redraw()


func clear_run_feedback_prompt() -> void:
	_run_feedback_prompt.clear()
	queue_redraw()


func run_feedback_prompt_visible() -> bool:
	return _snapshot != null and _snapshot.run_state == &"dead" and \
		not _run_feedback_prompt.is_empty()


func environment_theme_index() -> int:
	return _environment_theme_index


func present_event(event: SimulationEvent) -> void:
	_feedback_message = event.message
	_feedback_position = event.position
	_feedback_remaining = 1.2
	match event.kind:
		SimulationEvent.Kind.REEL_STARTED:
			_reel_feedback_remaining = REEL_FEEDBACK_DURATION
		SimulationEvent.Kind.BURST_STARTED:
			_burst_feedback_remaining = BURST_FEEDBACK_DURATION
			_burst_feedback_origin = Vector2(
				float(event.data.get("origin_x", 0.0)),
				float(event.data.get("origin_y", 0.0)),
			)
			_burst_feedback_anchor = event.position
			_burst_feedback_direction = Vector2(
				float(event.data.get("direction_x", 0.0)),
				float(event.data.get("direction_y", 0.0)),
			).normalized()
		SimulationEvent.Kind.DIVE_STARTED:
			_burst_feedback_remaining = BURST_FEEDBACK_DURATION
			_burst_feedback_origin = Vector2(
				float(event.data.get("origin_x", 0.0)),
				float(event.data.get("origin_y", 0.0)),
			)
			_burst_feedback_anchor = event.position
			_burst_feedback_direction = Vector2(
				float(event.data.get("direction_x", 0.0)),
				float(event.data.get("direction_y", 0.0)),
			).normalized()
		SimulationEvent.Kind.INVALID_TARGET:
			_feedback_color = RED
		SimulationEvent.Kind.OUT_OF_RANGE, SimulationEvent.Kind.REEL_UNAVAILABLE, \
				SimulationEvent.Kind.REEL_EMPTY, \
				SimulationEvent.Kind.BURST_UNAVAILABLE, \
				SimulationEvent.Kind.DIVE_UNAVAILABLE:
			_feedback_color = YELLOW
		SimulationEvent.Kind.ANCHOR_FAILED:
			_feedback_color = RED
		SimulationEvent.Kind.HAZARD_CUE:
			_feedback_color = YELLOW
		SimulationEvent.Kind.FLY_COLLECTED:
			_feedback_color = YELLOW
		SimulationEvent.Kind.BOOST_COLLECTED:
			_feedback_color = CYAN
		SimulationEvent.Kind.BOOST_EXPIRED:
			_feedback_color = MUTED
		SimulationEvent.Kind.RESCUE_USED:
			_feedback_color = GREEN
		SimulationEvent.Kind.SURFACE_BOUNCED:
			_feedback_color = CYAN
		SimulationEvent.Kind.REGION_ENTERED:
			_region_banner_name = str(event.message).get_slice(" · ", 0)
			_region_banner_focus = str(event.message).trim_prefix(
				"%s · " % _region_banner_name)
			_region_banner_remaining = REGION_BANNER_DURATION
			_feedback_color = CYAN
		SimulationEvent.Kind.CHECKPOINT_REACHED:
			_feedback_color = YELLOW
		_:
			_feedback_color = GREEN
	queue_redraw()


func screen_to_world(screen_position: Vector2) -> Vector2:
	return screen_position + Vector2(_camera_x, 0.0)


func _process(delta: float) -> void:
	_reel_feedback_remaining = maxf(0.0, _reel_feedback_remaining - delta)
	_burst_feedback_remaining = maxf(0.0, _burst_feedback_remaining - delta)
	_region_banner_remaining = maxf(
		0.0,
		_region_banner_remaining - delta,
	)
	_region_visual_transition_remaining = maxf(
		0.0,
		_region_visual_transition_remaining - delta,
	)
	if _snapshot == null:
		return
	if not _reduced_motion:
		_motion_time += delta
	var viewport_size := get_viewport_rect().size
	var look_ahead := maxf(0.0, _snapshot.velocity.x - _snapshot.target_speed) * \
		_snapshot.camera_look_ahead
	var target := maxf(
		0.0,
		_snapshot.furthest_x - viewport_size.x / 3.0 + look_ahead,
	)
	if _reduced_motion:
		_camera_x = target
	else:
		var follow := 1.0 - exp(-_snapshot.camera_follow_strength * delta)
		_camera_x = lerpf(_camera_x, target, follow)
	_feedback_remaining = maxf(0.0, _feedback_remaining - delta)
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		size = LabLayout.REFERENCE_SIZE
	var environment := _environment_theme()
	draw_rect(
		Rect2(Vector2.ZERO, size),
		environment["background"] as Color,
	)
	_draw_parallax(size)
	_draw_course(size)
	if _zone_lightning_active():
		# Illumination is the strike's bargain: the lethal beat briefly reveals
		# the whole corridor, while web/player feedback remains drawn on top.
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.88, 0.95, 1.0, 0.13))
	if _snapshot == null:
		_draw_text(Vector2(32.0, 58.0), "Loading Swing Laboratory…", 24, WEB)
		return
	_draw_web()
	_draw_action_feedback()
	_draw_bird()
	_draw_spider()
	_draw_feedback()
	_draw_hud(size)
	if _show_debug_tools and _snapshot.debug_visible:
		_draw_debug(size)


func _draw_parallax(size: Vector2) -> void:
	var environment := _environment_theme()
	draw_rect(
		Rect2(0.0, size.y * 0.72, size.x, size.y * 0.28),
		environment["background_deep"] as Color,
	)
	var parallax_x := 0.0 if _reduced_motion else _camera_x
	if _uses_curated_zone_art():
		var profile := CourseRegionCatalog.VISUAL_OLD_GROWTH \
			if _snapshot == null else _snapshot.region_visual_profile
		if _region_visual_transition_remaining > 0.0 and \
				_region_visual_transition_from != profile:
			var blend := 1.0 - _region_visual_transition_remaining / \
				REGION_VISUAL_TRANSITION_DURATION
			_draw_region_backdrop(
				_region_visual_transition_from,
				size,
				parallax_x,
				1.0 - blend,
			)
			_draw_region_backdrop(profile, size, parallax_x, blend)
		else:
			_draw_region_backdrop(profile, size, parallax_x, 1.0)
		return
	var far_offset := fposmod(-parallax_x * 0.08, 240.0)
	for index in range(-1, 8):
		var x := far_offset + float(index) * 240.0
		draw_circle(
			Vector2(x, 135.0 + float(index % 3) * 54.0),
			105.0,
			environment["far"] as Color,
		)
	var near_offset := fposmod(-parallax_x * 0.22, 310.0)
	for index in range(-1, 6):
		var x := near_offset + float(index) * 310.0
		draw_circle(
			Vector2(x, size.y + 25.0),
			155.0,
			environment["near"] as Color,
		)
	var grid_color := Color(environment["accent"] as Color, 0.11)
	for y in range(90, int(size.y), 90):
		draw_line(
			Vector2(0.0, float(y)),
			Vector2(size.x, float(y)),
			grid_color,
			1.0,
		)
	var grid_offset := fposmod(-parallax_x, 120.0)
	for x in range(-120, int(size.x) + 120, 120):
		draw_line(Vector2(float(x) + grid_offset, 0.0),
			Vector2(float(x) + grid_offset, size.y), grid_color, 1.0)


func _draw_region_backdrop(
	profile: StringName,
	size: Vector2,
	parallax_x: float,
	alpha: float,
) -> void:
	if alpha <= 0.0:
		return
	var zone_layers := ArtAssetCatalog.zone_backdrop_art_specs(profile)
	if not zone_layers.is_empty():
		for layer: Dictionary in zone_layers:
			_draw_forest_backdrop_layer(
				StringName(layer.get("asset_id", &"")),
				size,
				parallax_x,
				float(layer.get("scroll_scale", 0.065)),
				Color(
					1.0, 1.0, 1.0,
					float(layer.get("opacity", 0.78)) * alpha,
				),
			)
		_draw_region_ambience(size, parallax_x, profile, alpha)
		return
	if profile == CourseRegionCatalog.VISUAL_CANOPY:
		_draw_forest_backdrop_layer(
			ArtAssetCatalog.CANOPY_BACKDROP_FAR,
			size,
			parallax_x,
			0.035,
			Color(0.68, 0.83, 0.58, 0.94 * alpha),
		)
		_draw_forest_backdrop_layer(
			ArtAssetCatalog.CANOPY_BACKDROP_MID,
			size,
			parallax_x,
			0.11,
			Color(0.75, 0.90, 0.62, 0.58 * alpha),
		)
		_draw_region_ambience(size, parallax_x, profile, alpha)
		return
	_draw_forest_backdrop_layer(
		ArtAssetCatalog.FOREST_BACKDROP_FAR,
		size,
		parallax_x,
		0.035,
		Color(0.58, 0.68, 0.58, 0.72 * alpha),
	)
	_draw_forest_backdrop_layer(
		ArtAssetCatalog.FOREST_BACKDROP_MID,
		size,
		parallax_x,
		0.10,
		Color(0.62, 0.70, 0.60, 0.36 * alpha),
	)
	_draw_forest_backdrop_layer(
		ArtAssetCatalog.FOREST_BACKDROP_NEAR,
		size,
		parallax_x,
		0.22,
		Color(0.52, 0.62, 0.48, 0.24 * alpha),
	)
	_draw_region_ambience(size, parallax_x, profile, alpha)


func _draw_forest_backdrop_layer(
	asset_id: StringName,
	size: Vector2,
	parallax_x: float,
	scroll_scale: float,
	modulate: Color,
) -> void:
	var texture := _art_texture(asset_id)
	if texture == null:
		return
	var tile_width := size.x
	var offset := fposmod(-parallax_x * scroll_scale, tile_width)
	var world_tile := floori(parallax_x * scroll_scale / tile_width)
	for index in range(-1, 2):
		var tile_index := world_tile + index
		var x := offset + float(index) * tile_width
		var mirrored := posmod(tile_index, 2) == 1
		draw_set_transform(
			Vector2(x + (tile_width if mirrored else 0.0), 0.0),
			0.0,
			Vector2(-1.0 if mirrored else 1.0, 1.0),
		)
		draw_texture_rect(
			texture,
			Rect2(Vector2.ZERO, size),
			false,
			modulate,
		)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_region_ambience(
	size: Vector2,
	parallax_x: float,
	profile: StringName,
	alpha: float = 1.0,
) -> void:
	if profile == CourseRegionCatalog.VISUAL_OLD_GROWTH:
		return
	var motion := 0.0 if _reduced_motion else _motion_time
	if profile == CourseRegionCatalog.VISUAL_CANOPY:
		draw_rect(
			Rect2(Vector2.ZERO, size),
			Color(0.03, 0.20, 0.12, 0.13 * alpha),
		)
		var offset := fposmod(-parallax_x * 0.16, 190.0)
		for index in range(-1, 9):
			var x := offset + float(index) * 190.0
			var thread_end := 110.0 + float(posmod(index, 4)) * 42.0
			draw_line(
				Vector2(x, 0.0),
				Vector2(x + sin(motion * 0.7 + index) * 8.0, thread_end),
				Color(WEB, 0.13 * alpha),
				1.2,
				true,
			)
			draw_circle(
				Vector2(x + 34.0, 90.0 + float(posmod(index, 3)) * 86.0),
				5.0 + float(posmod(index, 2)) * 2.0,
				Color(0.60, 0.88, 0.55, 0.16 * alpha),
			)
		return
	if profile == CourseRegionCatalog.VISUAL_HOLLOW:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.20, 0.10, 0.04, 0.18 * alpha))
		return
	if profile == CourseRegionCatalog.VISUAL_ARBORETUM:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.08, 0.14, 0.12, 0.14 * alpha))
		return
	if profile == CourseRegionCatalog.VISUAL_STORM:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.04, 0.07, 0.14, 0.30 * alpha))
		var storm_motion := _zone_phase_seconds(600, 61)
		var gust := 0.0 if _snapshot == null else \
			ZoneMechanics.gust_strength(
				_snapshot.distance_pixels, _snapshot.seed, _snapshot.tick)
		var rain_offset := fposmod(
			-parallax_x * 0.31 + storm_motion * 190.0, 92.0)
		for index in range(-2, 18):
			var x := rain_offset + index * 92.0
			draw_line(
				Vector2(x, 0.0), Vector2(x - 190.0 - gust * 96.0, size.y),
				Color(0.75, 0.87, 0.94, (0.20 + gust * 0.16) * alpha),
				2.0 + gust * 0.8, true)
		return
	if profile == CourseRegionCatalog.VISUAL_WEB_CITY:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.02, 0.08, 0.26 * alpha))
		return
	if profile == CourseRegionCatalog.VISUAL_ASHEN:
		var ash_drift_active := _snapshot != null and \
			_snapshot.distance_pixels >= 315000.0
		draw_rect(
			Rect2(Vector2.ZERO, size),
			Color(
				0.10,
				0.07,
				0.06,
				(0.28 if ash_drift_active else 0.10) * alpha,
			),
		)
		if not ash_drift_active:
			return
		var ash_motion := _zone_phase_seconds(420, 79)
		for index in range(18):
			var ember := Vector2(
				fposmod(index * 137.0 - parallax_x * 0.18, size.x + 80.0) - 40.0,
				fposmod(index * 83.0 + ash_motion * 31.0, size.y),
			)
			draw_circle(ember, 1.8, Color(1.0, 0.34, 0.08, 0.48 * alpha))
		return
	if profile == CourseRegionCatalog.VISUAL_MIST:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.72, 0.76, 0.77, 0.38 * alpha))


func _zone_phase_seconds(period_ticks: int, phase_salt: int) -> float:
	if _snapshot == null:
		return 0.0
	var chunk_index := floori(
		(_camera_x + LabLayout.REFERENCE_SIZE.x * 0.5) / CourseStream.CHUNK_WIDTH)
	var phase_tick := _snapshot.tick + CourseMotion.phase_offset_ticks(
		chunk_index, _snapshot.seed, period_ticks, phase_salt)
	return float(posmod(phase_tick, period_ticks)) / 60.0


func _zone_lightning_active() -> bool:
	if _snapshot == null or _snapshot.region_visual_profile != \
			CourseRegionCatalog.VISUAL_STORM:
		return false
	for index in range(_snapshot.obstacle_visual_ids.size()):
		if _snapshot.obstacle_visual_ids[index] != \
				ZoneCourseBuilder.V_RIDGE_LIGHTNING:
			continue
		if index >= _snapshot.obstacle_active.size() or \
				_snapshot.obstacle_active[index] != 0:
			return true
	return false


func _draw_course(size: Vector2) -> void:
	if _snapshot == null:
		return

	for surface_index in range(_snapshot.surfaces.size()):
		var surface: PackedVector2Array = _snapshot.surfaces[surface_index]
		var screen_surface := _polygon_to_screen(surface)
		var surface_bounds := _polygon_bounds(screen_surface)
		if surface_bounds.end.x < -80.0 or \
				surface_bounds.position.x > size.x + 80.0:
			continue
		var anchor_class := _snapshot.surface_anchor_classes[surface_index] \
			if surface_index < _snapshot.surface_anchor_classes.size() \
			else CourseGeometry.ANCHOR_FIXED
		var surface_color := _zone_surface_color(anchor_class)
		var visual_id := _snapshot.surface_visual_ids[surface_index] \
			if surface_index < _snapshot.surface_visual_ids.size() else &""
		var surface_art := ArtAssetCatalog.zone_surface_art_spec(
			visual_id, anchor_class)
		var surface_asset := StringName(surface_art.get("asset_id", &""))
		var surface_texture := _art_texture(surface_asset) \
			if not surface_asset.is_empty() else null
		var is_sticky_bead := anchor_class == CourseGeometry.ANCHOR_STICKY and \
			maxf(surface_bounds.size.x, surface_bounds.size.y) < 100.0
		if surface_texture != null and not is_sticky_bead:
			_draw_texture_oriented(
				surface_texture,
				screen_surface,
				surface_art.get("overscan", Vector2(10.0, 6.0)) as Vector2,
				Color(1.0, 0.78, 0.58, 1.0) \
					if anchor_class == CourseGeometry.ANCHOR_STICKY \
					else Color.WHITE,
			)
		else:
			draw_colored_polygon(screen_surface, surface_color)
			if surface_texture == null:
				_draw_closed_polyline(
					screen_surface,
					Color(0.82, 1.0, 1.0, 0.94),
					4.0 if anchor_class == CourseGeometry.ANCHOR_MOVING_PIVOT \
					else 2.5,
				)
		if anchor_class == CourseGeometry.ANCHOR_STICKY and not is_sticky_bead:
			var bounds := _polygon_bounds(screen_surface)
			for bead_index in range(4):
				draw_circle(
					Vector2(lerpf(bounds.position.x, bounds.end.x,
						(float(bead_index) + 0.5) / 4.0), bounds.get_center().y),
					6.0, Color("ffc07a"))
		if _snapshot.collision_outlines_visible:
			_draw_closed_polyline(screen_surface, CYAN, 2.0)

	for decoration_index in range(_snapshot.decorations.size()):
		if decoration_index < _snapshot.decoration_active.size() and \
				_snapshot.decoration_active[decoration_index] == 0:
			continue
		var decoration := _polygon_to_screen(
			_snapshot.decorations[decoration_index])
		var decoration_bounds := _polygon_bounds(decoration)
		if decoration_bounds.end.x < -40.0 or \
				decoration_bounds.position.x > size.x + 40.0:
			continue
		var visual_id := _snapshot.decoration_visual_ids[decoration_index] \
			if decoration_index < _snapshot.decoration_visual_ids.size() else &""
		if visual_id == ZoneCourseBuilder.V_ARBORETUM_DRIP:
			draw_line(
				decoration_bounds.get_center() + Vector2.UP * 22.0,
				decoration_bounds.get_center() + Vector2.UP * 6.0,
				Color(0.68, 0.92, 0.91, 0.34), 1.5, true)
			draw_colored_polygon(decoration, Color(0.67, 0.92, 0.91, 0.72))
			_draw_closed_polyline(
				decoration, Color(0.88, 1.0, 1.0, 0.88), 1.5)

	for boundary: PackedVector2Array in _snapshot.boundary_surfaces:
		var screen_boundary := _polygon_to_screen(boundary)
		var boundary_bounds := _polygon_bounds(screen_boundary)
		if boundary_bounds.end.x < -80.0 or \
				boundary_bounds.position.x > size.x + 80.0:
			continue
		var environment := _environment_theme()
		var outline: Color = (
			environment["lethal_edge"] as Color
			if _snapshot.course_boundaries_lethal
			else environment["safe_edge"] as Color
		)
		var fill := Color(0.20, 0.16, 0.09, 0.96) \
			if _snapshot.course_boundaries_lethal \
			else Color(0.07, 0.25, 0.22, 0.96)
		if _uses_forest_art():
			_draw_environment_polygon(
				boundary,
				screen_boundary,
				environment["material_tint"] as Color,
				fill,
			)
		else:
			var boundary_profile := _visual_profile_for_world_polygon(boundary)
			var zone_colors := _zone_boundary_colors(boundary_profile)
			fill = zone_colors["fill"]
			outline = zone_colors["edge"]
			draw_colored_polygon(screen_boundary, fill)
			var boundary_art := ArtAssetCatalog.zone_boundary_art_spec(
				boundary_profile, _boundary_is_ceiling(boundary))
			if boundary_art.is_empty():
				_draw_closed_polyline(screen_boundary, outline, 3.0)
		if _snapshot.collision_outlines_visible:
			_draw_closed_polyline(
				screen_boundary,
				outline,
				2.0,
			)

	if _snapshot.web_guides_visible:
		for guide: Vector2 in _snapshot.anchors:
			var screen := _world_to_screen(guide)
			if screen.x < -80.0 or screen.x > size.x + 80.0:
				continue
			var distance := guide.distance_to(_render_spider_position())
			var in_range := distance >= 90.0 and \
				distance <= _snapshot.web_maximum_length
			var color := GREEN if in_range else YELLOW
			draw_circle(screen, 10.0, Color(color, 0.12))
			draw_arc(screen, 11.0, 0.0, TAU, 24, Color(color, 0.72), 2.0)
			draw_circle(screen, 3.0, WEB)

	var obstacle_index := 0
	while obstacle_index < _snapshot.obstacles.size():
		var obstacle: PackedVector2Array = _snapshot.obstacles[obstacle_index]
		var contact_obstacle: PackedVector2Array = \
			_snapshot.obstacle_contact_polygons[obstacle_index] \
			if obstacle_index < _snapshot.obstacle_contact_polygons.size() \
			else obstacle
		if _snapshot.collision_outlines_visible and \
				obstacle_index < \
					_snapshot.obstacle_contact_rest_polygons.size() and \
				_snapshot.obstacle_contact_rest_polygons[obstacle_index] != \
					contact_obstacle:
			var rest := _polygon_to_screen(
				_snapshot.obstacle_contact_rest_polygons[obstacle_index])
			_draw_closed_polyline(rest, Color(0.78, 0.92, 0.90, 0.24), 2.0)
		if obstacle_index < _snapshot.obstacle_active.size() and \
				_snapshot.obstacle_active[obstacle_index] == 0:
			obstacle_index += 1
			continue
		var screen_obstacle := _polygon_to_screen(obstacle)
		var screen_contact_obstacle := _polygon_to_screen(contact_obstacle)
		var obstacle_bounds := _polygon_bounds(screen_obstacle)
		if obstacle_bounds.end.x < -80.0 or \
				obstacle_bounds.position.x > size.x + 80.0:
			obstacle_index += 1
			continue
		_draw_obstacle(
			obstacle, screen_obstacle, screen_contact_obstacle, obstacle_index)
		obstacle_index += 1

	if _uses_forest_art():
		_redraw_forest_boundary_edges(size)
	elif _uses_curated_zone_art():
		_redraw_authored_zone_boundary_edges(size)

	for fly: Vector2 in _snapshot.fly_positions:
		var fly_screen := _world_to_screen(fly)
		if fly_screen.x < -40.0 or fly_screen.x > size.x + 40.0:
			continue
		_draw_fly(fly_screen, fly)

	for boost: Vector2 in _snapshot.boost_positions:
		var boost_screen := _world_to_screen(boost)
		if boost_screen.x < -50.0 or boost_screen.x > size.x + 50.0:
			continue
		draw_circle(boost_screen, 18.0, Color(0.08, 0.30, 0.34, 0.94))
		draw_arc(boost_screen, 22.0, 0.0, TAU, 28, CYAN, 4.0)
		draw_polyline(PackedVector2Array([
			boost_screen + Vector2(-5.0, -12.0),
			boost_screen + Vector2(4.0, -3.0),
			boost_screen + Vector2(-2.0, 2.0),
			boost_screen + Vector2(7.0, 12.0),
		]), WEB, 4.0, true)

	if _snapshot.web_guides_visible and _snapshot.dive_preview_available:
		var preview_color := GREEN if _snapshot.dive_preview_safe else RED
		var preview_start := _world_to_screen(_render_spider_position())
		var preview_end := _world_to_screen(_snapshot.dive_preview_endpoint)
		var preview_anchor := _world_to_screen(_snapshot.dive_preview_anchor)
		draw_dashed_line(preview_start, preview_end, preview_color, 3.0, 10.0)
		draw_line(preview_end, preview_anchor, Color(preview_color, 0.35), 2.0)
		draw_arc(preview_end, 13.0, 0.0, TAU, 24, preview_color, 3.0)

	if _snapshot.collision_outlines_visible:
		var kill_x := _world_to_screen(
			Vector2(_snapshot.left_kill_boundary, 0.0)).x
		if kill_x > 0.0 and kill_x < size.x:
			draw_line(Vector2(kill_x, 0.0), Vector2(kill_x, size.y), RED, 3.0)


func _draw_continuous_forest_profile(
	world_polygon: PackedVector2Array,
	screen_polygon: PackedVector2Array,
) -> void:
	var profile := _visual_profile_for_world_polygon(world_polygon)
	var rail_asset := ArtAssetCatalog.CANOPY_RAIL_TILE \
		if profile == CourseRegionCatalog.VISUAL_CANOPY \
		else ArtAssetCatalog.FOREST_RAIL_TILE
	var texture := _art_texture(rail_asset)
	if texture == null or screen_polygon.size() < 4:
		return
	# Boundary polygons store the playable profile first and the outer thickness
	# in reverse. Drawing the first half with world-anchored source UVs keeps
	# bark continuous through every contour and chunk seam.
	var profile_size := floori(float(screen_polygon.size()) * 0.5)
	var is_ceiling := world_polygon[0].y < CourseStream.CEILING_Y + 100.0
	for index in range(profile_size - 1):
		var start := screen_polygon[index]
		var finish := screen_polygon[index + 1]
		var world_start := world_polygon[index]
		var world_finish := world_polygon[index + 1]
		if start.x > finish.x:
			var screen_swap := start
			start = finish
			finish = screen_swap
			var world_swap := world_start
			world_start = world_finish
			world_finish = world_swap
		var segment := finish - start
		if segment.length() < 8.0:
			continue
		var flip_y := 1.0 if is_ceiling else -1.0
		var visual_length := segment.length() + \
			FOREST_RAIL_SEGMENT_OVERLAP * 2.0
		var source_world_start := minf(world_start.x, world_finish.x) - \
			FOREST_RAIL_SEGMENT_OVERLAP
		var source_x := source_world_start / FOREST_RAIL_WORLD_REPEAT * \
			float(texture.get_width())
		var source_width := visual_length / FOREST_RAIL_WORLD_REPEAT * \
			float(texture.get_width())
		draw_set_transform(
			start.lerp(finish, 0.5),
			segment.angle(),
			Vector2(1.0, flip_y),
		)
		draw_texture_rect_region(
			texture,
			Rect2(
				Vector2(-visual_length * 0.5, -FOREST_BRANCH_BASELINE),
				Vector2(visual_length, FOREST_BRANCH_HEIGHT),
			),
			Rect2(
				Vector2(source_x, 0.0),
				Vector2(source_width, float(texture.get_height())),
			),
			Color.WHITE,
			false,
			false,
		)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _redraw_forest_boundary_edges(viewport_size: Vector2) -> void:
	# Obstacles deliberately extend behind the wall art. Drawing the continuous
	# rail last masks transparent source padding and makes each hazard look
	# rooted in one environment without changing either collision shape.
	for boundary: PackedVector2Array in _snapshot.boundary_surfaces:
		var screen_boundary := _polygon_to_screen(boundary)
		var bounds := _polygon_bounds(screen_boundary)
		if bounds.end.x < -80.0 or \
				bounds.position.x > viewport_size.x + 80.0:
			continue
		_draw_continuous_forest_profile(boundary, screen_boundary)


func _draw_continuous_zone_profile(
	world_polygon: PackedVector2Array,
	screen_polygon: PackedVector2Array,
) -> void:
	if screen_polygon.size() < 4:
		return
	var is_ceiling := _boundary_is_ceiling(world_polygon)
	var profile := _visual_profile_for_world_polygon(world_polygon)
	var art_spec := ArtAssetCatalog.zone_boundary_art_spec(profile, is_ceiling)
	if art_spec.is_empty():
		return
	var asset_id := StringName(art_spec.get("asset_id", &""))
	var texture := _art_texture(asset_id)
	if texture == null:
		return

	# Boundary polygons store the playable profile first and their outward
	# thickness in reverse. Every wall tile is authored with its playable edge
	# flush to the texture edge, so drawing outward from the profile cannot make
	# the corridor look narrower than the authoritative collision geometry.
	var profile_size := floori(float(screen_polygon.size()) * 0.5)
	var draw_height := float(art_spec.get("draw_height", 108.0))
	var world_repeat := float(art_spec.get("world_repeat", 2048.0))
	var overlap := float(art_spec.get("segment_overlap", 24.0))
	var mirror_outward := bool(art_spec.get("mirror_outward", false))
	for index in range(profile_size - 1):
		var start := screen_polygon[index]
		var finish := screen_polygon[index + 1]
		var world_start := world_polygon[index]
		var world_finish := world_polygon[index + 1]
		if start.x > finish.x:
			var screen_swap := start
			start = finish
			finish = screen_swap
			var world_swap := world_start
			world_start = world_finish
			world_finish = world_swap
		var segment := finish - start
		if segment.length() < 8.0:
			continue
		var visual_length := segment.length() + overlap * 2.0
		var source_world_start := minf(world_start.x, world_finish.x) - overlap
		var source_x := source_world_start / world_repeat * \
			float(texture.get_width())
		var source_width := visual_length / world_repeat * \
			float(texture.get_width())
		var mirror_floor := mirror_outward and not is_ceiling
		draw_set_transform(
			start.lerp(finish, 0.5),
			segment.angle(),
			Vector2(1.0, -1.0 if mirror_floor else 1.0),
		)
		draw_texture_rect_region(
			texture,
			Rect2(
				Vector2(
					-visual_length * 0.5,
					-draw_height if is_ceiling or mirror_floor else 0.0,
				),
				Vector2(visual_length, draw_height),
			),
			Rect2(
				Vector2(source_x, 0.0),
				Vector2(source_width, float(texture.get_height())),
			),
			Color.WHITE,
			false,
			false,
		)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _redraw_authored_zone_boundary_edges(viewport_size: Vector2) -> void:
	# Draw the material edge after obstacles so ceiling/floor-grown objects meet
	# a continuous finished wall instead of exposing transparent joins.
	for boundary: PackedVector2Array in _snapshot.boundary_surfaces:
		var screen_boundary := _polygon_to_screen(boundary)
		var bounds := _polygon_bounds(screen_boundary)
		if bounds.end.x < -80.0 or \
				bounds.position.x > viewport_size.x + 80.0:
			continue
		_draw_continuous_zone_profile(boundary, screen_boundary)


func _boundary_is_ceiling(world_polygon: PackedVector2Array) -> bool:
	return _polygon_bounds(world_polygon).get_center().y < \
		(CourseStream.CEILING_Y + CourseStream.FLOOR_Y) * 0.5


func _draw_obstacle(
	world_polygon: PackedVector2Array,
	polygon: PackedVector2Array,
	contact_polygon: PackedVector2Array,
	obstacle_index: int,
) -> void:
	var obstacle_kind := _snapshot.obstacle_kinds[obstacle_index] \
		if obstacle_index < _snapshot.obstacle_kinds.size() \
		else CourseObstacleCatalog.UNSPECIFIED
	var environment := _environment_theme()
	if not _uses_forest_art():
		_draw_zone_obstacle(
			world_polygon, polygon, contact_polygon, obstacle_index)
		return
	if _uses_forest_art():
		var world_bounds := _polygon_bounds(world_polygon)
		var profile := _visual_profile_for_world_polygon(world_polygon)
		var canopy_art := profile == CourseRegionCatalog.VISUAL_CANOPY
		var screen_bounds := _polygon_bounds(polygon)
		var attached_to_ceiling := \
			world_bounds.position.y <= CourseStream.CEILING_Y + 2.0
		var attached_to_floor := \
			world_bounds.end.y >= CourseStream.FLOOR_Y - 2.0
		var detached := not attached_to_ceiling and not attached_to_floor
		var top_points := 0
		var bottom_points := 0
		for point: Vector2 in world_polygon:
			if absf(point.y - world_bounds.position.y) <= 3.0:
				top_points += 1
			if absf(point.y - world_bounds.end.y) <= 3.0:
				bottom_points += 1
		var hanging := top_points >= bottom_points and not detached
		var wide := screen_bounds.size.x > screen_bounds.size.y * 1.15
		var tall_narrow := screen_bounds.size.y > screen_bounds.size.x * 1.35
		var asset_id := ArtAssetCatalog.CANOPY_BRAMBLE \
			if canopy_art else ArtAssetCatalog.FOREST_BRAMBLE
		var flip_y := false
		var flip_x := false
		var directional_art := CanopyObstacleArt.directional_spec(
			obstacle_kind,
			CanopyObstacleArt.MOUNT_CEILING
				if attached_to_ceiling else CanopyObstacleArt.MOUNT_FLOOR,
		) if canopy_art else {}
		if not directional_art.is_empty():
			asset_id = StringName(directional_art["asset_id"])
			flip_y = bool(directional_art["flip_y"])
			flip_x = bool(directional_art["flip_x"])
		elif canopy_art and detached:
			asset_id = ArtAssetCatalog.CANOPY_BRAMBLE
		elif canopy_art and (tall_narrow or (hanging and not wide)):
			asset_id = ArtAssetCatalog.CANOPY_SEED_POD
			flip_y = attached_to_floor
		elif canopy_art and hanging:
			flip_y = true
		elif detached:
			asset_id = ArtAssetCatalog.FOREST_BRAMBLE
		elif world_polygon.size() == 6 and not tall_narrow:
			asset_id = ArtAssetCatalog.FOREST_ROOT_STUMP
			flip_y = hanging
		elif tall_narrow:
			asset_id = ArtAssetCatalog.FOREST_HANGING_VINE
			flip_y = attached_to_floor
		elif hanging and not wide:
			asset_id = ArtAssetCatalog.FOREST_HANGING_VINE
		elif hanging:
			flip_y = true
		var texture := _art_texture(asset_id)
		var draw_backing := bool(environment.get(
			"draw_obstacle_geometry_backing",
			true,
		)) or texture == null
		if draw_backing:
			_draw_environment_polygon(
				world_polygon,
				polygon,
				environment["obstacle_tint"] as Color,
				OBSTACLE_DARK,
			)
		if texture != null:
			if detached:
				var world_center := world_bounds.get_center()
				var top_left := _world_to_screen(Vector2(
					world_center.x - 9.0,
					CourseStream.CEILING_Y,
				))
				var top_right := _world_to_screen(Vector2(
					world_center.x + 9.0,
					CourseStream.CEILING_Y,
				))
				draw_line(
					top_left,
					Vector2(screen_bounds.get_center().x - 5.0, screen_bounds.position.y),
					Color(WEB, 0.30),
					1.4,
					true,
				)
				draw_line(
					top_right,
					Vector2(screen_bounds.get_center().x + 5.0, screen_bounds.position.y),
					Color(WEB, 0.20),
					1.2,
					true,
				)
			var art_bounds := screen_bounds.grow(
				FOREST_OBSTACLE_ART_OVERSCAN,
			)
			if attached_to_ceiling:
				art_bounds.position.y -= FOREST_RAIL_JOIN_OVERLAP
				art_bounds.size.y += FOREST_RAIL_JOIN_OVERLAP
			elif attached_to_floor:
				art_bounds.size.y += FOREST_RAIL_JOIN_OVERLAP
			if tall_narrow:
				_draw_texture_uncropped_height(texture, art_bounds, flip_y)
			else:
				_draw_texture_cover(texture, art_bounds, flip_y, flip_x)
			if not detached:
				_draw_forest_growth_socket(
					world_polygon,
					polygon,
					hanging,
				)
		if _snapshot.collision_outlines_visible:
			_draw_closed_polyline(
				contact_polygon,
				environment["lethal_edge"] as Color,
				2.0,
			)
		return
	_draw_environment_polygon(
		world_polygon,
		polygon,
		environment["obstacle_tint"] as Color,
		OBSTACLE_DARK,
	)
	if _snapshot.collision_outlines_visible:
		_draw_closed_polyline(
			contact_polygon,
			environment["lethal_edge"] as Color,
			2.0,
		)
	if _environment_theme_index != 0:
		return
	var center := Vector2.ZERO
	for point: Vector2 in polygon:
		center += point
	center /= float(maxi(polygon.size(), 1))
	draw_circle(center, 10.0, Color(OBSTACLE, 0.76))
	for index in range(0, polygon.size(), 2):
		draw_line(
			center,
			center.lerp(polygon[index], 0.82),
			Color(OBSTACLE, 0.72),
			6.0,
		)


func _draw_zone_obstacle(
	_world_polygon: PackedVector2Array,
	polygon: PackedVector2Array,
	contact_polygon: PackedVector2Array,
	obstacle_index: int,
) -> void:
	# World geometry remains the authority. Finished art only replaces the
	# prototype fill when an explicit visual/content-id route resolves to a
	# loaded texture; missing assets retain the honest geometry fallback.
	var visual_id := _snapshot.obstacle_visual_ids[obstacle_index] \
		if obstacle_index < _snapshot.obstacle_visual_ids.size() else &""
	var content_id := _snapshot.obstacle_ids[obstacle_index] \
		if obstacle_index < _snapshot.obstacle_ids.size() else &""
	var anchorable := obstacle_index >= _snapshot.obstacle_anchorable.size() or \
		_snapshot.obstacle_anchorable[obstacle_index] != 0
	var colors := _zone_obstacle_colors(
		_snapshot.region_visual_profile, anchorable, visual_id)
	var visibility := 1.0
	if _snapshot.region_visual_profile == CourseRegionCatalog.VISUAL_MIST and \
			not anchorable:
		var lead_x := _polygon_bounds(polygon).get_center().x
		visibility = clampf((960.0 - lead_x) / 280.0, 0.10, 1.0)
	var fill: Color = colors["fill"]
	var edge: Color = colors["edge"]
	fill.a *= visibility
	edge.a *= visibility
	var art_spec := ArtAssetCatalog.zone_obstacle_art_spec(
		visual_id, content_id, anchorable)
	var asset_id := StringName(art_spec.get("asset_id", &""))
	var texture := _art_texture(asset_id) if not asset_id.is_empty() else null
	var bounds := _polygon_bounds(polygon)
	if asset_id == ArtAssetCatalog.WEB_CITY_RESIDENT and \
			minf(bounds.size.x, bounds.size.y) < 30.0:
		# The resident texture is drawn once over its body and already includes
		# every leg. Component leg polygons remain authoritative collision, but
		# their old fallback outlines made the finished sprite look wireframed.
		if _snapshot.collision_outlines_visible:
			_draw_closed_polyline(contact_polygon, CYAN, 2.0)
		return
	if texture == null:
		draw_colored_polygon(polygon, fill)
		_draw_closed_polyline(polygon, edge, 3.5 if anchorable else 4.0)
		if _snapshot.collision_outlines_visible:
			_draw_closed_polyline(contact_polygon, CYAN, 2.0)
		return

	var overscan := art_spec.get("overscan", Vector2(10.0, 10.0)) as Vector2
	var modulate := Color(1.0, 1.0, 1.0, visibility)
	if StringName(art_spec.get("placement", &"contain")) == &"oriented":
		_draw_texture_oriented(texture, polygon, overscan, modulate)
	else:
		var art_bounds := Rect2(
			bounds.position - overscan,
			bounds.size + overscan * 2.0,
		)
		var minimum_size := art_spec.get("minimum_size", Vector2.ZERO) as Vector2
		var fitted_size := Vector2(
			maxf(art_bounds.size.x, minimum_size.x),
			maxf(art_bounds.size.y, minimum_size.y),
		)
		art_bounds = Rect2(art_bounds.get_center() - fitted_size * 0.5, fitted_size)
		_draw_texture_contain(
			texture,
			art_bounds,
			modulate,
			bool(art_spec.get("flip_x", false)),
			bool(art_spec.get("flip_y", false)),
		)

	if _snapshot.collision_outlines_visible:
		_draw_closed_polyline(contact_polygon, CYAN, 2.0)


func _zone_obstacle_colors(
	profile: StringName,
	anchorable: bool,
	visual_id: StringName,
) -> Dictionary:
	var fill := Color("56352c")
	var edge := Color("f3d7b0") if anchorable else Color("ff765d")
	match profile:
		CourseRegionCatalog.VISUAL_ARBORETUM:
			fill = Color("263c3a")
			edge = Color("bceee2") if anchorable else Color("f4fbff")
		CourseRegionCatalog.VISUAL_STORM:
			fill = Color("293847")
			edge = Color("d8efff") if anchorable else Color("ffb35c")
		CourseRegionCatalog.VISUAL_WEB_CITY:
			fill = Color("25223a")
			edge = Color("edfaff") if anchorable else Color("ff684f")
		CourseRegionCatalog.VISUAL_ASHEN:
			fill = Color("242022")
			edge = Color("d9f7ff") if anchorable else Color("ff6d31")
		CourseRegionCatalog.VISUAL_MIST:
			fill = Color("778184")
			edge = Color("7df4ff") if anchorable else Color("bcc3c4")
	if visual_id in [ZoneCourseBuilder.V_RIDGE_LIGHTNING, ZoneCourseBuilder.V_ASH_EMBER]:
		fill = Color("ff9b3d")
		edge = Color("fff2b0")
	return {"fill": fill, "edge": edge}


func _zone_surface_color(anchor_class: StringName) -> Color:
	match anchor_class:
		CourseGeometry.ANCHOR_MOVING_PIVOT:
			return Color("35b8a8")
		CourseGeometry.ANCHOR_HIGHWAY:
			return Color("d9f7ff")
		CourseGeometry.ANCHOR_STICKY:
			return Color("a86648")
		_:
			return Color(0.07, 0.26, 0.29, 0.96)


func _zone_boundary_colors(profile: StringName) -> Dictionary:
	match profile:
		CourseRegionCatalog.VISUAL_HOLLOW:
			return {"fill": Color("3b241d"), "edge": Color("e8cda7")}
		CourseRegionCatalog.VISUAL_ARBORETUM:
			return {"fill": Color("243633"), "edge": Color("87c4ae")}
		CourseRegionCatalog.VISUAL_STORM:
			return {"fill": Color("202c3a"), "edge": Color("c5e6f5")}
		CourseRegionCatalog.VISUAL_WEB_CITY:
			return {"fill": Color("151628"), "edge": Color("dffaff")}
		CourseRegionCatalog.VISUAL_ASHEN:
			return {"fill": Color("1c1819"), "edge": Color("a89c94")}
		CourseRegionCatalog.VISUAL_MIST:
			return {"fill": Color("6c7476"), "edge": Color("b9c2c3")}
		_:
			return {"fill": Color("33291d"), "edge": Color("f06449")}


func _draw_texture_contain(
	texture: Texture2D,
	bounds: Rect2,
	modulate: Color = Color.WHITE,
	flip_x: bool = false,
	flip_y: bool = false,
) -> void:
	var texture_size := texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	var scale := minf(
		bounds.size.x / texture_size.x,
		bounds.size.y / texture_size.y,
	)
	var draw_size := texture_size * scale
	draw_set_transform(
		bounds.get_center(),
		0.0,
		Vector2(-1.0 if flip_x else 1.0, -1.0 if flip_y else 1.0),
	)
	draw_texture_rect(
		texture,
		Rect2(-draw_size * 0.5, draw_size),
		false,
		modulate,
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_texture_oriented(
	texture: Texture2D,
	polygon: PackedVector2Array,
	overscan: Vector2,
	modulate: Color,
) -> void:
	if polygon.size() < 2:
		return
	var axis := Vector2.RIGHT
	var longest_edge := 0.0
	for index in range(polygon.size()):
		var edge := polygon[(index + 1) % polygon.size()] - polygon[index]
		if edge.length_squared() > longest_edge:
			longest_edge = edge.length_squared()
			axis = edge.normalized()
	var normal := Vector2(-axis.y, axis.x)
	var along_min := INF
	var along_max := -INF
	var across_min := INF
	var across_max := -INF
	for point: Vector2 in polygon:
		var along := point.dot(axis)
		var across := point.dot(normal)
		along_min = minf(along_min, along)
		along_max = maxf(along_max, along)
		across_min = minf(across_min, across)
		across_max = maxf(across_max, across)
	var centre := axis * ((along_min + along_max) * 0.5) + \
		normal * ((across_min + across_max) * 0.5)
	var draw_size := Vector2(
		along_max - along_min + overscan.x * 2.0,
		across_max - across_min + overscan.y * 2.0,
	)
	draw_set_transform(centre, axis.angle(), Vector2.ONE)
	draw_texture_rect(
		texture,
		Rect2(-draw_size * 0.5, draw_size),
		false,
		modulate,
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_forest_growth_socket(
	world_polygon: PackedVector2Array,
	screen_polygon: PackedVector2Array,
	hanging: bool,
) -> void:
	var profile := _visual_profile_for_world_polygon(world_polygon)
	var socket_asset := ArtAssetCatalog.CANOPY_GROWTH_SOCKET \
		if profile == CourseRegionCatalog.VISUAL_CANOPY \
		else ArtAssetCatalog.FOREST_GROWTH_SOCKET
	var texture := _art_texture(socket_asset)
	if texture == null:
		return
	var world_bounds := _polygon_bounds(world_polygon)
	var touches_ceiling := \
		world_bounds.position.y <= CourseStream.CEILING_Y + 2.0
	var touches_floor := world_bounds.end.y >= CourseStream.FLOOR_Y - 2.0
	if not touches_ceiling and not touches_floor:
		return
	var bounds := _polygon_bounds(screen_polygon)
	var width := clampf(bounds.size.x * 0.72, 112.0, 218.0)
	var height := width * float(texture.get_height()) / \
		float(texture.get_width())
	var contact_y := bounds.position.y if hanging else bounds.end.y
	draw_set_transform(
		Vector2(bounds.get_center().x, contact_y),
		0.0,
		Vector2(1.0, -1.0 if hanging else 1.0),
	)
	draw_texture_rect(
		texture,
		Rect2(
			Vector2(-width * 0.5, -height + 12.0),
			Vector2(width, height),
		),
		false,
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_fly(screen_position: Vector2, world_position: Vector2) -> void:
	var texture := _art_texture(ArtAssetCatalog.GOLDEN_FLY)
	if texture == null:
		draw_circle(screen_position, 6.0, YELLOW)
		draw_circle(screen_position + Vector2(-7.0, -5.0), 5.0, Color(WEB, 0.74))
		draw_circle(screen_position + Vector2(7.0, -5.0), 5.0, Color(WEB, 0.74))
		draw_arc(screen_position, 11.0, 0.0, TAU, 20, Color(YELLOW, 0.48), 2.0)
		return
	var flutter := sin(
		float(_snapshot.tick) * 0.22 + world_position.x * 0.013,
	)
	var sprite_size := Vector2(34.0, 23.0) * (1.0 + flutter * 0.025)
	draw_circle(screen_position, 14.0, Color(YELLOW, 0.13))
	draw_texture_rect(
		texture,
		Rect2(screen_position - sprite_size * 0.5, sprite_size),
		false,
	)


func _draw_texture_cover(
	texture: Texture2D,
	bounds: Rect2,
	flip_y: bool = false,
	flip_x: bool = false,
) -> void:
	var texture_size := texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0 or \
			bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return
	var source := Rect2(Vector2.ZERO, texture_size)
	var source_aspect := texture_size.x / texture_size.y
	var target_aspect := bounds.size.x / bounds.size.y
	if source_aspect > target_aspect:
		var cropped_width := texture_size.y * target_aspect
		source.position.x = (texture_size.x - cropped_width) * 0.5
		source.size.x = cropped_width
	else:
		var cropped_height := texture_size.x / target_aspect
		source.position.y = (texture_size.y - cropped_height) * 0.5
		source.size.y = cropped_height
	var scale_x := -1.0 if flip_x else 1.0
	var scale_y := -1.0 if flip_y else 1.0
	draw_set_transform(bounds.get_center(), 0.0, Vector2(scale_x, scale_y))
	draw_texture_rect_region(
		texture,
		Rect2(-bounds.size * 0.5, bounds.size),
		source,
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_texture_uncropped_height(
	texture: Texture2D,
	bounds: Rect2,
	flip_y: bool = false,
) -> void:
	# Tall growth uses the complete vertical vine asset instead of cover-cropping
	# its sides into a rectangular cut. A little conservative horizontal
	# overscan is preferable to invisible lethal geometry; collision remains the
	# smaller authoritative polygon and DEBUG can still show it exactly.
	var texture_size := texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0 or \
			bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return
	var natural_width := bounds.size.y * texture_size.x / texture_size.y
	var draw_size := Vector2(maxf(bounds.size.x, natural_width), bounds.size.y)
	draw_set_transform(
		bounds.get_center(),
		0.0,
		Vector2(1.0, -1.0 if flip_y else 1.0),
	)
	draw_texture_rect(
		texture,
		Rect2(-draw_size * 0.5, draw_size),
		false,
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_web() -> void:
	if not _snapshot.web_attached:
		return
	var spider := _world_to_screen(_render_spider_position())
	var anchor := _world_to_screen(_snapshot.anchor)
	var web_color := _web_color()
	draw_line(spider, anchor, Color(0.25, 0.72, 0.77, 0.35), 7.0)
	draw_line(spider, anchor, web_color, 2.5)
	if _snapshot.reel_active:
		var pulse := 0.5 if _reduced_motion else \
			fposmod(_motion_time * 2.2, 1.0)
		draw_circle(spider.lerp(anchor, pulse), 7.0, CYAN)


func _draw_action_feedback() -> void:
	if _reel_feedback_remaining > 0.0 and _snapshot.web_attached:
		var reel_alpha := clampf(
			_reel_feedback_remaining / REEL_FEEDBACK_DURATION,
			0.0,
			1.0,
		)
		var spider := _world_to_screen(_render_spider_position())
		var anchor := _world_to_screen(_snapshot.anchor)
		draw_line(spider, anchor, Color(CYAN, reel_alpha * 0.82), 9.0)
		var reel_progress := 1.0 - reel_alpha
		var reel_radius := 28.0 if _reduced_motion else \
			28.0 + reel_progress * 24.0
		draw_arc(
			spider,
			reel_radius,
			0.0,
			TAU,
			40,
			Color(CYAN, reel_alpha),
			5.0,
		)

	if _burst_feedback_remaining <= 0.0:
		return
	var burst_alpha := clampf(
		_burst_feedback_remaining / BURST_FEEDBACK_DURATION,
		0.0,
		1.0,
	)
	var origin := _world_to_screen(_burst_feedback_origin)
	var anchor := _world_to_screen(_burst_feedback_anchor)
	draw_line(origin, anchor, Color(YELLOW, burst_alpha * 0.72), 10.0)
	draw_line(
		origin,
		origin + _burst_feedback_direction * 150.0,
		Color(WEB, burst_alpha),
		7.0,
	)
	var burst_progress := 1.0 - burst_alpha
	var burst_radius := 32.0 if _reduced_motion else \
		32.0 + burst_progress * 38.0
	draw_arc(
		origin,
		burst_radius,
		0.0,
		TAU,
		48,
		Color(YELLOW, burst_alpha),
		6.0,
	)


func _draw_spider() -> void:
	var render_velocity := _render_spider_velocity()
	var center := _world_to_screen(_render_spider_position())
	var rotation := _render_spider_rotation(render_velocity)
	var pose_scale := _spider_pose_scale(render_velocity)
	var scale := _snapshot.player_collision_radius / 18.0
	var accent := SPIDER_ACCENT
	var body := SPIDER_DARK
	match _snapshot.spider_style:
		PlayerProgress.STYLE_AMBER:
			accent = Color("ffd166")
			body = Color("4d2b20")
		PlayerProgress.STYLE_COMET:
			accent = Color("8be9fd")
			body = Color("3a275f")
	match _snapshot.spider_id:
		SpiderCatalog.SKITTER:
			accent = accent.lightened(0.18)
		SpiderCatalog.ANCHORITE:
			body = body.lightened(0.12)
		SpiderCatalog.BALLOONER:
			accent = accent.lerp(CYAN, 0.34)
		SpiderCatalog.BUCKLER:
			body = body.lerp(Color("435b67"), 0.42)
			accent = accent.lerp(GREEN, 0.45)
	var finished_sprite := _draw_finished_spider_sprite(
		center,
		rotation,
		scale,
		pose_scale,
	)
	if not finished_sprite:
		for side in [-1.0, 1.0]:
			for index in range(4):
				var y := -15.0 + float(index) * 10.0
				var hip := center + (
					_pose_local(Vector2(side * 10.0, y), pose_scale) *
						scale).rotated(rotation)
				var knee := center + (
					_pose_local(Vector2(
						side * (24.0 + index * 2.0),
						y - 9.0 + index * 5.0,
					), pose_scale) * scale).rotated(rotation)
				var foot := center + (
					_pose_local(Vector2(
						side * (38.0 + index * 3.0),
						y + 2.0 + index * 6.0,
					), pose_scale) * scale).rotated(rotation)
				draw_polyline(
					PackedVector2Array([hip, knee, foot]),
					body,
					5.0,
					true,
				)
				draw_polyline(
					PackedVector2Array([hip, knee, foot]),
					accent,
					1.5,
					true,
				)
		draw_circle(center + _pose_local(
			Vector2(-8.0, 0.0), pose_scale).rotated(rotation) * scale,
			17.0 * scale, body)
		draw_circle(center + _pose_local(
			Vector2(12.0, -1.0), pose_scale).rotated(rotation) * scale,
			14.0 * scale, body)
		draw_circle(center + _pose_local(
			Vector2(-9.0, -4.0), pose_scale).rotated(rotation) * scale,
			6.0 * scale, accent)
		draw_circle(center + _pose_local(
			Vector2(17.0, -5.0), pose_scale).rotated(rotation) * scale,
			3.2 * scale, WEB)
		draw_circle(center + _pose_local(
			Vector2(17.0, -5.0), pose_scale).rotated(rotation) * scale,
			1.4 * scale, Color("15202b"))
	if _snapshot.spider_id == SpiderCatalog.BALLOONER and \
			_snapshot.glide_remaining > 0.0:
		draw_arc(
			center + Vector2(0.0, -23.0 * scale),
			30.0 * scale,
			PI,
			TAU,
			30,
			Color(_web_color(), 0.72),
			3.0,
		)
	if _snapshot.rescue_shield_remaining > 0.0:
		draw_arc(
			center,
			32.0 * scale,
			0.0,
			TAU,
			48,
			Color(GREEN, 0.82),
			5.0,
		)
	if _snapshot.surface_bounce_enabled:
		draw_arc(
			center,
			27.0 * scale,
			-PI * 0.92,
			PI * 0.92,
			42,
			GREEN if _snapshot.surface_bounce_ready else Color(MUTED, 0.42),
			4.0,
		)
	if _show_debug_tools and _snapshot.collision_outlines_visible:
		draw_arc(center, _snapshot.player_collision_radius, 0.0, TAU, 40, CYAN, 1.5)
		draw_arc(
			center,
			_snapshot.obstacle_contact_radius,
			0.0,
			TAU,
			40,
			YELLOW,
			1.5,
		)
		draw_line(center, center + render_velocity * 0.12, YELLOW, 2.0)


## The bird is a presentation of SimulationWorld state, never a second motion
## source. Its four authored poses are blended from the fixed-tick flap phase;
## bob shares that same phase and banking reads only authoritative Y velocity.
func _draw_bird() -> void:
	if _snapshot == null or not _snapshot.bird_enabled:
		return
	var center := _world_to_screen(_render_bird_position())
	var bob := bird_vertical_bob(_snapshot.bird_flap_phase, _reduced_motion)
	center.y += bob
	var bank := bird_bank(_render_bird_velocity().y, _reduced_motion)
	var glide_mix := 1.0 if _reduced_motion else \
		bird_glide_mix(_snapshot.bird_flap_rate)
	var sample := bird_frame_sample(_snapshot.bird_flap_phase)
	var current_asset: StringName = BIRD_FLAP_ASSETS[int(sample["current"])]
	var next_asset: StringName = BIRD_FLAP_ASSETS[int(sample["next"])]
	var current_texture := _art_texture(current_asset)
	var next_texture := _art_texture(next_asset)
	var glide_texture := _art_texture(ArtAssetCatalog.PURSUING_BIRD_GLIDE)

	# A phase-coupled halo makes closing pressure readable without inventing an
	# independent visual clock. The bird itself remains the exact danger line.
	if _snapshot.bird_closing:
		var danger_pulse := 0.16 + \
			absf(sin(_snapshot.bird_flap_phase * TAU)) * 0.10
		draw_circle(center, 82.0, Color(RED, danger_pulse))

	draw_set_transform(center, bank, Vector2.ONE)
	var bird_rect := Rect2(-BIRD_CANVAS_SIZE * 0.5, BIRD_CANVAS_SIZE)
	if current_texture != null and next_texture != null:
		var blend := float(sample["blend"])
		var flap_alpha := 1.0 - glide_mix
		draw_texture_rect(
			current_texture, bird_rect, false,
			Color(1.0, 1.0, 1.0, flap_alpha * (1.0 - blend)))
		draw_texture_rect(
			next_texture, bird_rect, false,
			Color(1.0, 1.0, 1.0, flap_alpha * blend))
		if glide_texture != null and glide_mix > 0.0:
			draw_texture_rect(
				glide_texture, bird_rect, false,
				Color(1.0, 1.0, 1.0, glide_mix))
	elif glide_texture != null:
		draw_texture_rect(glide_texture, bird_rect, false, Color.WHITE)
	else:
		# Import failures stay legible in development builds without changing the
		# contact seam: this simple silhouette is presentation-only fallback art.
		draw_colored_polygon(PackedVector2Array([
			Vector2(-90.0, 8.0), Vector2(-24.0, -34.0),
			Vector2(28.0, -10.0), Vector2(92.0, 0.0),
			Vector2(28.0, 19.0), Vector2(-20.0, 40.0),
		]), Color("592c24"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func bird_frame_sample(phase: float) -> Dictionary:
	var frame_position := fposmod(phase, 1.0) * \
		float(BIRD_FLAP_SEQUENCE.size())
	var slot := floori(frame_position) % BIRD_FLAP_SEQUENCE.size()
	var next_slot := (slot + 1) % BIRD_FLAP_SEQUENCE.size()
	var raw_blend := frame_position - floorf(frame_position)
	var smooth_blend := raw_blend * raw_blend * (3.0 - 2.0 * raw_blend)
	return {
		"current": BIRD_FLAP_SEQUENCE[slot],
		"next": BIRD_FLAP_SEQUENCE[next_slot],
		"blend": smooth_blend,
	}


static func bird_glide_mix(flap_rate: float) -> float:
	return 1.0 - clampf((flap_rate - 0.70) / 0.55, 0.0, 1.0)


static func bird_vertical_bob(phase: float, reduced_motion: bool) -> float:
	if reduced_motion:
		return 0.0
	return sin((fposmod(phase, 1.0) - 0.125) * TAU) * 8.0


static func bird_bank(vertical_velocity: float, reduced_motion: bool) -> float:
	var strength := 0.10 if reduced_motion else 0.30
	return clampf(vertical_velocity / 520.0, -1.0, 1.0) * strength


func _draw_finished_spider_sprite(
	center: Vector2,
	rotation: float,
	scale: float,
	pose_scale: Vector2,
) -> bool:
	var asset_id := ArtAssetCatalog.spider_asset_id(_snapshot.spider_id)
	if asset_id == &"":
		return false
	var texture := _art_texture(asset_id)
	if texture == null:
		return false
	var tint := ArtAssetCatalog.spider_style_tint(_snapshot.spider_style)
	var sprite_size := Vector2(96.0, 46.0) * scale
	draw_set_transform(center, rotation, pose_scale)
	draw_texture_rect(
		texture,
		Rect2(-sprite_size * 0.5, sprite_size),
		false,
		tint,
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	return true


func _draw_feedback() -> void:
	if _feedback_remaining <= 0.0:
		return
	if _feedback_position != Vector2.ZERO:
		var screen := _world_to_screen(_feedback_position)
		var radius := 18.0 + (1.2 - _feedback_remaining) * 28.0
		draw_arc(screen, radius, 0.0, TAU, 32,
			Color(_feedback_color, clampf(_feedback_remaining, 0.0, 1.0)), 3.0)


func _draw_hud(size: Vector2) -> void:
	var distance_metres := _snapshot.distance_pixels / 10.0
	_draw_text(Vector2(142.0, 48.0), "%05.1f m" % distance_metres, 28, WEB)
	_draw_text(
		Vector2(142.0, 72.0),
		_snapshot.region_name,
		14,
		CYAN,
	)
	_draw_text(
		Vector2(size.x - 280.0, 48.0),
		"FLIES %d  ·  TOTAL %d" % [_snapshot.run_flies, _snapshot.total_flies],
		20,
		YELLOW,
	)
	if _snapshot.burst_frenzy_remaining > 0.0:
		_draw_text(
			Vector2(size.x - 280.0, 78.0),
			"BURST FRENZY %.1fs" % _snapshot.burst_frenzy_remaining,
			18,
			CYAN,
		)
	var life_text := "RESCUE READY" if _snapshot.rescue_available \
		else "RESCUE SPENT"
	_draw_text(
		Vector2(size.x - 280.0, 104.0),
		life_text,
		16,
		GREEN if _snapshot.rescue_available else MUTED,
	)
	if _snapshot.glide_capacity > 0.0:
		_draw_text(
			Vector2(size.x - 280.0, 128.0),
			"GLIDE %.1fs" % _snapshot.glide_remaining,
			16,
			CYAN,
		)
	if _snapshot.surface_bounce_enabled:
		_draw_text(
			Vector2(size.x - 280.0, 152.0),
			"SHELL READY" if _snapshot.surface_bounce_ready else "SHELL SPENT",
			16,
			GREEN if _snapshot.surface_bounce_ready else MUTED,
		)
	_draw_button(LabLayout.menu_rect(size), "MENU", false)
	if _show_control_hints:
		_draw_text(Vector2(142.0, 96.0),
			"Tap solid above to web · tap solid below to Dive Pull", 16, MUTED)
		_draw_text(Vector2(142.0, 119.0), _feedback_message, 17, _feedback_color)
	if _snapshot.run_mode == SwingLabSession.RUN_PRACTICE:
		_draw_centered_text(
			Vector2(size.x * 0.5, 42.0),
			_run_access_status(),
			17,
			YELLOW,
		)
	elif _snapshot.run_mode == SwingLabSession.RUN_TUTORIAL_PRACTICE:
		var coaching := LabLayout.tutorial_coaching_rect(size)
		var coaching_color := GREEN \
			if _snapshot.tutorial_objective_complete else CYAN
		draw_rect(coaching, Color(0.02, 0.07, 0.08, 0.94))
		draw_rect(coaching, coaching_color, false, 3.0)
		_draw_centered_text(
			Vector2(coaching.get_center().x, coaching.position.y + 27.0),
			_snapshot.tutorial_progress,
			16,
			coaching_color,
		)
		_draw_centered_text(
			Vector2(coaching.get_center().x, coaching.position.y + 57.0),
			_snapshot.tutorial_coaching,
			14,
			WEB,
		)
		_draw_centered_text(
			Vector2(coaching.get_center().x, coaching.position.y + 78.0),
			"NO REWARDS · RETURNS TO THIS LESSON",
			12,
			YELLOW,
		)
	if _region_banner_remaining > 0.0:
		var alpha := clampf(_region_banner_remaining, 0.0, 1.0)
		var banner := Rect2(
			Vector2(size.x * 0.25, size.y * 0.19),
			Vector2(size.x * 0.5, 90.0),
		)
		draw_rect(banner, Color(0.02, 0.07, 0.08, 0.78 * alpha))
		draw_rect(banner, Color(CYAN, 0.72 * alpha), false, 2.0)
		_draw_centered_text(
			Vector2(size.x * 0.5, banner.position.y + 37.0),
			_region_banner_name,
			24,
			Color(WEB, alpha),
		)
		_draw_centered_text(
			Vector2(size.x * 0.5, banner.position.y + 65.0),
			_region_banner_focus,
			15,
			Color(CYAN, alpha),
		)
	_draw_text(
		Vector2(30.0, size.y - 18.0),
		"BUILD %s" % ProjectSettings.get_setting(
			"application/config/version",
			"unknown",
		),
		13,
		MUTED,
	)

	if _show_debug_tools:
		var debug_rect := LabLayout.debug_toggle_rect(size)
		_draw_button(
			debug_rect,
			"CLOSE" if _snapshot.debug_visible else "DEBUG",
			_snapshot.debug_visible,
		)

	var reel_rect := LabLayout.reel_rect(size)
	var center := reel_rect.get_center()
	var radius := reel_rect.size.x * 0.44
	var reel_fill := Color(0.04, 0.3, 0.34, 0.94) if _snapshot.reel_active \
		else Color(0.04, 0.12, 0.16, 0.82)
	draw_circle(center, radius, reel_fill)
	draw_arc(center, radius, 0.0, TAU, 64,
		CYAN if _snapshot.reel_active else Color(0.55, 0.72, 0.76, 0.55),
		6.0 if _snapshot.reel_active else 4.0)
	if _reel_feedback_remaining > 0.0:
		draw_arc(center, radius + 8.0, 0.0, TAU, 64, WEB, 7.0)
	var energy_ratio := _snapshot.reel_energy / maxf(_snapshot.reel_capacity, 0.001)
	draw_arc(center, radius, -PI * 0.5, -PI * 0.5 + TAU * energy_ratio,
		64, CYAN if _snapshot.reel_lockout <= 0.0 else RED, 8.0)
	var reel_label := "PULL" if _snapshot.reel_active else "REEL"
	_draw_centered_text(center + Vector2(0.0, 7.0), reel_label, 22, WEB)

	var burst_rect := LabLayout.burst_rect(size)
	var burst_center := burst_rect.get_center()
	var burst_radius := burst_rect.size.x * 0.44
	var burst_ready := _snapshot.burst_charges > 0 and \
		_snapshot.web_attached
	var burst_fill := Color(0.36, 0.19, 0.06, 0.96) if burst_ready \
		else Color(0.12, 0.1, 0.08, 0.86)
	draw_circle(burst_center, burst_radius, burst_fill)
	draw_arc(burst_center, burst_radius, 0.0, TAU, 64,
		YELLOW if burst_ready else Color(0.54, 0.47, 0.37, 0.64), 5.0)
	if _burst_feedback_remaining > 0.0:
		draw_arc(burst_center, burst_radius + 8.0, 0.0, TAU, 64, WEB, 8.0)
	var cooldown_ratio := 1.0 - clampf(
		_snapshot.burst_cooldown /
			maxf(_snapshot.burst_cooldown_capacity, 0.001),
		0.0,
		1.0,
	)
	draw_arc(burst_center, burst_radius, -PI * 0.5,
		-PI * 0.5 + TAU * cooldown_ratio, 64, YELLOW, 9.0)
	var burst_label := "PULL" if _snapshot.pull_active else (
		"ATTACH" if not _snapshot.web_attached else (
		"BURST" if burst_ready else "%.1f" % _snapshot.burst_cooldown)
	)
	_draw_centered_text(
		burst_center + Vector2(0.0, 7.0), burst_label, 20, WEB)
	if _snapshot.burst_charge_capacity > 1:
		# Reserve pips: filled while a stored Burst is ready, hollow while
		# the serial refill timer is still working on that slot.
		var pip_span := 22.0
		var pip_left := burst_center + Vector2(
			-pip_span * 0.5 * (_snapshot.burst_charge_capacity - 1), 40.0)
		for pip in range(_snapshot.burst_charge_capacity):
			var pip_center := pip_left + Vector2(pip_span * pip, 0.0)
			if pip < _snapshot.burst_charges:
				draw_circle(pip_center, 6.0, YELLOW)
			else:
				draw_arc(pip_center, 6.0, 0.0, TAU, 24,
					Color(0.54, 0.47, 0.37, 0.8), 2.0)

	if _snapshot.run_state != &"active":
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.04, 0.06, 0.62))
		if run_feedback_prompt_visible():
			_draw_run_feedback_prompt(size)
		else:
			var title := \
				"FALLING…" if _snapshot.run_state == &"dying" else "RUN ENDED"
			_draw_text(
				Vector2(size.x * 0.5 - 90.0, size.y * 0.43), title, 30, WEB)
		if _snapshot.run_state == &"dead" and \
				not run_feedback_prompt_visible():
			_draw_text(Vector2(size.x * 0.5 - 154.0, size.y * 0.5),
				"Tap anywhere to restart", 22, CYAN)


func _draw_run_feedback_prompt(size: Vector2) -> void:
	var panel := LabLayout.run_feedback_panel_rect(size)
	draw_rect(panel, Color(0.02, 0.07, 0.09, 0.98))
	draw_rect(panel, CYAN, false, 3.0)
	var ordinal := int(_run_feedback_prompt.get("eligible_run_ordinal", 0))
	var limit := int(_run_feedback_prompt.get("eligible_run_limit", 0))
	_draw_centered_text(
		panel.position + Vector2(panel.size.x * 0.5, 34.0),
		"QUICK CHECK · RUN %d OF %d" % [ordinal, limit],
		16,
		YELLOW,
	)
	_draw_centered_text(
		panel.position + Vector2(panel.size.x * 0.5, 78.0),
		str(_run_feedback_prompt.get("question_line_one", "")),
		22,
		WEB,
	)
	_draw_centered_text(
		panel.position + Vector2(panel.size.x * 0.5, 108.0),
		str(_run_feedback_prompt.get("question_line_two", "")),
		22,
		WEB,
	)
	_draw_button(
		LabLayout.run_feedback_yes_rect(size),
		str(_run_feedback_prompt.get("yes_label", "YES — I KNEW")),
		true,
	)
	_draw_button(
		LabLayout.run_feedback_no_rect(size),
		str(_run_feedback_prompt.get("no_label", "NO — NOT SURE")),
		false,
	)
	_draw_button(
		LabLayout.run_feedback_skip_rect(size),
		"SKIP · RESTART",
		false,
	)
	_draw_centered_text(
		panel.position + Vector2(panel.size.x * 0.5, panel.size.y - 18.0),
		"LOCAL ONLY · INCLUDED IN MANUAL RUN HISTORY EXPORT",
		12,
		MUTED,
	)
	_draw_button(LabLayout.menu_rect(size), "MENU", false)


func _draw_debug(size: Vector2) -> void:
	var panel := LabLayout.debug_panel_rect(size)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.03, 0.05, 0.56))
	draw_rect(panel, Color(0.02, 0.07, 0.1, 0.98))
	draw_rect(panel, CYAN, false, 2.0)
	_draw_text(Vector2(94.0, 52.0), "SWING LAB TUNING", 25, WEB)
	_draw_text(
		Vector2(94.0, 76.0),
		"Choose a section, then use one-tap values or the large − / + controls.",
		15,
		MUTED,
	)

	for index in range(SwingConfig.preset_names().size()):
		var name := SwingConfig.preset_names()[index]
		_draw_button(
			LabLayout.preset_rect(index, size),
			_preset_label(name),
			name == _snapshot.preset_name,
		)

	for index in range(TuningCatalog.category_count()):
		var category := TuningCatalog.category(index)
		_draw_button(
			LabLayout.category_rect(index, size),
			str(category["label"]),
			index == _snapshot.debug_category_index,
		)

	var active_category := TuningCatalog.category(
		_snapshot.debug_category_index)
	_draw_text(
		Vector2(96.0, LabLayout.DEBUG_CONTENT_TOP - 10.0),
		str(active_category["help"]),
		14,
		MUTED,
	)
	if StringName(active_category["id"]) == TuningCatalog.CATEGORY_VISUALS:
		_draw_environment_theme_cards(size)
	elif StringName(active_category["id"]) == TuningCatalog.CATEGORY_OVERLAYS:
		_draw_overlay_controls(size)
	elif _snapshot.debug_category_index == TuningCatalog.tools_category_index():
		_draw_debug_tools(size)
	else:
		_draw_tuning_cards(StringName(active_category["id"]), size)

	# The modal is drawn after the HUD, so redraw its close affordance on top.
	_draw_button(
		LabLayout.debug_toggle_rect(size),
		"CLOSE",
		true,
	)


func _draw_tuning_cards(
	category_id: StringName,
	size: Vector2,
) -> void:
	var parameters := TuningCatalog.parameters_for_category(category_id)
	for card_index in range(parameters.size()):
		var descriptor: Dictionary = parameters[card_index]
		var parameter := StringName(descriptor["id"])
		var value := float(_snapshot.tuning_values.get(parameter, 0.0))
		var card := LabLayout.parameter_card_rect(card_index, size)
		var selected := parameter == _snapshot.selected_parameter
		draw_rect(
			card,
			Color(0.045, 0.15, 0.18, 0.98) if selected
				else Color(0.025, 0.105, 0.13, 0.98),
		)
		draw_rect(card, CYAN if selected else Color(MUTED, 0.65), false, 2.0)
		_draw_text(
			card.position + Vector2(18.0, 29.0),
			str(descriptor["label"]),
			19,
			WEB,
		)
		_draw_text(
			card.position + Vector2(18.0, 56.0),
			str(descriptor["help"]),
			14,
			MUTED,
		)
		_draw_text(
			card.position + Vector2(card.size.x - 154.0, 30.0),
			_format_tuning_value(parameter, value),
			18,
			YELLOW,
		)
		_draw_button(
			LabLayout.parameter_minus_rect(card_index, size), "−", false)
		_draw_button(
			LabLayout.parameter_plus_rect(card_index, size), "+", false)

		var quick_values: Array = descriptor["quick"]
		for quick_index in range(quick_values.size()):
			var quick_value := float(quick_values[quick_index])
			_draw_button(
				LabLayout.parameter_quick_rect(
					card_index,
					quick_index,
					quick_values.size(),
					size,
				),
				_quick_value_label(parameter, quick_value),
				is_equal_approx(value, quick_value),
			)
		if parameter == TuningCatalog.DEBUG_START_DISTANCE:
			_draw_button(
				LabLayout.parameter_value_apply_rect(card_index, size),
				"GO",
				false,
			)

	if category_id == TuningCatalog.CATEGORY_PULLS:
		var status := "DIVE READY" if _snapshot.dive_ready \
			else "DIVE NEEDS AN UPPER WEB"
		var status_color := GREEN if _snapshot.dive_ready else YELLOW
		var panel := LabLayout.debug_panel_rect(size)
		_draw_text(
			Vector2(panel.end.x - 324.0, panel.end.y - 24.0),
			status,
			15,
			status_color,
		)
	elif category_id == TuningCatalog.CATEGORY_ABILITIES and \
			_snapshot.surface_bounce_enabled:
		var shell_status := "IMPACT SHELL READY" \
			if _snapshot.surface_bounce_ready \
			else "IMPACT SHELL NEEDS AN UPPER WEB"
		var panel := LabLayout.debug_panel_rect(size)
		_draw_text(
			Vector2(panel.end.x - 390.0, panel.end.y - 24.0),
			shell_status,
			15,
			GREEN if _snapshot.surface_bounce_ready else YELLOW,
		)
	elif category_id == TuningCatalog.CATEGORY_RUN:
		var panel := LabLayout.debug_panel_rect(size)
		_draw_text(
			Vector2(panel.position.x + 20.0, panel.end.y - 24.0),
			"DEPTH CHANGES RESTART THE TEST · CLOSE DEBUG TO PLAY",
			15,
			YELLOW,
		)


func _draw_debug_tools(size: Vector2) -> void:
	var labels := [
		"Pause simulation",
		"Advance one physics frame",
		"Quarter-speed playback",
		"Record input trace",
		"Replay last trace",
		"Export diagnostic file",
	]
	var descriptions := [
		"Freeze the run while keeping this menu responsive.",
		"Pause and move the simulation forward exactly once.",
		"Compare movement at 25% speed.",
		"Capture deterministic commands for later comparison.",
		"Restart and play the most recent command trace.",
		"Save positions, tuning, pull state, and command history.",
	]
	for index in range(labels.size()):
		var card := LabLayout.utility_rect(index, size)
		var active := (
			(index == 0 and _snapshot.debug_paused)
			or (index == 2 and _snapshot.slow_motion)
			or (index == 3 and _snapshot.recording)
			or (index == 4 and _snapshot.replaying)
		)
		draw_rect(
			card,
			Color(0.08, 0.35, 0.38, 0.94) if active
				else Color(0.025, 0.105, 0.13, 0.98),
		)
		draw_rect(card, CYAN if active else MUTED, false, 2.0)
		_draw_text(card.position + Vector2(20.0, 42.0), labels[index], 20, WEB)
		_draw_text(
			card.position + Vector2(20.0, 74.0),
			descriptions[index],
			14,
			MUTED,
		)
		var state := ""
		match index:
			0:
				state = "PAUSED" if _snapshot.debug_paused else "RUNNING"
			2:
				state = "ON" if _snapshot.slow_motion else "OFF"
			3:
				state = "RECORDING" if _snapshot.recording else "READY"
			4:
				state = "PLAYING" if _snapshot.replaying else "READY"
			5:
				state = "TOUCH TO SAVE"
		if not state.is_empty():
			_draw_text(card.position + Vector2(20.0, 111.0), state, 14, YELLOW)


func _draw_overlay_controls(size: Vector2) -> void:
	var labels := ["Collision outlines", "Web target guides"]
	var descriptions := [
		"Show exact lethal polygons, player radius, velocity, and kill boundary.",
		"Show optional attachment markers and the predicted Dive endpoint.",
	]
	var active_states := [
		_snapshot.collision_outlines_visible,
		_snapshot.web_guides_visible,
	]
	for index in range(labels.size()):
		var card := LabLayout.parameter_card_rect(index, size)
		var active: bool = active_states[index]
		draw_rect(
			card,
			Color(0.08, 0.35, 0.38, 0.94) if active
				else Color(0.025, 0.105, 0.13, 0.98),
		)
		draw_rect(card, CYAN if active else MUTED, false, 2.0)
		_draw_text(card.position + Vector2(20.0, 42.0), labels[index], 20, WEB)
		_draw_text(
			card.position + Vector2(20.0, 74.0),
			descriptions[index],
			14,
			MUTED,
		)
		_draw_text(
			card.position + Vector2(20.0, 111.0),
			"ON" if active else "OFF",
			14,
			GREEN if active else YELLOW,
		)


func _draw_environment_theme_cards(size: Vector2) -> void:
	for index in range(EnvironmentThemeCatalog.count()):
		var definition := EnvironmentThemeCatalog.theme(index)
		var card := LabLayout.environment_theme_card_rect(index, size)
		var selected := index == _environment_theme_index
		draw_rect(
			card,
			Color(0.045, 0.15, 0.18, 0.98) if selected
				else Color(0.025, 0.105, 0.13, 0.98),
		)
		var preview := Rect2(
			card.position + Vector2(8.0, 8.0),
			Vector2(card.size.x - 16.0, 102.0),
		)
		var texture := _environment_textures.get(index) as Texture2D
		if texture == null:
			draw_rect(preview, Color("102531"))
			draw_rect(
				Rect2(
					preview.position,
					Vector2(preview.size.x, preview.size.y * 0.45),
				),
				Color(0.20, 0.16, 0.09, 0.96),
			)
			draw_line(
				preview.position + Vector2(0.0, preview.size.y * 0.45),
				preview.position + Vector2(
					preview.size.x,
					preview.size.y * 0.45,
				),
				YELLOW,
				4.0,
			)
		else:
			draw_texture_rect(
				texture,
				preview,
				true,
				definition["material_tint"] as Color,
			)
			if StringName(definition["id"]) == \
					EnvironmentThemeCatalog.ANCIENT_FOREST:
				var branch := _art_texture(
					ArtAssetCatalog.FOREST_RAIL_TILE,
				)
				if branch != null:
					draw_texture_rect(
						branch,
						Rect2(
							preview.position + Vector2(0.0, 54.0),
							Vector2(preview.size.x, 44.0),
						),
						false,
					)
		draw_rect(
			card,
			definition["accent"] as Color if selected else Color(MUTED, 0.65),
			false,
			3.0 if selected else 2.0,
		)
		_draw_text(
			card.position + Vector2(14.0, 136.0),
			str(definition["label"]),
			18,
			WEB,
		)
		_draw_text(
			card.position + Vector2(14.0, 164.0),
			str(definition["description"]),
			13,
			MUTED,
		)
		if selected:
			_draw_text(
				card.end - Vector2(88.0, 16.0),
				"ACTIVE",
				13,
				definition["lethal_edge"] as Color,
			)


func _draw_button(rect: Rect2, label: String, active: bool) -> void:
	draw_rect(rect, Color(0.08, 0.35, 0.38, 0.94) if active
		else Color(0.04, 0.14, 0.18, 0.88))
	draw_rect(rect, CYAN if active else MUTED, false, 2.0)
	var width := _font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
	_draw_text(Vector2(rect.get_center().x - width * 0.5, rect.get_center().y + 5.0),
		label, 15, WEB)


func _draw_text(position: Vector2, text: String, size: int, color: Color) -> void:
	draw_string(_font, position, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)


func _draw_centered_text(
	center: Vector2,
	text: String,
	size: int,
	color: Color,
) -> void:
	var width := _font.get_string_size(
		text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size).x
	_draw_text(center - Vector2(width * 0.5, 0.0), text, size, color)


func _format_tuning_value(parameter: StringName, value: float) -> String:
	var descriptor := TuningCatalog.descriptor(parameter)
	var format := StringName(descriptor.get("format", &"decimal"))
	match format:
		&"toggle":
			return "ON" if value >= 0.5 else "OFF"
		&"percent":
			return "%.0f%%" % (value * 100.0)
		&"seconds":
			return "%.2f s" % value
		&"pixels":
			return "%.0f px" % value
		&"speed":
			return "%.0f px/s" % value
		&"meters":
			return "%.0f m" % (value / 10.0)
		&"debug_level":
			return "OWNED" if value < 0.0 else "LEVEL %d" % roundi(value)
		&"number":
			return "%.0f" % value
	return "%.3f" % value


func _quick_value_label(parameter: StringName, value: float) -> String:
	var descriptor := TuningCatalog.descriptor(parameter)
	var format := StringName(descriptor.get("format", &"decimal"))
	match format:
		&"toggle":
			return "ON" if value >= 0.5 else "OFF"
		&"percent":
			return "%.0f%%" % (value * 100.0)
		&"seconds":
			return "%.1fs" % value
		&"pixels":
			return "%.0f" % value
		&"speed":
			return "%.0f" % value
		&"meters":
			return "%.0fm" % (value / 10.0)
		&"debug_level":
			if value < 0.0:
				return "OWNED"
			if roundi(value) == SpiderCatalog.MAX_UPGRADE_LEVEL:
				return "MAX"
			return "L%d" % roundi(value)
		&"number":
			return "%.0f" % value
	return "%.2f" % value


func _run_access_status() -> String:
	var level := _snapshot.debug_upgrade_overlay_level
	if _snapshot.debug_start_active:
		return (
			"DEBUG START %.0f m · UPGRADES L%d · AWARDS NOTHING" % [
				_snapshot.start_distance_pixels / 10.0,
				level,
			]
			if level >= 0
			else "DEBUG START %.0f m · AWARDS NOTHING" % (
				_snapshot.start_distance_pixels / 10.0)
		)
	if level >= 0:
		return "DEBUG UPGRADES L%d · AWARDS NOTHING" % level
	return "PRACTICE · NO FLIES OR RECORDS"


func _preset_label(name: StringName) -> String:
	match name:
		SwingConfig.PRESET_WEIGHTY:
			return "WEIGHTY"
		SwingConfig.PRESET_AGILE:
			return "AGILE"
		_:
			return "BALANCED"


func _polygon_to_screen(polygon: PackedVector2Array) -> PackedVector2Array:
	var converted := PackedVector2Array()
	for point: Vector2 in polygon:
		converted.append(_world_to_screen(point))
	return converted


func _draw_environment_polygon(
	world_polygon: PackedVector2Array,
	screen_polygon: PackedVector2Array,
	tint: Color,
	graybox_fill: Color,
) -> void:
	var texture := _environment_textures.get(
		_environment_theme_index,
	) as Texture2D
	if texture == null:
		draw_colored_polygon(screen_polygon, graybox_fill)
		return
	var uvs := PackedVector2Array()
	for point: Vector2 in world_polygon:
		# Repeated CanvasItem UVs use 0–1 texture space. Mapping them from world
		# coordinates keeps the material fixed while the camera scrolls and
		# makes adjacent course polygons share the same visual surface.
		uvs.append(point / ENVIRONMENT_TEXTURE_WORLD_SIZE)
	draw_colored_polygon(screen_polygon, tint, uvs, texture)


func _load_environment_textures() -> void:
	_environment_textures.clear()
	for index in range(EnvironmentThemeCatalog.count()):
		var definition := EnvironmentThemeCatalog.theme(index)
		var path := str(definition["texture_path"])
		if path.is_empty() or not ResourceLoader.exists(path):
			continue
		var texture := load(path) as Texture2D
		if texture != null:
			_environment_textures[index] = texture


func _load_art_textures() -> void:
	_art_textures.clear()
	for asset_id: StringName in ArtAssetCatalog.ASSETS:
		var path := ArtAssetCatalog.texture_path(asset_id)
		if path.is_empty() or not ResourceLoader.exists(path):
			continue
		var texture := load(path) as Texture2D
		if texture != null:
			_art_textures[asset_id] = texture


func _art_texture(asset_id: StringName) -> Texture2D:
	return _art_textures.get(asset_id) as Texture2D


func _uses_forest_art() -> bool:
	if not _uses_curated_zone_art() or _snapshot == null:
		return false
	return _snapshot.region_visual_profile in [
		CourseRegionCatalog.VISUAL_OLD_GROWTH,
		CourseRegionCatalog.VISUAL_CANOPY,
	]


func _uses_curated_zone_art() -> bool:
	return StringName(_environment_theme()["id"]) == \
		EnvironmentThemeCatalog.ANCIENT_FOREST


func _visual_profile_for_world_polygon(
	world_polygon: PackedVector2Array,
) -> StringName:
	var world_x := _polygon_bounds(world_polygon).get_center().x
	var distance := maxf(0.0, world_x - CourseStream.START_X)
	return StringName(
		CourseRegionCatalog.region_for_distance(distance)["visual_profile"],
	)


func _environment_theme() -> Dictionary:
	return EnvironmentThemeCatalog.theme(_environment_theme_index)


func _polygon_bounds(polygon: PackedVector2Array) -> Rect2:
	if polygon.is_empty():
		return Rect2()
	var minimum := polygon[0]
	var maximum := polygon[0]
	for point: Vector2 in polygon:
		minimum.x = minf(minimum.x, point.x)
		minimum.y = minf(minimum.y, point.y)
		maximum.x = maxf(maximum.x, point.x)
		maximum.y = maxf(maximum.y, point.y)
	return Rect2(minimum, maximum - minimum)


func _draw_closed_polyline(
	polygon: PackedVector2Array,
	color: Color,
	width: float,
) -> void:
	if polygon.size() < 2:
		return
	var closed := polygon.duplicate()
	closed.append(polygon[0])
	draw_polyline(closed, color, width, true)


func _render_spider_position(fraction_override: float = -1.0) -> Vector2:
	if _motion_tick < 0:
		return _current_spider_position
	return _previous_spider_position.lerp(
		_current_spider_position,
		_physics_interpolation_fraction(fraction_override),
	)


func _render_spider_velocity(fraction_override: float = -1.0) -> Vector2:
	if _motion_tick < 0:
		return _current_spider_velocity
	return _previous_spider_velocity.lerp(
		_current_spider_velocity,
		_physics_interpolation_fraction(fraction_override),
	)


func _render_bird_position(fraction_override: float = -1.0) -> Vector2:
	if _motion_tick < 0:
		return _current_bird_position
	return _previous_bird_position.lerp(
		_current_bird_position,
		_physics_interpolation_fraction(fraction_override),
	)


func _render_bird_velocity(fraction_override: float = -1.0) -> Vector2:
	if _motion_tick < 0:
		return _current_bird_velocity
	return _previous_bird_velocity.lerp(
		_current_bird_velocity,
		_physics_interpolation_fraction(fraction_override),
	)


func _physics_interpolation_fraction(fraction_override: float = -1.0) -> float:
	if fraction_override >= 0.0:
		return clampf(fraction_override, 0.0, 1.0)
	return clampf(Engine.get_physics_interpolation_fraction(), 0.0, 1.0)


func _render_spider_rotation(render_velocity: Vector2) -> float:
	if render_velocity.length_squared() < 1.0:
		return 0.0
	return clampf(render_velocity.angle() * 0.16, -0.35, 0.35)


func _spider_pose_scale(render_velocity: Vector2) -> Vector2:
	if _reduced_motion or _snapshot == null:
		return Vector2.ONE
	var target_speed := maxf(_snapshot.target_speed, 1.0)
	var speed_ratio := clampf(
		(render_velocity.length() - target_speed * 0.75) / target_speed,
		0.0,
		1.0,
	)
	var horizontal := 1.0 + speed_ratio * 0.01
	var vertical := 1.0 - speed_ratio * 0.007
	if _snapshot.pull_active or _burst_feedback_remaining > 0.0:
		horizontal += 0.025
		vertical -= 0.018
	elif _snapshot.reel_active:
		horizontal -= 0.012
		vertical += 0.02
	elif _snapshot.glide_remaining > 0.0:
		horizontal += 0.018
		vertical -= 0.01
	return Vector2(
		clampf(horizontal, 0.97, 1.045),
		clampf(vertical, 0.97, 1.035),
	)


func _pose_local(local_position: Vector2, pose_scale: Vector2) -> Vector2:
	return Vector2(
		local_position.x * pose_scale.x,
		local_position.y * pose_scale.y,
	)


func _world_to_screen(world_position: Vector2) -> Vector2:
	return world_position - Vector2(_camera_x, 0.0)


func _web_color() -> Color:
	match _snapshot.web_variant:
		PlayerProgress.WEB_DEW:
			return Color("73e0a4")
		PlayerProgress.WEB_EMBER:
			return Color("ffd166")
		_:
			return WEB
