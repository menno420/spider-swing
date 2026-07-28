extends RefCounted
class_name SolidGeometry
## Deterministic polygon queries shared by attachment and collision policy.


static func closest_point_on_polygon(
	point: Vector2,
	polygon: PackedVector2Array,
) -> Dictionary:
	if polygon.size() < 2:
		return {
			"found": false,
			"point": Vector2.ZERO,
			"distance": INF,
		}

	var best_point := polygon[0]
	var best_distance_squared := INF
	for index in range(polygon.size()):
		var start := polygon[index]
		var finish := polygon[(index + 1) % polygon.size()]
		var candidate := _closest_point_on_segment(point, start, finish)
		var distance_squared := point.distance_squared_to(candidate)
		if distance_squared < best_distance_squared:
			best_distance_squared = distance_squared
			best_point = candidate
	return {
		"found": true,
		"point": best_point,
		"distance": sqrt(best_distance_squared),
	}


static func circle_intersects_polygon(
	center: Vector2,
	radius: float,
	polygon: PackedVector2Array,
) -> bool:
	if polygon.size() < 3:
		return false
	if _point_inside_polygon(center, polygon):
		return true
	var nearest := closest_point_on_polygon(center, polygon)
	return bool(nearest["found"]) and \
		center.distance_squared_to(nearest["point"]) <= radius * radius


static func bounds(polygon: PackedVector2Array) -> Rect2:
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


static func distance_to_segment(
	point: Vector2,
	start: Vector2,
	finish: Vector2,
) -> float:
	return point.distance_to(_closest_point_on_segment(point, start, finish))


static func _closest_point_on_segment(
	point: Vector2,
	start: Vector2,
	finish: Vector2,
) -> Vector2:
	var segment := finish - start
	var length_squared := segment.length_squared()
	if length_squared <= 0.000001:
		return start
	var progress := clampf((point - start).dot(segment) / length_squared, 0.0, 1.0)
	return start + segment * progress


static func _point_inside_polygon(
	point: Vector2,
	polygon: PackedVector2Array,
) -> bool:
	var inside := false
	var previous := polygon.size() - 1
	for current in range(polygon.size()):
		var a := polygon[current]
		var b := polygon[previous]
		if ((a.y > point.y) != (b.y > point.y)) and \
				point.x < (b.x - a.x) * (point.y - a.y) / \
				maxf(absf(b.y - a.y), 0.000001) * signf(b.y - a.y) + a.x:
			inside = not inside
		previous = current
	return inside
