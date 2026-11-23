class_name JumpBoostCommand
extends Command

func execute(character: Character) -> Status:
	# set jump boost multiplier here
	var boosted_jump_velocity = character.DEFAULT_JUMP_VELOCITY * 1.5
	
	character.jumpBoost = true
	character.jump_velocity = boosted_jump_velocity
	
	return Status.DONE
