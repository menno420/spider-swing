extends RefCounted
class_name CourseGeometry
## Immutable-at-consumption world geometry crossing application -> simulation.
##
## The course stream owns which chunks are retained. Simulation receives only
## the compact collision/attachment geometry needed for the current fixed step.

var surfaces: Array[PackedVector2Array] = []
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
var fly_positions: PackedVector2Array = PackedVector2Array()
var boost_positions: PackedVector2Array = PackedVector2Array()
var first_chunk_index: int = 0
var last_chunk_index: int = 0


## Append one obstacle together with its anchor eligibility.
##
## Use this rather than `obstacles.append` so the two arrays cannot drift.
func append_obstacle(
	polygon: PackedVector2Array,
	anchorable: bool = true,
) -> void:
	while obstacle_anchorable.size() < obstacles.size():
		obstacle_anchorable.append(1)
	obstacles.append(polygon)
	obstacle_anchorable.append(1 if anchorable else 0)


func is_obstacle_anchorable(index: int) -> bool:
	if index < 0 or index >= obstacle_anchorable.size():
		return true
	return obstacle_anchorable[index] != 0


func duplicate_geometry() -> CourseGeometry:
	var copy := CourseGeometry.new()
	for surface: PackedVector2Array in surfaces:
		copy.surfaces.append(surface.duplicate())
	for surface: PackedVector2Array in boundary_surfaces:
		copy.boundary_surfaces.append(surface.duplicate())
	copy.aim_guides = aim_guides.duplicate()
	for obstacle: PackedVector2Array in obstacles:
		copy.obstacles.append(obstacle.duplicate())
	copy.obstacle_anchorable = obstacle_anchorable.duplicate()
	copy.fly_positions = fly_positions.duplicate()
	copy.boost_positions = boost_positions.duplicate()
	copy.first_chunk_index = first_chunk_index
	copy.last_chunk_index = last_chunk_index
	return copy
