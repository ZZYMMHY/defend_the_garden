class_name GardenCore
extends Node3D

signal health_changed(current: float, maximum: float)
signal destroyed

const VisualFactory = preload("res://scripts/core/visual_factory.gd")

var max_health := 220.0
var health := 220.0
var active := true
var _visual_root: Node3D


func _ready() -> void:
	name = "GardenCore"
	add_to_group("garden_core")
	_build_visuals()
	health_changed.emit(health, max_health)


func take_damage(amount: float) -> void:
	if not active:
		return
	health = maxf(0.0, health - amount)
	health_changed.emit(health, max_health)
	_pulse_damage()
	if health <= 0.0:
		active = false
		destroyed.emit()


func restore_full() -> void:
	health = max_health
	active = true
	health_changed.emit(health, max_health)


func _build_visuals() -> void:
	_visual_root = Node3D.new()
	_visual_root.name = "FlowerVisual"
	add_child(_visual_root)

	VisualFactory.add_cylinder(
		_visual_root,
		"Soil",
		1.45,
		0.4,
		Vector3(0.0, 0.2, 0.0),
		Color("#523823")
	)
	VisualFactory.add_cylinder(
		_visual_root,
		"GrassRing",
		1.22,
		0.18,
		Vector3(0.0, 0.48, 0.0),
		Color("#4f9d4b")
	)
	VisualFactory.add_cylinder(
		_visual_root,
		"Stem",
		0.16,
		1.8,
		Vector3(0.0, 1.35, 0.0),
		Color("#4cac45")
	)

	var glow_material := VisualFactory.make_material(
		Color("#ffe66e"),
		Color(1.0, 0.55, 0.08, 1.0),
		0.46
	)
	VisualFactory.add_sphere(
		_visual_root,
		"FlowerHeart",
		0.48,
		Vector3(0.0, 2.3, 0.0),
		Color("#ffe66e"),
		Vector3.ONE,
		glow_material
	)

	for index in 6:
		var angle := TAU * float(index) / 6.0
		var petal_position := Vector3(cos(angle) * 0.72, 2.3, sin(angle) * 0.72)
		VisualFactory.add_sphere(
			_visual_root,
			"Petal%d" % index,
			0.42,
			petal_position,
			Color("#fff5d4"),
			Vector3(1.25, 0.6, 0.85)
		)

	var light := OmniLight3D.new()
	light.name = "GardenGlow"
	light.position = Vector3(0.0, 2.5, 0.0)
	light.light_color = Color("#ffd978")
	light.light_energy = 2.4
	light.omni_range = 6.0
	light.shadow_enabled = false
	_visual_root.add_child(light)


func _pulse_damage() -> void:
	if not is_instance_valid(_visual_root):
		return
	var tween := create_tween()
	tween.tween_property(_visual_root, "scale", Vector3(1.12, 0.86, 1.12), 0.07)
	tween.tween_property(_visual_root, "scale", Vector3.ONE, 0.12)
