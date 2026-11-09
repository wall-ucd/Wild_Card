class_name Player
extends Character

var _dead:bool = false

@onready var animation_tree: AnimationTree = $AnimationTree

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
	_manage_animation_tree_state()


func _ready():
	super()
	animation_tree.active = true
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


# Logic to support the state machine in the AnimationTree (idle <-> walk, jump on leaving the floor).
func _manage_animation_tree_state() -> void:
	if not is_zero_approx(velocity.x):
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/moving"] = true
	else:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/moving"] = false

	if is_on_floor():
		animation_tree["parameters/conditions/jumping"] = false
		animation_tree["parameters/conditions/on_floor"] = true
	else:
		animation_tree["parameters/conditions/jumping"] = true
		animation_tree["parameters/conditions/on_floor"] = false
