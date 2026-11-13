extends Area2D

func _on_body_entered(collisionObject) -> void:
	if collisionObject.has_method("take_damage"):
		collisionObject.take_damage()
