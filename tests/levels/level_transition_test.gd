extends SceneTree

# Run: godot --headless --path . --script res://tests/levels/level_transition_test.gd --quit-after 600
func _initialize() -> void:
	call_deferred("_test_transitions")

func _test_transitions() -> void:
	var world = load("res://world.tscn").instantiate()
	root.add_child(world)
	await _frames(3)
	var player = world.get_node("Player")
	assert(world.current_level.name == "TutorialLevel")
	assert(world.get_node("LevelContainer").get_child_count() == 1)
	var coin = world.current_level.get_node("Coin")
	assert(coin.find_children("*", "CollisionShape2D", true, false).size() == 1)
	player.global_position = coin.global_position
	player.velocity = Vector2.ZERO
	await _frames(10)
	assert(world.current_level.name == "Level1")
	assert(world.get_node("LevelContainer").get_child_count() == 1)
	assert(player._last_teleported_position == world.current_level.get_node("SpawnPoint").global_position)
	assert(world.get_node("Camera2D").global_position == world.current_level.get_node("SpawnPoint/CameraPosition").global_position)
	# Force an absent destination so the fallback remains testable after Level2 exists.
	coin = world.current_level.get_node("Coin")
	coin.next_level = "res://tests/levels/missing_destination.tscn"
	assert(not ResourceLoader.exists(coin.next_level))
	player.global_position = coin.global_position
	player.velocity = Vector2.ZERO
	await _frames(10)
	assert(world.current_level.name == "TestLevel")
	assert(world.get_node("LevelContainer").get_child_count() == 1)
	assert(world.current_level.find_children("*", "CanvasLayer", true, false).size() == 1)
	await _frames(40)
	assert(player.is_on_floor())
	var checkpoint: Vector2 = player._last_teleported_position
	player.take_damage()
	await _frames(3)
	assert(player.global_position.distance_to(checkpoint) < 5)
	world.get_node("BackgroundMusic").stop()
	player.get_node("TakeDamageSound").stop()
	await _frames(3)
	world.queue_free()
	await _frames(6)
	print("PASS: coin transitions, missing-level fallback, one active level/background, camera and checkpoint, respawn")
	quit()

func _frames(count: int) -> void:
	for i in range(count):
		await physics_frame
