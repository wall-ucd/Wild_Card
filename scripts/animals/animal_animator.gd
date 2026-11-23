class_name AnimalAnimator
extends Area2D

# Plays an animal's animations. It's on the root of every animal scene (scenes/animals/).
# Each animal's settings (which frames to use etc.) are in the Inspector on that scene.
#
# Call these from your code:
#  faceLeft(true / false)                       turn the animal around
#  updateAnimation(velocity, onFloor, delta)    call every frame. Plays idle / walk / jump / land by itself
#  playAbility()                                plays the animal's ability animation (dash, pounce...)
#  isPlayingAbility()                           true while the ability animation is playing
#
# Example
#  animal.faceLeft(facing == Facing.LEFT)
#  animal.updateAnimation(velocity, is_on_floor(), delta)
#  if dashed: animal.playAbility()

@export var idleAnim := "idle"
@export var walkAnim := "walk"
@export var walkLeftAnim := "" # only if the animal has its own walk left animation 
@export var walkSpeed := 0.0 # speed the walk looks right at. Walks faster when moving faster (0 = never)
@export var facesLeft := false # true if the sprite sheet faces left

@export_group("Jump")
@export var hopFrames: Array[int] = [] # little hop when leaving the ground
@export var airFrame := -1 # frame held in the air until landing (-1 = no jump frames)
@export var landFrames: Array[int] = []

@export_group("Ability")
@export var abilityFrames: Array[int] = [] # frames to play for the ability...
@export var abilityFps := 12.0
@export var abilityAnim := "" # ...or an animation from the AnimationPlayer

const HOP_FPS = 24.0
const LAND_FPS = 14.0

var currentAnim := ""
var handFrames := [] # frames being played by hand (hop, land, ability)
var handFps := 12.0
var handTimer := 0.0
var inAir := false
var wasOnFloor := true
var lastYVelocity := 0.0
var firstUpdate := true
var facingLeft := false


func _ready() -> void:
	# we play the animations ourselves so turn off the AnimationTree
	if has_node("AnimationTree"):
		$AnimationTree.active = false
	$AnimationPlayer.play(idleAnim)
	currentAnim = idleAnim


func faceLeft(left: bool) -> void:
	facingLeft = left
	if walkLeftAnim == "":
		$Sprite2D.flip_h = left != facesLeft


func playAbility() -> void:
	if abilityFrames.size() > 0:
		playHandFrames(abilityFrames, abilityFps)
	elif abilityAnim != "":
		$AnimationPlayer.play(abilityAnim)
		$AnimationPlayer.speed_scale = 1.0
		currentAnim = abilityAnim


func isPlayingAbility() -> bool:
	if abilityFrames.size() > 0 and handFrames == abilityFrames:
		return true
	return abilityAnim != "" and currentAnim == abilityAnim and $AnimationPlayer.is_playing()


func updateAnimation(velocity: Vector2, onFloor: bool, delta: float) -> void:
	# first time: start in the air pose if we're already in the air
	if firstUpdate:
		firstUpdate = false
		wasOnFloor = onFloor
		lastYVelocity = velocity.y
		inAir = not onFloor

	# Jumping (only for animals with jump frames):
	# little hop when we leave the ground, hold the air frame, then land
	if airFrame != -1:
		var launchedMidAir = velocity.y < lastYVelocity - 200 # like the bunny's double jump
		if not onFloor and (wasOnFloor or launchedMidAir):
			inAir = true
			if velocity.y < 0: # going up so do the hop (not when walking off a ledge)
				playHandFrames(hopFrames, HOP_FPS)
		elif onFloor and not wasOnFloor:
			inAir = false
			playHandFrames(landFrames, LAND_FPS)
	wasOnFloor = onFloor
	lastYVelocity = velocity.y

	# frames being played by hand (hop, landing or ability)
	if handFrames.size() > 0:
		handTimer += delta
		var i = int(handTimer * handFps)
		if i < handFrames.size():
			$Sprite2D.frame = handFrames[i]
			return
		handFrames = [] # done

	# hold the air frame until we land
	if inAir and airFrame != -1:
		$Sprite2D.frame = airFrame
		return

	# let the ability animation finish (hedgehog dash)
	if abilityAnim != "" and currentAnim == abilityAnim and $AnimationPlayer.is_playing():
		return

	# idle or walk
	var anim = idleAnim
	var moving = abs(velocity.x) > 1
	if moving:
		if facingLeft and walkLeftAnim != "":
			anim = walkLeftAnim
		else:
			anim = walkAnim
	if currentAnim != anim:
		$AnimationPlayer.play(anim)
		currentAnim = anim

	# walk faster when moving faster so the feet don't slide (max 3x)
	$AnimationPlayer.speed_scale = 1.0
	if moving and walkSpeed > 0:
		$AnimationPlayer.speed_scale = clamp(abs(velocity.x) / walkSpeed, 1.0, 3.0)


func playHandFrames(frames: Array, fps: float) -> void:
	if frames.size() == 0:
		return
	# stop the AnimationPlayer so it doesn't change the frame back
	if currentAnim != "":
		$AnimationPlayer.stop()
		currentAnim = ""
	handFrames = frames
	handFps = fps
	handTimer = 0.0
