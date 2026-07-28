extends SceneTree

var checks := 0
var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed_scene := load("res://scenes/game/main.tscn") as PackedScene
	_check(packed_scene != null, "main scene loads")
	if packed_scene == null:
		_finish()
		return

	var game := packed_scene.instantiate()
	game.test_mode = true
	root.add_child(game)
	await process_frame
	await process_frame

	_check(game.player != null, "player is created")
	_check(game.garden_core != null, "garden core is created")
	_check(game.game_camera != null, "isometric camera is created")
	_check(game.hud != null, "HUD is created")
	_check(game.wave_director != null, "wave director is created")
	_check(game.player.health == 100.0, "player starts at full health")
	_check(game.garden_core.health == 220.0, "garden starts at full health")
	_check(game.wave_director.get_wave_count() == 3, "three waves are configured")
	_check(game.wave_director.get_total_enemy_count() == 26, "wave roster has 26 enemies")
	_check(InputMap.has_action("move_forward"), "move input is registered")
	_check(InputMap.has_action("dash"), "dash input is registered")
	_check(InputMap.has_action("restart"), "restart input is registered")

	var original_player_health: float = game.player.health
	game.player.take_damage(9.0)
	_check(game.player.health == original_player_health - 9.0, "player damage is applied")
	game.player.heal(9.0)
	_check(game.player.health == original_player_health, "player healing is applied")

	var original_core_health: float = game.garden_core.health
	game.garden_core.take_damage(12.0)
	_check(game.garden_core.health == original_core_health - 12.0, "garden damage is applied")
	game.garden_core.restore_full()
	_check(game.garden_core.health == game.garden_core.max_health, "garden can be restored")

	var walker = game.spawn_enemy("walker", 0)
	var runner = game.spawn_enemy("runner", 1)
	var bruiser = game.spawn_enemy("bruiser", 2)
	await process_frame
	_check(get_node_count_in_group("zombies") == 3, "all zombie archetypes spawn")
	_check(runner.move_speed > walker.move_speed, "runner is the fastest zombie")
	_check(bruiser.max_health > walker.max_health, "bruiser is the toughest zombie")
	_check(bruiser.attack_damage > walker.attack_damage, "bruiser hits hardest")

	walker.global_position = game.player.global_position + game.player.aim_direction * 2.2
	game.player.debug_fire()
	await process_frame
	_check(get_node_count_in_group("projectiles") == 1, "pea blaster creates a projectile")
	for _frame in 20:
		await physics_frame
	_check(walker.health < walker.max_health, "pea projectile damages a zombie")

	walker.take_damage(999.0, Vector3.RIGHT)
	await process_frame
	_check(not walker.active, "lethal damage deactivates a zombie")
	_check(game.sunlight == 10, "zombie defeat grants sunlight")

	game._on_all_waves_cleared()
	_check(game.game_over, "clearing all waves finishes the run")
	_check(not game.player.can_control, "player control stops after victory")

	for zombie in get_nodes_in_group("zombies"):
		if is_instance_valid(zombie):
			zombie.queue_free()
	await process_frame
	game.queue_free()
	await process_frame
	_finish()


func _check(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS: %s" % description)
	else:
		failures.append(description)
		push_error("FAIL: %s" % description)


func _finish() -> void:
	if failures.is_empty():
		print("SMOKE TEST RESULT: %d checks passed" % checks)
		quit(0)
	else:
		print("SMOKE TEST RESULT: %d/%d checks failed" % [failures.size(), checks])
		for failure in failures:
			print(" - %s" % failure)
		quit(1)
