class_name TeleportCommand
extends Command


func execute(character: Character) -> Status:
	if character.facing == character.Facing.LEFT:
		character.global_position += Vector2(-200,0)
	elif character.facing == character.Facing.RIGHT:
		character.global_position += Vector2(200,0)
	
	return Status.DONE
