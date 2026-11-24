@tool
class_name LevelBackground
extends Node2D

# Parallax background for a level.
# Put this inside the level's "Background" CanvasLayer and pick a scenery in the Inspector.
# It copies the layers from that scenery scene (the *_scenery.tscn files) and:
#  - scales them by a whole number so the pixel art stays sharp
#  - makes them big enough to fill the screen
#  - moves each layer at its own speed when the camera moves (parallax)
#  - keeps the clouds drifting (autoscroll)
# If you change the layers in the scenery scene, every level using it changes too.

@export_file("*_scenery.tscn") var scenery := "res://assets/environments/seasonal/grassland/grassland_scenery.tscn":
	set(newScenery):
		scenery = newScenery
		if is_inside_tree():
			makeLayers()

var layers = [] # each one is {"sprite", "parallax", "speed", "drift"}
var pixelScale := 1


func _enter_tree() -> void:
	get_viewport().size_changed.connect(resizeLayers)
	resizeLayers()


func _ready() -> void:
	makeLayers()


func _exit_tree() -> void:
	var viewport := get_viewport()
	if viewport != null and viewport.size_changed.is_connected(resizeLayers):
		viewport.size_changed.disconnect(resizeLayers)


func makeLayers() -> void:
	# delete the old layers
	for layer in layers:
		layer.sprite.queue_free()
	layers.clear()

	var sceneryScene = load(scenery)
	if sceneryScene == null:
		return
	var sceneryCopy = sceneryScene.instantiate()

	# copy every Parallax2D layer from the scenery
	for parallax in sceneryCopy.find_children("*", "Parallax2D", true, false):
		var sprites = parallax.find_children("*", "Sprite2D", false, false)
		if sprites.size() == 0 or sprites[0].texture == null:
			continue
		var original = sprites[0]

		var sprite = Sprite2D.new()
		sprite.texture = original.texture
		sprite.centered = false
		sprite.region_enabled = true
		sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED # so it can scroll forever
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(sprite)

		layers.append({
			"sprite": sprite,
			"parallax": parallax.scroll_scale.x,
			# autoscroll is in the scenery's scaled pixels, so divide by its scale
			"speed": parallax.autoscroll.x / abs(original.scale.x),
			"drift": 0.0,
		})

	sceneryCopy.free()
	resizeLayers()


func resizeLayers() -> void:
	var viewport := get_viewport()
	if viewport == null or layers.is_empty():
		return
	var screenSize = viewport.get_visible_rect().size
	var pictureSize = layers[0].sprite.texture.get_size()

	# smallest whole number scale that fills the screen's height
	pixelScale = max(1, ceil(screenSize.y / pictureSize.y))

	for layer in layers:
		layer.sprite.scale = Vector2(pixelScale, pixelScale)
		# line the bottom of the picture up with the bottom of the screen
		layer.sprite.position = Vector2(0, screenSize.y - pictureSize.y * pixelScale)

	scrollLayers(0.0)


func _process(delta: float) -> void:
	scrollLayers(delta)


func scrollLayers(delta: float) -> void:
	var viewport := get_viewport()
	if viewport == null:
		return
	var screenSize = viewport.get_visible_rect().size

	# how far the camera has moved (in screen pixels)
	var cameraX = 0.0
	if not Engine.is_editor_hint():
		var camera = viewport.get_camera_2d()
		if camera:
			cameraX = camera.get_screen_center_position().x * camera.zoom.x

	for layer in layers:
		layer.drift += layer.speed * delta
		var x = (cameraX * layer.parallax) / pixelScale - layer.drift
		var height = layer.sprite.texture.get_height()
		layer.sprite.region_rect = Rect2(floor(x), 0, ceil(screenSize.x / pixelScale) + 1, height)
