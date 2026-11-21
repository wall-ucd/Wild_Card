
class_name DashCommand
extends Command

const DASH_SPEED = 1200.0

func execute(character: Character) -> Status:
	var player := character as Player
	if player == null:
		return Status.ERROR

	# Stop vertical movement immediately
	player.velocity.y = 0

	# Dash in the direction the player is facing
	if player.facing == Character.Facing.LEFT:
		player.velocity.x = -DASH_SPEED
	elif player.facing == Character.Facing.RIGHT:
		player.velocity.x = DASH_SPEED

	player.dashing = true

	return Status.DONE
