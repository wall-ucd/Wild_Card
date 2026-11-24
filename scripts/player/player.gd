class_name Player
extends Character

#Defaults
var DASH_DURATION:float = 0.15
var GLIDE_DURATION:float = 2
var SPEED_DURATION:float = 2
var JUMP_DURATION:float = 2
var WALL_JUMP_BOUNCE_DURATION:float = 0.2

#Variables to assist with abilities
var dashing:bool = false
var dashCount:float = DASH_DURATION
var gliding:bool = false
var glideCount:float = GLIDE_DURATION
var speedBoost:bool = false
var speedCount:float = SPEED_DURATION
var jumpBoost:bool = false
var jumpCount:float = JUMP_DURATION
var wallJumping:bool = false
var wallCount:float = WALL_JUMP_BOUNCE_DURATION

var _dead:bool = false
var _last_teleported_position:Vector2 = Vector2(0, 0)
var previous_frame_position:Vector2
signal died_and_respawned

@onready var animation_tree: AnimationTree = $AnimationTree

var ability0:Command #teleport
var ability1:Command #double jump
var ability2:Command #dash
var ability3:Command #glide
var ability4:Command #speed boost
var ability5:Command #jump boost
var ability6:Command #wall jump

func teleport_to_spawn(spawn_position: Vector2) -> void:
	# Set the checkpoint explicitly, including short-distance level transitions.
	global_position = spawn_position
	_last_teleported_position = spawn_position
	previous_frame_position = spawn_position
	velocity = Vector2.ZERO
	_dead = false
	dashing = false
	dashCount = DASH_DURATION
	gliding = false
	glideCount = GLIDE_DURATION
	jumpBoost = false
	jumpCount = JUMP_DURATION
	speedBoost = false
	speedCount = SPEED_DURATION
	gravity = DEFAULT_GRAVITY
	wallJumping = false
	wallCount = WALL_JUMP_BOUNCE_DURATION


func take_damage():
	# This just oofs the player.
	$TakeDamageSound.pitch_scale = randf_range(0.65, 1.2)
	$TakeDamageSound.play(0.7)
	_dead = true

# I personally think it makes more sense to store the abilities in an array, like abilities[CAT]
# As it is, this function needs to be updated as new animals are added
func use_ability(animal : Globals.animal_type):
	
	
	if(animal == Globals.animal_type.BUNNY):
		ability2.execute(self)
	
	if(animal == Globals.animal_type.HEDGEHOG):
		ability4.execute(self)
	if(animal == Globals.animal_type.FROG):
		ability5.execute(self)
	if(animal == Globals.animal_type.CAT):
		ability6.execute(self)

	
	if(animal == Globals.animal_type.SNAIL):
		ability0.execute(self)
	if(animal == Globals.animal_type.MOUSE):
		ability0.execute(self)
	if(animal == Globals.animal_type.AXOLOTL):
		ability0.execute(self)

func _physics_process(delta: float):
	if _dead:
		# Teleport back to last teleported position
		# or where the player started.
		self.global_position = _last_teleported_position
		emit_signal("died_and_respawned")
		_dead = false
		return
	
	# Detect a teleport and save it.
	if ((self.global_position - previous_frame_position).length() * delta > 4):
		_last_teleported_position = self.global_position
		print((self.global_position - previous_frame_position).length() * delta)
	previous_frame_position = self.global_position

	var move_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		
	if Input.is_action_just_pressed("jump"):
		up_cmd.execute(self)
	
	if jumpBoost:
		jumpCount -= delta
		if jumpCount <= 0:
			jumpBoost = false
			jump_velocity = DEFAULT_JUMP_VELOCITY
			jumpCount = JUMP_DURATION
	
	if speedBoost:
		speedCount -= delta
		if speedCount <= 0:
			speedBoost = false
			movement_speed = DEFAULT_MOVE_VELOCITY
			speedCount = SPEED_DURATION
	
	if gliding:
		glideCount -= delta
		if glideCount <= 0 || is_on_floor():
			gliding = false
			glideCount = GLIDE_DURATION
			gravity = DEFAULT_GRAVITY
	
	if dashing:
		dashCount -= delta
		if dashCount <= 0:
			dashing = false
			dashCount = DASH_DURATION
	elif wallJumping:
		wallCount -= delta
		if wallCount <= 0:
			wallJumping = false
			wallCount = WALL_JUMP_BOUNCE_DURATION
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
	_last_teleported_position = self.global_position
	animation_tree.active = true
	previous_frame_position = self.global_position
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
	ability4 = SpeedBoostCommand.new()
	ability5 = JumpBoostCommand.new()
	ability6 = WallJumpCommand.new()


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
	ability4 = IdleCommand.new()
	ability5 = IdleCommand.new()
	ability6 = IdleCommand.new()


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


func _apply_gravity(delta: float) -> void:
	if dashing:
		velocity.y = 0
		return

	super._apply_gravity(delta)
