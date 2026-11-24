class_name CardDisplay
extends Control

@export var cardSpacing := 120

signal useAbility(animal : Globals.animal_type)
var cards : Array[Card]
# The card scene for each animal (they're in scenes/cards/ui/)
var cardScenes = {
	Globals.animal_type.FROG: preload("res://scenes/cards/ui/frog_ui_card.tscn"),
	Globals.animal_type.CAT: preload("res://scenes/cards/ui/cat_ui_card.tscn"),
	Globals.animal_type.HEDGEHOG: preload("res://scenes/cards/ui/hedgehog_ui_card.tscn"),
	Globals.animal_type.BUNNY: preload("res://scenes/cards/ui/bunny_ui_card.tscn"),
	Globals.animal_type.SNAIL: preload("res://scenes/cards/ui/snail_ui_card.tscn"),
	Globals.animal_type.MOUSE: preload("res://scenes/cards/ui/mouse_ui_card.tscn"),
	Globals.animal_type.AXOLOTL: preload("res://scenes/cards/ui/axolotl_ui_card.tscn"),
	Globals.animal_type.BAT: preload("res://scenes/cards/ui/bat_ui_card.tscn"),
}

func adjustCardPositions():
	for i in cards.size():
		cards[i].setXPos(cardSpacing * i)

func addCard(type : Globals.animal_type) -> void:
	# Check if card of type already exists
	for i in cards.size():
		if cards[i].animal == type:
			cards[i].increment()
			return
	
	# Create a new card
	var instance := cardScenes[type].instantiate() as Card
	var x := cardSpacing * cards.size()
	instance.initialize(type, x)
	cards.push_back(instance)
	add_child(instance)
	
	# Connect signals
	instance.removeCard.connect(removeCard)
	instance.useCard.connect(useCard)

func clearHand() -> void:
	# Free the cards
	for c in cards:
		c.queue_free()
	
	# Empty the array
	cards.clear()

func removeCard(cardInstance : Card):
	cards.erase(cardInstance)
	cardInstance.queue_free()
	adjustCardPositions()

func useCard(animal : Globals.animal_type):
	useAbility.emit(animal)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _draw() -> void:
	pass
