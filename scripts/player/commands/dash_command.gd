class_name DashCommand
extends Command


func execute(character: Character) -> Status:
	if character.facing == character.Facing.LEFT:
		character.velocity.x = character.jump_velocity
	elif character.facing == character.Facing.RIGHT:
		character.velocity.x = -character.jump_velocity
	character.dashing = true
	
	return Status.DONE
