class_name Player
extends Character

var _dead:bool = false
var double_jumped:bool = false
var dashing:bool = false
var dashCount:int = 20
var gliding:bool = false
var glideCount:int = 200

@onready var animation_tree: AnimationTree = $AnimationTree

var ability0 : Command #teleport
var ability1 : Command #double jump
var ability2 : Command #dash
var ability3 : Command #glide

func _physics_process(delta: float):
	if _dead:
		return

	var move_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	if is_on_floor():
		double_jumped = false

	if Input.is_action_just_pressed("jump"):
		up_cmd.execute(self)
		
	if Input.is_action_just_pressed("jump"):
		up_cmd.execute(self)
		
	#Ability activations. Will be modified
	if Input.is_action_just_pressed("ability0"):
		ability0.execute(self)
		
	if Input.is_action_just_pressed("ability1"):
		ability1.execute(self)
	
	if Input.is_action_just_pressed("ability2"):
		ability2.execute(self)
		
	if Input.is_action_just_pressed("ability3"):
		ability3.execute(self)
	
	if gliding:
		glideCount -= 1
		if glideCount <= 0 || is_on_floor():
			gliding = false
			glideCount = 200
			gravity = defaultGravity
	
	if dashing:
		dashCount -= 1
		if dashCount <= 0:
			dashing = false
			dashCount = 20
			
	else:
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
	#abilities
	ability0 = TeleportCommand.new()
	ability1 = DoubleJumpCommand.new()
	ability2 = DashCommand.new()
	ability3 = GlideCommand.new()


func unbind_player_input_commands():
	right_cmd = IdleCommand.new()
	left_cmd = IdleCommand.new()
	up_cmd = IdleCommand.new()
	idle = IdleCommand.new()
	#abilities
	ability0 = IdleCommand.new()
	ability1 = IdleCommand.new()
	ability2 = IdleCommand.new()
	ability3 = IdleCommand.new()


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
