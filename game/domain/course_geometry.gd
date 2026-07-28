extends RefCounted
class_name CourseGeometry
## Immutable-at-consumption world geometry crossing application -> simulation.
##
## The course stream owns which chunks are retained. Simulation receives only
## the compact collision/attachment geometry needed for the current fixed step.

var surface_segments: Array[Rect2] = []
var aim_guides: PackedVector2Array = PackedVector2Array()
var obstacles: Array[Rect2] = []
var first_chunk_index: int = 0
var last_chunk_index: int = 0


func duplicate_geometry() -> CourseGeometry:
	var copy := CourseGeometry.new()
	copy.surface_segments = surface_segments.duplicate()
	copy.aim_guides = aim_guides.duplicate()
	copy.obstacles = obstacles.duplicate()
	copy.first_chunk_index = first_chunk_index
	copy.last_chunk_index = last_chunk_index
	return copy
