class_name GlideCommand
extends Command


func execute(character: Character) -> Status:
	if !character.is_on_floor():
		character.gliding = true
		character.velocity.y = 0
		@warning_ignore("integer_division")
		character.gravity = character.gravity / 4
	
	return Status.DONE
