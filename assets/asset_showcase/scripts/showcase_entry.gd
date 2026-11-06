extends Node2D
## One item in the asset showcase (TEST ONLY - not used by the game).
## Holds an AnimatedSprite2D called "Sprite" (or a static Sprite2D) plus labels.
## Left click cycles to the next animation, right click to the previous one.

@export var display_name: String = ""
## Animation names in the order they should be cycled (SpriteFrames sorts them alphabetically).
@export var animation_order: PackedStringArray = []
@export var default_animation: String = ""
## Size of the clickable area in local pixels, centred on the sprite.
@export var hit_size: Vector2 = Vector2(64, 64)

var _sprite: AnimatedSprite2D
var _anim_label: Label
var _index: int = 0


func _ready() -> void:
	_sprite = get_node_or_null("Sprite") as AnimatedSprite2D
	_anim_label = get_node_or_null("AnimLabel") as Label
	if _sprite == null or _sprite.sprite_frames == null:
		return
	if animation_order.is_empty():
		animation_order = _sprite.sprite_frames.get_animation_names()
	var start := animation_order.find(default_animation)
	_set_index(max(start, 0))


func has_animations() -> bool:
	return _sprite != null and animation_order.size() > 0


func step_animation(step: int) -> void:
	if not has_animations():
		return
	_set_index(posmod(_index + step, animation_order.size()))


func reset_animation() -> void:
	if not has_animations():
		return
	_set_index(max(animation_order.find(default_animation), 0))


func set_paused(paused: bool) -> void:
	if _sprite == null:
		return
	if paused:
		_sprite.pause()
	else:
		_sprite.play()


func contains_global_point(point: Vector2) -> bool:
	var local := to_local(point)
	return Rect2(-hit_size * 0.5, hit_size).has_point(local)


func _set_index(i: int) -> void:
	_index = i
	var anim := StringName(animation_order[_index])
	_sprite.play(anim)
	if _anim_label:
		var frames := _sprite.sprite_frames.get_frame_count(anim)
		_anim_label.text = "%s  (%d/%d, %df)" % [anim, _index + 1, animation_order.size(), frames]
