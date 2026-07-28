class_name PeaProjectile
extends Area3D

const VisualFactory = preload("res://scripts/core/visual_factory.gd")

var direction := Vector3.FORWARD
var speed := 18.0
var damage := 12.0
var lifetime := 2.2
var _hit := false


func setup(new_direction: Vector3, new_damage: float = 12.0) -> void:
	direction = new_direction.normalized()
	damage = new_damage


func _ready() -> void:
	name = "PeaProjectile"
	add_to_group("projectiles")
	collision_layer = 8
	collision_mask = 4
	monitoring = true
	monitorable = false

	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.2
	collision.shape = shape
	add_child(collision)

	var pea_material := VisualFactory.make_material(
		Color("#8fe04f"),
		Color(0.2, 1.0, 0.08, 1.0),
		0.42
	)
	VisualFactory.add_sphere(
		self,
		"Pea",
		0.22,
		Vector3.ZERO,
		Color("#8fe04f"),
		Vector3.ONE,
		pea_material
	)

	var glow := OmniLight3D.new()
	glow.name = "PeaGlow"
	glow.light_color = Color("#8fe04f")
	glow.light_energy = 1.2
	glow.omni_range = 2.5
	glow.shadow_enabled = false
	add_child(glow)

	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if _hit:
		return
	global_position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	if _hit or not body.is_in_group("zombies"):
		return
	_hit = true
	if body.has_method("take_damage"):
		body.take_damage(damage, direction)
	_spawn_hit_flash()
	queue_free()


func _spawn_hit_flash() -> void:
	var flash := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.35
	mesh.height = 0.7
	flash.mesh = mesh
	flash.material_override = VisualFactory.make_material(
		Color("#e9ffc9"),
		Color(0.55, 1.0, 0.25, 1.0)
	)
	var flash_parent := get_parent()
	if flash_parent == null:
		flash_parent = get_tree().current_scene
	if flash_parent == null:
		return
	flash_parent.add_child(flash)
	flash.global_position = global_position
	flash.scale = Vector3.ONE * 0.5
	var tween := flash.create_tween()
	tween.tween_property(flash, "scale", Vector3.ONE * 1.8, 0.1)
	tween.tween_callback(flash.queue_free)
