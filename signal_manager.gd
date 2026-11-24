extends Node

func useAbility(type : Globals.animal_type):
	%Player.use_ability(type)

func onCardPickup(type : Globals.animal_type):
	%UI.addCard(type)

func onDeath():
	%UI.incrementAttempts()

func clearHand():
	%UI.clearHand()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Player
	%Player/CardsToPickupManager.card_pickup.connect(onCardPickup)
	%Player.died_and_respawned.connect(clearHand)
	%Player.died_and_respawned.connect(onDeath)
	
	# UI
	%UI/CardDisplay.useAbility.connect(useAbility)
