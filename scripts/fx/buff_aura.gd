class_name BuffAura
extends Node2D

# An aura that shows a buff is active (like scenes/fx/speed_aura.tscn).
# The scene's position is the character's feet. It's already in player.tscn (hidden).
#
# How to use it:
#  - show()      plays the "start" animation, then loops "loop"
#  - playEnd()   plays the "end" animation, then hides it
#  - hide()      hides it straight away
# Other buffs can use this too: copy speed_aura.tscn and swap the SpriteFrames
# (it needs "start", "loop" and "end" animations).


func _ready() -> void:
	visibility_changed.connect(onVisibilityChanged)
	$Aura.animation_finished.connect(onAnimationFinished)
	if visible:
		$Aura.play("start")


func onVisibilityChanged() -> void:
	if visible:
		$Aura.play("start")


func playEnd() -> void:
	if visible:
		$Aura.play("end")


func onAnimationFinished() -> void:
	if $Aura.animation == "start":
		$Aura.play("loop")
	elif $Aura.animation == "end":
		hide()
