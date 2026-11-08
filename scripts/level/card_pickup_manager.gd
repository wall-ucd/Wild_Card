extends Node
class_name card_pickup_manager

signal card_pickup(card_type)

func _on_child_entered_tree(node: Node) -> void:
	emit_signal("card_pickup", global_variables.animal_type[node.name])
	remove_child(node)

func _ready():
	pass
