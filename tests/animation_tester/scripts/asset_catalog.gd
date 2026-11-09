class_name AssetCatalog
extends RefCounted
## Finds testable assets on disk so the tester never needs a hard-coded list.
##
## Anything dropped into one of the scan folders shows up automatically:
##   *.tscn / *.scn ............ scenes (player, animals, pickups...)
##   *_scenery.tscn ............ backdrops for the Scenery dropdown instead of the Asset dropdown
##   SpriteFrames (.tres) ...... AnimatedSprite2D previews
##   TileSet (.tres) ........... tile palette previews
##
## Other tests in res://tests can reuse this: AssetCatalog.scan(["res://assets"]).

enum Kind { SCENE, SPRITE_FRAMES, TILESET, SCENERY }

const KIND_TITLES := {
	Kind.SCENE: "Scenes",
	Kind.SPRITE_FRAMES: "Sprite frames",
	Kind.TILESET: "Tilesets",
	Kind.SCENERY: "Sceneries",
}

const SCENE_EXTENSIONS := ["tscn", "scn"]
const RESOURCE_EXTENSIONS := ["tres", "res"]
## Folder names that only add noise to a label ("animals/frog/sprite_frames" -> "animals/frog").
const NOISE_FOLDERS := ["sprite_frames", "sprite_sheets", "tiles", "background", "layers"]


class Entry:
	var path: String
	var kind: int
	var label: String

	func _init(p_path: String, p_kind: int, p_label: String) -> void:
		path = p_path
		kind = p_kind
		label = p_label


## Scan `roots` recursively. Paths in `scenery_only` are offered as sceneries but never as assets
## (used for res://scenes/levels so whole levels can be used as a backdrop).
static func scan(roots: PackedStringArray, scenery_only: PackedStringArray = PackedStringArray()) -> Array[Entry]:
	var found: Array[Entry] = []
	for root in roots:
		_scan_dir(root.trim_suffix("/"), root.trim_suffix("/"), scenery_only, found)
	found.sort_custom(func(a: Entry, b: Entry) -> bool:
		if a.kind != b.kind:
			return a.kind < b.kind
		return a.label.naturalnocasecmp_to(b.label) < 0)
	return found


static func _scan_dir(dir: String, root: String, scenery_only: PackedStringArray, out: Array[Entry]) -> void:
	# ResourceLoader.list_directory also works in exported builds (it hides .import/.remap files).
	for item in ResourceLoader.list_directory(dir):
		if item.begins_with("."):
			continue
		var path := dir + "/" + item.trim_suffix("/")
		if item.ends_with("/"):
			_scan_dir(path, root, scenery_only, out)
			continue
		var kind := _classify(path, scenery_only)
		if kind >= 0:
			out.append(Entry.new(path, kind, _make_label(path, root)))


static func _classify(path: String, scenery_only: PackedStringArray) -> int:
	var ext := path.get_extension().to_lower()
	if ext in SCENE_EXTENSIONS:
		for prefix in scenery_only:
			if path.begins_with(prefix):
				return Kind.SCENERY
		return Kind.SCENERY if path.get_basename().ends_with("_scenery") else Kind.SCENE
	if ext in RESOURCE_EXTENSIONS:
		match _resource_type(path):
			"SpriteFrames":
				return Kind.SPRITE_FRAMES
			"TileSet":
				return Kind.TILESET
	return -1


## Read the type from a text resource header without loading it; fall back to loading.
static func _resource_type(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f:
		var header := f.get_line()
		var at := header.find("type=\"")
		if header.begins_with("[gd_resource") and at >= 0:
			var start := at + 6
			return header.substr(start, header.find("\"", start) - start)
	var res := load(path)
	return res.get_class() if res else ""


static func _make_label(path: String, root: String) -> String:
	var rel := path.trim_prefix(root + "/")
	var folders := Array(rel.get_base_dir().split("/", false)).filter(
		func(f: String) -> bool: return not f in NOISE_FOLDERS)
	var where := "/".join(folders)
	if where.is_empty():
		where = root.trim_prefix("res://")
	return "%s   (%s)" % [rel.get_file().get_basename(), where]
