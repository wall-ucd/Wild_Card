extends Node2D
## Asset showcase controller (TEST ONLY - nothing in the game references this).
## Run asset_showcase.tscn with F6 ("Run Current Scene"). Main scene / project settings are untouched.
##
## Uses raw keys/mouse instead of the project's Input Map so it does not depend on
## or add to the shared input actions.
##
## Controls:
##   WASD / arrows ....... pan camera          Mouse wheel / + - .. zoom
##   Left-drag / Middle-drag pan               Left click sprite .. next animation
##   Right click sprite .. previous animation  N / P .............. next / prev animation on ALL
##   Space ............... pause / resume      R .................. reset all animations
##   Home / 0 ............ reset camera        H .................. toggle help
##   C ................... next colour on every diorama creature (or use its Color button)

const PAN_SPEED := 900.0
const ZOOM_MIN := 0.15
const ZOOM_MAX := 6.0

@onready var _camera: Camera2D = $Camera2D
@onready var _help: Control = $HUD/Help

var _start_cam_pos: Vector2
var _start_zoom: Vector2
var _paused := false
var _dragging := false
var _drag_moved := false
var _drag_start := Vector2.ZERO


func _ready() -> void:
	_start_cam_pos = _camera.position
	_start_zoom = _camera.zoom


func _entries() -> Array[Node]:
	return get_tree().get_nodes_in_group(&"showcase_entry")


func _process(delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		dir.x -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		dir.x += 1
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		dir.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		dir.y += 1
	if dir != Vector2.ZERO:
		var fast := 2.5 if Input.is_physical_key_pressed(KEY_SHIFT) else 1.0
		_camera.position += dir.normalized() * PAN_SPEED * fast * delta / _camera.zoom.x


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion and _dragging:
		if event.position.distance_to(_drag_start) > 4.0:
			_drag_moved = true
		if _drag_moved:
			_camera.position -= event.relative / _camera.zoom.x
	elif event is InputEventKey and event.pressed and not event.echo:
		_handle_key(event)


func _handle_mouse_button(e: InputEventMouseButton) -> void:
	match e.button_index:
		MOUSE_BUTTON_WHEEL_UP:
			if e.pressed:
				_zoom_at(1.15, e.position)
		MOUSE_BUTTON_WHEEL_DOWN:
			if e.pressed:
				_zoom_at(1.0 / 1.15, e.position)
		MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MIDDLE:
			if e.pressed:
				_dragging = true
				_drag_moved = e.button_index == MOUSE_BUTTON_MIDDLE
				_drag_start = e.position
			else:
				if e.button_index == MOUSE_BUTTON_LEFT and not _drag_moved:
					_click(1)
				_dragging = false
		MOUSE_BUTTON_RIGHT:
			if e.pressed:
				_click(-1)


func _handle_key(e: InputEventKey) -> void:
	match e.physical_keycode:
		KEY_N:
			for n in _entries():
				n.step_animation(1)
		KEY_P:
			for n in _entries():
				n.step_animation(-1)
		KEY_R:
			for n in _entries():
				n.reset_animation()
		KEY_C:
			for n in _entries():
				if n.has_method(&"step_variant"):
					n.step_variant(1)
		KEY_SPACE:
			_paused = not _paused
			for n in _entries():
				n.set_paused(_paused)
			for n in get_tree().get_nodes_in_group(&"showcase_parallax"):
				n.set_paused(_paused)
		KEY_HOME, KEY_0:
			_camera.position = _start_cam_pos
			_camera.zoom = _start_zoom
		KEY_EQUAL, KEY_KP_ADD:
			_zoom_at(1.25, get_viewport().get_visible_rect().size * 0.5)
		KEY_MINUS, KEY_KP_SUBTRACT:
			_zoom_at(0.8, get_viewport().get_visible_rect().size * 0.5)
		KEY_H:
			_help.visible = not _help.visible


func _click(step: int) -> void:
	var p := get_global_mouse_position()
	for n in _entries():
		if n.contains_global_point(p):
			n.step_animation(step)
			return


func _zoom_at(factor: float, screen_pos: Vector2) -> void:
	# Camera2D is centred (default anchor), so world = cam_pos + (screen - half_view) / zoom.
	var offset := screen_pos - get_viewport().get_visible_rect().size * 0.5
	var before := _camera.position + offset / _camera.zoom.x
	var z := clampf(_camera.zoom.x * factor, ZOOM_MIN, ZOOM_MAX)
	_camera.zoom = Vector2(z, z)
	_camera.position = before - offset / z
