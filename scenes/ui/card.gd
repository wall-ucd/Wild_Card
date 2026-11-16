class_name Card
extends Control

const HOVER_SCALE_MIN : float = 2
const HOVER_SCALE_MAX : float = 2.25
const HOVER_SCALE_DELTA : float = 10

var animal : Globals.animal_type
var quantity : int = 1
var hoverScale = HOVER_SCALE_MIN

func initialize(type : Globals.animal_type, xPos : float):
	animal = type
	position.x = xPos

func increment() -> void:
	# increment counter
	quantity += 1

	# update label text
	updateText()
	

# Return true if the card has been used up
func decrement() -> bool:
	# decrement counter
	quantity -= 1
	
	# update label text
	updateText()
	
	# check for used up condition
	if quantity <= 0:
		return true
	return false

func updateText() -> void:
	$CardBase/CardNumberBox/CardNumberLabel.text = str(quantity)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Handle Card Scaling
	if $Button.is_hovered():
		hoverScale = move_toward(hoverScale, HOVER_SCALE_MAX, delta * HOVER_SCALE_DELTA)
	else:
		hoverScale = move_toward(hoverScale, HOVER_SCALE_MIN, delta * HOVER_SCALE_DELTA)
	scale = hoverScale * Vector2(1,1)
		
