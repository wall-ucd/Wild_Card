class_name CardDisplay
extends Control


@export var numCards : int

func _on_card_pickup(animal_type: Variant) -> void:
	if animal_type == global_variables.animal_type.FROG:
		print("Picked up frog")
	elif animal_type == global_variables.animal_type.CAT:
		print("Picked up cat")
	elif animal_type == global_variables.animal_type.HEDGEHOG:
		print("Picked up hedgehog")
	elif animal_type == global_variables.animal_type.BUNNY:
		print("Picked up bunny")
	elif animal_type == global_variables.animal_type.SNAIL:
		print("Picked up snail")
	elif animal_type == global_variables.animal_type.MOUSE:
		print("Picked up mouse")
	elif animal_type == global_variables.animal_type.AXOLOTL:
		print("Picked up axolotl")
	elif animal_type == global_variables.animal_type.BAT:
		print("Picked up bat")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _draw() -> void:
	const X_OFFSET := 20
	const CARD_DIST := 160
	const CARD_WIDTH := 120
	const CARD_HEIGHT := 160
	for i in numCards:
		var xPos := X_OFFSET + CARD_DIST * i
		var yPos := 0
		draw_rect(Rect2(xPos, yPos, CARD_WIDTH, CARD_HEIGHT), Color.RED)
