class_name GardenZombie
extends CharacterBody3D

signal died(zombie: Node, kind: String)

const VisualFactory = preload("res://scripts/core/visual_factory.gd")

var kind := "walker"
var player: Node3D
var garden_core: Node3D
var focus_core := true
var max_health := 34.0
var health := 34.0
var move_speed := 2.05
var attack_damage := 8.0
var attack_range := 1.25
var attack_interval := 0.8
var active := true

var _attack_cooldown := 0.0
var _knockback := Vector3.ZERO
var _visual_root: Node3D
var _walk_time := 0.0


func setup(
		zombie_kind: String,
		player_target: Node3D,
		core_target: Node3D,
		should_focus_core: bool
	) -> void:
	kind = zombie_kind
	player = player_target
	garden_core = core_target
	focus_core = should_focus_core
	_apply_stats()


func _ready() -> void:
	name = "Zombie_%s" % kind
	add_to_group("zombies")
	collision_layer = 4
	collision_mask = 1

	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.43 if kind != "bruiser" else 0.58
	shape.height = 1.55 if kind != "bruiser" else 2.0
	collision.shape = shape
	collision.position.y = 0.8 if kind != "bruiser" else 1.0
	add_child(collision)
	_build_visuals()


func _physics_process(delta: float) -> void:
	if not active:
		velocity = Vector3.ZERO
		return
	if not is_instance_valid(player) or not is_instance_valid(garden_core):
		return

	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	_walk_time += delta
	var target := _choose_target()
	var offset := target.global_position - global_position
	offset.y = 0.0
	var distance := offset.length()
	if distance <= attack_range:
		velocity = _knockback
		_try_attack(target)
	else:
		var desired := offset.normalized() * move_speed
		var separation := _get_separation_force()
		velocity = desired + separation + _knockback
		move_and_slide()

	_knockback = _knockback.move_toward(Vector3.ZERO, 12.0 * delta)
	global_position.x = clampf(global_position.x, -11.0, 11.0)
	global_position.z = clampf(global_position.z, -8.0, 8.0)
	if is_instance_valid(_visual_root):
		_visual_root.position.y = sin(_walk_time * 8.0) * 0.045


func take_damage(amount: float, hit_direction: Vector3 = Vector3.ZERO) -> void:
	if not active:
		return
	health = maxf(0.0, health - amount)
	if hit_direction.length_squared() > 0.01:
		_knockback += hit_direction.normalized() * (4.6 if kind != "bruiser" else 2.2)
	_flash_hit()
	if health <= 0.0:
		active = false
		collision_layer = 0
		died.emit(self, kind)
		_play_death()


func _apply_stats() -> void:
	match kind:
		"runner":
			max_health = 24.0
			move_speed = 3.35
			attack_damage = 6.0
			attack_interval = 0.62
			attack_range = 1.12
		"bruiser":
			max_health = 82.0
			move_speed = 1.45
			attack_damage = 16.0
			attack_interval = 1.15
			attack_range = 1.52
		_:
			max_health = 34.0
			move_speed = 2.05
			attack_damage = 8.0
			attack_interval = 0.8
			attack_range = 1.25
	health = max_health


func _choose_target() -> Node3D:
	var player_distance := global_position.distance_to(player.global_position)
	if kind == "runner":
		return player
	if not focus_core or player_distance < 2.5:
		return player
	return garden_core


func _try_attack(target: Node3D) -> void:
	if _attack_cooldown > 0.0:
		return
	_attack_cooldown = attack_interval
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)
	if is_instance_valid(_visual_root):
		var tween := create_tween()
		tween.tween_property(_visual_root, "scale:z", 1.24, 0.08)
		tween.tween_property(_visual_root, "scale:z", 1.0, 0.11)


func _get_separation_force() -> Vector3:
	var result := Vector3.ZERO
	for other in get_tree().get_nodes_in_group("zombies"):
		if other == self or not is_instance_valid(other):
			continue
		var other_zombie := other as Node3D
		var away: Vector3 = global_position - other_zombie.global_position
		away.y = 0.0
		var distance_squared: float = away.length_squared()
		if distance_squared > 0.001 and distance_squared < 0.9:
			result += away.normalized() * (0.9 - sqrt(distance_squared)) * 2.4
	return result


func _build_visuals() -> void:
	_visual_root = Node3D.new()
	_visual_root.name = "ZombieVisual"
	add_child(_visual_root)

	var body_color := Color("#70965a")
	var coat_color := Color("#66536f")
	var scale_factor := 1.0
	if kind == "runner":
		body_color = Color("#8fbc62")
		coat_color = Color("#bf6b45")
	elif kind == "bruiser":
		body_color = Color("#587a55")
		coat_color = Color("#3d5260")
		scale_factor = 1.28

	var body := VisualFactory.add_capsule(
		_visual_root,
		"Body",
		0.4,
		1.25,
		Vector3(0.0, 0.78, 0.0),
		coat_color
	)
	body.scale = Vector3.ONE * scale_factor
	VisualFactory.add_sphere(
		_visual_root,
		"Head",
		0.42 * scale_factor,
		Vector3(0.0, 1.62 * scale_factor, -0.05),
		body_color
	)
	VisualFactory.add_sphere(
		_visual_root,
		"EyeLeft",
		0.07 * scale_factor,
		Vector3(-0.14 * scale_factor, 1.72 * scale_factor, -0.4 * scale_factor),
		Color("#e9ffdd")
	)
	VisualFactory.add_sphere(
		_visual_root,
		"EyeRight",
		0.07 * scale_factor,
		Vector3(0.14 * scale_factor, 1.72 * scale_factor, -0.4 * scale_factor),
		Color("#e9ffdd")
	)
	if kind == "bruiser":
		VisualFactory.add_box(
			_visual_root,
			"Armor",
			Vector3(1.25, 0.62, 0.34),
			Vector3(0.0, 1.03, -0.38),
			Color("#91a6ad")
		)


func _flash_hit() -> void:
	if not is_instance_valid(_visual_root):
		return
	var tween := create_tween()
	tween.tween_property(_visual_root, "scale", Vector3(1.12, 0.88, 1.12), 0.045)
	tween.tween_property(_visual_root, "scale", Vector3.ONE, 0.09)


func _play_death() -> void:
	if not is_instance_valid(_visual_root):
		queue_free()
		return
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_visual_root, "scale", Vector3(1.35, 0.12, 1.35), 0.22)
	tween.tween_property(_visual_root, "rotation:y", rotation.y + 1.5, 0.22)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
