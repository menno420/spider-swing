extends Node2D
## Swing Laboratory placeholder (bootstrap phase).
##
## Shows that the project boots, the Compatibility renderer is live, and the
## reference viewport is configured. It renders a label and nothing else.
##
## NOT gameplay: there is no spider body, no web, no forward drive, no anchor,
## no camera follow, and no physics of any kind here. Phase 0 replaces this
## placeholder with the real Swing Laboratory — see the Phase 0 issue and
## docs/game-design/Spider-Swing-GDD-v2.0.md § 23.
##
## Presentation-layer rules that already apply (docs/runtime_contracts.md):
## this layer consumes application APIs and domain events and never mutates
## authoritative simulation state.

const PLACEHOLDER_TITLE := "Spider Swing — Phase 0 Swing Laboratory"

@onready var _title: Label = %Title
@onready var _subtitle: Label = %Subtitle


func _ready() -> void:
	_title.text = PLACEHOLDER_TITLE
	_subtitle.text = _describe_runtime()


## One readable line proving the runtime contracts this bootstrap locked in.
func _describe_runtime() -> String:
	var viewport_size := Vector2i(
		int(ProjectSettings.get_setting("display/window/size/viewport_width", 0)),
		int(ProjectSettings.get_setting("display/window/size/viewport_height", 0)),
	)
	return "Godot %s · %s · %dx%d reference · %d Hz fixed step · swing physics not implemented yet" % [
		Engine.get_version_info().get("string", "unknown"),
		str(ProjectSettings.get_setting("rendering/renderer/rendering_method", "unknown")),
		viewport_size.x,
		viewport_size.y,
		Engine.physics_ticks_per_second,
	]
