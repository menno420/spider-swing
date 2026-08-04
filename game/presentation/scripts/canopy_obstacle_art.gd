extends RefCounted
class_name CanopyObstacleArt
## Shared presentation rule for directional Bramble Canopy obstacles.
##
## Source art is painted growing upward from the floor. Ceiling-mounted art
## therefore flips vertically, while the authored left/right kind owns only
## the horizontal mirror. Gameplay and tutorial previews consume this one rule
## so a staged lesson cannot silently place a production obstacle upside down.

const MOUNT_FLOOR := &"floor"
const MOUNT_CEILING := &"ceiling"
const VALID_MOUNTS: Array[StringName] = [MOUNT_FLOOR, MOUNT_CEILING]


static func directional_spec(
	obstacle_kind: StringName,
	mount: StringName,
) -> Dictionary:
	if mount not in VALID_MOUNTS:
		return {}
	var asset_id := &""
	var flip_x := false
	match obstacle_kind:
		CourseObstacleCatalog.CANOPY_HOOK_VINE_LEFT:
			asset_id = ArtAssetCatalog.CANOPY_HOOK_VINE
			flip_x = true
		CourseObstacleCatalog.CANOPY_HOOK_VINE_RIGHT:
			asset_id = ArtAssetCatalog.CANOPY_HOOK_VINE
		CourseObstacleCatalog.CANOPY_LEAF_SHUTTER_LEFT:
			asset_id = ArtAssetCatalog.CANOPY_LEAF_SHUTTER
			flip_x = true
		CourseObstacleCatalog.CANOPY_LEAF_SHUTTER_RIGHT:
			asset_id = ArtAssetCatalog.CANOPY_LEAF_SHUTTER
		_:
			return {}
	return {
		"asset_id": asset_id,
		"kind": obstacle_kind,
		"mount": mount,
		"flip_x": flip_x,
		"flip_y": mount == MOUNT_CEILING,
	}
