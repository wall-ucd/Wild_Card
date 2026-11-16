class_name CardDisplay
extends Control

@export var cardSpacing := 100

var cards : Array[Card]
var cardScene : PackedScene = preload("res://scenes/ui/card.tscn")

func addCard(type : Globals.animal_type) -> void:
	# Check if card of type already exists
	for i in cards.size():
		if cards[i].animal == type:
			cards[i].increment()
			return
	
	# Create a new card
	var instance := cardScene.instantiate() as Card
	var x := cardSpacing * cards.size()
	instance.initialize(type, x)
	cards.push_back(instance)
	add_child(instance)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _draw() -> void:
	pass
