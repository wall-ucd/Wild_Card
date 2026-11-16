extends Node

func onCardPickup(type : Globals.animal_type):
	%UI.addCard(type)

func onDeath():
	%UI.incrementAttempts()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Player/CardsToPickupManager.card_pickup.connect(onCardPickup)
