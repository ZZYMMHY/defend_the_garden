class_name GardenCamera
extends Camera3D

var target: Node3D
var arena_center := Vector3.ZERO
var follow_speed := 4.2
var offset := Vector3(0.0, 14.5, 13.0)


func _ready() -> void:
	projection = Camera3D.PROJECTION_ORTHOGONAL
	size = 20.5
	near = 0.1
	far = 80.0
	current = true


func _process(delta: float) -> void:
	var focus := arena_center
	if is_instance_valid(target):
		focus = arena_center.lerp(target.global_position, 0.34)
		focus.x = clampf(focus.x, -3.6, 3.6)
		focus.z = clampf(focus.z, -2.2, 2.2)
	var desired_position := focus + offset
	global_position = global_position.lerp(
		desired_position,
		1.0 - exp(-follow_speed * delta)
	)
	look_at(focus + Vector3.UP * 0.45, Vector3.UP)
