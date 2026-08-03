extends Control
class_name TutorialPreview
## Deterministic, presentation-owned snapshots of the live game vocabulary.
##
## This control deliberately owns no SwingLabSession, SimulationWorld, course
## stream, input command, settlement, progression service, or save repository.
## It stages poses with production assets and semantic cues; authoritative
## geometry and mechanics remain in their existing owners.

const INK := SpiderUiTheme.INK
const SILK := SpiderUiTheme.SILK
const CYAN := SpiderUiTheme.DEW
const GREEN := SpiderUiTheme.MOSS
const YELLOW := SpiderUiTheme.AMBER
const RED := Color("ff6577")
const MUTED := SpiderUiTheme.MUTED

const COMMON_ASSETS: Array[StringName] = [
	ArtAssetCatalog.CANOPY_BACKDROP_FAR,
	ArtAssetCatalog.CANOPY_BACKDROP_MID,
	ArtAssetCatalog.CANOPY_RAIL_TILE,
	ArtAssetCatalog.PURSUING_BIRD_GLIDE,
]

const LESSON_ASSETS := {
	&"opening_pressure": [ArtAssetCatalog.CANOPY_HOOK_VINE],
	&"attach": [ArtAssetCatalog.CANOPY_HOOK_VINE],
	&"swing_release": [ArtAssetCatalog.CANOPY_HOOK_VINE],
	&"reel": [ArtAssetCatalog.CANOPY_HOOK_VINE],
	&"anchor_burst": [ArtAssetCatalog.CANOPY_HOOK_VINE],
	&"dive_recovery": [ArtAssetCatalog.CANOPY_LEAF_SHUTTER],
	&"read_course": [
		ArtAssetCatalog.CANOPY_HOOK_VINE,
		ArtAssetCatalog.CANOPY_LEAF_SHUTTER,
		ArtAssetCatalog.GOLDEN_FLY,
	],
	&"survive_restart": [ArtAssetCatalog.CANOPY_BRAMBLE],
}

var lesson: Dictionary = FrontEndState.TUTORIAL_STEPS[0]
var reduced_motion: bool = false
var spider_id: StringName = SpiderCatalog.CLASSIC
var spider_style: StringName = PlayerProgress.STYLE_GARDEN
var web_variant: StringName = PlayerProgress.WEB_CLASSIC
var _elapsed := 0.0
var _textures: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)
	queue_redraw()


func configure(
	next_lesson: Dictionary,
	motion_reduced: bool,
	selected_spider_id: StringName,
	selected_spider_style: StringName,
	selected_web_variant: StringName,
) -> void:
	lesson = next_lesson.duplicate(true)
	reduced_motion = motion_reduced
	spider_id = selected_spider_id \
		if selected_spider_id in SpiderCatalog.ALL_IDS else SpiderCatalog.CLASSIC
	spider_style = selected_spider_style
	web_variant = selected_web_variant
	_elapsed = 0.0
	queue_redraw()


func _process(delta: float) -> void:
	if not reduced_motion:
		_elapsed += delta
		queue_redraw()


## A testable render contract. Missing imports are explicit fallbacks rather
## than permission for the old grid/rectangle/spider diagram to return.
func preview_contract() -> Dictionary:
	var requested := required_asset_ids(
		StringName(lesson.get("preview", &"")), spider_id)
	var resolved := PackedStringArray()
	var fallbacks := PackedStringArray()
	for asset_id: StringName in requested:
		var path := ArtAssetCatalog.texture_path(asset_id)
		if not path.is_empty() and ResourceLoader.exists(path):
			resolved.append(path)
		else:
			fallbacks.append(str(asset_id))
	return {
		"lesson_id": StringName(lesson.get("id", &"")),
		"preview_id": StringName(lesson.get("preview", &"")),
		"spider_id": spider_id,
		"spider_asset": ArtAssetCatalog.spider_asset_id(spider_id),
		"web_variant": web_variant,
		"requested_assets": requested,
		"resolved_assets": resolved,
		"fallback_assets": fallbacks,
		"reduced_motion": reduced_motion,
		"motion_phase": _motion_phase(),
		"presentation_only": true,
		"primitive_only": false,
	}


static func required_asset_ids(
	preview_id: StringName,
	selected_spider_id: StringName,
) -> Array[StringName]:
	var result: Array[StringName] = COMMON_ASSETS.duplicate()
	var selected := ArtAssetCatalog.spider_asset_id(selected_spider_id)
	if selected != &"":
		result.append(selected)
	for asset_id: StringName in LESSON_ASSETS.get(preview_id, []):
		if asset_id not in result:
			result.append(asset_id)
	return result


func _motion_phase() -> float:
	return 0.42 if reduced_motion else fposmod(_elapsed * 0.28, 1.0)


func _draw() -> void:
	var area := Rect2(Vector2.ZERO, size)
	draw_style_box(SpiderUiTheme.panel_style(SpiderUiTheme.PANEL, 22), area)
	if area.size.x < 32.0 or area.size.y < 32.0:
		return
	_draw_bramble_canopy(area)
	var preview_id := StringName(lesson.get("preview", &"opening_pressure"))
	match preview_id:
		&"attach":
			_draw_attach(area)
		&"swing_release":
			_draw_swing_release(area)
		&"reel":
			_draw_reel(area)
		&"anchor_burst":
			_draw_anchor_burst(area)
		&"dive_recovery":
			_draw_dive_recovery(area)
		&"read_course":
			_draw_read_course(area)
		&"survive_restart":
			_draw_survive_restart(area)
		_:
			_draw_opening_pressure(area)
	_draw_common_hud(area)


func _draw_bramble_canopy(area: Rect2) -> void:
	var far := _texture(ArtAssetCatalog.CANOPY_BACKDROP_FAR)
	var mid := _texture(ArtAssetCatalog.CANOPY_BACKDROP_MID)
	if far != null:
		draw_texture_rect(far, area.grow(-3.0), false, Color(1.0, 1.0, 1.0, 0.72))
	else:
		draw_rect(area.grow(-3.0), Color("101c18"))
	if mid != null:
		var drift := 0.0 if reduced_motion else sin(_elapsed * 0.18) * 5.0
		draw_texture_rect(
			mid,
			Rect2(Vector2(drift, 0.0), area.size),
			false,
			Color(1.0, 1.0, 1.0, 0.34),
		)
	var rail := _texture(ArtAssetCatalog.CANOPY_RAIL_TILE)
	var rail_height := maxf(24.0, area.size.y * 0.12)
	if rail != null:
		draw_texture_rect(rail, Rect2(0.0, 0.0, area.size.x, rail_height), false)
		draw_set_transform(Vector2(0.0, area.size.y), 0.0, Vector2(1.0, -1.0))
		draw_texture_rect(rail, Rect2(0.0, 0.0, area.size.x, rail_height), false)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		draw_line(Vector2.ZERO, Vector2(area.size.x, 0.0), RED, 5.0)
		draw_line(
			Vector2(0.0, area.size.y), area.size, RED, 5.0)


func _draw_opening_pressure(area: Rect2) -> void:
	var phase := _motion_phase()
	var anchor := Vector2(area.size.x * 0.46, area.size.y * 0.18)
	var spider := Vector2(
		lerpf(area.size.x * 0.38, area.size.x * 0.62, phase),
		area.size.y * (0.62 - sin(phase * PI) * 0.14),
	)
	_draw_web(anchor, spider, 4.0)
	_draw_target(anchor, true)
	_draw_spider(spider, -0.12)
	_draw_bird(Vector2(area.size.x * 0.18, area.size.y * 0.56), 0.12)
	_draw_obstacle(
		ArtAssetCatalog.CANOPY_HOOK_VINE,
		Rect2(area.size.x * 0.72, area.size.y * 0.08, 92.0, area.size.y * 0.48),
	)
	_draw_route_arrow(
		Vector2(area.size.x * 0.56, area.size.y * 0.57),
		Vector2(area.size.x * 0.82, area.size.y * 0.42),
		GREEN,
	)
	_draw_badge("NO FREE DRIVE", Vector2(area.size.x * 0.50, area.size.y * 0.80), YELLOW)


func _draw_attach(area: Rect2) -> void:
	var spider := Vector2(area.size.x * 0.30, area.size.y * 0.68)
	var target := Vector2(area.size.x * 0.70, area.size.y * 0.22)
	_draw_obstacle(
		ArtAssetCatalog.CANOPY_HOOK_VINE,
		Rect2(area.size.x * 0.64, area.size.y * 0.05, 108.0, area.size.y * 0.43),
	)
	_draw_spider(spider)
	_draw_web(spider, spider.lerp(target, 0.72 if reduced_motion else _motion_phase()), 3.0)
	_draw_target(target, true)
	_draw_target(Vector2(area.size.x * 0.47, area.size.y * 0.13), false)
	_draw_badge("SOLID + IN RANGE", Vector2(area.size.x * 0.63, area.size.y * 0.67), GREEN)
	_draw_badge("GUIDE ≠ SURFACE", Vector2(area.size.x * 0.33, area.size.y * 0.30), CYAN)


func _draw_swing_release(area: Rect2) -> void:
	var phase := _motion_phase()
	var anchor := Vector2(area.size.x * 0.45, area.size.y * 0.19)
	var angle := lerpf(2.15, 0.62, phase)
	var rope := minf(area.size.x, area.size.y) * 0.34
	var spider := anchor + Vector2(cos(angle), sin(angle)) * rope
	if phase < 0.72 or reduced_motion:
		_draw_web(anchor, spider, 4.0)
	_draw_target(anchor, true)
	_draw_spider(spider, -0.25)
	for index in range(7):
		var progress := float(index) / 6.0
		var point := spider + Vector2(160.0 * progress, -78.0 * progress + 58.0 * progress * progress)
		draw_circle(point, 4.0, Color(GREEN, 0.42 + progress * 0.58))
	_draw_route_arrow(
		Vector2(area.size.x * 0.55, area.size.y * 0.50),
		Vector2(area.size.x * 0.82, area.size.y * 0.37),
		GREEN,
	)
	_draw_badge("RISING RELEASE", Vector2(area.size.x * 0.68, area.size.y * 0.73), GREEN)


func _draw_reel(area: Rect2) -> void:
	var pulse := 0.46 if reduced_motion else (sin(_elapsed * 2.4) + 1.0) * 0.5
	var anchor := Vector2(area.size.x * 0.48, area.size.y * 0.18)
	var length := lerpf(area.size.y * 0.53, area.size.y * 0.32, pulse)
	var spider := anchor + Vector2(-length * 0.26, length)
	_draw_web(anchor, spider, 5.0, YELLOW)
	_draw_target(anchor, true)
	_draw_spider(spider)
	_draw_action_button(
		Vector2(area.size.x * 0.82, area.size.y * 0.70),
		"REEL",
		CYAN,
		1.0 - pulse * 0.62,
	)
	_draw_badge("SHORTER RADIUS", Vector2(area.size.x * 0.49, area.size.y * 0.69), YELLOW)


func _draw_anchor_burst(area: Rect2) -> void:
	var start := Vector2(area.size.x * 0.28, area.size.y * 0.68)
	var target := Vector2(area.size.x * 0.72, area.size.y * 0.24)
	var travel := 0.40 if reduced_motion else minf(_motion_phase() * 0.64, 0.40)
	var spider := start.lerp(target, travel)
	_draw_obstacle(
		ArtAssetCatalog.CANOPY_HOOK_VINE,
		Rect2(area.size.x * 0.67, area.size.y * 0.04, 104.0, area.size.y * 0.44),
	)
	draw_line(start, target, Color(SILK, 0.34), 2.0, true)
	_draw_burst_trail(start, spider)
	_draw_target(target, true)
	_draw_spider(spider, -0.35)
	_draw_action_button(
		Vector2(area.size.x * 0.84, area.size.y * 0.72), "BURST", YELLOW, 0.68)
	_draw_badge("AIMED 40%", Vector2(area.size.x * 0.53, area.size.y * 0.73), YELLOW)


func _draw_dive_recovery(area: Rect2) -> void:
	var start := Vector2(area.size.x * 0.32, area.size.y * 0.34)
	var lower := Vector2(area.size.x * 0.64, area.size.y * 0.79)
	var upper := Vector2(area.size.x * 0.74, area.size.y * 0.17)
	var spider := start.lerp(lower, 0.40)
	_draw_obstacle(
		ArtAssetCatalog.CANOPY_LEAF_SHUTTER,
		Rect2(area.size.x * 0.54, area.size.y * 0.65, 120.0, area.size.y * 0.26),
	)
	_draw_burst_trail(start, spider)
	draw_line(spider, upper, _web_color(), 4.0, true)
	_draw_target(lower, true)
	_draw_target(upper, true)
	_draw_spider(spider, 0.34)
	_draw_badge("DIVE SPENT", Vector2(area.size.x * 0.34, area.size.y * 0.72), YELLOW)
	_draw_badge("UPPER WEB REARMS", Vector2(area.size.x * 0.67, area.size.y * 0.46), GREEN)


func _draw_read_course(area: Rect2) -> void:
	_draw_obstacle(
		ArtAssetCatalog.CANOPY_HOOK_VINE,
		Rect2(area.size.x * 0.40, area.size.y * 0.05, 106.0, area.size.y * 0.43),
	)
	_draw_obstacle(
		ArtAssetCatalog.CANOPY_LEAF_SHUTTER,
		Rect2(area.size.x * 0.68, area.size.y * 0.60, 120.0, area.size.y * 0.29),
	)
	var spider := Vector2(area.size.x * 0.22, area.size.y * 0.63)
	_draw_spider(spider)
	_draw_route_arrow(spider + Vector2(45.0, -12.0), Vector2(area.size.x * 0.80, area.size.y * 0.43), GREEN)
	_draw_asset(
		ArtAssetCatalog.GOLDEN_FLY,
		Rect2(area.size.x * 0.57, area.size.y * 0.42, 56.0, 38.0),
	)
	_draw_badge("BURST FRENZY", Vector2(area.size.x * 0.72, area.size.y * 0.18), CYAN)
	_draw_badge("BRAMBLE CANOPY", Vector2(area.size.x * 0.28, area.size.y * 0.82), INK)


func _draw_survive_restart(area: Rect2) -> void:
	var spider := Vector2(area.size.x * 0.48, area.size.y * 0.68)
	_draw_obstacle(
		ArtAssetCatalog.CANOPY_BRAMBLE,
		Rect2(area.size.x * 0.62, area.size.y * 0.58, 134.0, area.size.y * 0.31),
	)
	_draw_spider(spider)
	draw_circle(spider, 43.0, Color(GREEN, 0.10))
	draw_arc(spider, 43.0, 0.0, TAU, 48, GREEN, 5.0, true)
	_draw_bird(Vector2(area.size.x * 0.23, area.size.y * 0.56), 0.08)
	_draw_badge("RESCUE READY", Vector2(area.size.x * 0.48, area.size.y * 0.38), GREEN)
	_draw_badge("RAIL · OBSTACLE · BIRD", Vector2(area.size.x * 0.67, area.size.y * 0.82), RED)
	_draw_cocoon_button(
		Rect2(area.size.x * 0.68, area.size.y * 0.22, 112.0, 42.0), "RESTART", GREEN)


func _draw_common_hud(area: Rect2) -> void:
	_draw_cocoon_button(Rect2(16.0, 14.0, 82.0, 40.0), "MENU", CYAN)
	_draw_text(Vector2(114.0, 38.0), "000.0 m", 18, SILK)
	_draw_text(Vector2(114.0, 57.0), "BRAMBLE CANOPY", 11, CYAN)
	_draw_text(Vector2(area.size.x - 178.0, 35.0), "RESCUE READY", 13, GREEN)


func _draw_spider(position: Vector2, rotation: float = 0.0) -> void:
	var asset := ArtAssetCatalog.spider_asset_id(spider_id)
	var texture := _texture(asset)
	if texture == null:
		draw_circle(position, 20.0, Color("3a2721"))
		_draw_text(position + Vector2(-28.0, 5.0), "SPIDER", 10, INK)
		return
	draw_set_transform(position, rotation, Vector2.ONE)
	draw_texture_rect(
		texture,
		Rect2(Vector2(-48.0, -23.0), Vector2(96.0, 46.0)),
		false,
		ArtAssetCatalog.spider_style_tint(spider_style),
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_bird(position: Vector2, rotation: float = 0.0) -> void:
	var texture := _texture(ArtAssetCatalog.PURSUING_BIRD_GLIDE)
	if texture == null:
		draw_colored_polygon(PackedVector2Array([
			position + Vector2(-40.0, 4.0), position + Vector2(-12.0, -22.0),
			position + Vector2(14.0, -6.0), position + Vector2(42.0, 2.0),
			position + Vector2(12.0, 18.0),
		]), Color("592c24"))
		return
	draw_set_transform(position, rotation, Vector2.ONE)
	draw_texture_rect(
		texture, Rect2(Vector2(-44.0, -44.0), Vector2(88.0, 88.0)), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_obstacle(asset_id: StringName, rect: Rect2) -> void:
	if not _draw_asset(asset_id, rect):
		draw_rect(rect, Color(SpiderUiTheme.BARK, 0.92))
		draw_rect(rect, RED, false, 3.0)


func _draw_asset(asset_id: StringName, rect: Rect2) -> bool:
	var texture := _texture(asset_id)
	if texture == null:
		return false
	draw_texture_rect(texture, rect, false)
	return true


func _draw_web(
	from: Vector2,
	to: Vector2,
	width: float = 4.0,
	color: Color = Color.TRANSPARENT,
) -> void:
	var strand := _web_color() if color == Color.TRANSPARENT else color
	draw_line(from, to, Color(strand, 0.34), width + 4.0, true)
	draw_line(from, to, strand, width, true)


func _draw_burst_trail(from: Vector2, to: Vector2) -> void:
	var direction := (to - from).normalized()
	draw_line(from, to, Color(YELLOW, 0.48), 9.0, true)
	for index in range(4):
		var point := to - direction * (24.0 + float(index) * 18.0)
		draw_line(point, point + direction * 11.0, Color(YELLOW, 0.92 - index * 0.16), 4.0, true)


func _draw_target(position: Vector2, legal: bool) -> void:
	var color := GREEN if legal else CYAN
	var pulse := 0.0 if reduced_motion else sin(_elapsed * 3.6) * 3.0
	draw_circle(position, 16.0 + pulse, Color(color, 0.16))
	draw_arc(position, 9.0, 0.0, TAU, 24, color, 3.0, true)
	draw_circle(position, 3.0, INK)


func _draw_route_arrow(from: Vector2, to: Vector2, color: Color) -> void:
	draw_line(from, to, Color(color, 0.72), 4.0, true)
	var direction := (to - from).normalized()
	var normal := direction.orthogonal()
	draw_colored_polygon(PackedVector2Array([
		to, to - direction * 18.0 + normal * 10.0,
		to - direction * 18.0 - normal * 10.0,
	]), color)


func _draw_action_button(
	center: Vector2,
	label: String,
	accent: Color,
	ratio: float,
) -> void:
	var radius := 38.0
	draw_circle(center, radius, Color(SpiderUiTheme.PANEL, 0.94))
	draw_arc(center, radius, 0.0, TAU, 48, Color(MUTED, 0.55), 4.0, true)
	draw_arc(
		center, radius, -PI * 0.5, -PI * 0.5 + TAU * clampf(ratio, 0.0, 1.0),
		48, accent, 7.0, true)
	_draw_centered(label, center + Vector2(0.0, 6.0), 14, INK)


func _draw_badge(text: String, center: Vector2, accent: Color) -> void:
	var font_size := 12
	var width := ThemeDB.fallback_font.get_string_size(
		text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + 20.0
	var rect := Rect2(center - Vector2(width * 0.5, 14.0), Vector2(width, 28.0))
	draw_style_box(SpiderUiTheme.badge_style(accent), rect)
	_draw_centered(text, center + Vector2(0.0, 4.0), font_size, accent)


func _draw_cocoon_button(rect: Rect2, text: String, accent: Color) -> void:
	draw_style_box(SpiderUiTheme.button_style(
		Color(SpiderUiTheme.PANEL_SOFT, 0.94), accent), rect)
	_draw_centered(text, rect.get_center() + Vector2(0.0, 5.0), 12, INK)


func _draw_text(position: Vector2, text: String, font_size: int, color: Color) -> void:
	draw_string(
		ThemeDB.fallback_font, position, text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _draw_centered(
	text: String,
	position: Vector2,
	font_size: int,
	color: Color,
) -> void:
	var width := ThemeDB.fallback_font.get_string_size(
		text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	_draw_text(position - Vector2(width * 0.5, 0.0), text, font_size, color)


func _texture(asset_id: StringName) -> Texture2D:
	if asset_id == &"":
		return null
	if _textures.has(asset_id):
		return _textures[asset_id] as Texture2D
	var path := ArtAssetCatalog.texture_path(asset_id)
	var texture := load(path) as Texture2D \
		if not path.is_empty() and ResourceLoader.exists(path) else null
	_textures[asset_id] = texture
	return texture


func _web_color() -> Color:
	match web_variant:
		PlayerProgress.WEB_DEW:
			return GREEN
		PlayerProgress.WEB_EMBER:
			return YELLOW
		_:
			return SILK
