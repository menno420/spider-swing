extends RefCounted
class_name CourseObstacleCatalog
## Stable semantic obstacle kinds shared across course generation and rendering.
##
## Geometry remains authoritative for collision and attachment. These ids only
## tell presentation which inspected silhouette belongs over that geometry, so
## the renderer never has to infer content identity from a bounding rectangle.

const UNSPECIFIED := &""
const CANOPY_HOOK_VINE_LEFT := &"canopy_hook_vine_left"
const CANOPY_HOOK_VINE_RIGHT := &"canopy_hook_vine_right"
const CANOPY_LEAF_SHUTTER_LEFT := &"canopy_leaf_shutter_left"
const CANOPY_LEAF_SHUTTER_RIGHT := &"canopy_leaf_shutter_right"
