extends Node2D
## Neutral backdrop for the tester: a grid (one cell = one 16px tile at the game's 2x scale)
## with a floor line at y = 0 where the asset stands.

const CELL := 32.0
const HALF_WIDTH := 1600.0
const HEIGHT := 900.0
const FLOOR_THICKNESS := 64.0


func _ready() -> void:
	name = "BlankScenery"
	var spawn := Marker2D.new()
	spawn.name = "SpawnPoint"
	add_child(spawn)


func _draw() -> void:
	draw_rect(Rect2(-HALF_WIDTH, -HEIGHT, HALF_WIDTH * 2.0, HEIGHT), Color(0.16, 0.17, 0.21))
	var line := Color(1, 1, 1, 0.06)
	var x := -HALF_WIDTH
	while x <= HALF_WIDTH:
		draw_line(Vector2(x, -HEIGHT), Vector2(x, 0), line)
		x += CELL
	var y := 0.0
	while y >= -HEIGHT:
		draw_line(Vector2(-HALF_WIDTH, y), Vector2(HALF_WIDTH, y), line)
		y -= CELL
	draw_rect(Rect2(-HALF_WIDTH, 0, HALF_WIDTH * 2.0, FLOOR_THICKNESS), Color(0.3, 0.32, 0.38))
	draw_line(Vector2(-HALF_WIDTH, 0), Vector2(HALF_WIDTH, 0), Color(0.55, 0.8, 1.0, 0.8), 2.0)
