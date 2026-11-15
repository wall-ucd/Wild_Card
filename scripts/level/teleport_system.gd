extends Area2D


signal level_requested(scene_path: String)

# Leave empty for a coin that does not change levels.
@export_file("*.tscn") var next_level := ""
var _triggered := false

func _ready() -> void:
	# A coin can use its own Area2D instead of a second overlapping hitbox.
	body_entered.connect(_on_teleport_entrance_body_entered)

func _on_teleport_entrance_body_entered(body: Node2D) -> void:
	if not body is Player or next_level.is_empty() or _triggered:
		return
	_triggered = true
	level_requested.emit(next_level)
