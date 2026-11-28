class_name card_pickup
extends Area2D

# A card in the level (scenes/cards/level_card_base.tscn).
# Each animal has its own level card scene made from it (scenes/cards/level/frog_level_card.tscn etc.)
# with "animal" set, so you just drag the one you want into the level.
# The card floats up and down, spins every few seconds, and floats up and fades when picked up.

signal card_pickup(card_type)

@export var animal: Globals.animal_type = Globals.animal_type.FROG

const CARD_SIZE = Vector2(68, 109)
const FLOAT_HEIGHT = 6.0
const FLOAT_SPEED = 0.8 # bobs per second
const SPIN_EVERY = 4.0 # seconds between spins
const SPIN_TIME = 0.8 # how long one spin takes
const CARD_BOTTOM = 54.0 # the card is centred on the pickup so its bottom is 54 pixels down
const SHADOW_GAP = 12.0

var used = false
var floatTimer := 0.0
var pastPlayerDiedCount = 0

func _ready():
	# start at a random time so cards next to each other don't move together
	floatTimer = randf() * SPIN_EVERY
	pastPlayerDiedCount = GlobalVariables.playerDieCount

func _process(delta: float) -> void:
	# Make not used if player respawns.
	if GlobalVariables.playerDieCount > pastPlayerDiedCount:
		pastPlayerDiedCount = GlobalVariables.playerDieCount
		if used:
			var tween = create_tween().set_parallel(true)
			tween.tween_property($Card, "position:y", $Card.position.y + 40.0, 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			tween.tween_property($Card, "modulate:a", 0.35, 0)
			tween.tween_property($Card, "modulate:a", 1, 0.35)
			used = false
	
	if used or not is_visible_in_tree():
		return
	floatTimer += delta

	# float up and down
	var bob = -(sin(floatTimer * TAU * FLOAT_SPEED) * 0.5 + 0.5) * FLOAT_HEIGHT
	$Card.position.y = CARD_BOTTOM + round(bob)

	# spin: squish the card sideways, and show the back when it's turned around
	var squish = 1.0
	var timeInSpin = fmod(floatTimer, SPIN_EVERY)
	if timeInSpin > SPIN_EVERY - SPIN_TIME:
		var spinProgress = (timeInSpin - (SPIN_EVERY - SPIN_TIME)) / SPIN_TIME
		squish = cos(spinProgress * TAU)
	if abs(squish) < 0.02:
		squish = 0.02 # scale can't be 0
	$Card.scale.x = squish
	$Card/Front.visible = squish >= 0
	$Card/Back.visible = squish < 0

	queue_redraw() # update the shadow


func _draw() -> void:
	if used:
		return
	# shadow under the card. It gets smaller when the card is higher up or turned sideways
	var height = (CARD_BOTTOM - $Card.position.y) / FLOAT_HEIGHT
	var shadowWidth = CARD_SIZE.x * 0.7 * clamp(abs($Card.scale.x), 0.3, 1.0) * (1.0 - height * 0.3)
	draw_set_transform(Vector2(0, CARD_BOTTOM + SHADOW_GAP), 0.0, Vector2(1.0, 0.18)) # squash the circle flat
	draw_circle(Vector2.ZERO, shadowWidth / 2, Color(0, 0, 0, 0.3))
	draw_set_transform(Vector2.ZERO)


func _on_body_entered(body: Node2D) -> void:
	if is_instance_of(body, CharacterBody2D) and body.name.to_lower().find("player") != -1 and used == false:
		# New card:
		used = true
		for child in body.get_children():
			if child.name == "CardsToPickupManager" and is_instance_of(child, Node):
				var cardToPickup = Node.new()
				cardToPickup.name = Globals.animal_type.keys()[animal] # the manager reads the animal from the name
				child.add_child(cardToPickup)
				$PickupSound.play()
		playPickupAnimation()



# card floats up and fades out
func playPickupAnimation() -> void:
	queue_redraw() # removes the shadow
	var tween = create_tween().set_parallel(true)
	tween.tween_property($Card, "position:y", $Card.position.y - 40.0, 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property($Card, "modulate:a", 0.0, 0.35)
