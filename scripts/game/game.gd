class_name GardenRun
extends Node3D

@export var test_mode := false

const VisualFactory = preload("res://scripts/core/visual_factory.gd")
const PlayerScript = preload("res://scripts/player/player.gd")
const ZombieScript = preload("res://scripts/entities/zombie.gd")
const CoreScript = preload("res://scripts/entities/garden_core.gd")
const CameraScript = preload("res://scripts/game/camera_follow.gd")
const WaveDirectorScript = preload("res://scripts/game/wave_director.gd")
const HUDScript = preload("res://scripts/ui/hud.gd")

var player: DavePlayer
var garden_core: GardenCore
var game_camera: GardenCamera
var wave_director: WaveDirector
var hud: GardenHUD
var sunlight := 0
var game_over := false

var _spawn_positions := [
	Vector3(-10.4, 0.0, -6.4),
	Vector3(10.4, 0.0, -6.4),
	Vector3(-10.4, 0.0, 6.4),
	Vector3(10.4, 0.0, 6.4),
]


func _ready() -> void:
	name = "GardenRun"
	_build_environment()
	_build_arena()
	_build_camera()
	_build_garden_core()
	_build_player()
	_build_hud()
	_build_wave_director()
	if not test_mode:
		hud.show_intro()
		wave_director.start()


func _process(_delta: float) -> void:
	if is_instance_valid(hud):
		hud.set_enemy_count(get_tree().get_node_count_in_group("zombies"))
	if InputMap.has_action("restart") and Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()


func spawn_enemy(kind: String, spawn_slot: int = 0) -> GardenZombie:
	var zombie := ZombieScript.new()
	var core_focused := kind != "runner" and ((sunlight / 10 + spawn_slot) % 3 != 0)
	zombie.setup(kind, player, garden_core, core_focused)
	add_child(zombie)
	var spawn_position: Vector3 = _spawn_positions[spawn_slot % _spawn_positions.size()]
	var jitter := Vector3(
		randf_range(-0.65, 0.65),
		0.0,
		randf_range(-0.65, 0.65)
	)
	zombie.global_position = spawn_position + jitter
	zombie.died.connect(_on_zombie_died)
	return zombie


func _build_environment() -> void:
	var world := WorldEnvironment.new()
	world.name = "WorldEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#92bdc1")
	environment.background_energy_multiplier = 0.82
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#b8d1c8")
	environment.ambient_light_energy = 0.78
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_BG
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = environment
	add_child(world)

	var sunlight_node := DirectionalLight3D.new()
	sunlight_node.name = "Sunlight"
	sunlight_node.rotation_degrees = Vector3(-53.0, -36.0, 0.0)
	sunlight_node.light_color = Color("#fff2ce")
	sunlight_node.light_energy = 1.25
	sunlight_node.shadow_enabled = true
	sunlight_node.directional_shadow_max_distance = 42.0
	add_child(sunlight_node)


func _build_arena() -> void:
	var arena := Node3D.new()
	arena.name = "FloatingGardenArena"
	add_child(arena)

	VisualFactory.add_box(
		arena,
		"IslandCliff",
		Vector3(25.0, 1.7, 19.0),
		Vector3(0.0, -1.05, 0.0),
		Color("#4e493c")
	)
	VisualFactory.add_box(
		arena,
		"GrassTop",
		Vector3(24.0, 0.48, 18.0),
		Vector3(0.0, -0.24, 0.0),
		Color("#5f9f58")
	)
	VisualFactory.add_box(
		arena,
		"BattleGround",
		Vector3(14.0, 0.08, 10.5),
		Vector3(0.0, 0.03, 0.0),
		Color("#759f62")
	)

	var floor_body := StaticBody3D.new()
	floor_body.name = "ArenaFloorCollision"
	floor_body.collision_layer = 1
	floor_body.collision_mask = 0
	var floor_collision := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(24.0, 0.6, 18.0)
	floor_collision.shape = floor_shape
	floor_collision.position = Vector3(0.0, -0.3, 0.0)
	floor_body.add_child(floor_collision)
	arena.add_child(floor_body)

	var rock_color := Color("#71806b")
	for rock_data in [
		[Vector3(-10.9, 0.15, -7.7), Vector3(2.0, 0.7, 1.2)],
		[Vector3(-7.8, 0.1, -8.2), Vector3(2.7, 0.6, 0.8)],
		[Vector3(9.8, 0.15, -8.0), Vector3(3.1, 0.7, 0.9)],
		[Vector3(-10.2, 0.15, 7.9), Vector3(3.0, 0.7, 0.9)],
		[Vector3(8.6, 0.1, 8.1), Vector3(3.9, 0.6, 0.8)],
	]:
		VisualFactory.add_box(
			arena,
			"BorderRock",
			rock_data[1],
			rock_data[0],
			rock_color
		)

	_build_entry_bridge(arena, Vector3(-10.2, 0.05, -6.2), 0.0)
	_build_entry_bridge(arena, Vector3(10.2, 0.05, -6.2), 0.0)
	_build_entry_bridge(arena, Vector3(-10.2, 0.05, 6.2), 0.0)
	_build_entry_bridge(arena, Vector3(10.2, 0.05, 6.2), 0.0)

	for tree_position in [
		Vector3(-8.8, 0.0, -4.2),
		Vector3(8.7, 0.0, -4.8),
		Vector3(-8.9, 0.0, 4.3),
		Vector3(8.9, 0.0, 4.7),
	]:
		_build_tree(arena, tree_position)

	for lantern_position in [
		Vector3(-5.8, 0.0, -4.5),
		Vector3(5.8, 0.0, -4.5),
		Vector3(-5.8, 0.0, 4.5),
		Vector3(5.8, 0.0, 4.5),
	]:
		_build_lantern(arena, lantern_position)


func _build_entry_bridge(parent: Node3D, origin: Vector3, rotation_y: float) -> void:
	var bridge := Node3D.new()
	bridge.name = "StoneBridge"
	bridge.position = origin
	bridge.rotation.y = rotation_y
	parent.add_child(bridge)
	for index in 4:
		var x_offset := (float(index) - 1.5) * 0.86
		VisualFactory.add_box(
			bridge,
			"BridgeStone%d" % index,
			Vector3(0.76, 0.22, 2.15),
			Vector3(x_offset, 0.0, 0.0),
			Color("#9da28b")
		)


func _build_tree(parent: Node3D, tree_position: Vector3) -> void:
	var tree := Node3D.new()
	tree.name = "GardenTree"
	tree.position = tree_position
	parent.add_child(tree)
	VisualFactory.add_cylinder(
		tree,
		"Trunk",
		0.26,
		2.0,
		Vector3(0.0, 1.0, 0.0),
		Color("#5b4533")
	)
	VisualFactory.add_sphere(
		tree,
		"Crown",
		1.15,
		Vector3(0.0, 2.35, 0.0),
		Color("#376b46"),
		Vector3(1.2, 0.9, 1.05)
	)
	VisualFactory.add_sphere(
		tree,
		"CrownAccent",
		0.72,
		Vector3(0.65, 2.18, 0.18),
		Color("#4f8550")
	)


func _build_lantern(parent: Node3D, lantern_position: Vector3) -> void:
	var lantern := Node3D.new()
	lantern.name = "SunLantern"
	lantern.position = lantern_position
	parent.add_child(lantern)
	VisualFactory.add_cylinder(
		lantern,
		"Post",
		0.09,
		1.25,
		Vector3(0.0, 0.62, 0.0),
		Color("#3c5144")
	)
	var glow_material := VisualFactory.make_material(
		Color("#ffc95f"),
		Color(1.0, 0.45, 0.08, 1.0)
	)
	VisualFactory.add_sphere(
		lantern,
		"Glow",
		0.17,
		Vector3(0.0, 1.32, 0.0),
		Color("#ffc95f"),
		Vector3.ONE,
		glow_material
	)


func _build_camera() -> void:
	game_camera = CameraScript.new()
	game_camera.name = "GameCamera"
	add_child(game_camera)
	game_camera.global_position = game_camera.offset


func _build_garden_core() -> void:
	garden_core = CoreScript.new()
	add_child(garden_core)
	garden_core.global_position = Vector3.ZERO
	garden_core.destroyed.connect(_on_core_destroyed)


func _build_player() -> void:
	player = PlayerScript.new()
	add_child(player)
	player.global_position = Vector3(0.0, 0.0, 4.8)
	player.setup(game_camera, self)
	player.died.connect(_on_player_died)
	game_camera.target = player


func _build_hud() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "HUDLayer"
	canvas.layer = 10
	add_child(canvas)
	hud = HUDScript.new()
	canvas.add_child(hud)
	player.health_changed.connect(hud.set_dave_health)
	player.dash_changed.connect(hud.set_dash_available)
	garden_core.health_changed.connect(hud.set_core_health)
	hud.set_dave_health(player.health, player.max_health)
	hud.set_core_health(garden_core.health, garden_core.max_health)
	hud.set_sun(sunlight)


func _build_wave_director() -> void:
	wave_director = WaveDirectorScript.new()
	wave_director.name = "WaveDirector"
	add_child(wave_director)
	wave_director.spawn_requested.connect(spawn_enemy)
	wave_director.wave_started.connect(hud.set_wave)
	wave_director.countdown_changed.connect(hud.set_countdown)
	wave_director.state_changed.connect(hud.set_state)
	wave_director.all_waves_cleared.connect(_on_all_waves_cleared)


func _on_zombie_died(_zombie: Node, kind: String) -> void:
	var reward := 20 if kind == "bruiser" else 10
	sunlight += reward
	hud.set_sun(sunlight)


func _on_player_died() -> void:
	_finish_run(false)


func _on_core_destroyed() -> void:
	_finish_run(false)


func _on_all_waves_cleared() -> void:
	_finish_run(true)


func _finish_run(victory: bool) -> void:
	if game_over:
		return
	game_over = true
	wave_director.stop()
	player.can_control = false
	for zombie in get_tree().get_nodes_in_group("zombies"):
		if is_instance_valid(zombie):
			zombie.active = false
	hud.show_game_over(victory)
