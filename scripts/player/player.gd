class_name DavePlayer
extends CharacterBody3D

signal health_changed(current: float, maximum: float)
signal dash_changed(available: bool)
signal died
signal shot

const VisualFactory = preload("res://scripts/core/visual_factory.gd")
const ProjectileScript = preload("res://scripts/entities/projectile.gd")

const MOVE_SPEED := 5.4
const DASH_SPEED := 13.5
const DASH_DURATION := 0.19
const DASH_COOLDOWN := 1.05
const FIRE_INTERVAL := 0.21

var max_health := 100.0
var health := 100.0
var can_control := true
var aim_direction := Vector3(0.0, 0.0, -1.0)
var camera: Camera3D
var projectile_parent: Node

var _fire_cooldown := 0.0
var _dash_time := 0.0
var _dash_cooldown := 0.0
var _dash_direction := Vector3.ZERO
var _invulnerable_time := 0.0
var _visual_root: Node3D


func setup(game_camera: Camera3D, projectile_container: Node) -> void:
	camera = game_camera
	projectile_parent = projectile_container


func _ready() -> void:
	name = "Dave"
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	_ensure_inputs()

	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.42
	shape.height = 1.55
	collision.shape = shape
	collision.position.y = 0.8
	add_child(collision)

	_build_visuals()
	health_changed.emit(health, max_health)
	dash_changed.emit(true)


func _physics_process(delta: float) -> void:
	_fire_cooldown = maxf(0.0, _fire_cooldown - delta)
	_dash_cooldown = maxf(0.0, _dash_cooldown - delta)
	_invulnerable_time = maxf(0.0, _invulnerable_time - delta)

	if not can_control:
		velocity = Vector3.ZERO
		return

	var input_vector := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)
	var move_direction := Vector3(input_vector.x, 0.0, input_vector.y)
	if move_direction.length_squared() > 1.0:
		move_direction = move_direction.normalized()

	if Input.is_action_just_pressed("dash") and _dash_cooldown <= 0.0:
		var requested_direction := move_direction if move_direction.length_squared() > 0.01 else aim_direction
		_start_dash(requested_direction)

	if _dash_time > 0.0:
		_dash_time -= delta
		velocity = _dash_direction * DASH_SPEED
	else:
		velocity = move_direction * MOVE_SPEED

	move_and_slide()
	global_position.x = clampf(global_position.x, -10.8, 10.8)
	global_position.z = clampf(global_position.z, -7.7, 7.7)

	_update_aim()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_try_fire()

	if _dash_cooldown <= 0.0:
		dash_changed.emit(true)


func take_damage(amount: float) -> void:
	if not can_control or _invulnerable_time > 0.0:
		return
	health = maxf(0.0, health - amount)
	_invulnerable_time = 0.35
	health_changed.emit(health, max_health)
	_pulse_damage()
	if health <= 0.0:
		can_control = false
		died.emit()


func heal(amount: float) -> void:
	health = minf(max_health, health + amount)
	health_changed.emit(health, max_health)


func debug_fire() -> void:
	_fire_cooldown = 0.0
	_try_fire()


func _update_aim() -> void:
	if not is_instance_valid(camera):
		return
	var mouse_position := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_position)
	var ray_direction := camera.project_ray_normal(mouse_position)
	var floor_plane := Plane(Vector3.UP, 0.75)
	var intersection: Variant = floor_plane.intersects_ray(ray_origin, ray_direction)
	if intersection is Vector3:
		var flat_direction: Vector3 = intersection - global_position
		flat_direction.y = 0.0
		if flat_direction.length_squared() > 0.05:
			aim_direction = flat_direction.normalized()
			look_at(global_position + aim_direction, Vector3.UP)


func _try_fire() -> void:
	if _fire_cooldown > 0.0 or not is_instance_valid(projectile_parent):
		return
	_fire_cooldown = FIRE_INTERVAL
	var projectile := ProjectileScript.new()
	projectile.setup(aim_direction, 12.0)
	projectile_parent.add_child(projectile)
	projectile.global_position = global_position + Vector3.UP * 0.82 + aim_direction * 0.9
	shot.emit()
	_pulse_weapon()


func _start_dash(direction: Vector3) -> void:
	if direction.length_squared() < 0.01:
		return
	_dash_direction = direction.normalized()
	_dash_time = DASH_DURATION
	_dash_cooldown = DASH_COOLDOWN
	_invulnerable_time = DASH_DURATION + 0.05
	dash_changed.emit(false)


func _build_visuals() -> void:
	_visual_root = Node3D.new()
	_visual_root.name = "DaveVisual"
	add_child(_visual_root)

	VisualFactory.add_capsule(
		_visual_root,
		"Body",
		0.42,
		1.28,
		Vector3(0.0, 0.78, 0.0),
		Color("#d56e35")
	)
	VisualFactory.add_sphere(
		_visual_root,
		"Head",
		0.4,
		Vector3(0.0, 1.58, -0.02),
		Color("#f1bd87")
	)
	VisualFactory.add_cylinder(
		_visual_root,
		"HatBrim",
		0.64,
		0.12,
		Vector3(0.0, 1.92, 0.0),
		Color("#f2d16b")
	)
	VisualFactory.add_cylinder(
		_visual_root,
		"HatTop",
		0.39,
		0.42,
		Vector3(0.0, 2.12, 0.0),
		Color("#e8be51")
	)
	VisualFactory.add_box(
		_visual_root,
		"PeaBlaster",
		Vector3(0.26, 0.26, 1.0),
		Vector3(0.42, 1.02, -0.48),
		Color("#4f9f52")
	)
	VisualFactory.add_sphere(
		_visual_root,
		"Muzzle",
		0.22,
		Vector3(0.42, 1.02, -1.0),
		Color("#8fda55"),
		Vector3(1.0, 1.0, 0.72)
	)


func _pulse_weapon() -> void:
	if not is_instance_valid(_visual_root):
		return
	var weapon := _visual_root.get_node_or_null("PeaBlaster")
	if weapon == null:
		return
	var tween := create_tween()
	tween.tween_property(weapon, "scale:z", 0.72, 0.035)
	tween.tween_property(weapon, "scale:z", 1.0, 0.07)


func _pulse_damage() -> void:
	if not is_instance_valid(_visual_root):
		return
	var tween := create_tween()
	tween.tween_property(_visual_root, "scale", Vector3(1.12, 0.88, 1.12), 0.055)
	tween.tween_property(_visual_root, "scale", Vector3.ONE, 0.11)


func _ensure_inputs() -> void:
	_add_key_action("move_forward", KEY_W)
	_add_key_action("move_forward", KEY_UP)
	_add_key_action("move_back", KEY_S)
	_add_key_action("move_back", KEY_DOWN)
	_add_key_action("move_left", KEY_A)
	_add_key_action("move_left", KEY_LEFT)
	_add_key_action("move_right", KEY_D)
	_add_key_action("move_right", KEY_RIGHT)
	_add_key_action("dash", KEY_SPACE)
	_add_key_action("dash", KEY_SHIFT)
	_add_key_action("restart", KEY_R)


func _add_key_action(action_name: StringName, key_code: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for existing_event in InputMap.action_get_events(action_name):
		if existing_event is InputEventKey and existing_event.physical_keycode == key_code:
			return
	var event := InputEventKey.new()
	event.physical_keycode = key_code
	InputMap.action_add_event(action_name, event)
