extends Node2D
## A creature standing in a biome diorama (TEST ONLY - not used by the game).
## Has one SpriteFrames per colour variant. "Color" button swaps variant, "Anim" button
## cycles animation. Also responds to the showcase keys (N/P/R/Space/C) and clicks.

@export var display_name: String = ""
## One SpriteFrames per colour variant (all variants share animation names).
@export var variants: Array = []
@export var variant_names: PackedStringArray = []
@export var animation_order: PackedStringArray = []
@export var default_animation: String = ""
@export var hit_size: Vector2 = Vector2(64, 64)

var _sprite: AnimatedSprite2D
var _info: Label
var _variant := 0
var _anim := 0


func _ready() -> void:
	_sprite = $Sprite
	_info = get_node_or_null("Info") as Label
	var color_btn := get_node_or_null("ColorButton") as Button
	var anim_btn := get_node_or_null("AnimButton") as Button
	if color_btn:
		color_btn.pressed.connect(step_variant.bind(1))
	if anim_btn:
		anim_btn.pressed.connect(step_animation.bind(1))
	_anim = max(animation_order.find(default_animation), 0)
	_apply()


func step_variant(step: int) -> void:
	if variants.is_empty():
		return
	_variant = posmod(_variant + step, variants.size())
	_apply()


func step_animation(step: int) -> void:
	if animation_order.is_empty():
		return
	var frames := variants[_variant] as SpriteFrames
	# Skip names this variant doesn't have (variants are normally identical).
	for _i in animation_order.size():
		_anim = posmod(_anim + step, animation_order.size())
		if frames.has_animation(animation_order[_anim]):
			break
	_apply()


func reset_animation() -> void:
	_anim = max(animation_order.find(default_animation), 0)
	_apply()


func set_paused(paused: bool) -> void:
	if paused:
		_sprite.pause()
	else:
		_sprite.play()


func contains_global_point(point: Vector2) -> bool:
	return Rect2(-hit_size * 0.5, hit_size).has_point(to_local(point))


func _apply() -> void:
	if variants.is_empty():
		return
	var frames := variants[_variant] as SpriteFrames
	var anim := StringName(animation_order[_anim]) if not animation_order.is_empty() else &"default"
	if not frames.has_animation(anim):
		anim = StringName(default_animation)
	_sprite.sprite_frames = frames
	_sprite.play(anim)
	if _info:
		var vname := variant_names[_variant] if _variant < variant_names.size() else str(_variant)
		_info.text = "%s  (%d/%d)\n%s  (%d/%d)" % [
			vname, _variant + 1, variants.size(), anim, _anim + 1, animation_order.size()]
