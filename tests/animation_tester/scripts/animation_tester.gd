extends Node2D
## Animation tester.
## Open res://tests/animation_tester/animation_tester.tscn and press F6 (Run Current Scene).
##
## 1. Asset ...... any scene / SpriteFrames / TileSet found under SCAN_ROOTS.
## 2. Animation .. every animation that asset has.
## 3. Scenery .... any *_scenery.tscn, any level in res://scenes/levels, or a blank grid.
## Pause, step a frame back/forward, and zoom (buttons or mouse wheel).
##
## Nothing in the game references this. To make something show up, just put it in res://assets
## (or res://scenes). Scenery scenes are picked up by the "_scenery.tscn" suffix and may contain
## a Marker2D called "SpawnPoint" (where the asset stands).

const SCAN_ROOTS: PackedStringArray = ["res://assets", "res://scenes"]
const SCENERY_ONLY: PackedStringArray = ["res://scenes/levels"]  ## Levels: scenery dropdown only.
const DEFAULT_ASSET := "res://scenes/player.tscn"
const DEFAULT_SCENERY := "res://assets/environments/seasonal/grassland/grassland_scenery.tscn"
const BlankScenery := preload("res://tests/animation_tester/scripts/blank_scenery.gd")

const ZOOM_DEFAULT := 1.5
const ZOOM_MIN := 0.25
const ZOOM_MAX := 8.0
const ZOOM_STEP := 1.25
const CAMERA_LIFT := Vector2(0, -90)  ## Look a bit above the feet.

@onready var _scenery_holder: Node2D = $World/SceneryHolder
@onready var _preview_holder: Node2D = $World/PreviewHolder
@onready var _camera: Camera2D = $Camera2D
@onready var _asset_select: OptionButton = %AssetSelect
@onready var _anim_select: OptionButton = %AnimSelect
@onready var _scenery_select: OptionButton = %ScenerySelect
@onready var _play_pause: Button = %PlayPause
@onready var _prev_frame: Button = %PrevFrame
@onready var _next_frame: Button = %NextFrame
@onready var _zoom_out: Button = %ZoomOut
@onready var _zoom_in: Button = %ZoomIn

var _entries: Array[AssetCatalog.Entry] = []
var _preview: AssetPreview
var _scenery: Node2D
var _spawn := Vector2.ZERO


func _ready() -> void:
	_camera.zoom = Vector2.ONE * ZOOM_DEFAULT
	_asset_select.item_selected.connect(func(_i: int) -> void: _on_asset_selected())
	_anim_select.item_selected.connect(_on_animation_selected)
	_scenery_select.item_selected.connect(func(_i: int) -> void: _on_scenery_selected())
	_play_pause.pressed.connect(_toggle_pause)
	_prev_frame.pressed.connect(_step_frame.bind(-1))
	_next_frame.pressed.connect(_step_frame.bind(1))
	_zoom_out.pressed.connect(_zoom.bind(1.0 / ZOOM_STEP))
	_zoom_in.pressed.connect(_zoom.bind(ZOOM_STEP))

	_entries = AssetCatalog.scan(SCAN_ROOTS, SCENERY_ONLY)
	_fill_scenery_list()
	_fill_asset_list()


# ---------------------------------------------------------------- lists ----

func _fill_asset_list() -> void:
	_asset_select.clear()
	var last_kind := -1
	for e in _entries:
		if e.kind == AssetCatalog.Kind.SCENERY:
			continue
		if e.kind != last_kind:
			_asset_select.add_separator(AssetCatalog.KIND_TITLES[e.kind])
			last_kind = e.kind
		_asset_select.add_item(e.label)
		var idx := _asset_select.item_count - 1
		_asset_select.set_item_metadata(idx, e.path)
		_asset_select.set_item_tooltip(idx, e.path)
	var index := _find_item(_asset_select, DEFAULT_ASSET)
	if index < 0:
		index = _first_selectable(_asset_select)
	if index >= 0:
		_asset_select.select(index)
		_on_asset_selected()


func _fill_scenery_list() -> void:
	_scenery_select.clear()
	_scenery_select.add_item("Blank grid")
	_scenery_select.set_item_metadata(0, "")
	for e in _entries:
		if e.kind == AssetCatalog.Kind.SCENERY:
			_scenery_select.add_item(e.label.replace("_scenery", ""))
			var idx := _scenery_select.item_count - 1
			_scenery_select.set_item_metadata(idx, e.path)
			_scenery_select.set_item_tooltip(idx, e.path)
	_scenery_select.select(maxi(_find_item(_scenery_select, DEFAULT_SCENERY), 0))
	_on_scenery_selected()


func _find_item(select: OptionButton, path: String) -> int:
	for i in select.item_count:
		if not select.is_item_separator(i) and select.get_item_metadata(i) == path:
			return i
	return -1


func _first_selectable(select: OptionButton) -> int:
	for i in select.item_count:
		if not select.is_item_separator(i):
			return i
	return -1


func _entry_for(path: String) -> AssetCatalog.Entry:
	for e in _entries:
		if e.path == path:
			return e
	return null


# ------------------------------------------------------------- selection ----

func _on_asset_selected() -> void:
	var i := _asset_select.selected
	if i < 0 or _asset_select.is_item_separator(i):
		return
	var entry := _entry_for(_asset_select.get_item_metadata(i))
	if entry == null:
		return
	if _preview:
		_preview_holder.remove_child(_preview)
		_preview.queue_free()
	_preview = AssetPreview.create(entry)
	_preview.position = _spawn
	_preview_holder.add_child(_preview)

	_anim_select.clear()
	var names := _preview.get_animation_names()
	for n in names:
		_anim_select.add_item(n)
	if names.is_empty():
		_anim_select.add_item("(no animations)")
	for control in [_anim_select, _play_pause, _prev_frame, _next_frame]:
		control.disabled = names.is_empty()
	_update_pause_button()


func _on_animation_selected(index: int) -> void:
	if _preview and not _anim_select.disabled:
		_preview.play(_anim_select.get_item_text(index))


func _on_scenery_selected() -> void:
	var path: String = _scenery_select.get_item_metadata(_scenery_select.selected)
	if _scenery:
		_scenery_holder.remove_child(_scenery)
		_scenery.queue_free()
	_scenery = null
	if not path.is_empty():
		var packed := load(path) as PackedScene
		if packed:
			_scenery = packed.instantiate() as Node2D
	if _scenery == null:
		_scenery = BlankScenery.new()
	_scenery_holder.add_child(_scenery)
	var marker := _scenery.find_child("SpawnPoint", true, false) as Node2D
	_spawn = marker.global_position if marker else Vector2.ZERO
	if _preview:
		_preview.position = _spawn
	_camera.position = _spawn + CAMERA_LIFT
	_camera.reset_smoothing()


# -------------------------------------------------------------- controls ----

func _toggle_pause() -> void:
	if _preview:
		_preview.set_paused(not _preview.is_paused())
		_update_pause_button()


func _step_frame(direction: int) -> void:
	if _preview:
		_preview.step_frame(direction)
		_update_pause_button()


func _update_pause_button() -> void:
	_play_pause.text = "Play" if _preview and _preview.is_paused() else "Pause"


func _zoom(factor: float) -> void:
	_camera.zoom = Vector2.ONE * clampf(_camera.zoom.x * factor, ZOOM_MIN, ZOOM_MAX)


func _unhandled_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb and mb.pressed:
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(1.15)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(1.0 / 1.15)
