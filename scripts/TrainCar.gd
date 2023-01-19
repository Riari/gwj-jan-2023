extends Spatial

signal collision_detected(this, node)

var material
var transitioning = false
var transition_from = 1.0
var transition_to = 0.25
var transition_speed = 1.0
var offset = transition_from

func show():
	visible = true

	var children = get_children()

	for child in children:
		if not child is MeshInstance:
			continue

		material = child.get_surface_material(0)
		material.set_shader_param("offset", transition_from)

	transitioning = true

func _process(delta):
	if not transitioning:
		return

	offset -= delta * transition_speed

	if offset <= transition_to:
		transitioning = false
		remove_materials()
		return

	material.set_shader_param("offset", offset)

func remove_materials():
	var children = get_children()

	for child in children:
		if not child is MeshInstance:
			continue

		for i in child.get_surface_material_count():
			child.set_surface_material(i, null)

func on_body_entered(node: Node):
	emit_signal("collision_detected", self, node)
