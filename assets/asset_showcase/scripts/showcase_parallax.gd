extends Node2D
## Scrolls stacked background layers at different speeds (TEST ONLY).
## Each child Sprite2D must have region_enabled and texture_repeat = Enabled.
## Children are ordered back (index 0, slowest) to front (fastest).

@export var base_speed: float = 6.0
@export var speed_step: float = 8.0

var _paused := false


func set_paused(paused: bool) -> void:
	_paused = paused


func _process(delta: float) -> void:
	if _paused:
		return
	var i := 0
	for child in get_children():
		var sprite := child as Sprite2D
		if sprite == null or not sprite.region_enabled:
			continue
		var r := sprite.region_rect
		r.position.x = fmod(r.position.x + (base_speed + speed_step * i) * delta, float(sprite.texture.get_width()))
		sprite.region_rect = r
		i += 1
