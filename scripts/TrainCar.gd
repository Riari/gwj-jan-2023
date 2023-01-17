extends Spatial

signal collision_detected(this, node)

func on_body_entered(node: Node):
	emit_signal("collision_detected", self, node)
