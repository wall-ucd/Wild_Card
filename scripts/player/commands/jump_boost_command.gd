class_name JumpBoostCommand
extends Command


func execute(character: Character) -> Status:
	character.jumpBoost = true
	character.jump_velocity = character.jump_velocity * 2
	
	return Status.DONE
