class_name CardDisplay
extends Control


@export var numCards : int

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
