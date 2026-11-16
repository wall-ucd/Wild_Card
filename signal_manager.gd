extends Node

func onCardPickup(type : Globals.animal_type):
	# Notify UI
	%UI.addCard(type)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Player/CardsToPickupManager.card_pickup.connect(onCardPickup)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
