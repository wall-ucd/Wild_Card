class_name WallJumpCommand
extends Command


func execute(character: Character) -> Status:
	if character.is_on_wall():
		character.velocity.y = character.jump_velocity
		if character.facing == character.Facing.RIGHT:
			character.velocity.x = -character.movement_speed
			character.sprite.flip_h = true
			character.change_facing(Character.Facing.LEFT)
		elif character.facing == character.Facing.LEFT:
			character.velocity.x = character.movement_speed
			character.sprite.flip_h = false
			character.change_facing(Character.Facing.RIGHT)
		character.wallJumping = true
		
	return Status.DONE
