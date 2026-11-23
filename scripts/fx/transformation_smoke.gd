class_name TransformationSmoke
extends AnimatedSprite2D

# The smoke puff for turning into an animal (scenes/fx/transformation_smoke.tscn).
# It plays as soon as it becomes visible, then hides itself again when it's done.
#
# How to use it:
#  - Put it in a scene (hidden) and call show() whenever you want a puff, or
#  - instance it into the level where you want it (it plays straight away).
#
# The first frame is a big solid cloud, so the "covered" signal is the moment to
# hide the player and show the animal (if you instance it, connect it before add_child).
# "finished" is sent when the smoke is gone.
# The 4 Outline nodes are dark copies 1 pixel out so it shows up on white clouds.

signal covered
signal finished

@export var deleteWhenDone := false # true = delete the smoke when it's done instead of hiding it


func _ready() -> void:
	visibility_changed.connect(onVisibilityChanged)
	frame_changed.connect(onFrameChanged)
	animation_finished.connect(onAnimationFinished)
	if visible:
		playSmoke()


func onVisibilityChanged() -> void:
	if visible:
		playSmoke()


func playSmoke() -> void:
	play("burst")
	for outline in get_children():
		outline.play("burst")
	covered.emit()


# keep the outlines on the same frame as the smoke
func onFrameChanged() -> void:
	for outline in get_children():
		outline.frame = frame


func onAnimationFinished() -> void:
	if deleteWhenDone:
		queue_free()
	else:
		hide()
	finished.emit()
