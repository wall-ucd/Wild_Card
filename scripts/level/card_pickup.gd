class_name card_pickup
extends Area2D

signal card_pickup(card_type)

var used = false

func _ready():
	pass
	
func _on_body_entered(body: Node2D) -> void:
	if is_instance_of(body, CharacterBody2D) and body.name.to_lower().find("player") != -1 and used == false:
		# New card:
		used = true
		for child in body.get_children():
			if child.name == "CardsToPickupManager" and is_instance_of(child, Node):
				var cardToPickup = Node.new()
				cardToPickup.name = self.name
				child.add_child(cardToPickup)
				$PickupSound.play()
