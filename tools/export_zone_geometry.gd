extends SceneTree
## Exports representative deterministic course silhouettes for visual QA.
##
## Usage:
##   godot --headless --path . --script res://tools/export_zone_geometry.gd \
##     -- --out=/tmp/spider-zone-geometry.json

const VIEW_SIZE := Vector2(1280.0, 720.0)
const CAMERA_LEFT_OFFSET := VIEW_SIZE.x / 3.0
const COURSE_SEED := 1337
const SAMPLE_TICK := 137
const SAMPLE_DISTANCES_METRES := [
	2500.0, 6000.0, 12500.0, 15100.0,
	23750.0, 28750.0, 33750.0, 37500.0,
]


func _initialize() -> void:
	var output_path := "/tmp/spider-zone-geometry.json"
	var sample_distances := SAMPLE_DISTANCES_METRES.duplicate()
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--out="):
			output_path = argument.trim_prefix("--out=")
		elif argument.begins_with("--bramble-metres="):
			sample_distances[1] = float(argument.trim_prefix(
				"--bramble-metres="))
		elif argument.begins_with("--silk-metres="):
			sample_distances[2] = float(argument.trim_prefix(
				"--silk-metres="))
		elif argument.begins_with("--arboretum-metres="):
			sample_distances[3] = float(argument.trim_prefix(
				"--arboretum-metres="))
	var zones: Array[Dictionary] = []
	for metres: float in sample_distances:
		zones.append(_capture_zone(metres))
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		printerr("[zone-geometry] could not open %s" % output_path)
		quit(1)
		return
	file.store_string(JSON.stringify({
		"course_seed": COURSE_SEED,
		"sample_tick": SAMPLE_TICK,
		"viewport": [VIEW_SIZE.x, VIEW_SIZE.y],
		"zones": zones,
	}, "  "))
	file.close()
	print("[zone-geometry] wrote %s" % output_path)
	quit(0)


func _capture_zone(metres: float) -> Dictionary:
	var distance_pixels := metres * CourseRegionCatalog.PIXELS_PER_METRE
	var spider_x := SimulationWorld.START_POSITION.x + distance_pixels
	var stream := CourseStream.new()
	stream.reset(
		10000.0, 0.94, 0.90, 1.12, [], true, 1.0, 1.0,
		20000.0, COURSE_SEED, spider_x)
	var geometry := stream.geometry()
	var world_left := maxf(0.0, spider_x - CAMERA_LEFT_OFFSET)
	var region := CourseRegionCatalog.region_for_distance(distance_pixels)
	var pattern_ids: Array = []
	for chunk_index in range(
		geometry.first_chunk_index, geometry.last_chunk_index + 1):
		pattern_ids.append(str(stream.pattern_id_for_chunk(chunk_index)))
	var boundaries: Array = []
	for polygon: PackedVector2Array in geometry.boundary_surfaces:
		if _visible(polygon, world_left):
			boundaries.append(_polygon_rows(polygon, world_left))
	var surfaces: Array = []
	var surface_anchor_classes: Array = []
	var surface_visual_ids: Array = []
	for index in range(geometry.surfaces.size()):
		var sample := CourseMotion.sample_polygon(
			geometry.surfaces[index], geometry.surface_motion_spec(index),
			SAMPLE_TICK, 1.0 / 60.0)
		var polygon: PackedVector2Array = sample["current"]
		if _visible(polygon, world_left):
			surfaces.append(_polygon_rows(polygon, world_left))
			surface_anchor_classes.append(str(
				geometry.surface_anchor_class(index)))
			surface_visual_ids.append(str(geometry.surface_visual_id(index)))
	var decorations: Array = []
	for index in range(geometry.decorations.size()):
		var sample := CourseMotion.sample_polygon(
			geometry.decorations[index], geometry.decoration_motion_spec(index),
			SAMPLE_TICK, 1.0 / 60.0)
		if not bool(sample["active"]):
			continue
		var polygon: PackedVector2Array = sample["current"]
		if _visible(polygon, world_left):
			decorations.append(_polygon_rows(polygon, world_left))
	var obstacles: Array = []
	var obstacle_anchorable: Array = []
	var obstacle_content_ids: Array = []
	var obstacle_visual_ids: Array = []
	for index in range(geometry.obstacles.size()):
		var sample := CourseMotion.sample_polygon(
			geometry.obstacles[index], geometry.obstacle_motion_spec(index),
			SAMPLE_TICK, 1.0 / 60.0)
		if not bool(sample["active"]):
			continue
		var polygon: PackedVector2Array = sample["current"]
		if _visible(polygon, world_left):
			obstacles.append(_polygon_rows(polygon, world_left))
			obstacle_anchorable.append(geometry.is_obstacle_anchorable(index))
			obstacle_content_ids.append(str(geometry.obstacle_id(index)))
			obstacle_visual_ids.append(str(geometry.obstacle_visual_id(index)))
	var flies: Array = []
	for fly: Vector2 in geometry.fly_positions:
		var screen := fly - Vector2(world_left, 0.0)
		if screen.x >= -20.0 and screen.x <= VIEW_SIZE.x + 20.0:
			flies.append([screen.x, screen.y])
	return {
		"id": str(region["id"]),
		"name": str(region["name"]),
		"metres": metres,
		"visual_profile": str(region["visual_profile"]),
		"pattern_ids": pattern_ids,
		"boundaries": boundaries,
		"surfaces": surfaces,
		"surface_anchor_classes": surface_anchor_classes,
		"surface_visual_ids": surface_visual_ids,
		"decorations": decorations,
		"obstacles": obstacles,
		"obstacle_anchorable": obstacle_anchorable,
		"obstacle_content_ids": obstacle_content_ids,
		"obstacle_visual_ids": obstacle_visual_ids,
		"flies": flies,
	}


func _visible(polygon: PackedVector2Array, world_left: float) -> bool:
	if polygon.is_empty():
		return false
	var bounds := SolidGeometry.bounds(polygon)
	return bounds.end.x >= world_left - 80.0 and \
		bounds.position.x <= world_left + VIEW_SIZE.x + 80.0


func _polygon_rows(
	polygon: PackedVector2Array,
	world_left: float,
) -> Array:
	var rows: Array = []
	for point: Vector2 in polygon:
		rows.append([point.x - world_left, point.y])
	return rows
