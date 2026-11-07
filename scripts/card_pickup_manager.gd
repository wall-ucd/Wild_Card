extends Node2D
class_name card_pickup_manager

signal card_pickup(card_type)

func _on_card_pickup(card_type: Variant) -> void:
	# Relay which card got picked up to the UI.
	emit_signal("card_pickup", card_type)

func _ready():
	for card_pickup_element in get_children():
		card_pickup_element.connect("card_pickup", _on_card_pickup)
