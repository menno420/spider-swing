extends RefCounted
class_name CourseGeometry
## Immutable-at-consumption world geometry crossing application -> simulation.
##
## The course stream owns which chunks are retained. Simulation receives only
## the compact collision/attachment geometry needed for the current fixed step.

var surfaces: Array[PackedVector2Array] = []
const ANCHOR_FIXED := &"fixed"
const ANCHOR_MOVING_PIVOT := &"moving_pivot"
const ANCHOR_HIGHWAY := &"silk_highway"
const ANCHOR_STICKY := &"sticky_silk"
const ANCHOR_ROTTEN := &"rotten_once"
const ANCHOR_COLLAPSING := &"collapsing_span"

## Metadata parallel to `surfaces`. Legacy/manual surfaces default to an
## ordinary fixed anchor when an index has no entry.
var surface_ids: Array[StringName] = []
var surface_anchor_classes: Array[StringName] = []
var surface_visual_ids: Array[StringName] = []
var surface_motion_specs: Array[Dictionary] = []
## Harmless authored shapes that share the deterministic phase model without
## entering targeting or collision. Ruined Arboretum's drip chains live here.
var decorations: Array[PackedVector2Array] = []
var decoration_ids: Array[StringName] = []
var decoration_visual_ids: Array[StringName] = []
var decoration_motion_specs: Array[Dictionary] = []
var boundary_surfaces: Array[PackedVector2Array] = []
var aim_guides: PackedVector2Array = PackedVector2Array()
var obstacles: Array[PackedVector2Array] = []
## Per-obstacle web-anchor eligibility, parallel to `obstacles`.
##
## Ceiling-grown hazards stay tappable; floor-grown ones do not. The rule is
## about unintended input, not reachability: a release tap and a web tap are
## aimed at the same area, so a floor-grown hazard sitting just below the
## spider turned release taps into Dive Pulls. Collision is untouched — every
## obstacle stays lethal, floor-grown ones simply stop answering taps.
##
## An index past the end reads as anchorable, so geometry assembled without
## calling `append_obstacle` keeps the original behaviour.
var obstacle_anchorable: PackedByteArray = PackedByteArray()
## Presentation-only semantic kind, parallel to `obstacles`.
##
## The kind never changes collision, lethality, or anchor eligibility. Legacy
## geometry without a kind returns `UNSPECIFIED` and keeps the renderer's
## conservative fallback.
var obstacle_kinds: Array[StringName] = []
var obstacle_ids: Array[StringName] = []
var obstacle_anchor_classes: Array[StringName] = []
var obstacle_visual_ids: Array[StringName] = []
var obstacle_motion_specs: Array[Dictionary] = []
var fly_positions: PackedVector2Array = PackedVector2Array()
var boost_positions: PackedVector2Array = PackedVector2Array()
var first_chunk_index: int = 0
var last_chunk_index: int = 0
var course_seed: int = 0


## Append one obstacle together with its anchor eligibility.
##
## Use this rather than `obstacles.append` so the two arrays cannot drift.
func append_obstacle(
	polygon: PackedVector2Array,
	anchorable: bool = true,
	kind: StringName = CourseObstacleCatalog.UNSPECIFIED,
	content_id: StringName = &"",
	visual_id: StringName = &"",
	motion_spec: Dictionary = {},
	anchor_class: StringName = ANCHOR_FIXED,
) -> void:
	while obstacle_anchorable.size() < obstacles.size():
		obstacle_anchorable.append(1)
	while obstacle_kinds.size() < obstacles.size():
		obstacle_kinds.append(CourseObstacleCatalog.UNSPECIFIED)
	while obstacle_ids.size() < obstacles.size():
		obstacle_ids.append(&"")
	while obstacle_visual_ids.size() < obstacles.size():
		obstacle_visual_ids.append(&"")
	while obstacle_motion_specs.size() < obstacles.size():
		obstacle_motion_specs.append({})
	while obstacle_anchor_classes.size() < obstacles.size():
		obstacle_anchor_classes.append(ANCHOR_FIXED)
	obstacles.append(polygon)
	obstacle_anchorable.append(1 if anchorable else 0)
	obstacle_kinds.append(kind)
	obstacle_ids.append(content_id)
	obstacle_visual_ids.append(visual_id)
	obstacle_motion_specs.append(motion_spec.duplicate(true))
	obstacle_anchor_classes.append(anchor_class)


## Append a safe web-compatible surface together with its semantic anchor
## class. Highways and pivot sockets belong here, never in lethal obstacles.
func append_anchor_surface(
	polygon: PackedVector2Array,
	anchor_class: StringName = ANCHOR_FIXED,
	content_id: StringName = &"",
	visual_id: StringName = &"",
	motion_spec: Dictionary = {},
) -> void:
	surfaces.append(polygon)
	surface_ids.append(content_id)
	surface_anchor_classes.append(anchor_class)
	surface_visual_ids.append(visual_id)
	surface_motion_specs.append(motion_spec.duplicate(true))


func append_decoration(
	polygon: PackedVector2Array,
	content_id: StringName = &"",
	visual_id: StringName = &"",
	motion_spec: Dictionary = {},
) -> void:
	decorations.append(polygon)
	decoration_ids.append(content_id)
	decoration_visual_ids.append(visual_id)
	decoration_motion_specs.append(motion_spec.duplicate(true))


func is_obstacle_anchorable(index: int) -> bool:
	if index < 0 or index >= obstacle_anchorable.size():
		return true
	return obstacle_anchorable[index] != 0


func obstacle_kind(index: int) -> StringName:
	if index < 0 or index >= obstacle_kinds.size():
		return CourseObstacleCatalog.UNSPECIFIED
	return obstacle_kinds[index]


func obstacle_id(index: int) -> StringName:
	return obstacle_ids[index] if index >= 0 and index < obstacle_ids.size() \
		else &""


func obstacle_anchor_class(index: int) -> StringName:
	return obstacle_anchor_classes[index] \
		if index >= 0 and index < obstacle_anchor_classes.size() \
		else ANCHOR_FIXED


func obstacle_visual_id(index: int) -> StringName:
	return obstacle_visual_ids[index] \
		if index >= 0 and index < obstacle_visual_ids.size() else &""


func obstacle_motion_spec(index: int) -> Dictionary:
	return obstacle_motion_specs[index].duplicate(true) \
		if index >= 0 and index < obstacle_motion_specs.size() else {}


func surface_id(index: int) -> StringName:
	return surface_ids[index] if index >= 0 and index < surface_ids.size() \
		else &""


func surface_anchor_class(index: int) -> StringName:
	return surface_anchor_classes[index] \
		if index >= 0 and index < surface_anchor_classes.size() \
		else ANCHOR_FIXED


func surface_visual_id(index: int) -> StringName:
	return surface_visual_ids[index] \
		if index >= 0 and index < surface_visual_ids.size() else &""


func surface_motion_spec(index: int) -> Dictionary:
	return surface_motion_specs[index].duplicate(true) \
		if index >= 0 and index < surface_motion_specs.size() else {}


func decoration_id(index: int) -> StringName:
	return decoration_ids[index] \
		if index >= 0 and index < decoration_ids.size() else &""


func decoration_visual_id(index: int) -> StringName:
	return decoration_visual_ids[index] \
		if index >= 0 and index < decoration_visual_ids.size() else &""


func decoration_motion_spec(index: int) -> Dictionary:
	return decoration_motion_specs[index].duplicate(true) \
		if index >= 0 and index < decoration_motion_specs.size() else {}


func duplicate_geometry() -> CourseGeometry:
	var copy := CourseGeometry.new()
	for surface: PackedVector2Array in surfaces:
		copy.surfaces.append(surface.duplicate())
	copy.surface_ids = surface_ids.duplicate()
	copy.surface_anchor_classes = surface_anchor_classes.duplicate()
	copy.surface_visual_ids = surface_visual_ids.duplicate()
	copy.surface_motion_specs = surface_motion_specs.duplicate(true)
	for decoration: PackedVector2Array in decorations:
		copy.decorations.append(decoration.duplicate())
	copy.decoration_ids = decoration_ids.duplicate()
	copy.decoration_visual_ids = decoration_visual_ids.duplicate()
	copy.decoration_motion_specs = decoration_motion_specs.duplicate(true)
	for surface: PackedVector2Array in boundary_surfaces:
		copy.boundary_surfaces.append(surface.duplicate())
	copy.aim_guides = aim_guides.duplicate()
	for obstacle: PackedVector2Array in obstacles:
		copy.obstacles.append(obstacle.duplicate())
	copy.obstacle_anchorable = obstacle_anchorable.duplicate()
	copy.obstacle_kinds = obstacle_kinds.duplicate()
	copy.obstacle_ids = obstacle_ids.duplicate()
	copy.obstacle_anchor_classes = obstacle_anchor_classes.duplicate()
	copy.obstacle_visual_ids = obstacle_visual_ids.duplicate()
	copy.obstacle_motion_specs = obstacle_motion_specs.duplicate(true)
	copy.fly_positions = fly_positions.duplicate()
	copy.boost_positions = boost_positions.duplicate()
	copy.first_chunk_index = first_chunk_index
	copy.last_chunk_index = last_chunk_index
	copy.course_seed = course_seed
	return copy
