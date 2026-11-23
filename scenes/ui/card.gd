class_name Card
extends Control

signal useCard(animal : Globals.animal_type)
signal removeCard(cardInstance : Card)

const HOVER_SCALE_MIN : float = 2
const HOVER_SCALE_MAX : float = 2.25
const HOVER_SCALE_DELTA : float = 10

var animal : Globals.animal_type
var quantity : int = 1
var hoverScale = HOVER_SCALE_MIN

func setXPos(newXPos : float) -> void:
	position.x = newXPos

func initialize(type : Globals.animal_type, xPos : float):
	animal = type
	setXPos(xPos)

func increment() -> void:
	# increment counter
	quantity += 1

	# update label text
	updateText()

# Return true if the card has been used up
func decrement() -> void:
	# decrement counter
	quantity -= 1
	
	# update label text
	updateText()
	
func updateText() -> void:
	$Front/CountBadge/CountLabel.text = str(quantity)

func signalCardPressed():
	# TODO: have some checking if the card can be used
	useCard.emit(animal)
	
	decrement()
	if quantity == 0:
		removeCard.emit(self)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Button.pressed.connect(signalCardPressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Handle Card Scaling
	if $Button.is_hovered():
		hoverScale = move_toward(hoverScale, HOVER_SCALE_MAX, delta * HOVER_SCALE_DELTA)
	else:
		hoverScale = move_toward(hoverScale, HOVER_SCALE_MIN, delta * HOVER_SCALE_DELTA)
	scale = hoverScale * Vector2(1,1)
		
