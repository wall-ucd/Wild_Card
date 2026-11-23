extends Node2D

@export_file("*.tscn") var starting_level := "res://scenes/levels/tutorial_level.tscn"
var fallback_level := "res://scenes/levels/test_level.tscn"

var current_level: Node2D

func _ready() -> void:
	load_level(starting_level)

func load_level(scene_path: String) -> void:
	var target := scene_path if ResourceLoader.exists(scene_path) else fallback_level
	var packed := load(target) as PackedScene
	if packed == null:
		push_error("Cannot load level: " + target)
		return
	var next_level := packed.instantiate() as Node2D
	if next_level == null or not next_level.has_node("SpawnPoint"):
		if next_level: next_level.free()
		push_error("Level needs a Node2D root and SpawnPoint: " + target)
		return
	# Remove the previous scene before activating the next scene's physics/background.
	for old_level in $LevelContainer.get_children():
		$LevelContainer.remove_child(old_level)
		old_level.queue_free()
	current_level = next_level
	$LevelContainer.add_child(current_level)
	for node in current_level.find_children("*", "Area2D", true, false):
		if node.has_signal("level_requested"):
			node.level_requested.connect(_on_level_requested)
	var spawn := current_level.get_node("SpawnPoint") as Marker2D
	$Player.teleport_to_spawn(spawn.global_position)
	var camera_position := spawn.get_node_or_null("CameraPosition") as Marker2D
	$Camera2D.global_position = camera_position.global_position if camera_position else spawn.global_position

func _on_level_requested(scene_path: String) -> void:
	load_level.call_deferred(scene_path)
