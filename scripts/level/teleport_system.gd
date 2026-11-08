extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_teleport_entrance_body_entered(body: Node2D) -> void:
	if body == %Player:
		# Move player to next level.
		body.global_position = $Teleport_Exit.global_position
		%Camera2D.global_position = $NewCameraLocation.global_position
