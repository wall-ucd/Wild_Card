class_name card_pickup
extends Area2D

var used = false

func _ready():
	pass
	
func _on_body_entered(body: Node2D) -> void:
	if body == %Player and used == false:
		# New card:
		used = true
		var new_card = Node.new()
		new_card.name = self.name
		%CardDisplay.add_child(new_card)
		# Delete the node.
		$PickupSound.play()
		remove_child($AnimatedSprite2D)
