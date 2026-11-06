class_name Player
extends Character

var _dead:bool = false

func _physics_process(delta: float):
	if _dead:
		return

	var move_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	if Input.is_action_just_pressed("jump"):
		up_cmd.execute(self)
	
	if move_input > 0.1:
		right_cmd.execute(self)
	elif move_input < -0.1:
		left_cmd.execute(self)
	else:
		idle.execute(self)
	
	super(delta)


func _ready():
	bind_player_input_commands()

func bind_player_input_commands():
	right_cmd = MoveRightCommand.new()
	left_cmd = MoveLeftCommand.new()
	up_cmd = JumpCommand.new()
	idle = IdleCommand.new()


func unbind_player_input_commands():
	right_cmd = IdleCommand.new()
	left_cmd = IdleCommand.new()
	up_cmd = IdleCommand.new()
	idle = IdleCommand.new()
