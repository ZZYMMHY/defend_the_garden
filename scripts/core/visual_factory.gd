class_name VisualFactory
extends RefCounted


static func make_material(
		color: Color,
		emission_color: Color = Color(0.0, 0.0, 0.0, 0.0),
		roughness: float = 0.82
	) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	if emission_color.a > 0.0:
		material.emission_enabled = true
		material.emission = emission_color
		material.emission_energy_multiplier = 2.1
	return material


static func add_box(
		parent: Node,
		node_name: String,
		size: Vector3,
		position: Vector3,
		color: Color,
		material_override: Material = null
	) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = position
	instance.material_override = material_override if material_override != null else make_material(color)
	parent.add_child(instance)
	return instance


static func add_sphere(
		parent: Node,
		node_name: String,
		radius: float,
		position: Vector3,
		color: Color,
		scale_value: Vector3 = Vector3.ONE,
		material_override: Material = null
	) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = position
	instance.scale = scale_value
	instance.material_override = material_override if material_override != null else make_material(color)
	parent.add_child(instance)
	return instance


static func add_cylinder(
		parent: Node,
		node_name: String,
		radius: float,
		height: float,
		position: Vector3,
		color: Color,
		material_override: Material = null
	) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = position
	instance.material_override = material_override if material_override != null else make_material(color)
	parent.add_child(instance)
	return instance


static func add_capsule(
		parent: Node,
		node_name: String,
		radius: float,
		height: float,
		position: Vector3,
		color: Color
	) -> MeshInstance3D:
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = position
	instance.material_override = make_material(color)
	parent.add_child(instance)
	return instance
