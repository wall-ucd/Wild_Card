class_name AssetPreview
extends Node2D
## Wraps one asset (scene, SpriteFrames or TileSet) behind a single interface so the tester
## doesn't care what kind of thing it is showing.
##
## The node's origin is the asset's feet: put it on the floor and the asset stands on it.

const RAW_SCALE := 2.0  ## Raw SpriteFrames / tilesets: same 2x the game uses.

var entry: AssetCatalog.Entry
var content: Node  ## The instanced scene root, AnimatedSprite2D or TileMapLayer.

var _animation_player: AnimationPlayer
var _animated_sprite: AnimatedSprite2D
var _current := ""
var _paused := false


static func create(p_entry: AssetCatalog.Entry) -> AssetPreview:
	var preview := AssetPreview.new()
	preview.entry = p_entry
	preview.name = "Preview"
	return preview


func _ready() -> void:
	match entry.kind:
		AssetCatalog.Kind.SCENE:
			_build_scene()
		AssetCatalog.Kind.SPRITE_FRAMES:
			_build_sprite_frames()
		AssetCatalog.Kind.TILESET:
			_build_tileset()
	_align_feet()
	var names := get_animation_names()
	if not names.is_empty():
		play(names[0])


# ---------------------------------------------------------------- building --

func _build_scene() -> void:
	var packed := load(entry.path) as PackedScene
	if packed == null:
		return
	content = packed.instantiate()
	add_child(content)
	# Freeze the scene's own gameplay script (gravity, input...) so it just stands there.
	content.set_physics_process(false)
	content.set_process(false)
	content.set_process_input(false)
	content.set_process_unhandled_input(false)
	# The tester picks animations directly, so the AnimationTree must not override them.
	var tree := _find(content, "AnimationTree") as AnimationTree
	if tree:
		tree.active = false
	_animation_player = _find(content, "AnimationPlayer") as AnimationPlayer
	_animated_sprite = _find(content, "AnimatedSprite2D") as AnimatedSprite2D


func _build_sprite_frames() -> void:
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = load(entry.path) as SpriteFrames
	sprite.scale = Vector2.ONE * RAW_SCALE
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	content = sprite
	_animated_sprite = sprite
	add_child(sprite)


## Lays every tile of every atlas out at its atlas coordinate, i.e. a palette of what the TileSet defines.
func _build_tileset() -> void:
	var tile_set := load(entry.path) as TileSet
	var layer := TileMapLayer.new()
	layer.tile_set = tile_set
	layer.scale = Vector2.ONE * RAW_SCALE
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	layer.collision_enabled = false
	var column_offset := 0
	for s in tile_set.get_source_count():
		var source_id := tile_set.get_source_id(s)
		var atlas := tile_set.get_source(source_id) as TileSetAtlasSource
		if atlas == null:
			continue
		var widest := 0
		for t in atlas.get_tiles_count():
			var coords := atlas.get_tile_id(t)
			layer.set_cell(coords + Vector2i(column_offset, 0), source_id, coords)
			widest = maxi(widest, coords.x + 1)
		column_offset += widest + 1
	content = layer
	add_child(layer)


## Shift the content so this node's origin sits at the bottom of the asset.
func _align_feet() -> void:
	var item := content as Node2D
	if item == null:
		return
	var rect := _local_bounds()
	if entry.kind == AssetCatalog.Kind.SCENE:
		item.position = Vector2(0, -rect.end.y)
	else:
		item.position = Vector2(-rect.get_center().x, -rect.end.y)


## Bounds relative to `content`. Characters use their collision shape (that's what stands on the
## floor); everything else uses its visuals.
func _local_bounds() -> Rect2:
	if content is CharacterBody2D:
		for shape_node in content.find_children("*", "CollisionShape2D", true, false):
			var cs := shape_node as CollisionShape2D
			if cs.shape:
				return _rect_in_content(cs, cs.shape.get_rect())
	if content is TileMapLayer:
		var layer := content as TileMapLayer
		var used := layer.get_used_rect()
		var size := Vector2(layer.tile_set.tile_size)
		return Rect2(Vector2(used.position) * size * layer.scale, Vector2(used.size) * size * layer.scale)
	var bounds := Rect2()
	var first := true
	var nodes: Array[Node] = [content]
	nodes.append_array(content.find_children("*", "", true, false))
	for n in nodes:
		var r := Rect2()
		if n is Sprite2D and (n as Sprite2D).texture:
			r = (n as Sprite2D).get_rect()
		elif n is AnimatedSprite2D and (n as AnimatedSprite2D).sprite_frames:
			var a := n as AnimatedSprite2D
			var tex := a.sprite_frames.get_frame_texture(a.animation, 0) if a.sprite_frames.has_animation(a.animation) else null
			if tex == null:
				continue
			r = Rect2(-tex.get_size() * 0.5 + a.offset, tex.get_size())
		else:
			continue
		r = _rect_in_content(n as Node2D, r)
		bounds = r if first else bounds.merge(r)
		first = false
	return bounds


## `r` (in `node`'s space) expressed in this preview's space, ignoring content's own position.
func _rect_in_content(node: Node2D, r: Rect2) -> Rect2:
	var xf := Transform2D.IDENTITY
	var n: Node = node
	while n != null and n != content:
		if n is Node2D:
			xf = (n as Node2D).transform * xf
		n = n.get_parent()
	if content is Node2D:
		var c := content as Node2D
		xf = Transform2D(c.rotation, c.scale, c.skew, Vector2.ZERO) * xf
	return xf * r


func _find(root: Node, type: String) -> Node:
	if root.is_class(type):
		return root
	var hits := root.find_children("*", type, true, false)
	return hits[0] if not hits.is_empty() else null


# --------------------------------------------------------------- animation --

func get_animation_names() -> PackedStringArray:
	var names := PackedStringArray()
	if _animation_player:
		for n in _animation_player.get_animation_list():
			if n != "RESET":
				names.append(n)
	elif _animated_sprite and _animated_sprite.sprite_frames:
		var list := _animated_sprite.sprite_frames.get_animation_names()
		list.sort()
		names.append_array(list)
	return names


func play(anim_name: String) -> void:
	_current = anim_name
	if _animation_player and _animation_player.has_animation(anim_name):
		_animation_player.play(anim_name)
		if _paused:
			_animation_player.pause()
	elif _animated_sprite and _animated_sprite.sprite_frames.has_animation(anim_name):
		_animated_sprite.play(anim_name)
		if _paused:
			_animated_sprite.pause()


func set_paused(paused: bool) -> void:
	_paused = paused
	if _animation_player and _animation_player.has_animation(_current):
		if paused:
			_animation_player.pause()
		else:
			_animation_player.play(_current)
	elif _animated_sprite:
		if paused:
			_animated_sprite.pause()
		else:
			_animated_sprite.play(_current)


func is_paused() -> bool:
	return _paused


## Step one frame forward/back. Pauses playback first.
func step_frame(direction: int) -> void:
	if not _paused:
		set_paused(true)
	if _animation_player and _animation_player.has_animation(_current):
		var anim := _animation_player.get_animation(_current)
		var step := anim.step if anim.step > 0.0 else 0.1
		var t := fposmod(_animation_player.current_animation_position + step * direction, anim.length)
		_animation_player.seek(t, true)
	elif _animated_sprite and _animated_sprite.sprite_frames.has_animation(_current):
		var count := _animated_sprite.sprite_frames.get_frame_count(_current)
		_animated_sprite.frame = posmod(_animated_sprite.frame + direction, count)
