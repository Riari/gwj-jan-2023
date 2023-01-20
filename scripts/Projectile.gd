extends Spatial

var launched = false
var speed = 5.0

func launch():
	launched = true

func explode():
	get_node("/root/Spatial/VFXController").spawn_explosion_at(global_transform)
	queue_free()

func _process(delta):
	if not launched:
		return

	translate(Vector3(0, 0, -(delta * speed)))