class_name JumpBoostCommand
extends Command


func execute(character: Character) -> Status:
	character.jumpBoost = true
	character.jump_velocity = character.jump_velocity * 1.7
	
	return Status.DONE
