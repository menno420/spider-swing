extends RefCounted
class_name SimulationSnapshot
## Read-only-by-convention frame presented outside authoritative simulation.

var tick: int = 0
var position: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var target_speed: float = 0.0
var distance_pixels: float = 0.0
var furthest_x: float = 0.0
var left_kill_boundary: float = 0.0
var web_attached: bool = false
var anchor: Vector2 = Vector2.ZERO
var rope_length: float = 0.0
var web_maximum_length: float = 0.0
var tension: float = 0.0
var reel_energy: float = 0.0
var reel_capacity: float = 100.0
var reel_active: bool = false
var reel_lockout: float = 0.0
var burst_cooldown: float = 0.0
var burst_cooldown_capacity: float = 1.0
var run_state: StringName = &"active"
var death_cause: StringName = &""
var preset_name: StringName = &"balanced_candidate"
var anchors: PackedVector2Array = PackedVector2Array()
var surface_segments: Array[Rect2] = []
var obstacles: Array[Rect2] = []
var debug_visible: bool = false
var debug_paused: bool = false
var slow_motion: bool = false
var recording: bool = false
var replaying: bool = false
var selected_parameter: StringName = &"gravity"
var selected_parameter_value: float = 0.0
var seed: int = 1337
var camera_follow_strength: float = 8.0
var camera_look_ahead: float = 0.22
