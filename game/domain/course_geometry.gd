extends RefCounted
class_name CourseGeometry
## Immutable-at-consumption world geometry crossing application -> simulation.
##
## The course stream owns which chunks are retained. Simulation receives only
## the compact collision/attachment geometry needed for the current fixed step.

var surfaces: Array[PackedVector2Array] = []
var aim_guides: PackedVector2Array = PackedVector2Array()
var obstacles: Array[PackedVector2Array] = []
var first_chunk_index: int = 0
var last_chunk_index: int = 0


func duplicate_geometry() -> CourseGeometry:
	var copy := CourseGeometry.new()
	for surface: PackedVector2Array in surfaces:
		copy.surfaces.append(surface.duplicate())
	copy.aim_guides = aim_guides.duplicate()
	for obstacle: PackedVector2Array in obstacles:
		copy.obstacles.append(obstacle.duplicate())
	copy.first_chunk_index = first_chunk_index
	copy.last_chunk_index = last_chunk_index
	return copy
