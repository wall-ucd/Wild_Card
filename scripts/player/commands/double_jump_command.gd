class_name DoubleJumpCommand
extends Command


func execute(character: Character) -> Status:
	if !character.is_on_floor() && !character.double_jumped && !character.gliding:
		character.velocity.y = character.jump_velocity
		character.command_callback("jump")
		character.double_jumped = true
	return Status.DONE
