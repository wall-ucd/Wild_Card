extends Area2D

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(collisionObject) -> void:
	if collisionObject.has_method("take_damage"):
		collisionObject.take_damage()
