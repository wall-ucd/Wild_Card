class_name DoubleJumpCommand
extends Command


func execute(character: Character) -> Status:
	if !character.is_on_floor() && !character.gliding:
		character.velocity.y = character.DEFAULT_JUMP_VELOCITY
	return Status.DONE
