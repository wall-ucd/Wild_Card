class_name Card
extends Control

const HOVER_SCALE_MIN : float = 2
const HOVER_SCALE_MAX : float = 2.25
const HOVER_SCALE_DELTA : float = 10

var Variant
var quantity : int = 1
var hoverScale = HOVER_SCALE_MIN

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
		
