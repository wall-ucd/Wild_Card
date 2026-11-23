class_name SpeedBoostCommand
extends Command


func execute(character: Character) -> Status:
	character.speedBoost = true
	character.movement_speed = character.DEFAULT_MOVE_VELOCITY * 2
	
	return Status.DONE
