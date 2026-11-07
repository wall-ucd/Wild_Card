class_name card_pickup
extends Area2D

signal card_pickup(card_type)

var used = false

func _ready():
	pass
	
func _on_body_entered(body: Node2D) -> void:
	if body == %Player and used == false:
		# New card:
		used = true
		# Delete the node.
		$PickupSound.play()
		remove_child($AnimatedSprite2D)
		emit_signal("card_pickup", global_variables.animal_type[self.name])
