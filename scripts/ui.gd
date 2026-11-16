extends Control

var attempts : int = 1

func addCard(type : Globals.animal_type) -> void:
	$CardDisplay.addCard(type)
	
func incrementAttempts() -> void:
	attempts += 1
	$In_Game/Top_Text/Attempts_Counter.text = str(attempts)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
